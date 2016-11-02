import Foundation

func downloadPuppeteersFile() {
    if (!(pingPong)) {
        print("No API!")
        return
    }
    let people_url = URL(string: GlobalConstants.api_people_url)
    do {
        // let d_data = try Data(contentsOf: people_url!)
        // TJK For testing before changes to Robby.
        let test_file = Bundle.main.path(forResource: "puppet-people", ofType: "json")
        let json_string = try String(contentsOfFile: test_file!)
        // TJK
        let json_data = json_string.data(using: .utf8)!
        do {
            _ = try JSONSerialization.jsonObject(with: json_data, options: [.allowFragments]) as! [String:AnyObject]
            let people_path = GlobalConstants.documents_directory.appendingPathComponent("people.json")
            do {
                try json_string.write(toFile: people_path, atomically: true, encoding: .utf8)
                print("Wrote Puppeteers to Cache")
            } catch let error as NSError {
                print("Error writing Puppeteers to Cache, Error: " + error.localizedDescription)
            }
        } catch let error as NSError {
            print("Error parsing Puppeteers, Error: " + error.localizedDescription)
        }
    } catch let error as NSError {
        print("Error downloading Puppeteers, Error:" + error.localizedDescription)
    }
}

func readPuppeteersFile() -> Bool {
    let people_path = GlobalConstants.documents_directory.appendingPathComponent("people.json")
    puppeteersArray = []
    do {
        let json_string = try String(contentsOfFile: people_path)
        let json_data = json_string.data(using: .utf8)!
        let json_object = try JSONSerialization.jsonObject(with: json_data, options: [.allowFragments]) as! [String:AnyObject]
        var puppeteers = json_object["puppeteers"] as! [AnyObject]
        puppeteers.sort { ($0["first_name"] as? String)! < ($1["first_name"] as? String)! }
        puppeteersSectionTitles.removeAllObjects()
        puppeteersBySection.removeAllObjects()
        puppeteersPhotoArray.removeAllObjects()
        for i in (0...puppeteers.count-1) {
            let puppeteer = puppeteers[i]
            puppeteersArray.add(puppeteer)
            let first_name = (puppeteer["first_name"] as! String)
            let first_character = String(first_name[first_name.startIndex])
            if (puppeteersBySection.object(forKey: first_character) == nil) {
                let puppeteerNamesArray = NSMutableArray()
                puppeteersBySection.setValue(puppeteerNamesArray, forKey: first_character)
                puppeteersSectionTitles.add(first_character)
            }
            (puppeteersBySection.object(forKey: first_character) as! NSMutableArray).add(puppeteer)
            let profile_photo = puppeteer["photo_path"] as! String
            if (!(profile_photo.isEmpty)) {
                puppeteersPhotoArray.setValue(1, forKey: profile_photo)
            }
        }
        print("Read \(puppeteersArray.count) Puppeteers from Cache")
    } catch let error as NSError {
        print("Error reading Puppeteers from Cache, Error:" + error.localizedDescription)
    }

    let result = (puppeteersArray.count > 0)
    return result
}

func ensurePuppeteerPhotosDirectory() -> Bool {
    let file_manager = FileManager.default
    if (!(file_manager.fileExists(atPath: GlobalConstants.avatars_directory as String))) {
        _ = try? file_manager.createDirectory(atPath: GlobalConstants.avatars_directory as String, withIntermediateDirectories: false, attributes: nil)
    }
    return (file_manager.fileExists(atPath: GlobalConstants.avatars_directory as String))
}

func downloadPuppeteerPhotos() -> Bool {
    _ = ensurePuppeteerPhotosDirectory()
    for item in puppeteersArray {
        let puppeteer = item as! NSDictionary
        let profile_photo = puppeteer["photo_path"] as! String
        downloadPuppeteerPhoto(profile_photo)
    }
    print("Downloaded Puppeteer Photos")
    return true
}

