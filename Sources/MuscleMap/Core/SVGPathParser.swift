//
//  SVGPathParser.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct SVGPathParser {

    static func parse(_ pathString: String) -> [SVGPathCommand] {
        var commands: [SVGPathCommand] = []
        var index = pathString.startIndex
        var currentCommand: Character = "M"

        func skipWhitespaceAndCommas() {
            while index < pathString.endIndex {
                let char = pathString[index]
                if char == " " || char == "," || char == "\n" || char == "\t" {
                    index = pathString.index(after: index)
                } else {
                    break
                }
            }
        }

        func parseNumber() -> CGFloat? {
            skipWhitespaceAndCommas()
            guard index < pathString.endIndex else { return nil }

            var numStr = ""
            var hasDecimal = false
            var hasExponent = false

            if pathString[index] == "-" || pathString[index] == "+" {
                numStr.append(pathString[index])
                index = pathString.index(after: index)
            }

            while index < pathString.endIndex {
                let char = pathString[index]

                if char.isNumber {
                    numStr.append(char)
                    index = pathString.index(after: index)
                } else if char == "." && !hasDecimal && !hasExponent {
                    hasDecimal = true
                    numStr.append(char)
                    index = pathString.index(after: index)
                } else if (char == "e" || char == "E") && !hasExponent {
                    hasExponent = true
                    numStr.append(char)
                    index = pathString.index(after: index)
                    if index < pathString.endIndex && (pathString[index] == "-" || pathString[index] == "+") {
                        numStr.append(pathString[index])
                        index = pathString.index(after: index)
                    }
                } else {
                    break
                }
            }

            return Double(numStr).map { CGFloat($0) }
        }

        func parseFlag() -> Bool? {
            skipWhitespaceAndCommas()
            guard index < pathString.endIndex else { return nil }
            let char = pathString[index]
            if char == "0" || char == "1" {
                index = pathString.index(after: index)
                return char == "1"
            }
            return nil
        }

        while index < pathString.endIndex {
            skipWhitespaceAndCommas()
            guard index < pathString.endIndex else { break }

            let char = pathString[index]

            if char.isLetter && char != "e" && char != "E" {
                currentCommand = char
                index = pathString.index(after: index)
            }

            let isRelative = currentCommand.isLowercase
            let cmd = currentCommand.uppercased().first!

            switch cmd {
            case "M":
                if let x = parseNumber(), let y = parseNumber() {
                    commands.append(.moveTo(x: x, y: y, relative: isRelative))
                    currentCommand = isRelative ? "l" : "L"
                }

            case "L":
                if let x = parseNumber(), let y = parseNumber() {
                    commands.append(.lineTo(x: x, y: y, relative: isRelative))
                }

            case "H":
                if let x = parseNumber() {
                    commands.append(.horizontalLineTo(x: x, relative: isRelative))
                }

            case "V":
                if let y = parseNumber() {
                    commands.append(.verticalLineTo(y: y, relative: isRelative))
                }

            case "C":
                if let x1 = parseNumber(), let y1 = parseNumber(),
                   let x2 = parseNumber(), let y2 = parseNumber(),
                   let x = parseNumber(), let y = parseNumber() {
                    commands.append(.curveTo(x1: x1, y1: y1, x2: x2, y2: y2, x: x, y: y, relative: isRelative))
                }

            case "S":
                if let x2 = parseNumber(), let y2 = parseNumber(),
                   let x = parseNumber(), let y = parseNumber() {
                    commands.append(.smoothCurveTo(x2: x2, y2: y2, x: x, y: y, relative: isRelative))
                }

            case "Q":
                if let x1 = parseNumber(), let y1 = parseNumber(),
                   let x = parseNumber(), let y = parseNumber() {
                    commands.append(.quadraticCurveTo(x1: x1, y1: y1, x: x, y: y, relative: isRelative))
                }

            case "T":
                if let x = parseNumber(), let y = parseNumber() {
                    commands.append(.smoothQuadraticCurveTo(x: x, y: y, relative: isRelative))
                }

            case "A":
                if let rx = parseNumber(), let ry = parseNumber(),
                   let angle = parseNumber(),
                   let largeArc = parseFlag(),
                   let sweep = parseFlag(),
                   let x = parseNumber(), let y = parseNumber() {
                    commands.append(.arcTo(rx: rx, ry: ry, angle: angle, largeArc: largeArc, sweep: sweep, x: x, y: y, relative: isRelative))
                }

            case "Z":
                commands.append(.closePath)

            default:
                index = pathString.index(after: index)
            }
        }

        return commands
    }
}
