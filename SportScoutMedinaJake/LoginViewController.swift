//
//  LoginViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Hide password
        passwordTextField.isSecureTextEntry = true
        
        // ask for notification auth
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) {
            (granted,error) in
            if granted {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        // sign in the user if they already signed in
        Auth.auth().addStateDidChangeListener() {
            (auth,user) in
            if let user = user {
                // check if the user is done customizing their profile;
                // meaning that they have an entry in the 'users' table
                let docRef = db.collection("users").document(user.uid)
                docRef.getDocument {
                    (documentSnapshot, error) in
                    if let document = documentSnapshot, document.exists {
                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                        self.emailTextField.text = nil
                        self.passwordTextField.text = nil
                    }
                    if error != nil {
                        print("Error: LoginViewController: Unable to check if user exists.")
                    }
                }
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (authResult,error) in
            if ((error as NSError?) != nil) {
                    self.errorMessage.text = "Invalid email or password"
            } else {
                self.errorMessage.text = ""
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                self.emailTextField.text = nil
                self.passwordTextField.text = nil
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
