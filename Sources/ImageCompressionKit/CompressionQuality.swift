//
//  CompressionQuality.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 27.10.2024.
//

import AVFoundation
import OSLog
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
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
