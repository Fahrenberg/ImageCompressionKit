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
        Logger.test.info("image size: \(image.sizeDescription, privacy: .public)")

        let imageCenterAligned = try XCTUnwrap(TestImage.image(size: .small_center))
        Logger.test.info("imageCenterAligned size: \(imageCenterAligned.sizeDescription, privacy: .public)")
        
        let expectedHeight = Int(imageCenterAligned.size.height)
        let expectedWidth = Int(imageCenterAligned.size.width)
        Logger.test.info("expectedHeight: \(expectedHeight, privacy: .public), expectedWidth: \(expectedWidth)")
        let resizedImage = image.resized(
            to: CGSize(width: expectedWidth, height: expectedHeight),
            alignment: .center
        )
        let resultWidth = Int(try XCTUnwrap(resizedImage?.size.width))
        let resultHeight = Int(try XCTUnwrap(resizedImage?.size.height))
        Logger.test.info("resizedImage: \(resizedImage?.sizeDescription ?? "nil", privacy: .public)")
        XCTAssertEqual(resultHeight, expectedHeight)
        XCTAssertEqual(resultWidth, expectedWidth)
        
        // Alignment test: images size must be equal
        XCTAssertEqual(resizedImage?.pngData()?.count, imageCenterAligned.pngData()?.count)
        // write resizedImage to disk for preview
        try resizedImage?.writeToDisk(filename: "resizedAlignedImage.bmp")
        
    }

}
