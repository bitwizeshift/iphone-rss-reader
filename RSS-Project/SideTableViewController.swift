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


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //
    // ADD New URL
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
                let alert = UIAlertController(title: "Feed Exists", message: "Feed at url \(urlString) already exists!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
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
