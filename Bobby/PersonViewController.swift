import UIKit

class PersonViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
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
                        _ = writePuppeteerPhotoFile(profile_photo, photo_data: photo_data)
                    }
                }
            }
            if (photo_data.count != 0) {
                self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2;
                self.photoImageView.clipsToBounds = true;
                self.photoImageView.image = UIImage(data: photo_data)
            }

            if let first_name = puppeteer["first_name"] as? String {
                self.firstNameLabel.text = first_name
                self.lastNameLabel.text = ""
            }

            if let last_name = puppeteer["last_name"] as? String {
                self.lastNameLabel.text = last_name
            } else {
                self.lastNameLabel.text = ""
            }

            // TJK rename label to ou
            if let ou = puppeteer["ou"] as? String {
                self.departmentLabel.text = ou
            } else {
                self.departmentLabel.text = ""
            }

            if let job_title = puppeteer["job_title"] as? String {
                self.titleLabel.text = job_title
            } else {
                self.titleLabel.text = ""
            }
            
            // TJK rename label to personaltitle
            if let personaltitle = puppeteer["personaltitle"] as? String {
                self.descriptionLabel.text = personaltitle
            } else {
                self.descriptionLabel.text = ""
            }

            if let mobile = puppeteer["mobile"] as? String {
                self.mobilePhoneLabel.text = mobile
                self.textMobile.isHidden = mobile.isEmpty
            } else {
                self.mobilePhoneLabel.text = ""
            }
            
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
