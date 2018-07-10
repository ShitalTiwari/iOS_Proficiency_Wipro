//
//  APICall.swift
//  iOS_Wipro
//
//  Created by SierraVista Technologies Pvt Ltd on 10/07/18.
//  Copyright © 2018 Shital. All rights reserved.
//

import UIKit

class APICall: NSObject {
    //This method calls API to download data from url
    func getAPIDataFromURL(completionHandler: @escaping (_ result: [String:AnyObject])-> Void) {
        
        let callURL = URL(string: Constants.GlobalConstants.apiURL)
        
        //Calling session to fetch data from url
        URLSession.shared.dataTask(with: callURL!) { (data, response, error) in
            
            if let dataResponse = data {
                if let responseString = String(data: dataResponse, encoding: String.Encoding.ascii) {
                    
                    if let jsonData = responseString.data(using: String.Encoding.utf8) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: AnyObject]
                            
                            if (json[Constants.GlobalConstants.rowsKey] as? [[String: AnyObject]]) != nil {
                                completionHandler(json)
                            } else {
                                completionHandler(["Error": "Invalid JSON data" as AnyObject])
                            }
                            
                        } catch {
                            completionHandler(["Error": error.localizedDescription as AnyObject])
                        }
                    }
                }
                
            }
            }.resume()
    }
}
