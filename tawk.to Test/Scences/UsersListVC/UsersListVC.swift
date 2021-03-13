//
//  UsersListVC.swift
//  tawk.to Test
//
//  Created by Mahmoud Shurrab on 12/03/2021.
//

import UIKit

class UsersListVC: UIViewController, SkeletonDisplayable {
    var isUsersLoaded: Bool = false
    var allUsersListArray: [UserModel] = []
    var usersListArray: [UserModel] = []
    @IBOutlet weak var usersList: UITableView!
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersList.tableFooterView = UIView()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        usersList.addSubview(refreshControl)
        
        if CoreDataFunctions.shared.getAllUsers().count > 0 {
            self.allUsersListArray = CoreDataFunctions.shared.getAllUsers()
            displayUsersList()
        } else {
            showSkeleton()
        }
        
        getUsersList("0")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.usersList.reloadData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getUsersList("0")
    }
    
    func getUsersList(_ since: String){
        API.shared.getUsersRequest(since, true) { response in
            self.refreshControl.endRefreshing()
            
            if since == "0" {
                self.allUsersListArray = response
            } else {
                self.allUsersListArray.append(contentsOf: response)
            }
            
            self.displayUsersList()
        }
    }
    
    func displayUsersList() {
        self.usersListArray = self.allUsersListArray
        
        self.usersList.reloadData()
        self.isUsersLoaded = true
        self.hideSkeleton()
    }
}

extension UsersListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            usersListArray = allUsersListArray
        } else {
            usersListArray = allUsersListArray.filter({($0.login?.contains(searchText))!})
        }
        
        self.usersList.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension UsersListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isUsersLoaded ? usersListArray.count : 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isUsersLoaded {
            let userDetails = usersListArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: UserListCell.self),
                for: indexPath) as! UserListCell
            
            cell.avatar.downloaded(from: userDetails.avatarurl ?? "")
            cell.name.text = userDetails.login
            
            cell.notesIcon.isHidden = !(CoreDataFunctions.shared.isUserNoted(userDetails.id ?? 0))
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: UserListCell.self),
            for: indexPath) as! UserListCell
        return cell
    }
}

extension UsersListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isUsersLoaded {return}
        let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: UserDetailsVC.self)) as? UserDetailsVC
        vc?.userDetails = usersListArray[indexPath.row]
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == usersListArray.count - 5 {
            getUsersList("\(usersListArray.last?.id ?? 0)")
        }
    }
}

