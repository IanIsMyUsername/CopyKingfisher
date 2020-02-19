//
//  Runtime.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/7.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(object, key) as? T
}

func setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T) {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}
