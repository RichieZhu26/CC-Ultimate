//
//  PreviewViewController.swift
//  TheBigBang
//
//  Created by myl142857 on 6/17/19.
//  Copyright © 2019 myl142857. All rights reserved.
//

import UIKit
import CoreML
import Vision

protocol PassInformationDelegate: class {
    func passImage(image: UIImage)
    func passFirstAndOperator(first: String, mathOperator: String)
}


class PreviewViewController: UIViewController {
    
    var imageView: UIImageView!
    var presentImage: UIImage!
    var processImage: UIImage!
    var processButton: UIButton!
    var identityLabel: UILabel!
    var retakeBarButtonItem: UIBarButtonItem!
    var nextBarButtonItem: UIBarButtonItem!
    
    // Layer into which to draw bounding box paths.
    var pathLayer: CALayer?
    
    var digitImages_first: [CGImage]! = []
    var result = ""
    var firstNumber: String!
    var mathOperator: String!
    var secondNumber: String!
    
    weak var delegate_1: PassNumberDelegate?
    weak var delegate_2: PassAllDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        processImage = scaleAndOrient(image: presentImage)
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = presentImage
        view.addSubview(imageView)
        
        processButton = UIButton()
        processButton.translatesAutoresizingMaskIntoConstraints = false
        processButton.setTitle("PROCESS", for: .normal)
        processButton.setTitleColor(.black, for: .normal)
        processButton.layer.borderWidth = 2.0
        processButton.addTarget(self, action: #selector(processTheFormula), for: .touchUpInside)
        view.addSubview(processButton)
        
        identityLabel = UILabel()
        identityLabel.translatesAutoresizingMaskIntoConstraints = false
        identityLabel.text = "RESULT"
        identityLabel.textColor = .black
        identityLabel.textAlignment = .center
        view.addSubview(identityLabel)
        
        retakeBarButtonItem = UIBarButtonItem(title: "Retake", style: UIBarButtonItem.Style.plain, target: self, action: #selector( myLeftSideBarButtonItemTapped(_:)))
        self.navigationItem.leftBarButtonItem = retakeBarButtonItem
        
        nextBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItem.Style.plain, target: self, action: #selector(
            myRightSideBarButtonItemTapped(_:)))
        self.navigationItem.rightBarButtonItem = nextBarButtonItem
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -175)
            ])
        NSLayoutConstraint.activate([
            processButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            processButton.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -125),
            processButton.widthAnchor.constraint(equalToConstant: 150),
            processButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        NSLayoutConstraint.activate([
            identityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            identityLabel.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            identityLabel.widthAnchor.constraint(equalToConstant: 400),
            identityLabel.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
    @objc func myLeftSideBarButtonItemTapped(_ sender: UIBarButtonItem!) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func myRightSideBarButtonItemTapped(_ sender: UIBarButtonItem!) {
        if firstNumber == nil && mathOperator == nil {
            if self.result == "" {
                identityLabel.text = "Number is invalid. Please try again."
                return
            }
            for i in self.result {
                if i == "$" {
                    identityLabel.text = "Number is invalid. Please try again."
                    return
                }
            }
            let operatorViewController = OperatorViewController()
            navigationController?.pushViewController(operatorViewController, animated: true)
            self.delegate_1 = operatorViewController
            delegate_1?.passNumber(number: self.result)
        }
        else {
            self.secondNumber = self.result
            let outputViewController = OutputViewController()
            navigationController?.pushViewController(outputViewController, animated: true)
            self.delegate_2 = outputViewController
            delegate_2?.passAll(first: self.firstNumber, mathOperator: self.mathOperator, second: self.secondNumber)
        }
    }
    
    @objc func processTheFormula() {
        // Convert from UIImageOrientation to CGImagePropertyOrientation.
        let cgOrientation = CGImagePropertyOrientation(processImage.imageOrientation)
        
        performVisionRequest(image: processImage.cgImage!,
                             orientation: cgOrientation)
        
        //        let outputViewController = OutputViewController()
        //        present(outputViewController, animated: true, completion: nil)
        
        for image in self.digitImages_first {
            startClassification(fro: UIImage(cgImage: image))
        }
        self.identityLabel.text = self.result
        
    }
    
    func buildRequest() -> VNCoreMLRequest {
        do {
            let model = try VNCoreMLModel(for: MNISTClassifier().model)
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request, error in self?.checkResults(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load ML model: \(error)")
        }
    }
    
    func checkResults(for request: VNRequest, error: Error?) {
//        DispatchQueue.main.async {
            guard let results = request.results else {
                self.identityLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            let classifications = results as! [VNClassificationObservation]
            if classifications.isEmpty {
                self.identityLabel.text = "Nothing recognized."
            } else {
                let bestClassifications = classifications.prefix(1)
                let bestMatch = bestClassifications[0]
                if bestMatch.confidence < 0.75
                {
//                    self.identityLabel.text = "No Match"
                    self.result = self.result + "$"
                    
                } else {
                    self.result = self.result + bestMatch.identifier
//                    self.identityLabel.text = bestMatch.identifier
                }
            }
        }
//    }
    
    func startClassification(fro image: UIImage) {
        if let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) {
            guard let ciImage = CIImage(image: image) else {
                fatalError("Unable to create \(CIImage.self) from \(image).")
            }
//            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
                do {
                    let request = self.buildRequest()
                    try handler.perform([request])
                } catch {
                    print("Classification failed: \(error.localizedDescription)")
                }
            }
        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // FROM VISIONBASICS
    
    // MARK: - Helper Methods
    
    /// - Tag: PreprocessImage
    func scaleAndOrient(image: UIImage) -> UIImage {
        
        // Set a default value for limiting image size.
        let maxResolution: CGFloat = 640
        
        guard let cgImage = image.cgImage else {
            print("UIImage has no CGImage backing it!")
            return image
        }
        
        // Compute parameters for transform.
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        var transform = CGAffineTransform.identity
        
        var bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        if width > maxResolution ||
            height > maxResolution {
            let ratio = width / height
            if width > height {
                bounds.size.width = maxResolution
                bounds.size.height = round(maxResolution / ratio)
            } else {
                bounds.size.width = round(maxResolution * ratio)
                bounds.size.height = maxResolution
            }
        }
        
        let scaleRatio = bounds.size.width / width
        let orientation = image.imageOrientation
        switch orientation {
        case .up:
            transform = .identity
        case .down:
            transform = CGAffineTransform(translationX: width, y: height).rotated(by: .pi)
        case .left:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: 0, y: width).rotated(by: 3.0 * .pi / 2.0)
        case .right:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: 0).rotated(by: .pi / 2.0)
        case .upMirrored:
            transform = CGAffineTransform(translationX: width, y: 0).scaledBy(x: -1, y: 1)
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0, y: height).scaledBy(x: 1, y: -1)
        case .leftMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: width).scaledBy(x: -1, y: 1).rotated(by: 3.0 * .pi / 2.0)
        case .rightMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2.0)
        }
        
        return UIGraphicsImageRenderer(size: bounds.size).image { rendererContext in
            let context = rendererContext.cgContext
            
            if orientation == .right || orientation == .left {
                context.scaleBy(x: -scaleRatio, y: scaleRatio)
                context.translateBy(x: -height, y: 0)
            } else {
                context.scaleBy(x: scaleRatio, y: -scaleRatio)
                context.translateBy(x: 0, y: -height)
            }
            context.concatenate(transform)
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
    
    func presentAlert(_ title: String, error: NSError) {
        // Always present alert on main thread.
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default) { _ in
                                            // Do nothing -- simply dismiss alert.
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Vision
    
    /// - Tag: PerformRequests
    fileprivate func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {
        
        // Fetch desired requests based on switch status.
        let requests = createVisionRequests()
        // Create a request handler.
        let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                        orientation: orientation,
                                                        options: [:])
        
        // Send the requests to the request handler.
//        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
                //<<<
                var text = requests[0].results as? [VNTextObservation]
                if text!.count != 0 {
                    let first = text![0]
                    for charBox in (first.characterBoxes)! {
                        print(charBox)
                    }
                    
                    var transform = CGAffineTransform.identity
                    transform = transform.scaledBy(x: CGFloat(image.width), y: CGFloat(-image.height))
                    transform = transform.translatedBy(x: 0, y: -1)
                    //x
                    
                    for box in first.characterBoxes! {
                        //
                        //if box == first.characterBoxes![0] {
                        let rect = box.boundingBox.applying(transform)
                        
                        let scaleUp: CGFloat = 0.2
                        let biggerRect = rect.insetBy(
                            dx: -(rect.size.width) * scaleUp,
                            dy: -rect.size.height * scaleUp
                        )
                        if let croppedImage = self.crop(image: image, rect: biggerRect) {
                            let resizeImage = CIImage(cgImage: resize(croppedImage)!)

                            let context = CIContext()
                            
                            let exposureFilter = CIFilter(name: "CIExposureAdjust")
                                exposureFilter?.setValue(resizeImage, forKey: kCIInputImageKey)
                                exposureFilter?.setValue(1.0, forKey: kCIInputEVKey)
                            let afterPreviewImage_1 = (exposureFilter?.outputImage)!
                            let monochromeFilter = CIFilter(name: "CIColorMonochrome")
                            monochromeFilter?.setValue(afterPreviewImage_1, forKey: kCIInputImageKey)
                            monochromeFilter?.setValue(CIColor(color: .white), forKey: kCIInputColorKey)
                            monochromeFilter?.setValue(1.0, forKey: kCIInputIntensityKey)
                            let afterPreviewImage_2 = (monochromeFilter?.outputImage)!
                            let colorInvertFilter = CIFilter(name: "CIColorInvert")
                            colorInvertFilter?.setValue(afterPreviewImage_2, forKey: kCIInputImageKey)
                            let afterPreviewImage_3 = (colorInvertFilter?.outputImage)!
                            let unsharpFilter = CIFilter(name: "CIUnsharpMask")
                            unsharpFilter?.setValue(afterPreviewImage_3, forKey: kCIInputImageKey)
                            let afterPreviewImage_4 = (unsharpFilter?.outputImage)!
                            
                            let resultImage = context.createCGImage(afterPreviewImage_4, from: afterPreviewImage_4.extent)
                            self.digitImages_first.append(resultImage!)
                            }
                        
                    }
                    print(self.digitImages_first.count)
                }
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                self.presentAlert("Image Request Failed", error: error)
                return
            }
        }
//    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
    
    func resize(_ image: CGImage) -> CGImage? {
        let width = 28
        let height = 28
        
        guard let colorSpace = image.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: image.bitsPerComponent, bytesPerRow: image.bytesPerRow, space: colorSpace, bitmapInfo: image.alphaInfo.rawValue) else { return nil }
        
        // draw image to context (resizing it)
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)))
        
        // extract resulting image from context
        return context.makeImage()
        
    }
    
    //<<<
    private func crop(image: CGImage, rect: CGRect) -> CGImage? {
        guard let cropped = image.cropping(to: rect) else {
            return nil
        }
        
        return cropped
    }
    //>>>
    
    /// - Tag: CreateRequests
    fileprivate func createVisionRequests() -> [VNRequest] {
        
        // Create an array to collect all desired requests.
        var requests: [VNRequest] = []
        
        // Create & include a request if and only if switch is ON.
        requests.append(self.textDetectionRequest)
        
        // Return grouped requests as a single array.
        return requests
    }
    
    fileprivate func handleDetectedText(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            self.presentAlert("Text Detection Error", error: nsError)
            return
        }
        // Perform drawing on the main thread.
        DispatchQueue.main.async {
            guard let drawLayer = self.pathLayer,
                let results = request?.results as? [VNTextObservation] else {
                    return
            }
            self.draw(text: results, onImageWithBounds: drawLayer.bounds)
            drawLayer.setNeedsDisplay()
        }
    }
    
    /// - Tag: ConfigureCompletionHandler
    lazy var textDetectionRequest: VNDetectTextRectanglesRequest = {
        let textDetectRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleDetectedText)
        // Tell Vision to report bounding box around each character.
        textDetectRequest.reportCharacterBoxes = true
        return textDetectRequest
    }()
    
    // MARK: - Path-Drawing
    
    fileprivate func boundingBox(forRegionOfInterest: CGRect, withinImageBounds bounds: CGRect) -> CGRect {
        
        let imageWidth = bounds.width
        let imageHeight = bounds.height
        
        // Begin with input rect.
        var rect = forRegionOfInterest
        
        // Reposition origin.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.origin.x
        rect.origin.y = (1 - rect.origin.y) * imageHeight + bounds.origin.y
        
        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight
        
        return rect
    }
    
    fileprivate func shapeLayer(color: UIColor, frame: CGRect) -> CAShapeLayer {
        // Create a new layer.
        let layer = CAShapeLayer()
        
        // Configure layer's appearance.
        layer.fillColor = nil // No fill to show boxed object
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.borderWidth = 2
        
        // Vary the line color according to input.
        layer.borderColor = color.cgColor
        
        // Locate the layer.
        layer.anchorPoint = .zero
        layer.frame = frame
        layer.masksToBounds = true
        
        // Transform the layer to have same coordinate system as the imageView underneath it.
        layer.transform = CATransform3DMakeScale(1, -1, 1)
        
        return layer
    }
    
    // Lines of text are RED.  Individual characters are PURPLE.
    fileprivate func draw(text: [VNTextObservation], onImageWithBounds bounds: CGRect) {
        CATransaction.begin()
        for wordObservation in text {
            let wordBox = boundingBox(forRegionOfInterest: wordObservation.boundingBox, withinImageBounds: bounds)
            let wordLayer = shapeLayer(color: .red, frame: wordBox)
            
            // Add to pathLayer on top of image.
            pathLayer?.addSublayer(wordLayer)
            
            // Iterate through each character within the word and draw its box.
            guard let charBoxes = wordObservation.characterBoxes else {
                continue
            }
            for charObservation in charBoxes {
                let charBox = boundingBox(forRegionOfInterest: charObservation.boundingBox, withinImageBounds: bounds)
                let charLayer = shapeLayer(color: .purple, frame: charBox)
                charLayer.borderWidth = 1
                
                // Add to pathLayer on top of image.
                pathLayer?.addSublayer(charLayer)
            }
        }
        CATransaction.commit()
    }

}

extension PreviewViewController: PassInformationDelegate {
    func passImage(image: UIImage) {
        self.presentImage = image
    }
    func passFirstAndOperator(first: String, mathOperator: String) {
        self.firstNumber = first
        self.mathOperator = mathOperator
    }
}
