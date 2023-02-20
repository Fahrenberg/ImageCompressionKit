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
