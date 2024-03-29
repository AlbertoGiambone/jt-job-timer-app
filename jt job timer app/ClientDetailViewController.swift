//
//  ClientDetailViewController.swift
//  jt job timer app
//
//  Created by Alberto Giambone on 31/12/20.
//

import UIKit
import Firebase
import Charts

class ClientDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    

    //MARK: Passed var from ClientViewController
    
    var clientIDFromCVC: String?
    var clientNameFromCVC: String?
    
    //MARK: Connection
    
    @IBOutlet weak var clientName: RoundLabel!
    
    @IBOutlet weak var counterLabel: UILabel!
        
    @IBOutlet weak var collection: UICollectionView!

    
    
    @IBAction func AddJob(_ sender: UIButton) {
        performSegue(withIdentifier: "addJob", sender: self)
    }

    
    //MARK: Firestore fetching
    
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
                    
                    
                    newOrder = WDday.sorted(by: {$0.jobdate > $1.jobdate})
        
                    print("\(totoalH) QUESTO è TOATAL H")
                    let newDouble = totoalH.compactMap(Double.init)
                    counterLabel.text = String("Tot ⏰ \(newDouble.reduce(0, +))")
                    
                    self.collection.reloadData()
                }
                
               
            }
            
        
        }
    }
    
    
    
    
    
    
    
    //MARK: View Lifecycle
    
    var totoalH = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientName.text = String("🙋‍♂️ \(clientNameFromCVC!)")
        
        overrideUserInterfaceStyle = .light

        //Collection Settings
        collection.delegate = self
        collection.dataSource = self
        
        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        collection.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        
        //updateChart()
        
        //Segment settings
        
        //segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.selected)
        //segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFirestoredata()
        collection.reloadData()
        getWeekBalance ()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        WDday = [jobDetail]()
        totoalH = [String]()
        newOrder = [jobDetail]()
    }
    
    
    
    
    //Setting value for BarChart
    
    var OneDayBefore = [Double]()
    var TwoDaysBefore = [Double]()
    var ThreeDaysBefore = [Double]()
    var FourDaysBefore = [Double]()
    var FiveDaysBefore = [Double]()
    var SixDaysBefore = [Double]()
    var SevenDaysBefore = [Double]()
    
    
    
    /*
    func gettingChartdata() {
        print("BEFORE FOR STATEMENT!")
        
        for i in WDday {
            
            print("internal testing....")
            let exampleDate = i.jobdate
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
            //let unitMont = NSCalendar.Unit.month

            let distance = calendar.components(unit, from: date0, to: date1, options: [])
            //let monthDistance = calendar.components(unitMont, from: date0, to: date1, options: [])
        
            if distance.day! > -1 {
                OneDayBefore.append(Double("\(i.hoursNumber)")!)
                print("MENO UN GIORNO \(i.hoursNumber)")
            }
            if distance.day! > -2 && distance.day! < -1 {
                TwoDaysBefore.append(Double("\(i.hoursNumber)")!)
            }
            if distance.day! > -3 && distance.day! < -2 {
                ThreeDaysBefore.append(Double("\(i.hoursNumber)")!)
            }
            if distance.day! > -4 && distance.day! < -3 {
                FourDaysBefore.append(Double("\(i.hoursNumber)")!)
            }
            if distance.day! > -5 && distance.day! < -4 {
                FiveDaysBefore.append(Double("\(i.hoursNumber)")!)
            }
            if distance.day! > -6 {
                SixDaysBefore.append(Double("\(i.hoursNumber)")!)
            }
            if distance.day! > -7 {
                SevenDaysBefore.append(Double("\(i.hoursNumber)")!)
            }
        }
        
        
    }
    */
    
    
    func getWeekBalance() {
        
        print("BEFORE!!! ::::")
        
        for u in newOrder {
            print("\(u.clientName) PRINTATOOOOOOOO")
        }
        
        for j in WDday {
            
            print("AFTER!!! :::::")
            let exampleDate = j.jobdate
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
            
            
            if distance.day! > -8 {
                
                OneDayBefore.append(Double("\(j.hoursNumber)")!)
                }
            }
            
        }
        
        
    
    
    
    //MARK: Chart settings
    
//    func updateChart() {
//
//        let dayOne = OneDayBefore.reduce(0, +)
//        let dayTwo = TwoDaysBefore.reduce(0, +)
//        let dayThree = ThreeDaysBefore.reduce(0, +)
//        let dayFour = FourDaysBefore.reduce(0, +)
//        let dayFive = FiveDaysBefore.reduce(0, +)
//        let daySix = SixDaysBefore.reduce(0, +)
//        let daySeven = SevenDaysBefore.reduce(0, +)
//
//
//        let entryOne = BarChartDataEntry(x: 1.0, y: dayOne)
//        let entrytwo = BarChartDataEntry(x: 2.0, y: dayTwo)
//        let entryThree = BarChartDataEntry(x: 3.0, y: dayThree)
//        let entryFour = BarChartDataEntry(x: 4.0, y: dayFour)
//        let entryFive = BarChartDataEntry(x: 5.0, y: dayFive)
//        let entrySix = BarChartDataEntry(x: 6.0, y: daySix)
//        let entrySeven = BarChartDataEntry(x: 7.0, y: daySeven)
//
//        let dataSet = BarChartDataSet(entries: [entryOne, entrytwo, entryThree, entryFour, entryFive, entrySix, entrySeven], label: "Week Work Time")
//        let data = BarChartData(dataSets: [dataSet])
//        graphView.data = data
//        graphView.chartDescription?.text = "Number of Hours this week"
//
//        graphView.notifyDataSetChanged()
//    }
    
   
    
    
    //MARK: Collection Setup
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DetailCollectionCellCollectionViewCell
        
        
        let textInTheLabel = String("\(newOrder[indexPath.row].hoursNumber)h \(newOrder[indexPath.row].jobType)")
        cell.textLabel.text = textInTheLabel
        cell.textLabel.backgroundColor = UIColor(red: 255/255, green: 238/255, blue: 153/255, alpha: 1)
        
        let day = newOrder[indexPath.row].jobdate
        let dayFormatter = DateFormatter()
        dayFormatter.dateStyle = .short
        let stringDate = dayFormatter.string(from: day)
        
        cell.dateLabel.text = String("\(stringDate)")
        cell.dateLabel.backgroundColor = UIColor(red: 255/255, green: 238/255, blue: 153/255, alpha: 1)
        
        return cell
    }
    
    
    
    var OBJECT_TO_MOVE = [jobDetail]()
    var EDIT_ROW: jobDetail?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
            EDIT_ROW = newOrder[indexPath.row]
            performSegue(withIdentifier: "editJob", sender: nil)
        
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
    
    /*
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
    */



}
