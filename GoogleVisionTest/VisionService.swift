//
//  VisionService.swift
//  GoogleVisionTest
//
//  Created by Chris Nevin on 08/08/2017.
//  Copyright © 2017 CJNevin. All rights reserved.
//

import Foundation
import Moya

enum VisionService {
    case annotate(ImageResource)
}

extension VisionService: TargetType {
    var baseURL: URL {
        return URL(string: "https://vision.googleapis.com/v1")!
    }
    
    var path: String {
        switch self {
        case .annotate:
            return "/images:annotate"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .annotate:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case let .annotate(resource):
            return [
                "requests": [
                    ["image": [
                        "content": resource.base64()
                        ],
                     "features": [
                        [
                            "type": "LABEL_DETECTION",
                            "maxResults": 1
                        ]
                        ]
                    ]
                ]
            ]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .annotate:
            return JSONEncoding.default // Send parameters as JSON in request body
        }
    }
    
    var sampleData: Data {
        fatalError("Not implemented")
    }
    
    var task: Task {
        switch self {
        case .annotate:
            return .request
        }
    }
    
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
