//
//  FEInputPadViewController.swift
//  FECore
//
//  Created by apps on 15/10/16.
//  Copyright © 2015年 apps. All rights reserved.
//

import UIKit

public protocol FEBottomInputBarDelegate  {


}

public class FEBottomInputBarViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var inputBarView: UIView!
    
    @IBOutlet weak var inputBarHeightLayoutConstraint: NSLayoutConstraint!

    var feViewControllerTransition:FEViewControllerTransition!
    
    @IBOutlet weak var containerView: UIView!

    var inputBarViewFrame:CGRect!

    var orgInputTextViewcontentSize:CGFloat!
    
    var orgInputBarHeightLayoutConstraint:CGFloat!
    
    var keyBoardHeight:CGFloat!

    var isShowInputPad:Bool = false

    var emojiInputPad:FEEmojiInputPadCollectionViewController!
    
    var inputpad_2:UIViewController!

    let InputStatusKeyBoard = 0

    let InputStatusEmoji = 1

    var inputStatus:Int = 1
    
    let EmojiChar = "☺︎"
    let KeyBoardChar = "⌨"

    public var placeHoldLabel:UILabel!
    public var placeHoldString:String!

    @IBAction func leftButtonAction(sender: AnyObject) {

        if InputStatusKeyBoard == inputStatus {

            hideInputPad()
            inputTextView.becomeFirstResponder()

        } else {

            inputTextView.resignFirstResponder()
            showInputPad()
        
        }
        
        
    }
    
    @IBAction func rightButtonAction(sender: AnyObject) {

        inputTextView.resignFirstResponder()
        hideInputPad()
        
    }

    
    @IBAction func t1(sender: AnyObject) {

        feViewControllerTransition.transition("EmojiPad")

    }

    @IBAction func t2(sender: AnyObject) {
        feViewControllerTransition.transition("inputpad_2")
    }

    
    @IBAction func deleteWord(sender: AnyObject) {

        if true == inputTextView.text.isEmpty {
            return
        }

        inputTextView.deleteBackward()

    }

    public  override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.

        inputBarViewFrame = inputBarView.frame

        inputTextView.delegate = self

        orgInputBarHeightLayoutConstraint = inputBarHeightLayoutConstraint.constant

        emojiInputPad = feInputPadStoryBoard.instantiateViewControllerWithIdentifier("EmojiPad") as!FEEmojiInputPadCollectionViewController

        inputpad_2 = feInputPadStoryBoard.instantiateViewControllerWithIdentifier("inputpad_2")

        feViewControllerTransition = FEViewControllerTransition(ContainerViewController: self, ContainerView: containerView)

        feViewControllerTransition.addViewController("EmojiPad", viewController: emojiInputPad)
        feViewControllerTransition.addViewController("inputpad_2", viewController: inputpad_2)

        keyBoardHeight = 260
        
        self.view.frame = getDefaultMainViewFrame( UIScreen.mainScreen().bounds.size )

        /*
        inputTextView.keyboardType = UIKeyboardType.URL
        inputTextView.returnKeyType = UIReturnKeyType.Done
        inputTextView.enablesReturnKeyAutomatically = true
        */
        //inputTextView.keyboardAppearance = UIKeyboardAppearance.Default
        //inputTextView.secureTextEntry
        //inputTextView.keyboardDismissMode =


        placeHoldString = "#"
        placeHoldLabel = UILabel()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDeviceOrientationChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)

    }


    public  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //屏幕发生旋转
    //这里是无法正确判断 inputTextView 的高度的，所以不能依赖这个
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        if nil == inputTextView {
            return
        }

        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        let fixHeight = inputTextView.contentSize.height - orgInputTextViewcontentSize

        var fixFrameY:CGFloat = 0.0
        let frame = getDefaultMainViewFrame(size)
        
        if true == isShowInputPad {

            // 竖屏
            if size.height > size.width {
            
                keyBoardHeight = 260
            
            } else {
                keyBoardHeight = 220
            }
            
            fixFrameY += keyBoardHeight

        }

        UIView.animateWithDuration(0.25,

            animations: {
                
                self.inputBarHeightLayoutConstraint.constant = self.orgInputBarHeightLayoutConstraint + fixHeight
                self.view.frame = CGRect(x:frame.origin.x, y:frame.origin.y - fixHeight - fixFrameY, width:frame.size.width, height: frame.size.height)
                
            },
            completion: {
                (finished:Bool) -> Void in
                
                self.view.layoutIfNeeded()
                
            }
        )


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
                self.isShowInputPad = true
                
            }
        )
        
    }
    
    public func hideInputPad(){
        
        leftButton.setTitle(EmojiChar, forState: UIControlState.Normal)
        inputStatus = InputStatusEmoji

        emojiInputPad.inputTextView = nil
        
        let fixHeight = inputTextView.contentSize.height - orgInputTextViewcontentSize
        let frame = getDefaultMainViewFrame(UIScreen.mainScreen().bounds.size)
        
        UIView.animateWithDuration(0.25,

            animations: {
                
                self.inputBarHeightLayoutConstraint.constant = self.orgInputBarHeightLayoutConstraint + fixHeight
                self.view.frame = CGRect(x:frame.origin.x, y:frame.origin.y - fixHeight, width:frame.size.width, height: frame.size.height)
                
            },
            completion: {
                (finished:Bool) -> Void in
                
                self.view.layoutIfNeeded()
                self.isShowInputPad = false
            }
        )
        
    }

    func onDeviceOrientationChange(notification: NSNotification) {
        
        textViewDidChange(self.inputTextView)
        
    }

    func getDefaultMainViewFrame(size:CGSize)->(CGRect) {

        let frame = self.view.frame
        // -2 是因为 inputBar 距离顶部有2个像素，这里做一个补偿
        return CGRect(x:0, y: size.height - orgInputBarHeightLayoutConstraint - 2, width:frame.size.width, height:frame.size.height)

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

    public override func viewDidAppear(animated: Bool) {

        orgInputTextViewcontentSize = inputTextView.contentSize.height
        
    }

    func handleKeyboardWillShowNotification(notification: NSNotification) {
        
        if true != self.inputTextView.isFirstResponder() {
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

            let y = UIScreen.mainScreen().bounds.height - keyboardViewEndFrame.size.height - inputBarHeightLayoutConstraint.constant - 3
            let width = UIScreen.mainScreen().bounds.width

            let height = frame.size.height

            self.view.frame = CGRect(x:0, y:y, width:width, height: height)
            self.view.layoutIfNeeded()

        } else {
        
            let y = UIScreen.mainScreen().bounds.height  - inputBarHeightLayoutConstraint.constant - 5
            let width = UIScreen.mainScreen().bounds.width

            let height = frame.size.height

            self.view.frame = CGRect(x:0, y:y, width:width, height: height)
            self.view.layoutIfNeeded()

        }
        
    }

    



    

    public func textViewDidBeginEditing(textView: UITextView) {



        if nil != textView.text && 0 == textView.text.lengthOfBytesUsingEncoding(NSUnicodeStringEncoding) {
            
            placeHoldLabel.frame = CGRect(x: 1.5, y:0.5, width: textView.frame.size.width, height: textView.frame.size.height)
            
            
            placeHoldLabel.text = placeHoldString
            placeHoldLabel.textColor = UIColor.grayColor()
            textView.addSubview(placeHoldLabel)
            
        } else {
            
            
            placeHoldLabel.removeFromSuperview()
            
        }
        
    }

    public func textViewDidChange(textView: UITextView) {

        if nil != textView.text && 0 == textView.text.lengthOfBytesUsingEncoding(NSUnicodeStringEncoding) {

            placeHoldLabel.frame = CGRect(x: 1.5, y:0.5, width: textView.frame.size.width, height: textView.frame.size.height)
            placeHoldLabel.text = placeHoldString
            placeHoldLabel.textColor = UIColor.grayColor()
            
            textView.addSubview(placeHoldLabel)
        
        } else {
        
        
            placeHoldLabel.removeFromSuperview()

        }
        
        
        
        if textView.contentSize.height < orgInputTextViewcontentSize {
            return
        }
        
        if textView.contentSize.height >= 100 {
            return
        }
        
        let fixHeight = textView.contentSize.height - orgInputTextViewcontentSize
        
        if inputBarHeightLayoutConstraint.constant == orgInputBarHeightLayoutConstraint + fixHeight {
            self.view.layoutIfNeeded()
            return
        }
        
        let frame = getDefaultMainViewFrame(UIScreen.mainScreen().bounds.size)
        
        self.view.frame = CGRect(x:frame.origin.x, y:frame.origin.y - fixHeight - keyBoardHeight, width:frame.size.width, height: frame.size.height)
        
        inputBarHeightLayoutConstraint.constant = orgInputBarHeightLayoutConstraint + fixHeight
        
        self.view.layoutIfNeeded()
        
        let selectedRange = textView.selectedRange
        
        textView.scrollRangeToVisible(selectedRange)

    }

    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    public func textViewShouldEndEditing(textView: UITextView) -> Bool{

        //print("#0 textViewShouldEndEditing")
        return true
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
    
        hideInputPad()

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


//inputTextView.becomeFirstResponder()
//defaultMainViewFrame = CGRect(x:0, y: UIScreen.mainScreen().bounds.height - orgInputBarHeightLayoutConstraint-4, width:UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)

