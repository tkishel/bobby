import Foundation

func downloadPuppeteersFile() {
    if (!(pingPong)) {
        print("No API!")
        return
    }

    let url = URL(string: GlobalConstants.api_people_url)
    do {
        // let d_data = try Data(contentsOf: url!)
        // TJK For testing before changes to Robby.
        let dd = "{" +
            "\"puppeteeers\":[" +
            "{" +
            "\"first_name\":\"Tom\"," +
            "\"last_name\":\"Kishel\"," +
            "\"job_title\":\"Sr Supt Eng\"," +
            "\"photo_path\":\"tom.kishel.jpg\"," +
            "\"floor\":5," +
            "\"location_x\":256," +
            "\"location_y\":512" +
            "}," +
            "{" +
            "\"first_name\":\"Manuel\"," +
            "\"last_name\":\"Batule\"," +
            "\"job_title\":\"Sr Bus Sys Dev\"," +
            "\"photo_path\":\"manny.jpg\"," +
            "\"floor\":6," +
            "\"location_x\":256," +
            "\"location_y\":512" +
            "}" +
            "]" +
        "}"
        let data = dd.data(using: .utf8)!
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as! [String:AnyObject] {
            var puppeteeers = jsonData["puppeteeers"] as! [AnyObject]
            puppeteeers.sort { ($0["first_name"] as? String)! < ($1["first_name"] as? String)! }
            // TJK Simplify
            //let sorted = puppeteeers.sorted { left, right -> Bool in
            //    guard let rightKey = right["first_name"] as? String else { return true }
            //    guard let leftKey = left["first_name"] as? String else { return false }
            //    return leftKey < rightKey
            //}
            //puppeteeers = sorted
            puppeteersSectionTitles.removeAllObjects()
            puppeteersBySection.removeAllObjects()
            puppeteersPhotoArray.removeAllObjects()
            for i in (0...puppeteeers.count-1) {
                let puppeteer = puppeteeers[i]
                let first_name = (puppeteer["first_name"] as! String)
                puppeteersArray.add(puppeteer)
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
            let path = GlobalConstants.documents_directory.appendingPathComponent("people.plist")
            let result = puppeteersArray.write(toFile: path, atomically: true)
            if (result) {
                print("Wrote \(puppeteersArray.count) Puppeteers to Cache")
            } else {
                print("Error writing \(puppeteersArray.count) Puppeteers to Cache")
            }
            print("Processed \(puppeteersArray.count) Puppeteers")
        }
    }
    catch {
        print("Error downloading Puppeteers from \(GlobalConstants.api_people_url)")
    }
}

func readPuppeteersFile() -> Bool {
    let people_path = GlobalConstants.documents_directory.appendingPathComponent("people.plist")
    let manager = FileManager.default
    if (manager.fileExists(atPath: people_path)) {
        puppeteersArray = []
        puppeteersArray = NSArray(contentsOfFile: people_path)! as! NSMutableArray
    }
    print("Read \(puppeteersArray.count) Puppeteers from Cache")
    let result = (puppeteersArray.count > 0)
    return result
}

func createPuppeteerPhotosDirectory() -> Bool {
    let manager = FileManager.default
    if (!(manager.fileExists(atPath: GlobalConstants.avatars_directory as String))) {
        _ = try? manager.createDirectory(atPath: GlobalConstants.avatars_directory as String, withIntermediateDirectories: false, attributes: nil)
    }
    return (manager.fileExists(atPath: GlobalConstants.avatars_directory as String))
}

func downloadPuppeteerPhotos() -> Bool {
    _ = createPuppeteerPhotosDirectory()
    for item in puppeteersArray {
        let puppeteer = item as! NSDictionary
        let profile_photo = puppeteer["photo_path"] as! String
        downloadPuppeteerPhoto(profile_photo)
    }
    // print("Downloaded Puppeteer Photos")
    return true
}

func downloadPuppeteerPhoto(_ profile_photo: String) {
    var photo_data = Data()
    if (profile_photo.isEmpty) {
        return
    }
    let path = GlobalConstants.avatars_directory.appendingPathComponent(profile_photo)
    let manager = FileManager.default
    if (manager.fileExists(atPath: path)) {
        if let file_attributes : NSDictionary = try! manager.attributesOfItem(atPath: path) as NSDictionary? {
            var file_date = Date()
            file_date = file_attributes.fileCreationDate()!

            downloadPuppeteerPhotoFileHeader(profile_photo, completion: { (photo_date) -> () in
                if (file_date.compare(photo_date) == ComparisonResult.orderedAscending) {
                    // print("File Older, Downloading Puppeteer Photo \(profile_photo)")
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
        // print("File Missing, Downloading Puppeteer Photo \(profile_photo) ")
        photo_data = downloadPuppeteerPhotoFile(profile_photo)
        if (photo_data.count != 0) {
            _ = writePuppeteerPhotoFile(profile_photo, photo_data: photo_data)
        }
    }
}

func downloadPuppeteerPhotoFileHeader(_ profile_photo: String, completion: ((_ photo_date: Date) -> ())?) {
    let noDate = Date(timeIntervalSinceReferenceDate: 0)
    let photo_url = "\(GlobalConstants.api_avatars_url)\(profile_photo)"
    let session = URLSession.shared
    let url = URL(string: photo_url)
    var request = URLRequest(url: url!)
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
    if (!(pingPong)) {
        print("No pingPong!")
        return empty_photo_data
    }
    if (profile_photo.isEmpty) {
        return empty_photo_data
    }
    let url = URL(string: "\(GlobalConstants.api_avatars_url)\(profile_photo)")
    print("Looking for Puppeteer Photo \(url)")
    if let photo_data = try? Data(contentsOf: url!) {
        print("Read Puppeteer Photo from URL \(profile_photo)")
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
    let path = GlobalConstants.avatars_directory.appendingPathComponent(profile_photo)
    let manager = FileManager.default
    if (manager.fileExists(atPath: path)) {
        photo_data = try! Data(contentsOf: URL(fileURLWithPath: path))
        // print("Read Puppeteer Photo from Cache \(profile_photo) ")
    }
    return photo_data
}

func writePuppeteerPhotoFile(_ profile_photo: String, photo_data: Data) -> Bool {
    if (profile_photo.isEmpty) {
        print("No profile_photo \(profile_photo)")
        return false
    }
    if (photo_data.count == 0) {
        print("No photo_data length ")
        return false
    }
    let path = GlobalConstants.avatars_directory.appendingPathComponent(profile_photo)
    let result = (try? photo_data.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil
    if (result) {
        print("Wrote Puppeteer Photo to Cache \(profile_photo) ")
    }
    return result
}

func deleteInactivePuppeteerPhotos() -> Bool {
    let manager = FileManager.default
    let file_list = try? manager.contentsOfDirectory(atPath: GlobalConstants.avatars_directory as String)
    for file_name in file_list! {
        let file_path = file_name as NSString
        // print("Checking in Cache \(file_path) ")
        if (puppeteersPhotoArray.object(forKey: file_path) == nil) {
            // print("Deleting from Cache \(file_path) ")
            _ = try? manager.removeItem(atPath: file_path as String)
        }
    }
    // print("Deleted Inactive Puppeteer Photos from Cache")
    return true
}
