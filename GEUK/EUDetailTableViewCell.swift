//
//  EUDetailTableViewCell.swift
//  GEUK_T1
//
//  Created by Mary Forde on 29/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class EUDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var region: UILabel!
    @IBOutlet weak var areaName: UILabel!
    @IBOutlet weak var EUColour: UILabel!
    @IBOutlet weak var electorate: UILabel!
    @IBOutlet weak var turnout: UILabel!
    @IBOutlet weak var remain: UILabel!
    @IBOutlet weak var remainPercent: UILabel!
    @IBOutlet weak var leave: UILabel!
    @IBOutlet weak var leavePercent: UILabel!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
