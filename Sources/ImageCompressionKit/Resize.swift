//
//  Resize.swift
//  PDF-Reporting
//
//  Created by Jean-Nicolas on 30.01.2025.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension PlatformImage {
    public func resized(to targetSize: CGSize, dpi: CGFloat = 72.0) -> PlatformImage? {
        let scaleFactor = dpi / 72.0
        let canvasSize = CGSize(width: targetSize.width * scaleFactor,
                                height: targetSize.height * scaleFactor)
        
        // Get the original image size
        let originalSize = self.size
        
        // Compute the scale factor to preserve the aspect ratio
        let widthRatio = canvasSize.width / originalSize.width
        let heightRatio = canvasSize.height / originalSize.height
        let uniformScale = min(widthRatio, heightRatio)
        
        // Determine the scaled image size
        let scaledImageSize = CGSize(width: originalSize.width * uniformScale,
                                     height: originalSize.height * uniformScale)
        
        // Center the scaled image in the canvas
        let xOffset = (canvasSize.width - scaledImageSize.width) / 2.0
        let yOffset = (canvasSize.height - scaledImageSize.height) / 2.0
        let drawingRect = CGRect(origin: CGPoint(x: xOffset, y: yOffset),
                                 size: scaledImageSize)
        
        #if canImport(UIKit)
        // For iOS, use UIGraphicsImageRenderer to create the image context.
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        return renderer.image { _ in
            self.draw(in: drawingRect)
        }
        #elseif canImport(AppKit)
        // For macOS, create a new NSImage and draw into it.
        let newImage = NSImage(size: canvasSize)
        newImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        self.draw(in: NSRect(origin: CGPoint(x: xOffset, y: yOffset), size: scaledImageSize),
                  from: NSRect(origin: .zero, size: originalSize),
                  operation: .copy,
                  fraction: 1.0)
        newImage.unlockFocus()
        return newImage
        #endif
    }
}
