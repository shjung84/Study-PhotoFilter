//
//  PhotoViewController.swift
//  Study-PhotoFilter
//
//  Created by SH.Jung on 2022/02/15.
//

import UIKit
import Photos

class PhotoViewController: UIViewController {
	
	// MARK: - Properties
	var asset: PHAsset?
	var assetCollection: PHAssetCollection?
	
	// MARK: IBOutlets
	@IBOutlet weak var assetImageView: UIImageView!
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var resetFilterButton: UIBarButtonItem!
	@IBOutlet weak var saveImageButton: UIBarButtonItem!
	
	// MARK: Privates
	private var originalImage: UIImage?
	private let cachingImageManager: PHCachingImageManager = PHCachingImageManager()
	private let imageFilteringQueue: OperationQueue = OperationQueue()
	private lazy var filterCollectionViewController: FilterCollectionViewController? = {
		return self.children.first as? FilterCollectionViewController
	}()
}

extension PhotoViewController {
	private func changeImageViewMode() {
		guard let isNavigationBarHidden: Bool = self.navigationController?.isNavigationBarHidden
			else { return }
		
		self.navigationController?.isNavigationBarHidden = !isNavigationBarHidden
		self.view.backgroundColor = isNavigationBarHidden ? UIColor.white : UIColor.black
		self.containerView.isHidden = !self.containerView.isHidden
	}
}

extension PhotoViewController {
	private func alertSaveResult(success: Bool, error: Error?) {
		let alert: UIAlertController
		let alertMessage: String
		
		if success {
			alertMessage = "카메라 롤에 저장하였습니다."
		} else {
			alertMessage = "사진저장에 실패했습니다. " + (error?.localizedDescription ?? "")
		}
		
		alert = UIAlertController(title: "알림", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
		
		alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
		
		OperationQueue.main.addOperation {
			self.present(alert, animated: true, completion: nil)
		}
	}
}

extension PhotoViewController {
	
	// MARK: - IBAction
	@IBAction func tapAssetImage(_ sender: UITapGestureRecognizer) {
		self.changeImageViewMode()
	}
	
	@IBAction func touchUpResetFilterButton(_ sender: UIBarButtonItem) {
		self.assetImageView.image = self.originalImage
		sender.isEnabled = false
		self.saveImageButton.isEnabled = false
	}
	
	@IBAction func touchUpSaveImageButton(_ sender: UIBarButtonItem) {
		
		guard let filteredImage: UIImage = self.assetImageView.image else {
			return
		}
		
		PHPhotoLibrary.shared().performChanges({
			PHAssetChangeRequest.creationRequestForAsset(from: filteredImage)
		}, completionHandler: self.alertSaveResult(success:error:))
	}
}

// MARK: - UIScrollViewControllerDelegate
extension PhotoViewController: UIScrollViewDelegate {
	// 스크롤뷰가 확대를 해야되는 뷰를 알려줌
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.assetImageView
	}
	
	// 줌 시작할 때 할일을 알려줌
	func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
		if self.navigationController?.isNavigationBarHidden == false {
			self.changeImageViewMode()
		}
	}
}

// MARK: - PHPhotoLibraryChangeObserver
extension PhotoViewController: PHPhotoLibraryChangeObserver {
	func photoLibraryDidChange(_ changeInstance: PHChange) {
		guard let asset: PHAsset = self.asset else {
			return
		}
		guard let changes = changeInstance.changeDetails(for: asset) else { return }
		
		DispatchQueue.main.async {
			if changes.objectWasDeleted {
				self.navigationController?.popViewController(animated: true)
			} else if let after = changes.objectAfterChanges {
				self.asset = after
			}
		}
	}
}

extension PhotoViewController {
	private func adjustFilter(name filterName: String) {
		imageFilteringQueue.addOperation {
			guard let inputImage: UIImage = self.originalImage else { return }
			guard let filter: CIFilter = CIFilter(name: filterName) else { return }
			guard let ciImage: CIImage = CIImage(image: inputImage) else { return }
			filter.setValue(ciImage, forKey: kCIInputImageKey)
			guard let outputImage: CIImage = filter.outputImage else { return }
			let context: CIContext = CIContext(options: nil)
			guard let cgImage: CGImage = context.createCGImage(outputImage,
															   from: outputImage.extent) else { return }
			let filteredImage: UIImage = UIImage(cgImage: cgImage)
			
			OperationQueue.main.addOperation {
				self.assetImageView.image = filteredImage
				self.resetFilterButton.isEnabled = true
				self.saveImageButton.isEnabled = true
			}
		}
	}
}

extension PhotoViewController {
	@objc private func didRecieveUserDidSelectFilterNotification(_ noti: Notification) {
		guard let userInfo = noti.userInfo else { return }
		guard let filterName: String = userInfo[userInfoKeyFilterName] as? String else { return }
		self.adjustFilter(name: filterName)
	}
}
