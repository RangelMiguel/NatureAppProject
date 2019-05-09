//
//  TVCInsect.swift
//  NatureApp
//
//  Created by Miguel Rangel on 5/8/19.
//  Copyright © 2019 Miguel Rangel. All rights reserved.
//

import UIKit

class TVCInsect: UITableViewCell {
    
    var insect: Insect!
    @IBOutlet weak var imagePhoto: UIImageView!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtDescription: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
