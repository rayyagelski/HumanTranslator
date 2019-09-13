//
//  ApiRequest.swift
//  Human Translator
//
//  Created by Yin on 13/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ApiRequest {

    static let BASE_URL = "http://18.218.140.14/"
    static let SERVER_URL = BASE_URL + "index.php/api/"

    static let REQ_REGISTER                 = SERVER_URL + "signup"
    static let REQ_LOGIN                    = SERVER_URL + "login"
    static let REQ_UPLOAD_PHOTO             = SERVER_URL + "uploadPhoto"
    static let REQ_UPDATE_PROFILE           = SERVER_URL + "updateProfile"
    static let REQ_SETAVAILABLE             = SERVER_URL + "setAvailable"
    static let REQ_SEARCH_TRANSLATORS       = SERVER_URL + "searchTranslator"
    static let REQ_GETREVIEW                = SERVER_URL + "getReview"
    static let REQ_SAVE_TOKEN               = SERVER_URL + "saveToken"
    static let REQ_SENDREQUEST              = SERVER_URL + "sendRequest"
    static let REQ_ACCEPTREQUEST            = SERVER_URL + "acceptRequest"
    static let REQ_REJECTREQUEST            = SERVER_URL + "rejectRequest"
    static let REQ_WRITE_REVIEW             = SERVER_URL + "writeReview"
    static let REQ_RESET_PASSWORD           = SERVER_URL + "resetPassword"
    
    
    static func register(_ user: UserModel, completion: @escaping (Int, Int) -> ()) {
        
        let params = [R.String.PARAM_NAME: user.name,
                      R.String.PARAM_EMAIL: user.email,
                      R.String.PARAM_PASSWORD: user.password,
                      R.String.PARAM_USERTYPE: user.user_type] as [String : Any]
        
        Alamofire.request(REQ_REGISTER, method: .post, parameters: params).responseJSON { response in
            
            print("register response : ", response)
            
            switch response.result {
                
            case .success:
                
                let dict = JSON(response.result.value!)
                
                let resultCode = dict[R.String.RESULT_CODE].intValue
                if resultCode == R.Const.CODE_SUCCESS {
                    let userId = dict[R.String.PARAM_USERID].intValue
                    
                    UserDefaults.standard.set(userId, forKey: R.String.KEY_USERID)
                    UserDefaults.standard.set(user.email, forKey: R.String.KEY_EMAIL)
                    UserDefaults.standard.set(user.password, forKey: R.String.KEY_PASSWORD)
                    
                    completion(resultCode, userId)
                } else if resultCode == R.Const.CODE_ALREADY_EXIST {
                    completion(resultCode, R.Const.CODE_ALREADY_EXIST)
                }
               
            case .failure(let error):
                completion(R.Const.CODE_FAIL, R.Const.CODE_0)
                print(error)
            }
        }
    }
    
    static func login(_ email: String, password: String, completion: @escaping (Int) -> ()) {
        
        let params = [R.String.PARAM_EMAIL: email,
                      R.String.PARAM_PASSWORD: password] as [String : Any]
        
        Alamofire.request(REQ_LOGIN, method: .post, parameters: params).responseJSON { response in
            
            print("login response : ", response)
            
            switch response.result {
                
            case .success:
                
                let dict = JSON(response.result.value!)
                
                let resultCode = dict[R.String.RESULT_CODE].intValue
                if resultCode == R.Const.CODE_SUCCESS {
                    
                    currentUser = ParseHelper.parseUser(dict)
                    
                    UserDefaults.standard.set(email, forKey: R.String.KEY_EMAIL)
                    UserDefaults.standard.set(password, forKey: R.String.KEY_PASSWORD)
                    
                    completion(R.Const.CODE_SUCCESS)
                    
                } else if resultCode == R.Const.CODE_NON_EXIST {
                    completion(R.Const.CODE_NON_EXIST)
                } else if resultCode == R.Const.CODE_WRONG_PWD {
                    completion(R.Const.CODE_WRONG_PWD)
                }
                
            case .failure(let error):
                completion(R.Const.CODE_FAIL)
                print(error)
            }
        }
    }
    
    static func resetPassword(_ email: String, password: String, completion: @escaping (Int) -> ()) {
        
        let params = [R.String.PARAM_EMAIL: email,
                      R.String.PARAM_PASSWORD: password] as [String : Any]
        
        Alamofire.request(REQ_RESET_PASSWORD, method: .post, parameters: params).responseJSON { response in
            
            print("resetPWD response : ", response)
            
            switch response.result {
                
            case .success:
                
                let dict = JSON(response.result.value!)
                
                let resultCode = dict[R.String.RESULT_CODE].intValue
                if resultCode == R.Const.CODE_SUCCESS {
                    
                    completion(R.Const.CODE_SUCCESS)
                    
                } else if resultCode == R.Const.CODE_NON_EXIST {
                    completion(R.Const.CODE_NON_EXIST)
                }
                
            case .failure(let error):
                completion(R.Const.CODE_FAIL)
                print(error)
            }
        }
    }
    
    static func uploadPhoto(_ imgURL: String, userId: Int, completion: @escaping (Int,  String) -> ()) {

        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(URL(fileURLWithPath: imgURL), withName: "file")
                multipartFormData.append(String(userId).data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: R.String.PARAM_USERID)
        },
            to: REQ_UPLOAD_PHOTO,
            
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        switch response.result {
                            
                        case .success(_):
                            let json = JSON(response.result.value!)
                            let resCode = json[R.String.RESULT_CODE].intValue
                            if (resCode == R.Const.CODE_SUCCESS) {
                                let imageurl = json[R.String.PARAM_PHOTOURL].stringValue
                                completion(R.Const.CODE_SUCCESS, imageurl)
                            }
                            else {
                                completion(R.Const.CODE_UPLOAD_FAIL, "")
                            }
                            
                        case .failure(_):
                            
                            completion(R.Const.CODE_FAIL, "")
                        }
                    }
                    
                case .failure(_):
                    completion(R.Const.CODE_FAIL, "")
                }
        })
    }
    
    static func updateProfile(_ user: UserModel, completion: @escaping (Int) -> ()) {
        
        let params = [R.String.PARAM_USERID: user.id,
                      R.String.PARAM_GENDER: user.gender,
                      R.String.PARAM_AGE: user.age,
                      R.String.PARAM_MYLANGUAGE: user.my_language,
                      R.String.PARAM_TRANSLANGUAGE: user.trans_language,
                      R.String.PARAM_ABOUTME: user.about_me,
                      R.String.PARAM_ISAVAILABLE: user.is_available] as [String : Any]
        
        Alamofire.request(REQ_UPDATE_PROFILE, method: .post, parameters: params).responseJSON { response in
            
            print("updateProfile response : ", response)
            
            switch response.result {
                
            case .success:
                
                let dict = JSON(response.result.value!)
                
                let resultCode = dict[R.String.RESULT_CODE].intValue
                if resultCode == R.Const.CODE_SUCCESS {
                    currentUser?.gender = user.gender
                    currentUser?.age = user.age
                    currentUser?.my_language = user.my_language
                    currentUser?.trans_language = user.trans_language
                    currentUser?.about_me = user.about_me
                    currentUser?.is_available = user.is_available
                    
                    completion(resultCode)
                }
                
            case .failure(let error):
                completion(R.Const.CODE_FAIL)
                print(error)
            }
        }
    }
    
    static func setAvailable(_ isAvailable: Int, completion: @escaping (Int) -> ()) {
        
        let params = [R.String.PARAM_USERID: currentUser!.id,
                      R.String.PARAM_ISAVAILABLE: isAvailable] as [String : Any]
        
        Alamofire.request(REQ_SETAVAILABLE, method: .post, parameters: params).responseJSON { response in
            
            print("set available response : ", response)
            
            switch response.result {
                
            case .success:
                
                let dict = JSON(response.result.value!)
                
                let resultCode = dict[R.String.RESULT_CODE].intValue
                if resultCode == R.Const.CODE_SUCCESS {
                    
                    currentUser?.is_available = isAvailable
                    
                    completion(R.Const.CODE_SUCCESS)
                    
                } else if resultCode == R.Const.CODE_NON_EXIST {
                    completion(R.Const.CODE_NON_EXIST)
                }
                
            case .failure(let error):
                completion(R.Const.CODE_FAIL)
                print(error)
            }
        }
    }
    
    static func searchTranslator(_ my_language: String, trans_language: String, completion: @escaping (Int, [UserModel]) -> ()) {
        
        let params = [R.String.PARAM_MYLANGUAGE: my_language,
                      R.String.PARAM_TRANSLANGUAGE: trans_language] as [String : Any]
        
        Alamofire.request(REQ_SEARCH_TRANSLATORS, method: .post, parameters: params).responseJSON { response in
            
            print("translators response : ", response)
            
            switch response.result {
                
            case .success:
                
                let dict = JSON(response.result.value!)
                
                let resultCode = dict[R.String.RESULT_CODE].intValue
                if resultCode == R.Const.CODE_SUCCESS {
                    
                    var translatorList = [UserModel]()
                    
                    for translatorObj in dict[R.String.PARAM_TRANSLATORS].arrayValue {
                        translatorList.append(ParseHelper.parseTranslator(translatorObj))
                    }
                    
                    completion(R.Const.CODE_SUCCESS, translatorList)
                }
                
            case .failure(let error):
                completion(R.Const.CODE_FAIL, [])
                print(error)
            }
        }
    }
    
    static func getReview(_ user_id: Int, completion: @escaping (Int, [ReviewModel]) -> ()) {
        
        let params = [R.String.PARAM_USERID: user_id] as [String : Any]
        
        Alamofire.request(REQ_GETREVIEW, method: .post, parameters: params).responseJSON { response in
            
            print("get review response : ", response)
            
            switch response.result {
                
            case .success:
                
                let dict = JSON(response.result.value!)
                
                let resultCode = dict[R.String.RESULT_CODE].intValue
                if resultCode == R.Const.CODE_SUCCESS {
                    
                    var reviewList = [ReviewModel]()
                    
                    for reviewObj in dict[R.String.PARAM_REVIEWS].arrayValue { 
                        reviewList.append(ParseHelper.parseReview(reviewObj))
                    }
                    
                    completion(R.Const.CODE_SUCCESS, reviewList)
                }
                
            case .failure(let error):
                completion(R.Const.CODE_FAIL, [])
                print(error)
            }
        }
    }
    
    static func saveToken(token: String, completion: @escaping(Int) -> ()) {
        if let user = currentUser {
            let params = [R.String.PARAM_USERID: user.id,
                          R.String.PARAM_TOKEN: token] as [String: Any]
            
            Alamofire.request(REQ_SAVE_TOKEN, method: .post, parameters: params).responseJSON { response in
                
                print(response)
                
                if response.result.isSuccess {
                    completion(R.Const.CODE_SUCCESS)
                } else {
                    completion(R.Const.CODE_FAIL)
                }
            }
        }
    }
    
    static func writeReview(target_id: Int, mark: Float, review: String, completion: @escaping(Int) -> ()) {
        
        let params = [R.String.PARAM_USERID: currentUser!.id,
                      R.String.PARAM_TARGETID: target_id,
                      R.String.PARAM_MARK: mark,
                      R.String.PARAM_REVIEW: review] as [String: Any]
        
        Alamofire.request(REQ_WRITE_REVIEW, method: .post, parameters: params).responseJSON { response in
            
            print(response)
            
            if response.result.isSuccess {
                
                let dict = JSON(response.result.value!)
                
                let resultCode = dict[R.String.RESULT_CODE].intValue
                if resultCode == R.Const.CODE_SUCCESS {
                    
                    completion(R.Const.CODE_SUCCESS)
                    
                } else {
                    completion(R.Const.CODE_FAIL)
                }
            }
        }
    }
    
    static func sendRequest(target_id: Int, room_no: String, completion: @escaping(Int) -> ()) {
        
        let params = [R.String.PARAM_USERID: currentUser!.id,
                      R.String.PARAM_NAME: currentUser!.name,
                      R.String.PARAM_ROOMNO: room_no,
                      R.String.PARAM_TARGETID: target_id] as [String: Any]
        
        Alamofire.request(REQ_SENDREQUEST, method: .post, parameters: params).responseJSON { response in
            
            print(response)
            
            if response.result.isSuccess {
                
                let dict = JSON(response.result.value!)
                
                let resultCode = dict[R.String.RESULT_CODE].intValue
                if resultCode == R.Const.CODE_SUCCESS {
                   
                    completion(R.Const.CODE_SUCCESS)
               
                } else {
                    completion(R.Const.CODE_FAIL)
                }
            }
        }
    }
    
    static func acceptRequest(target_id: Int, room_no: Int, completion: @escaping(Int, Int) -> ()) {
        
        let params = [R.String.PARAM_USERID: currentUser!.id,
                      R.String.PARAM_NAME: currentUser!.name,
                      R.String.PARAM_ROOMNO: room_no,
                      R.String.PARAM_TARGETID: target_id] as [String: Any]
        
        Alamofire.request(REQ_ACCEPTREQUEST, method: .post, parameters: params).responseJSON { response in
            
            print(response)
            
            if response.result.isSuccess {
                
                let dict = JSON(response.result.value!)
                
                let resultCode = dict[R.String.RESULT_CODE].intValue
                if resultCode == R.Const.CODE_SUCCESS {
                    
                    let room_no = dict[R.String.PARAM_ROOMNO].intValue
                    completion(R.Const.CODE_SUCCESS, room_no)
                    
                } else {
                    completion(R.Const.CODE_FAIL, 0)
                }
            }
        }
    }
    
    static func rejectRequest(target_id: Int, room_no: String, completion: @escaping(Int) -> ()) {
        
        let params = [R.String.PARAM_USERID: currentUser!.id,
                      R.String.PARAM_NAME: currentUser!.name,
                      R.String.PARAM_ROOMNO: room_no,
                      R.String.PARAM_TARGETID: target_id] as [String: Any]
        
        Alamofire.request(REQ_REJECTREQUEST, method: .post, parameters: params).responseJSON { response in
            
            print(response)
            
            if response.result.isSuccess {
                
                let dict = JSON(response.result.value!)
                
                let resultCode = dict[R.String.RESULT_CODE].intValue
                if resultCode == R.Const.CODE_SUCCESS {
                    
                    completion(R.Const.CODE_SUCCESS)
                    
                } else {
                    completion(R.Const.CODE_FAIL)
                }
            }
        }
    }

}
