import XCTest
import Nimble

@testable import MediaEditor

class MediaEditorFilterTests: XCTestCase {

    func testName() {
        let name = MediaEditorFilters.name

        expect(name).to(equal("Filters"))
    }

    func testIcon() {
        let icon = MediaEditorFilters.icon

        expect(icon).to(equal(UIImage(named: "filters", in: .mediaEditor, compatibleWith: nil)!))
    }

    func testApplyStyles() {
        let mediaEditorFilters = MediaEditorFilters.initialize(UIImage(), onFinishEditing: { _, _ in }, onCancel: {})
        mediaEditorFilters.loadView()

        mediaEditorFilters.apply(styles: [
            .doneLabel: "foo",
            .cancelLabel: "bar",
            .cancelColor: UIColor.black
        ])

        let viewController = mediaEditorFilters as! MediaEditorFilters
        expect(viewController.doneButton.titleLabel?.text).to(equal("foo"))
        expect(viewController.cancelButton.titleLabel?.text).to(equal("bar"))
        expect(viewController.cancelButton.tintColor).to(equal(.black))
    }

}
