//
//  PhotoService.swift
//  PhotoApp
//
//  Created by 심 승민 on 2018. 4. 17..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import Photos

class PhotoService: NSObject, PHPhotoLibraryChangeObserver {
    private let imageManager: PHCachingImageManager
    private var photos: Photos

    override init() {
        self.imageManager = PHCachingImageManager()
        self.photos = Photos()
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    var count: Int {
        return self.photos.photoAssets.count
    }

    func at(_ index: Int) -> PHAsset {
        return photos.at(index)
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: self.photos.photoAssets) else { return }
        self.photos.updateAssets(with: changes.fetchResultAfterChanges)
        NotificationCenter.default.post(name: .photoLibraryChanged, object: nil,
                                        userInfo: [NotificationKeys.photoChanges: changes])
    }

    func requestImage(at index: Int, targetSize: CGSize, _ completion: @escaping (UIImage?, Bool) -> (Void)) {
        imageManager.requestImage(for: photos.at(index),
                                  targetSize: targetSize,
                                  contentMode: PHImageContentMode.aspectFill,
                                  options: nil) { image, _ in completion(image, self.photos.at(index).isLivePhoto) }
    }

    func requestImages(from assets: [PHAsset], targetSize: CGSize, _ completion: @escaping ([UIImage?]) -> (Void)) {
        var downloadedImages: [UIImage?] = []
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        let myGroup = DispatchGroup()
        assets.forEach { asset in
            myGroup.enter()
            self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, _) in
                downloadedImages.append(image)
                myGroup.leave()
            })
        }
        myGroup.notify(queue: .global()) {
            completion(downloadedImages)
        }
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}
