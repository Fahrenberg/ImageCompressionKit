//
//  -------------------------------------------------------------------
//  ---------------     Image Resize Tests      		 --------------
//  ---------------		                    			 --------------
//  -------				                                    	-------
//  -------------------------------------------------------------------

import XCTest
import OSLog
import Extensions

@testable import ImageCompressionKit

final class ImageResizeTests: XCTestCase {
    
    override func setUpWithError() throws {
        let tmpDir = try PlatformImage.tempDirectory()
        FileManager.deleteAllFiles(directoryURL: tmpDir)  // reset
    }
    
    func testResizeMediumImage() throws {
        let image = try XCTUnwrap(TestImage.image(size: .medium))
        Logger.test.info("image size: \(image.sizeDescription, privacy: .public)")
        let expectedHeight = 500
        let expectedWidth = 500
        
        // ** function resized to test **
        let resizedImage = image.resized(to: CGSize(width: expectedWidth, height: expectedHeight))
        // **
        
        let resultWidth = Int(try XCTUnwrap(resizedImage?.size.width))
        let resultHeight = Int(try XCTUnwrap(resizedImage?.size.height))
        Logger.test.info("image resized: \(resizedImage?.sizeDescription ?? "nil", privacy: .public)")
        XCTAssertEqual(resultHeight, expectedHeight)
        XCTAssertEqual(resultWidth, expectedWidth)
        
        let resizedImageUnWrapped = try XCTUnwrap(resizedImage)
        let framedImage = resizedImageUnWrapped.addFrame().fillFrame() // for better visibility fill and frame image
        // write resizedImage to disk for preview
        try framedImage.writeToDisk(filename: "testResizeMediumImage.bmp")
    }
    
    // alignment (default = center)
    // fill transparent pixels (optional)
    func testAlignmentForResizedImage() throws {
        let image = try XCTUnwrap(TestImage.image(size: .small))
        Logger.test.info("image size: \(image.sizeDescription, privacy: .public)")
        
        let imageCenterAligned = try XCTUnwrap(TestImage.image(size: .small_center))
        Logger.test.info("imageCenterAligned size: \(imageCenterAligned.sizeDescription, privacy: .public)")
        
        let expectedHeight = Int(imageCenterAligned.size.height)
        let expectedWidth = Int(imageCenterAligned.size.width)
        Logger.test.info("expectedHeight: \(expectedHeight, privacy: .public), expectedWidth: \(expectedWidth)")
        
        // ** function resized to test **
        let resizedImage = image.resized(
            to: CGSize(width: expectedWidth, height: expectedHeight),
            alignment: .center
        )
        // **

        let resultWidth = Int(try XCTUnwrap(resizedImage?.size.width))
        let resultHeight = Int(try XCTUnwrap(resizedImage?.size.height))
        Logger.test.info("resizedImage: \(resizedImage?.sizeDescription ?? "nil", privacy: .public)")
        XCTAssertEqual(resultHeight, expectedHeight)
        XCTAssertEqual(resultWidth, expectedWidth)
        
        // Alignment test: images size must be equal
        XCTAssertEqual(resizedImage?.pngData()?.count, imageCenterAligned.pngData()?.count)
        
        let resizedImageVisible = try XCTUnwrap(resizedImage)
        let savedResizedImage = resizedImageVisible.addFrame().fillFrame() // for better visibility
        // write resizedImage to disk for preview
        try savedResizedImage.writeToDisk(filename: "testAlignmentForResizedImage.bmp")
        
    }
}
