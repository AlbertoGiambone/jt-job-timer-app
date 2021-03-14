//
//  ClientDetailViewController.swift
//  jt job timer app
//
//  Created by Alberto Giambone on 31/12/20.
//

import UIKit
import Firebase

class ClientDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: Passed var from ClientViewController
    
    var clientIDFromCVC: String?
    var clientNameFromCVC: String?
    
    //MARK: Connection
    
    @IBOutlet weak var clientName: RoundLabel!
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var counterLabel: UILabel!
    
    
    
    @IBAction func AddJob(_ sender: UIButton) {
        performSegue(withIdentifier: "addJob", sender: self)
    }
    
    
    
    
    //MARK: Firestore var
    
    let db = Firestore.firestore()
    

    
    var newOrder = [jobDetail]()
    var WDday = [jobDetail]()
    
    func fetchFirestoredata() {
        
        let queryJob = db.collection("JobTime")
        
        queryJob.getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data()["client name"] ?? "")")
                    
                    let userUIDX = UserDefaults.standard.object(forKey: "userInfo") as! String
                    let CID = document.data()["clientID"] as! String
                    
                    let r: String = document.data()["JUID"] as! String
                    if r == userUIDX && CID == clientIDFromCVC {
                        
                        let y = document.data()["hours number"] as! String
                        
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        let d: Date = formatter.date(from: document.data()["job date"] as! String)!
                        
                        
                        let t = jobDetail(JUID: document.data()["JUID"] as! String, clientName: document.data()["client name"] as! String, hoursNumber: y, jobdate: d, jobType: document.data()["job type"] as! String, docID: document.documentID, clientID: document.data()["clientID"] as! String)
                        
                        WDday.append(t)
                        totoalH.append(y)
                        
                    }
                    
                    
                    newOrder = WDday.sorted(by: {$0.jobdate < $1.jobdate})
        
                    print("\(totoalH) QUESTO è TOATAL H")
                    let newDouble = totoalH.compactMap(Double.init)
                    counterLabel.text = String("Tot ⏰ \(newDouble.reduce(0, +))")
                    
                    self.table.reloadData()
                }
                
               
            }
        
        
        }
    }
    
    
    
    //MARK: View Lifecycle
    
    var totoalH = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clientName.text = String("🙋‍♂️ \(clientNameFromCVC!)")
        
        table.dataSource = self
        table.delegate = self
        
        overrideUserInterfaceStyle = .light
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFirestoredata()
        table.reloadData()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        WDday = [jobDetail]()
        totoalH = [String]()
        newOrder = [jobDetail]()
    }
    
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addJob" {
            let nextVC = segue.destination as! AddJobViewController
            nextVC.clientName = clientNameFromCVC
            nextVC.clientID = clientIDFromCVC
        }
            if segue.identifier == "editJob"  {
                let nextVC = segue.destination as! AddJobViewController
                 nextVC.EditVC = EDIT_ROW
                nextVC.decide = true
        }
    }
    
    //MARK: tableview settings
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newOrder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String("\(newOrder[indexPath.row].hoursNumber)h \(newOrder[indexPath.row].jobType)")
        
        let day = newOrder[indexPath.row].jobdate
        let dayFormatter = DateFormatter()
        dayFormatter.dateStyle = .short
        let stringDate = dayFormatter.string(from: day)
        
        
        cell.detailTextLabel?.text = String("\(stringDate)")
        
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
        cell.detailTextLabel?.textColor = UIColor.gray
        cell.detailTextLabel?.font = UIFont(name: "Galvji", size: 11)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let id = newOrder[indexPath.row].docID
            db.collection("JobTime").document(id).delete()
            
            newOrder.remove(at: indexPath.row)
            self.table.deleteRows(at: [indexPath], with: .fade)
            self.table.reloadData()
        }
    }
    
    
    var EDIT_ROW: jobDetail?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        EDIT_ROW = newOrder[indexPath.row]
        performSegue(withIdentifier: "editJob", sender: nil)
    }
    
    
}
