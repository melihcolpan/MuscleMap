//
//  SVGPathCommand.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum SVGPathCommand {
    case moveTo(x: CGFloat, y: CGFloat, relative: Bool)
    case lineTo(x: CGFloat, y: CGFloat, relative: Bool)
    case horizontalLineTo(x: CGFloat, relative: Bool)
    case verticalLineTo(y: CGFloat, relative: Bool)
    case curveTo(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, x: CGFloat, y: CGFloat, relative: Bool)
    case smoothCurveTo(x2: CGFloat, y2: CGFloat, x: CGFloat, y: CGFloat, relative: Bool)
    case quadraticCurveTo(x1: CGFloat, y1: CGFloat, x: CGFloat, y: CGFloat, relative: Bool)
    case smoothQuadraticCurveTo(x: CGFloat, y: CGFloat, relative: Bool)
    case arcTo(rx: CGFloat, ry: CGFloat, angle: CGFloat, largeArc: Bool, sweep: Bool, x: CGFloat, y: CGFloat, relative: Bool)
    case closePath
}
