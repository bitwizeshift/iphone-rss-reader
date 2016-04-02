//
//  RSSCollection.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

class RSSCollection : NSObject, NSCoding {
    
    //------------------------------------------------------------------------
    // MARK: - Private Attributes
    //------------------------------------------------------------------------

    private var feedDelegate : RSSFeedDelegate?   = nil
    private var rssFeeds     = [RSSFeed]()
    private var rssFavorites = [RSSEntry]()

    //------------------------------------------------------------------------
    // MARK: - Private Static Attributes
    //------------------------------------------------------------------------
    
    private static let FEEDS_KEY       = "rssCollectionFeedsKey"
    private static let FAVORITES_KEY   = "rssCollectionFavoritesKey"

    //----------------------------------------------------------------------------
    // MARK: - Constructor
    //----------------------------------------------------------------------------

    //
    // Empty initializer
    //
    override init(){
    
    }
    
    //
    // Decoding initializer (for serialization)
    //
    @objc required init?(coder decoder: NSCoder) {
        print("Decoding RSSCollection")
        rssFeeds     = decoder.decodeObjectForKey(RSSCollection.FEEDS_KEY)     as! [RSSFeed]
        rssFavorites = decoder.decodeObjectForKey(RSSCollection.FAVORITES_KEY) as! [RSSEntry]
    }
    
    //----------------------------------------------------------------------------
    // MARK: - Properties
    //----------------------------------------------------------------------------
    
    //
    // Delegate for handling the feed delegates.
    // It retroactively passes the delegate to existing feeds if one is changed.
    //
    var delegate : RSSFeedDelegate?{
        get{
            return self.feedDelegate;
        }
        set(value){
            self.feedDelegate = value;
            for feed in self.feeds{
                feed.delegate = self.feedDelegate
            }
        }
    }
    
    //
    // Property for being able to only get the feeds (non-mutating)
    //
    var feeds : [RSSFeed]{
        get{
            return rssFeeds
        }
    }
    
    //
    // Property to retrieve all entries not in any specified order
    //
    var entries : [RSSEntry]{
        get{
            var e = [RSSEntry]()
            for feed in feeds{
                for entry in feed.entries{
                    e.append(entry)
                }
            }
            return e;
        }
    }
    
    //
    // Property to retrieve all entries in the favorites
    //
    var favorites : [RSSEntry]{
        get{
            return rssFavorites
        }
    }

    //
    // Property to retrieve all entries in a feed sorted chronologically
    //
    var entriesChronological : [RSSEntry]{
        get{
            var entries = [RSSEntry]()
            for feed in feeds{
                for entry in feed.entries{
                    entries.append(entry)
                }
            }
            return entries.sort(){ return $0.pubDate > $1.pubDate }
        }
    }

    //
    // Property to retrieve all entries in a feed sorted alphabetically
    //
    var entriesAlphabetical : [RSSEntry]{
        get{
            var entries = [RSSEntry]()
            for feed in feeds{
                for entry in feed.entries{
                    entries.append(entry)
                }
            }
            return entries.sort(){ return $0.title < $1.title }
        }
    }

    //----------------------------------------------------------------------------
    // MARK: - Update Feed
    //----------------------------------------------------------------------------

    //
    // Updates all RSS feeds in the RSSCollection
    //
    //
    func refresh( forceUpdate : Bool ){
        let rssQueue = dispatch_queue_create("RSS Queue", DISPATCH_QUEUE_CONCURRENT);

        for feed in feeds{
            // Send all refresh methods asynchronously
            dispatch_async(rssQueue,
            {
                feed.refresh( forceUpdate )
            })
        }
    }
    
    //----------------------------------------------------------------------------
    // MARK: - Adding / Removing Feeds
    //----------------------------------------------------------------------------
    
    //
    // Checks if a feed already exists by a URL
    //
    // This function returns true if the feed already exists
    //
    func feedExists( url : NSURL ) -> Bool {
        let newfeed = RSSFeed( feedURL: url )
        for f in feeds{
            if newfeed == f {
                return true
            }
        }
        return false
    }
    
    //
    // Adds a feed by URL
    //
    // This function returns false if the feed already exists in the collection
    //
    func addFeedURL( url : NSURL ) -> Bool {
        let newfeed = RSSFeed( feedURL: url )
        newfeed.delegate = self.feedDelegate
        
        return self.addFeed( newfeed )
    }
    
    //
    // Adds an RSSFeed to the collection
    //
    // This function returns false if the feed already exists in the collection
    //
    func addFeed( feed : RSSFeed ) -> Bool {
        
        for f in feeds{
            if f == feed{
                return false;
            }
        }
        feed.delegate = self.feedDelegate
        rssFeeds.append(feed)
        return true
    }
    
    //
    // Adds an entry to the list of favorited entries
    //
    func addFavorite( entry : RSSEntry ) -> Bool {
        if !isFavorite( entry ){
            rssFavorites.append( entry )
            return true
        }
        return false
    }
    
    //
    // Removes a favorite from the favorites section
    //
    func removeFavorite( entry : RSSEntry ) -> Bool {
        let before = rssFeeds.count
        rssFavorites = rssFavorites.filter(){ $0 != entry }
        let after = rssFeeds.count
        
        return before > after
    }
    
    //
    // Is this RSS entry a favorite entry?
    //
    func isFavorite( entry : RSSEntry ) -> Bool {
        for e in rssFavorites{
            if e == entry{
                return true
            }
        }
        return false
    }
    
    //----------------------------------------------------------------------------

    //
    // Removes an RSSFeed from the collection given the URL
    //
    // This function returns false if the feed doesn't exist
    //
    func removeFeedURL( url : NSURL ) -> Bool {
        let key = RSSFeed( feedURL: url )
        
        return self.removeFeed( key )
    }
    
    //
    // Removes an RSSFeed from the collection given the feed
    //
    // This function returns false if the feed doesn't exist
    //
    func removeFeed( feed : RSSFeed ) -> Bool{
        // Filter the feed and check to see if the count has changed
        let before = rssFeeds.count
        rssFeeds = rssFeeds.filter(){ $0 != feed }
        let after = rssFeeds.count
        
        return before > after
    }
    
    //
    // Clears the entire RSSCollection of data, removing all channels and favorites
    //
    func clear(){
        rssFeeds.removeAll()
        rssFavorites.removeAll()
    }
    
    //------------------------------------------------------------------------
    // MARK: - NSCoding Delegates
    //------------------------------------------------------------------------
    
    //
    // Encodes the RSSEntry with the coder
    //
    @objc func encodeWithCoder(coder: NSCoder) {
        
        print("Encoding RSSCollection")
        
        coder.encodeObject(rssFeeds, forKey:  RSSCollection.FEEDS_KEY)
        coder.encodeObject(rssFavorites, forKey: RSSCollection.FAVORITES_KEY)
    }
    
}