//
//  FileDataProtocoll.swift
//
//  Created by Gustav Neustadt on 01.09.22.
//
import UniformTypeIdentifiers

enum FontFormatHeader: UInt32, CaseIterable, Codable {
    case woff2 = 0x774f4632
    case woff = 0x774f4646
    case opentype = 0x4f54544f
    
    static func > (lhs: FontFormatHeader, rhs: FontFormatHeader) -> Bool {
        return lhs.order > rhs.order
    }
    static func < (lhs: FontFormatHeader, rhs: FontFormatHeader) -> Bool {
        return lhs.order < rhs.order
    }
    
    var description: String {
        switch self {
        case .woff2:
            return "woff2"
        case .woff:
            return "woff"
        case .opentype:
            return "otf"
        }
    }
    
    var order: Int {
        switch self {
        case .woff2:
            return 0
        case .woff:
            return 1
        case .opentype:
            return 2
        }
    }
    
}

protocol FileDataProtocol {
    var os2Table: OS2Table { get }
}
