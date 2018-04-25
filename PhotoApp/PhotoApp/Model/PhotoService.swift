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
        let myGroup = DispatchGroup()
        assets.forEach { asset in
            myGroup.enter()
            self.imageManager.requestImageData(for: asset, options: nil, resultHandler: { (data, _, _, _) in
                if let data = data, let fullImage = UIImage(data: data) {
                    let resizedImage = fullImage.resizedImage(fullImage.size.newSize(fitTo: targetSize))
                    downloadedImages.append(resizedImage)
                    myGroup.leave()
                }
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

extension CGSize {
    func newSize(fitTo targetSize: CGSize) -> CGSize {
        let widthRatio = targetSize.width / self.width
        let heightRatio = targetSize.height / self.height

        let applyRatio = widthRatio > heightRatio ? heightRatio : widthRatio
        return CGSize.init(width: self.width*applyRatio, height: self.height*applyRatio)
    }
}

extension UIImage {
    func resizedImage(_ targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(targetSize)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
