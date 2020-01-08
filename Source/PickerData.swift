//
//  PickerData.swift
//  Picker
//
//  Created by Tam Huynh on 5/8/19.
//  Copyright © 2019 th. All rights reserved.
//

import UIKit

public protocol PickerDatasource {
    var datasources: [[PickerData]] { get }
}

public struct PickerData {
    public var title: String
    public var value: String
    public var optionalValue: String?
    public var options: [String: Any]?
    
    public init(value: String? = nil, title: String? = nil, optional: String? = nil, options: [String: Any]? = nil) {
        self.value = value ?? ""
        self.title = title ?? value ?? ""        
        self.optionalValue = optional
        self.options = options
    }
}

public struct PickerItem {
    public var component: Int
    public var row: Int
    public var data: PickerData
}

public extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        var i = self.startIndex
        while i != self.endIndex {
            if i == index {
                return self[index]
            }
            i = self.index(after: i)
        }
        return nil
    }
}
