//
//  ViewController.swift
//  Touch ID And Keychain
//
//  Created by Yohannes Wijaya on 10/18/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var secretTextView: UITextView!
    
    // MARK: - IBAction Properties
    
    @IBAction func authenticateUser(sender: UIButton) {
        let localAuthenticationContext = LAContext()
        var error: NSError?
        
        if localAuthenticationContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself w/ your fingerprint!"
            
            localAuthenticationContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { [unowned self] (success: Bool, authenticationError: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if success { self.unlockSecretMessage() }
                    else {
                        if let error = authenticationError {
                            if error.code == LAError.UserFallback.rawValue {
                                let alertController = UIAlertController(title: "Passcode? Ha!", message: "It's Touch ID or nothing. Sorry!", preferredStyle: .Alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                        let ac = UIAlertController(title: "Authentication failed", message: "Your finger could not be verified. Please try again.", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(ac, animated: true, completion: nil)
                    }
                })
            })
        }
        else {
            let alertController = UIAlertController(title: "Touch ID is not available", message: "Your device is not configured for Touch ID.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
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

