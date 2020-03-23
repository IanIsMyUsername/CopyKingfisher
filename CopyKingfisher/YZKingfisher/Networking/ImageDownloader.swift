//
//  ImageDownloader.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/19.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Represents a success result of an image downloading progress.
public struct ImageLoadingResult {
    
    /// The downloaded image.
    public let image: KFCrossPlatformImage
    
    /// Original URL of the image request.
    public let url: URL?
    
    /// The raw data received from downloader.
    public let originalData: Data
}

/// Represents a task of an image downloading process.
public struct DownloadTask {
    
    /// The `SessionDataTask` object bounded to this download task. Multiple `DownloadTask`s could refer
    /// to a same `sessionTask`. This is an optimization in Kingfisher to prevent multiple downloading task
    /// for the same URL resource at the same time.
    ///
    /// When you `cancel` a `DownloadTask`, this `SessionDataTask` and its cancel token will be pass through.
    /// You can use them to identify the cancelled task.
    public let sessionTask: SessionDataTask
    
    /// The cancel token which is used to cancel the task. This is only for identify the task when it is cancelled.
    /// To cancel a `DownloadTask`, use `cancel` instead.
    public let cancelToken: SessionDataTask.CancelToken
    
    /// Cancel this task if it is running. It will do nothing if this task is not running.
    ///
    /// - Note:
    /// In Kingfisher, there is an optimization to prevent starting another download task if the target URL is being
    /// downloading. However, even when internally no new session task created, a `DownloadTask` will be still created
    /// and returned when you call related methods, but it will share the session downloading task with a previous task.
    /// In this case, if multiple `DownloadTask`s share a single session download task, cancelling a `DownloadTask`
    /// does not affect other `DownloadTask`s.
    ///
    /// If you need to cancel all `DownloadTask`s of a url, use `ImageDownloader.cancel(url:)`. If you need to cancel
    /// all downloading tasks of an `ImageDownloader`, use `ImageDownloader.cancelAll()`.
    public func cancel() {
        sessionTask.cancel(token: cancelToken)
    }
}

extension DownloadTask {
    enum WrappedTask {
        case download(DownloadTask)
        case dataProviding
        
        func cancel() {
            switch self {
            case .download(let task): task.cancel()
            case .dataProviding: break
            }
        }
        
        var value: DownloadTask? {
            switch self {
            case .download(let task): return task
            case .dataProviding: return nil
            }
        }
    }
}

/// Represents a downloading manager for requesting the image with a URL from server.
open class ImageDownloader {
    
    // MARK: Singleton
    /// The default downloader.
    public static let `default` = ImageDownloader(name: "default")
    
    // MARK: Public Properties
    /// The duration before the downloading is timeout. Default is 15 seconds.
    open var downloadTimeout: TimeInterval = 15.0
    
    /// A set of trusted hosts when receiving server trust challenges. A challenge with host name contained in this
    /// set will be ignored. You can use this set to specify the self-signed site. It only will be used if you don't
    /// specify the `authenticationChallengeResponder`.
    ///
    /// If `authenticationChallengeResponder` is set, this property will be ignored and the implementation of
    /// `authenticationChallengeResponder` will be used instead.
    open var trustedHosts: Set<String>?
    
    /// Use this to set supply a configuration for the downloader. By default,
    /// NSURLSessionConfiguration.ephemeralSessionConfiguration() will be used.
    ///
    /// You could change the configuration before a downloading task starts.
    /// A configuration without persistent storage for caches is requested for downloader working correctly.
    open var sessionConfiguration = URLSessionConfiguration.ephemeral {
        didSet {
            session.invalidateAndCancel()
            session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
        }
    }
    
    /// Whether the download requests should use pipeline or not. Default is false.
    open var requestUsePipelining = false
    
    /// Delegate of this `ImageDownloader` object. See `ImageDownloaderDelegate` protocol for more.
    open weak var delegate: ImageDownloaderDelegate?
    
    /// A responder for authentication challenge.
    /// Downloader will forward the received authentication challenge for the downloading session to this responder.
    var authenticationChallengeResponder: AuthenticationChallengeResponsable?
    
    private let name: String
    private let sessionDelegate: SessionDelegate
    private var session: URLSession
    
    // MARK: Initializers
    
    /// Creates a downloader with name.
    ///
    /// - Parameter name: The name for the downloader. It should not be empty.
    public init(name: String) {
        if name.isEmpty {
            fatalError("[Kingfisher] You should specify a name for the downloader. "
                + "A downloader with empty name is not permitted.")
        }
        self.name = name
        sessionDelegate = SessionDelegate()
        session = URLSession(configuration: <#T##URLSessionConfiguration#>, delegate: <#T##URLSessionDelegate?#>, delegateQueue: <#T##OperationQueue?#>)
        
        
        
    }
    
    
}
