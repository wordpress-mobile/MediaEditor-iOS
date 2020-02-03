import UIKit

/**
 An object that manages editing media.

 You can start the MediaEditor with a single or an array of `UIImage` or `PHAsset` out of the box.
 Also, you can give any other object as long it conforms to the `AsyncImage` protocol.

 # UINavigationController
 Since each capability has it's own (or is a) View Controller, the Media Editor is also a Navigation Controller that presents them.
 And by being a ViewController, this allows it to be custom presented.
*/
open class MediaEditor: UINavigationController {
    /// The capabilities do be displayed in the Media Editor. You can add your own capability here.
    public static var capabilities: [MediaEditorCapability.Type] = [MediaEditorFilters.self, MediaEditorCropZoomRotate.self]

    /// The ViewController that shows thumbnails and capabilities
    var hub: MediaEditorHub = {
        let hub: MediaEditorHub = MediaEditorHub.initialize()
        hub.loadViewIfNeeded()
        return hub
    }()

    /// Callback that is called after the user finishes editing images. It gives all the images and the operations made.
    public var onFinishEditing: (([AsyncImage], [MediaEditorOperation]) -> ())?

    /// Callback called when the user exists
    public var onCancel: (() -> ())?

    /// A dictionary that returns all the available images UIImages. The key is the index of the image.
    public private(set) var images: [Int: UIImage] = [:]

    /// All the async images that are being displayed.
    public private(set) var asyncImages: [AsyncImage] = []

    /// Indexes of the images that were edited.
    public private(set) var editedImagesIndexes: Set<Int> = []

    /// The actions that were made in this session.
    public private(set) var actions: [MediaEditorOperation] = []

    /// Returns which MediaEditorCapability is being displayed.
    public private(set) var currentCapability: MediaEditorCapability?

    /// A Boolean value indicating whether the Media Editor is being used to edit plain UIImages
    public private(set) var isEditingPlainUIImages = false

     /// The index of the last capability tapped.
    public private(set) var lastTappedCapabilityIndex = 0

    /// A Boolean value indicating whether the Media Editor has just a single image and single capability.
    public var isSingleImageAndCapability: Bool {
        return ((asyncImages.count == 1) || (images.count == 1 && asyncImages.count == 0)) && Self.capabilities.count == 1
    }

    /// The index of the image that is currently being displayed or being edited.
    public var selectedImageIndex: Int {
        return hub.selectedThumbIndex
    }

    /// A Dictionary of the styles to be applied in the Media Editor
    open var styles: MediaEditorStyles = [:] {
        didSet {
            currentCapability?.apply(styles: styles)
            hub.apply(styles: styles)
        }
    }

    /// A initializer for a single UIImage.
    ///
    /// Use this method to initialize the Media Editor with a single plain UIImage.
    /// - Parameter image: `UIImage` to be displayed
    ///
    public init(_ image: UIImage) {
        self.images = [0: image]
        super.init(nibName: nil, bundle: nil)
        viewControllers = [hub]
        setup()
    }

    /// A initializer for an array of UIImage.
    ///
    /// Use this method to initialize the Media Editor with multiple UIImage.
    /// - Parameter images: `[UIImage]` to be displayed
    ///
    public init(_ images: [UIImage]) {
        self.images = images.enumerated().reduce(into: [:]) { $0[$1.offset] = $1.element }
        super.init(nibName: nil, bundle: nil)
        viewControllers = [hub]
        setup()
    }

    /// A initializer for a single AsyncImage.
    ///
    /// Use this method to initialize the Media Editor with a single AsyncImage.
    /// - Parameter asyncImage: `AsyncImage` to be displayed
    /// - Note: This method accepts PHAsset out of the box
    ///
    public init(_ asyncImage: AsyncImage) {
        self.asyncImages.append(asyncImage)
        super.init(nibName: nil, bundle: nil)
        viewControllers = [hub]
        setup()
    }

    /// A initializer for an array of [AsyncImage].
    ///
    /// Use this method to initialize the Media Editor with multiple AsyncImage.
    /// - Parameter asyncImages: `[AsyncImage]` to be displayed
    /// - Note: This method accepts [PHAsset] out of the box
    ///
    public init(_ asyncImages: [AsyncImage]) {
        self.asyncImages = asyncImages
        super.init(nibName: nil, bundle: nil)
        viewControllers = [hub]
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.isEnabled = false
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentCapability = nil
    }

    public func edit(from viewController: UIViewController? = nil, onFinishEditing: @escaping ([AsyncImage], [MediaEditorOperation]) -> (), onCancel: (() -> ())? = nil) {
        self.onFinishEditing = onFinishEditing
        self.onCancel = onCancel
        viewController?.present(self, animated: true)
    }

    private func setup() {
        setupModalStyle()
        setupHub()
        setupForAsync()
        presentIfSingleImageAndCapability()
    }

    private func setupModalStyle() {
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .fullScreen
        navigationBar.isHidden = true
    }

