//
//  WOFF2FileData.swift
//
//  Created by Gustav Neustadt on 01.09.22.
//
import OrderedCollections
import Brotli

public struct WOFF2FileData: FileDataProtocol {
    static let knownTags = [
        "cmap", "head", "hhea", "hmtx", "maxp", "name", "OS/2", "post", "cvt ",
        "fpgm", "glyf", "loca", "prep", "CFF ", "VORG", "EBDT", "EBLC", "gasp",
        "hdmx", "kern", "LTSH", "PCLT", "VDMX", "vhea", "vmtx", "BASE", "GDEF",
        "GPOS", "GSUB", "EBSC", "JSTF", "MATH", "CBDT", "CBLC", "COLR", "CPAL",
        "SVG ", "sbix", "acnt", "avar", "bdat", "bloc", "bsln", "cvar", "fdsc",
        "feat", "fmtx", "fvar", "gvar", "hsty", "just", "lcar", "mort", "morx",
        "opbd", "prop", "trak", "Zapf", "Silf", "Glat", "Gloc", "Feat", "Sill"
    ];
    public struct Header {
        let signature:                      UInt32,
            flavor:                         UInt32,
            length:                         UInt32,
            numTables:                      UInt16,
            reserved:                       UInt16,
            totalSfntSize:                  UInt32,
            totalCompressedSize:            UInt32,
            majorVersion:                   UInt16,
            minorVersion:                   UInt16,
            metaOffset:                     UInt32,
            metaLength:                     UInt32,
            metaOrigLength:                 UInt32,
            privOffset:                     UInt32,
            privLength:                     UInt32
        
        public init(_ binary: BinaryFile) {
            self.signature =                binary.getUInt32()
            self.flavor =                   binary.getUInt32()
            self.length =                   binary.getUInt32()
            self.numTables =                binary.getUInt16()
            self.reserved =                 binary.getUInt16()
            self.totalSfntSize =            binary.getUInt32()
            self.totalCompressedSize =      binary.getUInt32()
            self.majorVersion =             binary.getUInt16()
            self.minorVersion =             binary.getUInt16()
            self.metaOffset =               binary.getUInt32()
            self.metaLength =               binary.getUInt32()
            self.metaOrigLength =           binary.getUInt32()
            self.privOffset =               binary.getUInt32()
            self.privLength =               binary.getUInt32()
        }
    }
    
    public struct TableDirectoryEntry {
        
        let flags:                          UInt8,
            tag:                            String,
            origLength:                     UInt32,
            transformLength:                UInt32?,
            transformationVersion:          UInt8,
            transformed:                    Bool,
            origOffset:                     UInt32
        
        
        public init?(_ binary: BinaryFile, origOffset: UInt32 = 0) {
            self.flags = binary.getUInt8()
            
            var tempTag: String
            if (self.flags & 0x3f) == 0x3f {
                tempTag = binary.getString(length: 4)
            } else {
                tempTag = WOFF2FileData.knownTags[Int(self.flags & 0x3f)]
            }
            
            
            self.tag =                      tempTag
            
            guard let tempOrigLength =      binary.getUIntBase128() else { return nil }
            
            self.origLength =               tempOrigLength
            
            let transformationVersion = (self.flags >> 6) & 0x03
            let transformed = self.tag == "loca" || self.tag == "glyf" ? transformationVersion == 0 : transformationVersion != 0
            
            self.transformLength =          transformed ? binary.getUIntBase128() : nil
            self.transformationVersion =    transformationVersion
            self.transformed =              transformed
            self.origOffset =               origOffset
        }
    }
    
    public struct CollectionHeader {
        let version:                        UInt32,
            numFonts:                       UInt16
        
        init(_ binary: BinaryFile) {
            self.version =                  binary.getUInt32()
            self.numFonts =                 binary.get255UInt16()
        }
    }
    
    public struct CollectionFontEntry {
        let numTables:                      UInt16,
            flavor:                         String,
            index:                          UInt16
        
        init(_ binary: BinaryFile) {
            self.numTables =                binary.get255UInt16()
            self.flavor =                   binary.getString(length: 4)
            self.index =                    binary.get255UInt16()
        }
    }
    
    public init?(binary: BinaryFile) {
        binary.setPosition(0)
        self.header = Header(binary)
        self.tableDirectoryEntries = WOFF2FileData.parseTableDirectoryEntries(binary: binary, numTables: self.header.numTables)
        
        (self.collectionHeader, self.collectionFontEntries) = WOFF2FileData.parseCollectionFontEntries(binary: binary, headerFlavor: header.flavor)
        
        guard let os2TableRecord = self.tableDirectoryEntries["OS/2"] else { return nil }
        self.os2Table = WOFF2FileData.parseOS2Table(binary: binary, os2TableRecord: os2TableRecord, headerTotalCompressedSize: self.header.totalCompressedSize)!
    }
    
    private static func parseOS2Table(binary: BinaryFile, os2TableRecord: TableDirectoryEntry, headerTotalCompressedSize size: UInt32) -> OS2Table? {
        let origDataArray: [UInt8] = binary.data

        let arraySlice: [UInt8] = Array(origDataArray[binary.position..<(binary.position + Int(size))])
        let nsData: NSData = NSData(data: Data(arraySlice))
        
        guard let decompressed: Data = nsData.brotliDecompressed() else {
            print("decompress failed", nsData)
            return nil
        }
        
        let newBinary = BinaryFile(data: NSData(data: decompressed))
        let os2TableOffset = os2TableRecord.origOffset
        newBinary.setPosition(Int(os2TableOffset))
        return OS2Table(binary: newBinary)
    }
    
    private static func parseTableDirectoryEntries(binary: BinaryFile, numTables: UInt16) -> OrderedDictionary<String, TableDirectoryEntry>{
        var tempTableDirectoryEntries: OrderedDictionary<String, TableDirectoryEntry> = [:]
        
        var origOffset: UInt32 = 0
        for _ in 1...numTables {
            guard let entry = TableDirectoryEntry(binary, origOffset: origOffset) else { continue }
            tempTableDirectoryEntries[entry.tag] = entry
            origOffset += entry.origLength
        }
        return tempTableDirectoryEntries
    }
    
    private static func parseCollectionFontEntries(binary: BinaryFile, headerFlavor flavor: UInt32) -> (header: CollectionHeader?, collectionFontEntries: [String: CollectionFontEntry]?) {
        guard flavor == 0x74746366 else {
            return (nil, nil)
        }
        
        let tempCollectionHeader = CollectionHeader(binary)
        var tempCollectionFontEntries: [String : CollectionFontEntry] = [:]
        for _ in 1...tempCollectionHeader.numFonts {
            let entry = CollectionFontEntry(binary)
            tempCollectionFontEntries[entry.flavor] = entry
        }
        return (tempCollectionHeader, tempCollectionFontEntries)
    }
    
    public let header: Header
    
    public let tableDirectoryEntries: OrderedDictionary<String, TableDirectoryEntry>
    public let collectionHeader: CollectionHeader?
    public let collectionFontEntries: [String: CollectionFontEntry]?
    public let os2Table: OS2Table
}
