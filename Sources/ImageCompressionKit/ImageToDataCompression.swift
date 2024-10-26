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
    /// Otherwise jpg compression.
    /// If data size after compression is greater than proposedMaxSize, one more try with reduced compressionQuality.
    ///
    /// - returns: Compressed Image Data or nil (no compression possible)
    func imageDataCompressing(
        compressionQuality: CGFloat,
        askedMaxBytes: UInt64 = .max
    ) -> Data? {
        if let heicData = self.heicDataCompression(
            compressionQuality: compressionQuality)
        {
            guard heicData.count > askedMaxBytes else { return heicData }
            // one more try with half compressionQuality
            guard
                let minimumHeicData = self.heicDataCompression(
                    compressionQuality: compressionQuality / 2.0)
            else { return heicData }
            return minimumHeicData
        } else {
            if let jpgData = self.jpgDataCompression(
                compressionQuality: compressionQuality)
            {
                guard jpgData.count > askedMaxBytes else { return jpgData }
                // one more try with half compressionQuality
                guard
                    let minimumJpgData = self.jpgDataCompression(
                        compressionQuality: compressionQuality / 2.0)
                else { return jpgData }
                return minimumJpgData
            }
        }
        return nil  // no compression possible
    }
}

extension Logger {
    static let subsystem = "\(Bundle.main.bundleIdentifier!)"
}
