// OCStyle.
//
// Created by Matua Doc.
// Created on 2024-03-16.

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
    
    package var cssDictionary: [String: String] {
        let value = switch self {
        case .fontFamily(let family):
            family.cssValue
        case .fontSize(let int), .borderWidth(let int), .borderRadius(let int):
            "\(int)px"
        case .fontWeight(let weight):
            weight.cssValue
        case .borderStyle(let style):
            style.cssValue
        case .backgroundColor(let color), .foregroundColor(let color), .borderColor(let color):
            color.cssValue
        }
        return [self.cssName: value]
    }
}

/// A type-safe representation of colours used for fonts, backgrounds, and borders.
/// To specify a custom, use OCColor.rgb or OCColor.rgba.
public enum OCColor {
    // No colour.
    case transparent
    
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
    
    /// A custom hex code.
    case hex(String)
    
    
    /// A custom RGB colour. Each number (0 to 255) represents red, green, and blue channels respectively.
    case rgb(UInt8, UInt8, UInt8)
    
    /// A custom RGB colour with alpha channel.
    /// The first three numbers (0 to 255) represent red, green, and blue channels respectively.
    /// The final number (0.0 to 1.0) represents the alpha channel. 0.0 is transparent, 1.0 is opaque.
    case rgba(UInt8, UInt8, UInt8, Double)
    
    package var cssValue: String {
        guard let child = Mirror(reflecting: self).children.first, let label = child.label else {
            return "\(self)"
        }
        return if label != "hex" { "\(label)\(child.value)" } else { "\(child.value)" }
    }
}

/// A type-safe representation of a font family, used for buttons, labels, etc.
public enum OCFontFamily {
    /// The default sans-serif font. On Windows, this is Arial. On macOS, this is Helvetica.
    case sansSerif
    
    /// The default serif font. On Windows, this is Times New Roman. On macOS, this is Times.
    case serif
    
    /// The default monospace font. On most platforms, this is Courier or Courier Mono.
    case monospace
    
    /// A specified font family name.
    case byName(String)
    
    package var cssValue: String {
        guard let child = Mirror(reflecting: self).children.first else {
            if case .sansSerif = self {
                return "sans-serif"
            } else {
                return "\(self)"
            }
        }
        return "\(child.value)"
    }
}

/// A type-safe representation of font weights used for buttons, labels, etc.
public enum OCFontWeight {
    /// Thin text.
    case lighter
    
    /// Regular text.
    case normal
    
    /// Bold text.
    case bold
    
    /// Heavy text.
    case bolder
    
    /// A custom weight. Minimum is 0, maximum is 900.
    case custom(UInt16)
    
    public var description: String {
        switch self {
        case .custom(let weight): return "\(weight)"
        default: return "\(self)"
        }
    }
    
    public var cssValue: String {
        guard let child = Mirror(reflecting: self).children.first else {
            return "\(self)"
        }
        return "\(child.value)"
    }
}

/// A type-safe representation of a border style.
public enum OCBorderStyle : String {
    /// No border.
    case none
    
    /// A dotted line.
    case dotted
    
    /// A dashed line.
    case dashed
    
    /// A solid, uninterrupted line.
    case solid
    
    package var cssValue: String {
        return self.rawValue
    }
}
