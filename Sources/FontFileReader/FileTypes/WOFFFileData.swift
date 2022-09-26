//
//  WOFFFileData.swift
//
//  Created by Gustav Neustadt on 31.08.22.
//
import Foundation

public struct WOFFFileData: FileDataProtocol {
    public struct Header {
        let signature:              UInt32,
            flavor:                 UInt32,
            length:                 UInt32,
            numTables:              UInt16,
            reserved:               UInt16,
            totalSfntSize:          UInt32,
            majorVersion:           UInt16,
            minorVersion:           UInt16,
            metaOffset:             UInt32,
            metaLength:             UInt32,
            metaOrigLength:         UInt32,
            privOffset:             UInt32,
            privLength:             UInt32
        
        public init(_ binary: BinaryFile) {
            self.signature =        binary.getUInt32()
            self.flavor =           binary.getUInt32()
            self.length =           binary.getUInt32()
            self.numTables =        binary.getUInt16()
            self.reserved =         binary.getUInt16()
            self.totalSfntSize =    binary.getUInt32()
            self.majorVersion =     binary.getUInt16()
            self.minorVersion =     binary.getUInt16()
            self.metaOffset =       binary.getUInt32()
            self.metaLength =       binary.getUInt32()
            self.metaOrigLength =   binary.getUInt32()
            self.privOffset =       binary.getUInt32()
            self.privLength =       binary.getUInt32()
        }
    }
    
    public struct TableDirectoryEntry {
        public let tag:                    String,
            offset:                 UInt32,
            compLength:             UInt32,
            origLength:             UInt32,
            origChecksum:           UInt32
        
        var isCompressed: Bool {
            return self.compLength != self.origLength
        }
        
        public init(_ binary: BinaryFile) {
            self.tag =              binary.getString(length: 4)
            self.offset =           binary.getUInt32()
            self.compLength =       binary.getUInt32()
            self.origLength =       binary.getUInt32()
            self.origChecksum =     binary.getUInt32()
        }
    }
    
    
    
    public init?(binary: BinaryFile) {
        binary.setPosition(0)
        self.header = Header(binary)
        self.tableDirectoryEntries = WOFFFileData.parseTableDirectoryEntries(binary: binary, numTables: self.header.numTables)
        
//      _____________ TABLES ______________
        guard let os2TableDirectoryEntry = self.tableDirectoryEntries["OS/2"] else { return nil }
        self.os2Table = WOFFFileData.parseOS2Table(os2TableDirectoryEntry: os2TableDirectoryEntry, binary: binary)
    }
    
    private static func parseTableDirectoryEntries(binary: BinaryFile, numTables: UInt16) -> [String : TableDirectoryEntry] {
        var tempTableDirectoryEntries: [String : TableDirectoryEntry] = [:]
        for _ in 1...numTables {
            let entry = TableDirectoryEntry(binary)
            tempTableDirectoryEntries[entry.tag] = entry
        }
        return tempTableDirectoryEntries
    }
    
    private static func parseOS2Table(os2TableDirectoryEntry: TableDirectoryEntry, binary: BinaryFile) -> OS2Table {

        let offset = Int(os2TableDirectoryEntry.offset)
        let isCompressed = os2TableDirectoryEntry.isCompressed
        let length = Int(os2TableDirectoryEntry.compLength)
        
        if isCompressed {
            let origDataArray: [UInt8] = binary.data
            let arraySlice: [UInt8] = Array(origDataArray[offset+2..<(offset + length)])
            let newData: Data = Data(arraySlice)
            let nsData: NSData = NSData(data: newData)
            
            do {
                let dataDecompressed = try nsData.decompressed(using: .zlib)
                let decompressedBinary = BinaryFile(data: dataDecompressed)
                return OS2Table(binary: decompressedBinary)
                
            } catch {
                print(error)
            }
            
        }
        
        binary.setPosition(offset)
        return OS2Table(binary: binary)
    }
    
    public let os2Table: OS2Table
    public let header: Header
    public let tableDirectoryEntries: [String : TableDirectoryEntry]
}
