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

    /// Generic method to find the optimal compression quality for the target size
    ///
    /// Skips compression if the original image size (PNG format) is smaller than or equal to the askedMaxSize.
    /// If no size constraint is set, returns the original PNG data.
    ///
    private func findOptimalCompressionQuality(
        askedMaxSize: UInt64,
        compressionClosure: (Double) -> Data?
    ) -> Data? {
        // Constants for the compression search algorithm
        let tolerance: Double = 0.1 // 10% tolerance
        let maxAttempts = 20 // Limit to avoid infinite loops in case of issues
        
        // Check if the image's original PNG size is smaller or equal to askedMaxSize
        if let originalData = self.pngData(),
           askedMaxSize == .max || UInt64(originalData.count) <= askedMaxSize {
            Logger.source.info(
                """
                Skipping compression as original image size (\(originalData.count) bytes)
                is smaller than or equal to the askedMaxSize (\(askedMaxSize == .max ? ".max" : String(describing: askedMaxSize)) bytes).
                """
            )
            return originalData
        }

        // Initial bounds for the compression quality (0.0 - lowest, 1.0 - highest)
        var lowerBound: Double = 0.0
        var upperBound: Double = 1.0
        var bestCompressionQuality: Double = 1.0
        var attempts = 0

        while attempts < maxAttempts {
            let midQuality = (lowerBound + upperBound) / 2.0

            // Compress the image with the current quality setting
            guard let compressedData = compressionClosure(midQuality) else {
                return nil // Return nil if compression fails
            }

            let dataSize = UInt64(compressedData.count)
            let minSize = UInt64(Double(askedMaxSize) * (1.0 - tolerance))
            let maxSize = UInt64(Double(askedMaxSize) * (1.0 + tolerance))

            // Check if the data size is within the 10% tolerance range
            if dataSize >= minSize && dataSize <= maxSize {
                Logger.source.info(
                    """
                    Compression completed for askedMaxSize (\(askedMaxSize))
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
        return compressionClosure(bestCompressionQuality)
    }

    /// Compress UIImage or NSImage to askedMaxSize (+/-10%) using HEIC format
    ///
    /// Skips compression if the original image size (PNG format) is smaller than or equal to the askedMaxSize.
    /// If no size constraint is set, returns the original PNG data.
    ///
    public func heicDataCompression(askedMaxSize: UInt64 = .max) -> Data? {
        return findOptimalCompressionQuality(askedMaxSize: askedMaxSize) { compressionQuality in
            return self.heicDataCompression(compressionQuality: compressionQuality)
        }
    }

    /// Compress UIImage or NSImage to askedMaxSize (+/-10%) using JPEG format
    ///
    /// Skips compression if the original image size (PNG format) is smaller than or equal to the askedMaxSize.
    /// If no size constraint is set, returns the original PNG data.
    ///
    public func jpgDataCompression(askedMaxSize: UInt64 = .max) -> Data? {
        return findOptimalCompressionQuality(askedMaxSize: askedMaxSize) { compressionQuality in
            return self.jpgDataCompression(compressionQuality: compressionQuality)
        }
    }
}



extension Logger {
    static let subsystem = "\(Bundle.main.bundleIdentifier!)"
    fileprivate static let source = Logger(subsystem: subsystem, category: "ImageDataCompression")
}
