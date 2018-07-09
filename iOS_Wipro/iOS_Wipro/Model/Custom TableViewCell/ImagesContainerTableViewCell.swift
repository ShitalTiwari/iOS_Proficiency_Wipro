//
//  ImagesContainerTableViewCell.swift
//  iOS_Wipro
//
//  Created by SierraVista Technologies Pvt Ltd on 09/07/18.
//  Copyright © 2018 Shital. All rights reserved.
// This Class takes care for custom table view cell creation and its configuration

import UIKit

class ImagesContainerTableViewCell: UITableViewCell {

    //Outlet declarations
    @IBOutlet var cellImage : UIImageView?
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblDescription: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
}
