//
//  HEICWithData.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 16.06.2026.
//

import Playgrounds
import Foundation
import UniformTypeIdentifiers
import ImageIO
import Extensions
import ImageConverterKit





#Playground("Image Types") {
    let filenames = [
//     "HEIC-Scan.heic",
//     "JPG-Scan.jpg",
//     "PNG-Scan-1.png",
     "JPG-Large.jpg",
//     "TIFF.tif",
//     "Sample-Word-DOC.docx",
//     "SamplePDF.pdf",
     "small-webp.bmp"
    ]
   
    for filename in filenames {
        let data: Data = try readTestData(filename: filename)
        let convertedData = data.heicData()
        print(data.count,
              data.isImage,
              data.imageType?.isHEICImage,
              convertedData?.count,
              convertedData?.imageType?.isHEICImage
              )
    }
    
}

#Playground("Image Dimension") {
    let filename = "small-webp.bmp"
    guard let originalData: Data = try? readTestData(filename: filename),
          let originalSource = CGImageSourceCreateWithData(originalData as CFData, nil),
          let originalImage =  CGImageSourceCreateImageAtIndex(originalSource, 0, nil)
    else { return  }
    _ = originalImage.width
    _ = originalImage.height
    
   
    guard let heicData = originalData.heicData(),
          let heicSource = CGImageSourceCreateWithData(heicData as CFData, nil),
          let heicImage =  CGImageSourceCreateImageAtIndex(heicSource, 0, nil)
    else { return  }
    _ = heicImage.width
    _ = heicImage.height
    
}
