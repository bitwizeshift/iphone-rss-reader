//
//  RSSParserDelegate.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

//
// Protocol: RSSParserDelegate
//
// Delegate class used for the RSSParser to dispatch operations at various points
//
@objc protocol RSSParserDelegate{
    
    //
    // Method called when the parsing begins
    //
    optional func rssBeginParsing()
    
    //
    // Method called when the parsing completes
    //
    optional func rssCompleteParsing()
    
    //
    // Method called in the event of an rss parsing error, indicating the line
    // number and string reason for the error.
    //
    //optional func rssError( reason : String, line : Int )
    
    //
    // Method called every time an RSS Image is successfully downloaded
    //
    optional func rssImageDownload( didGetImage index : Int )
    
    //
    // Method called every time an RSS Image is not successfully downloaded
    //
    optional func rssImageDownload( didNotGetImage index : Int )
}