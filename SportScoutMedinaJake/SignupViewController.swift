//
//  SignupViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit

class SignupViewController: UIViewController {

    var SignupToCustomizeProfileSegueIdentifier = "SignupToCustomizeProfileSegue"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        // do firebase user creation
        self.performSegue(withIdentifier: SignupToCustomizeProfileSegueIdentifier, sender: nil)
    }
    

}
