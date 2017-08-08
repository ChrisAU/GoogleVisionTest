//
//  ServiceProvider.swift
//  GoogleVisionTest
//
//  Created by Chris Nevin on 08/08/2017.
//  Copyright © 2017 CJNevin. All rights reserved.
//

import Foundation
import Moya

let apiKey = ""

struct ServiceProvider {
    static let shared = ServiceProvider()
    
    let provider: RxMoyaProvider<VisionService>
    
    private init() {
        let endpointClosure = { (target: VisionService) -> Endpoint<VisionService> in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            let endpoint = Endpoint<VisionService>(
                url: "\(defaultEndpoint.url)?key=\(apiKey)",
                sampleResponseClosure: defaultEndpoint.sampleResponseClosure,
                method: target.method,
                parameters: target.parameters,
                parameterEncoding: target.parameterEncoding,
                httpHeaderFields: defaultEndpoint.httpHeaderFields)
            return endpoint
        }
        provider = RxMoyaProvider<VisionService>(endpointClosure: endpointClosure)
    }
}

