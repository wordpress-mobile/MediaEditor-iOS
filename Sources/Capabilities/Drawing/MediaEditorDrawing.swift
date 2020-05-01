import UIKit
import PencilKit

@available(iOS 13.0, *)
class MediaEditorDrawing: UIViewController, PKToolPickerObserver {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var canvasView: PKCanvasView!

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

        imageView.image = image

        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false

        // Ensure ink remains the same color regardless of light / dark mode
        canvasView.overrideUserInterfaceStyle = .light
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Based on Apple's sample PencilKit code from WWDC 2019
        // Set up the tool picker, using the window of our parent because our view has not
        // been added to a window yet.
        if let window = parent?.view.window, let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            toolPicker.addObserver(self)

            canvasView.becomeFirstResponder()
        }
    }

    // MARK: - Actions

    @IBAction func cancel(_ sender: Any) {
        onCancel?()
    }

    @IBAction func done(_ sender: Any) {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)

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
        }
    }
}
