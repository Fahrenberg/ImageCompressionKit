//
//  -------------------------------------------------------------------
//  ---------------     Image Resize Tests      		 --------------
//  ---------------		                    			 --------------
//  -------				                                    	-------
//  -------------------------------------------------------------------

import XCTest
import OSLog

@testable import ImageCompressionKit

final class ImageResizeTests: XCTestCase {
    func testResizeMediumImage() throws {
        let image = try XCTUnwrap(TestImage.image(size: .medium))
        Logger.test.info("image size: \(image.sizeDescription, privacy: .public)")
        let expectedHeight = 500
        let expectedWidth = 500
        let resizedImage = image.resized(to: CGSize(width: expectedWidth, height: expectedHeight))
        let resultWidth = Int(try XCTUnwrap(resizedImage?.size.width))
        let resultHeight = Int(try XCTUnwrap(resizedImage?.size.height))
        Logger.test.info("image resized: \(resizedImage?.sizeDescription ?? "nil", privacy: .public)")
        XCTAssertEqual(resultHeight, expectedHeight)
        XCTAssertEqual(resultWidth, expectedWidth)
        
        // write resizedImage to disk for preview
        try resizedImage?.writeToDisk(filename: "resizedImage.bmp")
    }
    
    // alignment (default = center)
    // fill transparent pixels (optional)
    
    func testResizedImageCenterAlignment() throws {
        let image = try XCTUnwrap(TestImage.image(size: .small))
        let imageCenterAligned = try XCTUnwrap(TestImage.image(size: .small))
        Logger.test.info("image size: \(image.sizeDescription, privacy: .public)")
        let expectedHeight = 200
        let expectedWidth = 400
        let resizedImage = image.resized(to: CGSize(width: expectedWidth, height: expectedHeight))
        let resultWidth = Int(try XCTUnwrap(resizedImage?.size.width))
        let resultHeight = Int(try XCTUnwrap(resizedImage?.size.height))
        Logger.test.info("image resized: \(resizedImage?.sizeDescription ?? "nil", privacy: .public)")
        XCTAssertEqual(resultHeight, expectedHeight)
        XCTAssertEqual(resultWidth, expectedWidth)
        // write resizedImage to disk for preview
        try resizedImage?.writeToDisk(filename: "resizedAlignedImage.bmp")
        
    }

}
