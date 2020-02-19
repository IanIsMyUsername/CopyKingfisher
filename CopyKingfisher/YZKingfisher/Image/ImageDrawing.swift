//
//  ImageDrawing.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/19.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Image Conversion
extension KingfisherWrapper where Base: KFCrossPlatformImage {
    #if os(macOS)
    static func image(cgImage: CGImage, scale: CGFloat, refImage: KFCrossPlatformImage?) -> KFCrossPlatformImage {
        return KFCrossPlatformImage(cgImage: cgImage, size: .zero)
    }
    
    /// Normalize the image. This getter does nothing on macOS but return the image itself.
    public var normalized: KFCrossPlatformImage { return base }
    
    #else
    /// Creating an image from a give `CGImage` at scale and orientation for refImage. The method signature is for
    /// compatibility of macOS version.
    static func image(cgImage: CGImage, scale: CGFloat, refImage: KFCrossPlatformImage?) -> KFCrossPlatformImage {
        return KFCrossPlatformImage(cgImage: cgImage, scale: scale, orientation: refImage?.imageOrientation ?? .up)
    }
    
    #endif
}

// MARK: - Image Transforming
extension KingfisherWrapper where Base: KFCrossPlatformImage {
    
    /// Return an image with given scale.
    ///
    /// - Parameter scale: Target scale factor the new image should have.
    /// - Returns: The image with target scale. If the base image is already in the scale, `base` will be returned.
    public func scaled(to scale: CGFloat) -> KFCrossPlatformImage {
        guard scale != self.scale else {
            return base
        }
        guard let cgImage = cgImage else {
            assertionFailure("[Kingfisher] Scaling only works for CG-based image.")
            return base
        }
        return KingfisherWrapper.image(cgImage: cgImage, scale: scale, refImage: base)
    }
}
