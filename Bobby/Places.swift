import Foundation

func downloadPlacesFile() {
    if (!(pingPong)) {
        print("No pingPong!")
        return
    }

    let url = URL(string: GlobalConstants.api_places_url)
    do {
        let data = try Data(contentsOf: url!)
        let dataJSON = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
        if let places = dataJSON["places"] {
            placesSectionTitles.removeAllObjects()
            placesBySection.removeAllObjects()
            for index in (0...places.count-1) {
                let place = places[index] as! [String : AnyObject]
                let name = (place["name"] as! String)
                // TJK Convert JSON object to NSDictionary object, and add to placesArray.
                if (placesBySection.object(forKey: name) == nil) {
                    let placesNamesArray = NSMutableArray()
                    placesBySection.setValue(placesNamesArray, forKey: name)
                    placesSectionTitles.add(name)
                }
                (placesBySection.object(forKey: name) as! NSMutableArray).add(place)
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
    let path = GlobalConstants.documents_directory.appendingPathComponent("places.plist")
    let manager = FileManager.default
    if (manager.fileExists(atPath: path)) {
        placesArray = []
        placesArray = NSArray(contentsOfFile: path)!
    }
    let result = (placesArray.count > 0)
    print("Read \(placesArray.count) Places from Cache")
    return result
}
