// OCStyle.
//
// Created by Matua Doc.
// Created on 2024-03-25.

import Foundation

/// A content justification style, conforming to `justify-content` in CSS.
public enum OCContentJustification : String {
    /// The controls are aligned to the start of the box, usually the left.
    case flexStart = "flex-start !important"

    /// The controls are aligned to the end of the box, usually the right.
    case flexEnd = "flex-end !important"

    /// The controls are aligned to the center of the box.
    case center = "center !important"

    /// The controls are aligned to the start, center, and end. There are spaces between each.
    case spaceBetween = "space-between !important"

    /// The controls are aligned similarly to `.spaceBetween`, with spaces at the start and end.
    case spaceAround = "space-around !important"

    /// The controls are aligned similarly to `.spaceAround` with the space and control width being equal.
    case spaceEvenly = "space-evenly !important"
}



// MARK: - CSS

/// A Swift representation of CSS styles used by Remi.
public enum OCStyle {
    // Colors.
    case backgroundColor(OCColor)
    case foregroundColor(OCColor)
    
    // Font.
    case fontFamily(OCFontFamily)
    case fontSize(Int)
    case fontWeight(OCFontWeight)
    
    // Border.
    case borderStyle(OCBorderStyle)
    case borderWidth(Int)
    case borderRadius(Int)
    case borderColor(OCColor)
    
    fileprivate var cssName: String {
        switch self {
        case .backgroundColor(_): return "background-color"
        case .foregroundColor(_): return "color"
        case .fontFamily(_): return "font-family"
        case .fontSize(_): return "font-size"
        case .fontWeight(_): return "font-weight"
        case .borderStyle(_): return "border-style"
        case .borderColor(_): return "border-color"
        case .borderRadius(_): return "border-radius"
        case .borderWidth(_): return "border-width"
        }
    }
    
    public var cssDictionary: [String: String] {
        let value = switch self {
        case .fontFamily(let family):
            family.description
        case .fontSize(let int), .borderWidth(let int), .borderRadius(let int):
            "\(int)px"
        case .fontWeight(let weight):
            weight.description
        case .borderStyle(let style):
            style.description
        case .backgroundColor(let color), .foregroundColor(let color), .borderColor(let color):
            color.description
        }
        return [self.cssName: value]
    }
}

public enum OCColor : CustomStringConvertible {
    // Basic colours.
    case black
    case silver
    case gray
    case white
    case maroon
    case red
    case purple
    case fuchsia
    case green
    case lime
    case olive
    case yellow
    case navy
    case blue
    case teal
    case aqua
    
    // Extended.
    case aliceBlue
    case antiqueWhite
    case aquaMarine
    case azure
    case beige
    case bisque
    case blanchedAlmond
    case blueviolet
    case brown
    case burlyWood
    case cadetBlue
    case chatreuse
    case chocolate
    case coral
    case cornflowerBlue
    case cornSilk
    case crimson
    case cyan
    case darkBlue
    case darkCyan
    case darkGoldenrod
    case darkGray
    case darkGrey  // Commonwealth spelling.
    case darkGreen
    case darkKhaki
    case darkMagenta
    case darkOliveGreen
    case darkOrange
    case darkOrchid
    case darkRed
    case darkSalmon
    case darkSeaGreen
    case darkSlateBlue
    case darkSlateGray
    case darkSlateGrey  // Commonwealth.
    case darkTurquoise
    case darkViolet
    case deepPink
    case deepSkyBlue
    case dimGray
    case dimGrey  // Commonwealth.
    case dodgerBlue
    case fireBrick
    case floralWhite
    case forestGreen
    case gainsboro
    case ghostWhite
    case gold
    case goldenrod
    case grey  // Commonwealth.
    case greenYellow
    case honeydew
    case hotPink
    case indianRed
    case indigo
    case ivory
    case khaki
    case lavender
    case lavenderblush
    case lawnGreen
    case lemonchiffon
    case lightBlue
    case lightCoral
    case lightCyan
    case lightGoldenrodYellow
    case lightGray
    case lightGrey  // Commonwealth.
    case lightGreen
    case lightPink
    case lightSalmon
    case lightSeaGreen
    case lightSkyBlue
    case lightSlateGray
    case lightSlateGrey  // Commonwealth.
    case lightSteelBlue
    case lightYellow
    case limeGreen
    case linen
    case magenta
    case mediumAquamarine
    case mediumBlue
    case mediumOrchid
    case mediumPurple
    case mediumSeaGreen
    case mediumSlateBlue
    case mediumSpringGreen
    case mediumTurquoise
    case mediumVioletRed
    case midnightBlue
    case mintCream
    case mistyRose
    case moccasin
    case navajoWhite
    case oldLace
    case oliveDrab
    case orange
    case orangeRed
    case orchid
    case paleGoldenrod
    case paleGreen
    case paleTurquoise
    case paleVioletRed
    case papayaWhip
    case peachPuff
    case peru
    case pink
    case plum
    case powderblue
    case rosyBrown
    case royalBlue
    case saddleBrown
    case salmon
    case sandyBrown
    case seaGreen
    case seashell
    case sienna
    case skyBlue
    case slateBlue
    case slateGray
    case slateGrey  // Commonwealth.
    case snow
    case springGreen
    case steelBlue
    case tan
    case thistle
    case tomato
    case turquoise
    case violet
    case wheat
    case whiteSmoke
    case yellowGreen
    
    
    // Custom.
    case hexCode(String)
    
    public var description: String {
        switch self {
        case .hexCode(let hex): return hex
        default: return "\(self)".lowercased()
        }
    }
}

public enum OCFontFamily : CustomStringConvertible {
    case sansSerif
    case serif
    case monospace
    case byName(String)
    
    public var description: String {
        switch self {
        case .sansSerif: return "sans-serif"
        case .byName(let family): return "\(family)"
        default: return "\(self)"
        }
    }
}

public enum OCFontWeight : CustomStringConvertible {
    case lighter
    case normal
    case bold
    case bolder
    case custom(Int)
    
    public var description: String {
        switch self {
        case .custom(let weight): return "\(weight)"
        default: return "\(self)"
        }
    }
}

public enum OCBorderStyle : String, CustomStringConvertible {
    case none
    case dotted
    case dashed
    
    public var description: String {
        return "\(self)"
    }
}
