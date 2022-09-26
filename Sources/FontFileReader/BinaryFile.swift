//
//  BinaryFile.swift
//
//  Created by Gustav Neustadt on 31.08.22.
//
import Foundation

public class BinaryFile {
    var position: Int = 0
    var data: [UInt8]
    
    public init(data: NSData) {
        self.data = BinaryFile.getUInt8ArrayFromData(data: data)
    }
    
    public static func getUInt8ArrayFromData(data: NSData) -> [UInt8] {
        var array = [UInt8](repeating: 0, count: data.length)
        
        data.getBytes(&array, length: data.length)
        return array
    }
    
    public func step(_ steps: Int = 1) -> Void {
        position = position + steps
    }
    
    public func getString(length: Int = 1) -> String {
        var array: [UInt8] = []
        
        for _ in 1...length {
            array.append(self.getUInt8())
        }
        
        let data = Data(array)
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    public func getUInt8() -> UInt8 {
        let returnData = data[position]
        
        self.step()
        return returnData
    }
    
    public func getUInt16() -> UInt16 {
        return UInt16(self.getUInt8())  << 8 + UInt16(self.getUInt8())
    }
    
    public func getUInt32() -> UInt32 {
        return UInt32(self.getUInt16()) << 16 + UInt32(self.getUInt16())
    }
    
    public func get255UInt16() -> UInt16 {
        var code: UInt8,
            value: UInt16,
            value2: UInt16
        
        let oneMoreByteCode1 =      UInt16(255),
            oneMoreByteCode2 =      UInt16(254),
            wordCode =              UInt16(253),
            lowestUCode =           UInt16(253)
            
        code = self.getUInt8()
        
        if code == wordCode {
            value = UInt16(self.getUInt8())
            value <<= 8
            value &= 0xff00
            value2 = UInt16(self.getUInt8())
            value |= value2 & 0x00ff
        } else if code == oneMoreByteCode1 {
            value = UInt16(self.getUInt8())
            value = (value + lowestUCode)
        } else if code == oneMoreByteCode2 {
            value = UInt16(self.getUInt8())
            value = (value + lowestUCode * 2)
        } else {
            value = UInt16(code)
        }
        
        return value
    }
    
    public func getUIntBase128() -> UInt32? {
        var result: UInt32 = 0
        
        for i in 0...4 {
            let dataByte = UInt32(self.getUInt8())
            
            if i == 0 && dataByte == 0x80 {
                return nil
            }
            
            if (result & 0xFE000000) == 1 {
                return nil
            }
            
            result = (result << 7) | (dataByte & 0x7F)
            
            if (dataByte & 0x80) == 0 {
                return result
            }
        }
        
        return nil
       
    }
    
    public func getInt8() -> Int8 {
        return Int8(bitPattern: self.getUInt8())
    }
    public func getInt16() -> Int16 {
        return Int16(bitPattern: self.getUInt16())
    }
    public func getInt32() -> Int32 {
        return Int32(bitPattern: self.getUInt32())
    }
    
    public func printHex<T: BinaryInteger>(_ int: T) -> String  {
        return String(int, radix: 16)
    }
    
    public func setPosition(_ position: Int?) -> Void {
        guard position != nil else { return }
        self.position = position!
    }
}
