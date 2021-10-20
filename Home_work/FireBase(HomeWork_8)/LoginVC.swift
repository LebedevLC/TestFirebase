//
//  ViewController.swift
//  FireBase(HomeWork_8)
//
//  Created by Сергей Чумовских  on 18.10.2021.
//

import Foundation
import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet var visibleView: UIView!
    @IBOutlet var loginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    private var tapGesture: UITapGestureRecognizer?
    private var handle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMyTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Adding authorization status listener
        self.handle = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "goToFireBaseNC", sender: nil)
                self.loginTextField.text = nil
                self.passwordTextField.text = nil
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    private func setMyTap() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        visibleView.addGestureRecognizer(tapGesture!)
    }
    
    @objc private func hideKeyboard() {
        self.visibleView?.endEditing(true)
    }

    @IBAction func enterButtonDidTapped(_ sender: UIButton) {
        // 1
        guard
            let email = loginTextField.text,
            let password = passwordTextField.text,
            email.count > 0,
            password.count > 0
        else {
//            self?.showAlert(title: "Error", message: "Login/password is not entered")
            print("Error login/pass")
            return
        }
        // 2
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error, user == nil {
//                self?.showAlert(title: "Error", message: error.localizedDescription)
                print("Error server")
            }
        }

    }
    
    @IBAction func registerButtonDidTapped(_ sender: UIButton) {
        // 1
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        // 2
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        // 3
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        // 4
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let emailField = alert.textFields?[0],
                  let passwordField = alert.textFields?[1],
                  let password = passwordField.text,
                  let email = emailField.text else { return }
            // 4.2
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
                if error != nil {
                    //                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    print("Error server")
                } else {
                    // 4.3
                    Auth.auth().signIn(withEmail: email, password: password)
                }
            }
        }
        // 5
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
}

