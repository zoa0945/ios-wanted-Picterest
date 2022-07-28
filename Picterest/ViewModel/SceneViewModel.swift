//
//  SceneViewModel.swift
//  Picterest
//
//  Created by Mac on 2022/07/26.
//

import UIKit
import CoreData

class SceneViewModel {
    private let networkService = UnsplashAPI()
    private let appdelegate = UIApplication.shared.delegate as! AppDelegate
    private lazy var context = appdelegate.persistentContainer.viewContext
    
    func getImageURLs(_ completion: @escaping (Result<[RandomPhoto], Error>) -> Void) {
        return networkService.getPhoto(completion)
    }
    
    private func configFileManager(_ id: String) -> URL {
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let filePath = docDir.appendingPathComponent("\(id).png")
        
        return filePath
    }
    
    func saveData(_ randomPhoto: RandomPhoto, _ memo: String) {
        let filePath = configFileManager(randomPhoto.id)
        let newPhoto = Photo(context: self.context)
        newPhoto.memo = memo
        newPhoto.id = randomPhoto.id
        newPhoto.filepath = filePath
        newPhoto.imageurl = randomPhoto.urls.thumb
        
        LoadImage().loadImage(randomPhoto.urls.thumb) { result in
            switch result {
            case .success(let image):
                if let data = image.pngData() {
                    do {
                        try data.write(to: filePath)
                    } catch {
                        print("filemanager save error: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        do {
            try self.context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func fetchCoreData() -> [Photo] {
        do {
            let request = Photo.fetchRequest()
            let photos = try context.fetch(request)
            print("success")
            return photos
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
}