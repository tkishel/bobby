import UIKit

class PersonViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deskPhoneLabel: UILabel!
    @IBOutlet weak var extLabel: UILabel!
    @IBOutlet weak var mobilePhoneLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!

    @IBOutlet weak var callDesk: UIButton!
    @IBOutlet weak var callMobile: UIButton!
    @IBOutlet weak var textMobile: UIButton!

    @IBAction func callDeskAction(_ sender: UIButton) {
        if let desk_phone = puppeteer["desk_phone"] as? NSString {
            let desk_phone_url = desk_phone.replacingOccurrences(of: ".", with: "")
            UIApplication.shared.openURL(URL(string:"tel:\(desk_phone_url)")!)
        }
    }

    @IBAction func callMobileAction(_ sender: UIButton) {
        if let cell_phone = puppeteer["cell_phone"] as? NSString {
            let cell_phone_url = cell_phone.replacingOccurrences(of: ".", with: "")
            UIApplication.shared.openURL(URL(string:"tel:\(cell_phone_url)")!)
        }
    }

    @IBAction func textMobileAction(_ sender: UIButton) {
        if let cell_phone = puppeteer["cell_phone"] as? NSString {
            let cell_phone_url = cell_phone.replacingOccurrences(of: ".", with: "")
            UIApplication.shared.openURL(URL(string:"sms:\(cell_phone_url)")!)
        }
    }

    @IBOutlet weak var showFloor: UIButton!
    @IBAction func showFloorAction(_ sender: UIButton) {
        //
    }

    var puppeteer: NSDictionary!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        showPuppeteer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PersonFloorSeque") {
            let floorViewController: FloorViewController = segue.destination as! FloorViewController
            floorViewController.floor = self.puppeteer["floor"] as? Int
            floorViewController.location_x = self.puppeteer["location_x"] as? CGFloat
            floorViewController.location_y = self.puppeteer["location_y"] as? CGFloat
        }
    }

    func showPuppeteer() {
        if ((self.puppeteer) != nil) {
            if let first_name = puppeteer["first_name"] as? String {
                self.firstNameLabel.text = first_name
                self.lastNameLabel.text = ""
            }

            if let last_name = puppeteer["last_name"] as? String {
                self.lastNameLabel.text = last_name
            } else {
                self.lastNameLabel.text = ""
            }

            if let job_title = puppeteer["job_title"] as? String {
                self.titleLabel.text = job_title
            } else {
                self.titleLabel.text = ""
            }

            // TJK rename department to ou
            if let department = puppeteer["department"] as? String {
                self.departmentLabel.text = department
            } else {
                self.departmentLabel.text = ""
            }

            // TJK rename description to personaltitle
            if let description = puppeteer["description"] as? String {
                self.descriptionLabel.text = description
            } else {
                self.descriptionLabel.text = ""
            }

            var photo_data = Data()

            let profile_photo = puppeteer["photo_path"] as! String
            if (profile_photo.isEmpty) {
                photo_data = readDefaultPuppeteerPhotoFile() as Data
            } else {
                photo_data = readPuppeteerPhotoFile(profile_photo)
                if (photo_data.count == 0) {
                    photo_data = downloadPuppeteerPhotoFile(profile_photo)
                    if (photo_data.count == 0) {
                        photo_data = readDefaultPuppeteerPhotoFile() as Data
                    } else {
                        writePuppeteerPhotoFile(profile_photo, photo_data: photo_data)
                    }
                }
            }
            if (photo_data.count != 0) {
                self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2;
                self.photoImageView.clipsToBounds = true;
                self.photoImageView.image = UIImage(data: photo_data)
            }

            // TJK toss
            if let desk_phone = puppeteer["desk_phone"] as? String {
                self.deskPhoneLabel.text = desk_phone
                self.callDesk.isHidden = desk_phone.isEmpty
            } else {
                self.deskPhoneLabel.text = ""
            }

            // TJK unused
            if let ext = puppeteer["extension"] as? String {
                self.extLabel.text = ext
            } else {
                self.extLabel.text = ""
            }

            if let cell_phone = puppeteer["cell_phone"] as? String {
                self.mobilePhoneLabel.text = cell_phone
                self.callMobile.isHidden = cell_phone.isEmpty
                self.textMobile.isHidden = cell_phone.isEmpty
            } else {
                self.mobilePhoneLabel.text = ""
            }

            // TJK expand to location,floor,x,y
            
            if let floor = puppeteer["floor"] as? Int {
                let floorName = floorNumberToName(floor)
                self.floorLabel.text = floorName
                self.showFloor.isHidden = (floorName == "Not in PDX")
            } else {
                self.floorLabel.text = ""
            }
        }
    }
}
