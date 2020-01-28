import UIKit
import Photos
import MediaEditor

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let photos = fetchLatestPhotos(limit: 30)
        let mediaEditor = MediaEditor(photos)
        mediaEditor.edit(from: self, onFinishEditing: { _, _ in }, onCancel: { })
    }

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

}
