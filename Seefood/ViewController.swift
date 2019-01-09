//
//  ViewController.swift
//  Seafood
//
//  Created by Angela Gu on 2018-09-25.
//  Copyright © 2018 Angela Gu. All rights reserved.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imagePicker.delegate = self
        //imagePicker.sourceType = .camera
        imagePicker.sourceType = .photoLibrary //can pick photo from photo library
        imagePicker.allowsEditing = false
        // can crop the image
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            //ci image = core image image, it is a special type of image that allows us to use the vision framework and the core M-L framework in order to get an interpretation from it
            // use guard for security reason, check if userpickimage can be convert to ciimage
            
            guard let ciimage = CIImage(image: userPickedImage) else{
                fatalError("Can not convert to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image:CIImage){
        // VNCoreMLModel comes from vision imported
        // if model is nil, give a fatal error
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("Loading CoreML Model Failed")
        }
        // when the request has completed is to process the results of the request passed in
        // call back
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Classification Failed")
            }
            
            if let firstResult = results.first{
                self.navigationItem.title = firstResult.identifier
            }
            
        }
        // specify image we want to classify, process the result
        
        let handler = VNImageRequestHandler(ciImage:image)
        
        do {
            try handler.perform([request])
        }
        catch{
            print(error)
        }
    }
    @IBAction func CameraTapped(_ sender: UIBarButtonItem) {
        // determine when we enable the image picker
        // completion: dont want to do anything after taking photo
        present(imagePicker, animated: true, completion: nil)
    }
    

}

