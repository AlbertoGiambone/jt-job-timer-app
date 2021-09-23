//
//  LoginViewController.swift
//  jt job timer app
//
//  Created by Alberto Giambone on 20/08/21.
//

import UIKit
import Firebase
import FirebaseUI

class LoginViewController: UIViewController, FUIAuthDelegate {

    
    //MARK: Connection
    
    @IBOutlet weak var AppLogo: UIImageView!
    
    
    
    
    //MARK: LIfeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppLogo.layer.cornerRadius = 64
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        signInTrust()
    }
    
    //MARK: Sign in
    
    func showUserInfo(user:User) {

        print("USER.UID: \(user.uid)")
        UserDefaults.standard.setValue(user.uid, forKey: "userInfo")
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            print("GREAT!!! You Are Logged in as \(user.uid)")
            UserDefaults.standard.setValue(user.uid, forKey: "userInfo")
        }
    }
    
    func showLoginVC() {
        let autUI = FUIAuth.defaultAuthUI()
        let providers = [FUIOAuth.appleAuthProvider()]
        
        autUI?.providers = providers
        
        let autViewController = autUI!.authViewController()
        autViewController.modalPresentationStyle = .fullScreen
        self.present(autViewController, animated: true, completion: nil)
    }
    
    func signInTrust() {
        if UserDefaults.standard.object(forKey: "userInfo") != nil {
            DispatchQueue.main.async { // <<<<< (new)
                let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as! TabBarController
                secondVC.modalPresentationStyle = .fullScreen // <<<<< (switched)
                self.present(secondVC, animated:true, completion:nil)
                print("USER LOGGED IN!!!")
            }
        } else {
            print("USER NOT LOGGED IN")
        }
        
    }
    
    
    //MARK: SignIn Action
    
    
    @IBAction func AppleSignInPressed(_ sender: UIButton) {
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.showUserInfo(user:user)
                UserDefaults.standard.removeObject(forKey: "userInfo")
                
                let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as! TabBarController
                secondVC.modalPresentationStyle = .fullScreen // <<<<< (switched)
                self.present(secondVC, animated:true, completion:nil)
                UserDefaults.standard.setValue(user.uid, forKey: "userInfo")
                print("USER LOGGED IN!!!")
                
            } else {
                self.showLoginVC()
            }
        }
        
    }
    
 
    @IBAction func AnonymousSignInPressed(_ sender: UIButton) {
        
        Auth.auth().signInAnonymously { authResult, error in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            UserDefaults.standard.setValue(user.uid, forKey: "userInfo")
            if isAnonymous == true {
                print("User is signed in with UID \(user.uid)")
                UserDefaults.standard.removeObject(forKey: "userInfo")
                
                let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as! TabBarController
                    self.present(secondVC, animated:true, completion:nil)
            
                }
            
            }
        
    }
    
    
    
}
