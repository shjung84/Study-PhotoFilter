//
//  FilterCollectionViewCell.swift
//  Study-PhotoFilter
//
//  Created by SH.Jung on 2022/02/15.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
	
	// MARK: - Properties
	override var isSelected: Bool {
		didSet {
			self.imageView.layer.borderWidth = isSelected ? 4.0 : 0
			self.imageView.alpha = isSelected ? 0.7 : 1.0
			super.isSelected = isSelected
		}
	}
	
	// MARK: IBOutlets
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var filterNameLabel: UILabel!
	
}

extension FilterCollectionViewCell {
	
	// MARK: - Life Cycle
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.filterNameLabel.layer.shadowColor = UIColor.black.cgColor
		filterNameLabel.layer.shadowRadius = 3.0
		filterNameLabel.layer.shadowOpacity = 1.0
		filterNameLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
		filterNameLabel.layer.masksToBounds = false
	}
	
	override func prepareForReuse() {
		self.imageView.image = nil
		self.imageView.layer.borderWidth = 0
		self.imageView.alpha = 1.0
		self.filterNameLabel.text = nil
	}
}
