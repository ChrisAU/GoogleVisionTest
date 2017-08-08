//
//  ImagePickerInteractor.swift
//  GoogleVisionTest
//
//  Created by Chris Nevin on 08/08/2017.
//  Copyright © 2017 CJNevin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class ImagePickerInteractor: NSObject {
    fileprivate let imageSubject = PublishSubject<ImageResource?>()
    weak var presenter: ViewControllerPresentable?
    
    func pick(from source: UIImagePickerControllerSourceType = .photoLibrary) -> Driver<ImageResource> {
        return Observable.deferred { [weak self] in
            guard let `self` = self else {
                return .empty()
            }
            let imagePicker = self.makeImagePicker(with: source)
            self.presenter?.present(imagePicker)
            return self.imageSubject.asObservable()
                .take(1)
                .flatMap { image -> Observable<ImageResource> in
                    guard let image = image else {
                        return .empty()
                    }
                    return .just(image)
                }.do(onCompleted: { [weak self] in
                    self?.presenter?.dismiss(imagePicker)
                })
        }.asDriver(onErrorRecover: { _ in .empty() })
    }
    
    private func makeImagePicker(with source: UIImagePickerControllerSourceType = .photoLibrary) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        return imagePicker
    }
}

extension ImagePickerInteractor: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        imageSubject.onNext(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageSubject.onNext(nil)
    }
}
