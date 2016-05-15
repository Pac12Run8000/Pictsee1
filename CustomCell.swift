//
//  CustomCell.swift
//  Pictsee1
//
//  Created by Michelle Grover on 5/14/16.
//  Copyright © 2016 Norbert Grover. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var cellBgImage: UIImageView!
    
    @IBOutlet weak var cellLabelCaption: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
