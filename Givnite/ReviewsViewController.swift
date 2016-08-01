//
//  ReviewsViewController.swift
//  Givnite
//
//  Created by Danny Tan on 8/1/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
class ReviewsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var reviewerLeaveMessageTextView: UITextView!
    
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    var reviewers: [Reviewer]?
    
    let databaseRef = FIRDatabase.database().referenceFromURL("https://givniteapp-292f6.firebaseio.com/")
   
    let user = FIRAuth.auth()!.currentUser
    
    var reviewArray = [String] ()
    
    var userID: String?

    var placeHolderText: String = "Leave a message bro."

    var timeArray = [Int]()
    
    var sameUser: Bool = true

    
    func getReviews() {
        
        self.reviewers = [Reviewer] ()

        
        databaseRef.child("user").child(userID!).child("reviews").queryOrderedByChild("time").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
        
            if let keys = snapshot.value?.allKeys as? [String] {
            
                for key in keys {
                    
                    if let reviews = snapshot.value![key] as? NSDictionary {
                        
                
                        if let time = reviews["time"] as? Int {
                            self.timeArray.append(time)
                        }
                    }
                }
                
                self.timeArray = self.timeArray.sort().reverse()
                
                
                for time in self.timeArray {
                    for key in keys {
                        if let keyDictionary = snapshot.value![key] as? NSDictionary {
                            if let time2 = keyDictionary["time"]{
                                if time == time2 as! Int {
                                    self.reviewArray.append(key)
                                }
                            }
                        }
                    }
                }

                self.getReviewInfo()
            
            }

        })
    }
    
    
    func getReviewInfo() {
        
        databaseRef.child("user").child(userID!).child("reviews").queryOrderedByChild("time").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
            for reviewString in self.reviewArray {
                
                var aReviewer = Reviewer()
                
                if let reviews = snapshot.value![reviewString] as? NSDictionary {
                
                    if let review = reviews["review"] as? String {
                        
                        aReviewer.review = review
                    }
                    
                    if let user = reviews["user"] as? String {
                        self.databaseRef.child("user").child(user).observeSingleEventOfType(.Value, withBlock: { (snapshot)
                            in
                            
                            
                            if let name = snapshot.value!["name"] as? String {
                                aReviewer.name = name
                            }
                            if let school = snapshot.value!["school"] as? String {
                                aReviewer.school = school
                            }
                            
                            if let picture = snapshot.value!["picture"] as? String {
                                aReviewer.picture = picture
                            }
                            
                            
                            
                            aReviewer.reviewDate = reviewString
                            
                            self.reviewers?.append(aReviewer)
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                            
                            
                        })
                    }
                }
            }
        })
    
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if sameUser == true {
            self.reviewerLeaveMessageTextView.hidden = true
            self.submitButton.hidden = true
        }
        
        getReviews()
        
        if reviewerLeaveMessageTextView.text.isEmpty {
            reviewerLeaveMessageTextView.text = placeHolderText
            reviewerLeaveMessageTextView.textColor = UIColor.lightGrayColor()
        }

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReviewsViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReviewsViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    
    
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReviewsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.reviewerLeaveMessageTextView.delegate = self

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackToProfileView(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewers!.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewTableViewCell
        
        cell.reviewer = reviewers![indexPath.row]
        
        return cell
        
        
    }
    
    
    //hides keyboard when enter is pressed
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    
    //hides keyboard when tap 
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    //shift the screen when there is a keyboard
    func keyboardWillShow(sender: NSNotification) {
        
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                
                self.view.frame.origin.y -= keyboardSize.height
            }
        } else {
            
            self.view.frame.origin.y += keyboardSize.height - offset.height
        }
    }
    

    
    @IBAction func submitReview(sender: AnyObject) {
        
          reviewerLeaveMessageTextView.resignFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReviewsViewController.keyboardWillShow(_:)), name: UIKeyboardWillHideNotification, object: nil)

        

        
        
        let dateformatter = NSDateFormatter()
    
        
        dateformatter.timeZone = NSTimeZone(abbreviation: "EST")
        dateformatter.dateFormat = "MMMM dd, yyyy HH:mm:ss"
        let dateString = dateformatter.stringFromDate(NSDate())
        let time = FIRServerValue.timestamp()
        
        
        if reviewerLeaveMessageTextView.text == placeHolderText {
            reviewerLeaveMessageTextView.text = ""
            
        }
        databaseRef.child("user").child(userID!).child("reviews").child(dateString).child("review").setValue(reviewerLeaveMessageTextView.text)
            
        
         databaseRef.child("user").child(userID!).child("reviews").child(dateString).child("user").setValue(user!.uid)

        
        databaseRef.child("user").child(userID!).child("reviews").child(dateString).child("time").setValue(time)
        
    
        
        self.reviewerLeaveMessageTextView.text = ""
        reviewArray.removeAll()
        timeArray.removeAll()
        reviewers?.removeAll()
        self.viewDidLoad()
        
        
    }
    
    
    // Placeholder Color
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
