//
//  API.swift
//  tawk.to Test
//
//  Created by Mahmoud Shurrab on 12/03/2021.
//

import Foundation

class API{
    static let shared = API()
    
    static let mainURL = "https://api.github.com/"
    static let usersURL = "users"
    
    private init(){}
    
    private func getRequest(_ urlString: String, _ isShowingLoader: Bool, completion: @escaping(Data) -> ()){
        if let url = URL(string: API.mainURL+urlString) {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request){data, response, error in
                guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                    if isShowingLoader { self.executeRequestError() }
                    return
                }

                guard (200 ... 299) ~= response.statusCode else {
                    if isShowingLoader { self.executeRequestError() }
                    return
                }
                
                completion(data)
            }.resume()
        }
    }
    
    private func executeRequestError(){
        GeneralFunctions.shared.showPopUpDialog("ERROR", "Can't connect to server, please try again.")
    }
    
    public func getUsersRequest(_ since: String, _ isShowingLoader: Bool, completion: @escaping([UserModel]) -> ()){
        getRequest(API.usersURL+"?since="+since, isShowingLoader){ data in
            DispatchQueue.main.async {
                do {
                    let usersResponse = try JSONDecoder().decode([UserModel].self, from: data)
                    if since == "0" {
                        CoreDataFunctions.shared.removeAllUsers()
                    }
                    
                    for user in usersResponse {
                        CoreDataFunctions.shared.saveNewUser(user)
                    }
                    
                    completion(usersResponse)
                } catch {
                    self.executeRequestError()
                }
            }
        }
    }
    
    public func getUserDetailsRequest(_ login: String, _ isShowingLoader: Bool, completion: @escaping(UserModel) -> ()){
        getRequest(API.usersURL+"/"+login, isShowingLoader){ data in
            DispatchQueue.main.async {
                do {
                    let userResponse = try JSONDecoder().decode(UserModel.self, from: data)
                    CoreDataFunctions.shared.updateUser(userResponse)
                    completion(userResponse)
                } catch {
                    self.executeRequestError()
                }
            }
        }
    }
}
