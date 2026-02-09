//
//  PathBuilder.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct PathBuilder {

    static func buildPath(
        from svgPath: String,
        scale: CGFloat,
        offsetX: CGFloat,
        offsetY: CGFloat
    ) -> Path {
        var path = Path()
        let commands = SVGPathParser.parse(svgPath)

        var currentPoint = CGPoint.zero
        var lastControlPoint: CGPoint?
        var startPoint = CGPoint.zero

        for command in commands {
            switch command {
            case .moveTo(let x, let y, let relative):
                let point = relative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)
                let scaledPoint = CGPoint(x: point.x * scale + offsetX, y: point.y * scale + offsetY)
                path.move(to: scaledPoint)
                currentPoint = point
                startPoint = point
                lastControlPoint = nil

            case .lineTo(let x, let y, let relative):
                let point = relative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)
                let scaledPoint = CGPoint(x: point.x * scale + offsetX, y: point.y * scale + offsetY)
                path.addLine(to: scaledPoint)
                currentPoint = point
                lastControlPoint = nil

            case .horizontalLineTo(let x, let relative):
                let point = relative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y)
                    : CGPoint(x: x, y: currentPoint.y)
                let scaledPoint = CGPoint(x: point.x * scale + offsetX, y: point.y * scale + offsetY)
                path.addLine(to: scaledPoint)
                currentPoint = point
                lastControlPoint = nil

            case .verticalLineTo(let y, let relative):
                let point = relative
                    ? CGPoint(x: currentPoint.x, y: currentPoint.y + y)
                    : CGPoint(x: currentPoint.x, y: y)
                let scaledPoint = CGPoint(x: point.x * scale + offsetX, y: point.y * scale + offsetY)
                path.addLine(to: scaledPoint)
                currentPoint = point
                lastControlPoint = nil

            case .curveTo(let x1, let y1, let x2, let y2, let x, let y, let relative):
                let control1 = relative
                    ? CGPoint(x: currentPoint.x + x1, y: currentPoint.y + y1)
                    : CGPoint(x: x1, y: y1)
                let control2 = relative
                    ? CGPoint(x: currentPoint.x + x2, y: currentPoint.y + y2)
                    : CGPoint(x: x2, y: y2)
                let end = relative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)
                let scaledControl1 = CGPoint(x: control1.x * scale + offsetX, y: control1.y * scale + offsetY)
                let scaledControl2 = CGPoint(x: control2.x * scale + offsetX, y: control2.y * scale + offsetY)
                let scaledEnd = CGPoint(x: end.x * scale + offsetX, y: end.y * scale + offsetY)
                path.addCurve(to: scaledEnd, control1: scaledControl1, control2: scaledControl2)
                currentPoint = end
                lastControlPoint = control2

            case .smoothCurveTo(let x2, let y2, let x, let y, let relative):
                let control1 = lastControlPoint.map {
                    CGPoint(x: 2 * currentPoint.x - $0.x, y: 2 * currentPoint.y - $0.y)
                } ?? currentPoint
                let control2 = relative
                    ? CGPoint(x: currentPoint.x + x2, y: currentPoint.y + y2)
                    : CGPoint(x: x2, y: y2)
                let end = relative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)
                let scaledControl1 = CGPoint(x: control1.x * scale + offsetX, y: control1.y * scale + offsetY)
                let scaledControl2 = CGPoint(x: control2.x * scale + offsetX, y: control2.y * scale + offsetY)
                let scaledEnd = CGPoint(x: end.x * scale + offsetX, y: end.y * scale + offsetY)
                path.addCurve(to: scaledEnd, control1: scaledControl1, control2: scaledControl2)
                currentPoint = end
                lastControlPoint = control2

            case .quadraticCurveTo(let x1, let y1, let x, let y, let relative):
                let control = relative
                    ? CGPoint(x: currentPoint.x + x1, y: currentPoint.y + y1)
                    : CGPoint(x: x1, y: y1)
                let end = relative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)
                let scaledControl = CGPoint(x: control.x * scale + offsetX, y: control.y * scale + offsetY)
                let scaledEnd = CGPoint(x: end.x * scale + offsetX, y: end.y * scale + offsetY)
                path.addQuadCurve(to: scaledEnd, control: scaledControl)
                currentPoint = end
                lastControlPoint = control

            case .smoothQuadraticCurveTo(let x, let y, let relative):
                let control = lastControlPoint.map {
                    CGPoint(x: 2 * currentPoint.x - $0.x, y: 2 * currentPoint.y - $0.y)
                } ?? currentPoint
                let end = relative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)
                let scaledControl = CGPoint(x: control.x * scale + offsetX, y: control.y * scale + offsetY)
                let scaledEnd = CGPoint(x: end.x * scale + offsetX, y: end.y * scale + offsetY)
                path.addQuadCurve(to: scaledEnd, control: scaledControl)
                currentPoint = end
                lastControlPoint = control

            case .arcTo(_, _, _, _, _, let x, let y, let relative):
                let end = relative
                    ? CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                    : CGPoint(x: x, y: y)
                let scaledEnd = CGPoint(x: end.x * scale + offsetX, y: end.y * scale + offsetY)
                path.addLine(to: scaledEnd)
                currentPoint = end
                lastControlPoint = nil

            case .closePath:
                path.closeSubpath()
                currentPoint = startPoint
                lastControlPoint = nil
            }
        }

        return path
    }
}
