//
//  Image.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/7.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

#if os(macOS)
import AppKit
private var imagesKey: Void?
private var durationKey: Void?
#else
import UIKit
import MobileCoreServices
private var imageSourceKey: Void?
#endif

#if !os(watchOS)
import CoreImage
#endif


private var animatedImageDataKey: Void?

// MARK: - Image Properties
extension KingfisherWrapper where Base: KFCrossPlatformImage {
    private(set) var animatedImageData: Data? {
        get { return getAssociatedObject(base, &animatedImageDataKey) }
        set {
            setRetainedAssociatedObject(base, &animatedImageDataKey, newValue)
        }
    }
    
    #if os(macOS)
    var cgImage: CGImage? {
        return base.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    var scale: CGFloat {
        return 1.0
    }
    
    private(set) var images: [KFCrossPlatformImage]? {
        get { return getAssociatedObject(base, &imagesKey) }
        set { setRetainedAssociatedObject(base, &imagesKey, newValue) }
    }
    
    private(set) var duration: TimeInterval {
        get { return getAssociatedObject(base, &durationKey) ?? 0.0 }
        set { setRetainedAssociatedObject(base, &durationKey, newValue) }
    }
    
    var size: CGSize {
        return base.representations.reduce(.zero) { size, rep in
            let width = max(size.width, CGFloat(rep.pixelsWide))
            let height = max(size.height, CGFloat(rep.pixelsHigh))
            return CGSize(width: width, height: height)
        }
    }
    #else
    var cgImage: CGImage? { return base.cgImage }
    var scale: CGFloat { return base.scale }
    var images: [KFCrossPlatformImage]? { return base.images }
    var duration: TimeInterval { return base.duration }
    var size: CGSize {return base.size}
    
    private(set) var imageSource: CGImageSource? {
        get { return getAssociatedObject(base, &imageSourceKey) }
        set { setRetainedAssociatedObject(base, &imageSourceKey, newValue) }
    }
    #endif
    
    // Bitmap memory cost with bytes.
    var cost: Int {
        let pixel = Int(size.width * size.height * scale * scale)
        guard let cgImage = cgImage else {
            return pixel * 4
        }
        return pixel * cgImage.bitsPerPixel / 8
    }
}

// MARK: - Creating Images
extension KingfisherWrapper where Base: KFCrossPlatformImage {
    
    /// Creates an animated image from a given data and options. Currently only GIF data is supported.
    ///
    /// - Parameters:
    ///   - data: The animated image data.
    ///   - options: Options to use when creating the animated image.
    /// - Returns: An `Image` object represents the animated image. It is in form of an array of image frames with a
    ///            certain duration. `nil` if anything wrong when creating animated image.
    public static func animatedImage(data: Data, options: ImageCreatingOptions) -> KFCrossPlatformImage? {
        let info: [String: Any] = [
            kCGImageSourceShouldCache as String: true,
            kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF
        ]
        
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, info as CFDictionary) else {
            return nil
        }
        
        #if os(macOS)
        guard let animatedImage = GIFAnimatedImage(from: imageSource, for: info, options: options) else {
            return nil
        }
        var image: KFCrossPlatformImage?
        if options.onlyFirstFrame {
            image = animatedImage.images.first
        } else {
            image = KFCrossPlatformImage(data: data)
            var kf = image?.kf
            kf?.images = animatedImage.images
            kf?.duration = animatedImage.duration
        }
        image?.kf.animatedImageData = data
        return image
        #else
        
        var image: KFCrossPlatformImage?
        if options.preloadAll || options.onlyFirstFrame {
            // Use `images` image if you want to preload all animated data
            guard let animatedImage = GIFAnimatedImage(from: imageSource, for: info, options: options) else {
                return nil
            }
            if options.onlyFirstFrame {
                image = animatedImage.images.first
            } else {
                let duration = options.duration <= 0.0 ?
                    animatedImage.duration : options.duration
                image = UIImage.animatedImage(with: animatedImage.images, duration: duration)
            }
            image?.kf.animatedImageData = data
        }else {
            image = KFCrossPlatformImage(data: data, scale: options.scale)
            var kf = image?.kf
            kf?.imageSource = imageSource
            kf?.animatedImageData = data
        }
    
        return image
        #endif
        
    }
    
    /// Creates an image from a given data and options. `.JPEG`, `.PNG` or `.GIF` is supported. For other
    /// image format, image initializer from system will be used. If no image object could be created from
    /// the given `data`, `nil` will be returned.
    ///
    /// - Parameters:
    ///   - data: The image data representation.
    ///   - options: Options to use when creating the image.
    /// - Returns: An `Image` object represents the image if created. If the `data` is invalid or not supported, `nil`
    ///            will be returned.
    func image(data: Data, options: ImageCreatingOptions) -> KFCrossPlatformImage? {
        var image:KFCrossPlatformImage?
        switch data.kf.imageFormat {
        case .JPEG:
            image = KFCrossPlatformImage(data: data, scale: options.scale)
        case .PNG:
            image = KFCrossPlatformImage(data: data, scale: options.scale)
        case .GIF:
            image = KingfisherWrapper.a
            
        }
        
    }
}
