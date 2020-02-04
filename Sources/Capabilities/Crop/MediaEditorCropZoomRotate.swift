import UIKit
import TOCropViewController

typealias MediaEditorCropZoomRotate = TOCropViewController

extension TOCropViewController: MediaEditorCapability {
    public static var name = "Crop, Zoom, Rotate"

    public static var icon = UIImage(named: "gridicons-crop", in: .mediaEditor, compatibleWith: nil)!

    public static func initialize(_ image: UIImage, onFinishEditing: @escaping (UIImage, [MediaEditorOperation]) -> (), onCancel: @escaping () -> ()) -> CapabilityViewController {
        let cropViewController = TOCropViewController(image: image)

        weak var toCrop = cropViewController

        cropViewController.hidesNavigationBar = false

        cropViewController.onDidCropToRect = { image, _, _ in
            onFinishEditing(image, toCrop?.actions ?? [])
        }

        cropViewController.onDidFinishCancelled = { _ in
            onCancel()
        }

        return cropViewController
    }

    public func apply(styles: MediaEditorStyles) {
        if let doneLabel = styles[.doneLabel] as? String {
            toolbar.doneTextButton.setTitle(doneLabel, for: .normal)
        }

        if let cancelLabel = styles[.cancelLabel] as? String {
            toolbar.cancelTextButton.setTitle(cancelLabel, for: .normal)
        }

        if let cancelColor = styles[.cancelColor] as? UIColor {
            toolbar.cancelTextButton.tintColor = cancelColor
            toolbar.cancelIconButton.tintColor = cancelColor
        }

        if let resetIcon = styles[.resetIcon] as? UIImage {
            toolbar.resetButton.setImage(resetIcon, for: .normal)
        }

        if let doneIcon = styles[.doneIcon] as? UIImage {
            toolbar.doneIconButton.setImage(doneIcon, for: .normal)
        }

        if let cancelIcon = styles[.cancelIcon] as? UIImage {
            toolbar.cancelIconButton.setImage(cancelIcon, for: .normal)
        }

        if let rotateClockwiseIcon = styles[.rotateClockwiseIcon] as? UIImage {
            toolbar.rotateClockwiseButton?.setImage(rotateClockwiseIcon, for: .normal)
        }

        if let rotateCounterclockwiseButtonHidden = styles[.rotateCounterclockwiseButtonHidden] as? Bool {
            toolbar.rotateCounterclockwiseButtonHidden = rotateCounterclockwiseButtonHidden
        }
    }


}

//class MediaEditorCropZoomRotate: NSObject, MediaEditorCapability {
//    static var name = "Crop, Zoom, Rotate"
//
//    static var icon = UIImage(named: "gridicons-crop", in: .mediaEditor, compatibleWith: nil)!
//
//    var image: UIImage
//
//    var onFinishEditing: (UIImage, [MediaEditorOperation]) -> ()
//
//    var onCancel: (() -> ())
//
//    lazy var viewController: UIViewController = {
//        let cropViewController = TOCropViewController(image: image)
//
//        cropViewController.hidesNavigationBar = false
//
//        cropViewController.delegate = self
//
//        return cropViewController
//    }()
//
//    required init(_ image: UIImage,
//                  onFinishEditing: @escaping (UIImage, [MediaEditorOperation]) -> (),
//                  onCancel: @escaping () -> ()) {
//        self.image = image
//        self.onFinishEditing = onFinishEditing
//        self.onCancel = onCancel
//    }
//
//    func apply(styles: MediaEditorStyles) {
//        guard let viewController = viewController as? TOCropViewController else {
//            return
//        }
//
//        if let doneLabel = styles[.doneLabel] as? String {
//            viewController.toolbar.doneTextButton.setTitle(doneLabel, for: .normal)
//        }
//
//        if let cancelLabel = styles[.cancelLabel] as? String {
//            viewController.toolbar.cancelTextButton.setTitle(cancelLabel, for: .normal)
//        }
//
//        if let cancelColor = styles[.cancelColor] as? UIColor {
//            viewController.toolbar.cancelTextButton.tintColor = cancelColor
//            viewController.toolbar.cancelIconButton.tintColor = cancelColor
//        }
//
//        if let resetIcon = styles[.resetIcon] as? UIImage {
//            viewController.toolbar.resetButton.setImage(resetIcon, for: .normal)
//        }
//
//        if let doneIcon = styles[.doneIcon] as? UIImage {
//            viewController.toolbar.doneIconButton.setImage(doneIcon, for: .normal)
//        }
//
//        if let cancelIcon = styles[.cancelIcon] as? UIImage {
//            viewController.toolbar.cancelIconButton.setImage(cancelIcon, for: .normal)
//        }
//
//        if let rotateClockwiseIcon = styles[.rotateClockwiseIcon] as? UIImage {
//            viewController.toolbar.rotateClockwiseButton?.setImage(rotateClockwiseIcon, for: .normal)
//        }
//
//        if let rotateCounterclockwiseButtonHidden = styles[.rotateCounterclockwiseButtonHidden] as? Bool {
//            viewController.toolbar.rotateCounterclockwiseButtonHidden = rotateCounterclockwiseButtonHidden
//        }
//    }
//}
//
//extension MediaEditorCropZoomRotate: TOCropViewControllerDelegate {
//    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
//        onCancel()
//    }
//
//    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
//        onFinishEditing(image, cropViewController.actions)
//    }
//}
