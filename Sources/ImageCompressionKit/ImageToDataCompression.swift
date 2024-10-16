import AVFoundation

// Color for macOS and iOS
#if canImport(UIKit)
    import UIKit
    public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
    import AppKit
    public typealias PlatformImage = NSImage
#endif

extension PlatformImage {
    enum HEICError: Error {
        case heicNotSupported
        case cgImageMissing
        case canNotFinalize
        case cgImageNotAddedAndFinished
        case noImageCreated
    }
    /// Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)
    public func heicData(compressionQuality: CGFloat) throws -> Data {
        let data = NSMutableData()
        guard
            let imageDestination =
                CGImageDestinationCreateWithData(
                    data, AVFileType.heic as CFString, 1, nil
                )
        else {
            // [Supported devices for HEIC](https://support.apple.com/en-us/HT207022)
            throw HEICError.heicNotSupported
        }

        #if canImport(UIKit)
        let cgImage = self.cgImage
        #elseif canImport(AppKit)
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
        guard let cgImage else {
            throw HEICError.cgImageMissing
        }

        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]

        CGImageDestinationAddImage(imageDestination, cgImage, options)
        guard CGImageDestinationFinalize(imageDestination) else {
            throw HEICError.cgImageNotAddedAndFinished
        }

        return data as Data
    }

}

extension PlatformImage {
    enum JPGError: Error {
        case image_has_no_data_or_unsupported_bitmap_format
        case noImageCreated
        case unknown
    }
    /// Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)
    #if canImport(UIKit)
        public func jpgCompressorData(compressionQuality: CGFloat) throws
            -> Data
        {
            guard let data = jpegData(compressionQuality: compressionQuality)
            else {
                throw JPGError.image_has_no_data_or_unsupported_bitmap_format
            }
            print("JPGCompressor -jpgData = \(data.count)")
            return data
        }
    #endif
    #if canImport(AppKit)
        public func jpgCompressorData(compressionQuality: CGFloat) throws -> Data {
            let image = self
            let cgImage = image.cgImage(
                forProposedRect: nil, context: nil, hints: nil)!
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            let properties = [NSBitmapImageRep.PropertyKey.compressionFactor: compressionQuality]
            let jpegData = bitmapRep.representation(
                using: NSBitmapImageRep.FileType.jpeg, properties: properties)!
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
