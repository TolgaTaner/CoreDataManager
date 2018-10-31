//
//  TasksTableView.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 19.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import UIKit


protocol TasksTableViewDelegate:class{
    func deleteActionDidTapped(_ selectedTask:TaskModel)
}


class TasksTableView: UITableView {

    weak var actionDelegate:TasksTableViewDelegate?
    
    var tasks : [TaskModel] = [] 
        
    
    override func awakeFromNib() {
        delegate = self
        dataSource = self
        tableFooterView = UIView()
    }
}

extension TasksTableView:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = dequeueReusableCell(withIdentifier: TasksTableViewCell.cellId, for: indexPath) as? TasksTableViewCell {
            let task = tasks[indexPath.row]
             cell.nameLabel.text = task.name
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedTask = tasks[indexPath.row]
        
        let delete = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, nil)   in
            self?.actionDelegate?.deleteActionDidTapped(selectedTask)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
