//
//  RSSFeedDelegate.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-20.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

//
// Protocol: RSSFeedDelegate
//
// Delegates to handle callbacks for RSSFeed
//
@objc protocol RSSFeedDelegate{
    
    //
    // Method called when the RSS feed begins downloading
    //
    optional func rssFeedBeginDownload()
    
    //
    // Method called when the RSS Feed is downloaded successfully
    //
    optional func rssFeedDownloadSuccess()
    
    //
    // Method called when the RSS feed fails to successfully download
    //
    optional func rssFeedDownloadFailure()
}