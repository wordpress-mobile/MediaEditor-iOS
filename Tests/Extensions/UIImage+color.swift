import UIKit

extension UIImage {

    /**
        Returns an UIImage with a specified background color.
        - parameter color: The color of the background
     */
    convenience init(color: UIColor) {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size);
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        context.setFillColor(color.cgColor);
        context.fill(rect)

        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.init(ciImage: CIImage(image: image)!)
    }
}
