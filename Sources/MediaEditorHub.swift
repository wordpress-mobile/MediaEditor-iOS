import UIKit

public class MediaEditorHub: UIViewController {

    @IBOutlet public weak var doneButton: UIButton!
    @IBOutlet public weak var cancelIconButton: UIButton!
    @IBOutlet public weak var activityIndicatorView: UIVisualEffectView!
    @IBOutlet public weak var activityIndicatorLabel: UILabel!
    @IBOutlet public weak var mainStackView: UIStackView!
    @IBOutlet public weak var thumbsCollectionView: UICollectionView!
    @IBOutlet public weak var imagesCollectionView: UICollectionView!
    @IBOutlet public weak var capabilitiesCollectionView: UICollectionView!
    @IBOutlet public weak var toolbarHeight: NSLayoutConstraint!

    weak var delegate: MediaEditorHubDelegate?

    var onCancel: (() -> ())?

    var onDone: (() -> ())?

    var numberOfThumbs = 0 {
        didSet {
            setupToolbar()
        }
    }

    var capabilities: [(String, UIImage)] = [] {
        didSet {
            setupCapabilities()
        }
    }

    var availableThumbs: [Int: UIImage] = [:]

    var availableImages: [Int: UIImage] = [:]

    private(set) var selectedThumbIndex = 0 {
        didSet {
            highlightSelectedThumb(current: selectedThumbIndex, before: oldValue)
            showOrHideActivityIndicatorAndCapabilities()
        }
    }

    private(set) var isUserScrolling = false

    private var selectedColor: UIColor?

    private var indexesOfImagesBeingLoaded: [Int] = []

    private var isSingleImage: Bool {
        return numberOfThumbs == 1
    }

    private var isSingleCapabilityAndImage: Bool {
        isSingleImage && capabilities.count == 1
    }

    private var styles: MediaEditorStyles?

    private var hubDidAppeared = false

    override public func viewDidLoad() {
        super.viewDidLoad()
        thumbsCollectionView.dataSource = self
        thumbsCollectionView.delegate = self
        capabilitiesCollectionView.dataSource = self
        capabilitiesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
    }

    /// Select the last asset every time the view layout it's subviews until the hub appears.
    /// This is needed because of some layout recalculations that happens.
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !hubDidAppeared {
            selectLastAsset()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hubDidAppeared = true
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadImagesAndReposition()
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.reloadImagesAndReposition()
        })
    }

    @IBAction func cancel(_ sender: Any) {
        onCancel?()
    }

    @IBAction func done(_ sender: Any) {
        onDone?()
    }

    func show(image: UIImage, at index: Int) {
        availableImages[index] = image
        availableThumbs[index] = image

        let imageCell = imagesCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? MediaEditorImageCell
        imageCell?.errorView.isHidden = true
        imageCell?.imageView.image = image

        let cell = thumbsCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? MediaEditorThumbCell
        cell?.thumbImageView.image = image

        showOrHideActivityIndicatorAndCapabilities()
    }

    func show(thumb: UIImage, at index: Int) {
        availableThumbs[index] = thumb

        let cell = thumbsCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? MediaEditorThumbCell
        cell?.thumbImageView.image = thumb

        let imageCell = imagesCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? MediaEditorImageCell
        imageCell?.imageView.image = availableImages[index] ?? thumb

        showOrHideActivityIndicatorAndCapabilities()
    }

    func apply(styles: MediaEditorStyles) {
        loadViewIfNeeded()

        self.styles = styles

        if let doneLabel = (styles[.insertLabel] ?? styles[.doneLabel]) as? String {
            doneButton.setTitle(String(format: doneLabel, "\(numberOfThumbs)"), for: .normal)
        }

        if let cancelColor = styles[.cancelColor] as? UIColor {
            cancelIconButton.tintColor = cancelColor
        }

        if let doneColor = styles[.doneColor] as? UIColor {
            doneButton.tintColor = doneColor
        }

        if let cancelIcon = styles[.cancelIcon] as? UIImage {
            cancelIconButton.setImage(cancelIcon, for: .normal)
        }

        if let loadingLabel = styles[.loadingLabel] as? String {
            activityIndicatorLabel.text = loadingLabel
        }

        if let color = styles[.selectedColor] as? UIColor {
            selectedColor = color
        }
    }

    func showActivityIndicator() {
        activityIndicatorView.isHidden = false
    }

    func hideActivityIndicator() {
        activityIndicatorView.isHidden = true
    }

    func disableDoneButton() {
        doneButton.isEnabled = false
    }

    func enableDoneButton() {
        doneButton.isEnabled = true
    }

    func loadingImage(at index: Int) {
        indexesOfImagesBeingLoaded.append(index)
        showOrHideActivityIndicatorAndCapabilities()
    }

    func loadedImage(at index: Int) {
        indexesOfImagesBeingLoaded = indexesOfImagesBeingLoaded.filter { $0 != index }
        showOrHideActivityIndicatorAndCapabilities()
    }

    func failedToLoad(at index: Int) {
        let cell = imagesCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? MediaEditorImageCell
        cell?.errorView.isHidden = false
        hideActivityIndicator()
    }

    private func reloadImagesAndReposition() {
        view.layoutIfNeeded()
        thumbsCollectionView.reloadData()
        imagesCollectionView.reloadData()
        thumbsCollectionView.layoutIfNeeded()
        imagesCollectionView.layoutIfNeeded()
        thumbsCollectionView.selectItem(at: IndexPath(row: selectedThumbIndex, section: 0), animated: false, scrollPosition: .right)
        imagesCollectionView.scrollToItem(at: IndexPath(row: selectedThumbIndex, section: 0), at: .right, animated: false)
    }

    private func setupToolbar() {
        toolbarHeight.constant = isSingleImage ? Constants.toolbarHeight : Constants.thumbHeight
        thumbsCollectionView.isHidden = isSingleImage ? true : false
    }

    private func highlightSelectedThumb(current: Int, before: Int) {
        let current = thumbsCollectionView.cellForItem(at: IndexPath(row: current, section: 0)) as? MediaEditorThumbCell
        let before = thumbsCollectionView.cellForItem(at: IndexPath(row: before, section: 0)) as? MediaEditorThumbCell
        before?.hideBorder()
        current?.showBorder()
    }

    private func showOrHideActivityIndicatorAndCapabilities() {
        let imageAvailable = availableThumbs[selectedThumbIndex] ?? availableImages[selectedThumbIndex]

        let isBeingLoaded = imageAvailable == nil || indexesOfImagesBeingLoaded.contains(selectedThumbIndex)

        if isBeingLoaded {
            showActivityIndicator()
            disableCapabilities()
        } else {
            hideActivityIndicator()
            enableCapabilities()
        }
    }

    private func disableCapabilities() {
        capabilitiesCollectionView.isUserInteractionEnabled = false
        capabilitiesCollectionView.layer.opacity = 0.5
    }

    private func enableCapabilities() {
        capabilitiesCollectionView.isUserInteractionEnabled = true
        capabilitiesCollectionView.layer.opacity = 1
    }

    private func setupCapabilities() {
        capabilitiesCollectionView.isHidden = isSingleCapabilityAndImage ? true : false
        capabilitiesCollectionView.reloadData()
    }

    private func selectLastAsset() {
        DispatchQueue.main.async {
            self.selectedThumbIndex = self.numberOfThumbs - 1
            self.imagesCollectionView.scrollToItem(at: IndexPath(row: self.selectedThumbIndex, section: 0), at: .right, animated: false)
            self.thumbsCollectionView.scrollToItem(at: IndexPath(row: self.selectedThumbIndex, section: 0), at: .right, animated: false)
        }
    }

    static func initialize() -> MediaEditorHub {
        return UIStoryboard(name: "MediaEditorHub", bundle: Bundle(for: MediaEditorHub.self)).instantiateViewController(withIdentifier: "hubViewController") as! MediaEditorHub
    }

    private enum Constants {
        static var thumbCellIdentifier = "thumbCell"
        static var imageCellIdentifier = "imageCell"
        static var capabCellIdentifier = "capabilityCell"
        static var thumbHeight: CGFloat = 64
        static var toolbarHeight: CGFloat = 44
    }
}

