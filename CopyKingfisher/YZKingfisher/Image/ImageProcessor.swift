//
//  ImageProcessor.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/17.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

/// Represents an item which could be processed by an `ImageProcessor`.
///
/// - image: Input image. The processor should provide a way to apply
///          processing on this `image` and return the result image.
/// - data:  Input data. The processor should provide a way to apply
///          processing on this `image` and return the result image.
public enum ImageProcessItem {
    
    /// Input image. The processor should provide a way to apply
    /// processing on this `image` and return the result image.
    case image(KFCrossPlatformImage)
    
    /// Input data. The processor should provide a way to apply
    /// processing on this `image` and return the result image.
    case data(Data)
}


/// An `ImageProcessor` would be used to convert some downloaded data to an image.
public protocol ImageProcessor {
    /// Identifier of the processor. It will be used to identify the processor when
    /// caching and retrieving an image. You might want to make sure that processors with
    /// same properties/functionality have the same identifiers, so correct processed images
    /// could be retrieved with proper key.
    ///
    /// - Note: Do not supply an empty string for a customized processor, which is already reserved by
    /// the `DefaultImageProcessor`. It is recommended to use a reverse domain name notation string of
    /// your own for the identifier.
    var identifier: String { get }
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: The return value should be `nil` if processing failed while converting an input item to image.
    ///         If `nil` received by the processing caller, an error will be reported and the process flow stops.
    ///         If the processing flow is not critical for your flow, then when the input item is already an image
    ///         (`.image` case) and there is any errors in the processing, you could return the input image itself
    ///         to keep the processing pipeline continuing.
    /// - Note: Most processor only supports CG-based images. watchOS is not supported for processors containing
    ///         a filter, the input image will be returned directly on watchOS.
    /// - Note:
    /// This method is deprecated. Please implement the version with
    /// `KingfisherParsedOptionsInfo` as parameter instead.
    @available(*, deprecated,
    message: "Deprecated. Implement the method with same name but with `KingfisherParsedOptionsInfo` instead.")
    func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> KFCrossPlatformImage?
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: The parsed options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: The return value should be `nil` if processing failed while converting an input item to image.
    ///         If `nil` received by the processing caller, an error will be reported and the process flow stops.
    ///         If the processing flow is not critical for your flow, then when the input item is already an image
    ///         (`.image` case) and there is any errors in the processing, you could return the input image itself
    ///         to keep the processing pipeline continuing.
    /// - Note: Most processor only supports CG-based images. watchOS is not supported for processors containing
    ///         a filter, the input image will be returned directly on watchOS.
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage?
}

extension ImageProcessor {
    public func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> KFCrossPlatformImage? {
        return process(item: item, options: KingfisherParsedOptionsInfo(options))
    }
}
 
/// The default processor. It converts the input data to a valid image.
/// Images of .PNG, .JPEG and .GIF format are supported.
/// If an image item is given as `.image` case, `DefaultImageProcessor` will
/// do nothing on it and return the associated image.
public struct DefaultImageProcessor: ImageProcessor {
    /// A default `DefaultImageProcessor` could be used across.
    public static let `default` = DefaultImageProcessor()
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
    public let identifier = ""
    
    /// Creates a `DefaultImageProcessor`. Use `DefaultImageProcessor.default` to get an instance,
    /// if you do not have a good reason to create your own `DefaultImageProcessor`.
    public init() {}
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image.kf.scaled(to: options.scaleFactor)
        case .data(let data):
            return Kin
            
        }
    }
    
    
    
}
