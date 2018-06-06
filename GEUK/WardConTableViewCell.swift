//
//  WardConTableViewCell.swift
//  GEUK_T1
//
//  Created by Mary Forde on 26/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class WardConTableViewCell: UITableViewCell {
   
    @IBOutlet weak var areaName: UILabel!
    @IBOutlet weak var wardName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
