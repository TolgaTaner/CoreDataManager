//
//  TasksTableViewCell.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 19.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import UIKit

class TasksTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    static let cellId = "itemCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        //self.nameLabel.text?.removeAll()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    

}
