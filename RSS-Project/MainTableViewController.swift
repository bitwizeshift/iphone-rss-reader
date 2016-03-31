//
//  MainTableViewController.swift
//  RSS-Project
//
//  Created by Tomas Baena on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import UIKit

@objc
protocol MainTableViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}
class MainTableViewController: UITableViewController, RSSParserDelegate, RSSFeedDelegate {
    
    //------------------------------------------------------------------------
    // MARK: - Public Attributes
    //------------------------------------------------------------------------

    var delegate : MainTableViewControllerDelegate?

    //------------------------------------------------------------------------
    // MARK: - Private Attributes
    //------------------------------------------------------------------------

    private var indicator = RefCountedIndicator()

    private var collection : RSSCollection? = nil
    private var entries    : [RSSEntry]?    = nil
    
    //------------------------------------------------------------------------
    // MARK: - Actions
    //------------------------------------------------------------------------
    
    //
    // Action for opening the right menu
    //
    @IBAction func openRightMenu(sender: AnyObject) {
        delegate?.toggleRightPanel?()
    }
    
    //
    // Action for opening the left menu
    //
    @IBAction func openSideMenu(sender: AnyObject) {
        delegate?.toggleLeftPanel?()
        
    }
    
    //------------------------------------------------------------------------
    // MARK: - View Loading
    //------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        collection = RSSSharedCollection.getInstance().getCollection()
        collection!.delegate = self
        //collection!.addFeedURL( NSURL(string: "http://rss.cbc.ca/lineup/topstories.xml")! )
        collection!.addFeedURL( NSURL(string: "http://rss.cnn.com/rss/edition.rss")! )

        collection!.refresh( false );
        entries = collection!.entries
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

    //------------------------------------------------------------------------
    // MARK: - Table View Data Source
    //------------------------------------------------------------------------

    //
    // Section indices for the table view
    //
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var keys = [String]()
        for feed in collection!.feeds{
            if !feed.channelTitle.isEmpty && !keys.contains( feed.channelTitle[0].uppercaseString ){
                keys.append( feed.channelTitle[0].uppercaseString )
            }
        }
        return keys
    }

    //
    // The number of sections in this Table
    //
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return collection!.feeds.count
    }

    //
    // The title for the individual section
    //
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return collection!.feeds[section].channelTitle
    }

    //
    // The number of rows in the section
    //
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return collection!.feeds[section].entries.count
    }
    
    //
    // Gets the cell for the table
    //
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let entry = entries![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("MainFeedCell", forIndexPath: indexPath) as! MainTableViewCell
        if let data = entry.imageData {
            cell.storyImg.image  = UIImage( data: data )
        }
        
        cell.storyTitle.text = entry.title
        cell.storyCategory.text = entry.category

        return cell
    }

    
    //
    // Override to support conditional editing of the table view.
    //
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    //
    // Override to support editing the table view.
    //
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // TODO: Add to block list
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    //------------------------------------------------------------
    // MARK: - Navigation
    //------------------------------------------------------------
    
    //
    // Pass the web-view entry
    //
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "goToWebView") {
            let detailVC = segue!.destinationViewController as! WebViewController
            detailVC.entry = self.entries![tableView.indexPathForSelectedRow!.row]
        }
    }
    
    //------------------------------------------------------------
    // MARK: - RSSParser Delegates
    //------------------------------------------------------------
    
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
        entries = collection!.entriesChronological
        self.tableView.reloadData()
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
        self.tableView.reloadData()
    }
    
    //
    // Method called when image is not downloaded
    //
    func rssImageDownloadFailure( index: Int ){
        print("Unable to download image " + String(index) )
        indicator.disable()
        self.tableView.reloadData()
    }
    
    //------------------------------------------------------------
    // MARK: - RSSFeed Delegates
    //------------------------------------------------------------
    
    //
    // Feed is starting to download, enable status-indicator
    //
    func rssFeedBeginDownload(){
        print("Start Download")
        indicator.enable()
    }
    
    //
    // Method called when the RSS Feed is downloaded successfully
    //
    func rssFeedDownloadSuccess(){
        entries = collection!.entriesAlphabetical
        self.tableView.reloadData()
        
        print("Complete download")
        indicator.disable()
        
    }
    
    //
    // Method called when the RSS feed fails to successfully download
    //
    func rssFeedDownloadFailure(){
        print("Failed to download")
        indicator.disable()
    }
    
    //
    // Method called when the RSS feed downloads and updates the new feed
    //
    func rssFeedUpdated(){
        entries = collection!.entriesChronological
        self.tableView.reloadData()
    }
    
    //
    // Method called when an image is about to be downloaded
    //
    func rssFeedBeginImageDownload( index : Int, entry : RSSEntry? ){
        indicator.enable()
        print("Downloading image \(index)")
    }
    
    //
    // Method called when an image is downloaded
    //
    func rssFeedImageDownloaded( index : Int, entry : RSSEntry? ){
        self.tableView.reloadData()
        
        print("[Success] Image \(index) downloaded")
        indicator.disable()
    }
    
    //
    // Method called when the RSS feed fails to successfully download
    //
    func rssFeedImageNotDownloaded( index : Int, entry : RSSEntry? ){
        self.tableView.reloadData()
        
        print("[Failure] Image \(index) failed to download")
        indicator.disable()
    }
}


extension ContainerViewController: UIGestureRecognizerDelegate {
    // MARK: Gesture recognizer
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        switch(recognizer.state) {
        case .Began:
            if (currentState == .BothCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                }
//                else {
//                    addRightPanelViewController()
//                }
                
                showShadowForCenterViewController(true)
            }
        case .Changed:
            if ((gestureIsDraggingFromLeftToRight || currentState == .LeftPanelExpanded) && currentState != .RightPanelExpanded) {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                recognizer.setTranslation(CGPointZero, inView: view)
            }else{
                
            }
        case .Ended:
            if (sideTableViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(hasMovedGreaterThanHalfway)
            }
//            else if (rightTableViewController != nil) {
//                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
//                animateRightPanel(hasMovedGreaterThanHalfway)
//            }
        default:
            break
        }
    }
    
}

extension MainTableViewController: RightTableViewControllerDelegate {
    func filterSelected(filter: String) {

        //        imageView.image = animal.image
        //        titleLabel.text = animal.title
        //        creatorLabel.text = animal.creator
        
        delegate?.collapseSidePanels?()
    }
}

extension MainTableViewController: SideTableViewControllerDelegate {
    func categorySelected(category: String) {
//        imageView.image = animal.image
//        titleLabel.text = animal.title
//        creatorLabel.text = animal.creator
        
        delegate?.collapseSidePanels?()
    }
}

