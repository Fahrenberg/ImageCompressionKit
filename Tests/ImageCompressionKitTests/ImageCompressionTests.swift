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
        let jpgQuality: CGFloat = 0.3
        let maxExpectedResultBytes: UInt64 = 790_000

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
        let heicQuality: CGFloat = 0.3
        let maxExpectedResultBytes: UInt64 = 380_000

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
        let maxExpectedSize: UInt64 = 105_000
        let image = try XCTUnwrap(TestImage.large)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.heicDataCompression(askedMaxSize: maxExpectedSize)
        let resultSize =  UInt64(try XCTUnwrap(compressedData?.count))
        
        let maxSize = UInt64( Double(maxExpectedSize) * 1.1)
        XCTAssertLessThan(resultSize, maxSize ) // +10% deviation allowed
        
        let minSize = UInt64( Double(maxExpectedSize) * 0.9)
        XCTAssertGreaterThan(resultSize, minSize) // -10% deviation allowed
        
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
        let maxExpectedSize: UInt64 = 500_000
        let image = try XCTUnwrap(TestImage.large)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.jpgDataCompression(askedMaxSize: maxExpectedSize)
        let resultSize =  UInt64(try XCTUnwrap(compressedData?.count))
        
        let maxSize = UInt64( Double(maxExpectedSize) * 1.1)
        XCTAssertLessThan(resultSize, maxSize ) // +10% deviation allowed
        
        let minSize = UInt64( Double(maxExpectedSize) * 0.9)
        XCTAssertGreaterThan(resultSize, minSize) // -10% deviation allowed
        
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

    
    func testHEICCompressionQualityOutOfBounds() throws {
        let image = try XCTUnwrap(TestImage.large)
           
           // Test compressionQuality < 0
           let dataNegativeQuality = image.heicDataCompression(compressionQuality: -1.0)
           XCTAssertNotNil(dataNegativeQuality, "Data should not be nil for out-of-bounds quality < 0")
           
           // Test compressionQuality > 1
           let dataHighQuality = image.heicDataCompression(compressionQuality: 2.0)
           XCTAssertNotNil(dataHighQuality, "Data should not be nil for out-of-bounds quality > 1")
           
           // Test compressionQuality = 0
           let dataZeroQuality = image.heicDataCompression(compressionQuality: 0.0)
           XCTAssertNotNil(dataZeroQuality, "Data should not be nil for quality = 0")
           
           // Test compressionQuality = 1
           let dataMaxQuality = image.heicDataCompression(compressionQuality: 1.0)
           XCTAssertNotNil(dataMaxQuality, "Data should not be nil for quality = 1")
       }
       
    func testJPGCompressionQualityOutOfBounds() throws {
           let image = try XCTUnwrap(TestImage.large)
           
           // Test compressionQuality < 0
           let dataNegativeQuality = image.jpgDataCompression(compressionQuality: -1.0)
           XCTAssertNotNil(dataNegativeQuality, "Data should not be nil for out-of-bounds quality < 0")
           
           // Test compressionQuality > 1
           let dataHighQuality = image.jpgDataCompression(compressionQuality: 2.0)
           XCTAssertNotNil(dataHighQuality, "Data should not be nil for out-of-bounds quality > 1")
           
           // Test compressionQuality = 0
           let dataZeroQuality = image.jpgDataCompression(compressionQuality: 0.0)
           XCTAssertNotNil(dataZeroQuality, "Data should not be nil for quality = 0")
           
           // Test compressionQuality = 1
           let dataMaxQuality = image.jpgDataCompression(compressionQuality: 1.0)
           XCTAssertNotNil(dataMaxQuality, "Data should not be nil for quality = 1")
       }
    
    func testHEICCompressionWithEqualOrMoreThan20Attempts() throws {
        let maxExpectedSize: UInt64 = 10_000  // too small, will fail!
        let image = try XCTUnwrap(TestImage.large)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.heicDataCompression(askedMaxSize: maxExpectedSize)
        let resultSize =  UInt64(try XCTUnwrap(compressedData?.count))
        
        let maxSize = UInt64( Double(maxExpectedSize) * 1.1)
        XCTAssertLessThan(resultSize, maxSize ) // +10% deviation allowed
        
        let minSize = UInt64( Double(maxExpectedSize) * 0.9)
        XCTAssertGreaterThan(resultSize, minSize) // -10% deviation allowed
        
        Logger.test.error(
            """
            testHEICCompressionWithEqualOrMoreThan20Attempts:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            Factor: \(Double(originalSize) / (Double(resultSize)))x smaller
            """
            )
    }
    
    
    func testJPGCompressionWithEqualOrMoreThan20Attempts() throws {
        let maxExpectedSize: UInt64 = 100_000 // too small, will fail!
        let image = try XCTUnwrap(TestImage.large)
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.jpgDataCompression(askedMaxSize: maxExpectedSize)
        let resultSize =  UInt64(try XCTUnwrap(compressedData?.count))
        
        let maxSize = UInt64( Double(maxExpectedSize) * 1.1)
        XCTAssertLessThan(resultSize, maxSize ) // +10% deviation allowed
        
        let minSize = UInt64( Double(maxExpectedSize) * 0.9)
        XCTAssertGreaterThan(resultSize, minSize) // -10% deviation allowed
        
        Logger.test.error(
            """
            testJPGCompressionWithEqualOrMoreThan20Attempts:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            Factor: \(Double(originalSize) / (Double(resultSize)))x smaller
            """
            )
    }
    
}

