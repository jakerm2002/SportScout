//
//  SignupViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    var SignupToCustomizeProfileSegueIdentifier = "SignupToCustomizeProfileSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide password
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
//        Auth.auth().addStateDidChangeListener() {
//            (auth,user) in
//            if user != nil {
//                self.performSegue(withIdentifier: self.SignupToCustomizeProfileSegueIdentifier, sender: nil)
//                self.emailTextField.text = nil
//                self.passwordTextField.text = nil
//            }
//        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
}

     // Code from Firebase to get a user's profile info

     //import { getAuth } from "firebase/auth";
     //
     //const auth = getAuth();
     //const user = auth.currentUser;
     //if (user !== null) {
     //  // The user object has basic properties such as display name, email, etc.
     //  const displayName = user.displayName;
     //  const email = user.email;
     //  const photoURL = user.photoURL;
     //  const emailVerified = user.emailVerified;
     //
     //  // The user's ID, unique to the Firebase project. Do NOT use
     //  // this value to authenticate with your backend server, if
     //  // you have one. Use User.getToken() instead.
     //  const uid = user.uid;
     //}


     // Update a user's profile

     //import { getAuth, updateProfile } from "firebase/auth";
     //const auth = getAuth();
     //updateProfile(auth.currentUser, {
     //  displayName: "Jane Q. User", photoURL: "https://example.com/jane-q-user/profile.jpg"
     //}).then(() => {
     //  // Profile updated!
     //  // ...
     //}).catch((error) => {
     //  // An error occurred
     //  // ...
     //});

