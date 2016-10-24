import Foundation

//var descriptor: NSSortDescriptor = NSSortDescriptor(key: "first_name", ascending: true)
//var sortedPlacesArray: NSArray = puppeteersArray.sortedArrayUsingDescriptors([descriptor])

func downloadPlacesFile() {
    if (!(pingPong)) {
        print("No API!")
        return
    }

    let url = URL(string: GlobalConstants.api_places_url)
    do {
        // let d_data = try Data(contentsOf: url!)
        // TJK For testing before changes to Robby.
        let dd = "{" +
            "\"places\":[" +
            "{" +
            "\"location\":\"PDX5-05-S-R2D2-VC\"," +
            "\"name\":\"R2D2\"" +
            "}," +
            "{" +
            "\"location\":\"PDX5-05-S-C3PO-VC\"," +
            "\"name\":\"C3PO\"" +
            "}" +
            "]" +
        "}"
        let data = dd.data(using: .utf8)!
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as! [String:AnyObject] {
            let places = jsonData["places"] as! [AnyObject]
            placesSectionTitles.removeAllObjects()
            placesBySection.removeAllObjects()
            for i in (0...places.count-1) {
                let place = places[i]
                if let name = place["name"] as? String {
                  placesArray.add(place)
                  if (placesBySection.object(forKey: name) == nil) {
                      let placesNamesArray = NSMutableArray()
                      placesBySection.setValue(placesNamesArray, forKey: name)
                      placesSectionTitles.add(name)
                  }
                  (placesBySection.object(forKey: name) as! NSMutableArray).add(place)
                }
            }
            let path = GlobalConstants.documents_directory.appendingPathComponent("places.plist")
            let result = placesArray.write(toFile: path, atomically: true)
            if (result) {
                print("Wrote \(placesArray.count) Places to Cache")
            } else {
                print("Error writing \(placesArray.count) Places to Cache")
            }
            print("Processed \(placesArray.count) Places")
        }
    }
    catch {
        print("Error downloading Places from \(GlobalConstants.api_places_url)")
    }
}

func readPlacesFile() -> Bool {
    let places_path = GlobalConstants.documents_directory.appendingPathComponent("places.plist")
    let manager = FileManager.default
    if (manager.fileExists(atPath: places_path)) {
        placesArray = []
        placesArray = NSArray(contentsOfFile: places_path)! as! NSMutableArray
    }
    print("Read \(placesArray.count) Places from Cache")
    let result = (placesArray.count > 0)
    return result
}
