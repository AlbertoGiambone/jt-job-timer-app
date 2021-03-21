//
//  HomeViewController.swift
//  jt job timer app
//
//  Created by Alberto Giambone on 21/12/20.
//

import UIKit
import FirebaseUI
import Firebase
import Charts


class HomeViewController: UIViewController, FUIAuthDelegate {

    
    //MARK: Connection
    

    @IBOutlet weak var clientNumber: UITextField!
    
    
    @IBOutlet weak var hoursNumber: UITextField!
    
    
    
    
    
    
    @IBAction func LogOut(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
          } catch let err {
            print(err)
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
    
    func showUserInfo(user:User) {
        
        print("USER.UID: \(user.uid)")
        UserDefaults.standard.setValue(user.uid, forKey: "userInfo")
    }
    
    
    //MARK: view Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.showUserInfo(user:user)
            } else {
                self.showLoginVC()
            }
        }
        
        
            fetchFirestoreData()
        
        
        
    }
    
    var userUID: String?
    
    
    /*Problema di Userdefault NIL, fetchare i dati in maniera diversa o luogo dicerso da willAppear*/
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tabBarItem.isEnabled = true
        
    }
    
    //MARK: Fetch db client for aggregate data
    
    let db = Firestore.firestore()
    
    var clientCounter = [String]()
    var Cnumber: Int?
    var hoursCounter = [String]()
    var stodo = [Double]()
    
    
    func fetchFirestoreData() {
        
        userUID = UserDefaults.standard.object(forKey: "userInfo") as? String
        

        
        let queryRef = db.collection("UserInfo")
        
        //queryRef.whereField("UID", isEqualTo: userUID!)
        
        queryRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    
                    let r = document.data()["UID"] as! String
                    if r == self.userUID {
                    self.clientCounter.append(document.data()["name"] as! String)
                    }
                    
                }
            }
            self.clientNumber.text = String("\(self.clientCounter.count)")
            print("NUMERO CLIENTI XXXXXXXXXXX  \(self.clientCounter.count)")
        }

        
        let queryJob = db.collection("JobTime")
        
        //queryJob.whereField("JUID", isEqualTo: self.userUID!)
        
        queryJob.getDocuments() {
            (querySnapshot, err) in
            if let err = err {
                print("Error getting JobTime documents: \(err)")
            }else{
                for document in querySnapshot!.documents {
                    
                    let r = document.data()["JUID"] as! String
                    
                    if r == self.userUID {
                    
                        let t = document.data()["hours number"] as! String
                        self.hoursCounter.append(t)
                        
                    }
                    
                }
            }
            
            if self.hoursCounter.isEmpty {
                self.hoursCounter = ["0"]
            }else{
            for r in self.hoursCounter {
                self.stodo.append(Double(r)!)
                }
            }
            self.hoursNumber.text = String("\(self.stodo.reduce(0, +))")
        }
     
        
    
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            print("GREAT!!! You Are Logged in as \(user.uid)")
            UserDefaults.standard.setValue(user.uid, forKey: "userInfo")
        }
    }

    
    //MARK: Reinit array for right counting
    
    override func viewDidDisappear(_ animated: Bool) {
        clientCounter.removeAll()
            Cnumber = 0
        stodo.removeAll()
        hoursCounter.removeAll()
    }

}
