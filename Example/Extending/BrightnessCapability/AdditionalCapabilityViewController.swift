import UIKit
import MediaEditor

class AdditionalCapabilityViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Append Brightness to the list of capabilities
        MediaEditor.capabilities.append(BrightnessCapability.self)

        // Add tap gesture in the image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            MediaEditor.capabilities.removeLast()
        }
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let image = imageView.image else {
            return
        }

        // Give the image to the MediaEditor (you can also pass an array of UIImage)
        let mediaEditor = MediaEditor(image)
        mediaEditor.edit(from: self, onFinishEditing: { images, action in
            // Display the edited image
            guard let images = images as? [UIImage] else {
                return
            }

            self.imageView.image = images.first
        }, onCancel: {
            // User canceled
        })
    }
}
