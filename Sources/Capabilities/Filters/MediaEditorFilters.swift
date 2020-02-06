import UIKit

struct MediaEditorFilter {
    let name: String
    let ciFilterName: String
}

class MediaEditorFilters: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    var image: UIImage!

    lazy var thumbImage: UIImage = {
        let size = Constant.thumbWidth * UIScreen.main.scale
        return image.fit(size: CGSize(width: size, height: size))
    }()

    var filters: [MediaEditorFilter] {
        return [
            MediaEditorFilter(
                name: "None",
                ciFilterName: ""
            ),
            MediaEditorFilter(
                name: "Sepia",
                ciFilterName: "CISepiaTone"
            ),
            MediaEditorFilter(
                name: "Mono",
                ciFilterName: "CIPhotoEffectMono"
            ),
            MediaEditorFilter(
                name: "Noir",
                ciFilterName: "CIPhotoEffectNoir"
            ),
            MediaEditorFilter(
                name: "Vintage",
                ciFilterName: "CIPhotoEffectProcess"
            ),
            MediaEditorFilter(
                name: "Tonal",
                ciFilterName: "CIPhotoEffectTonal"
            ),
            MediaEditorFilter(
                name: "Transfer",
                ciFilterName: "CIPhotoEffectTransfer"
            ),
            MediaEditorFilter(
                name: "Chrome",
                ciFilterName: "CIPhotoEffectChrome"
            ),
            MediaEditorFilter(
                name: "Fade",
                ciFilterName: "CIPhotoEffectFade"
            ),
            MediaEditorFilter(
                name: "Instant",
                ciFilterName: "CIPhotoEffectInstant"
            )
        ]
    }

    let context = MediaEditor.ciContext

    var onFinishEditing: ((UIImage, [MediaEditorOperation]) -> ())?

    var onCancel: (() -> ())?

    private var selectedFilterIndex = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        imageView.image = image
        filtersCollectionView.dataSource = self
        filtersCollectionView.delegate = self
    }

    @IBAction func cancel(_ sender: Any) {
        onCancel?()
    }

    @IBAction func done(_ sender: Any) {
        guard selectedFilterIndex.row > 0 else {
            onCancel?()
            return
        }

        guard let ciImage = imageView.image?.ciImage, let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            onCancel?()
            return
        }

        onFinishEditing?(UIImage(cgImage: cgImage), [.filter])
    }

    func sepiaFilter(_ input: CIImage, intensity: Double) -> CIImage? {
        let sepiaFilter = CIFilter(name:"CISepiaTone")
        sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        return sepiaFilter?.outputImage
    }

    func filter(_ image: UIImage, name: String) -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            return image
        }

        let sepiaFilter = CIFilter(name: name)
        sepiaFilter?.setValue(ciImage, forKey: kCIInputImageKey)

        guard let outputImage = sepiaFilter?.outputImage else {
            return image
        }
        return UIImage(ciImage: outputImage)
    }

    static func initialize() -> MediaEditorFilters {
        return UIStoryboard(
            name: "MediaEditorFilters",
            bundle: Bundle(for: MediaEditorFilters.self)
        ).instantiateViewController(withIdentifier: "filtersViewController") as! MediaEditorFilters
    }

    private enum Constant {
        static var thumbWidth: CGFloat = 64
        static var filterCellWidth: CGFloat = 71
        static var filterCellHeight: CGFloat = 93
    }
}

extension MediaEditorFilters: MediaEditorCapability {
    static var name = "Filters"

    static var icon = UIImage(named: "filters", in: .mediaEditor, compatibleWith: nil)!

    static func initialize(_ image: UIImage, onFinishEditing: @escaping (UIImage, [MediaEditorOperation]) -> (), onCancel: @escaping () -> ()) -> CapabilityViewController {
        let viewController: MediaEditorFilters = MediaEditorFilters.initialize()
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

// MARK: - UICollectionViewDataSource

extension MediaEditorFilters: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! MediaEditorFilterCell

        cell.configure(image: filter(thumbImage, name: filters[indexPath.row].ciFilterName), title: filters[indexPath.row].name)

        if indexPath == selectedFilterIndex {
            cell.showBorder()
        } else {
            cell.hideBorder()
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MediaEditorFilters: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: selectedFilterIndex) as? MediaEditorFilterCell)?.hideBorder()
        (collectionView.cellForItem(at: indexPath) as? MediaEditorFilterCell)?.showBorder()
        selectedFilterIndex = indexPath
        imageView.image = filter(image, name: filters[indexPath.row].ciFilterName)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MediaEditorFilters: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constant.filterCellWidth, height: Constant.filterCellHeight)
    }
}

