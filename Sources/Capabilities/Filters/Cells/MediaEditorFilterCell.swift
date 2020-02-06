import UIKit

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
