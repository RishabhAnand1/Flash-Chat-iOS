//
//  ChatViewController.swift
//  Flash Chat iOS13


import UIKit
import Firebase
import WebKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = [
        //We do not these dummy message anymore as we are taking inputs from the user
//        Message(sender: "1@2.com", body: "Hey!"),
//        Message(sender: "a@b.com", body: "Hello!"),
//        Message(sender: "1@2.com", body: "What's up?")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
//      tableView.delegate = self //also change it in Attributes inspector
        title = K.appName
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
        

    }
    
    func loadMessages() {
        
        
        //If we wanted to use the data just once, we would use dbcollection().getDocumets. But since we have to update our chatTable in real time, we use a feature of Firebase which can listen to changes and update the document dictionary in real time. To use it, we replace .getDocuments with .addSnapshotListner
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { querySnapshot, error in
            
            self.messages = [] //We empty out the messages array in order to flus the previous data which otherwise would repeat everytime a new message is added
            
            if let e = error {
                print("There was an error \(e)")
            } else {
                // Getting hold of the data in form of a dictionary
                if let snapShotDocuments = querySnapshot?.documents {
                    for doc in snapShotDocuments {
                        let data = doc.data()
                        //Conditionally downcasting messageSender, messageBody as a string because it is of type "Any" when accessed from Firestore
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            //This wilk tap into the table view and trigger the dataSource method again. Remember: Whenever trying to manipulate the user interface, inside a closure, it is better to enclose the code inside a DipatchQueue
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                //This part is used to self scroll the tableView to the bottom
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        //Making and puttion data into Message Model and subsequently to Firestore
        if let messageBody = messageTextfield.text , let messageSender = Auth.auth().currentUser?.email {
            //We are saving our data in form of a dictionary [String: Any] and sending it to Firestore cloud
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970 //We'll use this dateField to sort the messages on the basis of the time they were created/sent.
            ]) { error in
                if let e = error {
                    print("There was an issue saving data to firestore \(e)")
                } else {
                    print("Message saved succefully")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                    
                }
            }
            
        }
        
    }
    

    @IBAction func logOutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
      
    }
    
}


extension ChatViewController: UITableViewDataSource {
    
    //How many rows or cells do you want in your tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    //This method is asking us for a UITableView cell that it should display in each and every row of the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        //Here we are adjusting the appearence of the message bubble according to sender
        //This is a message form the current user
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }//This is a message from another sender
        else {
            
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
       
        return cell
        
    }
    
    
}

//extension ChatViewController: UITableViewDelegate {
//    //Whenever the table view is interacted by the user, then we get this method triggered, which we don't need currently in this app
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath)
//    }
//
//
//}


