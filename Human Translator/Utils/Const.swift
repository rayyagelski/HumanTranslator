//
//  Const.swift
//  Human Translator
//
//  Created by Yin on 09/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import Foundation


var arrAge = [Int]()
var languageArr = [LanguageModel]()
var isLogout: Bool = false
var isLogin: Bool = false
var isCalled: Bool = false

class R {
    
    class String {
        
        static let SAVE_ROOT_PATH               = "HumanTranslator"
        
        static let APP_NAME                     = "HumanTranslator"
        static let OK                           = "OK"
        static let CANCEL                       = "Cancel"
        static let NO                           = "No"
        static let YES                          = "Yes"
        
        static let ERROR                        = "Error"
        static let CHECK_NAME_EMPTY             = "Please input your name"
        static let CHECK_PASSWORD_EMPTY         = "Please input your password"
        static let CHECK_EMAIL_EMPTY            = "Please input your email address"
        static let CHECK_EMAIL_INVALID          = "Please input valid email"
        static let CHECK_AGE_EMPTY              = "Please select your age"
        static let CHECK_GENDER_EMPTY           = "Please select your gender"
        static let CHECK_MYLANGUAGE             = "Please select your language"
        static let CHECK_TRANS_LANGUAGE         = "Please select your translate language"
        static let CHECK_ABOUTME                = "Please write about you"
        static let SUCCESS_UPDATE               = "Profile updated successfully"
        static let NON_AVAILABLE                = "Translator is not available"
        static let INVALID_RATING               = "invalid rating"
        static let INVAILD_REVIEW_LETTER        = "Please write at least 6 letters"
        static let SUCCESS_RATE                 = "Successfully rated"
        static let SUCCESS_RESETPWD             = "Successfully reset"
        
        ////
        static let ERROR_CONNECT                = "Failed to server connection"
        static let EXIST_EMAIL                  = "Email is already registered"
        static let UNREGISTERED_USER            = "User does not registered"
        static let WRONG_PASSWORD               = "Wrong password"
        
        static let FROM_GALLERY                 = "Gallery"
        static let FROM_CAMERA                  = "Camera"
        
        static let KEY_EMAIL                    = "email"
        static let KEY_PASSWORD                 = "password"
        static let KEY_USERID                   = "user_id"
        static let KEY_TOKEN                    = "key_token"
        static let KEY_REQUEST                  = "request"
        static let KEY_ACCEPT                   = "accept"
        
        
        
        static let AGE                          = "Age"
        static let GENDER                       = "Gender"
        static let SEL_LANGUAGE                 = "Select language"
        
        //Parameters
        
        static let PARAM_ID                     = "id"
        static let PARAM_USERID                 = "user_id"
        static let PARAM_NAME                   = "name"
        static let PARAM_EMAIL                  = "email"
        static let PARAM_PASSWORD               = "password"
        static let PARAM_USERTYPE               = "user_type"
        static let PARAM_ISAVAILABLE            = "is_available"
        static let PARAM_AGE                    = "age"
        static let PARAM_GENDER                 = "gender"
        static let PARAM_ABOUTME                = "about_me"
        static let PARAM_MYLANGUAGE             = "my_language"
        static let PARAM_TRANSLANGUAGE          = "trans_language"        
        static let PARAM_PHOTOURL               = "photo_url"
        static let PARAM_AVGMARK                = "avg_mark"
        static let PARAM_USERMODEL              = "userModel"
        static let PARAM_TRANSLATORS            = "translators"
        static let PARAM_REVIEWS                = "reviews"
        
        static let PARAM_REVIEW                 = "review"
        static let PARAM_MARK                   = "mark"
        static let PARAM_TOKEN                  = "token"
        static let PARAM_MSGTYPE                = "msg_type"
        static let PARAM_ROOMNO                 = "room_no"
        static let PARAM_TARGETID               = "target_id"
        
        
        // Result code
        static let RESULT_CODE                  = "result_code"
        static let RESULT_SUCCESS               = "result_success"
        
    }
    
    class Const  {
        
        static let CODE_FAIL                    = -100
        static let CODE_0                       = 0
        static let CODE_SUCCESS                 = 100
        static let CODE_ALREADY_EXIST           = 101
        static let CODE_UPLOAD_FAIL             = 102
        static let CODE_NON_EXIST               = 103
        static let CODE_WRONG_PWD               = 104
        static let CODE_GROUP_EXIST             = 105
        
        static let IS_CALLING                   = 111
        static let IS_RECEIVING                 = 222
        
        
        
    }
    
    class Array {
        
        static let GENDER                       = ["Male", "Female"]
        
    }
}
