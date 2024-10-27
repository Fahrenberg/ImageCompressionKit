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

    //MARK: Using compressionQuality
    func testJPGCompressionWithLargeData() throws {
        let jpgQuality: CGFloat = 0.1
        let maxExpectedResultBytes: UInt64 = 520_000

        let image = try XCTUnwrap(TestImage.large)
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

    func testHEICCompressionWithLargeImage() throws {
        let heicQuality: CGFloat = 0.1
        let maxExpectedResultBytes: UInt64 = 115_000

        let image = try XCTUnwrap(TestImage.large)
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
    
    //MARK: No compression for small images
    func testNoHEICCompressionWithSmallImage() throws {
        let image = try XCTUnwrap(TestImage.small)
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
    
    func testNoJPGCompressionWithSmallImage() throws {
        let image = try XCTUnwrap(TestImage.small)
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
  
    //MARK: No compression if using without parameters
    func testNoHEICCompression() throws {
        let image = try XCTUnwrap(TestImage.large)
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
    
    func testNoJPGCompression() throws {
        let image = try XCTUnwrap(TestImage.large)
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
    
    //MARK: Using askedMaxSize (bytes)
    func testHEICCompressToSize() throws {
        let maxExpectedResultBytes: UInt64 = 500_000
        let image = try XCTUnwrap(TestImage.large)
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
    
   
    func testJPGCompressToSize() throws {
        let maxExpectedResultBytes: UInt64 = 105_000
        let image = try XCTUnwrap(TestImage.large)
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

    
    
    //MARK: nil Image
    func testNilImageWithHEICCompression() throws {
    #if canImport(UIKit)
        class MockImage: UIImage, @unchecked Sendable {
            override var cgImage: CGImage? {
                return nil // Always return nil for testing purposes
            }
        }
    #endif
    #if canImport(AppKit)
        class MockImage: NSImage {
            override func cgImage(
                forProposedRect proposedRect: UnsafeMutablePointer<NSRect>?,
                context: NSGraphicsContext?,
                hints: [NSImageRep.HintKey : Any]?
            ) -> CGImage? {
                return nil // Always return nil for testing purposes
            }
        }
    #endif
        let image = MockImage()
        let compressedData = image.heicDataCompression()
        XCTAssertNil(compressedData)
    }

}
