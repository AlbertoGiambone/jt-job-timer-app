//
//  ClientListViewController.swift
//  jt job timer app
//
//  Created by Alberto Giambone on 07/03/21.
//

import UIKit
import Firebase

class ClientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: Connection
    
    @IBOutlet weak var table: RoundTableView!
    
    
    
    //MARK: Firebase calling
    
    var Cname = [clientDetail]()
    
    let db = Firestore.firestore()
    
    func QueryClientInfo() {
        
        let userUID = UserDefaults.standard.object(forKey: "userInfo")
        
        let queryClient = db.collection("UserInfo")
        
        queryClient.whereField("UID", isEqualTo: userUID!)
        
        queryClient.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting client List \(err)")
            }else{
                for document in querySnapshot!.documents {
                    
                    let t = clientDetail(UID: document.data()["UID"] as! String , CLname: document.data()["name"] as! String, CLmail: document.data()["e-mail"] as! String, CLpostCode: document.data()["post code"] as! String, CLprovince: document.data()["province"] as! String, CLstate: document.data()["state"] as! String, CLstreet: document.data()["street"] as! String, CLdocID: document.documentID)
                    
                    if t.UID == userUID as! String {
                        self.Cname.append(t)
                    }
                }
            }
            self.table.reloadData()
        }
        
    }
    
 
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        QueryClientInfo()
        print("CNAME PRINTED \(Cname)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        Cname.removeAll()
    }
    
    //MARK: Tableview settings
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Cname.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = Cname[indexPath.row].CLname
        cell.textLabel?.font = UIFont(name: "Galvji", size: 15)
        cell.textLabel?.textColor = .darkGray
        
        
        return cell
    }
    
    
    
}
