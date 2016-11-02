import UIKit

class ThingsViewController: UIViewController {
    
    @IBOutlet weak var thingsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showThings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showThings() {
        if (thingsArray.count > 0) {
            self.thingsLabel.text = thingsString
        } else {
            self.thingsLabel.text = "No Beer!"
        }
    }
}

