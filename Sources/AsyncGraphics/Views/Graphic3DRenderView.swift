//
//  Created by Anton Heestand on 2022-12-10.
//

#if os(visionOS)

import SwiftUI
import CoreGraphicsExtensions

/// SwiftUI view for rendering and displaying ``Graphic3D``s.
public struct Graphic3DRenderView: View {
    
    @Bindable private var renderer: Graphic3DViewRenderer
    
    public init(renderer: Graphic3DViewRenderer) {
        _renderer = Bindable(renderer)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                if let resolution: Size3D = renderer.resolution {
                    ForEach(Array(0..<Int(resolution.depth)), id: \.self) { index in
                        GeometryReader { contentGeometry in
                            GraphicVisionRepresentableView(
                                interpolation: renderer.interpolation,
                                extendedDynamicRange: renderer.extendedDynamicRange
                            ) { renderInView in
                                renderer.renderInView[index] = renderInView
                            }
                            .offset(z: {
                                let count: Int = max(2, Int(resolution.depth))
                                let fraction: CGFloat = CGFloat(index) / CGFloat(count - 1)
                                let depthAspectRatio: CGFloat = resolution.depth / resolution.height
                                return fraction * contentGeometry.size.height * depthAspectRatio
                            }())
                        }
                        .aspectRatio(CGSize(width: resolution.width,
                                            height: resolution.height),
                                     contentMode: .fit)
                    }
                }
            }
            .onAppear {
                renderer.viewSize = geometry.size
            }
            .onChange(of: geometry.size) { _, newSize in
                renderer.viewSize = newSize
            }
        }
        .allowsHitTesting(false)
    }
}

#endif
