//
//  ChatViewController.swift
//  wasssup
//
//  Created by Lawrence Gimenez on 01/05/2017.
//  Copyright © 2017 Law Gimenez. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var nameMessageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Public variables
    
    public var arrayMessages = [Message]()
    public var userId: String!
    
    // MARK: - Private variables
    
    private var database: Database!
    
    // MARK: - ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create instance of the database
        database = Database()
        // Remove extra cells
        chatTableView.tableFooterView = UIView()
        // Set data source for our TableView
        chatTableView.dataSource = self
        // Set delegate for message TextField
        nameMessageTextField.delegate = self
        // Return key for message TextField should be send
        nameMessageTextField.returnKeyType = .send
        // Add padding / inset for both TextFields
        nameMessageTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        // Add corner radius for send button
        sendButton.layer.cornerRadius = 6
        // Get current user ID
        userId = FIRAuth.auth()?.currentUser?.uid
        // Get messages from the API on start
        getMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        title = "Chat app"
        // Add right logout button item
        let logoutButton = UIButton.init(type: .custom)
        logoutButton.backgroundColor = UIColor(hexString: "#666666")
        logoutButton.addTarget(self, action: #selector(self.logout), for: .touchUpInside)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        logoutButton.setTitle("Log out", for: .normal)
        logoutButton.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        logoutButton.layer.cornerRadius = 6
        logoutButton.clipsToBounds = true
        let estimateRepairsButtonItem = UIBarButtonItem(customView: logoutButton)
        navigationItem.rightBarButtonItem = estimateRepairsButtonItem
    }
    
    // MARK: - Actions
    
    @IBAction func sendTapped(_ sender: Any) {
        // Dismiss keyboard
        nameMessageTextField.resignFirstResponder()
        // And send message to API
        sendMessage()
    }
    
    // MARK: - Public methods
    
    public func logout() {
        try! FIRAuth.auth()?.signOut()
        UserDefaults.standard.set(false, forKey: Keys.isLoggedIn)
        let mainNavigationController = storyboard?.instantiateViewController(withIdentifier: "mainNav") as! UINavigationController
        present(mainNavigationController, animated: true, completion: nil)
    }
    
    public func sendMessage() {
        // Get user ID
        let userId = FIRAuth.auth()?.currentUser?.uid
        let currentDate = Date()
        // Get a reference to the database
        let messageReference = FIRDatabase.database().reference().child(Keys.databaseMessages).childByAutoId()
        messageReference.child(Keys.date).setValue(String(describing: currentDate))
        messageReference.child(Keys.userId).setValue(userId)
        messageReference.child(Keys.username).setValue(UserDefaults.standard.string(forKey: Keys.username))
        messageReference.child(Keys.content).setValue(nameMessageTextField.text)
        // Clear new message TextField
        nameMessageTextField.text = ""
        // Get and update message list
        getMessages()
    }
    
    // MARK: - Private methods
    
    private func getMessages() {
        arrayMessages = database.getAllMessages()
        if !arrayMessages.isEmpty {
            // If messages saved in database, display them immediately
            chatTableView.reloadData()
            // If not empty, hide indicator
            loadingIndicator.isHidden = true
        }
        let messageReference = FIRDatabase.database().reference().child(Keys.databaseMessages)
        messageReference.observe(.value, with: {
            snapshot in
            if snapshot.value is NSNull {
            } else {
                self.arrayMessages.removeAll()
                // Loop through messages
                for messageSnapshot in snapshot.children {
                    // Each snapshot has a key of date
                    // and value of message values
                    let snapshot = messageSnapshot as! FIRDataSnapshot
                    // Get the date
                    let message = Message()
                    message.messageId = snapshot.key
                    // Get the message
                    let messageDict = snapshot.value as! NSDictionary
                    message.date = messageDict[Keys.date] as? String
                    message.content = messageDict[Keys.content] as? String
                    message.username = messageDict[Keys.username] as? String
                    message.userId = messageDict[Keys.userId] as? String
                    // Hide indicator
                    self.loadingIndicator.isHidden = true
                    // Add to our list
                    self.arrayMessages.append(message)
                    // Reload our list
                    self.chatTableView.reloadData()
                    // Save to database
                    self.database.saveMessage(message: message)
                }
            }
        })
    }
}

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Send message to database
        sendMessage()
        // Dismiss keyboard
        textField.resignFirstResponder()
        return true
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = arrayMessages[indexPath.row]
        if message.userId == userId {
            // Use the sent table view cell
            let sentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "sentCell", for: indexPath) as! SentTableViewCell
            sentTableViewCell.contentButton.setTitle(message.content, for: .normal)
            sentTableViewCell.usernameLabel.text = message.username
            return sentTableViewCell
        } else {
            // Use the received table view cell
            let receivedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "receivedCell", for: indexPath) as! ReceivedTableViewCell
            receivedTableViewCell.contentButton.setTitle(message.content, for: .normal)
            receivedTableViewCell.usernameLabel.text = message.username
            return receivedTableViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMessages.count
    }
}
