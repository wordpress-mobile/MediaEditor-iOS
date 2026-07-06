import Foundation

extension Bundle {
    @objc public class var mediaEditor: Bundle {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        return Bundle(for: MediaEditor.self)
#endif
    }

    static func mediaEditorBundle(for type: AnyClass) -> Bundle? {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        return Bundle(for: type)
#endif
    }
}
