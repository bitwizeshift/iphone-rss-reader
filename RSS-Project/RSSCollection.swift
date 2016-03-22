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
    // MARK: - Public Static Attributes
    //------------------------------------------------------------------------
    
    var feedDelegate   : RSSFeedDelegate?   = nil
    var parserDelegate : RSSParserDelegate? = nil
    
    //------------------------------------------------------------------------
    // MARK: - Private Attributes
    //------------------------------------------------------------------------

    private var rssFeeds    = [RSSFeed]()
    private var favorites   = [RSSEntry]()
    private var blacklisted = [RSSEntry]()
        
    //------------------------------------------------------------------------
    // MARK: - Private Static Attributes
    //------------------------------------------------------------------------
    
    private static let FEEDS_KEY       = "rssCollectionFeedsKey"
    private static let FAVORITES_KEY   = "rssCollectionFavoritesKey"
    private static let BLACKLISTED_KEY = "rssCollectionBlacklistedKey"

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
        rssFeeds    = decoder.decodeObjectForKey(RSSCollection.FEEDS_KEY)       as! [RSSFeed]
        favorites   = decoder.decodeObjectForKey(RSSCollection.FAVORITES_KEY)   as! [RSSEntry]
        blacklisted = decoder.decodeObjectForKey(RSSCollection.BLACKLISTED_KEY) as! [RSSEntry]
    }
    
    //----------------------------------------------------------------------------
    // MARK: - Properties
    //----------------------------------------------------------------------------
    
    //
    // Property for being able to only get the feeds (non-mutating)
    //
    var feeds : [RSSFeed]{
        get{
            return rssFeeds
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
            return entries.sort(){ return $0.pubDate < $1.pubDate }
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
                    if !blacklisted.contains(entry){
                        entries.append(entry)
                    }
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
    // Adds a feed by URL
    //
    // This function returns false if the feed already exists in the collection
    //
    func addFeedURL( url : NSURL ) -> Bool {
        let newfeed = RSSFeed( feedURL: url )
        newfeed.delegate       = self.feedDelegate
        newfeed.parserDelegate = self.parserDelegate
        
        return self.addFeed( newfeed )
    }
    
    //
    // Adds an RSSFeed to the collection
    //
    // This function returns false if the feed already exists in the collection
    //
    func addFeed( feed : RSSFeed ) -> Bool {
        if feeds.contains(feed) {
            return false
        }
        rssFeeds.append(feed)
        return true
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
    // Clears the entire RSSCollection of data, removing all channels, favoritess,
    // and blacklisted entries
    //
    func clear(){
        rssFeeds.removeAll()
        favorites.removeAll()
        blacklisted.removeAll()
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
        coder.encodeObject(favorites, forKey: RSSCollection.FAVORITES_KEY)
        coder.encodeObject(blacklisted, forKey: RSSCollection.BLACKLISTED_KEY)
    }
    
}