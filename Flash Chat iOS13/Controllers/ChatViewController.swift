//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages : [Message] = [
        Message(sender: "1@2.com", body: "Hello"),
        Message(sender: "a@b.com", body: "Hi there"),
        Message(sender: "1@2.com", body: "You are beautiful")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier )
        title = K.appName
        navigationItem.hidesBackButton = true
        
        loadMessages()
    }
    
    func loadMessages() {
        
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { querySnapshot, error in
            
            self.messages = []
            
            if let e = error {
                print (e)
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    print(snapshotDocuments)
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        print(data)
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            
                            //add new message to messages array
                            self.messages.append(newMessage)
                            
                            //update the ui or table view
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                
                                //Go to the bottom of messages
                                let indexPath = IndexPath(row: self.messages.count  - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true )
                                self.messageTextfield.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.bodyField: messageBody,
                K.FStore.senderField: messageSender,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { error in
                
                    if let e = error {
                        print(e)
                    } else {
                        print("Send data succesfully.")
                        
                    }
            }
        }
        
    }
    
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            //Navigate to welcome screen
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController : UITableViewDataSource {
    //Data Source chi lay data cho tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        //Casting to our messagecell design
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        
        cell.label.text = message.body
        
        //This is the message from the current user
        if message.sender == Auth.auth().currentUser?.email {
            
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            //Set background color for bubble
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            //Change label text color
            cell.label.textColor = UIColor(named: K.BrandColors.purple )
        }
        //This is the message from the other sender
        else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            
            //Set background color for bubble
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            //Change label text color
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple  )
        }
        
        
        print(indexPath.row)
        return cell
    }
}


extension ChatViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

