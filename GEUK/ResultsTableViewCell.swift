//
//  ResultsTableViewCell.swift
//  GEUK_T1
//
//  Created by Mary Forde on 26/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var constituency: UILabel!
    @IBOutlet weak var region: UILabel!
    @IBOutlet weak var partyColour: UILabel!
    @IBOutlet weak var partyColour1: UILabel!
    @IBOutlet weak var party: UILabel!
    @IBOutlet weak var majoritypercent: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var onsid: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var runnerUpColor: UILabel!
    @IBOutlet weak var runnerUpColor1: UILabel!
    @IBOutlet weak var prevColor: UILabel!
    @IBOutlet weak var prevColor1: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
