//
//  RSSParser.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

//
// Class: RSSParser
//
// This class handles the parsing of RSS feeds
//
class RSSParser: NSObject, NSXMLParserDelegate {
    
    //----------------------------------------------------------------------------
    // Public Attributes
    //----------------------------------------------------------------------------
    
    // List of RSS Feed data
    var channel = RSSChannel()
    
    // Delegate class for parsing RSS data
    var delegate : RSSParserDelegate? = nil
    
    //----------------------------------------------------------------------------
    // Private Members
    //----------------------------------------------------------------------------
    
    // List of all the channel tags we care about
    static private let CHANNEL_TAGS = ["title","description","link","image","category","lastBuildDate","skipDays","skipHours"]
    
    // List of all the channel image tags we care about
    static private let CHANNEL_IMAGE_TAGS =
        ["url","title","link"]
    
    // List of all the entry tags we care about
    static private var ENTRY_TAGS = ["title","link","pubdate","author","description","category"]
    
    private var currentEntry : RSSEntry? = nil
    private var inCategory      = false
    private var currentElement  = ""
    private var foundCharacters = ""
    private var parser : NSXMLParser?;
    
    //----------------------------------------------------------------------------
    // Constructor
    //----------------------------------------------------------------------------
    
    //
    // Constructs the RSSParser class given the URL to read
    //
    init(_ rssURL: NSURL) {
        super.init()
        parser = NSXMLParser(contentsOfURL: rssURL)
        parser!.delegate = self
    }
    
    init( data: NSData ){
        super.init()
        parser = NSXMLParser(data: data)
        parser!.delegate = self
    }
    
    init( data: NSData, channel : RSSChannel ){
        super.init()
        self.parser = NSXMLParser(data: data)
        self.parser!.delegate = self
        self.channel = channel;
    }
    
    //
    // Begins parsing the document, calling the method onCompletion() after 
    // the parsing is finished
    //
    func parse( onCompletion : ()-> Void){
        parser!.parse()
        onCompletion()
    }
    
    //
    // Parses the document
    //
    func parse(){
        parser!.parse()
    }
    
    //----------------------------------------------------------------------------
    // MARK: - Delegate Methods
    //----------------------------------------------------------------------------
    
    //
    // Called on opening tag of element
    //
    internal func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]){
        // Record only if a category or an item
        if( elementName == "category"){
            inCategory = true
        }else if( elementName == "item"){
            currentEntry = RSSEntry()
        }
        
        currentElement = elementName
    }
    
    //
    // Called on contents of element
    //
    internal func parser(parser: NSXMLParser, foundCharacters string: String) {
        // Only record element characters if there is an open RSSEntry
        
        if inCategory && currentEntry == nil {
            if (RSSParser.CHANNEL_TAGS.contains(currentElement)){
                foundCharacters += string
            }
        } else if currentEntry != nil {
            if (RSSParser.ENTRY_TAGS.contains(currentElement)){
                foundCharacters += string
            }
        }
    }
    
    //
    // Called on ending (closing) tag of element
    //
    internal func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if !foundCharacters.isEmpty{
            if inCategory && currentEntry == nil {
            
            } else if currentEntry != nil {
                let entry = currentEntry!
                
                // Check if the closed tags are of interest
                if elementName == "link"{
                    entry.link = NSURL( string: foundCharacters.trim() )
                }
                else if elementName == "pubDate"{
                    entry.pubDate = foundCharacters.trim();
                }
                else if elementName == "title"{
                    entry.title = foundCharacters.trim();
                }
                else if elementName == "author"{
                    entry.author = foundCharacters.trim();
                }
                else if elementName == "description"{
                    
                    let quoteSet = NSCharacterSet(charactersInString: "\"'")
                    let IMG    = "<img"
                    let SRC    = "src="
                    
                    var source: NSString?
                    
                    let theScanner = NSScanner(string: foundCharacters)
                    theScanner.scanUpToString(IMG, intoString: nil);
                    theScanner.scanString(IMG, intoString: nil)
                    theScanner.scanUpToString(SRC, intoString: nil);
                    theScanner.scanString(SRC, intoString: nil)
                    theScanner.scanUpToCharactersFromSet( quoteSet, intoString: nil ) // Go to starting quote
                    theScanner.scanCharactersFromSet( quoteSet, intoString: nil )
                    theScanner.scanUpToCharactersFromSet( quoteSet, intoString: &source )
                    
                    if let urlString = source as? String{
                        entry.imageURL = NSURL( string: urlString );
                    }else{
                        entry.entryDescription = foundCharacters.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil).trim()
                    }
                }
                else if elementName == "category"{
                    entry.category = foundCharacters.trim();
                }
                else if elementName == "item"{
                    channel.entries.append(currentEntry!)
                    currentEntry = nil
                }
                
                // Reset found characters
                foundCharacters = ""
            }
        }
    }
    
    //
    // Called when the parser begins parsing the document
    //
    internal func parserDidStartDocument(parser: NSXMLParser){
        self.delegate?.rssBeginParsing?()
    }
    
    //
    // Called when the parser finishes parsing the document
    //
    internal func parserDidEndDocument(parser: NSXMLParser) {
        self.delegate?.rssCompleteParsing?()
        var index = 0
        let imageQueue = dispatch_queue_create("Image Queue", DISPATCH_QUEUE_CONCURRENT);
        
        // Download images for channels
        
        
        // Download all images for
        for entry in self.channel.entries {
            let i = index
            self.delegate?.rssImageBeginDownload?(i)
            // Don't dispatch if a URL wasn't discovered
            if let url = entry.imageURL{
                // Dispatch to download the image data
                dispatch_async(imageQueue, {
                    entry.imageData = NSData( contentsOfURL: url )
                    
                    // If the imageData was successfully loaded
                    if entry.imageData != nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.delegate?.rssImageDownloadSuccess?(i)
                        }); //dispatch_asyn
                        // If it wasn't successfully loaded
                    }else{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.delegate?.rssImageDownloadFailure?(i)
                        }); //dispatch_asyn
                    }
                }) //dispatch_asyn
            } else{
                let i = index
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.rssImageDownloadFailure?(i)
                }); //dispatch_asyn
            } // if let url
            index++
        }
    }
    
    //
    // Called during parse errors. Just log the description
    //
    internal func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        print(parseError.description)
    }
    
    //
    // Called during validation errors. Just log the description
    //
    internal func parser(parser: NSXMLParser, validationErrorOccurred validationError: NSError) {
        print(validationError.description)
    }
    
}