import UIKit

class PlaceViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var deskPhoneLabel: UILabel!
    @IBOutlet weak var extLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    
    @IBOutlet weak var callDesk: UIButton!
    @IBAction func callDeskAction(_ sender: AnyObject) {
        if let desk_phone = place["phone"] as? NSString {
            let desk_phone_url = desk_phone.replacingOccurrences(of: ".", with: "")
            UIApplication.shared.openURL(URL(string:"tel:\(desk_phone_url)")!)
        }
    }
    
    @IBOutlet weak var showFloor: UIButton!
    @IBAction func showFloorAction(_ sender: UIButton) {
        //
    }
    
    let dot = UIImage(named: "dot.png")

    var place: NSDictionary!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPlace()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PlaceFloorSeque") {
            let floorViewController: FloorViewController = segue.destination as! FloorViewController
            floorViewController.floor = self.place["floor"] as? Int
            floorViewController.location_x = self.place["location_x"] as? CGFloat
            floorViewController.location_y = self.place["location_y"] as? CGFloat
        }
    }
    
    func showPlace() {
        if ((self.place) != nil) {
            if let name = place["name"] as? String {
                self.nameLabel.text = name
            } else {
                self.nameLabel.text = ""
            }
            
            if let client = place["client"] as? String {
                self.clientLabel.text = client
            } else {
                self.clientLabel.text = ""
            }
            
            if let project = place["project"] as? String {
                self.projectLabel.text = project
            } else {
                self.projectLabel.text = ""
            }
            
            if let phone = place["phone"] as? String {
                self.deskPhoneLabel.text = phone
                self.callDesk.isHidden = phone.isEmpty
            } else {
                self.deskPhoneLabel.text = ""
            }
            
            if let ext = place["extension"] as? String {
                self.extLabel.text = ext
            } else {
                self.extLabel.text = ""
            }
            
            if let floor = place["floor"] as? Int {
                let floorName = floorNumberToName(floor)
                self.floorLabel.text = floorName
                self.showFloor.isHidden = (floorName == "Not in PDX")
                let floorImage = UIImage(named: "floor-\(floor).png")!
                self.photoImageView.image = floorImage
                self.photoImageView.layer.cornerRadius = (self.photoImageView.frame.size.width / 2)
                self.photoImageView.clipsToBounds = true
                if let x = place["location_x"] as? CGFloat {
                    let y = place["location_y"] as? CGFloat
                    let xf = CGFloat((2500.0 - x) + 4)
                    let yf = CGFloat(y! + 8)
                    // Adjust imageView's layer.contentRect to offset image's position to the correct x/y.
                    // Note: layer.contentRect coordinate space is not in pixels, but in percents.
                    // e.g. 0.4 = 40% (as opposed to image.size.width * 0.4).
                    // So we must calc the x/y as percentages of the overall image width.
                    let floorImageSize = floorImage.size
                    let xp = (xf / floorImageSize.width) - ((self.photoImageView.frame.size.height / 2) / floorImageSize.width)
                    let yp = (yf / floorImageSize.height) - ((self.photoImageView.frame.size.height / 2) / floorImageSize.height)
                    self.photoImageView.layer.contentsRect = CGRect(origin: CGPoint(x: xp, y: yp), size: self.photoImageView.layer.contentsRect.size)
                    let dotView = UIImageView(image: self.dot)
                    self.photoImageView.addSubview(dotView)
                    dotView.center = CGPoint(x: self.photoImageView.frame.size.width / 2, y: self.photoImageView.frame.size.height / 2)
                }
            } else {
                self.floorLabel.text = ""
            }
        }
    }
}
