import Foundation

extension Bundle {
    @objc public class var mediaEditor: Bundle {
        let defaultBundle = Bundle(for: MediaEditor.self)
        // If installed with CocoaPods, resources will be in MediaEditor.bundle
        if let bundleURL = defaultBundle.resourceURL,
            let resourceBundle = Bundle(url: bundleURL.appendingPathComponent("MediaEditor.bundle")) {
            return resourceBundle
        }
        // Otherwise, the default bundle is used for resources
        return defaultBundle
    }
}
