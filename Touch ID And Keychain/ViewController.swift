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
        self.unlockSecretMessage()
    }
    
    // MARK: - Methods Override

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Nothing to see here!"
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "adjustForKeyboard", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "adjustForKeyboard", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: "saveSecretMessage", name: UIApplicationWillResignActiveNotification, object: nil)
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
    
    func saveSecretMessage() {
        if !self.secretTextView.hidden {
            KeychainWrapper.setString(self.secretTextView.text, forKey: "SecretMessage")
            self.secretTextView.resignFirstResponder()
            self.secretTextView.hidden = true
            self.title = "Nothing to see here!"
        }
    }
    
    func unlockSecretMessage() {
        self.secretTextView.hidden = false
        self.title = "Classified. Echelon 1 only."
        
        if let decodedText = KeychainWrapper.stringForKey("SecretMessage") {
            self.secretTextView.text = decodedText
        }
    }
}

