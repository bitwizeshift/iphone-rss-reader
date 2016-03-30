//
//  RSSEntry.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

//
// Class: RSSEntry
//
// This class is used to contain entries in an RSS Feed. It is a simple
// POD datatype intended to passed by reference for the sole purpose of
// containing the various pieces of information used in the RSSParser
//
class RSSEntry : NSObject, NSCoding, NSCopying{
    
    //------------------------------------------------------------------------
    // MARK: - Public Attributes
    //------------------------------------------------------------------------
    
    // All Optional Elements technically (according to the standard). 
    // They are all, however, the most common elements
    var title            : String = "";
    var link             : NSURL? = nil;
    var pubDate          : String = "";
    var author           : String = "";
    var entryDescription : String = "";
    var category         : String = "";
    
    // Optional data in the header
    var imageURL         : NSURL? = nil;
    var imageData        : NSData? = nil;
    
    //------------------------------------------------------------------------
    // MARK: - Private Static Members
    //------------------------------------------------------------------------
    
    private static let TITLE_KEY   = "rssEntryTitleKey"
    private static let LINK_KEY    = "rssEntryLinkKey"
    private static let PUBDATE_KEY = "rssEntryPubDateKey"
    private static let AUTHOR_KEY  = "rssEntryAuthorKey"
    private static let DESCRIPTION_KEY = "rssEntryDescriptionKey"
    private static let CATEGORY_KEY = "rssEntryCategoryKey"
    
    private static let IMG_URL_KEY  = "rssEntryImgURLKey"
    private static let IMG_DATA_KEY = "rssEntryImgDataKey"
    
    //------------------------------------------------------------------------
    // MARK: - Constructors
    //------------------------------------------------------------------------
    
    //
    // Empty constructor
    //
    override init() {
        
    }
    
    //
    // Constructs a RSSEntry from a decoder
    //
    required init?(coder decoder: NSCoder) {
        print("Decoding RSSEntry")
        title     = decoder.decodeObjectForKey(RSSEntry.TITLE_KEY) as! String
        link      = decoder.decodeObjectForKey(RSSEntry.LINK_KEY) as? NSURL
        pubDate   = decoder.decodeObjectForKey(RSSEntry.PUBDATE_KEY) as! String
        author    = decoder.decodeObjectForKey(RSSEntry.AUTHOR_KEY) as! String
        entryDescription = decoder.decodeObjectForKey(RSSEntry.DESCRIPTION_KEY) as! String
        category  = decoder.decodeObjectForKey(RSSEntry.CATEGORY_KEY) as! String
        imageURL  = decoder.decodeObjectForKey(RSSEntry.IMG_URL_KEY) as? NSURL
        imageData = decoder.decodeObjectForKey(RSSEntry.IMG_DATA_KEY) as? NSData
    }
    
    //------------------------------------------------------------------------
    // MARK: - NSCoding and NSCopying Delegates
    //------------------------------------------------------------------------
    
    //
    // Encodes the RSSEntry with the coder
    //
    func encodeWithCoder(coder: NSCoder) {
        
        print("Encoding RSSEntry")

        coder.encodeObject(title, forKey:  RSSEntry.TITLE_KEY)
        coder.encodeObject(link, forKey:   RSSEntry.LINK_KEY)
        coder.encodeObject(pubDate, forKey: RSSEntry.PUBDATE_KEY)
        coder.encodeObject(author, forKey: RSSEntry.AUTHOR_KEY)
        coder.encodeObject(entryDescription, forKey: RSSEntry.DESCRIPTION_KEY)
        coder.encodeObject(category, forKey: RSSEntry.CATEGORY_KEY)
        coder.encodeObject(imageURL, forKey: RSSEntry.IMG_URL_KEY)
        coder.encodeObject(imageData, forKey: RSSEntry.IMG_DATA_KEY)
    }
    
    //
    // Copy the zone of the RSSEntry
    //
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = RSSEntry()
        
        copy.title = self.title;
        copy.link  = self.link
        copy.pubDate = self.pubDate
        copy.author = self.author
        copy.entryDescription = self.entryDescription
        copy.category = self.category
        copy.imageURL = self.imageURL
        copy.imageData = self.imageData
        
        return copy
    }
}

func == ( lhs : RSSEntry, rhs : RSSEntry ) -> Bool {
    if let lhsLink = lhs.link{
        if let rhsLink = rhs.link{
            return lhsLink.absoluteString == rhsLink.absoluteString;
        }
    }
    return false
}

func != ( lhs : RSSEntry, rhs : RSSEntry ) -> Bool {
    return !(lhs==rhs)
}
