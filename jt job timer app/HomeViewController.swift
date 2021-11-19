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


class HomeViewController: UIViewController, ChartViewDelegate, FUIAuthDelegate {

    
    //MARK: Connection
    

    @IBOutlet weak var clientNumber: UITextField!
    
    @IBOutlet weak var thisMontClient: UITextField!
    
    @IBOutlet weak var hoursNumber: UITextField!
    
    @IBOutlet weak var thisMontHours: UITextField!
    
    
    @IBOutlet weak var barchart: BarChartView!
    
    

    
    @IBAction func LogOut(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            secondVC.modalPresentationStyle = .fullScreen // <<<<< (switched)
            self.present(secondVC, animated:true, completion:nil)
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
    
    //MARK: func for dispatch
    
    func run(after seconds: Int, completion: @escaping () -> Void) {
        let deadLine = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadLine){
            completion()
        }
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
        
        
        
        run(after: 1){
            self.fetchFirestoreData()
        }
        run(after: 2){
            self.ArrayData()
        }
        run(after: 3){ [self] in
            self.sentimentStat()
        }
    }
    
    
    var userUID: String?
    
    
    /*Problema di Userdefault NIL, fetchare i dati in maniera diversa o luogo dicerso da willAppear*/
    
    //MARK: VAR
    
    var clientCounter = [clientDetail]()
    var Cnumber = [String]()
    var CHours = [Double]()
    var hoursCounter = [String]()
    var stodo = [Double]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tabBarItem.isEnabled = true
        
