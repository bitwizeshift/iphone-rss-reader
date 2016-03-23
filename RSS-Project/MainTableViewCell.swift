//
//  MainTableViewCell.swift
//  RSS-Project
//
//  Created by Tomas Baena on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var storyImg: UIImageView!
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var storyCategory: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.storyImg.layer.cornerRadius = 5
        self.storyImg.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
