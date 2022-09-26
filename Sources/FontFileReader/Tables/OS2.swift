//
//  OS2.swift
//
//  Created by Gustav Neustadt on 31.08.22.
//
import Foundation

public struct OS2Table {
    let version:                    UInt16,
        xAvgCharWidth:              Int16,
        usWeightClass:              UInt16,
        usWidthClass:               UInt16,
        fsType:                     UInt16,
        ySubscriptXSize:            Int16,
        ySubscriptYSize:            Int16,
        ySubscriptXOffset:          Int16,
        ySubscriptYOffset:          Int16,
        ySuperscriptXSize:          Int16,
        ySuperscriptYSize:          Int16,
        ySuperscriptXOffset:        Int16,
        ySuperscriptYOffset:        Int16,
        yStrikeoutSize:             Int16,
        yStrikeoutPosition:         Int16,
        sFamilyClass:               Int16,
        bFamilyType:                UInt8,
        bSerifStyle:                UInt8,
        bWeight:                    UInt8,
        bProportion:                UInt8,
        bContrast:                  UInt8,
        bStrokeVariation:           UInt8,
        bArmStyle:                  UInt8,
        bLetterform:                UInt8,
        bMidline:                   UInt8,
        bXHeight:                   UInt8,
        ulUnicodeRange1:            UInt32,
        ulUnicodeRange2:            UInt32,
        ulUnicodeRange3:            UInt32,
        ulUnicodeRange4:            UInt32,
        achVendID:                  UInt32,
        fsSelection:                UInt16,
        usFirstCharIndex:           UInt16,
        usLastCharIndex:            UInt16,
        sTypoAscender:              Int16,
        sTypoDescender:             Int16,
        sTypoLineGap:               Int16,
        usWinAscent:                UInt16,
        usWinDescent:               UInt16
    
    struct FsSelection {
        let italic:             Bool,
            underscore:         Bool,
            negative:           Bool,
            outlined:           Bool,
            strikeout:          Bool,
            bold:               Bool,
            regular:            Bool,
            useTypeMetrics:     Bool,
            wws:                Bool,
            oblique:            Bool
    }
    
    var fsSelectionDecoded: FsSelection {

        let bits: [(key: String, value: UInt16)] = [
            ("italic",           0b0000000000000001),
            ("underscore",       0b0000000000000010),
            ("negative",         0b0000000000000100),
            ("outlined",         0b0000000000001000),
            ("strikeout",        0b0000000000010000),
            ("bold",             0b0000000000100000),
            ("regular",          0b0000000001000000),
            ("useTypeMetrics",   0b0000000010000000),
            ("wws",              0b0000000100000000),
            ("oblique",          0b0000001000000000)
        ]

        let fs = self.fsSelection

        var temp: [String : Bool] = [:]
        for (key, value) in bits {
            temp[key] = (fs & value) == value
        }

        return FsSelection(
            italic:         temp["italic"] ?? false,
            underscore:     temp["underscore"] ?? false,
            negative:       temp["negative"] ?? false,
            outlined:       temp["outlined"] ?? false,
            strikeout:      temp["strikeout"] ?? false,
            bold:           temp["bold"] ?? false,
            regular:        temp["regular"] ?? false,
            useTypeMetrics: temp["useTypeMetrics"] ?? false,
            wws:            temp["wws"] ?? false,
            oblique:        temp["oblique"] ?? false
        )
    }
    
    enum CompressionType {
        case brotli
        case zlib
    }
    
    public init(binary: BinaryFile) {
        self.version =              binary.getUInt16()
        self.xAvgCharWidth =        binary.getInt16()
        self.usWeightClass =        binary.getUInt16()
        self.usWidthClass =         binary.getUInt16()
        self.fsType =               binary.getUInt16()
        self.ySubscriptXSize =      binary.getInt16()
        self.ySubscriptYSize =      binary.getInt16()
        self.ySubscriptXOffset =    binary.getInt16()
        self.ySubscriptYOffset =    binary.getInt16()
        self.ySuperscriptXSize =    binary.getInt16()
        self.ySuperscriptYSize =    binary.getInt16()
        self.ySuperscriptXOffset =  binary.getInt16()
        self.ySuperscriptYOffset =  binary.getInt16()
        self.yStrikeoutSize =       binary.getInt16()
        self.yStrikeoutPosition =   binary.getInt16()
        self.sFamilyClass =         binary.getInt16()
        self.bFamilyType =          binary.getUInt8()
        self.bSerifStyle =          binary.getUInt8()
        self.bWeight =              binary.getUInt8()
        self.bProportion =          binary.getUInt8()
        self.bContrast =            binary.getUInt8()
        self.bStrokeVariation =     binary.getUInt8()
        self.bArmStyle =            binary.getUInt8()
        self.bLetterform =          binary.getUInt8()
        self.bMidline =             binary.getUInt8()
        self.bXHeight =             binary.getUInt8()
        self.ulUnicodeRange1 =      binary.getUInt32()
        self.ulUnicodeRange2 =      binary.getUInt32()
        self.ulUnicodeRange3 =      binary.getUInt32()
        self.ulUnicodeRange4 =      binary.getUInt32()
        self.achVendID =            binary.getUInt32()
        self.fsSelection =          binary.getUInt16()
        self.usFirstCharIndex =     binary.getUInt16()
        self.usLastCharIndex =      binary.getUInt16()
        self.sTypoAscender =        binary.getInt16()
        self.sTypoDescender =       binary.getInt16()
        self.sTypoLineGap =         binary.getInt16()
        self.usWinAscent =          binary.getUInt16()
        self.usWinDescent =         binary.getUInt16()
    }
}
