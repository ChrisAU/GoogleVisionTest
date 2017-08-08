//
//  ViewController.swift
//  GoogleVisionTest
//
//  Created by Chris Nevin on 08/08/2017.
//  Copyright © 2017 CJNevin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Moya

class ViewController: UIViewController {
    fileprivate var disposeBag: DisposeBag! = DisposeBag()
    
    fileprivate lazy var serviceProvider: RxMoyaProvider<VisionService> = {
        return ServiceProvider.shared.provider
    }()
    
    fileprivate lazy var imagePickerInteractor: ImagePickerInteractor = {
        let imagePickerInteractor = ImagePickerInteractor()
        imagePickerInteractor.presenter = self
        return imagePickerInteractor
    }()
    
    fileprivate lazy var pickImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Pick Image", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1 / UIScreen.main.scale
        return button
    }()
    
    fileprivate lazy var processImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Process Image", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1 / UIScreen.main.scale
        return button
    }()
    
    fileprivate lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1 / UIScreen.main.scale
        return imageView
    }()
    
    fileprivate lazy var responseTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1 / UIScreen.main.scale
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bind()
    }
}

fileprivate extension ViewController {
    enum Metric {
        static let spacing = UIEdgeInsets(top: 20, left: 20, bottom: -20, right: -20)
        static let buttonHeight: CGFloat = 44
        static let responseHeight: CGFloat = 150
    }
}

fileprivate extension ViewController {
    private func tapAction(forButton button: UIButton) -> Driver<Void> {
        let buttonAction = Variable<Void?>(nil)
        button.rx.tap
            .bind(to: buttonAction)
            .disposed(by: disposeBag)
        return buttonAction.asDriver().filter({ $0 != nil }).map({ $0! })
    }
    
    private func pickImageAction() -> Driver<Void> {
        return tapAction(forButton: pickImageButton)
    }
    
    private func processImageAction() -> Driver<Void> {
        return tapAction(forButton: processImageButton)
    }
    
    func bind() {
        let viewModel = ViewModel(pickImage: pickImageAction(),
                                  processImage: processImageAction(),
                                  imagePicker: imagePickerInteractor,
                                  serviceProvider: serviceProvider)
        
        viewModel.imageResource
            .map({ $0 as? UIImage })
            .drive(previewImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.canProcessImage
            .drive(processImageButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.annotation
            .drive(responseTextView.rx.text)
            .disposed(by: disposeBag)
    }
    
    func layout() {
        view.backgroundColor = .white
        edgesForExtendedLayout = []
        title = "Vision"
        
        processImageButton.isEnabled = false
        
        [previewImageView, pickImageButton, processImageButton, responseTextView].forEach(view.addSubview)
        
        let spacing = Metric.spacing
        
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: spacing.top),
            previewImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: spacing.left),
            previewImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: spacing.right),
            previewImageView.heightAnchor.constraint(equalTo: previewImageView.widthAnchor),
            
            responseTextView.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: spacing.top),
            responseTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: spacing.left),
            responseTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: spacing.right),
            responseTextView.heightAnchor.constraint(equalToConstant: Metric.responseHeight),
            
            pickImageButton.topAnchor.constraint(greaterThanOrEqualTo: responseTextView.bottomAnchor, constant: spacing.top),
            pickImageButton.bottomAnchor.constraint(equalTo: processImageButton.topAnchor, constant: spacing.bottom),
            pickImageButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: spacing.left),
            pickImageButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: spacing.right),
            pickImageButton.heightAnchor.constraint(equalToConstant: Metric.buttonHeight),
            
            processImageButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: spacing.left),
            processImageButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: spacing.right),
            processImageButton.heightAnchor.constraint(equalToConstant: Metric.buttonHeight),
            processImageButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: spacing.bottom)
        ])
    }
}
