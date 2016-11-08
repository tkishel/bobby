import UIKit

class PlacesNavViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// UITableViewController embedded in the above UINavigationController

class PlacesViewController: UITableViewController {
    @IBOutlet var appsPlacesTableView : UITableView?

    @IBAction func placeSeque(_ sender: AnyObject) {
        performSegue(withIdentifier: "PlaceSeque", sender: sender)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.black
        print("Loading Places View")
        pingRobby()
        print("Loaded Places View")
    }

    func reloadPlaces(_ notification: Notification) {
        // processPlacesArray()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
    //    let result = placesSectionTitles
    //    result.insertObject(UITableViewIndexSearch atIndex: 0)
    //    return result
    //}

    override func numberOfSections(in tableView: UITableView) -> Int {
        let result = placesSectionTitles.count
        return result
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        let result = placesSectionTitles.object(at: section) as! String
        return result
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        //if (index == 0) {
        //    return -1
        //}
        let result = index
        return result
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section_key = placesSectionTitles.object(at: section) as! NSString
        let section_objects = placesBySection.object(forKey: section_key) as! NSMutableArray
        let result = section_objects.count
        return result
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Place")
        let section_key = placesSectionTitles.object(at: (indexPath as NSIndexPath).section) as! NSString
        let section_objects = placesBySection.object(forKey: section_key) as! NSMutableArray

        cell.backgroundColor = UIColor.clear

        let place = section_objects.object(at: (indexPath as NSIndexPath).row) as! NSDictionary

        let location = place["location"] as! String
        if (location.isEmpty) {
            cell.detailTextLabel?.text = ""
        } else {
            cell.detailTextLabel?.text = location
        }
        cell.detailTextLabel?.textColor = UIColor.white

        let name = place["name"] as! String
        if (name.isEmpty) {
            cell.textLabel?.text = ""
        } else {
            cell.textLabel?.text = name
        }
        cell.textLabel?.textColor = UIColor.white

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section_key = placesSectionTitles.object(at: (indexPath as NSIndexPath).section) as! NSString
        let section_objects = placesBySection.object(forKey: section_key) as! NSMutableArray
        let puppeteer = section_objects.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        placeSeque(puppeteer)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PlaceSeque") {
            let placeViewController: PlaceViewController = segue.destination as! PlaceViewController
            placeViewController.place = sender as! NSDictionary
        }
    }
}
