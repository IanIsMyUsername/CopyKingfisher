//
//  Box.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/6/2.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

class Box<T> {
    var value: T
    init(_ value: T) {
        self.value = value
    }
}
