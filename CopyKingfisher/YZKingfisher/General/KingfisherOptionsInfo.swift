//
//  KingfisherOptionsInfo.swift
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

/// KingfisherOptionsInfo is a typealias for [KingfisherOptionsInfoItem].
/// You can use the enum of option item with value to control some behaviors of Kingfisher.
public typealias KingfisherOptionsInfo = [KingfisherOptionsInfoItem]

extension Array where Element == KingfisherOptionsInfoItem {
    static let empty: KingfisherOptionsInfo = []
}


/// Represents the available option items could be used in `KingfisherOptionsInfo`.
public enum KingfisherOptionsInfoItem {
    
    /// Kingfisher will use the associated `ImageCache` object when handling related operations,
    /// including trying to retrieve the cached images and store the downloaded image to it.
    case targetCache(ImageCache)
    
    /// The `ImageCache` for storing and retrieving original images. If `originalCache` is
    /// contained in the options, it will be preferred for storing and retrieving original images.
    /// If there is no `.originalCache` in the options, `.targetCache` will be used to store original images.
    ///
    /// When using KingfisherManager to download and store an image, if `cacheOriginalImage` is
    /// applied in the option, the original image will be stored to this `originalCache`. At the
    /// same time, if a requested final image (with processor applied) cannot be found in `targetCache`,
    /// Kingfisher will try to search the original image to check whether it is already there. If found,
    /// it will be used and applied with the given processor. It is an optimization for not downloading
    /// the same image for multiple times.
    case originalCache(ImageCache)
    
    /// Kingfisher will use the associated `ImageDownloader` object to download the requested images.
    case downloader(ImageDownloader)
    
    /// Member for animation transition when using `UIImageView`. Kingfisher will use the `ImageTransition` of
    /// this enum to animate the image in if it is downloaded from web. The transition will not happen when the
    /// image is retrieved from either memory or disk cache by default. If you need to do the transition even when
    /// the image being retrieved from cache, set `.forceRefresh` as well.
    case transition(ImageTransition)
    
}

// Improve performance by parsing the input `KingfisherOptionsInfo` (self) first.
// So we can prevent the iterating over the options array again and again.
/// The parsed options info used across Kingfisher methods. Each property in this type corresponds a case member
/// in `KingfisherOptionsInfoItem`. When a `KingfisherOptionsInfo` sent to Kingfisher related methods, it will be
/// parsed and converted to a `KingfisherParsedOptionsInfo` first, and pass through the internal methods.
public struct KingfisherParsedOptionsInfo {
    var callbackQueue:
    
    public var processor: ImageProcessor = DefaultImageProcessor.default
    public var scaleFactor: CGFloat = 1.0
    
 
    init(_ info: KingfisherOptionsInfo?) {
        guard let info = info else {
            return
        }
       
    }
    
}
