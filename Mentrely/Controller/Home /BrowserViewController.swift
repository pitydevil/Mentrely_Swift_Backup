//
//  BrowserViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 23/12/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import WebKit
import TTGSnackbar

class BrowserViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate{
    
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var titleNewsLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var newsBar: UIToolbar!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var stopButton: UIBarButtonItem!
    var fullURL   : String?
    var titleNews : String?
    fileprivate var lastContentOffset: CGFloat = 0
    fileprivate let snackbar = TTGSnackbar(message: "Copied to clipboard!", duration: .middle)
    fileprivate let shareSnackbar = TTGSnackbar(message: "Shared!", duration: .middle)
    private var estimatedProgressObserver: NSKeyValueObservation?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBOutlet weak var loadButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressView.isHidden = true
        progressView.setProgress(0, animated: false)
        forwardButton.isEnabled = false
        backButton.isEnabled = false
        
        webView.scrollView.delegate = self
        webView.scrollView.bounces = false
        setupEstimatedProgressObserver()
        webView.load(URLRequest(url: URL(string: fullURL ?? "")!))
        webView.navigationDelegate = self
        webView.configuration.mediaTypesRequiringUserActionForPlayback = .all
        webView.configuration.allowsInlineMediaPlayback = true
        urlLabel.text = fullURL ?? ""
        titleNewsLabel.text = titleNews
    }

        
    @IBAction func moreButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let copy = UIAlertAction(title: "Copy Link", style: .default) { (action) in
            UIPasteboard.general.string = self.fullURL ?? ""
            self.snackbar.leftMargin = 25
            self.snackbar.rightMargin = 25
            self.snackbar.animationType = .slideFromTopBackToTop
            self.snackbar.shouldDismissOnSwipe = true
            self.snackbar.show()
        }
        let safari = UIAlertAction(title: "Safari", style: .default) { (action) in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let safari = UIAlertAction(title: "Safari", style: .default) { (UIAlertAction) in
                    guard let url = URL(string: self.fullURL ?? "") else { return }
                     UIApplication.shared.open(url)
                   }
                 let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                 alert.addAction(safari)
                 alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(copy)
        alert.addAction(safari)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        snackbar.dismiss()
        shareSnackbar.dismiss()
    }

    fileprivate func hideTabBar() {
        var frame = self.newsBar.frame
        frame.origin.y = self.view.frame.size.height + (frame.size.height)
        UIView.animate(withDuration: 0.2, animations: {
            self.newsBar.frame = frame
        })
    }

    fileprivate func showTabBar() {
        var frame = self.newsBar.frame
        frame.origin.y = self.view.frame.size.height - (frame.size.height)-21
        UIView.animate(withDuration: 0.5, animations: {
            self.newsBar.frame = frame
        })
    }
    
    @IBAction func action1(_ sender: Any) {
        webView.goBack()
    }
  
    @IBAction func backButton(_ sender: Any) {
        webView.goForward()
    }
    @IBAction func stopAction(_ sender: UIBarButtonItem) {
        webView.stopLoading()
        UIView.animate(withDuration: 0.33,
        animations: {
            self.progressView.alpha = 0.0
        },
            completion: { isFinished in
                self.stopButton.isEnabled = false
                self.progressView.setProgress(0, animated: false)
                self.progressView.isHidden = isFinished
         })
    }
    
    @IBAction func action3(_ sender: Any) {
       let alert =  UIAlertController(title: "Share this news to", message: nil, preferredStyle: .actionSheet)
           let action = UIAlertAction(title: "Other", style: .default) { (UIAlertAction) in
            let activityController = UIActivityViewController(activityItems: [self.fullURL ?? ""], applicationActivities: nil)
                   activityController.completionWithItemsHandler = { (nil, completed, _, error) in
                   if completed  {
                        self.shareSnackbar.shouldDismissOnSwipe = true
                        self.shareSnackbar.rightMargin = 25
                        self.shareSnackbar.leftMargin = 25
                        self.shareSnackbar.animationType = .slideFromTopBackToTop
                        self.shareSnackbar.show()
                   } else {
                        print("\(error?.localizedDescription ?? "")")
                   }
               }
               self.present(activityController, animated: true, completion: nil)
           }
           let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           alert.addAction(action)
           alert.addAction(cancel)
          present(alert, animated: true, completion: nil)
    }
    
    private func setupEstimatedProgressObserver() {
         estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
         }
     }
    
    //MARK: -Webview function
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == webView.scrollView {
           if self.lastContentOffset > scrollView.contentOffset.y {
                // move up
                showTabBar()
            }
            else if self.lastContentOffset < scrollView.contentOffset.y {
               // move down
                hideTabBar()
            }
            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        webView.reload()
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

        if webView.isLoading == true {
            stopButton.isEnabled = true
        }
        progressView.isHidden = false
        UIView.animate(withDuration: 0.33,
            animations: {
                self.progressView.alpha = 1.0
         })
    }
    

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.webView.backForwardList.backList.count == 0 {
            backButton.isEnabled = false
        }else {
            backButton.isEnabled = true
        }


        if webView.backForwardList.forwardList.count == 0 {
            forwardButton.isEnabled = false
        }else {
            forwardButton.isEnabled = true
        }
        UIView.animate(withDuration: 0.33,
            animations: {
                self.progressView.alpha = 0.0
            },
        completion: { isFinished in
            self.progressView.setProgress(0, animated: false)
            self.progressView.isHidden = isFinished
            self.stopButton.isEnabled = false
        })
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIView.animate(withDuration: 0.33,
            animations: {
                self.progressView.alpha = 0.0
            },
                completion: { isFinished in
                    self.stopButton.isEnabled = false
                    self.progressView.setProgress(0, animated: false)
                    self.progressView.isHidden = isFinished
             })
    }
    
    @IBAction func dismissed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
