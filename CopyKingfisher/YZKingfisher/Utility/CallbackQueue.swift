//
//  CallbackQueue.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/19.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

/// Represents callback queue behaviors when an calling of closure be dispatched.
///
/// - asyncMain: Dispatch the calling to `DispatchQueue.main` with an `async` behavior.
/// - currentMainOrAsync: Dispatch the calling to `DispatchQueue.main` with an `async` behavior if current queue is not
///                       `.main`. Otherwise, call the closure immediately in current main queue.
/// - untouch: Do not change the calling queue for closure.
/// - dispatch: Dispatches to a specified `DispatchQueue`.
