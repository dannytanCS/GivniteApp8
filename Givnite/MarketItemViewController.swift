//
//  MarketItemViewController.swift
//  Givnite
//
//  Created by Danny Tan on 7/17/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class MarketItemViewController: UIViewController {

    @IBOutlet weak var bookDescription: UITextView!
    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var bookPrice: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var messageButton: SpringButton!
    
    @IBOutlet weak var backButtonOutlet: UIButton!
    
    //isbn 
    
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var publisher: UILabel!
    @IBOutlet weak var publishedDate: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var bookDescription2: UITextView!
    
    
    let storageRef = FIRStorage.storage().referenceForURL("gs://givniteapp-292f6.appspot.com")
    let databaseRef = FIRDatabase.database().referenceFromURL("https://givniteapp-292f6.firebaseio.com/")
    let user = FIRAuth.auth()!.currentUser

    
    var image = UIImage()
    
    var imageArray = [UIImage]()
    var imageNameArray = [String]()
    var userArray = [String]()
    var imageDict = [UIImage:AnyObject]()
    
    
    var imageName:String?
    var price: String?
    var name: String?
    var userID: String?
    var bkdescription: String?
    
    
 
    
    //CHAT ADDITION
    //CHAT ADDITION
    var chatUID : String?
    
    
    var imageList = [UIImage]()
    
    var imageNameList = [String]()
    
    var imageIndex: Int = 0
    
    var maxImages: Int = 0
    
    func timefunc()
    {
        messageButton.animation = "shake"
        messageButton.curve = "linear"
        messageButton.duration = 0.3
        messageButton.x = 0.5
        messageButton.force = 0.5
        messageButton.velocity = 0.5
        messageButton.damping = 0.5
        messageButton.animate()
    }
    
    
    @IBAction func showInfo(sender: AnyObject) {
        
        self.descriptionView.hidden = false
        
    }
    
    
    @IBAction func cancelInfo(sender: AnyObject) {
        
        self.descriptionView.hidden = true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if user?.uid == userID {
            messageButton.hidden = true
        }
        
        self.flipButton.hidden = true
  
        self.imageView.layer.cornerRadius = 10
        self.imageView.clipsToBounds = true
        //self.imageView.layer.borderWidth = 2
        //self.imageView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).CGColor

        self.bookName.text = self.name
        self.bookPrice.text = self.price
        self.bookDescription.text = self.bkdescription
        self.bookDescription.editable = false
        self.descriptionView.hidden = true
        self.view.bringSubviewToFront(backButtonOutlet)

        
        
        databaseRef.child("user").child(userID!).child("name").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
            if let userName = snapshot.value! as? String {
                self.sellerName.text = userName
            }
        })

        databaseRef.child("marketplace").child(imageName!).observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
            //checks for isbn
            
            if let isbn = snapshot.value!["isbn"] as? String {
                self.flipButton.hidden = false
            }
            
            if let searchable = snapshot.value!["searchable"] as? NSDictionary {
                if let bookDescription = searchable["description"] as? String {
                    self.bookDescription.text = bookDescription
                }
                if let title = searchable["title2"] as? String {
                    self.bookTitle.text = title
                }
                if let author = searchable["author"] as? String {
                    self.bookAuthor.text = author
                }
                
                if let publisher = searchable["publisher"] as? String {
                    self.publisher.text = publisher
                }
                
                if let publishedDate = searchable["publishedDate"] as? String {
                    self.publishedDate.text = publishedDate
                }
                if let genre = searchable["categories"] as? String {
                    self.genre.text = genre
                }
                if let description = searchable["description2"] as? String {
                    self.bookDescription2.text = description
                }
                
                
            }
                

            
            
            
            let itemDictionary = snapshot.value!["images"] as! NSDictionary

            let sortKeys = itemDictionary.keysSortedByValueUsingComparator {
                (obj1: AnyObject!, obj2: AnyObject!) -> NSComparisonResult in
                let x = obj1 as! NSNumber
                let y = obj2 as! NSNumber
                return x.compare(y)
            }
                
                
            for key in sortKeys {
                self.imageNameList.append("\(key)")
            }
                
            for image in itemDictionary {
                
                let imagename = image.key
                print(imagename)
                
                if let imageCache = NSCache.sharedInstance.objectForKey(imagename) as? UIImage {
                    print(imageCache)
                    self.imageDict[imageCache] = image.value
                }
                    
                else {
                    let profilePicRef = self.storageRef.child(self.imageName!).child("\(imagename).jpg")
                    //sets the image on profile
                    profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                        if (error != nil) {
                            print ("File does not exist")
                            return
                        } else {
                            if (data != nil){
                                var imageToCache = UIImage(data:data!)
                                NSCache.sharedInstance.setObject(imageToCache!, forKey: imagename)
                                self.imageDict[imageToCache!] = image.value
                                
                            }
                        }
                    }
                }
                
                //change image dictionary into sorted image array
                var sortedTuples = self.imageDict.sort({ (a, b) in (a.1 as! Double) < (b.1 as! Double) })
                
                for tuple in sortedTuples {
                    if sortedTuples.count == self.imageNameList.count {
                        self.imageList.append(tuple.0)
                    }
                }
            }
            
            
            self.maxImages  = self.imageList.count - 1
            self.pageControl.currentPage = 0
            self.pageControl.numberOfPages = self.maxImages + 1
            if self.imageList.count > 0 {
                self.imageView.image =  self.imageList[0]
            }
            
        })
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:") // put : at the end of method name
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:") // put : at the end of method name
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
    
    }
    @IBAction func buttonPressed(sender: SpringButton) {
        //var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ItemViewController.timefunc), userInfo: nil, repeats: true)
        timefunc()
    }
    

    
    func swiped(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Right :
                
                
                // decrease index first
                
                imageIndex -= 1
                self.pageControl.currentPage -= 1
                
                // check if index is in range
                
                
                if imageIndex < 0 {
                    
                    imageIndex = maxImages
                    self.pageControl.currentPage = maxImages + 1
                    
                }
                
                if imageIndex >= 0 {
                    imageView.image =  imageList[imageIndex]
                }
                
            case UISwipeGestureRecognizerDirection.Left:
            
                
                // increase index first
                
                imageIndex += 1
                
                self.pageControl.currentPage += 1
                
                // check if index is in range
                
                
                if imageIndex > maxImages {
                    
                    imageIndex = 0
                    self.pageControl.currentPage = 0
                    
                }
                if imageIndex <= imageList.count && imageList.count > 0 {
                    imageView.image = imageList[imageIndex]
                }
            default:
                break //stops the code/codes nothing.
            }
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.performSegueWithIdentifier("goBack", sender: self)
    }
    
    @IBAction func startNewChat(sender: AnyObject) {
        //NEED 4 things for this function to run
        // 1- Current user's uid and name  && 2 - other user's uid and name
        
        
        let thisUserId = FIRAuth.auth()?.currentUser?.uid
        let thisUsername = FIRAuth.auth()?.currentUser?.displayName
        
        //NOTE this should be like otherUserId = self.otherUserId ( should be easily accesible if you are already showing the item by the user )
        let otherUserId = self.userID
        let otherUsername = self.sellerName.text
        
        
        //IGNORE THE FOLLOWING COMMENTS
        //        //running call anyways
        //
        //        getUserName((FIRAuth.auth()?.currentUser?.uid)!) { (name) -> Void in
        //            print("called in function")
        //            otherUserName = name
        //        }
        //
        //        print("called outside function")
        
        
        var newChatId = "\(thisUserId!)&&\(otherUserId!)"
        let otherNewChatId = "\(otherUserId!)&&\(thisUserId!)"
        self.chatUID = newChatId
        
        
        //uncomment this line or make a similar reference
        let chatRootRef = FIRDatabase.database().reference().child("user")
        
        //Checking if the chat already exists
        
        chatRootRef.child(thisUserId!).child("chats").observeSingleEventOfType(FIRDataEventType.Value, withBlock: {snapshot in
            if snapshot.hasChild(newChatId) || snapshot.hasChild(otherNewChatId){
                if snapshot.hasChild(otherNewChatId){
                    newChatId = otherNewChatId
                    self.chatUID = newChatId
                }
                self.performSegueWithIdentifier("shortCutChat", sender: self)
            }else{
                let unreadMessage = [thisUserId!,0]
                let timeInterval = NSDate().timeIntervalSinceReferenceDate
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("lastMessage").setValue("Hey")
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("otherUID").setValue(otherUserId)
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("otherUsername").setValue(otherUsername)
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("unread").setValue(unreadMessage)
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("lastUpdated").setValue(Int (timeInterval))
                
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("lastMessage").setValue("Hey")
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("otherUID").setValue(thisUserId)
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("otherUsername").setValue(thisUsername)
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("unread").setValue(unreadMessage)
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("lastUpdated").setValue(Int (timeInterval))

                
                //adding a new starter message by the person who started the chat
                let chatRef = FIRDatabase.database().reference().child("chats")
                chatRef.child(newChatId).child("0").child("senderId").setValue(thisUserId)
                let dateformatter = NSDateFormatter()
                dateformatter.timeZone = NSTimeZone(abbreviation: "GMT")
                dateformatter.dateFormat = "MMM dd, yyyy HH:mm zzz"
                
                //Add dates to the chat table view
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("sentDate").setValue(dateformatter.stringFromDate(NSDate()))
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("sentDate").setValue(dateformatter.stringFromDate(NSDate()))
                
                chatRef.child(newChatId).child("0").child("sentDate").setValue(dateformatter.stringFromDate(NSDate()))
                chatRef.child(newChatId).child("0").child("text").setValue("Hey!")
                
                self.performSegueWithIdentifier("shortCutChat", sender: self)
            }
        })
        
    }
 
    @IBAction func toProfileButton(sender: AnyObject) {
        
        performSegueWithIdentifier("toProfile", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goBack" {
            let destinationVC = segue.destinationViewController as! MarketplaceViewController
            
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromBottom
            view.window!.layer.addAnimation(transition, forKey: kCATransition)
            
            destinationVC.imageNameArray = self.imageNameArray
            destinationVC.imageArray = self.imageArray
            destinationVC.userArray = self.userArray
      
            
            
        }else if segue.identifier == "shortCutChat"{
            let destinationNavVC = segue.destinationViewController as! UINavigationController
            let destVC = destinationNavVC.viewControllers[0] as! ChatsTableViewController
            destVC.fbUID = ""
            destVC.userName = FIRAuth.auth()?.currentUser?.displayName
            destVC.firebaseUID = FIRAuth.auth()?.currentUser?.uid
            destVC.fromMarketPlace = true
            destVC.chatUID = self.chatUID
        }
        
        if segue.identifier == "cutToChat"{
            let chatVC = segue.destinationViewController as! SingleChatViewController
            chatVC.senderId = FIRAuth.auth()?.currentUser?.uid
            chatVC.senderDisplayName = FIRAuth.auth()?.currentUser?.displayName
            chatVC.chatUID = self.chatUID
            chatVC.fromMarketPlace = true
        }
        
        if segue.identifier == "toProfile" {
            let profileVC = segue.destinationViewController as! ProfileViewController
            profileVC.marketVC = true
            profileVC.userID = self.userID
            profileVC.savedImageName = self.imageName
        
        }
    }
}





