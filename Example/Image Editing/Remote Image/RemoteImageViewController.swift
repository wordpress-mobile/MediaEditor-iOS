import UIKit
import MediaEditor

class RemoteImageViewController: UIViewController {
    
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!

    let images = [
        RemoteImage(thumb: UIImage(named: "thumb1"), fullImageURL: "https://cldup.com/_rSwtEeDGD.jpg"),
        RemoteImage(thumb: UIImage(named: "thumb2"), fullImageURL: "https://cldup.com/L-cC3qX2DN.jpg")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Add tap gesture in the first image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        firstImageView.isUserInteractionEnabled = true
        firstImageView.addGestureRecognizer(tapGestureRecognizer)

        // Add tap gesture in the second image
        let secondTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        secondImageView.isUserInteractionEnabled = true
        secondImageView.addGestureRecognizer(secondTapGestureRecognizer)

        // Show the thumbs in this VC
        firstImageView.image = images.first?.thumb
        secondImageView.image = images[1].thumb
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        // Give the images to the MediaEditor
        let mediaEditor = MediaEditor(images)
        mediaEditor.edit(from: self, onFinishEditing: { images, action in
            // Display the returned images
            if let image = images.first?.editedImage {
                self.firstImageView.image = image
            }

            if let image = images[1].editedImage {
                self.secondImageView.image = image
            }
        }, onCancel: {
            // User canceled
        })
    }

}
/// Here we have a class that conforms to AsyncImage, in order to use remote images in the Media Editor
/// Basically, we need to provide the thumb and the full image
class RemoteImage: AsyncImage {
    var thumb: UIImage?

    let fullImageURL: URL

    var tasks: [URLSessionDataTask] = []

    init(thumb: UIImage?, fullImageURL: String) {
        self.thumb = thumb
        self.fullImageURL = URL(string: fullImageURL)!
    }

    func thumbnail(finishedRetrievingThumbnail: @escaping (UIImage?) -> ()) {
        // In this example we already provide the thumb
    }

    /// Here we download the full quality image
    func full(finishedRetrievingFullImage: @escaping (UIImage?) -> ()) {
        let task = URLSession.shared.dataTask(with: fullImageURL) { data, response, error in
            guard let data = data, error == nil else {
                // If any error occured, calls the callback without an image
                finishedRetrievingFullImage(nil)
                return
            }

            // If the download was succesfull, gives the image to the callback
            let downloadedImage = UIImage(data: data)
            finishedRetrievingFullImage(downloadedImage)
        }
        task.resume()
        tasks.append(task)
    }

    func cancel() {
        tasks.forEach { $0.cancel() }
    }

}
