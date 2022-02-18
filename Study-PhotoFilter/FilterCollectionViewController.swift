//
//  FilterCollectionViewController.swift
//  Study-PhotoFilter
//
//  Created by SH.Jung on 2022/02/15.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class FilterCollectionViewController: UICollectionViewController {

	// MARK: - Properties
	var photoAsset: PHAsset? {
		didSet {
			guard let asset = photoAsset else { return }
			
			let manager: PHCachingImageManager = self.cachingImageManager
			manager.requestImage(for: asset,
									targetSize: CGSize(width:200, height:200),
									contentMode: PHImageContentMode.aspectFill,
									options: nil,
									resultHandler: {image, _ in
									self.thumbnailImage = image})
		}
	}
	
	// MARK: - Privates
	private var thumbnailImage: UIImage? {
		didSet {
			self.collectionView?.reloadSections(IndexSet(0...0))
		}
	}
	private let cellResultIdentifier: String = "filterCell"
	private let cachingImageManager: PHCachingImageManager = PHCachingImageManager()
	private let imageOperationQueue: OperationQueue = OperationQueue()
	private var filteredImageChache: [String:UIImage] = [:]
}

extension FilterCollectionViewController {
	private var imageFilterNames: [String] {
		return ["CIPhotoEffectChrome",
				"CIPhotoEffectFade",
				"CIPhotoEffectInstant",
				"CIPhotoEffectMono",
				"CIPhotoEffectNoir",
				"CIPhotoEffectProcess",
				"CIPhotoEffectTonal",
				"CIPhotoEffectTransfer",
				"CISepiaTone",
				"CIVignette"]
	}
}

extension FilterCollectionViewController {
	private func adjustFilter(name filterName: String,
							  for indexPath: IndexPath,
							  cell: FilterCollectionViewCell) {
		if let filteredImage: UIImage = self.filteredImageChache[filterName] {
			cell.imageView.image = filteredImage; return;
		}
		
		self.imageOperationQueue.addOperation {
			guard let inputImage: UIImage = self.thumbnailImage else { return }
			guard let filter: CIFilter = CIFilter(name: filterName) else { return }
			guard let ciImage: CIImage = CIImage(image: inputImage) else { return }
			filter.setValue(ciImage, forKey: kCIInputImageKey)
			guard let outputImage: CIImage = filter.outputImage else { return }
			let context: CIContext = CIContext(options: nil)
			guard let cgImage: CGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
			let filteredImage: UIImage = UIImage(cgImage: cgImage)
			self.filteredImageChache[filterName] = filteredImage
			
			OperationQueue.main.addOperation {
				let cellAtIndex: UICollectionViewCell? = self.collectionView?.cellForItem(at: indexPath)
				
				guard let cell: FilterCollectionViewCell = cellAtIndex as? FilterCollectionViewCell else { return }
				
				cell.imageView.image = filteredImage
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension FilterCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.imageFilterNames.count
	}
}

extension FilterCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell: FilterCollectionViewCell
		cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellResultIdentifier,
												  for: indexPath) as! FilterCollectionViewCell
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								 willDisplay cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {
		
		guard let cell: FilterCollectionViewCell = cell as? FilterCollectionViewCell else { return }
		
		let filterName: String = self.imageFilterNames[indexPath.item]
		
		cell.filterNameLabel.text = filterName
		
		self.adjustFilter(name: filterName, for: indexPath, cell: cell)
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FilterCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,
								 layout collectionViewLayout: UICollectionViewLayout,
								 sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		guard let flowLayout: UICollectionViewFlowLayout =
				self.collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }
		
		let viewSize: CGSize = self.view.frame.size
		let sectionInset: UIEdgeInsets = flowLayout.sectionInset
		let itemHeight: CGFloat = viewSize.height - sectionInset.top - sectionInset.bottom
		let itemSize = CGSize(width: itemHeight, height: itemHeight)
		
		return itemSize
	}
}

// MARK: - UICollectionViewDelegate
extension FilterCollectionViewController {
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let userInfo: [String: Any]
		userInfo = [userInfoKeyFilterName:self.imageFilterNames[indexPath.item]]
		
		NotificationCenter.default.post(name: userDidSelectFilterNotificationName,
										object: nil,
										userInfo: userInfo)
	}
}

