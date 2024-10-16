# ImageCompressorKit


## HEIC Compression for UIImage or NSImage

Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)

Compress an UIImage or NSImage (Extension) to data:
````
public func heicData(compressionQuality: CGFloat) throws -> Data
````
- Uses ````CGImageDestinationCreateWithData(data, AVFileType.heic as CFString, 1, nil)```` to HEIC compress.
- CompressionQuality < 1.0

### Batch sync processing of multiple UIImages:
````
compressToHEICData(for images: [UIImage], compressionQuality: CGFloat) -> [Data]
````
### Batch async processing of multiple UIImages:
````
compressToHEICDataAsync(for images: [UIImage], compressionQuality: CGFloat) async -> [Data]
````
- Note: function is async but proecessing [UIImage] is sync, will us TaskGroup for parallel compressing.

## JPG Compression for UIImage or NSImage

Fallback solution to compress UIImage or NSImage
Use it if HEIC Compressor not available (old iPhones).

See [different approaches](https://stackoverflow.com/questions/29726643/how-to-compress-of-reduce-the-size-of-an-image-before-uploading-to-parse-as-pffi)
