# ImageCompressorKit

Extension for UIImage or NSImage (typealias PlatformImage).

## HEIC Compression for UIImage or NSImage

Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)

- Compress an UIImage or NSImage (Extension) to data.
- Very efficient but slower to compress than jpgC
- For compress multiple images use sync not async, it's faster...
 
````
public func heicDataCompression(compressionQuality: CGFloat) -> Data?
````

- CompressionQuality 0.0 < 1.0

## JPG Compression for UIImage or NSImage

- Fallback solution to compress UIImage or NSImage.
- Use it if HEIC Compressor not available (old iPhones).
- Less 10x efficient than HEIC compression. Faster to compress. 

Note: For compress multiple images use ```Task {}``` async (50% faster) rather than sync.


````
public func jpgDataCompression(compressionQuality: CGFloat) -> Data?
````
- CompressionQuality 0.0 < 1.0

See [different approaches](https://stackoverflow.com/questions/29726643/how-to-compress-of-reduce-the-size-of-an-image-before-uploading-to-parse-as-pffi)
