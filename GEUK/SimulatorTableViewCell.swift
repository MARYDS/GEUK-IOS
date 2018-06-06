//
//  SimulatorTableViewCell.swift
//  GEUK_T1
//
//  Created by Mary Forde on 11/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class SimulatorTableViewCell: UITableViewCell {

    @IBOutlet weak var partyColor: UILabel!
    @IBOutlet weak var party: UILabel!
    @IBOutlet weak var startPercent: UILabel!
    @IBOutlet weak var change14: UITextField!
    @IBOutlet weak var endPercent: UILabel!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
