//
//  PhotoCollectionViewCell.swift
//  Study-PhotoFilter
//
//  Created by SH.Jung on 2022/02/15.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
	
	// MARK: - Properties
	@IBOutlet weak var imageView: UIImageView!
	
	// MARK: - Life Cycle
	override func prepareForReuse() {
		super.prepareForReuse()
		self.imageView.image = nil
	}
}
