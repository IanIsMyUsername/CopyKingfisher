//
//  ImageCache.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/5.
//  Copyright © 2020 陈奕舟. All rights reserved.
//
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension Notification.Name {
    /// This notification will be sent when the disk cache got cleaned either there are cached files expired or the
    /// total size exceeding the max allowed size. The manually invoking of `clearDiskCache` method will not trigger
    /// this notification.
    ///
    /// The `object` of this notification is the `ImageCache` object which sends the notification.
    /// A list of removed hashes (files) could be retrieved by accessing the array under
    /// `KingfisherDiskCacheCleanedHashKey` key in `userInfo` of the notification object you received.
    /// By checking the array, you could know the hash codes of files are removed.
    public static let KingfisherDidCleanDiskCache = Notification.Name("com.onevcat.Kingfisher.KingfisherDidCleanDiskCache")
}

/// Key for array of cleaned hashes in `userInfo` of `KingfisherDidCleanDiskCacheNotification`.
public let KingfisherDiskCacheCleanedHashKey = "com.onevcat.Kingfisher.cleanedHash"

/// Cache type of a cached image.
/// - none: The image is not cached yet when retrieving it.
/// - memory: The image is cached in memory.
/// - disk: The image is cached in disk.
public enum CacheType {
/// The image is not cached yet when retrieving it.
    case none
    /// The image is cached in memory.
    case memory
    /// The image is cached in disk.
    case disk
    
    /// Whether the cache type represents the image is already cached or not.
    public var cached: Bool {
        switch self {
        case .memory, .disk: return true
        case .none: return false
        }
    }
}

/// Represents the caching operation result.
public struct CacheStoreResult {
    /// The cache result for memory cache. Caching an image to memory will never fail.
    public let memoryCacheResult: Result<(), Never>
    
    /// The cache result for disk cache. If an error happens during caching operation,
    /// you can get it from `.failure` case of this `diskCacheResult`.
    let diskCacheResult: Result<(), KingfisherError>
}

extension KFCrossPlatformImage: CacheCostCalculable {
    /// Cost of an image
    public var cacheCost:Int { return kf.cost }
    
}

extension Data: DataTransformable {
    public func toData() throws -> Data {
        return self
    }
    
    public static func fromData(_ data: Data) throws -> Data {
        return data
    }
    
    public static let empty = Data()
}

/// Represents the getting image operation from the cache.
///
/// - disk: The image can be retrieved from disk cache.
/// - memory: The image can be retrieved memory cache.
/// - none: The image does not exist in the cache.
public enum ImageCacheResult {
    
    /// The image can be retrieved from disk cache.
    case disk(KFCrossPlatformImage)
    
    /// The image can be retrieved memory cache.
    case memory(KFCrossPlatformImage)
    
    /// The image does not exist in the cache.
    case none
    
    /// Extracts the image from cache result. It returns the associated `Image` value for
    /// `.disk` and `.memory` case. For `.none` case, `nil` is returned.
    public var image: KFCrossPlatformImage? {
        switch self {
        case .disk(let image): return image
        case .memory(let image): return image
        case .none: return nil
        }
    }
    
    /// Returns the corresponding `CacheType` value based on the result type of `self`.
    public var cacheType: CacheType {
        switch self {
        case .disk: return .disk
        case .memory: return .memory
        case .none: return .none
        }
    }
}

/// Represents a hybrid caching system which is composed by a `MemoryStorage.Backend` and a `DiskStorage.Backend`.
/// `ImageCache` is a high level abstract for storing an image as well as its data to disk memory and disk, and
/// retrieving them back.
///
/// While a default image cache object will be used if you prefer the extension methods of Kingfisher, you can create
/// your own cache object and configure its storages as your need. This class also provide an interface for you to set
/// the memory and disk storage config.
open class ImageCache {
    
    // MARK: Singleton
    /// The default `ImageCache` object. Kingfisher will use this cache for its related methods if there is no
    /// other cache specified. The `name` of this default cache is "default", and you should not use this name
    /// for any of your customize cache.
    public static let `default` = ImageCache(name: "default")
    
    // MARK: Public Properties
    /// The `MemoryStorage.Backend` object used in this cache. This storage holds loaded images in memory with a
    /// reasonable expire duration and a maximum memory usage. To modify the configuration of a storage, just set
    /// the storage `config` and its properties.
    public let memoryStorage: MemoryStorage.Backend<KFCrossPlatformImage>
    
