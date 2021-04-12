//
//  AddJobViewController.swift
//  jt job timer app
//
//  Created by Alberto Giambone on 01/01/21.
//

import UIKit
import Firebase

class AddJobViewController: UIViewController, UITextFieldDelegate {

    
    //MARK: Client information from backVC
    
    var clientName: String?
    var clientID: String?
    
    var decide = false
    var EditVC: jobDetail?
    
    //MARK: Connection
    
    @IBOutlet weak var hNumber: RoundTextField!
    
    @IBOutlet weak var jobType: RoundTextField!
    
    @IBOutlet weak var jobDate: RoundTextField!
    
    @IBOutlet weak var saveButton: RoundButton!
    
    
    //MARK: limit text to number
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterAccepted = ",.0123456789"
        let allowedCharacterSet = CharacterSet(charactersIn: characterAccepted)
        let typedCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    }
    
    
    //MARK: Firestore
    
    let db = Firestore.firestore()
    
    
    
    //MARK: LifeCycle
    
    var datePicker : UIDatePicker?
    
    //DoneButton
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    @objc func datePickerDone() {
        jobDate.resignFirstResponder()
       }

       @objc func dateChanged() {
        var newDate = datePicker?.date
        var dayFormatter = DateFormatter()
        dayFormatter.dateStyle = .short
        jobDate.text = dayFormatter.string(from: newDate!)
       }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if decide == true {
            hNumber.text = EditVC?.hoursNumber
            jobType.text = EditVC?.jobType
            
            let day = EditVC?.jobdate
            let dayFormatter = DateFormatter()
            dayFormatter.dateStyle = .short
            jobDate.text = dayFormatter.string(from: day!)
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: Picker Settigs
        
        datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200))
        datePicker?.datePickerMode = .date
        datePicker!.addTarget(self, action: #selector(self.dateChanged), for: .allEvents)
        jobDate.inputView = datePicker
               let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.datePickerDone))
               let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        jobDate.inputAccessoryView = toolBar
        
        
        
        let day = Date()
        let dayFormatter = DateFormatter()
        dayFormatter.dateStyle = .short
        jobDate.text = dayFormatter.string(from: day)
        
        print(Date())
        
        // Mark Keyboard ToolBar setting
        
        let FooltoolBar = UIToolbar()
        FooltoolBar.sizeToFit()
        
        let FooldoneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        
        FooltoolBar.setItems([FooldoneButton], animated: false)
        
        hNumber.inputAccessoryView = FooltoolBar
        jobType.inputAccessoryView = FooltoolBar
        
        overrideUserInterfaceStyle = .light
        
        hNumber.delegate = self
        
    }
    
    

    @IBAction func addDayJOb(_ sender: RoundButton) {
        
        let userUID = UserDefaults.standard.object(forKey: "userInfo")
        
        if decide == false {
        
        if hNumber.hasText == true && clientName != nil {
            
            
            
            var HNumber = hNumber.text
            HNumber?.replace(",", with: ".")
            if Double(HNumber!) == nil {
                saveButton.isEnabled = false
                print("SAVE BUTTON DISABLED!")
            }else{
            db.collection("JobTime").addDocument(data: [
                "JUID": String(userUID as! String),
                "client name": String(clientName!),
                "hours number": String(HNumber ?? "0"),
                "job type": String(jobType.text ?? ""),
                "job date": String(jobDate.text ??  ""),
                "clientID": String(clientID ?? "NO CLIENT ID")
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    //print("Document added with ID: \(ref.documentID)")
                    }
                }
            }
            
            
        }else{
            saveButton.isEnabled = false
            print("NOTHING IS ENABLED!")
            }
        }
        if decide == true {
            if hNumber.hasText {
                
                var HNumber = hNumber.text
                HNumber?.replace(",", with: ".")
                if Double(HNumber!) == nil {
                    saveButton.isEnabled = false
                    print("SAVE BUTTON DISABLED!")
                }else{
                    let DOCREFERENCE = db.collection("JobTime").document(EditVC!.docID)
                    
                    DOCREFERENCE.setData([
                        "JUID": String(userUID as! String),
                        "client name": String(EditVC!.clientName),
                        "hours number": String(HNumber ?? ""),
                        "job type": String(jobType.text ?? ""),
                        "job date": String(jobDate.text ?? ""),
                        "clientID": String(EditVC?.clientID ?? "")
                    ])
                        
                }
                
            }
        }
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func deleteItem(_ sender: UIBarButtonItem) {
        
        
        db.collection("JobTime").document(EditVC!.docID).delete()
        print("DOCUMENT DELETE BY TRASH!")
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
    

}


//MARK: use . instead of , in DOUBLE value

extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
}

extension String {
    mutating func replace(_ originalString:String, with newString:String) {
        self = self.replacingOccurrences(of: originalString, with: newString)
    }
}
