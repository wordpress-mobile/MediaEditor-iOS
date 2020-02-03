import UIKit

class MediaEditorFilters: MediaEditorCapability {
    static var name = "Filters"

    static var icon = UIImage(named: "filters", in: .mediaEditor, compatibleWith: nil)!

    var image: UIImage

    var viewController: UIViewController

    var onFinishEditing: (UIImage, [MediaEditorOperation]) -> ()

    var onCancel: (() -> ())

    required init(_ image: UIImage, onFinishEditing: @escaping (UIImage, [MediaEditorOperation]) -> (), onCancel: @escaping () -> ()) {
        self.image = image
        self.onFinishEditing = onFinishEditing
        self.onCancel = onCancel
        let viewController: MediaEditorFiltersViewController = MediaEditorFiltersViewController.initialize()
        self.viewController = viewController
        viewController.onFinishEditing = onFinishEditing
        viewController.onCancel = onCancel
        viewController.image = image
    }

    func apply(styles: MediaEditorStyles) {

    }
}

struct MediaEditorFilter {
    let name: String
    let apply: (UIImage) -> (UIImage)
}

class MediaEditorFiltersViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filtersCollectionView: UICollectionView!

    var image: UIImage!

    lazy var thumbImage: UIImage = {
        let size = 64 * UIScreen.main.scale
        return image.fit(size: CGSize(width: size, height: size))
    }()

    var filters: [MediaEditorFilter] {
        return [
            MediaEditorFilter(
                name: "None",
                apply: { return $0 }
            ),
            MediaEditorFilter(
                name: "Sepia",
                apply: { return self.filter($0, name: "CISepiaTone") }
            ),
            MediaEditorFilter(
                name: "Mono",
                apply: { return self.filter($0, name: "CIPhotoEffectMono") }
            ),
            MediaEditorFilter(
                name: "Noir",
                apply: { return self.filter($0, name: "CIPhotoEffectNoir") }
            ),
            MediaEditorFilter(
                name: "Vintage",
                apply: { return self.filter($0, name: "CIPhotoEffectProcess") }
            ),
            MediaEditorFilter(
                name: "Tonal",
                apply: { return self.filter($0, name: "CIPhotoEffectTonal") }
            ),
            MediaEditorFilter(
                name: "Transfer",
                apply: { return self.filter($0, name: "CIPhotoEffectTransfer") }
            ),
            MediaEditorFilter(
                name: "Chrome",
                apply: { return self.filter($0, name: "CIPhotoEffectChrome") }
            ),
            MediaEditorFilter(
                name: "Fade",
                apply: { return self.filter($0, name: "CIPhotoEffectFade") }
            ),
            MediaEditorFilter(
                name: "Instant",
                apply: { return self.filter($0, name: "CIPhotoEffectInstant") }
            )
        ]
    }

    let context = CIContext()

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

        onFinishEditing?(UIImage.init(cgImage: cgImage), [])
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

    static func initialize() -> MediaEditorFiltersViewController {
        return UIStoryboard(name: "MediaEditorFilters", bundle: Bundle(for: MediaEditorFiltersViewController.self)).instantiateViewController(withIdentifier: "filtersViewController") as! MediaEditorFiltersViewController
    }
}

extension MediaEditorFiltersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! MediaEditorFilterCell

        cell.configure(image: filters[indexPath.row].apply(thumbImage), title: filters[indexPath.row].name)

        if indexPath == selectedFilterIndex {
            cell.showBorder()
        } else {
            cell.hideBorder()
        }

        return cell
    }
}

extension MediaEditorFiltersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: selectedFilterIndex) as? MediaEditorFilterCell)?.hideBorder()
        (collectionView.cellForItem(at: indexPath) as? MediaEditorFilterCell)?.showBorder()
        selectedFilterIndex = indexPath
        imageView.image = filters[indexPath.row].apply(image)
    }
}

extension MediaEditorFiltersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 71, height: 93)
    }
}

class MediaEditorFilterCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!

    func configure(image: UIImage, title: String) {
        imageView.image = image
        self.title.text = title
    }

    func showBorder(color: UIColor? = nil) {
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = color?.cgColor ?? Constant.defaultSelectedColor
    }

    func hideBorder() {
        imageView.layer.borderWidth = 0
    }

    private enum Constant {
        static var defaultSelectedColor = UIColor(red: 0.133, green: 0.443, blue: 0.694, alpha: 1).cgColor
    }
}