// MARK: - UICollectionViewDataSource

extension MediaEditorHub: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == capabilitiesCollectionView ? capabilities.count : numberOfThumbs
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == thumbsCollectionView {
            return cellForThumbsCollectionView(cellForItemAt: indexPath)
        } else if collectionView == imagesCollectionView {
            return cellForImagesCollectionView(cellForItemAt: indexPath)
        }

        return cellForCapabilityCollectionView(cellForItemAt: indexPath)
    }

    private func cellForThumbsCollectionView(cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = thumbsCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.thumbCellIdentifier, for: indexPath)

        if let thumbCell = cell as? MediaEditorThumbCell {
            thumbCell.thumbImageView.image = availableThumbs[indexPath.row]
            indexPath.row == selectedThumbIndex ? thumbCell.showBorder(color: selectedColor) : thumbCell.hideBorder()
        }

        return cell
    }

    private func cellForImagesCollectionView(cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.imageCellIdentifier, for: indexPath)

        if let imageCell = cell as? MediaEditorImageCell {
            imageCell.imageView.image = availableImages[indexPath.row] ?? availableThumbs[indexPath.row]
            imageCell.errorView.isHidden = true
            imageCell.apply(styles: styles)
            imageCell.delegate = delegate
        }

        showOrHideActivityIndicatorAndCapabilities()

        return cell
    }

    private func cellForCapabilityCollectionView(cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = capabilitiesCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.capabCellIdentifier, for: indexPath)

        if let capabilityCell = cell as? MediaEditorCapabilityCell {
            capabilityCell.configure(capabilities[indexPath.row])
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MediaEditorHub: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == imagesCollectionView {
            return CGSize(width: imagesCollectionView.frame.width, height: imagesCollectionView.frame.height)
        } else if collectionView == thumbsCollectionView {
            return numberOfThumbs > 1 ? CGSize(width: Constants.thumbHeight, height: Constants.thumbHeight) : .zero
        } else {
            return CGSize(width: Constants.toolbarHeight, height: Constants.toolbarHeight)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension MediaEditorHub: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == thumbsCollectionView {
            selectedThumbIndex = indexPath.row
            imagesCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        } else if collectionView == capabilitiesCollectionView {
            delegate?.capabilityTapped(indexPath.row)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == imagesCollectionView, isUserScrolling else {
            return
        }

        let imageIndexBasedOnScroll = Int(round(scrollView.bounds.origin.x / imagesCollectionView.frame.width))

        thumbsCollectionView.selectItem(at: IndexPath(row: imageIndexBasedOnScroll, section: 0), animated: true, scrollPosition: .right)
        selectedThumbIndex = imageIndexBasedOnScroll
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView == imagesCollectionView else {
            return
        }

        isUserScrolling = true
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView == imagesCollectionView else {
            return
        }

        isUserScrolling = false
    }
}

protocol MediaEditorHubDelegate: AnyObject {
    func capabilityTapped(_ index: Int)
    func retry()
}
