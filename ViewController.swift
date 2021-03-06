//
//  ViewController.swift
//  Pictsee1
//
//  Created by Michelle Grover on 4/30/16.
//  Copyright © 2016 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData
import AssetsLibrary
import Social
import MessageUI

class ViewController: UIViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,MFMailComposeViewControllerDelegate {
    
    let ManObjCon = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var nImage:ImageList? = nil
    var alertController:UIAlertController!
    var myMailComposer:MFMailComposeViewController?

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
        guard let image = imgDisplay.image, cgimg = image.CGImage else {
            print("There is no image")
            return
        }
        let openGLContext = EAGLContext(API: .OpenGLES2)
        let context = CIContext(EAGLContext: openGLContext!)
        
        let coreImage = CIImage(CGImage: cgimg)
        
        let chromeFilter = CIFilter(name: "CIPhotoEffectChrome")
        chromeFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let chromeFilterOut = chromeFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
            let photoEffectFilter = CIFilter(name: "CIPhotoEffectInstant")
            photoEffectFilter?.setValue(chromeFilterOut, forKey: kCIInputImageKey)
            
            if let exposureOutPut = photoEffectFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
                let output = context.createCGImage(exposureOutPut, fromRect: exposureOutPut.extent)
                let results = UIImage(CGImage: output)
                imgDisplay.image = results
            }
        }
    }
    
    @IBAction func filter3(sender: AnyObject) {
        guard let image = imgDisplay.image, cgimg = image.CGImage else {
            print("There is no image!")
            return
        }
        let openGLContext = EAGLContext(API: .OpenGLES2)
        let context = CIContext(EAGLContext: openGLContext!)
        
        let coreImage = CIImage(CGImage: cgimg)
        
        let PhotoEffectProcessFilter = CIFilter(name: "CIPhotoEffectProcess")
        PhotoEffectProcessFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let photoProcessOutPut = PhotoEffectProcessFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
            let output = context.createCGImage(photoProcessOutPut, fromRect: photoProcessOutPut.extent)
            let results = UIImage(CGImage: output)
            self.imgDisplay.image = results        }
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
    
    @IBAction func btnSaveToFolder(sender: AnyObject) {
        
        self.presentViewController(alertController, animated: true) { 
            (ACTION) -> Void in
                print("action sheet used")
        }
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
        
         if (self.imgDisplay.image != nil) {
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
        
        alertController = UIAlertController(title: "Where do you want your image?", message: "Save image to (Pictsee) folder or share on social media.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let emailAction = UIAlertAction(title: "Email", style: UIAlertActionStyle.Default) {(ACTION) -> Void in
            
            let eCaption:String = (self.nImage?.desc)!
            
            let eImage = UIImage(data: (self.nImage?.image)!)
            let pngImage = UIImagePNGRepresentation(eImage!)
            
            if MFMailComposeViewController.canSendMail() {
                self.myMailComposer = MFMailComposeViewController()
                
                self.myMailComposer?.mailComposeDelegate = self
                self.myMailComposer!.setToRecipients(["test@gmail.com"])
                self.myMailComposer!.setSubject("caption: \(eCaption)")
                self.myMailComposer!.setMessageBody("caption: \(eCaption)", isHTML: false)
                self.presentViewController(self.myMailComposer!, animated: true, completion: nil)
            } else {
            
            }
            func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
                switch (result.rawValue) {
                case MFMailComposeResultSent.rawValue:
                    print("Mail was sent")
                case MFMailComposeResultFailed.rawValue:
                    print("Msg Failed")
                case MFMailComposeResultSaved.rawValue:
                    print("Mail was saved")
                default:
                    print("Nothing")
                }
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            /**
            let myMailComposeController = MFMailComposeViewController()
            myMailComposeController.mailComposeDelegate = self
            myMailComposeController.setToRecipients(["test@gmail.com"])
            myMailComposeController.setSubject("caption: \(eCaption)")
            myMailComposeController.setMessageBody("caption: \(eCaption)", isHTML: false)
            **/
            //myMailComposeController.addAttachmentData(pngImage!, mimeType: "image/png", fileName: "image")
            
            
            /**
            if (MFMailComposeViewController.canSendMail()) {
                self.presentViewController(myMailComposeController, animated: true, completion: {
                    
                })
            } else {
                print("Device not configured for email.")
            }
            
            func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
                controller.dismissViewControllerAnimated(true) {() -> Void in
                }
            }
            **/
            print("send image to email")
        }
        let facebookAction = UIAlertAction(title: "Facebook", style: UIAlertActionStyle.Default) {(ACTION) -> Void in
            
            let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            vc.setInitialText(self.nImage!.desc)
            let sImage = UIImage(data: (self.nImage?.image)!)
            vc.addImage(sImage)
            self.presentViewController(vc, animated: true, completion: nil)
            print("shared on Facebook")
        }
        let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default) { (ACTION) -> Void in
            
            let vc1 = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc1.setInitialText(self.nImage!.desc)
            let tImage = UIImage(data: (self.nImage?.image)!)
            vc1.addImage(tImage)
            self.presentViewController(vc1, animated: true, completion: nil)
            print("share on Twitter")
        }
        let folderAction = UIAlertAction(title: "Folder", style: UIAlertActionStyle.Cancel) { (ACTION) -> Void in
            CustomPhotoAlbum.sharedInstance.saveImage(self.imgDisplay.image!)
            print("Saved to Folder")
        }
        
        
        alertController.addAction(emailAction)
        alertController.addAction(facebookAction)
        alertController.addAction(twitterAction)
        alertController.addAction(folderAction)
       
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

