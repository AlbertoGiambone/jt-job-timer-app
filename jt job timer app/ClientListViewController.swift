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
                    
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    let d: Date = formatter.date(from: document.data()["addedOnDate"] as! String)!
                    
                    let t = clientDetail(UID: document.data()["UID"] as! String , CLname: document.data()["name"] as! String, CLmail: document.data()["e-mail"] as! String, CLpostCode: document.data()["post code"] as! String, CLprovince: document.data()["province"] as! String, CLstate: document.data()["state"] as! String, CLstreet: document.data()["street"] as! String, CLdocID: document.documentID, addedOnDate: d)
                    
                    if t.UID == userUID as! String {
                        self.Cname.append(t)
                    }else{}
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
        Cname.removeAll()
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
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        cell.textLabel?.textColor = .darkGray
        
        
        return cell
    }
    
    var EDIT_CLIENT: clientDetail?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        EDIT_CLIENT = Cname[indexPath.row]
        performSegue(withIdentifier: "Edit/View", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let userUID = UserDefaults.standard.object(forKey: "userInfo") as! String
            
            let y: String = Cname[indexPath.row].CLname
            
            //deletring relative object in clientjob collection
            
            db.collection("JobTime").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documets: \(err)")
                }else{
                    for document in querySnapshot!.documents {
                        
                        let right = document.data()["JUID"] as! String
                        
                        if right == userUID {
                        
                        let r = document.data()["client name"] as! String
                        let i = document.documentID
                        if r == y {
                            self.db.collection("JobTime").document(i).delete()
                            print("deleted JobTime related object")
                        }else{
                            print("Error deleting relative document in JobTime Collection")
                            }
                        }
                    }
                }
            }
            
            db.collection("UserInfo").document(Cname[indexPath.row].CLdocID).delete()
            
            Cname.remove(at: indexPath.row)
            self.table.deleteRows(at: [indexPath], with: .fade)
            
            table.reloadData()
   
        }
    }
    
    //MARK: Action
    
    @IBAction func addClient(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addClient", sender: nil)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Edit/View" {
            let nextVC = segue.destination as! AddClientViewController
            nextVC.decide = true
            nextVC.CLIENT_DATA = EDIT_CLIENT
        }
    }
    
    
}
