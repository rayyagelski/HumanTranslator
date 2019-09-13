//
//  ParseHelper.swift
//  Human Translator
//
//  Created by Yin on 15/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import Foundation
import SwiftyJSON


class ParseHelper {
    
    static func parseUser(_ json: JSON) -> UserModel {
        
        let user = UserModel()
        let userObject = json[R.String.PARAM_USERMODEL]
        user.id = userObject[R.String.PARAM_ID].intValue
        user.name = userObject[R.String.PARAM_NAME].stringValue
        user.email = userObject[R.String.PARAM_EMAIL].stringValue
        user.password = userObject[R.String.PARAM_PASSWORD].stringValue
        user.photo_url = userObject[R.String.PARAM_PHOTOURL].stringValue
        user.user_type = userObject[R.String.PARAM_USERTYPE].intValue
        user.age = userObject[R.String.PARAM_AGE].intValue
        user.gender = userObject[R.String.PARAM_GENDER].intValue
        user.about_me = userObject[R.String.PARAM_ABOUTME].stringValue
        user.my_language = userObject[R.String.PARAM_MYLANGUAGE].stringValue
        user.trans_language = userObject[R.String.PARAM_TRANSLANGUAGE].stringValue
        user.is_available = userObject[R.String.PARAM_ISAVAILABLE].intValue
        user.avg_mark = userObject[R.String.PARAM_AVGMARK].floatValue
        
        return user
    }
    
    static func parseTranslator(_ userObject: JSON) -> UserModel {
        
        let user = UserModel()
        user.id = userObject[R.String.PARAM_USERID].intValue
        user.name = userObject[R.String.PARAM_NAME].stringValue
//        user.email = userObject[R.String.PARAM_EMAIL].stringValue
//        user.password = userObject[R.String.PARAM_PASSWORD].stringValue
        user.photo_url = userObject[R.String.PARAM_PHOTOURL].stringValue
//        user.user_type = userObject[R.String.PARAM_USERTYPE].intValue
        user.age = userObject[R.String.PARAM_AGE].intValue
        user.gender = userObject[R.String.PARAM_GENDER].intValue
        user.about_me = userObject[R.String.PARAM_ABOUTME].stringValue
//        user.my_language = userObject[R.String.PARAM_MYLANGUAGE].stringValue
//        user.trans_language = userObject[R.String.PARAM_TRANSLANGUAGE].stringValue
        user.is_available = userObject[R.String.PARAM_ISAVAILABLE].intValue
        user.avg_mark = userObject[R.String.PARAM_AVGMARK].floatValue
        
        return user
    }
    
    static func parseReview(_ reviewObject: JSON) -> ReviewModel {
        
        let review = ReviewModel()
        
        review.user_id = reviewObject[R.String.PARAM_ID].intValue
        review.name = reviewObject[R.String.PARAM_NAME].stringValue
        review.photo_url = reviewObject[R.String.PARAM_PHOTOURL].stringValue
        review.review = reviewObject[R.String.PARAM_REVIEW].stringValue
        review.mark = reviewObject[R.String.PARAM_MARK].floatValue
        
        return review
    }
}
