import UIKit

/// A type that is a UIViewController and also conforms to MediaEditorCapability
public typealias CapabilityViewController = UIViewController & MediaEditorCapability

/// A protocol that defines some properties for a Capability
public protocol MediaEditorCapability {

    /// The name of your Capability. Eg.: "Emojis"
    static var name: String { get }

    /// An icon that represents your Capability. This will be displayed in the Media Editor interface.
    static var icon: UIImage { get }

    /// A static initializer for a CapabilityViewController.
    ///
    /// Use this method to initialize your UIViewController that conforms to MediaEditorCapability.
    /// - Parameter image: `UIImage` to be displayed and edited
    /// - Parameter onFinishEditing: block to be called when the user finished editing the image
    /// - Parameter onCancel: block to be called when the user cancels editing the image
    ///
    static func initialize(_ image: UIImage,
         onFinishEditing: @escaping (UIImage, [MediaEditorOperation]) -> (),
         onCancel: @escaping () -> ()) -> CapabilityViewController

    /// A function that applies given styles into your UIViewController
    func apply(styles: MediaEditorStyles)
}
