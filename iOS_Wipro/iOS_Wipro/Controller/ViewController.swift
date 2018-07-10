//
//  ViewController.swift
//  iOS_Wipro
//
//  Created by SierraVista Technologies Pvt Ltd on 10/07/18.
//  Copyright © 2018 Shital. All rights reserved.
//

import UIKit
import SVProgressHUD
import Reachability

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tblImageContainer : UITableView?
    var tableData = [[String: AnyObject]]()
    var loadedImages = [String: UIImage]()
    
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
        self.tblImageContainer?.allowsSelection = false
        self.tblImageContainer?.register(UINib(nibName: Constants.GlobalConstants.strTableCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.GlobalConstants.strTableCellIdentifier)
        //Adding table view to view controller as subView
        
        self.view.addSubview(self.tblImageContainer!)
        
        //Adding constraints to table view
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tblView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tblView": self.tblImageContainer!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tblView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tblView":self.tblImageContainer!]))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.GlobalConstants.strTableCellIdentifier, for: indexPath) as! ImagesContainerTableViewCell
        
        cell.lblTitle?.text = ""
        cell.lblDescription?.text = ""
        cell.cellImage?.image = nil
        
        let dict = self.tableData[indexPath.row]
        cell.loadCellData(dict: dict) //Setting data to cell
        
        if dict[Constants.GlobalConstants.descriptionKey] as? String != nil && dict[Constants.GlobalConstants.titleKey] as? String != nil {
            cell.cellImage?.image = nil
            if let imageURL = dict[Constants.GlobalConstants.imageUrlKey] as? String {
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
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    //Sending tableviewcell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        SVProgressHUD.show()
        
        let checkInternet = Reachability()
        checkInternet?.whenReachable = { reachability in
            if reachability.connection == .wifi || reachability.connection == .cellular {
                checkInternet?.stopNotifier()
                APICall().getAPIDataFromURL { (response) in
                    SVProgressHUD.dismiss()
                    if (response[Constants.GlobalConstants.rowsKey] as? [[String: AnyObject]]) != nil {
                        //Setting Navigation Bar Title
                        
                        self.tableData = (response[Constants.GlobalConstants.rowsKey] as? [[String: AnyObject]])!
                        DispatchQueue.main.async {
                            self.title = response[Constants.GlobalConstants.titleKey] as? String
                            self.tblImageContainer?.reloadData()
                        }
                        
                    } else {
                        let alert = UIAlertController(title: "ERROR", message: response["Error"] as? String, preferredStyle: UIAlertControllerStyle.actionSheet)
                        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alert.addAction(alertAction)
                    }
                }
            } else {
                SVProgressHUD.dismiss()
                checkInternet?.stopNotifier()
                let alert = UIAlertController(title: "ERROR", message: "No Internet Connection!", preferredStyle: UIAlertControllerStyle.actionSheet)
                let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(alertAction)
            }
            
        }
        
        checkInternet?.whenUnreachable = { _ in
            SVProgressHUD.dismiss()
            checkInternet?.stopNotifier()
            
            let alert = UIAlertController(title: "ERROR", message: "No Internet Connection!", preferredStyle: UIAlertControllerStyle.actionSheet)
            let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertAction)
        }
        
        do {
            try checkInternet?.startNotifier()
        } catch  {
            SVProgressHUD.dismiss()
            checkInternet?.stopNotifier()
            
            let alert = UIAlertController(title: "ERROR", message: "No Internet Connection!", preferredStyle: UIAlertControllerStyle.actionSheet)
            let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertAction)
        }
    }


}

