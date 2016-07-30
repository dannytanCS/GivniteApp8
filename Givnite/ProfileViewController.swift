//
//  ProfileViewController.swift
//  Givnite
//
//  Created by Danny Tan  on 7/3/16.
//  Copyright © 2016 Givnite. All rights reserved.
//



import UIKit
import FBSDKCoreKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase


class ProfileViewController: UIViewController, UITextViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var schoolNameLabel: UILabel!
    
    
    @IBOutlet weak var graduationYearLabel: UILabel!
    
    @IBOutlet weak var addButton: SpringButton!
    
    @IBOutlet weak var majorLabel: UILabel!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var settingButton: UIButton!
    
    
    //connection buttons

    
    @IBOutlet weak var connectButton: DesignableButton!
    
    @IBOutlet weak var connectionButton: UIButton!
    
    var currentStateConnection:String?
    
    
    
    
    
    let storageRef = FIRStorage.storage().referenceForURL("gs://givniteapp-292f6.appspot.com")

    let dataRef = FIRDatabase.database().referenceFromURL("https://givniteapp-292f6.firebaseio.com/")
    let user = FIRAuth.auth()!.currentUser

    
    var imageNameArray = [String]()
    
    var imageArray = [UIImage]()
    
    var userID: String?
    
    var otherUser: Bool = false
    
    
    var placeHolderText: String = "placeholder"
    
    
    let screenSize = UIScreen.mainScreen().bounds
    
    
    
    //from market item VC
    var marketVC: Bool = false
    var savedImageName: String?
 
    
    
    //CHAT ADDITION
    //CHAT ADDITION
    //CHAT ADDITION
    var fbUID: String?
    var currentUserName: String?
    let firebaseUID = FIRAuth.auth()?.currentUser?.uid

 
    
    
    func timefunc()
    {
        addButton.animation = "pop"
        addButton.curve = "easeIn"
        addButton.duration = 1.0
        addButton.x = 0
        addButton.force = 0.5
        addButton.velocity = 0.1
        addButton.damping = 1
        addButton.animate()
    }
    
    func timefuncNew()
    {
        addButton.animation = "shake"
        addButton.curve = "linear"
        addButton.duration = 1.0
        addButton.animate()
    }
    
    override func viewDidLoad() {

        
        connectButton.hidden = true
        
        if otherUser == false && marketVC == false {
            userID = self.user?.uid
            storesInfoFromFB()
        }
        

    
        if otherUser == true || marketVC == true {
            print(123123)
            settingButton.hidden = true
            addButton.hidden = true
            connectionButton.hidden = true
            
            
            if (user!.uid != userID!) {
                print(123123)
                connectButton.hidden = false
            }
    
        }

        if marketVC == true {
            otherUser = marketVC
        }
        
        
    
        
        super.viewDidLoad()
      
    
        
      
       
        
        //var timer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: #selector(ItemViewController.timefunc), userInfo: nil, repeats: true)
        self.view.bringSubviewToFront(name)
        self.view.bringSubviewToFront(addButton)
        self.view.bringSubviewToFront(settingButton)
        
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.borderWidth = 2
        self.profilePicture.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).CGColor
    
        
    
        
        loadImages()
        getProfileImage()
        schoolInfo()
        
        
        self.bioTextView.editable = false
        
        
       
        
    
        
        if marketVC == false{
            let swipeRightGestureRecognizer : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "showMarketplace")
            swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
            self.view.addGestureRecognizer(swipeRightGestureRecognizer)
        }
        //CHAT ADDITION
        //CHAT ADDITION
        //CHAT ADDITION
        
        
        //Listeners for Gesture Recognizers
        if otherUser==false{
            let swipeLeftGestureRecognizer : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "showChatsTableView")
            swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
            self.view.addGestureRecognizer(swipeLeftGestureRecognizer)
        }
        
        
        if marketVC == true{
            let swipeRightGestureRecognizer : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "backToUserItem")
            swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
            self.view.addGestureRecognizer(swipeRightGestureRecognizer)
        }

        
    }
    
    //LOWER TWO FUNCTIONS ARE CHAT ADDITIONS
    //CHAT ADDITIONS
    //CHAT ADDITIONS
    //CHAT ADDITIONS
    
    
    //function for unwind segue
    @IBAction func returnToProfile(sender: UIStoryboardSegue){
        
    }
    
    //functions for gesture recognizers
    
    func showChatsTableView(){
        self.performSegueWithIdentifier("toChatsTableView", sender: self)
    }

    
    func showMarketplace(){
        self.performSegueWithIdentifier("toMarketplace", sender: self)
    }
    
    
    func backToUserItem() {
        self.performSegueWithIdentifier("backToItem", sender: self)
    }
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    //layout for cell size

    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 3)/3, height: (collectionView.frame.size.width - 3)/3 )
    }

    
    
    
    //loads images from cache or firebase
    
    func loadImages() {
        dataRef.child("user").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
        
            //adds image name from firebase database to an array
            
            if let itemDictionary = snapshot.value!["items"] as? NSDictionary {
            
                let sortKeys = itemDictionary.keysSortedByValueUsingComparator {
                    (obj1: AnyObject!, obj2: AnyObject!) -> NSComparisonResult in
                    let x = obj1 as! NSNumber
                    let y = obj2 as! NSNumber
                    return y.compare(x)
                }
            
                for key in sortKeys {
                    self.imageNameArray.append("\(key)")
                }
            
                if (self.imageArray.count == 0){
                    for index in 0..<self.imageNameArray.count {
                        self.imageArray.append(UIImage(named: "Examples")!)
                    }
                }
            
                dispatch_async(dispatch_get_main_queue(),{
                    self.collectionView.reloadData()
                })
            }
        })
    
    }
    
    //sets up the collection view
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageNameArray.count
    }
    
 

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderText
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as!
        CollectionViewCell
        
        
        if let imageName = self.imageNameArray[indexPath.row] as? String {
            var num = indexPath.row
            cell.imageView.image = nil
            
            
            if let image = NSCache.sharedInstance.objectForKey(imageName) as? UIImage{
                cell.imageView.image = image
                self.imageArray[indexPath.row] = image
            }
                
            else {
                
                var profilePicRef = storageRef.child(imageName).child("\(imageName).jpg")
                //sets the image on profile
                profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        print ("File does not exist")
                        return
                    } else {
                        if (data != nil){
                            let imageToCache = UIImage(data:data!)
                            NSCache.sharedInstance.setObject(imageToCache!, forKey: imageName)
                            //update to the correct cell
                            if (indexPath.row == num){
                                dispatch_async(dispatch_get_main_queue(),{
                                    cell.imageView.image = imageToCache
                                    self.imageArray[indexPath.row] = imageToCache!
                                    
                                })
                            }
                        }
                    }
                    }.resume()
            }
        }
        return cell
    }

    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showImage", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImage" {
            
            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath
            let destinationVC = segue.destinationViewController as! ItemViewController
            
            
            destinationVC.image = self.imageArray[indexPath.row]
            
            destinationVC.imageName  = self.imageNameArray[indexPath.row]
            
            destinationVC.userName = self.name.text!
            
            destinationVC.otherUser = self.otherUser.boolValue

            
            destinationVC.userID = self.userID
            
            if marketVC == true {
                destinationVC.marketVC = true
                destinationVC.savedImageName = self.savedImageName
              
            }
        }
        
        else if segue.identifier == "toChatsTableView"{
            let destinationNavVC = segue.destinationViewController as! UINavigationController
            let destVC = destinationNavVC.viewControllers[0] as! ChatsTableViewController
            destVC.fbUID = fbUID
            destVC.userName = FIRAuth.auth()?.currentUser?.displayName
            destVC.firebaseUID = firebaseUID
        }
        
        else if segue.identifier == "showCamera" {
            let destinationVC = segue.destinationViewController as! Camera
            destinationVC.school = self.schoolNameLabel.text
            destinationVC.major = self.majorLabel.text
        }
        
        else if segue.identifier == "backToItem" {
            let destinationVC = segue.destinationViewController as! MarketItemViewController
            destinationVC.userID = self.userID
            destinationVC.imageName = self.savedImageName
        }
    }
    
    
    var profileImageCache = NSCache()
    
    //gets and stores info from facebook
    func storesInfoFromFB(){
        
        let profilePicRef = storageRef.child(userID!+"/profile_pic.jpg")
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, id, gender, email, picture.type(large)"]).startWithCompletionHandler{(connection, result, error) -> Void in
            
            if error != nil {
                print (error)
                return
            }
            
            if let name = result ["name"] as? String {
                self.dataRef.child("user").child(self.userID!).child("name").setValue(name)
                //CHAT ADDITION
                //CHAT ADDITION
                //CHAT ADDITION
                self.currentUserName = name
            }
            
            if let profileID = result ["id"] as? String {
                self.dataRef.child("user").child(self.userID!).child("ID").setValue(profileID)
                //CHAT ADDITION
                //CHAT ADDITION
                //CHAT ADDITION
                self.fbUID = profileID
            }
            
            if let gender = result ["gender"] as? String {
                self.dataRef.child("user").child(self.userID!).child("gender").setValue(gender)
            }
            
            if let picture = result["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary,url = data["url"] as? String {
            
                if let imageData = NSData(contentsOfURL: NSURL (string:url)!) {
                    let uploadTask = profilePicRef.putData(imageData, metadata: nil){
                        metadata, error in
                            
                        if(error == nil) {
                            let downloadURL = metadata!.downloadURL
                            
                            profilePicRef.downloadURLWithCompletion { (URL, error) -> Void in
                                if (error != nil) {
                                    // Handle any errors
                                }
                                else {
                                    self.dataRef.child("user").child("\(self.user!.uid)/picture").setValue("\(URL!)")
                                }
                            }
                        }
                        else{
                            print ("Error in downloading image")
                        }
                    }
                }
            }
        }
    }
    
    

    
    
    func schoolInfo() {
        dataRef.child("user").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
         
            // Get user value
            if let name = snapshot.value!["name"] as? String {
                self.name.text = name
            }
            if let school = snapshot.value!["school"] as? String {
                self.schoolNameLabel.text = school
            }
            if let graduationYear = snapshot.value!["graduation year"] as? String {
                self.graduationYearLabel.text = "Class of " + graduationYear
            }
            if let major = snapshot.value!["major"] as? String {
                self.majorLabel.text = major
            }
            

            if let bioDescription = snapshot.value!["bio"] as? String {

                if bioDescription == "" || bioDescription == self.placeHolderText{
                    self.bioTextView.text = self.placeHolderText
                    self.bioTextView.textColor = UIColor.lightGrayColor()
                }
                else {
                    
                    self.bioTextView.text = bioDescription
                }
            }
            })
        
        
        if (userID != user!.uid) {
        
            dataRef.child("user").child(userID!).child("connections").child(self.user!.uid).observeSingleEventOfType(.Value, withBlock: { (snapshot)
                in
                
                
                if let value = snapshot.value! as? Int {
                  
                    
                    if value == 0 {
                        self.connectButton.setTitle("Confirm", forState: .Normal)
                        self.currentStateConnection = "0"
                    }
                    if value == 1 {
                        self.connectButton.setTitle("Request", forState: .Normal)
                        self.currentStateConnection = "1"
                    }
                    
                    if value == 2 {
                        self.connectButton.setTitle("Givnited", forState: .Normal)
                        self.currentStateConnection = "2"
                    }
                    
                    
                }
                    
                    
                else {
                    self.connectButton.setTitle("Add Friend", forState: .Normal)
                    
                    self.currentStateConnection = "3"
                }
                
            })
        }

    }
    
    
    func getProfileImage() {
        
        if let image = NSCache.sharedInstance.objectForKey(userID!) as? UIImage{
            self.profilePicture.image = image
        }
            
        else {
            let profilePicRef = storageRef.child(userID!+"/profile_pic.jpg")
            profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    var cacheImage = UIImage(data: data!)
                    self.profilePicture.image = cacheImage
                    NSCache.sharedInstance.setObject(cacheImage!, forKey: self.userID!)
                }
            }
        }
    }
    

        
        
      
    
    
    @IBAction func cameraPushed(sender: AnyObject) {
        performSegueWithIdentifier("showCamera", sender: self)
    }
    
    
    //connections functions
    
    //0 means requested (pending)
    //1 means waiting to connect (on the other user's side)
    //2 means givnited (both accepted)
    
   
    

    
    @IBAction func connectAction(sender: AnyObject) {
        //default
        
        if currentStateConnection! == "3" {
            
            dataRef.child("user").child(user!.uid).child("connections").child(userID!).setValue(0)
            
            dataRef.child("user").child(userID!).child("connections").child(user!.uid).setValue(1)
            
            self.connectButton.setTitle("Requested", forState: .Normal)
            self.currentStateConnection = "2"
        }
            
            //connected
            
            
        else if currentStateConnection! == "0" {
            
            dataRef.child("user").child(user!.uid).child("connections").child(userID!).setValue(2)
            
            dataRef.child("user").child(userID!).child("connections").child(user!.uid).setValue(2)
            
            self.connectButton.setTitle("Givnited", forState: .Normal)
            
            self.currentStateConnection = "2"
            
            
            
        }
            
            //says givnited or requested
            
        else if currentStateConnection! == "2" || currentStateConnection! == "1" {
            
            dataRef.child("user").child(user!.uid).child("connections").child(userID!).removeValue()
            
            dataRef.child("user").child(userID!).child("connections").child(user!.uid).removeValue()
            
            self.connectButton.setTitle("Add Friend", forState: .Normal)
            
            self.currentStateConnection = "3"
            
            
        }
    }
    
    
    @IBAction func showConnections(sender: AnyObject) {
        
        let connectionViewController: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("connection")
        self.presentViewController(connectionViewController, animated: true, completion: nil)
    }
    
    
    
    
}
