import UIKit

class PeopleNavViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// UITableViewController embedded in the above UINavigationController

class PeopleViewController: UITableViewController {
    @IBOutlet var appsPeopleTableView : UITableView?

    @IBAction func personSeque(_ sender: AnyObject) {
        performSegue(withIdentifier: "PersonSeque", sender: sender)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.black
        // TJK Fix!
        self.tableView.sectionIndexColor = UIColor.red
        print("Loading People View")
        pingRobby()
        print("Loaded People View")
    }

    func reloadPuppeteers(_ notification: Notification) {
        // processPuppeteersArray()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
    //    let result = puppeteersSectionTitles
    //    return result as [AnyObject]
    //}

    override func numberOfSections(in tableView: UITableView) -> Int {
        let result = puppeteersSectionTitles.count
        return result
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        let result = puppeteersSectionTitles.object(at: section) as! String
        return result
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        // return (index - 1) if UITableViewIndexSearch
        let result = index
        return result
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section_key = puppeteersSectionTitles.object(at: section) as! NSString
        let section_objects = puppeteersBySection.object(forKey: section_key) as! NSMutableArray
        let result = section_objects.count
        return result
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Puppeteers")
        let section_key = puppeteersSectionTitles.object(at: (indexPath as NSIndexPath).section) as! NSString
        let section_objects = puppeteersBySection.object(forKey: section_key) as! NSMutableArray

        let puppeteer = section_objects.object(at: (indexPath as NSIndexPath).row) as! NSDictionary

        cell.backgroundColor = UIColor.clear

        let first_name = puppeteer["first_name"] as? String
        let last_name = puppeteer["last_name"] as? String
        cell.textLabel?.text = first_name! + " " + last_name!
        cell.textLabel?.textColor = UIColor.white
        
        if let job_title = puppeteer["job_title"] as? String {
            cell.detailTextLabel?.text = job_title
        } else {
            cell.detailTextLabel?.text = ""
        }
        cell.detailTextLabel?.textColor = UIColor.white

        var photo_data = Data()

        let profile_photo = puppeteer["photo_path"] as! String
        if (profile_photo.isEmpty) {
            photo_data = readDefaultPuppeteerPhotoFile() as Data
        } else {
            photo_data = readPuppeteerPhotoFile(profile_photo)
            if (photo_data.count == 0) {
                // TJK ??? This appears to always execute
                // photo_data = downloadPuppeteerPhotoFile(profile_photo)
                if (photo_data.count == 0) {
                    photo_data = readDefaultPuppeteerPhotoFile() as Data
                } else {
                     _ = writePuppeteerPhotoFile(profile_photo, photo_data: photo_data)
                }
            }
        }

        if (photo_data.count != 0) {
            cell.imageView?.image = UIImage(data: photo_data)
            // TJK: Scale, Round!
            // let cellImageLayer: CALayer?  = cell.imageView?.layer
            // cellImageLayer?.cornerRadius = (cellImageLayer?.frame.size.width)! / 2;
            // cellImageLayer?.masksToBounds = true;
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section_key = puppeteersSectionTitles.object(at: (indexPath as NSIndexPath).section) as! NSString
        let section_objects = puppeteersBySection.object(forKey: section_key) as! NSMutableArray
        let puppeteer = section_objects.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        personSeque(puppeteer)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PersonSeque") {
            let personViewController: PersonViewController = segue.destination as! PersonViewController
            personViewController.puppeteer = sender as! NSDictionary
        }
    }
}
