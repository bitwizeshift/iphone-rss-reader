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

    var delegate: MainTableViewControllerDelegate?
    var indicator = RefCountedIndicator()

    var collection : RSSCollection? = nil
    var entries    : [RSSEntry]?    = nil

    @IBAction func openRightMenu(sender: AnyObject) {
        delegate?.toggleRightPanel?()
    }
    @IBAction func openSideMenu(sender: AnyObject) {
        delegate?.toggleLeftPanel?()
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        collection = RSSSharedCollection.getInstance().getCollection()
        collection!.delegate = self
        collection!.addFeedURL( NSURL(string: "http://rss.cbc.ca/lineup/topstories.xml")! )
        collection!.addFeedURL( NSURL(string: "http://www.xul.fr/rss.xml")! )
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let entries = entries{
            return entries.count
        }else{
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let entry = entries![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("MainFeedCell", forIndexPath: indexPath) as! MainTableViewCell
        cell.storyImg.image  = UIImage( data: entry.imageData! )
        cell.storyTitle.text = entry.title

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
        
        print("[Success] Image \(index) downloaded")
        indicator.disable()
    }
    
    //
    // Method called when the RSS feed fails to successfully download
    //
    func rssFeedImageNotDownloaded( index : Int, entry : RSSEntry? ){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
        
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
                } else {
                    addRightPanelViewController()
                }
                
                showShadowForCenterViewController(true)
            }
        case .Changed:
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if (sideTableViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(hasMovedGreaterThanHalfway)
            } else if (rightTableViewController != nil) {
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
                animateRightPanel(hasMovedGreaterThanHalfway)
            }
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

