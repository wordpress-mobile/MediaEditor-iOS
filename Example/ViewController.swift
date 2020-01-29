import UIKit

class ViewController: UITableViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #if !targetEnvironment(simulator)
        tableView.footerView(forSection: 2)?.isHidden = true
        #endif
    }

}
