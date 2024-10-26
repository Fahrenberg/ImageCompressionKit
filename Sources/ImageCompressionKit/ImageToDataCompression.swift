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
    /// Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)
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

extension Logger {
    static let subsystem = "\(Bundle.main.bundleIdentifier!)"
    fileprivate static let source = Logger(subsystem: subsystem, category: "ImageDataCompression")
}
