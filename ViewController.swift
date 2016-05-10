//
//  ViewController.swift
//  Pictsee1
//
//  Created by Michelle Grover on 4/30/16.
//  Copyright © 2016 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let ManObjCon = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var nImage:ImageList? = nil

    @IBOutlet weak var txtAreaDesc: UITextField!
   
    @IBAction func btnAddImage(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        pickerController.allowsEditing = true
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func filter1(sender: AnyObject) {
        guard let image = imgDisplay.image, cgimg = image.CGImage else {
            print("imgDisplay doesn't have an image")
            return
        }
        let openGLContext = EAGLContext(API: .OpenGLES2)
        let context = CIContext(EAGLContext: openGLContext!)
        
        let coreImage = CIImage(CGImage: cgimg)
        
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(0.5, forKey: kCIInputIntensityKey)
        
        if let sepiaOut = sepiaFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
            let gammaFilter = CIFilter(name: "CIGammaAdjust")
            gammaFilter?.setValue(sepiaOut, forKey: kCIInputImageKey)
            gammaFilter?.setValue(1.50, forKey: "inputPower")
            if let exposureOutPut = gammaFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
                let outPut = context.createCGImage(exposureOutPut, fromRect: exposureOutPut.extent)
                let results = UIImage(CGImage: outPut)
                self.imgDisplay.image = results
            }
        }
    }
    
    @IBAction func filter2(sender: AnyObject) {
    }
    
    @IBAction func filter3(sender: AnyObject) {
    }
    
    @IBAction func clearFilter(sender: AnyObject) {
    }
    
    @IBAction func btnAddCameraImage(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        pickerController.allowsEditing = true
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    @IBOutlet weak var imgDisplay: UIImageView!
    
    
    @IBAction func btnCancel(sender: AnyObject) {
        dismissVC()
    }
    @IBAction func btnSave(sender: AnyObject) {
        if(nImage != nil) {
            editItem()
        } else {
            newItem()
        }
        dismissVC()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.imgDisplay.image = image
    }
    
    func editItem() {
        nImage?.desc = txtAreaDesc.text
        if (self.imgDisplay.image != nil) {
            nImage?.image = UIImagePNGRepresentation(self.imgDisplay.image!)
        }
        do {
        try ManObjCon.save()
        } catch {
            print(error)
            return
        }
    }
    
    func newItem() {
        let context = self.ManObjCon
        let ent = NSEntityDescription.entityForName("ImageList", inManagedObjectContext: context)
        let listItem = ImageList(entity: ent!, insertIntoManagedObjectContext: ManObjCon)
        listItem.desc = txtAreaDesc.text
        
         if (self.imgDisplay != nil) {
            listItem.image = UIImagePNGRepresentation(self.imgDisplay.image!)
         }
        
        do {
            try context.save()
            print("Saving this: \(txtAreaDesc.text)")
        } catch {
            print(error)
            return
        }
        dismissVC()
    }
    
    
    func dismissVC() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (nImage != nil) {
            txtAreaDesc.text = nImage?.desc
            if (nImage?.image != nil) {
                self.imgDisplay.image = UIImage(data: (nImage?.image)!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

