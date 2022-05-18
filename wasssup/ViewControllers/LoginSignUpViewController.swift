//
//  LoginSignUpViewController.swift
//  wasssup
//
//  Created by Lawrence Gimenez on 01/05/2017.
//  Copyright © 2017 Law Gimenez. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import PKHUD
import SwiftHEXColors

class LoginSignUpViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginSignUpButton: UIButton!
    
    // MARK: - ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates for username and password TextField
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        // Add padding / inset for both TextFields
        usernameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        // Gesture recognized for dismissing keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        // Add text change recognizer
        usernameTextField.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
        // Disable login and sign up button first
        loginSignUpButton.isEnabled = false
        // Make Login / Sign up button rounded
        loginSignUpButton.layer.cornerRadius = 6
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update navigation bar background color
        navigationController?.navigationBar.barTintColor = .white
        // Hide back button
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    // MARK: - Actions
    
    @IBAction func loginSignUpTapped(_ sender: Any) {
        // Show logging in indicator
        showSignInIndicator()
        // Get username inputted
        let username = usernameTextField.text
        // Sign in user
        FIRAuth.auth()?.signIn(
            withEmail: username! + "@wasssup.com",
            password: passwordTextField.text!,
            completion: {
            user, error in
            if error == nil {
                // Get user name
                let usernameDatabase = FIRDatabase.database().reference().child(Keys.databaseUsername).child((user?.uid)!)
                usernameDatabase.observeSingleEvent(of: .value, with: {
                    snapshot in
                    if snapshot.value is NSNull {
                    } else {
                        let value = snapshot.value as! NSDictionary
                        let username = value["username"] as! String
                        self.saveUsername(username: username, userId: (user?.uid)!)
                        // Open chat page
                        self.goToChat()
                    }
                    self.hideSignInIndicator()
                })
            } else {
                if let errorCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
                    if errorCode == FIRAuthErrorCode.errorCodeUserNotFound {
                        // If user not found sign up
                        FIRAuth.auth()?.createUser(
                            withEmail: username! + "@wasssup.com",
                            password: self.passwordTextField.text!,
                            completion: {
                            user, error in
                            if error == nil {
                                // Sign up success
                                self.saveUsername(username: username!, userId: (user?.uid)!)
                                // Open chat page
                                self.goToChat()
                            }
                            // Hide sign in indicator
                            self.hideSignInIndicator()
                        })
                    }
                } else {
                    // Display error message
                    let errorAlertController = UIAlertController(title: "Wasssup", message: "There was a problem with login or signing up.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    errorAlertController.addAction(okAction)
                    self.present(errorAlertController, animated: true, completion: nil)
                }
            }
        })
    }
    
    // MARK: - Public methods
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldChanged(_ textField: UITextField) {
        if !(usernameTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)! {
            loginSignUpButton.isEnabled = true
        } else {
            // Disable login / sign up button
            loginSignUpButton.isEnabled = false
        }
    }
    
    func showSignInIndicator() {
        // Dismiss keyboard
        dismissKeyboard()
        // Display progress indicator
        HUD.show(.labeledProgress(title: "Wasssup", subtitle: "Signing in..."))
    }
    
    func hideSignInIndicator() {
        HUD.hide()
    }
    
    // MARK: - Private methods
    
    private func saveUsername(username: String, userId: String) {
        let usernameDatabase = FIRDatabase.database().reference().child(Keys.databaseUsername).child(userId)
        usernameDatabase.child(Keys.username).setValue(username)
        UserDefaults.standard.set(username, forKey: Keys.username)
    }
    
    private func goToChat() {
        // Set flag to logged in
        UserDefaults.standard.set(true, forKey: Keys.isLoggedIn)
        performSegue(withIdentifier: "goToChat", sender: nil)
    }
}

extension LoginSignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            // Dismiss keyboard
            dismissKeyboard()
        }
        return true
    }
}
