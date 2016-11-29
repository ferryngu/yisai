//
//  FEEmojiInputPadCollectionViewController.swift
//  FECore
//
//  Created by apps on 15/10/21.
//  Copyright © 2015年 apps. All rights reserved.
//

import UIKit

private let reuseIdentifier = "EmojiCell"

class FEEmojiInputPadCollectionViewController: UICollectionViewController {

    var inputTextView: UITextView!

    //"⌫"
    let emojiStringArry:[String] = [
        "😀","😬","😁","😂","😃","😄","😅","😆","😇","😉","😊","🙂","🙃","☺️","😋","😌","😍","😘",
        "😗","😙","😚","😜","😝","😛","🤑","🤓","😎","🤗","😏","😶","😐","😑","😒","🙄","🤔","😳",
        "😞","😟","😠","😡","😔","😕","🙁","☹️","😣","😖","😫","😩","😤","😮","😱","😨","😰","😯",
        "😦","😧","😢","😥","😪","😓","😭","😵","😲","🤐","😷","🤒","🤕","😴","💤","💩","😈","👿",
        "👹","👺","💀","👻","👽","🤖","😺","😸","😹","😻","😼","😽","🙀","😿","😾","🙌","👋","👎",
        "✊","👌","👐","🙏","👆","👈","🖕","🖖","💅","👄"

    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return emojiStringArry.count
    }

    
    
    
    /*
    var NSASCIIStringEncoding: UInt { get }
    var NSNEXTSTEPStringEncoding: UInt { get }
    var NSJapaneseEUCStringEncoding: UInt { get }
    var NSUTF8StringEncoding: UInt { get }
    
    NSUnicodeStringEncoding
    */
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
        if nil == inputTextView {
            return
        }
        
        let emojiString = emojiStringArry[indexPath.row]

        if "⌫" == emojiString {

            if true == inputTextView.text.isEmpty {
                return
            }

            inputTextView.deleteBackward()
            //inputTextView.needsUpdateConstraints()
    
            return

        }

        inputTextView.insertText(emojiStringArry[indexPath.row])

        inputTextView.scrollRangeToVisible(inputTextView.selectedRange)
        

    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        // Configure the cell

        let label1 = cell.viewWithTag(1001) as? UILabel!

        label1?.text = emojiStringArry[indexPath.row]

        return cell

    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
