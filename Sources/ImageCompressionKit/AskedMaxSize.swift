//
//  AskedMaxSize.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 27.10.2024.
//

import Foundation
import OSLog

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
        // Check if the image's original PNG size is smaller or equal to askedMaxSize
        if let originalData = self.pngData(),
           askedMaxSize == .max || UInt64(originalData.count) <= askedMaxSize {
            Logger.source.debug(
                """
                Skipping compression as original image size (\(originalData.count) bytes)
                is smaller than or equal to the askedMaxSize (\(askedMaxSize == .max ? ".max" : String(describing: askedMaxSize)) bytes).
                """
            )
            return originalData
        }

        // Constants for the compression search algorithm
        let tolerance: Double = 0.1 // 10% tolerance
        let maxAttempts = 6 // Limit to avoid infinite loops in case of issues, approx to double digit suffcient
        // Initial bounds for the compression quality (0.0 - lowest, 1.0 - highest)
        var lowerBound: Double = 0.0
        var upperBound: Double = 1.0
        // Results
        var midQuality: Double = 1.0
        var attempts = 0

        while attempts < maxAttempts {
            midQuality = (lowerBound + upperBound) / 2.0

            // Compress the image with the current quality setting
            guard let compressedData = compressionClosure(midQuality) else {
                return nil // Return nil if compression fails
            }

            let dataSize = UInt64(compressedData.count)
            let minSize = UInt64(Double(askedMaxSize) * (1.0 - tolerance))
            let maxSize = UInt64(Double(askedMaxSize) * (1.0 + tolerance))

            // Check if the data size is within the 10% tolerance range
            if dataSize >= minSize && dataSize <= maxSize {
                Logger.source.debug(
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
            }
            attempts += 1
        }
        Logger.source.error(
            """
            Compression not completed for askedMaxSize (\(askedMaxSize))
            Used attempts \(attempts) (max: \(maxAttempts))
            Using CompressionQuality: \(midQuality)
            """
        )
        // If max attempts are reached, use the best found compression quality
        return compressionClosure(midQuality)
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
