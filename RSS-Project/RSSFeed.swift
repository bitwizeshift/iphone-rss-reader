//
//  RSSFeed.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

//
// Class: RSSFeed
//
// This class represents an rss feed for a particular channel. It is used to
// handle the serialization/deserialization of a particular channel, along with
// extraction of categories and other small pieces of data.
//
// It also handles metadata necessary for determining when to redownload 
// data for a specific feed, such as the most recent entry
//
class RSSFeed : NSObject, NSCoding, RSSParserDelegate{
    
    //------------------------------------------------------------------------
    // MARK: - Private Attributes
    //------------------------------------------------------------------------
    
    private let feedURL     : NSURL;
    private var channel     : RSSChannel = RSSChannel();
    private var recentEntry : NSDate? = nil;
    private var feedData    : NSData = NSData();

    private var parser      : RSSParser? = nil

    //------------------------------------------------------------------------
    // MARK: - Private Static Attributes
    //------------------------------------------------------------------------
    
    private static let FEED_URL_KEY = "rssFeedFeedURLKey"
    private static let CHANNEL_KEY  = "rssFeedChannelKey"

    //------------------------------------------------------------------------
    // MARK: - Public Attribute
    //------------------------------------------------------------------------
    
    var delegate : RSSFeedDelegate? = nil

    //------------------------------------------------------------------------
    // MARK: - Constructors
    //------------------------------------------------------------------------

    //
    // Constructs an RSSFeed given the url
    //
    init( feedURL : NSURL ){
        self.feedURL = feedURL;
    }
    
    //
    // Constructs a RSSEntry from a decoder
    //
    required init?(coder decoder: NSCoder) {
        print("Decoding RSSFeed")
        feedURL = decoder.decodeObjectForKey(RSSFeed.FEED_URL_KEY) as! NSURL
        channel = decoder.decodeObjectForKey(RSSFeed.CHANNEL_KEY) as! RSSChannel
    }

    //------------------------------------------------------------------------
    // MARK: - Public Properties
    //------------------------------------------------------------------------
    
    //
    // Getter to retrieve the channel title
    //
    var channelTitle : String {
        get{
            return channel.title
        }
    }
    
    //
    // Getter to retrieve the channel link
    //
    var channelLink : NSURL? {
        get{
            return channel.link
        }
    }
    
    //
    // Getter to retrieve the channel's image data
    //
    var channelImageData : NSData? {
        get{
            return channel.imageData
        }
    }
    
    //
    // Getter to retrieve entries from an RSS feed
    //
    var entries : [RSSEntry] {
        get{
            return channel.entries
        }
    }
    
    //
    // Getter to retrieve list of all categories in this channel
    //
    var categories : [String] {
        get{
            var cat = [String]();
            for entry in channel.entries{
                // Only add non-empty unique categories
                if !entry.category.isEmpty && !cat.contains(entry.category){
                    cat.append(entry.category)
                }
            }
            return cat
        }
    }
    
    //------------------------------------------------------------------------
    // MARK: - RSS Feed API
    //------------------------------------------------------------------------
    
    //
    // Updates the channel feed
    //
    private func update( clearCache : Bool ){
        if( clearCache ){
            self.channel.clearEntries()
        }
        
        parser = RSSParser( data: self.feedData, channel: channel )
        parser!.delegate = self
        
        parser!.parse(){
            self.recentEntry = NSDate()
        }
    }
    
    //
    // Refreshes the RSS Feed by downloading the new file and parsing it.
    //
    // if clearCache is true, then it will also erase all elements in the
    // feed and perform a full refresh
    //
    func refresh( clearCache : Bool ){
        let url:     NSURL = feedURL
        let request: NSURLRequest = NSURLRequest(URL: url)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        // Before the download, if a delegate is assigned, run the method
        self.delegate?.rssFeedBeginDownload?()
        
        // Run the download task asynchronously to download the data
        let task = session.dataTaskWithRequest(request, completionHandler:{
            (data, response, error) in

            if let d = data{
                self.delegate?.rssFeedDownloadSuccess?()
                self.feedData = d
                self.update( clearCache )
            }else{
                self.delegate?.rssFeedDownloadFailure?()
            }
        })
        task.resume()
    }
    
    //
    // Filters the entries by the name of a given category
    //
    func filterByCategory( category : String ) -> [RSSEntry]{
        return channel.entries.filter(){
            return $0.category == category;
        }
    }
    
    //
    // Filters the RSSEntries by the name of a given author
    //
    func filterByAuthor( author : String ) -> [RSSEntry]{
        return channel.entries.filter(){
            return $0.author == author;
        }
    }
    
    //------------------------------------------------------------------------
    // MARK: - NSCoding and NSCopying Delegates
    //------------------------------------------------------------------------
    
    //
    // Encodes the RSSChannel with the coder
    //
    func encodeWithCoder(coder: NSCoder) {
        print("Encoding RSSFeed")
        coder.encodeObject(feedURL, forKey: RSSFeed.FEED_URL_KEY)
        coder.encodeObject(channel, forKey: RSSFeed.CHANNEL_KEY)
    }
    
    //------------------------------------------------------------------------
    // MARK: - RSSParser Delegates
    //------------------------------------------------------------------------
    
    //
    // Method called when parsing begins
    //
    func rssBeginParsing(){
        
    }
    
    //
    // Method called when the parsing completes
    //
    func rssCompleteParsing(){
        delegate?.rssFeedUpdated?()
    }
    
    //
    // Method called every time an RSS image begins downloading
    //
    func rssImageBeginDownload( index : Int ){
        delegate?.rssFeedBeginImageDownload?( index, entry: entries[index] )
    }
    
    //
    // Method called every time an RSS Image is successfully downloaded
    //
    func rssImageDownloadSuccess( index : Int ){
        delegate?.rssFeedImageDownloaded?( index, entry: entries[index] )
    }
    
    //
    // Method called every time an RSS Image is not successfully downloaded
    //
    func rssImageDownloadFailure( index : Int ){
        delegate?.rssFeedImageNotDownloaded?( index, entry: entries[index] )
    }
}

//------------------------------------------------------------------------
// MARK: - Public Operators
//------------------------------------------------------------------------

func == ( lhs : RSSFeed, rhs : RSSFeed ) -> Bool {
    return lhs.feedURL.absoluteString == rhs.feedURL.absoluteString
}

func != ( lhs : RSSFeed, rhs : RSSFeed ) -> Bool {
    return lhs.feedURL.absoluteString != rhs.feedURL.absoluteString
}