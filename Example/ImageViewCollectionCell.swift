import UIKit

class ImageViewCollectionCell: UICollectionViewCell {
    static let identifier = "imageViewCollectionCell"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editedLabel: UILabel!

    func configure(image: UIImage, wasEdited: Bool) {
        imageView.image = image
        editedLabel.isHidden = !wasEdited
    }
}
