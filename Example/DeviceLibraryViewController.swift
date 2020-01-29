import UIKit
import Photos
import MediaEditor

class DeviceLibraryViewController: UIViewController {

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var descriptionLabel: UILabel!

    var insertedImages: [AsyncImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
    }

    @IBAction func edit(_ sender: Any) {
        // Load the last 10 Photos
        let photos: [PHAsset] = fetchLatestPhotos(limit: 10)

        // Give 'em to the Media Editor
        let mediaEditor = MediaEditor(photos)

        // Present the Media Editor
        mediaEditor.edit(from: self, onFinishEditing: { images, actions in
            self.insertedImages = images
            self.imagesCollectionView.reloadData()
            self.descriptionLabel.isHidden = true
        }, onCancel: {
            // User tapped cancel
        })
    }
    
}

// MARK: - UICollectionViewDataSource

extension DeviceLibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return insertedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCollectionCell.identifier, for: indexPath) as! ImageViewCollectionCell

        // Check if the image was edited
        if let editedImage = insertedImages[indexPath.row].editedImage {
            cell.configure(image: editedImage, wasEdited: true)
            // If it wasn't, load the PHAsset and display it
        } else if let phAsset = insertedImages[indexPath.row] as? PHAsset {
            loadImage(from: phAsset, into: cell)
        }

        return cell
    }
}

// MARK: - Size of the cells

extension DeviceLibraryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (imagesCollectionView.frame.width - 21) / 3
        return CGSize(width: width, height: width)
    }
}

// MARK: - PHAsset related methods

extension DeviceLibraryViewController {
    func fetchLatestPhotos(limit: Int) -> [PHAsset] {
        var assets: [PHAsset] = []

        // Create fetch options.
        let options = PHFetchOptions()
        options.fetchLimit = limit

        // Add sortDescriptor so the lastest photos will be returned.
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]

        // Fetch the photos.
        let result = PHAsset.fetchAssets(with: .image, options: options)

        // Add them to an array
        result.enumerateObjects { photo, _, _ in
            assets.append(photo)
        }

        return assets
    }

    func loadImage(from asset: PHAsset, into cell: ImageViewCollectionCell) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.version = .current
        options.resizeMode = .fast
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .default, options: options) { image, info in
            guard let image = image else {
                return
            }

            cell.configure(image: image, wasEdited: false)
        }
    }
}
