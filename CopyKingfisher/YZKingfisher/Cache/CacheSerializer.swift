//
//  CacheSerializer.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/9.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

/// An `CacheSerializer` is used to convert some data to an image object after
/// retrieving it from disk storage, and vice versa, to convert an image to data object
/// for storing to the disk storage.
public protocol CacheSerializer {
    
    /// Gets the serialized data from a provided image
    /// and optional original data for caching to disk.
    ///
    /// - Parameters:
    ///   - image: The image needed to be serialized.
    ///   - original: The original data which is just downloaded.
    ///               If the image is retrieved from cache instead of
    ///               downloaded, it will be `nil`.
    /// - Returns: The data object for storing to disk, or `nil` when no valid
    ///            data could be serialized.
    func data(with image: KFCrossPlatformImage, original: Data?) -> Data?
    
    /// Gets an image from provided serialized data.
    ///
    /// - Parameters:
    ///   - data: The data from which an image should be deserialized.
    ///   - options: The parsed options for deserialization.
    /// - Returns: An image deserialized or `nil` when no valid image
    ///            could be deserialized.
    func image(with data: Data, options: KingfisherOptionsInfo) -> KFCrossPlatformImage?
    
    /// Gets an image deserialized from provided data.
    ///
    /// - Parameters:
    ///   - data: The data from which an image should be deserialized.
    ///   - options: Options for deserialization.
    /// - Returns: An image deserialized or `nil` when no valid image
    ///            could be deserialized.
    /// - Note:
    /// This method is deprecated. Please implement the version with
    /// `KingfisherParsedOptionsInfo` as parameter instead.
    @available(*, deprecated, message:  "Deprecated. Implement the method with same name but with `KingfisherParsedOptionsInfo` instead.")
    func image(with data: Data, options: KingfisherOptionsInfo?) -> KFCrossPlatformImage
}
