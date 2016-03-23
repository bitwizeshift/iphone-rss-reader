//
//  WebViewController.swift
//  RSS-Project
//
//  Created by Tomas Baena on 2016-03-22.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UITabBarDelegate {
    var webURL: NSURL!
    @IBOutlet weak var webView: UIWebView!
    @IBAction func forwardNav(sender: AnyObject) {
        webView.goForward()
    }
   
    @IBAction func refreshWebView(sender: AnyObject) {
        webView.reload()
    }
    @IBAction func backNav(sender: AnyObject) {
        webView.goBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let url = NSURL (string: self.webURL);
        let requestObj = NSURLRequest(URL: webURL);
        webView.loadRequest(requestObj);

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
//        if(item.tag == 1) {
            print(1)
//        }
        //This method will be called when user changes tab.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
