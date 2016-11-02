import Foundation

func downloadPlacesFile() {
    if (!(pingPong)) {
        print("No API!")
        return
    }
    do {
        // TJK
        // let places_url = URL(string: GlobalConstants.api_places_url)
        // let json_string = try Data(contentsOf: places_url!)
        let test_file = Bundle.main.path(forResource: "puppet-places", ofType: "json")
        let json_string = try String(contentsOfFile: test_file!)
        // TJK
        let json_data = json_string.data(using: .utf8)!
        do {
            _ = try JSONSerialization.jsonObject(with: json_data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let places_path = GlobalConstants.documents_directory.appendingPathComponent("places.json")
            do {
                try json_string.write(toFile: places_path, atomically: true, encoding: .utf8)
                print("Wrote Places to Cache")
            } catch let error as NSError {
                print("Error writing Places to Cache, Error: " + error.localizedDescription)
            }
        } catch let error as NSError {
            print("Error parsing Places, Error: " + error.localizedDescription)
        }
    } catch let error as NSError {
        print("Error downloading Places, Error:" + error.localizedDescription)
    }
}

func readPlacesFile() -> Bool {
    let places_path = GlobalConstants.documents_directory.appendingPathComponent("places.json")
    placesArray = []
    do {
        let json_string = try String(contentsOfFile: places_path)
        let json_data = json_string.data(using: .utf8)!
        let json_array = try JSONSerialization.jsonObject(with: json_data, options: JSONSerialization.ReadingOptions.mutableContainers)
        var sorted_places = json_array as! [Dictionary<String, AnyObject>]
        sorted_places.sort { ($0["name"] as? String)! < ($1["name"] as? String)! }
        placesSectionTitles.removeAllObjects()
        placesBySection.removeAllObjects()
        for place in sorted_places {
            placesArray.add(place)
            let name = (place["name"] as! String)
            let first_character = String(name[name.startIndex])
            if (placesBySection.object(forKey: first_character) == nil) {
                let placeNamesArray = NSMutableArray()
                placesBySection.setValue(placeNamesArray, forKey: first_character)
                placesSectionTitles.add(first_character)
            }
            (placesBySection.object(forKey: first_character) as! NSMutableArray).add(place)
        }
        print("Read \(placesArray.count) Places from Cache")
    } catch let error as NSError {
        print("Error reading Places from Cache, Error:" + error.localizedDescription)
    }
    
    let result = (placesArray.count > 0)
    return result
}
