//
//  DetailTableViewCell.swift
//  GEUK_T1
//
//  Created by Mary Forde on 28/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var partyColor: UILabel!
    @IBOutlet weak var partyColor1: UILabel!
    @IBOutlet weak var party: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var votes: UILabel!
    @IBOutlet weak var share: UILabel!
    @IBOutlet weak var change: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
