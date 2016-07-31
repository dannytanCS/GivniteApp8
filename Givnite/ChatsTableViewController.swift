//
//  ChatsTableViewController.swift
//  Givnite
//
//  Created by Parth Bhardwaj on 7/13/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth


class ChatsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var chats:NSArray?
    var chatsInfo:NSDictionary?
    let chatRootRef = FIRDatabase.database().reference().child("user")
    var numberOfRows = 0
    var snapshotKeys: NSArray?
    var snapShotDict: NSDictionary?
    var lastUpdated: NSMutableArray = []
    
    var fromMarketPlace = false
    var chatUID: String?
    
    var alreadyAppeared = false
    
    var userName: String?
    var fbUID: String?
    var firebaseUID: String? = FIRAuth.auth()?.currentUser?.uid
    
    let dateformatter = NSDateFormatter()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = userName
        // Do any additional setup after loading the view.
        //set up listeners for the gesture recognizers
        
        
        dateformatter.timeZone = NSTimeZone.localTimeZone()
        dateformatter.dateFormat = "MMM dd, yyyy HH:mm zzz"
        
        let swipeLeftGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "unwindToProfile")
        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeLeftGestureRecognizer)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if alreadyAppeared == false{
            let getChats = chatRootRef.child(firebaseUID!).child("chats").queryOrderedByChild("lastUpdated")
            getChats.observeEventType(FIRDataEventType.Value, withBlock:{ (snapshot) -> Void in
                if snapshot.exists(){
                    let sortedDict = snapshot.valueInExportFormat() as! NSDictionary
                    self.snapshotKeys = sortedDict.allKeys
                    self.snapShotDict = sortedDict
                    
//                    for var i = 0; i <= sortedDict.count; i++ {
//                        let tempDict = sortedDict[i]
//                        self.lastUpdated![i] = (tempDict?.valueForKey("lastUpdated"))!
//                    }
                    
//                    for key in sortedDict.allKeys{
//                        print(key)
//                        print(sortedDict)
//                        let tempDict = sortedDict.valueForKey(key as! String) as! NSDictionary
//                        self.lastUpdated.addObject(tempDict.valueForKey("lastUpdated")!)
//                        
//                        if self.lastUpdated.count != 0{
//                            let num = tempDict.valueForKey("lastUpdated")!
//                            if
//                        }
//                    }
                    
                    print(self.lastUpdated)
                    
                    print(sortedDict.allKeys)
                    print(sortedDict)
                    //print(dictOne.valueForKey("lastMessage"))
                    let keysArray = sortedDict.allKeys
                    self.chats = keysArray
                    self.numberOfRows = (self.chats?.count)!
                    self.tableView.reloadData()
                }
                if self.fromMarketPlace == true && self.alreadyAppeared==false{
                    if self.numberOfRows != 0{
                        self.performSegueWithIdentifier("toSingleChat", sender: self)
                    }
                }
                
                self.alreadyAppeared = true
            })
        }
        
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    @IBAction func returnFromSegue(sender: UIStoryboardSegue){
    }
    
    //function for the unwind segue
    func unwindToProfile(){
        self.performSegueWithIdentifier("chatsTableUnwind", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatListItem")! as! ChatTableViewCell
        print(snapshotKeys?.count)
        if snapshotKeys?.count != nil{
            let thisKey = snapshotKeys?[indexPath.row] as! String
            let thisDict = snapShotDict?.valueForKey(thisKey)
            cell.chatUserName.text = thisDict?.valueForKey("otherUsername") as? String
            print("printing this dict")
            print(thisDict)
            cell.lastMessage.text = thisDict?.valueForKey("lastMessage")as? String
            
            //Deciding to bold lastMessage or not
            let unreadArray = thisDict?.valueForKey("unread") as? NSDictionary
            
            if unreadArray != nil && unreadArray!.valueForKey("0") as? String != firebaseUID && unreadArray!.valueForKey("1") as! String=="yes"{
                var font = cell.lastMessage.font
                print(font)
                font = UIFont(name: (".SFUIText-Semibold"), size: ((font?.pointSize)!+3))
                cell.lastMessage.font = font
            }else{
                cell.lastMessage.font = UIFont(name: ".SFUIText-Regular", size: 13)
            }
            
            //Done making messages bold ^^
            
            let otherUID = thisDict?.valueForKey("otherUID") as? String
            
//            let otherImage = getImageUrl(otherUID!)
//            if otherImage.absoluteString != ""{
//                cell.profileImageView.image = UIImage(data: NSData(contentsOfURL: otherImage)!)
//            }else{
//                cell.profileImageView.image = UIImage(named: "blank-user")
//            }
            cell.profileImageView.image = UIImage(named: "blank-user")
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2
            cell.profileImageView.clipsToBounds = true
            return cell
        }else{
            cell.chatUserName.text = ""
            cell.lastMessage.text = ""
            cell.profileImageView.image = nil
            return cell
        }
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let thiscell = cell as! ChatTableViewCell
        if snapshotKeys?.count != nil{
            let thisKey = snapshotKeys?[indexPath.row] as! String
            let thisDict = snapShotDict?.valueForKey(thisKey)
            let otherUID = thisDict?.valueForKey("otherUID") as? String
            
            if  ((NSCache.sharedInstance.objectForKey("\(indexPath.row)chat")) != nil){
                thiscell.profileImageView.image = NSCache.sharedInstance.objectForKey("\(indexPath.row)chat") as? UIImage
            }else{
                chatRootRef.child(otherUID!).child("picture").observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) -> Void in
                    if snapshot.exists(){
                        let urlobtained = snapshot.value as! NSString
                        let imageURL = NSURL.init(string: urlobtained as String)
                        
                        let data = NSData(contentsOfURL: imageURL!)
                        if let dataCheck = data{
                            thiscell.profileImageView.image = UIImage(data: data!)
                            NSCache.sharedInstance.setObject(thiscell.profileImageView.image!, forKey: "\(indexPath.row)chat")
                        }else{
                            thiscell.profileImageView.image = UIImage(named: "blank-user")
                        }
                    }else{
                        thiscell.profileImageView.image = UIImage(named: "blank-user")
                    }
                    
                })
                
            }
            
            if let sentDate = thisDict?.valueForKey("sentDate"){
                let date = dateformatter.dateFromString(sentDate as! String)
                let timeInterval = NSDate().timeIntervalSinceDate(date!) as Double
                let dayNumber = Int (0.0.distanceTo(timeInterval/86400) as Double)
                
                if dayNumber == 0{
                    dateformatter.dateFormat = "HH:mm a"
                    print("sent at \(dateformatter.stringFromDate(date!))")
                    thiscell.lastMessageTime.text = "\(dateformatter.stringFromDate(date!))"
                }else if dayNumber>0 && dayNumber<3 {
                    dateformatter.dateFormat = "EEE"
                    print("sent at \(dateformatter.stringFromDate(date!))")
                    thiscell.lastMessageTime.text = "\(dateformatter.stringFromDate(date!))"
                }else {
                    dateformatter.dateFormat = "dd-MMM-yyyy"
                    print("sent at \(dateformatter.stringFromDate(date!))")
                    thiscell.lastMessageTime.text = "\(dateformatter.stringFromDate(date!))"
                }
                
                dateformatter.dateFormat = "MMM dd, yyyy HH:mm zzz"
            }
        }
    }
    func getImageUrl(userID: String) -> NSURL{
        var imageURL: NSURL? = nil
        let userRef = chatRootRef.child(userID).child("picture")
        userRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) -> Void in
            if snapshot.exists(){
                let urlobtained = snapshot.value as! NSString
                imageURL = NSURL.init(string: urlobtained as String)
            }
        })
        if let image = imageURL{
            return image
        }else{
            return NSURL(string: "")!
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if numberOfRows != 0{
            self.performSegueWithIdentifier("toSingleChat", sender: indexPath)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toSingleChat"{
            let chatVC = segue.destinationViewController as! SingleChatViewController
            chatVC.senderId = firebaseUID
            chatVC.senderDisplayName = userName
            if fromMarketPlace{
                chatVC.chatUID = self.chatUID
            }else{
                let thissender = sender as! NSIndexPath
                chatVC.chatUID = snapshotKeys?[thissender.row] as? String
            }
        }
    }
    
    @IBAction func startNewChat(sender: AnyObject){
        //NEED 4 things for this function to run
        // 1- Current user's uid and name  && 2 - other user's uid and name
        
        
        let thisUserId = FIRAuth.auth()?.currentUser?.uid
        let thisUsername = "should also be available"
        
        //NOTE this should be like otherUserId = self.otherUserId ( should be easily accesible if you are already showing the item by the user )
        let otherUserId = "randomUserId"
        let otherUsername = "should be grabbed just like the otherUserId. Otherwise we would have to run another cal here"
        
        
        //IGNORE THE FOLLOWING COMMENTS
        //        //running call anyways
        //
        //        getUserName((FIRAuth.auth()?.currentUser?.uid)!) { (name) -> Void in
        //            print("called in function")
        //            otherUserName = name
        //        }
        //
        //        print("called outside function")
        
        
        let newChatId = "\(thisUserId)$\(otherUserId)"
        
        //uncomment this line or make a similar reference
        //let chatRootRef = FIRDatabase.database().reference().child("user")
        chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("lastMessage").setValue("")
        chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("otherUID").setValue(otherUserId)
        chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("otherUsername").setValue(otherUsername)
        
        chatRootRef.child(otherUserId).child("chats").child(newChatId).child("lastMessage").setValue("")
        chatRootRef.child(otherUserId).child("chats").child(newChatId).child("otherUID").setValue(thisUserId)
        chatRootRef.child(otherUserId).child("chats").child(newChatId).child("otherUsername").setValue(thisUsername)
        
        //adding a new starter message by the person who started the chat
        let chatRef = FIRDatabase.database().reference().child("chats")
        chatRef.child(newChatId).child("0").child("senderId").setValue(thisUserId)
        chatRef.child(newChatId).child("0").child("sentDate").setValue(self.dateformatter.stringFromDate(NSDate()))
        chatRef.child(newChatId).child("0").child("text").setValue("Hey!")
    }
    
    
    //USE NSOPERATION QUEUE TO DO THIS
    func getUserName(uid: String, completion : (name:String)->Void) -> Void{
        let queryRef = chatRootRef.child(uid).child("name")
        var returnValue = ""
        
        queryRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) -> Void in
            returnValue = snapshot.value as! String
            print("called from within")
            completion(name: returnValue)
        })
        
        
        
        print("called outside")
    }
    
    func quickSort(array: [Int]) -> [Int]
    {
        var arr = array
        quickSort(&arr, left: 0, right: arr.count - 1)
        return arr;
    }
    
    func quickSort(inout arr: [Int], left: Int, right: Int)
    {
        let index = partition(&arr, left: left, right: right)
        
        if left < index - 1 {
            quickSort(&arr, left: left, right: index - 1)
        }
        
        if index < right {
            quickSort(&arr, left: index, right: right)
        }
    }
    
    func partition(inout arr: [Int], left: Int, right: Int) -> Int
    {
        var i = left
        var j = right
        let pivot = arr[(left + right) / 2]
        
        while i <= j {
            while arr[i] < pivot {
                i += 1
            }
            
            while j > 0 && arr[j] > pivot {
                j -= 1
            }
            
            if i <= j {
                if i != j {
                    swap(&arr[i], &arr[j])
                                    }
                i += 1
                
                if j > 0 {
                    j -= 1
                }
            }
        }
        return i
    }

    
    /*
    +    // MARK: - Navigation
    +
    +    // In a storyboard-based application, you will often want to do a little preparation before navigation
    +    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    +    // Get the new view controller using segue.destinationViewController.
    +    // Pass the selected object to the new view controller.
    +    }
    +    */
}