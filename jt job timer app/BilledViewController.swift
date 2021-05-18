//
//  BilledViewController.swift
//  jt job timer app
//
//  Created by Alberto Giambone on 14/05/21.
//

import UIKit
import Firebase

class BilledViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    

    
    //MARK: Var passed
    
    var clientIDFromCLVC: String?
    var clientNameFormCLVC: String?
    
    
    //MARK: Connection
    
    @IBOutlet weak var collection: UICollectionView!
    
    
    
    //MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collection.delegate = self
        collection.dataSource = self
        
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        collection.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFirestore()
        collection.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        WDday = [jobDetail]()
        totoalH = [String]()
        newOrder = [jobDetail]()
    }
    
    
    
    
    
    //MARK: Fetch from Firestore
    
    
    // custom array
    var newOrder = [jobDetail]()
    var WDday = [jobDetail]()
    var totoalH = [String]()
    
    let db = Firestore.firestore()
    
    func fetchFirestore() {
        
        let queryBilledJob = db.collection("JobBilled")
        
        queryBilledJob.getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
            
                for document in querySnapshot!.documents {
                    
                    print("\(document.documentID) =>> \(document.data()["client name"] ?? "")")
                    
                    let userIdentifier = UserDefaults.standard.object(forKey: "userInfo") as! String
                    let ClientID = document.data()["clientID"] as! String
                    
                    
                    let r: String = document.data()["JUID"] as! String
                    if r == userIdentifier && ClientID == clientIDFromCLVC {
                        
                        let y = document.data()["hours number"] as! String
                        
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        let d: Date = formatter.date(from: document.data()["job date"] as! String)!
                        
                        
                        let t = jobDetail(JUID: document.data()["JUID"] as! String, clientName: document.data()["client name"] as! String, hoursNumber: y, jobdate: d, jobType: document.data()["job type"] as! String, docID: document.documentID, clientID: document.data()["clientID"] as! String)
                    
                        WDday.append(t)
                        
                        totoalH.append(y)
                        
                        
                }
            
                    
                    newOrder = WDday.sorted(by: {$0.jobdate > $1.jobdate})
        
                    print("\(totoalH) QUESTO è TOATAL H")
                    let newDouble = totoalH.compactMap(Double.init)
                    //counterLabel.text = String("Tot ⏰ \(newDouble.reduce(0, +))")
                    
                    self.collection.reloadData()
            }
            
        }
        
        
    }
    }
    
    
    
    //MARK: CollectionView Settings
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BilledCellCollectionViewCell
        
        
        cell.hNUMBER.text = String("\(newOrder[indexPath.row].hoursNumber)h")
        cell.hNUMBER.textColor = UIColor(red: 255/255, green: 238/255, blue: 153/255, alpha: 1)
        
        cell.SUBJECT_LABEL.text = newOrder[indexPath.row].jobType
        cell.SUBJECT_LABEL.textColor = UIColor(red: 255/255, green: 238/255, blue: 153/255, alpha: 1)
        
        
        let day = newOrder[indexPath.row].jobdate
        let dayFormatter = DateFormatter()
        dayFormatter.dateStyle = .short
        let stringDate = dayFormatter.string(from: day)
        
        cell.DATE_LABEL.text = String("\(stringDate)")
        
        
        return cell
        
    }
    
}
