# CompressorKit

## ImageCompressor
- Compress an UIImage to a specific file size in bytes by iterating ````preparingThumbnail````.
- Use a startCompression < 1.0 to speed up.
- Returns the compressed UIImage.

````
static public func compress(image: UIImage,
                            maxBytes: UInt64,
                            startCompression: CGFloat = 1.0) -> UIImage?
````

## HEICCompressor

Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)

Compress an UIImage (Extension) to data:
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

## JPGCompressor

Fallback solution to compress images if HEIC Compressor not available (old iPhones).

See [different approaches](https://stackoverflow.com/questions/29726643/how-to-compress-of-reduce-the-size-of-an-image-before-uploading-to-parse-as-pffi)
