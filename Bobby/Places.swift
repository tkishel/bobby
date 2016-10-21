import Foundation

func downloadPlacesFile() {
    if (!(pingPong)) {
        print("No pingPong!")
        return
    }
    let url = URL(string: GlobalConstants.api_places_plist)
    placesData = NSData(data: try! Data(contentsOf: url!)) as Data as Data
    if (placesData != nil) {
        let format: UnsafeMutablePointer <PropertyListSerialization.PropertyListFormat> = UnsafeMutablePointer(nil)
        placesArray = try! PropertyListSerialization.propertyList(from: placesData! as Data, options: PropertyListSerialization.MutabilityOptions.mutableContainersAndLeaves, format: format) as! NSArray
        print("Downloaded Places PList")
        writePlacesFile()
    } else {
        print("Error Downloading Places PList")
    }
}

func readPlacesFile() -> Bool {
    let path = GlobalConstants.documents_directory.appendingPathComponent("rooms.plist")
    let manager = FileManager.default
    if (manager.fileExists(atPath: path)) {
        placesArray = []
        placesArray = NSArray(contentsOfFile: path)!
    }
    let result = (placesArray.count > 0)
    print("Read \(placesArray.count) Places from Cache")
    return result
}

func writePlacesFile() -> Bool {
    let path = GlobalConstants.documents_directory.appendingPathComponent("rooms.plist")
    let result = placesArray.write(toFile: path, atomically: true)
    if (result) {
        print("Wrote \(placesArray.count) Places to Cache")
    } else {
        print("Error writing \(placesArray.count) Places to Cache")
    }
    return result
}

func processPlacesArray(){
    placesSectionTitles.removeAllObjects()
    placesBySection.removeAllObjects()
    
    let descriptor: NSSortDescriptor = NSSortDescriptor(key: "client", ascending: true)
    let sortedPlacesArray: NSArray = placesArray.sortedArray(using: [descriptor])
    
    for item in sortedPlacesArray {
        let place = item as! NSDictionary
        var name = place["client"] as! String
        if (name.isEmpty) {
            name = "Open"
        }
        let key = name
        if (placesBySection.object(forKey: key) == nil) {
            let placesNamesArray = NSMutableArray()
            placesBySection.setValue(placesNamesArray, forKey: key)
            placesSectionTitles.add(key)
        }
        (placesBySection.object(forKey: key) as! NSMutableArray).add(place)
   }
    print("Processed \(placesArray.count) Places")
}
