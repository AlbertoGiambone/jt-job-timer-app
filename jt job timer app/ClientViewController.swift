//
//  ClientViewController.swift
//  jt job timer app
//
//  Created by Alberto Giambone on 22/12/20.
//

import UIKit
import Firebase

class ClientViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    //MARK: Connection
    
    @IBOutlet weak var table: RoundTableView!

    
    
    
    let db = Firestore.firestore()
    
    
    //MARK: tableview Settings
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cname.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(Cname[indexPath.row].CLname)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        //cell.textLabel?.font = UIFont(name: "Galvji", size: 11)
        return cell
    }
    
    
    var clientNameSelected: String?
    var clientIDSelected: String?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        clientNameSelected = Cname[indexPath.row].CLname
        clientIDSelected = Cname[indexPath.row].CLdocID
        performSegue(withIdentifier: "clientDetail", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            let y: String = Cname[indexPath.row].CLname
            
            //deletring relative object in clientjob collection
            
            db.collection("JobTime").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documets: \(err)")
                }else{
                    for document in querySnapshot!.documents {
                        
                        let right = document.data()["JUID"] as! String
                        
                        if right == self.userUID {
                        
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
    
    //MARK: Fetching Firebase Data for TableView
    
    var ClientNumber = [String]()
    var Cname = [clientDetail]()
    
    
    
    func fetchFirestoreData() {
        
        
        let queryUser = db.collection("UserInfo")
        
        queryUser.whereField("UID", isEqualTo: userUID!)
        
        queryUser.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data()["name"] ?? "")")
                    
                    
                    let t = clientDetail(UID: document.data()["UID"] as! String , CLname: document.data()["name"] as! String, CLmail: document.data()["e-mail"] as! String, CLpostCode: document.data()["post code"] as! String, CLprovince: document.data()["province"] as! String, CLstate: document.data()["state"] as! String, CLstreet: document.data()["street"] as! String, CLdocID: document.documentID)
                        
                    if t.UID == self.userUID {
                    self.Cname.append(t)
                    
                    }
                    
                    self.table.reloadData()
                }
                print(self.Cname)
            }
        }
 
    }
    

    
    //MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        table.delegate = self
        table.dataSource = self
    
        overrideUserInterfaceStyle = .light
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Cname = [clientDetail]()
    }
    
    
    var userUID: String?
    
    override func viewWillAppear(_ animated: Bool) {
        
        userUID = UserDefaults.standard.object(forKey: "userInfo") as! String
        
        fetchFirestoreData()
        table.reloadData()
    }
    
    
    
    //MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "clientDetail" {
            let detVC = segue.destination as! ClientDetailViewController
            detVC.clientNameFromCVC = clientNameSelected
            detVC.clientIDFromCVC = clientIDSelected
        }
    }
 
}
