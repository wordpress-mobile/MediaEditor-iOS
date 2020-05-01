import UIKit
import AVFoundation
import PencilKit

/// Wrapper view that contains an image view and a PencilKit canvas to allow
/// drawing on top of the image.
///
@available(iOS 13.0, *)
class MediaEditorAnnotationView: UIView {

    private let imageView = UIImageView()
    private let canvasView = PKCanvasView()

    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!

    var image: UIImage? {
        set {
            imageView.image = newValue
        }
        get {
            return renderedImage
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.NSUndoManagerCheckpoint,
                                                  object: canvasView.undoManager)
    }

    private func commonInit() {
        configureImageView()
        configureCanvasView()
    }

    private func configureImageView() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func configureCanvasView() {
        addSubview(canvasView)

        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false

        // Ensure ink remains the same color regardless of light / dark mode
        canvasView.overrideUserInterfaceStyle = .light

        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSUndoManagerCheckpoint, object: canvasView.undoManager, queue: nil) { [weak self] _ in
            self?.updateUndoRedoButtons()
        }
    }

    private func updateUndoRedoButtons() {
        undoButton.isEnabled = canvasView.undoManager?.canUndo ?? false
        redoButton.isEnabled = canvasView.undoManager?.canRedo ?? false
    }

    // MARK: - View Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        canvasView.frame = calculateCanvasFrame()
    }

    private func calculateCanvasFrame() -> CGRect {
        guard let image = imageView.image,
            imageView.contentMode == .scaleAspectFit,
            image.size.width > 0 && image.size.height > 0 else {
                return bounds
        }

        let size = AVMakeRect(aspectRatio: image.size, insideRect: bounds)

        let x = (bounds.width - size.width) * 0.5
        let y = (bounds.height - size.height) * 0.5

        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }

    // MARK: - Public methods

    /// Displays the system tool picker in the specified window
    ///
    func showTools(in window: UIWindow) {
        if let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            toolPicker.addObserver(self)

            canvasView.becomeFirstResponder()
            updateLayout(for: toolPicker)
        }
    }

    /// Renders the initial image with the canvas's image overlaid on top
    /// into a single UIImage instance.
    ///
    private var renderedImage: UIImage? {
        guard let imageViewImage = imageView.image else {
            return nil
        }

        guard canvasView.bounds != .zero else {
            return imageViewImage
        }

        // Check we actually have some changes
        if let undoManager = canvasView.undoManager,
            undoManager.canUndo == false {
            return imageViewImage
        }

        let targetSize = imageViewImage.size

        let canvasViewImage = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: .default())
        let renderedImage = renderer.image { context in
            imageViewImage.draw(at: .zero)
            canvasViewImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return renderedImage
    }
}

// Note: Code in this extension reused from WWDC 2019 PencilKit example
//
@available(iOS 13.0, *)
extension MediaEditorAnnotationView: PKToolPickerObserver {
    // MARK: Tool Picker Observer

    /// Delegate method: Note that the tool picker has changed which part of the canvas view
    /// it obscures, if any.
    internal func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }

    /// Delegate method: Note that the tool picker has become visible or hidden.
    internal func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }

    /// Helper method to adjust the canvas view size when the tool picker changes which part
    /// of the canvas view it obscures, if any.
    ///
    /// Note that the tool picker floats over the canvas in regular size classes, but docks to
    /// the canvas in compact size classes, occupying a part of the screen that the canvas
    /// could otherwise use.
    fileprivate func updateLayout(for toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: self)

        if obscuredFrame.isNull {
            canvasView.contentInset = .zero
            undoButton.isHidden = true
            redoButton.isHidden = true
        } else {
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bounds.maxY - obscuredFrame.minY, right: 0)
            undoButton.isHidden = false
            redoButton.isHidden = false
        }

        canvasView.scrollIndicatorInsets = canvasView.contentInset
    }
}
