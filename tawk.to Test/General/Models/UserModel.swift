//
//  UserModel.swift
//  tawk.to Test
//
//  Created by Mahmoud Shurrab on 12/03/2021.
//

import Foundation

class UserModel: Codable {
    let id: Int?
    let login: String?
    let avatarurl, name, company, blog: String?
    let followers, following: Int?

    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarurl = "avatar_url"
        case name, company, blog
        case followers, following
    }

    init(id: Int?, login: String?, avatarurl: String?, name: String?, company: String?, blog: String?, followers: Int?, following: Int?) {
        self.id = id
        self.login = login
        self.avatarurl = avatarurl
        self.name = name
        self.company = company
        self.blog = blog
        self.followers = followers
        self.following = following
    }
}
