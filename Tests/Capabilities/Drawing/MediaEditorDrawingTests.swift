import XCTest
import Nimble

@testable import MediaEditor

import XCTest

@available(iOS 13.0, *)
class MediaEditorDrawingTests: XCTestCase {

    func testName() {
        let name = MediaEditorDrawing.name

        expect(name).to(equal("Drawing"))
    }

    func testIcon() {
        let icon = MediaEditorDrawing.icon

        expect(icon).to(equal(UIImage(systemName: "pencil.tip.crop.circle")!))
    }

    func testApplyStyles() {
        let mediaEditorDrawing = MediaEditorDrawing.initialize(UIImage(), onFinishEditing: { _, _ in }, onCancel: {})
        mediaEditorDrawing.loadView()

        let undoIcon = UIImage(systemName: "arrowshape.turn.up.left")!
        let redoIcon = UIImage(systemName: "arrowshape.turn.up.right")!

        mediaEditorDrawing.apply(styles: [
            .doneLabel: "foo",
            .cancelLabel: "bar",
            .cancelColor: UIColor.red,
            .undoIcon: undoIcon,
            .redoIcon: redoIcon
        ])

        let viewController = mediaEditorDrawing as! MediaEditorDrawing
        expect(viewController.doneButton.titleLabel?.text).to(equal("foo"))
        expect(viewController.cancelButton.titleLabel?.text).to(equal("bar"))
        expect(viewController.cancelButton.tintColor).to(equal(.red))
        expect(viewController.undoButton.tintColor).to(equal(.red))
        expect(viewController.redoButton.tintColor).to(equal(.red))
        expect(viewController.undoButton.image(for: .normal)).to(equal(undoIcon))
        expect(viewController.redoButton.image(for: .normal)).to(equal(redoIcon))
    }

    private let image = UIImage()

    func testIsAMediaEditorCapability() {
        let mediaEditorDrawing = MediaEditorDrawing.initialize(image, onFinishEditing: { _, _ in }, onCancel: {})

        expect(mediaEditorDrawing).to(beAKindOf(MediaEditorCapability.self))
    }

    func testOriginalImageIsReturnedIfNoChangesMade() {
        let image = UIImage(systemName: "arrowshape.turn.up.left")!

        var result: UIImage? = nil
        let mediaEditorDrawing = MediaEditorDrawing.initialize(image, onFinishEditing: { finishedImage, _ in
            result = finishedImage
        }, onCancel: {}) as! MediaEditorDrawing
        let annotationViewMock = MediaEditorAnnotationViewMock()

        mediaEditorDrawing.loadView()
        mediaEditorDrawing.annotationView = annotationViewMock
        mediaEditorDrawing.viewDidLoad()
        mediaEditorDrawing.done(self)

        expect(image).to(equal(result))
    }

    func testModifiedImageIsReturnedIfChangesAreMade() {
        let image = UIImage(systemName: "arrowshape.turn.up.left")!

        var result: UIImage? = nil
        let mediaEditorDrawing = MediaEditorDrawing.initialize(image, onFinishEditing: { finishedImage, _ in
            result = finishedImage
        }, onCancel: {}) as! MediaEditorDrawing
        let annotationViewMock = MediaEditorAnnotationViewMock()
        annotationViewMock.image = UIImage()

        mediaEditorDrawing.loadView()
        mediaEditorDrawing.viewDidLoad()
        mediaEditorDrawing.annotationView = annotationViewMock
        mediaEditorDrawing.view.setNeedsLayout()
        mediaEditorDrawing.view.layoutIfNeeded()

        mediaEditorDrawing.done(self)

        expect(image).notTo(equal(result))
    }

    func testNewEditorHasNoUndoActions() {
        let mediaEditorDrawing = MediaEditorDrawing.initialize(UIImage(), onFinishEditing: { _, _ in }, onCancel: {}) as! MediaEditorDrawing
        mediaEditorDrawing.loadView()
        mediaEditorDrawing.viewDidLoad()

        expect(mediaEditorDrawing.undoButton.isEnabled).to(beFalse())
        expect(mediaEditorDrawing.redoButton.isEnabled).to(beFalse())
    }
}

@available(iOS 13.0, *)
private class MediaEditorAnnotationViewMock: MediaEditorAnnotationView {
    override var canUndo: Bool {
        return true
    }
}
