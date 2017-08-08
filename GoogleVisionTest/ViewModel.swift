//
//  ViewModel.swift
//  GoogleVisionTest
//
//  Created by Chris Nevin on 08/08/2017.
//  Copyright © 2017 CJNevin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Moya

class ViewModel {
    let imageResource: Driver<ImageResource>
    let canProcessImage: Driver<Bool>
    let annotation: Driver<String>
    
    init(pickImage: Driver<Void>,
         processImage: Driver<Void>,
         imagePicker: ImagePickerInteractor,
         serviceProvider: RxMoyaProvider<VisionService>)
    {
        imageResource = pickImage
            .flatMap { _ in imagePicker.pick() }
        
        canProcessImage = imageResource
            .map({ _ in true })
            .startWith(false)
        
        annotation = Driver.combineLatest(canProcessImage, processImage, imageResource) { $0 == true ? $2 : nil }
            .filter({ $0 != nil })
            .map({ $0! })
            .flatMap({
                serviceProvider
                    .request(.annotate($0))
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .flatMap { json -> Observable<String> in
                        guard
                            let response = json as? [String: Any],
                            let responses = response["responses"] as? [[String: Any]],
                            let labelAnnotations = responses.first?["labelAnnotations"] as? [[String: Any]],
                            let description = labelAnnotations.first?["description"] as? String else {
                            return .empty()
                        }
                        return .just(description)
                    }
                    .asDriver(onErrorRecover: { _ in .empty() })
            })
        
    }
}
