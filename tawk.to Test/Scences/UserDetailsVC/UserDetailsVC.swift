//
//  UserDetailsVC.swift
//  tawk.to Test
//
//  Created by Mahmoud Shurrab on 12/03/2021.
//

import UIKit

class UserDetailsVC: UIViewController, SkeletonDisplayable {
    var userDetails: UserModel?
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var blog: UILabel!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var save: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        notes.layer.borderWidth = 1
        notes.layer.borderColor = UIColor.black.cgColor
        
        userDetails = CoreDataFunctions.shared.getUser(userDetails?.id ?? 0)
        notes.text = CoreDataFunctions.shared.getUserNote(userDetails?.id ?? 0).note
        
        self.displayUserDetails()
        
        if userDetails?.login == "" {
            showSkeleton()
        }
        
        API.shared.getUserDetailsRequest(userDetails?.login ?? "", true) { response in
            self.userDetails = response
            self.displayUserDetails()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func displayUserDetails() {
        avatar.downloaded(from: userDetails?.avatarurl ?? "")
        followers.text = "\(userDetails?.followers ?? 0)"
        following.text = "\(userDetails?.following ?? 0)"
        name.text = userDetails?.name
        company.text = userDetails?.company
        blog.text = userDetails?.blog
        
        hideSkeleton()
    }
    
    @IBAction func saveAction() {
        notes.resignFirstResponder()
        CoreDataFunctions.shared.saveUserNote(userDetails?.id ?? 0, notes.text)
        GeneralFunctions.shared.showPopUpDialog("Success", "Note Saved")
    }
}
