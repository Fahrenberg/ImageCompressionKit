# ImageCompressorKit


## HEIC Compression for UIImage or NSImage

Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)

Compress an UIImage or NSImage (Extension) to data:
````
public func heicData(compressionQuality: CGFloat) throws -> Data
````

- CompressionQuality 0.0 < 1.0

## JPG Compression for UIImage or NSImage

Fallback solution to compress UIImage or NSImage
Use it if HEIC Compressor not available (old iPhones).

````
public func jpgCompressorData(compressionQuality: CGFloat) throws -> Data
````
- CompressionQuality 0.0 < 1.0

See [different approaches](https://stackoverflow.com/questions/29726643/how-to-compress-of-reduce-the-size-of-an-image-before-uploading-to-parse-as-pffi)
