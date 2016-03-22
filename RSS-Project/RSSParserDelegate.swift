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
// All methods are marked 'optional', meaning that they do not have to be implemented
// in order for this to compile
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
    
    optional func rssImageBeginDownload( index : Int )
    
    //
    // Method called every time an RSS Image is successfully downloaded
    //
    optional func rssImageDownloadSuccess( index : Int )
    
    //
    // Method called every time an RSS Image is not successfully downloaded
    //
    optional func rssImageDownloadFailure( index : Int )
}