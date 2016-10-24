import Foundation

struct GlobalConstants {
    static let documents_paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
    static let documents_directory = documents_paths.object(at: 0) as! NSString
    static let avatars_directory = documents_directory.appendingPathComponent("avatars") as NSString
    static let api_ping_pong = "https://robby.puppetlabs.net/" as String
    static let api_people_url = "https://robby.puppetlabs.net/people" as String
    static let api_places_url = "https://robby.puppetlabs.net/resources" as String
    static let api_avatars_url = "https://robby-images.s3.amazonaws.com/" as String
    static let default_avatar = Bundle.main.path(forResource: "generic", ofType: "png")
    static let pdx_floor5 = Bundle.main.path(forResource: "pdx_floor5", ofType: "png")
    static let pdx_floor6 = Bundle.main.path(forResource: "pdx_floor6", ofType: "png")
}

var pingPong = false

var puppeteersArray: NSMutableArray = []
var puppeteersSectionTitles = NSMutableArray()
var puppeteersBySection = NSMutableDictionary()
var puppeteersPhotoArray = NSMutableDictionary()

var placesArray: NSMutableArray = []
var placesSectionTitles = NSMutableArray()
var placesBySection = NSMutableDictionary()

// convert to background task

func pingRobby() {
    pingPong = false;
    let url = URL(string: GlobalConstants.api_ping_pong)
    let request = NSMutableURLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 3)
    var response: URLResponse?
    _ = try? NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
    if let http_response = response as? HTTPURLResponse {
        if (http_response.statusCode == 200) {
            pingPong = true;
        }
        print("Ping: \(GlobalConstants.api_ping_pong) \(http_response.statusCode)")
    } else {
        print("Ping: \(GlobalConstants.api_ping_pong) No HTTP Response")
    }
}

func launchPuppetApplication() {
    pingRobby()
    
    // TJK For testing before changes to Robby.
    pingPong = true
    
    print("Cache: \(GlobalConstants.documents_directory)")

    downloadPuppeteersFile()
    if (!readPuppeteersFile()) {
        downloadPuppeteersFile()
    }

    downloadPlacesFile()
    if (!readPlacesFile()){
        downloadPlacesFile()
    }

    _ = downloadPuppeteerPhotos()

    DispatchQueue.global(qos: .background).async(execute: {
        print("Dispatch Async: Processing Photos")
        _ = deleteInactivePuppeteerPhotos()
    })
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
