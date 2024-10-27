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
    
    var smallImage: PlatformImage? {
        let bundle = Bundle.module
        let largeImageURL  = bundle.url(forResource: "small", withExtension: "jpeg")!
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
        let maxExpectedResultBytes: UInt64 = 115_000

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
    
    //MARK: No Compression for small images
    
    func testNoHEICCompressionWithSmallImage() throws {
        let image = try XCTUnwrap(smallImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.heicDataCompression(askedMaxSize: 500_000)  // Small Image is 223613 bytes
        let resultSize = try XCTUnwrap(compressedData?.count)
        XCTAssertEqual(resultSize, originalSize)
        Logger.test.info(
            """
            testNoHEICCompressionWithSmallImage:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            """
            )
    }
    
    //MARK: No / Lossless Compression ( pngData() )
    func testNoHEICCompression() throws {
        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.heicDataCompression()
        let resultSize = try XCTUnwrap(compressedData?.count)
        XCTAssertEqual(resultSize, originalSize)
        Logger.test.info(
            """
            testNoHEICCompression:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            Factor: \(Double(originalSize) / (Double(resultSize)))x smaller
            """
            )
    }
    
    //MARK: Compress to a size(bytes)
    func testHEICCompressToSize() throws {
        let maxExpectedResultBytes: UInt64 = 500_000
        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.heicDataCompression(askedMaxSize: maxExpectedResultBytes)
        let resultSize = try XCTUnwrap(compressedData?.count)
        
        let maxResultSize = UInt64( Double(resultSize) * 1.1) // +10% deviation allowed
        XCTAssertLessThan(maxExpectedResultBytes, maxResultSize)
        
        let minResultSize = UInt64( Double(resultSize) * 0.9)
        XCTAssertGreaterThan(maxExpectedResultBytes, minResultSize) // -10% deviation allowed
        
        Logger.test.info(
            """
            testHEICCompressToSize:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            Factor: \(Double(originalSize) / (Double(resultSize)))x smaller
            """
            )
    }
    
    func testNoJPGCompression() throws {
        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.jpgDataCompression()
        let resultSize = try XCTUnwrap(compressedData?.count)
        XCTAssertEqual(resultSize, originalSize)
        Logger.test.info(
            """
            testNoJPGCompression:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            Factor: \(Double(originalSize) / (Double(resultSize)))x smaller
            """
            )
    }
    
    func testNoJPGCompressionWithSmallImage() throws {
        let image = try XCTUnwrap(smallImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.jpgDataCompression(askedMaxSize: 500_000)  // Small Image is 223613 bytes
        let resultSize = try XCTUnwrap(compressedData?.count)
        XCTAssertEqual(resultSize, originalSize)
        Logger.test.info(
            """
            testNoJPGCompressionWithSmallImage:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            """
            )
    }
    
  
   
    func testJPGCompressToSize() throws {
        let maxExpectedResultBytes: UInt64 = 105_000
        let image = try XCTUnwrap(largeImage)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.jpgDataCompression(askedMaxSize: maxExpectedResultBytes)
        let resultSize = try XCTUnwrap(compressedData?.count)
        
        let maxResultSize = UInt64( Double(resultSize) * 1.1) // +10% deviation allowed
        XCTAssertLessThan(maxExpectedResultBytes, maxResultSize)
        
        let minResultSize = UInt64( Double(resultSize) * 0.9)
        XCTAssertGreaterThan(minResultSize , maxExpectedResultBytes) // -10% deviation allowed
        
        Logger.test.info(
            """
            testJPGCompressToSize:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            Factor: \(Double(originalSize) / (Double(resultSize)))x smaller
            """
            )
    }
    
}
