//
//  PhotoService.swift
//  Pitaza170
//
//  Created by Артем Тихонов on 19.11.2022.
//

import UIKit

class PhotoService{
    
    private var images = [String: UIImage]()
    
    private let cacheLifeTime:TimeInterval = 30 * 24 * 60 * 60
    
    private let container: DataReloadable
    
    init(container: UITableView){
        self.container = Table(table:container)
    }
    
    init(container: UICollectionView){
        self.container = Collection(collection:container)
    }
    
    private static let pathName:String = {
        let pathName = "images"
        
        guard let cacheDirecctory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {return pathName}
        let url = cacheDirecctory.appendingPathComponent(pathName,isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        
        return pathName
    }()
    
    
    ///загрузка изображения из images/кэша/интернета
    func photoAtIndexPath(atIndexPath indexPath: IndexPath, byUrl url: String,completion:((UIImage)->Void)? = nil) -> UIImage?{
        var image:UIImage?
        if let photo = images[url] {
            image = photo
        } else if let photo = getImageFromCache(url: url){
            image = photo
        } else {
            loadPhotoWithIndexPath(atIndexPath: indexPath, byUrl: url,completion: completion)
            image = images[url]
        }
        return image
    }
    
    ///загрузка изображения из кэша
    private func getImageFromCache(url:String) -> UIImage?{
        guard
            let fileName = getFilePath(url: url),
            let info = try? FileManager.default.attributesOfItem(atPath: fileName),
            let modificationDate = info[FileAttributeKey.modificationDate] as? Date else {return nil}
        let lifeTime = Date().timeIntervalSince(modificationDate)
        
        guard
            lifeTime <= cacheLifeTime,
            let image = UIImage(contentsOfFile: fileName) else {return nil}
    
            self.images[url] = image
        return image
    }
    
    /// метод, который возвращает путь до элемента
    private func getFilePath(url:String) -> String? {
        guard let  cacheDirectory  = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
        
        let hashName = url.split(separator: "/").last ?? "default"
        return cacheDirectory.appendingPathComponent(PhotoService.pathName + "/" + hashName).path
    }
    
    ///загрузка фото с API и сохранение его в кэш
    private func loadPhotoWithIndexPath(atIndexPath indexPath: IndexPath, byUrl url: String,completion:((UIImage)->Void)? = nil){
        guard let uurl = URL(string: url) else {return}
        URLSession.shared.dataTask(with: URLRequest(url: uurl), completionHandler: {[weak self] data, _, error in
            if let _ = error  {
                return
            }
            guard let data = data,
                  let image  = UIImage(data: data) else {
                return
            }
            self?.saveImageToCache(url: url, image :image)
            DispatchQueue.main.async {
                completion?(image)
                self?.container.reloadRow(atIndexpath: indexPath)
                self?.images[url] = image
            }
        }).resume()
    }
    
    ///сохранение фото в кэш
    private func saveImageToCache(url: String, image :UIImage){
        guard
            let fileName = getFilePath(url: url),
            let data = image.pngData() else {return}
        FileManager.default.createFile(atPath: fileName, contents: data, attributes: nil)
              
    }
}

fileprivate protocol DataReloadable {
    func reloadRow(atIndexpath indexPath:IndexPath)
}


///внутренние классы для перезагрузки ячеек коллекций
extension PhotoService {
    private class Table: DataReloadable{
        let table:UITableView
        
        init(table:UITableView){
            self.table = table
        }
        
        func reloadRow(atIndexpath indexPath: IndexPath) {
            table.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    private class Collection: DataReloadable{
        let collection:UICollectionView
        
        init(collection:UICollectionView){
            self.collection = collection
        }
        
        func reloadRow(atIndexpath indexPath: IndexPath) {
            collection.reloadItems(at: [indexPath])
        }
    }
}

///получение фото без индекспаса
extension PhotoService {
    func photo(byUrl url: String, completion:((UIImage) -> Void)? = nil) -> UIImage?{
        var image:UIImage?
        if let photo = images[url] {
            image = photo
            completion?(image!)
        } else if let photo = getImageFromCache(url: url){
            image = photo
            completion?(image!)
        }
        return image
    }
    
    private func loadPhoto(byUrl url: String,completion:((UIImage) -> Void)? = nil){
        guard let uurl = URL(string: url) else {return}
        URLSession.shared.dataTask(with: URLRequest(url: uurl), completionHandler: {[weak self] data, _, error in
            if let _ = error  {
                return
            }
            guard let data = data,
                  let image  = UIImage(data: data) else {
                return
            }
            self?.saveImageToCache(url: url, image :image)
            DispatchQueue.main.async {
                completion?(image)
                self?.images[url] = image
            }
        }).resume()
    }
}