    private func setupHub() {
        hub.delegate = self

        hub.onCancel = { [weak self] in
            self?.cancel()
        }

        hub.onDone = { [weak self] in
            self?.done()
        }

        hub.apply(styles: styles)

        hub.availableThumbs = images

        hub.numberOfThumbs = max(images.count, asyncImages.count)

        hub.capabilities = Self.capabilities.reduce(into: []) { $0.append(($1.name, $1.icon)) }

        hub.apply(styles: styles)
    }

    private func setupForAsync() {
        isEditingPlainUIImages = images.count > 0
        
        asyncImages.enumerated().forEach { offset, asyncImage in
            if let thumb = asyncImage.thumb {
                thumbnailAvailable(thumb, offset: offset)
            } else {
                asyncImage.thumbnail(finishedRetrievingThumbnail: { [weak self] thumb in
                    self?.thumbnailAvailable(thumb, offset: offset)
                })
            }
        }

        if isSingleImageAndCapability {
            hub.disableDoneButton()
            capabilityTapped(0)
        }
    }

    private func presentIfSingleImageAndCapability() {
        guard isSingleImageAndCapability, let image = images[0], let capabilityEntity = Self.capabilities.first else {
            return
        }

        present(capability: capabilityEntity, with: image)
    }

    private func cancel() {
        if currentCapability == nil {
            cancelPendingAsyncImagesAndDismiss()
        } else if isSingleImageAndCapability {
            cancelPendingAsyncImagesAndDismiss()
        } else {
            dismissCapability()
        }
    }

    private func done() {
        let outputImages = isEditingPlainUIImages ? mapEditedImages() : mapEditedAsyncImages()
        onFinishEditing?(outputImages, actions)
        dismiss(animated: true)
    }

    /*
     Map the images hash to an images array preserving the original order,
     since Hashes are non-order preserving.
     */
    private func mapEditedImages() -> [UIImage] {
        return images.enumerated().compactMap { index, _ in images[index] }
    }

    private func mapEditedAsyncImages() -> [AsyncImage] {
        var editedImages: [AsyncImage] = []

        for (index, var asyncImage) in asyncImages.enumerated() {
            if editedImagesIndexes.contains(index), let editedImage = images[index] {
                asyncImage.isEdited = true
                asyncImage.editedImage = editedImage
            }
            editedImages.append(asyncImage)
        }

        return editedImages
    }

    private func cancelPendingAsyncImagesAndDismiss() {
        onCancel?()
        asyncImages.forEach { $0.cancel() }
        dismiss(animated: true)
    }

    private func present(capability capabilityEntity: MediaEditorCapability.Type, with image: UIImage) {
        prepareTransition()

        let capability = capabilityEntity.init(
            image,
            onFinishEditing: { [weak self] image, actions in
                self?.finishEditing(image: image, actions: actions)
            },
            onCancel: { [weak self] in
                self?.cancel()
        }
        )
        capability.apply(styles: styles)
        currentCapability = capability

        pushViewController(capability.viewController, animated: false)
    }

    private func finishEditing(image: UIImage, actions: [MediaEditorOperation]) {
        images[selectedImageIndex] = image

        self.actions.append(contentsOf: actions)

        if !actions.isEmpty {
            editedImagesIndexes.insert(selectedImageIndex)
        }

        if isSingleImageAndCapability {
            done()
            dismiss(animated: true)
        } else {
            hub.show(image: image, at: selectedImageIndex)
            dismissCapability()
        }
    }

    private func dismissCapability() {
        prepareTransition()
        popViewController(animated: false)
        currentCapability = nil
    }

    private func prepareTransition() {
        let transition: CATransition = CATransition()
        transition.duration = Constants.transitionDuration
        transition.type = .fade
        view.layer.add(transition, forKey: nil)
    }

    private func thumbnailAvailable(_ thumb: UIImage?, offset: Int) {
        guard let thumb = thumb else {
            return
        }

        DispatchQueue.main.async {
            self.hub.show(thumb: thumb, at: offset)
        }
    }

    private func fullImageAvailable(_ image: UIImage?, offset: Int) {
        guard let image = image else {
            DispatchQueue.main.async {
                self.hub.failedToLoad(at: offset)
            }
            return
        }

        self.images[offset] = image

        DispatchQueue.main.async {
            self.hub.hideActivityIndicator()

            self.hub.enableDoneButton()

            self.presentIfSingleImageAndCapability()

            self.hub.show(image: image, at: offset)
        }
    }

    private enum Constants {
        static let transitionDuration = 0.3
    }
}

extension MediaEditor: MediaEditorHubDelegate {
    func capabilityTapped(_ index: Int) {
        lastTappedCapabilityIndex = index

        if let image = images[selectedImageIndex] {
            present(capability: Self.capabilities[index], with: image)
        } else {
            let offset = selectedImageIndex
            hub.loadingImage(at: offset)
            asyncImages[selectedImageIndex].full(finishedRetrievingFullImage: { [weak self] image in
                DispatchQueue.main.async {

                    self?.hub.loadedImage(at: offset)

                    self?.fullImageAvailable(image, offset: offset)

                    if self?.selectedImageIndex == offset, let image = image {
                        self?.present(capability: Self.capabilities[index], with: image)
                    }

                }
            })
        }
    }

    func retry() {
        capabilityTapped(lastTappedCapabilityIndex)
    }
}