func downloadPuppeteerPhoto(_ profile_photo: String) {
    var photo_data = Data()
    if (profile_photo.isEmpty) {
        return
    }
    let path = GlobalConstants.avatars_directory.appendingPathComponent(profile_photo)
    let file_manager = FileManager.default
    if (file_manager.fileExists(atPath: path)) {
        if let file_attributes : NSDictionary = try! file_manager.attributesOfItem(atPath: path) as NSDictionary? {
            var file_date = Date()
            file_date = file_attributes.fileCreationDate()!

            downloadPuppeteerPhotoFileHeader(profile_photo, completion: { (photo_date) -> () in
                if (file_date.compare(photo_date) == ComparisonResult.orderedAscending) {
                    print("File Older, Downloading Puppeteer Photo \(profile_photo)")
                    photo_data = downloadPuppeteerPhotoFile(profile_photo)
                    if (photo_data.count != 0) {
                        // print("Writing \(profile_photo) Puppeteer Photo")
                        _ = writePuppeteerPhotoFile(profile_photo, photo_data: photo_data)
                    }
                } else {
                    // print("File Newer, Keeping Puppeteer Photo \(profile_photo) ")
                }
            })

        } else {
            // print("File Attribute Error, Updating Puppeteer Photo \(profile_photo) ")
            photo_data = downloadPuppeteerPhotoFile(profile_photo)
            if (photo_data.count != 0) {
                _ = writePuppeteerPhotoFile(profile_photo, photo_data: photo_data)
            }
        }
    } else {
        print("File Missing, Downloading Puppeteer Photo \(profile_photo)")
        photo_data = downloadPuppeteerPhotoFile(profile_photo)
        if (photo_data.count != 0) {
            _ = writePuppeteerPhotoFile(profile_photo, photo_data: photo_data)
        }
    }
}

func downloadPuppeteerPhotoFileHeader(_ profile_photo: String, completion: ((_ photo_date: Date) -> ())?) {
    let noDate = Date(timeIntervalSinceReferenceDate: 0)
    let session = URLSession.shared
    let photo_url = URL(string: "\(GlobalConstants.api_avatars_url)\(profile_photo)")
    var request = URLRequest(url: photo_url!)
    request.httpMethod = "HEAD"
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
        if let http_response = response as? HTTPURLResponse {
            let headers = http_response.allHeaderFields as NSDictionary
            // print("Headers for \(photo_url) \(headers)")
            if let url_date = headers.object(forKey: "Last-Modified") as? NSString {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
                var urlDate = Date()
                urlDate = dateFormatter.date(from: url_date as String)!
                if (completion != nil) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion!(urlDate)
                    })
                }
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    completion!(noDate)
                })
            }
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
                completion!(noDate)
            })
        }
    })
    task.resume()
}

func downloadPuppeteerPhotoFile(_ profile_photo: String) -> Data {
    let empty_photo_data = Data()
    if (profile_photo.isEmpty) {
        return empty_photo_data
    }
    let photo_url = URL(string: "\(GlobalConstants.api_avatars_url)\(profile_photo)")
    // print("Looking for Puppeteer Photo from \(photo_url)")
    if let photo_data = try? Data(contentsOf: photo_url!) {
        print("Downloaded Puppeteer Photo \(profile_photo)")
        return photo_data
    }
    return empty_photo_data
}

func readDefaultPuppeteerPhotoFile() -> Data {
    var photo_data = Data()
    photo_data = try! Data(contentsOf: URL(fileURLWithPath: GlobalConstants.default_avatar!))
    // print("Read Default Puppeteer Photo from File")
    return photo_data
}

func readPuppeteerPhotoFile(_ profile_photo: String) -> Data {
    var photo_data = Data()
    if (profile_photo.isEmpty) {
        return photo_data
    }
    let photo_path = GlobalConstants.avatars_directory.appendingPathComponent(profile_photo)
    let file_manager = FileManager.default
    if (file_manager.fileExists(atPath: photo_path)) {
        photo_data = try! Data(contentsOf: URL(fileURLWithPath: photo_path))
        // print("Read Puppeteer Photo from Cache \(profile_photo)")
    }
    return photo_data
}

func writePuppeteerPhotoFile(_ profile_photo: String, photo_data: Data) -> Bool {
    if (profile_photo.isEmpty) {
        print("Error writing Puppeteer Photo to Cache \(profile_photo): Empty")
        return false
    }
    if (photo_data.count == 0) {
        print("Error writing Puppeteer Photo to Cache \(profile_photo): Zero")
        return false
    }
    let photo_path = GlobalConstants.avatars_directory.appendingPathComponent(profile_photo)
    let result = (try? photo_data.write(to: URL(fileURLWithPath: photo_path), options: [.atomic])) != nil
    if (result) {
        print("Wrote Puppeteer Photo to Cache \(profile_photo)")
    }
    return result
}

func deleteInactivePuppeteerPhotos() -> Bool {
    let file_manager = FileManager.default
    let file_list = try? file_manager.contentsOfDirectory(atPath: GlobalConstants.avatars_directory as String)
    for file_name in file_list! {
        let file_name_as_nsstring = file_name as NSString
        // print("Checking in Cache \(file_name_as_nsstring) ")
        if (puppeteersPhotoArray.object(forKey: file_name_as_nsstring) == nil) {
            print("Deleting Inactive Puppeteer Photo from Cache \(file_name_as_nsstring) ")
            _ = try? file_manager.removeItem(atPath: file_name_as_nsstring as String)
        }
    }
    print("Deleted Inactive Puppeteer Photos from Cache")
    return true
}
