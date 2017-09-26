//
//  MenuContentTableViewCell.swift
//  Hitcha
//
//  Created by Daniel Phiri on 4/16/17.
//  Copyright © 2017 Cophiri. All rights reserved.
//

import UIKit

class MenuContentTableViewCell: UITableViewCell {
    
    
    //@IBOutlet weak var menuPrototype: UIView!
    @IBOutlet weak var menuPrototype: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
