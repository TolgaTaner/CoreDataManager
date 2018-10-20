//
//  TasksTableView.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 19.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import UIKit

class TasksTableView: UITableView {

    
    var tasks : [TaskModel] = []
    
    override func awakeFromNib() {
        delegate = self
        dataSource = self
        tableFooterView = UIView()
    }
}

extension TasksTableView:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = dequeueReusableCell(withIdentifier: TasksTableViewCell.cellId, for: indexPath) as? TasksTableViewCell {
            let task = tasks[indexPath.row]
             cell.nameLabel.text = task.name
            return cell
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
