//
//  ImageView+YZKingfisher.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/1.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

#if !os(watchOS)

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension KingfisherWrapper where Base: KFCrossPlatformImageView {
    
    //MARK: Setting Image
    
    /// Sets an image to the image view with a `Source`.
    ///
    /// - Parameters:
    ///   - source: The `Source` object defines data information from network or a data provider.
    ///   - placeholder: A placeholder to show while retrieving the image from the given `resource`.
    ///   - options: An options set to define image setting behaviors. See `KingfisherOptionsInfo` for more.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called.
    ///   - completionHandler: Called when the image retrieved and set finished.
    /// - Returns: A task represents the image downloading.
    ///
    /// - Note:
    /// This is the easiest way to use Kingfisher to boost the image setting process from a source. Since all parameters
    /// have a default value except the `source`, you can set an image from a certain URL to an image view like this:
    ///
    /// ```
    /// // Set image from a network source.
    /// let url = URL(string: "https://example.com/image.png")!
    /// imageView.kf.setImage(with: .network(url))
    ///
    /// // Or set image from a data provider.
    /// let provider = LocalFileImageDataProvider(fileURL: fileURL)
    /// imageView.kf.setImage(with: .provider(provider))
    /// ```
    ///
    /// For both `.network` and `.provider` source, there are corresponding view extension methods. So the code
    /// above is equivalent to:
    ///
    /// ```
    /// imageView.kf.setImage(with: url)
    /// imageView.kf.setImage(with: provider)
    /// ```
    ///
    /// Internally, this method will use `KingfisherManager` to get the source.
    /// Since this method will perform UI changes, you must call it from the main thread.
    /// Both `progressBlock` and `completionHandler` will be also executed in the main thread.
    ///
    @discardableResult
    public func setImage(
        with source: Source?,
        placeholder: Placeholder? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        var mutatingSelf = self
        guard let source = source else {
            mutatingSelf.placeholder = placeholder
            mutatingSelf.taskIdentifier = nil
            completionHandler?(.failure(KingfisherError.imageSettingError(reason: .emptySource)))
            return nil
        }
    
        var options = KingfisherParsedOptionsInfo()
        
    }

    
}

// MARK: - Associated Object
private var taskIdentifierKey: Void?
private var indicatorKey: Void?
private var indicatorTypeKey: Void?
private var placeholderKey: Void?
private var imageTaskKey: Void?

extension KingfisherWrapper where Base: KFCrossPlatformImageView {
    
//    Mark: Properties
    public private(set) var taskIdentifier: Source.Identifier.Value? {
        get {
            let box: Box<Source.Identifier.Value>? = getAssociatedObject(base, &taskIdentifierKey)
            return box?.value
        }
        set {
            let box = newValue.map{ Box($0) }
            setRetainedAssociatedObject(base, &taskIdentifierKey, box)
        }
    }
    
    
    /// Represents the `Placeholder` used for this image view. A `Placeholder` will be shown in the view while
    /// it is downloading an image.
    public private(set) var placeholder: Placeholder? {
        get { return getAssociatedObject(base, &placeholderKey) }
        set {
            if let previousPlaceholder = placeholder {
                previousPlaceholder.remove(from: base)
            }
            
            if let newPlaceholder = newValue {
                newPlaceholder.add(to: base)
            } else {
                base.image = nil
            }
            
            setRetainedAssociatedObject(base, &placeholderKey, newValue)
        }
    }
    
}


#endif
