//
//  ShareLinkProvider.swift
//  Listen Later
//
//  Created by Greg Hepworth on 06/06/2020.
//  Copyright © 2020 Breakbeat Ltd. All rights reserved.
//

import Foundation

class SharedCollectionManager {
  
  enum SourceProvider: String, Codable {
    case appleMusicAlbum
  }
  
  struct ShareableCollection: Codable {
    let schemaName = "jewel-shared-collection"
    let schemaVersion: Decimal = 1.1
    let collectionName: String
    let collectionCurator: String
    let collection: [ShareableSlot?]
    
    enum CodingKeys: String, CodingKey {
      case schemaName = "sn"
      case schemaVersion = "sv"
      case collectionName = "cn"
      case collectionCurator = "cc"
      case collection = "c"
    }
  }
  
  struct ShareableSlot: Codable {
    let sourceProvider: SourceProvider
    let sourceRef: String
    
    enum CodingKeys: String, CodingKey {
      case sourceProvider = "sp"
      case sourceRef = "sr"
    }
  }
  
  static func generateLongLink(for collection: Collection) -> URL? {
    var shareableSlots = [ShareableSlot?]()
    
    for slot in collection.slots {
      if let source = slot.source {
        let slot = ShareableSlot(sourceProvider: SourceProvider.appleMusicAlbum, sourceRef: source.id)
        shareableSlots.append(slot)
      } else {
        shareableSlots.append(nil)
      }
    }
    
    var collectionShareName = collection.name
    
    if collection.name == Navigation.Tab.onRotation.rawValue {
      let formatter = DateFormatter()
      formatter.dateFormat = "MMM yyyy"
      let dateString = formatter.string(from: Date())
      collectionShareName = "\(collection.curator)'s On Rotation - \(dateString)"
    }  else if collection.name.starts(with: "My ") {
      collectionShareName = collection.name.replaceFirstOccurrence(of: "My ", with: "\(collection.curator)'s ")
    }
    
    let shareableCollection = ShareableCollection(
      collectionName: collectionShareName,
      collectionCurator: collection.curator,
      collection: shareableSlots
    )
    
    do {
      let shareableCollectionJson = try JSONEncoder().encode(shareableCollection)
      return URL(string: "https://listenlater.link/s/?c=\(shareableCollectionJson.base64EncodedString())")!
    } catch {
      print(error)
      return nil
    }
  }
  
  static func setShareLinks(for collection: Collection) {
    
    AppEnvironment.global.update(action: LibraryAction.invalidateShareLinks(collectionId: collection.id))
    
    guard let longLink = generateLongLink(for: collection) else {
      print("💎 Share Links: > Could not create long link")
      AppEnvironment.global.navigation.shareLinkError = true
      return
    }
    
    let longDynamicLink = "https://listenlater.page.link/?link=\(longLink.absoluteString)"
    
    let firebaseShortLinkBodyRaw = ["longDynamicLink": longDynamicLink]
    guard let firebaseShortLinkBodyRawJSON = try? JSONEncoder().encode(firebaseShortLinkBodyRaw) else {
      print("💎 Share Links: > Could not encode link to JSON")
      AppEnvironment.global.navigation.shareLinkError = true
      return
    }
    
    guard let firebaseApiKey = Bundle.main.infoDictionary?["FIREBASE_API_KEY"] as? String else {
      print ("No Firebase API key found!")
      AppEnvironment.global.navigation.shareLinkError = true
      return
    }
    
    let firebaseRestUrl = URL(string: "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=\(firebaseApiKey)")!
    var request = URLRequest(url: firebaseRestUrl)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.uploadTask(with: request, from: firebaseShortLinkBodyRawJSON) { data, response, error in
      if let error = error {
        print ("Firebase API threw error: \(error)")
        AppEnvironment.global.navigation.shareLinkError = true
        return
      }
      guard let response = response as? HTTPURLResponse,
        (200...299).contains(response.statusCode) else {
          print ("Firebase gave a server error")
          AppEnvironment.global.navigation.shareLinkError = true
          return
      }
      if let mimeType = response.mimeType,
        mimeType == "application/json",
        let data = data {
        do {
          if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            DispatchQueue.main.async {
              if let shortLink = json["shortLink"] as? String {
                AppEnvironment.global.update(action: LibraryAction.setShareLinks(shareLinkLong: longLink, shareLinkShort: URL(string: shortLink)!, collectionId: collection.id))
              } else {
                print("💎 Share Links: > There was another error")
                AppEnvironment.global.navigation.shareLinkError = true
              }
            }
          }
        } catch let error as NSError {
          print("💎 Share Links: > Failed to load: \(error.localizedDescription)")
          AppEnvironment.global.navigation.shareLinkError = true
        }
      }
    }
    task.resume()
  }
  
  static func cueReceivedCollection(receivedCollectionUrl: URL) {
    if let urlComponents = URLComponents(url: receivedCollectionUrl, resolvingAgainstBaseURL: true) {
      let params = urlComponents.queryItems
      if let receivedCollectionEncoded = Data(base64Encoded: (params!.first(where: { $0.name == "c" })?.value!)!) {
        do {
          let shareableCollection = try JSONDecoder().decode(ShareableCollection.self, from: receivedCollectionEncoded)
          AppEnvironment.global.navigation = Navigation(onRotationId: AppEnvironment.global.navigation.onRotationId, activeCollectionId: AppEnvironment.global.navigation.activeCollectionId)
          AppEnvironment.global.update(action: LibraryAction.cueSharedCollection(shareableCollection: shareableCollection))
        } catch {
          print("💎 Shared Collection > Could not decode received collection: \(error)")
        }
      }
    }
  }
  
  static func expandShareableCollection(shareableCollection: ShareableCollection) {
    let collection = Collection(type: .sharedCollection, name: shareableCollection.collectionName, curator: shareableCollection.collectionCurator)
    
    AppEnvironment.global.update(action: LibraryAction.addSharedCollection(collection: collection))
    
    for (index, slot) in shareableCollection.collection.enumerated() {
      if slot?.sourceProvider == SourceProvider.appleMusicAlbum {
        RecordStore.purchase(album: slot!.sourceRef, forSlot: index, inCollection: collection.id)
      }
    }
  }
  
  static func loadRecommendations() {
    let request = URLRequest(url: URL(string: "https://listenlater.link/recommendations.json")!)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let data = data {
        if let decodedResponse = try? JSONDecoder().decode(ShareableCollection.self, from: data) {
          DispatchQueue.main.async {
            expandShareableCollection(shareableCollection: decodedResponse)
            return
          }
        }
      }
      
      print("💎 Load Recommendations > Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
    }.resume()
  }
  
}
