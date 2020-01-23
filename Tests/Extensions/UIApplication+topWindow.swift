import UIKit

extension UIApplication {
    var topWindow: UIWindow? {
        return windows.first
    }
}
