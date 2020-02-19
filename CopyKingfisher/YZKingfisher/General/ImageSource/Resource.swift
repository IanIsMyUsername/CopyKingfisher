//
//  Resource.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/2.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

/// Represents an image resource at a certain url and a given cache key.
/// Kingfisher will use a `Resource` to download a resource from network and cache it with the cache key when
/// using `Source.network` as its image setting source.
public protocol Resource {
    
    /// The key used in cache.
    var cacheKey: String { get }
    
    /// The target image URL.
    var downloadURL: URL { get }
}

extension Resource {
    
    /// Converts `self` to a valid `Source` based on its `downloadURL` scheme.
    /// A `.provider` with `LocalFileImageDataProvider` associated will be returned if the URL points to a local file. Otherwise,`.network` is returned.
    public func convertToSource() -> Source {
        return downloadURL.isFileURL ?
            .provider(LocalFileImageDataProvider(fileURL: downloadURL, cacheKey: cacheKey)):
            .network(self)
    }
}

/// ImageResource is a simple combination of `downloadURL` and `cacheKey`.
/// When passed to image view set methods, Kingfisher will try to download the target
/// image from the `downloadURL`, and then store it with the `cacheKey` as the key in cache.
public struct ImageResource: Resource {
    // MARK: - Initializers
    
    /// Creates an image resource.
    ///
    /// - Parameters:
    ///   - downloadURL: The target image URL from where the image can be downloaded.
    ///   - cacheKey: The cache key. If `nil`, Kingfisher will use the `absoluteString` of `downloadURL` as the key.
    ///               Default is `nil`.
    public init(downloadURL: URL, cacheKey: String? = nil) {
        self.downloadURL = downloadURL
        self.cacheKey = cacheKey ?? downloadURL.absoluteString
    }
    
    // MARK: Protocol Conforming
    
    /// The key used in cache
    public var cacheKey: String
    
    /// The target image URL
    public var downloadURL: URL
}

/// URL conforms to `Resource` in Kingfisher.
/// The `absoluteString` of this URL is used as `cacheKey`. And the URL itself will be used as `downloadURL`.
/// If you need customize the url and/or cache key, use `ImageResource` instead.
extension URL: Resource {
    public var cacheKey: String { return absoluteString }
    public var downloadURL: URL { return self}
}
