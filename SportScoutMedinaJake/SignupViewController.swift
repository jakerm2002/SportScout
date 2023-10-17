//
//  SignupViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import FirebaseAuth
import CoreData

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    var SignupToCustomizeProfileSegueIdentifier = "SignupToCustomizeProfileSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        fullNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        // Hide password
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        // Firebase user creation
        if self.usernameTextField.text == "" || self.fullNameTextField.text == "" || self.emailTextField.text == "" || self.passwordTextField.text == "" { // If a field is empty
            self.errorMessage.text = "One or more fields are missing"
        } else if self.passwordTextField.text != self.confirmPasswordTextField.text { // Passwords do not match
            self.errorMessage.text = "Passwords do not match"
        } else { // Everything looks valid, proceed to create account and segue
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                (authResult,error) in
                if let error = error as NSError? { // If there is an error
                    self.errorMessage.text = "\(error.localizedDescription)"
                } else {
                     self.errorMessage.text = ""
                     self.performSegue(withIdentifier: self.SignupToCustomizeProfileSegueIdentifier, sender: nil)
                     self.usernameTextField.text = nil
                     self.fullNameTextField.text = nil
                     self.emailTextField.text = nil
                     self.passwordTextField.text = nil
                     self.confirmPasswordTextField.text = nil
                }
            }
        }
    }
    
    func storeUser(username:String, fullName:String) {
        // store a user's username and Full Name into Core Data
        
        let user = NSEntityDescription.insertNewObject(
            forEntityName: "User",
            into: context)
        
        user.setValue(username, forKey: "username")
        user.setValue(fullName, forKey: "fullName")
        
        // commit the changes
        saveContext()
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Keyboard code
    // Called when 'return' key pressed

    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

