//
//  WebViewController.swift
//  RSS-Project
//
//  Created by Tomas Baena on 2016-03-22.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UITabBarDelegate, WKNavigationDelegate {
    
    //------------------------------------------------------------------------
    // MARK: - Public Variables
    //------------------------------------------------------------------------
    
    @IBOutlet var webBar: UIView!
    var webView : WKWebView = WKWebView()
    var spinnerIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 100, 100))
    var entry: RSSEntry? = nil
    
    // The collection, used for favoriting
    var collection : RSSCollection? = nil;
    
    //------------------------------------------------------------------------
    // MARK: - Outlets
    //------------------------------------------------------------------------

    @IBOutlet weak var navigationBar: UINavigationItem!

    //------------------------------------------------------------------------
    // MARK: - Actions
    //------------------------------------------------------------------------
    
    //
    // Backward navigation
    //

    @IBAction func backwardNav(sender: AnyObject) {
        if (self.webView.canGoBack) {
            webView.goBack()
        }
    }
    
    //
    // Refresh navigation
    //
    @IBAction func refreshWebView(sender: AnyObject) {
        webView.reload()
    }
    
    //
    // Forward navigation
    //
    @IBAction func forwardNav(sender: AnyObject) {
        if (self.webView.canGoForward) {
            webView.goForward()
        }
    }
    //
    // Open story in browser
    //
    @IBAction func openInBrowser(sender: AnyObject) {
            UIApplication.sharedApplication().openURL(entry!.link!)
    }
    
    //------------------------------------------------------------------------
    // MARK: - View Loading
    //------------------------------------------------------------------------
    
    //
    // Initialization when the view loads
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow the web-view gestures
        self.webView.allowsBackForwardNavigationGestures = true
        // Set the navigation title
        self.navigationBar.title = entry!.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Bookmarks, target: self, action: "addBookmark")
        if collection!.isFavorite( entry! ){
            self.navigationItem.rightBarButtonItem!.tintColor = UIColor.blueColor()
        }else{
            self.navigationItem.rightBarButtonItem!.tintColor = UIColor.grayColor()
        }
        
        // Set the background color to white
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Initiate the indicator
        self.spinnerIndicator.center = self.view.center
        self.spinnerIndicator.hidesWhenStopped = true
        self.spinnerIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        // Add subviews to the current view
        self.view.addSubview(self.webView)
        self.view.addSubview(self.spinnerIndicator)
        
        // Load the current request
        self.webView.navigationDelegate = self
        self.webView.loadRequest(NSURLRequest(URL: entry!.link!))
    }

    //
    // Did this veiw receive a memory warning?
    //
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // Create the subview layouts
    //
    override func viewWillLayoutSubviews() {
        let TOP_MARGIN    : CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        let BOTTOM_MARGIN : CGFloat = 40
        self.webView.frame = CGRectMake(0, TOP_MARGIN, self.view.frame.size.width, self.view.frame.size.height - BOTTOM_MARGIN - TOP_MARGIN)
        
        
    }
    //
    // Add story to bookmarks
    //
    func addBookmark(){
        if collection!.isFavorite( entry! ){
            collection!.removeFavorite( entry! )
            print("Bookmark Removed")
            self.navigationItem.rightBarButtonItem!.tintColor = UIColor.grayColor()
            
            
        }else{
            collection!.addFavorite( entry! )
            print("Bookmark Added")
            self.navigationItem.rightBarButtonItem!.tintColor = UIColor.blueColor()
        }
    }
    //------------------------------------------------------------------------
    // MARK: - WKNavigationDelegate
    //------------------------------------------------------------------------
    
    //
    // Delegate for beginning web navigation
    //
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.spinnerIndicator.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        NSLog("Begin Web Navigation")
    }
    
    //
    // Delegate for failing web navigation
    //
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError){
        self.spinnerIndicator.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        NSLog("Failed Navigation %@", error.localizedDescription)
    }
    
    //
    // Delegate for completing web navigation
    //
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.spinnerIndicator.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        NSLog("Navigation completed for:%@ URL:%@", webView.title!, webView.URL!)
    }

}
