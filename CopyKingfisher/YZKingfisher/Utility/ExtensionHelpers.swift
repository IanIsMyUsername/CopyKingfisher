//
//  ExtensionHelpers.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/6.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

extension Date {
    var isPast: Bool {
        return isPast(referenceDate: Date())
    }
    
    var isFuture: Bool {
        return !isPast
    }
    
    func isPast(referenceDate: Date) -> Bool {
        return timeIntervalSince(referenceDate) <= 0
    }
    
    func isFuture(referenceDate: Date) -> Bool {
        return !isPast(referenceDate: referenceDate)
    }
    
    // `Date` in memory is a wrap for `TimeInterval`. But in file attribute it can only accept `Int` number.
    // By default the system will `round` it. But it is not friendly for testing purpose.
    // So we always `ceil` the value when used for file attributes.
    var fileAtrributeDate: Date {
        return Date(timeIntervalSince1970: ceil(timeIntervalSince1970))
    }
}