    /// The `DiskStorage.Backend` object used in this cache. This storage stores loaded images in disk with a
    /// reasonable expire duration and a maximum disk usage. To modify the configuration of a storage, just set
    /// the storage `config` and its properties.
    public let diskStorage: DiskStorage.Backend<Data>
    
    private let ioQueue: DispatchQueue
    
    /// Closure that defines the disk cache path from a given path and cacheName.
    public typealias DiskCachePathClosure = (URL, String) -> URL
    
    // MARK: Initializers

    /// Creates an `ImageCache` from a customized `MemoryStorage` and `DiskStorage`.
    ///
    /// - Parameters:
    ///   - memoryStorage: The `MemoryStorage.Backend` object to use in the image cache.
    ///   - diskStorage: The `DiskStorage.Backend` object to use in the image cache.
    public init(
        memoryStorage: MemoryStorage.Backend<KFCrossPlatformImage>,
        diskStorage: DiskStorage.Backend<Data>
    ) {
        self.memoryStorage = memoryStorage
        self.diskStorage = diskStorage
        let ioQueueName = "com.onevcat.Kingfisher.ImageCache.ioQueue. \(UUID().uuidString)"
        ioQueue = DispatchQueue(label: ioQueueName)
        
        let notifications: [(Notification.Name, Selector)]
        #if !os(macOS) && !os(watchOS)
        #if swift(>=4.2)
        notifications = [
            (UIApplication.didReceiveMemoryWarningNotification, #selector(clearMemoryCache)),
            (UIApplication.willTerminateNotification, #selector(cleanExpiredDiskCache)),
            (UIApplication.didEnterBackgroundNotification, #selector(backgroundCleanExpiredDiskCache))
        ]
        #else
        notifications = [
            (NSNotification.Name.UIApplicationDidReceiveMemoryWarning, #selector(clearMemoryCache)),
            (NSNotification.Name.UIApplicationWillTerminate, #selector(cleanExpiredDiskCache)),
            (NSNotification.Name.UIApplicationDidEnterBackground, #selector(backgroundCleanExpiredDiskCache))
        ]
        #endif
        #elseif os(macOS)
        notifications = [
            (NSApplication.willResignActiveNotification, #selector(cleanExpiredDiskCache)),
        ]
        #else
        notifications = []
        #endif

        notifications.forEach { NotificationCenter.default.addObserver(self, selector: $0.1, name: $0.0, object: nil)
        }
    }
    
    /// Creates an `ImageCache` with a given `name`. Both `MemoryStorage` and `DiskStorage` will be created
    /// with a default config based on the `name`.
    ///
    /// - Parameter name: The name of cache object. It is used to setup disk cache directories and IO queue.
    ///                   You should not use the same `name` for different caches, otherwise, the disk storage would
    ///                   be conflicting to each other. The `name` should not be an empty string.
    public convenience init(name: String) {
        try! self.init(name: name, cacheDirectoryURL: nil, diskCachePathClosure: nil)
    }
    
    /// Creates an `ImageCache` with a given `name`, cache directory `path`
    /// and a closure to modify the cache directory.
    ///
    /// - Parameters:
    ///   - name: The name of cache object. It is used to setup disk cache directories and IO queue.
    ///           You should not use the same `name` for different caches, otherwise, the disk storage would
    ///           be conflicting to each other.
    ///   - cacheDirectoryURL: Location of cache directory URL on disk. It will be internally pass to the
    ///                        initializer of `DiskStorage` as the disk cache directory. If `nil`, the cache
    ///                        directory under user domain mask will be used.
    ///   - diskCachePathClosure: Closure that takes in an optional initial path string and generates
    ///                           the final disk cache path. You could use it to fully customize your cache path.
    /// - Throws: An error that happens during image cache creating, such as unable to create a directory at the given
    ///           path.
    public convenience init(
        name: String,
        cacheDirectoryURL: URL?,
        diskCachePathClosure: DiskCachePathClosure? = nil) throws
    {
        if name.isEmpty {
            fatalError("[Kingfisher] You should specify a name for the cache. A cache with empty name is not permitted.")
        }
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let costLimit = totalMemory / 4
        let memoryStorage = MemoryStorage.Backend<KFCrossPlatformImage>.init(config: .init(totalCostLimit: (costLimit > Int.max) ? Int.max : Int(costLimit)))
        var diskConfig = DiskStorage.Config(name: name, sizeLimit: 0, directory: cacheDirectoryURL)
        if let closur = diskCachePathClosure {
            diskConfig.cachePathBlock = closur
        }
        let diskStorage = try DiskStorage.Backend<Data>(config: diskConfig)
        diskConfig.cachePathBlock = nil
        
        self.init(memoryStorage: memoryStorage, diskStorage:diskStorage)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    // MARK: Storing Images
    open func store(
        _ image: KFCrossPlatformImage,
        original: Data? = nil,
        forKey key: String,
        options: KingfisherParsedOptionsInfo,
        toDisk:Bool = true,
        completionHandler:((CacheStoreResult) -> Void)? = nil)
        {
            let identifier = options.processor.identifier
            let callbackQueue = options.
            
            
    }
    
    // MARK: Cleaning
    /// Clears the memory storage of this cache.
    @objc public func clearMemoryCache() {
        try? memoryStorage.removeAll()
    }
    
    /// Clears the disk storage of this cache. This is an async operation.
    ///
    /// - Parameter handler: A closure which is invoked when the cache clearing operation finishes.
    /// This `handler` will be called from the main queue.
    open func clearDiskCache(completion handler: (()->())? = nil) {
        ioQueue.async {
            do {
                try self.diskStorage.removeAll()
            } catch _ { }
            if let handler = handler {
                DispatchQueue.main.async { handler() }
            }
        }
    }
    
    /// Clears the expired images from disk storage. This is an async operation.
    open func cleanExpiredMemoryCache() {
        memoryStorage.removeExpired()
    }
    
    /// Clears the expired images from disk storage. This is an async operation.
    @objc func cleanExpiredDiskCache() {
        cleanExpiredDiskCache(completion: nil)
    }
    
    /// Clears the expired images from disk storage. This is an async operation.
    ///
    /// - Parameter handler: A closure which is invoked when the cache clearing operation finishes.
    /// This `handler` will be called from the main queue.
    func cleanExpiredDiskCache(completion handler: (()->Void)? = nil) {
        ioQueue.async {
            do {
                var removed: [URL] = []
                let removedExpired = try self.diskStorage.removeExpiredValues()
                removed.append(contentsOf: removedExpired)
                
                let removedSizeExceeded = try self.diskStorage.removeSizeExceededValues()
                removed.append(contentsOf: removedSizeExceeded)
                
                if !removed.isEmpty {
                    DispatchQueue.main.async {
                        let cleanedHashes = removed.map { $0.lastPathComponent}
                        NotificationCenter.default.post(name: .KingfisherDidCleanDiskCache, object: self, userInfo: [KingfisherDiskCacheCleanedHashKey: cleanedHashes])
                    }
                }
                
                if let handler = handler {
                    DispatchQueue.main.async {
                        handler()
                    }
                }
                
            } catch {}
        }
    }

#if !os(macOS) && !os(watchOS)
    /// Clears the expired images from disk storage when app is in background. This is an async operation.
    /// In most cases, you should not call this method explicitly.
    /// It will be called automatically when `UIApplicationDidEnterBackgroundNotification` received.
    @objc public func backgroundCleanExpiredDiskCache() {
//         if 'sharedApplication()' is unavailable, then return
        guard let shareApplication = KingfisherWrapper<UIApplication>.shared else {
            return
        }
        
        func endBackgroundTask(_ task: inout UIBackgroundTaskIdentifier) {
            shareApplication.endBackgroundTask(task)
            #if swift(>=4.2)
            task = UIBackgroundTaskIdentifier.invalid
            #else
            task = UIBackgroundTaskInvalid
            #endif
        }
        
        var backgroundTask: UIBackgroundTaskIdentifier!
        backgroundTask = shareApplication.beginBackgroundTask(expirationHandler: {
            endBackgroundTask(&backgroundTask!)
        })
        
        cleanExpiredDiskCache {
            endBackgroundTask(&backgroundTask!)
        }
    }
#endif
        
        
}

#if !os(macOS) && !os(watchOS)
// MARK: - For App Extensions
extension UIApplication: KingfisherCompatible { }
extension KingfisherWrapper where Base: UIApplication {
    public static var shared: UIApplication? {
        let selector = NSSelectorFromString("sharedApplication")
        guard Base.responds(to: selector) else {
            return nil
        }
        return Base.perform(selector).takeUnretainedValue() as? UIApplication
    }
}
#endif
