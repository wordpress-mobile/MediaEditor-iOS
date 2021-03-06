import UIKit
import MediaEditor

class PlainUIImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Add tap gesture in the first image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)

        // Add tap gesture in the second image
        let secondTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        secondImageView.isUserInteractionEnabled = true
        secondImageView.addGestureRecognizer(secondTapGestureRecognizer)
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let firstImage = imageView.image,
            let secondImage = secondImageView.image else {
            return
        }

        // Give the image to the MediaEditor (you can also pass an array of UIImage)
        let mediaEditor = MediaEditor([firstImage, secondImage])
        mediaEditor.edit(from: self, onFinishEditing: { images, action in
            // Display the edited image
            guard let images = images as? [UIImage] else {
                return
            }

            self.imageView.image = images.first
            self.secondImageView.image = images[1]
        }, onCancel: {
            // User canceled
        })
    }
}
