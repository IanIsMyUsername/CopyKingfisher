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

// MARK: - Decoding Image
extension KingfisherWrapper where Base: KFCrossPlatformImage {
    
    /// Returns the decoded image of the `base` image. It will draw the image in a plain context and return the data
    /// from it. This could improve the drawing performance when an image is just created from data but not yet
    /// displayed for the first time.
    ///
    /// - Note: This method only works for CG-based image. The current image scale is kept.
    ///         For any non-CG-based image or animated image, `base` itself is returned.
    public var decoded: KFCrossPlatformImage { return decoded(scale: scale) }
    
    /// Returns decoded image of the `base` image at a given scale. It will draw the image in a plain context and
    /// return the data from it. This could improve the drawing performance when an image is just created from
    /// data but not yet displayed for the first time.
    ///
    /// - Parameter scale: The given scale of target image should be.
    /// - Returns: The decoded image ready to be displayed.
    ///
    /// - Note: This method only works for CG-based image. The current image scale is kept.
    ///         For any non-CG-based image or animated image, `base` itself is returned.
    public func decoded(scale: CGFloat) -> KFCrossPlatformImage {
        // Prevent animated image (GIF) losing it's images
        #if os(iOS)
        if imageSource != nil { return base }
        #else
        if images != nil { return base }
        #endif
        
        guard let imageRef = cgImage else {
            assertionFailure("[Kingfisher] Decoding only works for CG-based image.")
            return base
        }
        
        let size = CGSize(width: CGFloat(imageRef.width) / scale, height: CGFloat(imageRef.height) / scale)
        return draw(to: size, inverting: true, scale: scale) { context in
            context.draw(imageRef, in: CGRect(origin: .zero, size: size))
            return true
        }
    }
}

extension KingfisherWrapper where Base: KFCrossPlatformImage {
    func beginContext(size: CGSize, scale: CGFloat, inverting: Bool = false) -> CGContext? {
    
        #if os(macOS)
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: cgImage?.bitsPerComponent ?? 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .calibratedRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0) else
        {
            assertionFailure("[Kingfisher] Image representation cannot be created.")
            return nil
        }
        rep.size = size
        NSGraphicsContext.saveGraphicsState()
        guard let context = NSGraphicsContext(bitmapImageRep: rep) else {
            assertionFailure("[Kingfisher] Image context cannot be created.")
            return nil
        }
        
        NSGraphicsContext.current = context
        return context.cgContext
        #else
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        if inverting { // If drawing a CGImage, we need to make context flipped.
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: 0, y: -size.height)
        }
        return context
        #endif
    }
    
    func endContext() {
        #if os(macOS)
        NSGraphicsContext.restoreGraphicsState()
        #else
        UIGraphicsEndImageContext()
        #endif
    }
    
    func draw(
        to size: CGSize,
        inverting: Bool = false,
        scale: CGFloat? = nil,
        refImage: KFCrossPlatformImage? = nil,
        draw: (CGContext) -> Bool // // Whether use the refImage (`true`) or ignore image orientation (`false`)
    ) -> KFCrossPlatformImage {
        let targetScale = scale ?? self.scale
        guard let context = beginContext(size: size, scale: targetScale, inverting: inverting)  else {
            assertionFailure("[Kingfisher] Failed to create CG context for blurring image.")
            return base
        }
        defer {
            endContext()
        }
        let useRefImage = draw(context)
        guard let cgImage = context.makeImage() else {
            return base
        }
        let ref = useRefImage ? (refImage ?? base) : nil
        return KingfisherWrapper.image(cgImage: cgImage, scale: targetScale, refImage: ref)
    }
    
    #if os(macOS)
    func fixedForRetinaPixel(cgImage: CGImage, to size: CGSize) -> KFCrossPlatformImage {
        
        let image = KFCrossPlatformImage(cgImage: cgImage, size: base.size)
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        
        return draw(to: self.size) { context in
            image.draw(in: rect, from: .zero, operation: .copy, fraction: 1.0)
            return false
        }
    }
    #endif
}
