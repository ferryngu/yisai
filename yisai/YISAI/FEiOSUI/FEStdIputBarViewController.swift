//
//  FEStdIputBarViewController.swift
//  FECore
//
//  Created by apps on 15/10/29.
//  Copyright © 2015年 apps. All rights reserved.
//

import UIKit

public class FEStdIputBarViewController: UIViewController {
    
    public var inputTextView: UITextView!
    
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var inputBarHeightLayoutConstraint: NSLayoutConstraint!

    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet weak var rightButton: UIButton!
    
    var feViewControllerTransition:FEViewControllerTransition!

    var emojiInputPad:FEEmojiInputPadCollectionViewController!

    var orgInputBarHeightLayoutConstraint:CGFloat!
    
    var keyBoardHeight:CGFloat!

    let InputStatusKeyBoard = 0
    
    let InputStatusEmoji = 1
    
    var inputStatus:Int = 1
    
    let EmojiChar = "☺︎"
    let KeyBoardChar = "⌨"
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        emojiInputPad = feInputPadStoryBoard.instantiateViewControllerWithIdentifier("EmojiPad") as!FEEmojiInputPadCollectionViewController
        
        feViewControllerTransition = FEViewControllerTransition(ContainerViewController: self, ContainerView: containerView)
        
        feViewControllerTransition.addViewController("EmojiPad", viewController: emojiInputPad)
        
        orgInputBarHeightLayoutConstraint = inputBarHeightLayoutConstraint.constant
        
    }

    @IBAction func leftButtonAction(sender: AnyObject) {

        if nil == inputTextView {
            return
        }

        if InputStatusKeyBoard == inputStatus {
            
            hideInputPad()
            inputTextView.becomeFirstResponder()
            
        } else {
            
            inputTextView.resignFirstResponder()
            showInputPad()
            
        }
        
        /*
        inputTextView.resignFirstResponder()
        emojiInputPad.inputTextView = inputTextView
        showInputPad()
        */
    }
    
    @IBAction func rightButtonAction(sender: AnyObject) {

        if nil == inputTextView {
            return
        }
        
        inputTextView.resignFirstResponder()
        hideInputPad()
        
        //hideInputPad()
    }
    
    
    @IBAction func deleteWordAction(sender: AnyObject) {

        if nil == inputTextView || true == inputTextView.text.isEmpty {
            return
        }
        
        inputTextView.deleteBackward()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func viewWillAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.view.frame = getDefaultMainViewFrame( UIScreen.mainScreen().bounds.size )
        
    }
    
    public override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
    }

    func handleKeyboardWillShowNotification(notification: NSNotification) {
        
        if nil==self.inputTextView || true != self.inputTextView.isFirstResponder() {
            keyboardWillChangeFrameWithNotification(notification, showsKeyboard: false)
            return
        }

        leftButton.setTitle(EmojiChar, forState: UIControlState.Normal)
        inputStatus = InputStatusEmoji

        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: true)
    }
    
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {

        leftButton.setTitle(EmojiChar, forState: UIControlState.Normal)
        inputStatus = InputStatusKeyBoard
        
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: false)
    }

    func keyboardWillChangeFrameWithNotification(notification: NSNotification, showsKeyboard: Bool) {

        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame   = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        keyBoardHeight = keyboardViewEndFrame.size.height
        
        let frame = getDefaultMainViewFrame(UIScreen.mainScreen().bounds.size)
        
        if true == showsKeyboard {
            
            let y = UIScreen.mainScreen().bounds.height - keyboardViewEndFrame.size.height - inputBarHeightLayoutConstraint.constant
            let width = UIScreen.mainScreen().bounds.width
            
            let height = frame.size.height
            
            self.view.frame = CGRect(x:0, y:y, width:width, height: height)
            self.view.layoutIfNeeded()
            
        } else {
            
            let y = UIScreen.mainScreen().bounds.height
            let width = UIScreen.mainScreen().bounds.width
            
            let height = frame.size.height
            
            self.view.frame = CGRect(x:0, y:y, width:width, height: height)
            self.view.layoutIfNeeded()
            
        }
        
    }

    func getDefaultMainViewFrame(size:CGSize)->(CGRect) {
        
        let frame = self.view.frame
        return CGRect(x:0, y: size.height, width:frame.size.width, height:frame.size.height)
        
    }
    
    
    public func showInputPad(){
        
        leftButton.setTitle(KeyBoardChar, forState: UIControlState.Normal)
        inputStatus = InputStatusKeyBoard
        
        emojiInputPad.inputTextView = inputTextView

        keyBoardHeight = 260
        
        let fixHeight = inputBarHeightLayoutConstraint.constant
        
        let frame = getDefaultMainViewFrame(UIScreen.mainScreen().bounds.size)
        
        UIView.animateWithDuration(0.25,
            
            animations: {
                
                self.view.frame = CGRect(x:0, y:UIScreen.mainScreen().bounds.height - self.keyBoardHeight - fixHeight, width:frame.size.width, height: frame.size.height)
                
            },
            completion: {
                (finished:Bool) -> Void in
                
                self.view.layoutIfNeeded()

                
            }
        )
        
    }
    
    public func hideInputPad(){

        leftButton.setTitle(EmojiChar, forState: UIControlState.Normal)
        inputStatus = InputStatusEmoji
        
        let frame = getDefaultMainViewFrame(UIScreen.mainScreen().bounds.size)
        
        UIView.animateWithDuration(0.25,

            animations: {

                self.inputBarHeightLayoutConstraint.constant = self.orgInputBarHeightLayoutConstraint
                self.view.frame = CGRect(x:frame.origin.x, y:frame.origin.y, width:frame.size.width, height: frame.size.height)
                
            },
            completion: {
                (finished:Bool) -> Void in

                self.view.layoutIfNeeded()

            }
        )
     
        inputTextView.resignFirstResponder()
        
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

