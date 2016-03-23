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

    //
    // Method called hwne the Feed updates
    //
    optional func rssFeedUpdated()
    
    //
    // Method called when an image begins downloading
    //
    optional func rssFeedBeginImageDownload( index : Int, entry : RSSEntry? )
    
    //
    // Method called when an image is downloaded
    //
    optional func rssFeedImageDownloaded( index : Int, entry : RSSEntry? )
    
    //
    // Method called when an image fails to download
    //
    optional func rssFeedImageNotDownloaded( index : Int, entry : RSSEntry? )
}