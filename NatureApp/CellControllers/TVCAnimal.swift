//
//  TVCAnimal.swift
//  NatureApp
//
//  Created by Miguel Rangel on 5/8/19.
//  Copyright © 2019 Miguel Rangel. All rights reserved.
//

import UIKit

class TVCAnimal: UITableViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtDescription: UITextView!
    var animal: Animal!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
