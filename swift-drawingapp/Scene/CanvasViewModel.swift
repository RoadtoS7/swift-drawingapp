//
//  CanvasViewModel.swift
//  swift-drawingapp
//
//  Created by Sunghyun Kim on 2022/10/16.
//

import UIKit
import Combine

typealias StyledShape = Shape & StyleApplying

class CanvasViewModel {
    
    @Published private(set) var shapeViewModels: [ShapeViewModel] = []
    
    private var canvas: Canvas
    
    private var sizeOfView: CGSize!
    private var widthScale: Double!
    private var heightScale: Double!
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(canvas: Canvas) {
        self.canvas = canvas
        setupBindings()
    }
    
    private func setupBindings() {
        canvas.$shapes
            .map { shapes in
                shapes.compactMap { $0 as? StyledShape }
                    .map { self.convertToShapeViewModel($0) }
            }
            .sink { self.shapeViewModels = $0 }
            .store(in: &cancelBag)
    }
    
    func setSizeOfView(_ size: CGSize) {
        sizeOfView = size
        widthScale = size.width / canvas.size.width
        heightScale = size.height / canvas.size.height
    }
    
    func convertPoint(_ point: Point) -> CGPoint {
        return CGPoint(x: point.x * widthScale, y: point.y * heightScale)
    }
    
    func convertToShapeViewModel(_ shape: StyledShape) -> ShapeViewModel {
        let points = shape.points
            .map { convertPoint($0) }
        return ShapeViewModel(
            points: points,
            color: shape.color?.cgColor,
            lineColor: shape.lineColor?.cgColor
        )
    }
}
