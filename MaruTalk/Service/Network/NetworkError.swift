//
//  NetworkError.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/4/24.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidRequestData
    case responseCode(errorCode: String?)
    
    var errorCode: String? {
        switch self {
        case .responseCode(let errorCode):
            return errorCode
        default: return nil
        }
    }
}
