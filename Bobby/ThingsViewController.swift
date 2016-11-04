import UIKit

class ThingsViewController: UIViewController {
    
    @IBOutlet weak var things0: UILabel!
    @IBOutlet weak var things1: UILabel!
    @IBOutlet weak var things2: UILabel!
    @IBOutlet weak var things3: UILabel!
    
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
            self.things0.text = thingsArray[0] as? String
            self.things1.text = thingsArray[1] as? String
            self.things2.text = thingsArray[2] as? String
            self.things3.text = thingsArray[3] as? String
        } else {
            self.things0.text = "Oh no!"
            self.things1.text = "Oh no!"
            self.things2.text = "Oh no!"
            self.things3.text = "Oh no!"
        }
    }
}

