//
//  AddClientViewController.swift
//  jt job timer app
//
//  Created by Alberto Giambone on 24/12/20.
//

import UIKit
import Firebase

class AddClientViewController: UIViewController {

    //MARK: Passed var
    
    var decide = false
    
    var CLIENT_DATA: clientDetail?
    
    
    //MARK: Connection
    
    @IBOutlet weak var customerName: UITextField!
    
    @IBOutlet weak var customerStreet: UITextField!
    
    
    @IBOutlet weak var customerPostCode: UITextField!
    
    @IBOutlet weak var customerProvince: UITextField!
    
    @IBOutlet weak var customerState: UITextField!
    
    
    @IBOutlet weak var customerEmail: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //MARK: Firstore call
    
    let db = Firestore.firestore()
    
    
    @IBAction func savingClient(_ sender: UIBarButtonItem) {
        
        let userUID = UserDefaults.standard.object(forKey: "userInfo")
        
        if decide == false {
        
        if customerName.hasText == true {
            
            var ref: DocumentReference? = nil
            
            
            ref = db.collection("UserInfo").addDocument(data: [
                "UID": String(userUID as! String),
                "name": String("\(customerName.text!)"),
                "street": String("\(customerStreet.text ?? "")"),
                "post code": String("\(customerPostCode.text ?? "")"),
                "province": String("\(customerProvince.text ?? "")"),
                "state": String("\(customerState.text ?? "")"),
                "e-mail": String("\(customerEmail.text ?? "")")
            
            
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            navigationController?.popViewController(animated: true)
        }else{
            saveButton.isEnabled = false
        }
 
        }
        if decide == true {
            if customerName.hasText == true {
                
                let DOCREF = db.collection("UserInfo").document((CLIENT_DATA?.CLdocID)!)
                
                DOCREF.setData([
                    "UID": String(userUID as! String),
                    "name": String("\(customerName.text!)"),
                    "street": String("\(customerStreet.text ?? "")"),
                    "post code": String("\(customerPostCode.text ?? "")"),
                    "province": String("\(customerProvince.text ?? "")"),
                    "state": String("\(customerState.text ?? "")"),
                    "e-mail": String("\(customerEmail.text ?? "")")
                ]) { [self] err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(CLIENT_DATA?.CLdocID ?? "NO ID")")
                    }
                }
                navigationController?.popViewController(animated: true)
                
            }
        }
        
    }
    
    
    
    
    //DoneButton
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light

        // Mark Keyboard ToolBar setting
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        customerName.inputAccessoryView = toolBar
        customerEmail.inputAccessoryView = toolBar
        customerState.inputAccessoryView = toolBar
        customerProvince.inputAccessoryView = toolBar
        customerStreet.inputAccessoryView = toolBar
        customerPostCode.inputAccessoryView = toolBar
                
        customerName.attributedPlaceholder = NSAttributedString(string: "Name",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        customerEmail.attributedPlaceholder = NSAttributedString(string: "E-Mail",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        customerState.attributedPlaceholder = NSAttributedString(string: "State",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        customerProvince.attributedPlaceholder = NSAttributedString(string: "Province",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        customerStreet.attributedPlaceholder = NSAttributedString(string: "Street",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        customerPostCode.attributedPlaceholder = NSAttributedString(string: "Post Code",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        
        
        
        
        overrideUserInterfaceStyle = .light
    }
    

    override func viewWillAppear(_ animated: Bool) {
        if decide == true {
            customerName.text = CLIENT_DATA?.CLname ?? ""
            customerState.text = CLIENT_DATA?.CLstate ?? ""
            customerEmail.text = CLIENT_DATA?.CLmail ?? ""
            customerStreet.text = CLIENT_DATA?.CLstreet ?? ""
            customerProvince.text = CLIENT_DATA?.CLprovince ?? ""
            customerPostCode.text = CLIENT_DATA?.CLpostCode ?? ""
        }
        if decide == false {
            customerName.text =  ""
            customerState.text =  ""
            customerEmail.text =  ""
            customerStreet.text = ""
            customerProvince.text = ""
            customerPostCode.text = ""
        }
    }
    
    
    
    
    
    

}
