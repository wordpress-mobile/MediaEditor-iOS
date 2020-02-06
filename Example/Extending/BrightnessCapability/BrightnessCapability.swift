import UIKit
import MediaEditor

// MARK: - BrightnessViewController

class BrightnessViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var brightnessSlider: UISlider!

    let context = MediaEditor.ciContext

    var onFinishEditing: ((UIImage, [MediaEditorOperation]) -> ())?

    var onCancel: (() -> ())?

    var image: UIImage!

    lazy var ciImage: CIImage? = {
        return CIImage(image: image)
    }()

    lazy var brightnessFilter: CIFilter? = {
        guard let ciImage = ciImage else {
            return nil
        }

        let ciFilter = CIFilter(name: "CIColorControls")
        ciFilter?.setValue(ciImage, forKey: "inputImage")

        return ciFilter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }


    @IBAction func cancel(_ sender: Any) {
        onCancel?()
    }

    @IBAction func done(_ sender: Any) {
        // Check if the user changed the brightness
        guard brightnessSlider.value > 0 else {
            onCancel?()
            return
        }

        // Get the UIImage
        guard let ciImage = imageView.image?.ciImage, let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            onCancel?()
            return
        }

        onFinishEditing?(UIImage(cgImage: cgImage), [])
    }

    // When the slider changes, apply the brightness value
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        brightnessFilter?.setValue(sender.value, forKey: "inputBrightness")
        if let outputImage = brightnessFilter?.outputImage {
            imageView.image = UIImage(ciImage: outputImage)
        }
    }

    // Load it from storyboard
    static func fromStoryboard() -> BrightnessViewController {
        return UIStoryboard(name: "BrightnessCapability", bundle: .main).instantiateViewController(withIdentifier: "brightnessViewController") as! BrightnessViewController
    }
}

extension BrightnessViewController: MediaEditorCapability {
    static var name = "Brightness"

    static var icon = UIImage(named: "ink")!

    static func initialize(_ image: UIImage, onFinishEditing: @escaping (UIImage, [MediaEditorOperation]) -> (), onCancel: @escaping () -> ()) -> CapabilityViewController {
        let viewController = BrightnessViewController.fromStoryboard()
        viewController.onFinishEditing = onFinishEditing
        viewController.onCancel = onCancel
        viewController.image = image
        return viewController
    }

    func apply(styles: MediaEditorStyles) {
        // Apply styles here
    }
}
