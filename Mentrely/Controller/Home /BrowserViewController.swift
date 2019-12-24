//
//  BrowserViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 23/12/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController,     WKUIDelegate, WKNavigationDelegate  {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var fullURL = ""
    @IBOutlet weak var webView: WKWebView!
    override func viewWillAppear(_ animated: Bool) {
         webView.load(URLRequest(url: URL(string: fullURL)!))
            webView.navigationDelegate = self
            activityIndicator.startAnimating()
  
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
       activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    @IBAction func dismissed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
