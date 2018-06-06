//
//  DetailHeaderTableViewCell.swift
//  GEUK_T1
//
//  Created by Mary Forde on 29/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class DetailHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var electorate: UILabel!
    @IBOutlet weak var validVotes: UILabel!
    @IBOutlet weak var invalidVotes: UILabel!
    @IBOutlet weak var turnoverPercent: UILabel!
    @IBOutlet weak var turnoutPercent: UILabel!
    @IBOutlet weak var majorityVotes: UILabel!
    @IBOutlet weak var majorityPercent: UILabel!
    @IBOutlet weak var narrative: UILabel!
    @IBOutlet weak var compareYear: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
