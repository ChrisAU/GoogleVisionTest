//
//  ImageResource.swift
//  GoogleVisionTest
//
//  Created by Chris Nevin on 08/08/2017.
//  Copyright © 2017 CJNevin. All rights reserved.
//

import UIKit

// Abstract away the fact we are using a UIImage
protocol ImageResource {
    func base64() -> String
}

extension UIImage: ImageResource {
    func base64() -> String {
        let data = UIImageJPEGRepresentation(self, 1.0)!
        return data.base64EncodedString(options: .lineLength64Characters)
    }
}
