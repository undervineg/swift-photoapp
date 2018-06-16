//
//  ViewController.swift
//  PhotoApp
//
//  Created by 심 승민 on 2018. 4. 12..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

private let reuseIdentifier = MainPhotoCell.id

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    private var selectedItems: [PHAsset] = [] {
        willSet {
            doneButton.isEnabled = newValue.count > 2 ? true : false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollectionView(notification:)),
                                               name: .photoLibraryChanged, object: nil)
        collectionView.allowsMultipleSelection = true
        doneButton.isEnabled = false
    }

    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        // 넘길 때 UICollectionViewLayout()으로 하면 안 뜸.
        let doodleVC = DoodleCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let naviVC = UINavigationController(rootViewController: doodleVC)
        self.present(naviVC, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotoService.shared.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainPhotoCell
        let asset = PhotoService.shared.at(indexPath.item)
        cell.representedAssetIdentifier = asset.localIdentifier
        PhotoService.shared.requestImage(at: indexPath.item, targetSize: ViewConfig.thumbnailSize) {
            image, isLivePhoto  in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.photoImageView.image = image
                cell.liveBadgeImageView.image = isLivePhoto ? PHLivePhotoView.livePhotoBadgeImage(options: .overContent) : nil
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ViewConfig.thumbnailSize
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItems.append(PhotoService.shared.at(indexPath.item))
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = selectedItems.index(of: PhotoService.shared.at(indexPath.item)) {
            selectedItems.remove(at: index)
        }
    }

    @IBAction func isDone(_ sender: UIBarButtonItem) {
        PhotoService.shared.requestImages(from: selectedItems, targetSize: ViewConfig.videoSize) {
            self.startMakingVideo($0)
        }
    }

    private func startMakingVideo(_ selectedImages: [UIImage?]) {
        let videoMaker = try? VideoMaker(videoSize: ViewConfig.videoSize)
        let playDuration = 3
        videoMaker?.makeVideo(from: selectedImages, duration: playDuration) { videoUrl in
            PhotoService.shared.save(.video(videoUrl), { (isSaved) -> (Void) in
                isSaved ? self.showOKAlert("\(playDuration)초 동영상이 추가되었습니다.", self.deselectAllSelectedItems) : nil
            })
        }
    }

    private func deselectAllSelectedItems() {
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: true)
            if let index = selectedItems.index(of: PhotoService.shared.at($0.item)) {
                selectedItems.remove(at: index)
            }
        }
    }

}

extension MainViewController {
    @objc func updateCollectionView(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let changes = userInfo[NotificationKeys.photoChanges] as? PHFetchResultChangeDetails<PHAsset> else { return }
        DispatchQueue.main.async {
            changes.hasIncrementalChanges ? self.updateChangedItems(changes) : self.collectionView.reloadData()
        }
    }

    private func updateChangedItems(_ changes: PHFetchResultChangeDetails<PHAsset>) {
        self.collectionView.performBatchUpdates({
            if let insertedIndexes = changes.insertedIndexes, insertedIndexes.count > 0 {
                self.collectionView.insertItems(at: insertedIndexes.compactMap { IndexPath(row: $0, section: 0) })
            }
            if let deletedIndexes = changes.removedIndexes, deletedIndexes.count > 0 {
                self.collectionView.deleteItems(at: deletedIndexes.compactMap { IndexPath(row: $0, section: 0) })
            }
            if let changedIndexes = changes.changedIndexes, changedIndexes.count > 0 {
                self.collectionView.reloadItems(at: changedIndexes.compactMap { IndexPath(row: $0, section: 0) })
            }
            if changes.hasMoves {
                changes.enumerateMoves {
                    self.collectionView.moveItem(at: IndexPath(row: $0, section: 0), to: IndexPath(row: $1, section: 0))
                }
            }
        }, completion: nil)
    }

}
