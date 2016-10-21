import Foundation

struct GlobalConstants {
    static let documents_paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
    static let documents_directory = documents_paths.object(at: 0) as! NSString
    static let avatars_directory = documents_directory.appendingPathComponent("avatars") as NSString
    static let api_ping_pong = "https://robby.puppetlabs.net/ping" as String
    static let api_people_plist = "https://robby.puppetlabs.net/people.plist" as String
    static let api_places_plist = "https://robby.puppetlabs.net/resources.plist" as String
    static let api_avatars_plist = "https://robby.puppetlabs.net/avatars/" as String
    static let default_avatar = Bundle.main.path(forResource: "generic", ofType: "png")
    static let pdx_floor5 = Bundle.main.path(forResource: "pdx_floor5", ofType: "png")
    static let pdx_floor6 = Bundle.main.path(forResource: "pdx_floor6", ofType: "png")
}

var pingPong = false

var puppeteersData: NSMutableData?
var puppeteersArray: NSArray = []
var puppeteersSectionTitles = NSMutableArray()
var puppeteersBySection = NSMutableDictionary()
var puppeteersPhotoArray = NSMutableDictionary()

var placesData: NSMutableData?
var placesArray: NSArray = []
var placesSectionTitles = NSMutableArray()
var placesBySection = NSMutableDictionary()

// sendSynchronousRequest deprecated

func ping() {
    pingPong = false;
    let url = URL(string: GlobalConstants.api_ping_pong)
    let request = NSMutableURLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 3)
    var response: URLResponse?
    _ = try? NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
    if let http_response = response as? HTTPURLResponse {
        if (http_response.statusCode == 200) {
            pingPong = true;
        }
        print("Ping: \(http_response.statusCode)")
    } else {
        print("Ping: No HTTP Response")
    }
}

func launchPuppetApplication() {
    ping()
    
    let manager = FileManager.default

    downloadPuppeteersFile()
    let people_path = GlobalConstants.documents_directory.appendingPathComponent("people.plist")
    if (manager.fileExists(atPath: people_path)) {
        if (!readPuppeteersFile()) {
           downloadPuppeteersFile()
        }
    } else {
        downloadPuppeteersFile()
    }
    processPuppeteersArray()

    downloadPlacesFile()
    let places_path = GlobalConstants.documents_directory.appendingPathComponent("rooms.plist")
    if (manager.fileExists(atPath: places_path)) {
        if (!readPlacesFile()){
            downloadPlacesFile()
        }
    } else {
        downloadPlacesFile()
    }
    processPlacesArray()

    createAvatarsDirectory()
    
    downloadPuppeteerPhotos()

    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
        print("Dispatch Async: Processing Photos")
        deleteInactivePuppeteerPhotos()
    })
}

func createAvatarsDirectory() {
    let manager = FileManager.default
    if (!(manager.fileExists(atPath: GlobalConstants.avatars_directory as String))) {
        _ = try? manager.createDirectory(atPath: GlobalConstants.avatars_directory as String, withIntermediateDirectories: false, attributes: nil)
    }
    print("Avatars: \(GlobalConstants.avatars_directory)")
}

func floorNumberToName (_ number: Int) -> String {
    var name = String()
    switch number {
        case 5:
            name = "Fifth Floor"
        case 6:
            name = "Sixth Floor"
        default:
            name = "Not in PDX"
    }
    return name
}
