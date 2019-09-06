//
//  ViewController.swift
//  Camera Calculator
//
//  Created by myl142857 on 6/14/19.
//  Copyright © 2019 myl142857. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol PassFirstAndOperatorDelegate: class {
    func passFirstAndOperator(first: String, mathOperator: String)
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var firstNumber: String!
    var mathOperator: String!
    
    var cameraButton: UIButton!
    var cameraRollButton: UIButton!
    var guideLabel: UILabel!
    
    weak var delegate: PassInformationDelegate?
    
    var newMedia: Bool?
    var size: CGFloat = 75
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        cameraButton = UIButton()
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.setImage(UIImage(named: "camera"), for: .normal)
        cameraButton.addTarget(self, action: #selector(useCamera(_ :)), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        cameraRollButton = UIButton()
        cameraRollButton.translatesAutoresizingMaskIntoConstraints = false
        cameraRollButton.setTitle("Camera Roll", for: .normal)
        cameraRollButton.setTitleColor(.black, for: .normal)
        cameraRollButton.addTarget(self, action: #selector(useCameraRoll(_:)), for: .touchUpInside)
        view.addSubview(cameraRollButton)
        
        guideLabel = UILabel()
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        if self.firstNumber == nil && self.mathOperator == nil{
            guideLabel.text = "Start by recognizing the first number"
        }
        else {
            guideLabel.text = "Now, recognize the second number"
        }
        guideLabel.textAlignment = .center
        guideLabel.font = .boldSystemFont(ofSize: 16)
        view.addSubview(guideLabel)
        
        if firstNumber == nil && mathOperator == nil {
            navigationItem.hidesBackButton = true
        }
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 125),
            guideLabel.widthAnchor.constraint(equalToConstant: 300),
            guideLabel.heightAnchor.constraint(equalToConstant: 50)
            ])
        NSLayoutConstraint.activate([
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: size),
            cameraButton.heightAnchor.constraint(equalToConstant: size)
        ])
        NSLayoutConstraint.activate([
            cameraRollButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraRollButton.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            cameraRollButton.widthAnchor.constraint(equalToConstant: 100),
            cameraRollButton.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
    @objc func useCamera(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            newMedia = true
        }
    }

    @objc func useCameraRoll(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            newMedia = false
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        self.dismiss(animated: true, completion: nil)
        if mediaType.isEqual(to: kUTTypeImage as String) {
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            
//            imageView.image = image
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(ViewController.image(_ :didFinishSavingWithError:contextInfo:)), nil)
            }
            else if mediaType.isEqual(to: kUTTypeMovie as String) {
                // Code to support video here
            }
            
            //
            pushPreviewViewController(image: image)
        }
    }
    
    func pushPreviewViewController(image: UIImage) {
        let previewViewController = PreviewViewController()
        navigationController?.pushViewController(previewViewController, animated: true)
        self.delegate = previewViewController
        delegate?.passImage(image: image)
        if self.firstNumber != nil && self.mathOperator != nil {
            delegate?.passFirstAndOperator(first: self.firstNumber, mathOperator: self.mathOperator)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: UIAlertController.Style.alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // FROM VISIONBASICS ...
    

}

extension ViewController: PassFirstAndOperatorDelegate {
    func passFirstAndOperator(first: String, mathOperator: String) {
        self.firstNumber = first
        self.mathOperator = mathOperator
    }
}
