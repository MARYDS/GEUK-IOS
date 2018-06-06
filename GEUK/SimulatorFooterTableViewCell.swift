//
//  SimulatorFooterTableViewCell.swift
//  GEUK_T1
//
//  Created by Mary Forde on 12/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class SimulatorFooterTableViewCell: UITableViewCell {

    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var message1: UILabel!

    @IBOutlet weak var message2: UILabel!
    @IBOutlet weak var message3: UILabel!
    @IBOutlet weak var message4: UILabel!
    @IBOutlet weak var message5: UILabel!
    @IBOutlet weak var message6: UILabel!
    @IBOutlet weak var message7: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var saveRules: UIButton!
    @IBOutlet weak var runUniform: UIButton!
    @IBOutlet weak var runProportional: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
