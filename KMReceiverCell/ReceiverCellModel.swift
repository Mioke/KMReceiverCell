//
//  ReceiverCellModel.swift
//  FileMail
//
//  Created by jiangkelan on 20/05/2017.
//  Copyright © 2017 xlvip. All rights reserved.
//

import UIKit

public class ReceiverCellModel {
    var id: String?
    var displayed: String
    var fullName: String
    
    init(withID id: String?, name: String) {
        self.id = id
        self.fullName = name
        self.displayed = name
    }
}

extension ReceiverCellModel: Equatable {
    public static func ==(lhs: ReceiverCellModel, rhs: ReceiverCellModel) -> Bool {
        guard let lid = lhs.id, let rid = rhs.id else { return lhs.fullName == rhs.fullName }
        return lid == rid
    }
}

extension ReceiverCellModel: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return fullName
    }
    
    public var debugDescription: String {
        return fullName
    }
}
