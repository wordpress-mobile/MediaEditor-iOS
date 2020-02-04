import UIKit

public typealias CapabilityViewController = UIViewController & MediaEditorCapability

public protocol MediaEditorCapability {
    static var name: String { get }

    static var icon: UIImage { get }

    static func initialize(_ image: UIImage,
         onFinishEditing: @escaping (UIImage, [MediaEditorOperation]) -> (),
         onCancel: @escaping () -> ()) -> CapabilityViewController

    func apply(styles: MediaEditorStyles)
}
