import XCTest
import CropViewController
import Nimble

@testable import MediaEditor

class MediaEditorCropZoomRotateTests: XCTestCase {

    private let image = UIImage()

    func testIsAMediaEditorCapability() {
        let mediaEditorCrop = MediaEditorCropZoomRotate.initialize(image, onFinishEditing: { _, _ in }, onCancel: {})

        expect(mediaEditorCrop).to(beAKindOf(MediaEditorCapability.self))
    }

    func testDoNotHideNavigation() {
        let mediaEditorCrop = MediaEditorCropZoomRotate.initialize(image, onFinishEditing: { _, _ in }, onCancel: {})

        let viewController = mediaEditorCrop as? CropViewController

        expect(viewController?.hidesNavigationBar).to(beFalse())
    }

    func testOnDidCropToRectCallOnFinishEditing() {
        var onFinishEditingCalled = false
        let mediaEditorCrop = MediaEditorCropZoomRotate.initialize(
            image,
            onFinishEditing: { _, _ in
                onFinishEditingCalled = true
            },
            onCancel: {})
        let viewController = mediaEditorCrop as? CropViewController

        viewController?.onDidCropToRect?(image, .zero, 0)

        expect(onFinishEditingCalled).to(beTrue())
    }

    func testOnDidFinishCancelledCall() {
        var onCancelCalled = false
        let mediaEditorCrop = MediaEditorCropZoomRotate.initialize(
            image,
            onFinishEditing: { _, _ in },
            onCancel: {
                onCancelCalled = true
            }
        )
        let viewController = mediaEditorCrop as? CropViewController

        viewController?.onDidFinishCancelled?(true)

        expect(onCancelCalled).to(beTrue())
    }

    func testHideRotateCounterclockwiseButton() {
        let mediaEditorCrop = MediaEditorCropZoomRotate.initialize(image, onFinishEditing: { _, _ in }, onCancel: {})

        mediaEditorCrop.apply(styles: [.rotateCounterclockwiseButtonHidden: true])

        let viewController = mediaEditorCrop as? CropViewController
        expect(viewController?.toolbar.rotateCounterclockwiseButtonHidden).to(beTrue())
    }

}
