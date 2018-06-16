//
//  DoodleImageCell.swift
//  PhotoApp
//
//  Created by 심 승민 on 2018. 6. 16..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit

class DoodleImageCell: UICollectionViewCell, Reusable {
    private let imageView = UIImageView()

    func loadImage(from doodle: Doodle) {
        GoogleService.shared.fetchImage(from: doodle) { (image) in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        configureCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configureCell() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }

}
