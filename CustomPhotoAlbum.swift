//
//  CustomPhotoAlbum.swift
//  Pictsee1
//
//  Created by Michelle Grover on 5/11/16.
//  Copyright © 2016 Norbert Grover. All rights reserved.
//

import Foundation
import Photos

class CustomPhotoAlbum {

    static let albumName = "Pictsee"
    static let sharedInstance = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    
    init() {
    
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
            if let firstObject: AnyObject = collection.firstObject {
                return collection.firstObject as! PHAssetCollection
            }
            return nil
        }
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }
    
    func saveImage(image: UIImage) {
        if (assetCollection == nil) {
            return
        }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceholder!])
            }, completionHandler: nil)
    }
}
