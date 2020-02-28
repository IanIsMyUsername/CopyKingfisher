//
//  KingfisherManager.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/27.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

/// The downloading progress block type.
/// The parameter value is the `receivedSize` of current response.
/// The second parameter is the total expected data length from response's "Content-Length" header.
/// If the expected length is not available, this block will not be called.
public typealias DownloadProgressBlock = ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)

/// Represents the result of a Kingfisher retrieving image task.
public struct RetrieveImageResult {
    
    /// Gets the image object of this result.
    public let image: KFCrossPlatformImage
    
    /// Gets the cache source of the image. It indicates from which layer of cache this image is retrieved.
    /// If the image is just downloaded from network, `.none` will be returned.
    public let cacheType: CacheType
    
    /// The `Source` which this result is related to. This indicated where the `image` of `self` is referring.
    public let source: Source
    
    /// The original `Source` from which the retrieve task begins. It can be different from the `source` property.
    /// When an alternative source loading happened, the `source` will be the replacing loading target, while the
    /// `originalSource` will be kept as the initial `source` which issued the image loading process.
    public let original: Source
}

/// A struct that stores some related information of an `KingfisherError`. It provides some context information for
/// a pure error so you can identify the error easier.
public struct PropagationError {

    /// The `Source` to which current `error` is bound.
    public let source: Source
    
    /// The actual error happens in framework.
    public let error: KingfisherError
}

/// The downloading task updated block type. The parameter `newTask` is the updated new task of image setting process.
/// It is a `nil` if the image loading does not require an image downloading process. If an image downloading is issued,
/// this value will contain the actual `DownloadTask` for you to keep and cancel it later if you need.
public typealias DownloadTaskUpdatedBlock = ((_ newTask: ) -> Void)
