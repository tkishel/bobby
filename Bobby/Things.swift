import Foundation

func downloadThingsFile() {
    do {
        // TJK
        // let beers_url = URL(string: GlobalConstants.api_things_url)
        // let json_string = try Data(contentsOf: beers_url!)
        let test_file = Bundle.main.path(forResource: "puppet-things", ofType: "json")
        let json_string = try String(contentsOfFile: test_file!)
        // TJK
        let json_data = json_string.data(using: .utf8)!
        do {
            _ = try JSONSerialization.jsonObject(with: json_data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let beer_path = GlobalConstants.documents_directory.appendingPathComponent("beers.json")
            do {
                try json_string.write(toFile: beer_path, atomically: true, encoding: .utf8)
                print("Wrote Things to Cache")
            } catch let error as NSError {
                print("Error writing Things to Cache, Error: " + error.localizedDescription)
            }
        } catch let error as NSError {
            print("Error parsing Things, Error: " + error.localizedDescription)
        }
    } catch let error as NSError {
        print("Error downloading Things, Error:" + error.localizedDescription)
    }
}

func readThingsFile() -> Bool {
    let beers_path = GlobalConstants.documents_directory.appendingPathComponent("beers.json")
    thingsArray = []
    do {
        let json_string = try String(contentsOfFile: beers_path)
        let json_data = json_string.data(using: .utf8)!
        let json_array = try JSONSerialization.jsonObject(with: json_data,
                                                          options: JSONSerialization.ReadingOptions.mutableContainers)
        for beer in json_array as! [Dictionary<String, AnyObject>] {
            thingsArray.add(beer)
            let tap = (beer["tap"] as! String)
            let brewery = (beer["brewery"] as! String)
            let beer_name = (beer["beer_name"] as! String)
            thingsString = thingsString + "\(tap): \(brewery) \(beer_name)\n"
        }
        print("Read \(thingsArray.count) Things from Cache")
    } catch let error as NSError {
        print("Error reading Things from Cache, Error:" + error.localizedDescription)
    }
    let result = (thingsArray.count > 0)
    return result
}
