//
//  OTFFileData.swift
//
//  Created by Gustav Neustadt on 31.08.22.
//

public struct OTFFileData: FileDataProtocol {
    
    struct TableRecord {
        let tableTag:               String,
            checksum:               UInt32,
            offset:                 UInt32,
            length:                 UInt32
        
        init(_ binary: BinaryFile) {
            self.tableTag =         binary.getString(length: 4)
            self.checksum =         binary.getUInt32()
            self.offset =           binary.getUInt32()
            self.length =           binary.getUInt32()
        }
    }
    
    struct TableDirectory {
        let sfntVersion:            UInt32,
            numTables:              UInt16,
            searchRange:            UInt16,
            entrySelector:          UInt16,
            rangeShift:             UInt16
        
        init(_ binary: BinaryFile) {
            self.sfntVersion =      binary.getUInt32()
            self.numTables =        binary.getUInt16()
            self.searchRange =      binary.getUInt16()
            self.entrySelector =    binary.getUInt16()
            self.rangeShift =       binary.getUInt16()
        }
    }
    
    init?(binary: BinaryFile) {
        binary.setPosition(0)
        self.tableDirectory = TableDirectory(binary)
        self.tableRecords = OTFFileData.parseTableRecords(binary: binary, numTables: tableDirectory.numTables)
        
        guard let os2TableRecord = self.tableRecords["OS/2"] else { return nil }
        self.os2Table = OTFFileData.parseOS2Table(os2TableRecord: os2TableRecord, binary: binary)
    }
    
    private static func parseTableRecords(binary: BinaryFile, numTables: UInt16) -> [String : TableRecord] {
        var temporaryTableRecords: [String : TableRecord] = [:]
        for _ in 1...numTables {
            let record = TableRecord(binary)
            temporaryTableRecords[record.tableTag] = record
            
        }
        return temporaryTableRecords
    }
    
    private static func parseOS2Table(os2TableRecord: TableRecord, binary: BinaryFile) -> OS2Table {
        let os2TableOffset = os2TableRecord.offset
        binary.setPosition(Int(os2TableOffset))
        return OS2Table(binary: binary)
    }
    
    let tableDirectory: TableDirectory
    let tableRecords: [String : TableRecord]
    let os2Table: OS2Table
}
