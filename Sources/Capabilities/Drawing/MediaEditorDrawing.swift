import UIKit
import PencilKit

@available(iOS 13.0, *)
class MediaEditorDrawing: UIViewController {
    
    @IBOutlet weak var annotationView: MediaEditorAnnotationView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!

    var image: UIImage!

    let context = MediaEditor.ciContext

    var onFinishEditing: ((UIImage, [MediaEditorOperation]) -> ())?

    var onCancel: (() -> ())?

    static func initialize() -> MediaEditorDrawing {
        return UIStoryboard(
            name: "MediaEditorDrawing",
            bundle: Bundle(for: MediaEditorDrawing.self)
        ).instantiateViewController(withIdentifier: "drawingViewController") as! MediaEditorDrawing
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting images in code to avoid an 'iOS 13 only' warning in the storyboard
        undoButton.setImage(UIImage(systemName: "arrow.uturn.left.circle"), for: .normal)
        redoButton.setImage(UIImage(systemName: "arrow.uturn.right.circle"), for: .normal)
        undoButton.setTitle(nil, for: .normal)
        redoButton.setTitle(nil, for: .normal)

        annotationView.undoObserver = self
        annotationView.image = image
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Based on Apple's sample PencilKit code from WWDC 2019: https://developer.apple.com/documentation/pencilkit/drawing_with_pencilkit
        // Set up the tool picker, using the window of our parent because our view has not
        // been added to a window yet.
        if let window = parent?.view.window {
            annotationView.showTools(in: window)
        }
    }

    // MARK: - Actions

    @IBAction func cancel(_ sender: Any) {
        onCancel?()
    }

    @IBAction func done(_ sender: Any) {
        guard let image = annotationView.image else {
            onCancel?()
            return
        }

        onFinishEditing?(image, [.other])
    }
}

@available(iOS 13.0, *)
extension MediaEditorDrawing: MediaEditorCapability {
    static var name = "Drawing"

    static var icon = UIImage(systemName: "pencil.tip.crop.circle")!

    static func initialize(_ image: UIImage, onFinishEditing: @escaping (UIImage, [MediaEditorOperation]) -> (), onCancel: @escaping () -> ()) -> CapabilityViewController {
        let viewController: MediaEditorDrawing = MediaEditorDrawing.initialize()
        viewController.onFinishEditing = onFinishEditing
        viewController.onCancel = onCancel
        viewController.image = image
        return viewController
    }

    func apply(styles: MediaEditorStyles) {
        if let doneLabel = styles[.doneLabel] as? String {
            doneButton.setTitle(doneLabel, for: .normal)
        }

        if let cancelLabel = styles[.cancelLabel] as? String {
            cancelButton.setTitle(cancelLabel, for: .normal)
        }

        if let cancelColor = styles[.cancelColor] as? UIColor {
            cancelButton.tintColor = cancelColor
            undoButton.tintColor = cancelColor
            redoButton.tintColor = cancelColor
        }

        if let undoIcon = styles[.undoIcon] as? UIImage {
            undoButton.setImage(undoIcon, for: .normal)
        }

        if let redoIcon = styles[.redoIcon] as? UIImage {
            redoButton.setImage(redoIcon, for: .normal)
        }
    }
}

@available(iOS 13.0, *)
extension MediaEditorDrawing: MediaEditorAnnotationViewUndoObserver {
    func mediaEditorAnnotationView(_ annotationView: MediaEditorAnnotationView, isHidingUndoControls: Bool) {
        let shouldShowCustomControls = !isHidingUndoControls

        undoButton.isHidden = shouldShowCustomControls
        redoButton.isHidden = shouldShowCustomControls
    }

    func mediaEditorAnnotationViewUndoStatusDidChange(_ view: MediaEditorAnnotationView) {
        undoButton.isEnabled = view.canUndo
        redoButton.isEnabled = view.canRedo
    }
}
