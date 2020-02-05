import UIKit

extension UIImage {
    func with(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            draw(in: CGRect(origin: CGPoint.zero, size: size))
        }

        return image
    }

    func fit(size: CGSize) -> UIImage {
        let aspect = self.size.width / self.size.height
        if size.width / aspect <= size.height {
            return with(size: CGSize(width: size.width, height: size.width / aspect))
        } else {
            return with(size: CGSize(width: size.height * aspect, height: size.height))
        }
    }
}
