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
    
    var updateTimer : NSTimer? = nil

    //------------------------------------------------------------------------
    // MARK: - Private Attributes
    //------------------------------------------------------------------------
    
    // The function type for ordering the data
    typealias orderFuncType = ()->()

    private var indicator = RefCountedIndicator()
    private var collection : RSSCollection? = nil
    
    private var sections   : [String]       = [String]()
    private var entries    : [[RSSEntry]]   = [[RSSEntry]]()
    
    private var orderFunc  : orderFuncType? = nil;
    
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
        self.orderFunc = orderByChannel
        
        collection = RSSSharedCollection.getInstance().getCollection()
        collection!.delegate = self
        //collection!.addFeedURL( NSURL(string: "http://rss.cbc.ca/lineup/topstories.xml")! )
        //collection!.addFeedURL( NSURL(string: "http://www.nbcnewyork.com/news/top-stories/?rss=y&embedThumb=y&summary=y")! )
        //collection!.addFeedURL( NSURL(string: "http://rss.cnn.com/rss/cnn_topstories.rss")! )
        //collection!.addFeedURL( NSURL(string: "http://feeds.feedburner.com/patheos/igFf?format=xml")! )
        
        

        collection!.refresh( false );
        
        //enable pull down refresh
        self.refreshControl?.addTarget(self, action: "pullDownRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Set update timer
        self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(5*60.0, target: self, selector: "refresh", userInfo: nil, repeats: true)
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    //------------------------------------------------------------------------
    // MARK: - Ordering
    //------------------------------------------------------------------------

    func orderByChronological(){
        // Reset data
        self.sections = [String]()
        self.entries  = [[RSSEntry]]()
        
        self.sections.append("Chronological")
        self.entries.append( self.collection!.entriesChronological )
    }
    
    func orderByAlphabetical(){
        // Reset data
        self.sections = [String]()
        self.entries  = [[RSSEntry]]()
        
        self.sections.append("Alphabetical")
        self.entries.append( self.collection!.entriesAlphabetical )
    }

    
    //
    // Arranges all the feeds by channels
    //
    func orderByChannel(){
        
        // Reset data
        self.sections = [String]()
        self.entries  = [[RSSEntry]]()
        
        // Alphabetize the feeds
        let feeds = collection!.feeds.sort{ return $0.channelTitle < $1.channelTitle }

        // Add the data
        for feed in feeds{
            self.sections.append(feed.channelTitle);
            self.entries.append(feed.entries);
        }
    }
    
    //
    // Arranges all the feeds by favorites
    //
    func orderByFavorites(){
        
        // Reset data
        self.sections = [String]()
        self.entries  = [[RSSEntry]]()

        // Set up the data
        self.sections.append("Bookmarked")
        self.entries.append(collection!.favorites)
        
    }
    
    //
    // Reorders the RSS Data and reloads the table
    //
    func reorder(){
        if collection!.feeds.count == 0{
            self.sections = [String]()
            self.entries  = [[RSSEntry]]()
        }else if orderFunc != nil{
            // This syntax is retarded, Apple.
            self.orderFunc?()
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }

    //
    // Refresh all data
    //
    func refresh(){
        collection!.refresh(false)
    }
    
    //
    // Pull Down - Refresh Table
    //
    func pullDownRefresh(refreshControl: UIRefreshControl) {
        //Refresh
        print("Refreshing table")
        self.refresh()
        refreshControl.endRefreshing()
    }
    
    //------------------------------------------------------------------------
    // MARK: - Table View Data Source
    //------------------------------------------------------------------------

    //
    // The number of sections in this Table
    //
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.sections.count
    }

    //
    // The title for the individual section
    //
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.sections.count > 0{
            return self.sections[section]
        }else{
            return nil
        }
    }

    //
    // The number of rows in the section
    //
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if( self.entries.count > 0 ){
            return self.entries[section].count
        }else{
            return 0;
        }
    }
    
    //
    // Gets the cell for the table
    //
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let entry = self.entries[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MainFeedCell", forIndexPath: indexPath) as! MainTableViewCell
        if let data = entry.imageData {
            cell.storyImg.image  = UIImage( data: data )
        }else{
            // TODO: Set some default image for one not found
        }
        
        let fromFormatter = NSDateFormatter()
        fromFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        let toFormatter = NSDateFormatter()
        toFormatter.dateFormat = "EEEE, dd MMMM YYYY h:mm a"
        
        
        cell.storyTitle.text   = entry.title
        
        if let date = fromFormatter.dateFromString(entry.pubDate){
            cell.storyPubDate.text = toFormatter.stringFromDate(date)
        }else{
            cell.storyPubDate.text = "Unknown"
        }

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
        // Intentionally left empty
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        // Get the cell from indexPath.section and indexPath.row
        let entry = self.entries[indexPath.section][indexPath.row]
        
        let isFavorite = collection!.isFavorite( entry )
        
        var result = [UITableViewRowAction]()
        
        print( isFavorite )
        if isFavorite{
            let favorite = UITableViewRowAction(style: .Destructive, title: "Unbookmark", handler: { (action, indexPath) in
                self.collection!.removeFavorite( entry )
                self.reorder()
            })
            result.append(favorite)
        }else{
            let favorite = UITableViewRowAction(style: .Normal, title: "Bookmark", handler: { (action, indexPath) in
                self.collection!.addFavorite( entry )
                self.reorder()
            })
            result.append(favorite)
        }
        return result
    }
    
    //------------------------------------------------------------
    // MARK: - Navigation
    //------------------------------------------------------------
    
    //
    // Pass the web-view entry
    //
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "goToWebView") {
            let section = tableView.indexPathForSelectedRow!.section
            let row = tableView.indexPathForSelectedRow!.row
            
            let entry = self.entries[section][row]
            let detailVC = segue!.destinationViewController as! WebViewController
            detailVC.entry = entry
            detailVC.collection = collection
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
        //entries = collection!.entriesChronological
        self.reorder()
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
        self.reorder()
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
    
    func rssFeedError( feed: RSSFeed ) {
        let alert = UIAlertController(title: "RSS Feed Error", message: "Feed \(feed.channelTitle) (\(feed.channelURL)) is not a valid feed source. ", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Keep", style: UIAlertActionStyle.Default,handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: UIAlertActionStyle.Destructive, handler: {(alert: UIAlertAction!) in
                self.collection!.removeFeed( feed )
                self.reorder()
                self.delegate?.collapseSidePanels?()
            }))
        self.presentViewController(alert, animated: true, completion: nil)
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
//
// Handles filters being selected from right side panel
//
extension MainTableViewController: RightTableViewControllerDelegate {
    func filterSelected(filter: Int) {
        if (filter == 0){
            print("Filter by All (Chronological)")
            self.orderFunc = orderByChronological
        }else if(filter == 1){
            print("Filter by All (Alphabetical)")
            self.orderFunc = orderByAlphabetical
        }else if(filter == 2){
            print("Filter by News Source")
            self.orderFunc = orderByChannel
        }else if(filter == 3){
            print("Filter by Bookmarked")
            self.orderFunc = orderByFavorites
        }
        self.reorder()
        
        delegate?.collapseSidePanels?()
    }
}

