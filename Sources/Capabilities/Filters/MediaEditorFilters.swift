//import UIKit
//
//class MediaEditorFilters: MediaEditorCapability {
//    static var name = "Filters"
//
//    static var icon = UIImage(named: "filters", in: .mediaEditor, compatibleWith: nil)!
//
//    var image: UIImage
//
//    var viewController: UIViewController
//
//    var onFinishEditing: (UIImage, [MediaEditorOperation]) -> ()
//
//    var onCancel: (() -> ())
//
//    required init(_ image: UIImage, onFinishEditing: @escaping (UIImage, [MediaEditorOperation]) -> (), onCancel: @escaping () -> ()) {
//        self.image = image
//        self.onFinishEditing = onFinishEditing
//        self.onCancel = onCancel
//        let viewController: MediaEditorFiltersViewController = MediaEditorFiltersViewController.initialize()
//        self.viewController = viewController
//        viewController.onFinishEditing = onFinishEditing
//        viewController.onCancel = onCancel
//        viewController.image = image
//    }
//
//    func apply(styles: MediaEditorStyles) {
//        guard let viewController = viewController as? MediaEditorFiltersViewController else {
//            return
//        }
//
//        if let doneLabel = styles[.doneLabel] as? String {
//            viewController.doneButton.setTitle(doneLabel, for: .normal)
//        }
//
//        if let cancelLabel = styles[.cancelLabel] as? String {
//            viewController.cancelButton.setTitle(cancelLabel, for: .normal)
//        }
//
//        if let cancelColor = styles[.cancelColor] as? UIColor {
//            viewController.cancelButton.tintColor = cancelColor
//        }
//    }
//}
