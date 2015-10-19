//
//  ViewController.swift
//  Touch ID And Keychain
//
//  Created by Yohannes Wijaya on 10/18/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var secretTextView: UITextView!
    
    // MARK: - IBAction Properties
    
    @IBAction func authenticateUser(sender: UIButton) {
    }
    
    // MARK: - Methods Override

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "adjustForKeyboard", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "adjustForKeyboard", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Local Methods
    
    func adjustForKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardViewEndFrame = self.view.convertRect(keyboardScreenEndFrame, fromView: self.view.window!)
        
        if notification.name == UIKeyboardWillHideNotification {
            self.secretTextView.contentInset = UIEdgeInsetsZero
        }
        else {
            self.secretTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        self.secretTextView.scrollIndicatorInsets = self.secretTextView.contentInset
        
        let selectedRange = self.secretTextView.selectedRange
        self.secretTextView.scrollRangeToVisible(selectedRange)
    }
}

