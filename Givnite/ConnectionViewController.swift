//
//  ConnectionViewController.swift
//  Givnite
//
//  Created by Danny Tan on 7/27/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase



class ConnectionViewController: UIViewController,UITableViewDelegate {
    
    
    
    var userIDArray = [String]()
    var connectedArray = [Int]()
    
    var connections = [User]()
    
    var rowCount = 0

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        
        
        
        super.viewDidLoad()
        

     
        let databaseRef = FIRDatabase.database().referenceFromURL("https://givniteapp.firebaseio.com/")
        let user = FIRAuth.auth()!.currentUser
        
        
        let connectionRef = databaseRef.child("user").child(user!.uid).child("connections")
        
        connectionRef.observeEventType(FIRDataEventType.Value, withBlock:{ (snapshot) -> Void in
            
            
            if let connections = snapshot.value! as? NSDictionary {
                
                let allKeys = connections.allKeys as? [String]
                let allValues = connections.allValues as? [Int]
                
                self.userIDArray = allKeys!
                self.connectedArray = allValues!


    
             
            }
            self.getsTheConnections()
            
        })

    }
    
    

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }

    
    func getsTheConnections() {
        
        let storageRef = FIRStorage.storage().referenceForURL("gs://givniteapp.appspot.com")
        
        let databaseRef = FIRDatabase.database().referenceFromURL("https://givniteapp.firebaseio.com/")
        
        
        databaseRef.child("user").observeEventType(FIRDataEventType.Value, withBlock:{ (snapshot) -> Void in
          
            for user in self.userIDArray {
                
                if let userInfo = snapshot.value![user] as? NSDictionary {
                    
                    var someUser = User()
                    
                    if let name = userInfo["name"] as? String {
                        someUser.name = name
                    }
                    
                    if let school = userInfo["school"] as? String {
                        someUser.school = school
                    }
                    
                    if let imageUrl = userInfo["picture"] as? String {
                        
                        someUser.picture = imageUrl
                    }
                    

                    self.connections.append(someUser)
               
                }
            }
            
        self.rowCount = self.userIDArray.count

        self.tableView.reloadData()
            
        })
    }
  

    // 0 is requested 
    // 1 is connect
    // 2 is givnited
    
  
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell")! as! ConnectionTableViewCell
    
        
  

        if let aUser = self.connections[indexPath.row] as? User {
      
            cell.userName.text = aUser.name
            
            cell.userSchool.text = aUser.school

            
            
            if let image = NSCache.sharedInstance.objectForKey(aUser.name!) as? UIImage{
                cell.userImage.image = image
            }
                
            else {
            
                let url = NSURL (string: aUser.picture!)
                
                NSURLSession.sharedSession().dataTaskWithURL(url!) { (data
                    , response, error) in
                        
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    let imageToCache = UIImage(data: data!)
                    NSCache.sharedInstance.setObject(imageToCache!, forKey: aUser.name!)

                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        cell.userImage.image = imageToCache

                    })
                    
                }.resume()
            }
        }
        
        cell.connectButton.addTarget(self, action: "buttonClick:", forControlEvents: .TouchUpInside)
        
        
     
        
        if let value = self.connectedArray[indexPath.row] as? Int {
        
            if (value == 0) {
                cell.connectButton.setTitle("Requested", forState: .Normal)
              

            }
        
            if (value == 1) {
                cell.connectButton.setTitle("Confirm", forState: .Normal)
               

            }
        
            if (value == 2) {
                cell.connectButton.setTitle("Givnited", forState: .Normal)
              

            }
        
        }
        
        return cell

    }
   
    
    @IBAction func buttonClick(sender: UIButton) {
       
        var touchPoint: CGPoint = sender.convertPoint(CGPointZero, toView: tableView)
        // maintable --> replace your tableview name
        var clickedButtonIndexPath: NSIndexPath = tableView.indexPathForRowAtPoint(touchPoint)!
        
        
        let databaseRef = FIRDatabase.database().referenceFromURL("https://givniteapp.firebaseio.com/")
        let user = FIRAuth.auth()!.currentUser
        
        
        let otherUserID = userIDArray[clickedButtonIndexPath.row]
        
        let connectionValue = connectedArray[clickedButtonIndexPath.row]
        
        //connect
        
        if connectionValue == 1 {
            
            sender.setTitle("Givnited", forState: .Normal)
            
            databaseRef.child("user").child(user!.uid).child("connections").child(otherUserID).setValue(2)
            databaseRef.child("user").child(otherUserID).child("connections").child(user!.uid).setValue(2)
            
            connectionValue == 2
            
        }
        
        
        
        //requested or givnited
        else if connectionValue == 0 || connectionValue == 2 {
            
            
            databaseRef.child("user").child(user!.uid).child("connections").child(otherUserID).removeValue()
        
            databaseRef.child("user").child(otherUserID).child("connections").child(user!.uid).removeValue()
        
        
            connections.removeAtIndex(clickedButtonIndexPath.row)
            
            rowCount -= 1
            tableView.reloadData()
            
            
        }

        
        
    }



    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
