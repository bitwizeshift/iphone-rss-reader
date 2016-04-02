//
//  SideTableViewController.swift
//  RSS-Project
//
//  Created by Tomas Baena on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import UIKit

//
// Protocol: SideTableViewControllerDelegate
//
// This delegate handler is used for handling communication
// between the MainTableView and the SideTableView
//
protocol SideTableViewControllerDelegate {

    //
    // Adds a feed given the URL String
    //
    func addFeed( urlString : String ) -> Bool
    
    //
    // Removes a channel given the index of the string
    //
    func removeFeed( index : Int )
    
    //
    // Filters the entries by source
    //
    func filterBySource( index : Int )
    
    //
    // Number of feeds
    //
    func numberOfFeeds() -> Int;
    
    //
    // Retrieve the feed at the specified index
    //
    func feedAtIndex( index: Int ) -> RSSFeed
    
}

//
// Controller: SideTableView
//
// This controller manages the side-table view, used for filtering and
// adding new feeds to the system
//
class SideTableViewController: UITableViewController {
    var delegate: SideTableViewControllerDelegate?
    @IBOutlet weak var newSourceField: UITextField!
    var editMode = false


    override func viewDidLoad() {
        super.viewDidLoad()
        //Looks for single or multiple taps.
        newSourceField.autocorrectionType = .No
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        // Long tap recognizer for deleting sources
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.view.addGestureRecognizer(longPressRecognizer)
        //Short tap recognizer for selecting source
        let shortPressRecognizer = UITapGestureRecognizer(target: self, action: "shortPress:")
        self.view.addGestureRecognizer(shortPressRecognizer)
    }
    //
    //Called when long press occurred
    //
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
        
            let touchPoint = longPressGestureRecognizer.locationInView(self.view)
            if let indexPath = self.tableView.indexPathForRowAtPoint(touchPoint) {
                if let feed = delegate?.feedAtIndex( indexPath.row ){
                    let deleteMsg = "Are you sure you wish to delete " + feed.channelTitle+"?"
                    let refreshAlert = UIAlertController(title: "Delete", message: deleteMsg, preferredStyle: UIAlertControllerStyle.Alert)
                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
                    }))
                    refreshAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive
                        , handler: { (action: UIAlertAction!) in
                        self.delegate?.removeFeed(indexPath.row)
                            self.tableView.reloadData()
                    }))
                    presentViewController(refreshAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //
    // Called when short press occured
    //
    func shortPress(shortPressGesturRecognizer: UITapGestureRecognizer){
            let touchPoint = shortPressGesturRecognizer.locationInView(self.view)
            if let indexPath = self.tableView.indexPathForRowAtPoint(touchPoint) {
                delegate?.filterBySource( indexPath.row)
            }
    }
    
    //
    //Calls this function when the tap is recognized.
    //
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //
    // ADD New URL
    //
    @IBAction func editSources(sender: AnyObject) {
        if (editMode){
            super.setEditing(false, animated: true)
            self.tableView.setEditing(false, animated: true)
            editMode = false
        }else{
            super.setEditing(true, animated: true)
            self.tableView.setEditing(true, animated: true)
            editMode = true
        }
        
    }
    //
    //  ADD New URL
    //
    @IBAction func addSource(sender: AnyObject) {
        print(self.newSourceField.text)
        if let urlString = self.newSourceField.text{
            if urlString.isEmpty{
                let alert = UIAlertController(title: "Empty Input", message: "Please provide a URL before adding", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }else if delegate!.addFeed( urlString ){
                self.tableView.reloadData()
            }else{
                if NSURL( string: urlString ) == nil {
                    let alert = UIAlertController(title: "URL Invalid", message: "Feed at url \(urlString) is not valid!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }else{
                    let alert = UIAlertController(title: "Feed Exists", message: "Feed at url \(urlString) already exists!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
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
        return (delegate?.numberOfFeeds())!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.filterBySource( indexPath.row )
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SideMenuCell", forIndexPath: indexPath) as! SideTableViewCell

        if let feed = delegate?.feedAtIndex( indexPath.row ){
            cell.sourceLabel.text = feed.channelTitle
            if let data = feed.channelImageData {
                cell.sourceImg.image = UIImage( data: data )
            }
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }


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

}
