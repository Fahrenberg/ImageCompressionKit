//
//  -------------------------------------------------------------------
//  ---------------     JPGCompressorTests		 --------------
//  ---------------					 --------------
//  -------					-------
//  -------------------------------------------------------------------

import XCTest
import OSLog

@testable import ImageCompressionKit

final class ImageCompressionTests: XCTestCase {

    var largeImage: PlatformImage? {
        let bundle = Bundle.module
        let largeImageURL  = bundle.url(forResource: "large", withExtension: "png")!
        #if canImport(UIKit)
        return UIImage(contentsOfFile: largeImageURL.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: largeImageURL)
        #endif
    }

    func testBundleAccessToImage() {
        let image = largeImage
        XCTAssertNotNil(image)
    }

    //MARK: JPGCompressor
    func testJPGCompressorLargeData() throws {
        let jpgQuality: CGFloat = 0.1
        let maxExpectedResultBytes: UInt64 = 520_000

        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)

        let compressedSize = image.jpgDataCompression(
            compressionQuality: jpgQuality)
        let resultBytes = UInt64(try XCTUnwrap(compressedSize).count)
        XCTAssertNotEqual(resultBytes, 0)
        XCTAssertLessThanOrEqual(resultBytes, maxExpectedResultBytes)
        Logger.test.info(
            """
            testJPGCompressorLargeData: 
            Original-Size: \(originalSize) 
            Compressed-Size: \(resultBytes)
            Factor: \(Double(originalSize) / (Double(resultBytes)))x smaller
            """
        )
    }

    //MARK: HEIC Compressor
    func testHEICLargeData() throws {
        let heicQuality: CGFloat = 0.1
        let maxExpectedResultBytes: UInt64 = 105_000

        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)

        let compressedSize = image.heicDataCompression(compressionQuality: heicQuality)
        let resultBytes = UInt64(try XCTUnwrap(compressedSize).count)
        XCTAssertNotEqual(resultBytes, 0)
        XCTAssertLessThanOrEqual(resultBytes, maxExpectedResultBytes)
        Logger.test.info(
            """
            testHEICLargeData: 
            Original-Size: \(originalSize) 
            Compressed-Size: \(resultBytes)
            Factor: \(Double(originalSize) / (Double(resultBytes)))x smaller
            """
        )

    }
    
    func testLargeImageCompressionWithMaxSizeAndHalfCompressionQualiy() throws {
        let compressionQuality = 0.5
        let maxExpectedResultBytes: UInt64 = 500_000
        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.imageDataCompressing(
            compressionQuality: compressionQuality,
            askedMaxBytes: maxExpectedResultBytes
        )
        
        let notNilCompressedData: Data = try XCTUnwrap(compressedData)
        let compressedSize = UInt64(notNilCompressedData.count)
        Logger.test.info(
            """
            testLargeImageCompressionWithMaxSize (\(maxExpectedResultBytes))
            Original-Size: \(originalSize) 
            Compressed-Size: \(compressedSize)
            """
        )
        XCTAssertLessThanOrEqual(
            UInt64(compressedSize),
            maxExpectedResultBytes
        )
    }
    
    func testLargeImageCompressionWithMaxSize() throws {
        let compressionQuality = 0.5
        let maxExpectedResultBytes: UInt64 = 1_100_000
        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.imageDataCompressing(
            compressionQuality: compressionQuality,
            askedMaxBytes: maxExpectedResultBytes
        )
        
        let notNilCompressedData: Data = try XCTUnwrap(compressedData)
        let compressedSize = UInt64(notNilCompressedData.count)
        Logger.test.info(
            """
            testLargeImageCompressionWithMaxSize (\(maxExpectedResultBytes))
            Original-Size: \(originalSize) 
            Compressed-Size: \(compressedSize)
            """
        )
        XCTAssertLessThanOrEqual(
            UInt64(compressedSize),
            maxExpectedResultBytes
        )
    }
    
    func testLargeImageJPGCompressionWithMaxSizeAndHalfCompressionQualiy() throws {
        let compressionQuality = 0.5
        let maxExpectedResultBytes: UInt64 = 670_000
        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.imageDataCompressing(
            compressionQuality: compressionQuality,
            askedMaxBytes: maxExpectedResultBytes,
            jpg: true
        )
        
        let notNilCompressedData: Data = try XCTUnwrap(compressedData)
        let compressedSize = UInt64(notNilCompressedData.count)
        Logger.test.info(
            """
            testLargeImageCompressionWithMaxSize (\(maxExpectedResultBytes))
            Original-Size: \(originalSize) 
            Compressed-Size: \(compressedSize)
            """
        )
        XCTAssertLessThanOrEqual(
            UInt64(compressedSize),
            maxExpectedResultBytes
        )
    }
    
    func testLargeImageJPGCompressionWithMaxSize() throws {
        let compressionQuality = 0.5
        let maxExpectedResultBytes: UInt64 = 1_700_000
        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.imageDataCompressing(
            compressionQuality: compressionQuality,
            askedMaxBytes: maxExpectedResultBytes,
            jpg: true
        )
        
        let notNilCompressedData: Data = try XCTUnwrap(compressedData)
        let compressedSize = UInt64(notNilCompressedData.count)
        Logger.test.info(
            """
            testLargeImageCompressionWithMaxSize (\(maxExpectedResultBytes))
            Original-Size: \(originalSize) 
            Compressed-Size: \(compressedSize)
            """
        )
        XCTAssertLessThanOrEqual(
            UInt64(compressedSize),
            maxExpectedResultBytes
        )
    }
    
}

extension Logger {
    fileprivate static let test = Logger(subsystem: subsystem, category: "ImageDataCompressionTests")
}
