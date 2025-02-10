# ImageCompressionKit


![](https://img.shields.io/badge/iOS%20:-15-blue)
![](https://img.shields.io/badge/macOS%20:-11_(BigSur)-green)
![](https://img.shields.io/badge/macOS%20:-MacCatalyst-yellow)
![GitHub Release](https://img.shields.io/github/v/release/Fahrenberg/ImageCompressionKit)
![GitHub last commit](https://img.shields.io/github/last-commit/Fahrenberg/ImageCompressionKit)


Image compression for UIImage or NSImage (typealias PlatformImage).

## HEIC Compression for UIImage or NSImage

Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)

- Compress an UIImage or NSImage (Extension) to data.
- Very efficient but slower to compress than jpgC

- compressionQuality 0.0 < 1.0
 
Note: For compress multiple images use **sync** not async, it's faster...

### Compress to  +/- 10% of askedMaxSize
```swift
public func heicDataCompression(askedMaxSize: UInt64 = .max) -> Data? 
```
### Compress by setting compressionQuality
```swift
public func heicDataCompression(compressionQuality: CGFloat) -> Data?
```


## JPG Compression for UIImage or NSImage

- Fallback solution to compress UIImage or NSImage.
- Use it if HEIC Compressor not available (old iPhones).
- Less 10x efficient than HEIC compression. Faster to compress. 

- CompressionQuality 0.0 < 1.0

Note: For compress multiple images use ```Task {}``` async (50% faster) rather than sync.

### Compress to  +/- 10% of askedMaxSize
```swift
public func jpgDataCompression(askedMaxSize: UInt64 = .max) -> Data? 
````
### Compress by setting compressionQuality
```swift
public func jpgDataCompression(compressionQuality: CGFloat) -> Data?
````

See [different approaches](https://stackoverflow.com/questions/29726643/how-to-compress-of-reduce-the-size-of-an-image-before-uploading-to-parse-as-pffi)

## Resize Image

Resize original image to specific CGSize. Does not compress image.

```swift
public func resized(to targetSize: CGSize, dpi: CGFloat = 72.0) -> PlatformImage? 
```