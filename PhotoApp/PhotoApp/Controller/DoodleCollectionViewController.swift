//
//  DoodleCollectionViewController.swift
//  PhotoApp
//
//  Created by 심 승민 on 2018. 4. 26..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit

private let reuseIdentifier = DoodleImageCell.id

class DoodleCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

    private var doodles: [Doodle] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        configureNavigationBar()
        setupGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        GoogleService.shared.fetchDoodles { (doodles) in
            self.doodles = doodles
        }
    }

    // MARK: - PRIVATE

    private func setupCollectionView() {
        self.collectionView!.dataSource = self
        self.collectionView!.delegate = self
        self.collectionView!.register(DoodleImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.clearsSelectionOnViewWillAppear = true
        self.collectionView?.backgroundColor = UIColor.darkGray
    }

    private func configureNavigationBar() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.title = "Doodles"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(dismissSelf))
    }

    @objc private func dismissSelf() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doodles.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! DoodleImageCell
        cell.loadImage(from: doodles[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 50)
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(save)
    }

    // MARK: - Menu Controller

    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleMenuController(_:)))
        self.collectionView?.addGestureRecognizer(longPressGesture)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    @objc private func handleMenuController(_ gesture: UILongPressGestureRecognizer) {
        let touchPoint = gesture.location(in: self.collectionView)
        if let indexPath = self.collectionView?.indexPathForItem(at: touchPoint),
            let cell = self.collectionView?.cellForItem(at: indexPath) as? DoodleImageCell {
            setupMenu(for: cell)
            selectedDoodle = doodles[indexPath.row]
        }
    }

    private func setupMenu(for cell: DoodleImageCell) {
        let saveMenuItem = UIMenuItem(title: "Save", action: #selector(save))
        UIMenuController.shared.setTargetRect(CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height),
                                              in: cell.contentView)
        UIMenuController.shared.menuItems = [saveMenuItem]
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }

    private var selectedDoodle: Doodle!

    @objc private func save() {
        GoogleService.shared.fetchImage(from: selectedDoodle) { (image) in
            guard let image = image else { return }
            PhotoService.shared.save(.image(image), { (isSaved) -> (Void) in
                isSaved ? self.showOKAlert("사진 앨범에 저장되었습니다.", nil) : nil
            })
        }
    }

}
