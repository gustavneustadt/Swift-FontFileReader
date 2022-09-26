# FontFileReader

Package to read tables of font files like otf, woff and woff2.
At the moment only OS2 Support.

## Why?
I needed a way to read the OS2 table from a given font file. Because I was not able to implement [fonttools](https://github.com/fonttools/fonttools) into an app I’m developing I had to write a custom swift implementation.  
Feel free to contribute.
## Usage

``` swift

// import Library
import FontFileReader

// --------------------------------- //

// Load NSData from file
guard let data = NSData(contentsOf: url) else {
    // return or throw error
    return
}

// Load data into BinaryFile object
let binary = BinaryFile(data: data)

// Parse the file signature header
let fileSignature = binary.getUInt32()

// Pass the signature into FontFormatHeader objet and check for validity
guard let fontFormat = FontFormatHeader.init(rawValue: fileSignature) else {
    throw error.unknownFontFileFormat
}

var fontFileData: FileDataProtocol?

// handle binary according to the format
switch fontFormat {
case .opentype:
    fontFileData = OTFFileData(binary: binary)
case .woff:
    fontFileData = WOFFFileData(binary: binary)
case .woff2:
    fontFileData = WOFF2FileData(binary: binary)
}

guard fontFileData != nil else {
    return
}

// read data from fontFileData from the tables like (at the moment only OS2 Table supported)
let fontWeight = fontFileData!.os2Table.usWeightClass
let fontStyle = fontFileData!.os2Table.fsSelectionDecoded

```

## Todo
- [ ] CFF Table Support + Decompression in WOFF2
- [ ] implement custom errors to handle errors while parsing (change functions to throwing ones)

### Resources
[W3 WOFF Specification](https://www.w3.org/TR/WOFF/)
[W3 WOFF2 Specification](https://www.w3.org/TR/WOFF2/)

[Microsoft OTF Specification](https://docs.fileformat.com/font/otf/)
[Fonttools](https://github.com/fonttools/fonttools)