//
//  Handles Selection of source
//
extension MainTableViewController: SideTableViewControllerDelegate {
    //
    // Adds a feed given the URL String
    //
    func addFeed( urlString : String ) -> Bool{
        var added = false
        if let url = NSURL(string: urlString ){
            added = collection!.addFeedURL( url )
        }
        if added{
            self.refresh()
        }
        self.delegate?.collapseSidePanels?()
        return added
    }
    
    //
    // Removes a channel given the index of the string
    //
    func removeFeed( index : Int ){
        collection!.removeFeed( collection!.feeds[index] )
        self.reorder()
    }
    
    //
    // Filters the entries by source
    //
    func filterBySource( index : Int ){
        let feed = collection!.feeds[index]
        orderFunc = {
            // Reset data
            self.sections = [String]()
            self.entries  = [[RSSEntry]]()
            
            // Set up the data
            self.sections.append(feed.channelTitle)
            self.entries.append(feed.entries)
        }
        self.reorder()
        delegate?.collapseSidePanels?()
    }
    
    //
    // Number of feeds
    //
    func numberOfFeeds() -> Int{
        return collection!.feeds.count
    }
    
    //
    // Retrieve the feed at the specified index
    //
    func feedAtIndex( index: Int ) -> RSSFeed{
        return collection!.feeds[index]
    }
}

