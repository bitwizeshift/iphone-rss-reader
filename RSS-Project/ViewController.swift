//
//  ViewController.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RSSParserDelegate, RSSFeedDelegate {

    var parser : RSSParser? = nil;
    let URL_PATH: String = "http://rss.cbc.ca/lineup/topstories.xml"
    var count : Int32 = 0;
    
    var collection = RSSCollection()
    
    var indicator = RefCountedIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url: NSURL = NSURL(string: URL_PATH)!
        
        collection.parserDelegate = self
        collection.feedDelegate   = self
                
        print(collection.addFeedURL( url ))
        print(collection.addFeedURL( url ))
        
        print("About to refresh")
        collection.refresh( false );
        print("Finished refreshing")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - RSSParser Delegates
    
    // start element
    //
    
    //
    // Method called when the parsing begins
    //
    func rssBeginParsing(){
        print("Beginning RSS Parsing")
    }
    
    //
    // Method called when the parsing completes
    //
    func rssCompleteParsing(){
        print("Ending RSS Parsing")
    }
    
    func rssImageBeginDownload(index: Int) {
        indicator.enable()
    }
    
    //
    // Method called when image is downloaded
    //
    func rssImageDownloadSuccess( index: Int ){
        print("got image number " + String(index) )
        indicator.disable()
    }
    
    //
    // Method called when image is not downloaded
    //
    func rssImageDownloadFailure( index: Int ){
        print("Unable to download image " + String(index) )
        indicator.disable()
    }

    //
    // Feed is starting to download, enable status-indicator
    //
    @objc func rssFeedBeginDownload(){
        print("Start Download")
        indicator.enable()

    }
    
    //
    // Method called when the RSS Feed is downloaded successfully
    //
    @objc func rssFeedDownloadSuccess(){
        
        print("Complete download")
        indicator.disable()

    }
    
    //
    // Method called when the RSS feed fails to successfully download
    //
    @objc func rssFeedDownloadFailure(){
        print("Failed to download")
        indicator.disable()
    }
}

