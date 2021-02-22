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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let day = Date()
        let dayFormatter = DateFormatter()
        dayFormatter.dateStyle = .short
        jobDate.text = dayFormatter.string(from: day)
        
        print(Date())
        
        overrideUserInterfaceStyle = .light
        
        hNumber.delegate = self
    }
    

    @IBAction func addDayJOb(_ sender: RoundButton) {
        
        if hNumber.hasText == true && clientName != nil {
            
            let userUID = UserDefaults.standard.object(forKey: "userInfo")
            
            var HNumber = hNumber.text
            HNumber?.replace(",", with: ".")
            
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
            
            /*
            db.collection("Customer").document(clientName!).collection(clientName!).document(jobDate.text!).setData([
                "hours number": String("\(hNumber.text!)"),
                "job type": String("\(jobType.text ?? "")"),
                "job date": String("\(jobDate.text ?? "")")
            
                
            ], merge: false)*/
            
        }else{
            saveButton.isEnabled = false
        }
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