        barchart.delegate = self

    }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    
    //MARK: Fetch db client for aggregate data
    
    let db = Firestore.firestore()
    
    
    
    
    var ArrayForChart = [jobDetail]()
    
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
                    
                        
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        let dat = document.data()["addedOnDate"] as? String ?? ""
                        if dat != "" {
                        let D: Date = formatter.date(from: dat)!
                        
                        let c = clientDetail(UID: document.data()["UID"] as! String, CLname: document.data()["CLname"] as! String, CLmail: document.data()["CLmail"] as! String, CLpostCode: document.data()["CLpostCode"] as! String, CLprovince: document.data()["CLprovince"] as! String, CLstate: document.data()["CLstate"] as! String, CLstreet: document.data()["CLstreet"] as! String, CLdocID: document.documentID, addedOnDate: D)
                        
                        self.clientCounter.append(c)
                        }else{
                            print("added date == nil")
                        }
                    }
                }
            }
            self.clientNumber.text = String("\(self.clientCounter.count)")
            print("NUMERO CLIENTI XXXXXXXXXXX  \(self.clientCounter.count)")
            
        }

        
            let queryJob = db.collection("JobTime")
        

        queryJob.getDocuments() {
            (querySnapshot, err) in
            if let err = err {
                print("Error getting JobTime documents: \(err)")
            }else{
                for document in querySnapshot!.documents {
                    
                    let r = document.data()["JUID"] as! String
                    
                    if r == self.userUID {
                    
                        
                        
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        let d: Date = formatter.date(from: document.data()["job date"] as! String)!
                        
                        let g = jobDetail(JUID: document.data()["JUID"] as! String, clientName: document.data()["client name"] as! String, hoursNumber: document.data()["hours number"] as! String, jobdate: d, jobType: document.data()["job type"] as! String, docID: document.documentID , clientID: document.data()["clientID"] as! String)
                     
                        self.ArrayForChart.append(g)
                    }
                    
                }
            }
        
            
        }
    
    }
    
    var weekString = [String]()
    var monthString = [String]()
    
    var Hweek = [Double]()
    var Hmonth = [Double]()
    
    func sentimentStat() {
        
        clientNumber.text = String(clientCounter.count)
        
        
        for cl in clientCounter {
            
                let exampleDate = cl.addedOnDate
                let today = Date()
                
            let dayFormatter = DateFormatter()
            dayFormatter.dateStyle = .short
            let stringDate = dayFormatter.string(from: exampleDate)
                
                
            let fromStringToDate = dayFormatter.date(from: stringDate)
            let todayDateString = dayFormatter.string(from: today)
            let todayDateDate = dayFormatter.date(from: todayDateString)


            let calendar = NSCalendar.current as NSCalendar

            let date1 = calendar.startOfDay(for: fromStringToDate!)
            let date0 = calendar.startOfDay(for: todayDateDate!)

            let unit = NSCalendar.Unit.day
            let unitMont = NSCalendar.Unit.month

            let distance = calendar.components(unit, from: date0, to: date1, options: [])
            let monthDistance = calendar.components(unitMont, from: date0, to: date1, options: [])
                
                print("GIORNI DI DISTANZA: \(distance.day!)")
            
            
            if monthDistance.month! <= -2 {
                monthString.append(cl.CLname)
            }
        }
        
        for rt in ArrayForChart {
            
            let exampleDate = rt.jobdate
            let today = Date()
            
        let dayFormatter = DateFormatter()
        dayFormatter.dateStyle = .short
        let stringDate = dayFormatter.string(from: exampleDate)
            
            
        let fromStringToDate = dayFormatter.date(from: stringDate)
        let todayDateString = dayFormatter.string(from: today)
        let todayDateDate = dayFormatter.date(from: todayDateString)


        let calendar = NSCalendar.current as NSCalendar

        let date1 = calendar.startOfDay(for: fromStringToDate!)
        let date0 = calendar.startOfDay(for: todayDateDate!)

        let unit = NSCalendar.Unit.day
        let unitMont = NSCalendar.Unit.month

        let distance = calendar.components(unit, from: date0, to: date1, options: [])
        let monthDistance = calendar.components(unitMont, from: date0, to: date1, options: [])
            
            print("GIORNI DI DISTANZA: \(distance.day!)")
        
        
            if monthDistance.month! <= -2 {
                Hmonth.append(Double(rt.hoursNumber)!)
                }
            
            if distance.day! <= -8 {
                Hweek.append(Double(rt.hoursNumber)!)
            }
            hoursNumber.text = String(Hweek.reduce(0, +).truncate(places: 2))
            thisMontHours.text = String(Hmonth.reduce(0, +).truncate(places: 2))
        }
        
        
    }
    

    func ArrayData() {
        print(clientCounter)
        for y in self.clientCounter {
            var hours = 0.00
            for u in self.ArrayForChart {
                if u.clientName == y.CLname {
                hours += Double(u.hoursNumber)!
                print("\(hours) ECCOOOOLLLLEEEEORREEEE")
                }
                
            }
            self.CHours.append(hours)
            
        }
    
    print("\(clientCounter) \(CHours) ECCO GLI ARRAY PER IL GRAFICO!!!")
        
        
        
        //CHART
        
        var dataEntries = [BarChartDataEntry]()
         
        
        for r in 0..<clientCounter.count {

            dataEntries.append(BarChartDataEntry(x: Double(r), y: CHours[r]))
        }
        
        let set = BarChartDataSet(entries: dataEntries)
        set.colors = ChartColorTemplates.material()
        //set.stackLabels = clientCounter
        
        let CHART_DATA = BarChartData(dataSet: set)
        
        barchart.animate(xAxisDuration: 2, yAxisDuration: 2)
        barchart.data = CHART_DATA
        //barchart.xAxis.labelPosition = .bottom
        barchart.xAxis.enabled = false
        barchart.xAxis.gridColor = .clear
        barchart.leftAxis.gridColor = .clear
        barchart.leftAxis.enabled = false
        barchart.rightAxis.gridColor = .clear
        barchart.rightAxis.enabled = false
        barchart.xAxis.granularity = 1.0
        //barchart.xAxis.valueFormatter = IndexAxisValueFormatter(values: clientCounter)
        
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
            //Cnumber = 0
        stodo.removeAll()
        hoursCounter.removeAll()
    }


}
