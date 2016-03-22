//
//  RSSFeed.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

//
//
//
//
//
@objc protocol RSSFeedDelegate{
    
    //
    // Method called when the parsing begins
    //
    optional func rssFeedBeginDownload()
    
    //
    // Method called when the parsing completes
    //
    optional func rssFeedEndDownload()
    
}

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
class RSSFeed : NSObject, NSCoding{
    
    //------------------------------------------------------------------------
    // MARK: - Private Attributes
    //------------------------------------------------------------------------
    
    private let feedURL     : NSURL;
    private var channel     : RSSChannel = RSSChannel();
    private var recentEntry : NSDate? = nil;
    private var feedData    : NSData = NSData();

    //------------------------------------------------------------------------
    // MARK: - Private Static Attributes
    //------------------------------------------------------------------------
    
    private static let FEED_URL_KEY = "rssFeedFeedURLKey"
    private static let CHANNEL_KEY  = "rssFeedChannelKey"

    //------------------------------------------------------------------------
    // MARK: - Public Attribute
    //------------------------------------------------------------------------
    
    var delegate : RSSFeedDelegate?

    //------------------------------------------------------------------------
    // MARK: - Constructors
    //------------------------------------------------------------------------

    //
    // Constructs an RSSFeed given the url
    //
    init( feedURL : NSURL ){
        self.feedURL = feedURL;
    }
    
    init( feedURL : NSURL, channel : RSSChannel ){
        self.feedURL = feedURL;
        self.channel = channel;
    }
    
    //
    // Constructs a RSSEntry from a decoder
    //
    required init?(coder decoder: NSCoder) {
        feedURL = decoder.decodeObjectForKey(RSSFeed.FEED_URL_KEY) as! NSURL
        channel = decoder.decodeObjectForKey(RSSFeed.CHANNEL_KEY) as! RSSChannel
    }

    //------------------------------------------------------------------------
    // MARK: - Public Attributes
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
        get {
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
    // Updates the RSS Feed by downloading the new file and parsing it.
    //
    // if forceUpdate is true, then it will also erase all elements in the
    // feed and perform a full refresh
    //
    func update( forceUpdate : Bool ){
        
    }
    
    //
    // Refreshes all images in the RSS Feed
    //
    //
    //
    func refreshImages( forceUpdate : Bool ){
        
    }
    
    //
    // Downloads the RSS file to be parsed
    //
    func download(){
        let url: NSURL = feedURL
        let request: NSURLRequest = NSURLRequest(URL: url)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        // Before the download, if a delegate is assigned, run the method
        if let delegate = self.delegate{
            if let beginDownload = delegate.rssFeedBeginDownload{
                beginDownload();
            }
        }
        // Run the download task asynchronously to download the data
        let task = session.dataTaskWithRequest(request, completionHandler:{
            (data, response, error) in
            if let d = data{
                self.feedData = d
                self.update( false )
            }
            
            // Run delegate if one is assigned
            if let delegate = self.delegate{
                if let endDownload = delegate.rssFeedEndDownload{
                    endDownload();
                }
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

        coder.encodeObject(feedURL, forKey: RSSFeed.FEED_URL_KEY)
        coder.encodeObject(channel, forKey: RSSFeed.CHANNEL_KEY)
        
    }

    //------------------------------------------------------------------------
    // MARK: - Saving to and from an archive
    //------------------------------------------------------------------------
    
    //
    // Acquires the data path for this RSSFeed
    //
    private func dataFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        return documentsDirectory.stringByAppendingPathComponent( Settings.filename )
            as String
    }
    
    //
    // Loads the channel from a serialized file
    //
    func load(){ // un-archive saved data
        let filePath = self.dataFilePath()
        
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath)) {
            let data       = NSMutableData(contentsOfFile: filePath)!
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
            
            // If the deck does not exist, construct a new one
            if let optChannel = unarchiver.decodeObjectForKey(Settings.rootKey) as? RSSChannel{
                channel = optChannel
            }
            unarchiver.finishDecoding()
        }
    }
    
    //
    // Save the channel data to a serialized file
    //
    func save(){
        let filePath = self.dataFilePath()

        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject( channel, forKey: Settings.rootKey )
        archiver.finishEncoding()
        data.writeToFile(filePath, atomically: true)
    }

}
