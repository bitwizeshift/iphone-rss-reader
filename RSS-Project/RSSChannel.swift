//
//  RSSChannel.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

//
// Class: RSSChannel
//
// This class represents a channel for a specific RSS Feed. Channels contain
// the feed from
//
class RSSChannel : NSObject, NSCoding, NSCopying{
    
    //------------------------------------------------------------------------
    // MARK: - Private Attributes
    //------------------------------------------------------------------------
    
    private var rssEntries   : [RSSEntry] = [RSSEntry]()

    //------------------------------------------------------------------------
    // MARK: - Public Attributes
    //------------------------------------------------------------------------
    
    // Required Elements
    var title              : String = "";
    var channelDescription : String = "";
    var link               : NSURL? = nil;
    
    // Optional Elements
    var imageURL    : NSURL?  = nil;
    var imageData   : NSData? = nil;
    
    var category    : String? = nil;
    var lastBuild   : NSDate? = nil;
    var skipDays    : String? = nil;
    var skipHours   : String? = nil;
    
    //------------------------------------------------------------------------
    // MARK: - Private Static Members
    //------------------------------------------------------------------------
    
    // Required
    private static let TITLE_KEY      = "rssChannelTitleKey"
    private static let DESC_KEY       = "rssChannelDescKey"
    private static let LINK_KEY       = "rssChannelLinkKey"
    private static let ENTRIES_KEY    = "rssChannelEntriesKey"
    
    // Optionals
    private static let IMG_URL_KEY    = "rssChannelImgUrlKey"
    private static let CATEGORY_KEY   = "rssChannelCategoryKey"
    private static let LASTBUILD_KEY  = "rssChannelLastBuildKey"
    private static let SKIP_DAYS_KEY  = "rssChannelSkipDaysKey"
    private static let SKIP_HOURS_KEY = "rssChannelSkipHoursKey"
    
    //------------------------------------------------------------------------
    // MARK: - Constructors
    //------------------------------------------------------------------------
    
    //
    // Initializes an empty deck
    //
    override init(){
        
    }
    
    //
    // Initializes a RSSChannel that decodes data
    //
    required init?(coder decoder: NSCoder) {
        
        print("Decoding RSSChannel")
        // Required
        title   = (decoder.decodeObjectForKey(RSSChannel.TITLE_KEY) as! String)
        link    = (decoder.decodeObjectForKey(RSSChannel.LINK_KEY) as? NSURL)
        rssEntries = (decoder.decodeObjectForKey(RSSChannel.ENTRIES_KEY) as! [RSSEntry])
        
        // Optionals
        imageURL  = (decoder.decodeObjectForKey(RSSChannel.IMG_URL_KEY) as? NSURL);
        category  = (decoder.decodeObjectForKey(RSSChannel.CATEGORY_KEY) as? String);
        lastBuild = (decoder.decodeObjectForKey(RSSChannel.LASTBUILD_KEY) as? NSDate);
        skipDays  = (decoder.decodeObjectForKey(RSSChannel.SKIP_DAYS_KEY) as? String);
        skipHours = (decoder.decodeObjectForKey(RSSChannel.SKIP_HOURS_KEY) as? String);
    }

    //------------------------------------------------------------------------
    // MARK: - Public Properties
    //------------------------------------------------------------------------

    //
    // Returns the entries as a read-only list
    //
    var entries : [RSSEntry]{
        get{
            return rssEntries;
        }
    }

    //------------------------------------------------------------------------
    // MARK: - Data Manipulation
    //------------------------------------------------------------------------
    
    //
    // Clears all entries from this Channel
    //
    func clearEntries(){
        rssEntries.removeAll()
    }
    
    //
    // Adds entries by only appending new entries
    //
    func addEntry( entry : RSSEntry ) -> Bool{
        for e in rssEntries {
            if(e == entry){
                return false
            }
        }
        rssEntries.append(entry);
        return true;
    }
    
    func removeEntry( entry : RSSEntry ){
        
    }
    
    //------------------------------------------------------------------------
    // MARK: - NSCoding and NSCopying Delegates
    //------------------------------------------------------------------------
    
    //
    // Encodes the RSSChannel with the coder
    //
    func encodeWithCoder(coder: NSCoder) {
        
        print("Encoding RSSChannel")

        // Required
        coder.encodeObject(title, forKey:  RSSChannel.TITLE_KEY)
        coder.encodeObject(link, forKey:   RSSChannel.LINK_KEY)
        coder.encodeObject(entries, forKey: RSSChannel.ENTRIES_KEY)
        
        // Optionals
        coder.encodeObject(imageURL, forKey: RSSChannel.IMG_URL_KEY)
        coder.encodeObject(category, forKey: RSSChannel.CATEGORY_KEY)
        coder.encodeObject(lastBuild, forKey: RSSChannel.LASTBUILD_KEY)
        coder.encodeObject(skipDays, forKey: RSSChannel.SKIP_DAYS_KEY)
        coder.encodeObject(skipHours, forKey: RSSChannel.SKIP_HOURS_KEY)
    }
    
    //
    // Copy the zone of the RSSChannel
    //
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = RSSChannel()
        // required
        copy.title   = self.title
        copy.link    = self.link
        copy.rssEntries = self.rssEntries
        
        // Optionals
        copy.imageURL  = self.imageURL
        copy.category  = self.category
        copy.lastBuild = self.lastBuild
        copy.skipDays  = self.skipDays
        copy.skipHours = self.skipHours
        
        return copy
    } //copyWithZone
}

func == ( lhs : RSSChannel, rhs : RSSChannel ) -> Bool {
    if let lhsLink = lhs.link{
        if let rhsLink = rhs.link{
            return lhsLink.absoluteString == rhsLink.absoluteString;
        }
    }
    return false
}

func != ( lhs : RSSChannel, rhs : RSSChannel ) -> Bool {
    return !(lhs==rhs)
}