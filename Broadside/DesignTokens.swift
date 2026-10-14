import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #332848
    static let bg = Color(red: 0.200000, green: 0.156863, blue: 0.282353)
    static let bgHex = "#332848"
    /// #423857
    static let surface = Color(red: 0.258824, green: 0.219608, blue: 0.341176)
    static let surfaceHex = "#423857"
    /// #F4F4F6
    static let ink = Color(red: 0.956863, green: 0.956863, blue: 0.964706)
    static let inkHex = "#F4F4F6"
    /// #9673DE
    static let accent = Color(red: 0.588235, green: 0.450980, blue: 0.870588)
    static let accentHex = "#9673DE"
    /// #BAB6C3
    static let muted = Color(red: 0.729412, green: 0.713725, blue: 0.764706)
    static let mutedHex = "#BAB6C3"
    static let fontFamily = "Hoefler Text"
}
