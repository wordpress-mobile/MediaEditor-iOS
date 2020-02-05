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
