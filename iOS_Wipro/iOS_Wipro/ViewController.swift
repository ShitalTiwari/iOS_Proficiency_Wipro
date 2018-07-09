//
//  ViewController.swift
//  iOS_Wipro
//
//  Created by SierraVista Technologies Pvt Ltd on 09/07/18.
//  Copyright © 2018 Shital. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tblImageContainer : UITableView?
    var tableData = [[String: AnyObject]]()
    var loadedImages = [String: UIImage]()
    let strTableCellIdentifier = "ImagesContainerTableViewCell"
    
    //Pull to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ViewController.pullToRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Creating container table view
        self.tblImageContainer = UITableView(frame: self.view.bounds, style: .plain)
        self.tblImageContainer?.delegate = self
        self.tblImageContainer?.dataSource = self
        self.tblImageContainer?.tableFooterView = UIView()
        self.tblImageContainer?.translatesAutoresizingMaskIntoConstraints = false
        self.tblImageContainer?.addSubview(self.refreshControl)
        self.tblImageContainer?.register(UINib(nibName: self.strTableCellIdentifier, bundle: nil), forCellReuseIdentifier: self.strTableCellIdentifier)
        //Adding table view to view controller as subView
        
        self.view.addSubview(self.tblImageContainer!)
        
        //Adding constraints to table view
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tblView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tblView": self.tblImageContainer!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tblView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tblView":self.tblImageContainer!]))
        
        self.updatTableData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UITableView Delegate and Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tableData.count > 0 {
            return self.tableData.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Creating custom table view cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.strTableCellIdentifier, for: indexPath) as! ImagesContainerTableViewCell
        
        cell.lblTitle?.text = ""
        cell.lblDescription?.text = ""
        cell.cellImage?.image = nil
        
        let dict = self.tableData[indexPath.row]

        if dict["description"] as? String != nil && dict["title"] as? String != nil {
            if let title = dict["title"] as? String {
                cell.lblTitle?.text = title
            }
            if let desc = dict["description"] as? String {
                cell.lblDescription?.text = desc
            }
            cell.cellImage?.image = nil
            if let imageURL = dict["imageHref"] as? String {
                if loadedImages[imageURL] != nil {
                    cell.cellImage?.image = loadedImages[imageURL]
                } else {
                    self.downloadImage(url: imageURL) { (image) in
                        if let image = image {
                            self.loadedImages[imageURL] = image
                            DispatchQueue.main.async {
                                cell.cellImage?.image = image
                            }
                        }
                    }
                }
            }
        }
        return cell
        
        
    }
    
    //Sending tableviewcell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.tableData.count > 0 {
            let dict = self.tableData[indexPath.row]
            if dict["description"] as? String != nil {
                let height = CommonMethods.getCellHeight(text: dict["description"] as! String, width: tableView.bounds.width, font: UIFont.systemFont(ofSize: 17.0))
                return height + 54 //Adding constant for height of title label and constraints constants
            } else if dict["title"] as? String != nil {
                return 54
            }
            
        }
        return 0
    }
    
    //This method calls API to download data from url
    func getAPIDataFromURL(completionHandler: @escaping (_ result: [String:AnyObject])-> Void) {
        let apiURL = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
        
        let callURL = URL(string: apiURL)
        
        //Calling session to fetch data from url
        URLSession.shared.dataTask(with: callURL!) { (data, response, error) in
            
            if let dataResponse = data {
                if let responseString = String(data: dataResponse, encoding: String.Encoding.ascii) {
                    
                    if let jsonData = responseString.data(using: String.Encoding.utf8) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: AnyObject]
                            
                            if (json["rows"] as? [[String: AnyObject]]) != nil {
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
    
    //Method to download images from server and save them in temporary property
    func downloadImage(url: String, callback: @escaping (UIImage?) -> Void) {
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        URLSession.shared.dataTask(with: urlRequest) { (dataResponse, response, error) in
            
            if dataResponse != nil {
                // execute in UI thread
                DispatchQueue.global(qos: .utility).async {
                    callback(UIImage(data: dataResponse!))
                }
            } else {
                 DispatchQueue.global(qos: .utility).async {
                    callback(nil)
                }
            }
            }.resume()
    }
    
    //Refreshing table data on pull down
    @objc func pullToRefresh(_ refreshControl: UIRefreshControl) {
        
        self.tableData.removeAll()
        self.loadedImages.removeAll()
        self.tblImageContainer?.reloadData()
        self.updatTableData()
        refreshControl.endRefreshing()
    }
    
    //Refreshing table data and reloading
    func updatTableData() {
        self.getAPIDataFromURL { (response) in
            print(response)
            if (response["rows"] as? [[String: AnyObject]]) != nil {
                //Setting Navigation Bar Title
                
                self.tableData = (response["rows"] as? [[String: AnyObject]])!
                DispatchQueue.main.async {
                    self.title = response["title"] as? String
                    self.tblImageContainer?.reloadData()
                }
                
            } else {
                let alert = UIAlertController(title: "ERROR", message: response["Error"] as? String, preferredStyle: UIAlertControllerStyle.actionSheet)
                let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(alertAction)
            }
        }
    }
}

