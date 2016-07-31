//
//  SettingProfileViewController.swift
//  Givnite
//
//  Created by Danny Tan on 7/29/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase


class SettingProfileViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var aboutTextView: UITextView!
    
    
    var changePictureActionSheet: UIAlertController?
    let databaseRef = FIRDatabase.database().referenceFromURL("https://givniteapp-292f6.firebaseio.com/")
    let storageRef = FIRStorage.storage().referenceForURL("gs://givniteapp-292f6.appspot.com")
    let user = FIRAuth.auth()!.currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegates
     
        majorTextField.delegate = self
        aboutTextView.delegate = self

        //tap gesture recognizer
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingProfileViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //loads data from firebase
        dataFromFirebase()
        getProfileImage()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // Change Profile Picture
    @IBAction func changeProfilePictureButton(sender: AnyObject) {
        let changePictureActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let takePictureAlertAction = UIAlertAction(title: "Take Picture", style: .Default) { (action) in
            imagePicker.sourceType = .Camera
            self.presentViewController(imagePicker,animated: true, completion:nil)
        }
        let photoLibraryAlertAction = UIAlertAction(title: "Photo Library", style: .Default) { (action) in
            
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker,animated: true, completion:nil)
        }
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            return
        }
        changePictureActionSheet.addAction(takePictureAlertAction)
        changePictureActionSheet.addAction(photoLibraryAlertAction)
        changePictureActionSheet.addAction(cancelAlertAction)
        self.presentViewController(changePictureActionSheet, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let imageTaken = info[UIImagePickerControllerOriginalImage] as? UIImage
        profileImageView.image = imageTaken
        dismissViewControllerAnimated(true, completion: nil)
    
    }

    // Extract Personal Information from Firebase
    func dataFromFirebase () {
        databaseRef.child("user").child(user!.uid).observeEventType (.Value, withBlock: { (snapshot)
            in
            
            
            if let name = snapshot.value!["name"] as? String {
                self.nameLabel.text = name
            }
            if let school = snapshot.value!["school"] as? String {
                self.schoolLabel.text = school
            }
            if let major = snapshot.value!["major"] as? String {
                self.majorTextField.text = major
            }
            if let bioDescription = snapshot.value!["bio"] as? String {
                
                self.aboutTextView.text = bioDescription
            }
            else {
                self.aboutTextView.text = "Enter your information"
            }
            
        })
    }
    
    // Get Profile Image
    func getProfileImage() {
        if let image = NSCache.sharedInstance.objectForKey(user!.uid) as? UIImage{
            self.profileImageView.image = image
        }
        else {
            let profilePicRef = storageRef.child(user!.uid).child("profile_pic.jpg")
            profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    var cacheImage = UIImage(data: data!)
                    self.profileImageView.image = cacheImage
                    NSCache.sharedInstance.setObject(cacheImage!, forKey: self.user!.uid)
                }
            }
        }
    }
    
    // Update the information
    @IBAction func updateButton(sender: AnyObject) {
        databaseRef.child("user").child(user!.uid).child("major").setValue(majorTextField.text)
        databaseRef.child("user").child(user!.uid).child("bio").setValue(aboutTextView.text)
    }

}
