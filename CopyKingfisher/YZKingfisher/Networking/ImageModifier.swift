//
//  ImageModifier.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/20.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

/// An `ImageModifier` can be used to change properties on an image in between
/// cache serialization and use of the image. The modified returned image will be
/// only used for current rendering purpose, the serialization data will not contain
/// the changes applied by the `ImageModifier`.
public protocol ImageModifier {
    /// Modify an input `Image`.
    ///
    /// - parameter image:   Image which will be modified by `self`
    ///
    /// - returns: The modified image.
    ///
    /// - Note: The return value will be unmodified if modifying is not possible on
    ///         the current platform.
    /// - Note: Most modifiers support UIImage or NSImage, but not CGImage.
    func modify(_ image: KFCrossPlatformImage) -> KFCrossPlatformImage
}
