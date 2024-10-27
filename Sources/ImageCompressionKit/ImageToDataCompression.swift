import AVFoundation
import OSLog

// Color for macOS and iOS
#if canImport(UIKit)
    import UIKit
    public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
    import AppKit
    public typealias PlatformImage = NSImage
#endif

extension PlatformImage {
    /// HEIC Image Compression (more effiencient, slower)
    ///
    /// Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)
    public func heicDataCompression(compressionQuality: CGFloat) -> Data? {
        let data = NSMutableData()
        let imageDestination =
            CGImageDestinationCreateWithData(
                data, AVFileType.heic as CFString, 1, nil
            )
        #if canImport(UIKit)
            let cgImage = self.cgImage
        #elseif canImport(AppKit)
            let cgImage = self.cgImage(
                forProposedRect: nil, context: nil, hints: nil)
        #endif
        guard let cgImage,
            let imageDestination
        else {
            return nil
        }

        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]

        CGImageDestinationAddImage(imageDestination, cgImage, options)
        guard CGImageDestinationFinalize(imageDestination) else {
            return nil
        }

        return data as Data
    }
}

extension PlatformImage {
    /// JPG Image Compression (faster less efficient)
    #if canImport(UIKit)
        public func jpgDataCompression(compressionQuality: CGFloat) -> Data? {
            return jpegData(compressionQuality: compressionQuality)
        }
    #endif
    #if canImport(AppKit)
        public func jpgDataCompression(compressionQuality: CGFloat) -> Data? {
            let image = self
            let cgImage = image.cgImage(
                forProposedRect: nil, context: nil, hints: nil)!
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            let properties = [
                NSBitmapImageRep.PropertyKey.compressionFactor:
                    compressionQuality
            ]
            let jpegData = bitmapRep.representation(
                using: NSBitmapImageRep.FileType.jpeg, properties: properties)
            return jpegData
        }
    #endif
}

#if canImport(AppKit)
    extension NSImage {
        func pngData() -> Data? {
            tiffRepresentation?.bitmap?.png
        }
    }

    extension NSBitmapImageRep {
        var png: Data? { representation(using: .png, properties: [:]) }
    }
    extension Data {
        var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
    }
#endif

extension PlatformImage {
    /// Compress NSImage or UIImage to data with proposed max size.
    ///
    /// Use heic compression algorythm if hardware (iPhone 6 or newer) allows.
    /// Required minimum version is iOS 15, older is not supported legacy!
    /// If data size after compression is greater than proposedMaxSize, one more try with reduced compressionQuality.
    ///
    /// Use jpg = true to compress for jpg compatiblity.
    ///
    /// - returns: Compressed Image Data or nil (no compression possible)
    func imageDataCompressing(
        compressionQuality: CGFloat,
        askedMaxBytes: UInt64 = .max,
        jpg: Bool = false
    ) -> Data? {
        if jpg {
            if let jpgData = self.jpgDataCompression(
                compressionQuality: compressionQuality)
            {
                Logger.source.info(
                    """
                    1. JPG imageDataCompressing (\(askedMaxBytes))
                    CompressionQuality: \(compressionQuality)
                    JPG Compressed-Size: \(jpgData.count)
                    """
                )
                guard jpgData.count > askedMaxBytes else { return jpgData }
                // one more try with half compressionQuality
                guard
                    let minimumJpgData = self.jpgDataCompression(
                        compressionQuality: compressionQuality / 2.0)
                else { return jpgData }
                Logger.source.info(
                    """
                    2. JPG imageDataCompressing (\(askedMaxBytes))
                    CompressionQuality: \(compressionQuality / 2.0)
                    JPG Compressed-Size: \(minimumJpgData.count)
                    """
                )
                return minimumJpgData
            }
            return nil // something went wroing
        } else {
            if let heicData = self.heicDataCompression(
                compressionQuality: compressionQuality)
            {
                Logger.source.info(
                    """
                    1. HEIC imageDataCompressing (max. \(askedMaxBytes))
                    CompressionQuality: \(compressionQuality)
                    HEIC Compressed-Size: \(heicData.count)
                    """
                )
                guard heicData.count > askedMaxBytes else { return heicData }
                // one more try with half compressionQuality
                guard
                    let minimumHeicData = self.heicDataCompression(
                        compressionQuality: compressionQuality / 2.0)
                else { return heicData }
                Logger.source.info(
                    """
                    2. HEIC imageDataCompressing (max. \(askedMaxBytes))
                    CompressionQuality: \(compressionQuality / 2.0)
                    HEIC Compressed-Size: \(minimumHeicData.count)
                    """
                )
                return minimumHeicData
            }
            return nil  // something went wrong....
        }
    }
}

extension PlatformImage {
    /// Compress UIImage or NSImage to askedMaxSize (+/-10%)
    ///
    /// Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)
    ///
    /// Without askedMaxSize, compresses with loss less compression,
    /// compresssionQuality 1.0
    ///
    public func heicDataCompression(askedMaxSize: UInt64 = .max) -> Data? {
        // Constants for the compression search algorithm
        let tolerance: Double = 0.1 // 10% tolerance
        let maxAttempts = 20 // Limit to avoid infinite loops in case of issues
        
        // Early return if no size constraint is set
        if askedMaxSize == .max {
            return self.heicDataCompression(compressionQuality: 0.999)
        }
        
        // Initial bounds for the compression quality (0.0 - lowest, 1.0 - highest)
        var lowerBound: Double = 0.0
        var upperBound: Double = 1.0
        var bestCompressionQuality: Double = 1.0
        var attempts = 0
        
        while attempts < maxAttempts {
            let midQuality = (lowerBound + upperBound) / 2.0
            
            // Compress the image with the current quality setting
            guard let compressedData = self.heicDataCompression(compressionQuality: midQuality) else {
                return nil // Return nil if compression fails
            }
            
            let dataSize = UInt64(compressedData.count)
            let minSize = UInt64(Double(askedMaxSize) * (1.0 - tolerance))
            let maxSize = UInt64(Double(askedMaxSize) * (1.0 + tolerance))
            
            // Check if the data size is within the 10% tolerance range
            if dataSize >= minSize && dataSize <= maxSize {
                Logger.source.info(
                    """
                    heicDataCompression (\(askedMaxSize))
                    CompressionQuality: \(midQuality)
                    Used attempts: \(attempts)
                    """
                )
                return compressedData
            } else if dataSize > askedMaxSize {
                // Data size too large, reduce the compression quality
                upperBound = midQuality
            } else {
                // Data size too small, increase the compression quality
                lowerBound = midQuality
                bestCompressionQuality = midQuality
            }
            
            attempts += 1
        }
        
        // If max attempts are reached, use the best found compression quality
        return self.heicDataCompression(compressionQuality: bestCompressionQuality)
    }
    
    /// Compress UIImage or NSImage to askedMaxSize (+/-10%)
    ///
    /// Using faster jpg compression
    ///
    /// Without askedMaxSize, compresses with least compression,
    /// compresssionQuality 0.999
    ///
    public func jpgDataCompression(askedMaxSize: UInt64 = .max) -> Data? {
        if askedMaxSize == .max {
            return self.jpgDataCompression(compressionQuality: 0.999)
        }
        return nil
    }
    
}


extension Logger {
    static let subsystem = "\(Bundle.main.bundleIdentifier!)"
    fileprivate static let source = Logger(subsystem: subsystem, category: "ImageDataCompression")
}
