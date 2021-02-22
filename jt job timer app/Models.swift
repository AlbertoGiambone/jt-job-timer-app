//
//  Models.swift
//  jt job timer app
//
//  Created by Alberto Giambone on 21/01/21.
//

import Foundation



struct jobDetail {
    
    var JUID: String
    var clientName: String
    var hoursNumber: String
    var jobdate: String
    var jobType: String
    var docID: String
    var clientID: String
    
    var dict: [String: String] {
    return [
    
        "JUID": JUID,
        "client name": clientName,
        "hours number": hoursNumber,
        "job date": jobdate,
        "job type": jobType,
        "doc ID": docID,
        "clientID": clientID
    ]
    }
    
}


struct clientDetail {
    
    var UID: String
    var CLname: String
    var CLmail: String
    var CLpostCode: String
    var CLprovince: String
    var CLstate: String
    var CLstreet: String
    var CLdocID: String
    
    var CLdict: [String: String] {
        return [
        
            "UID": UID,
            "name": CLname,
            "e-mail": CLmail,
            "post code": CLpostCode,
            "province": CLprovince,
            "state": CLstate,
            "street": CLstreet,
            "CLdocID": CLdocID
            
        ]
    }
    
}
