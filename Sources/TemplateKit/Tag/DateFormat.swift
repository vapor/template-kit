import Foundation

/// Formats a floating-point time interval since epoch date to a specified format.
///
///     dateFormat(<timeIntervalSinceEpoch>, <dateFormat?>)
///
/// If no date format is supplied, a default will be used.
public final class DateFormat: TagRenderer {
    /// Creates a new `DateFormat` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> TemplateData {
        /// Require at least one parameter.
        switch tag.parameters.count {
        case 1, 2: break
        default: throw tag.error(reason: "Invalid parameter count: \(tag.parameters.count). 1 or 2 required.")
        }

        #warning("FIXME: performance")
        let formatter = DateFormatter()
        /// Assume the date is a floating point number
        let date = Date(timeIntervalSince1970: tag.parameters[0].asDouble ?? 0)
        /// Set format as the second param or default to ISO-8601 format.
        if tag.parameters.count == 2, case .string(let param) = tag.parameters[1] {
            formatter.dateFormat = param
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }

        /// Return formatted date
        return .string(formatter.string(from: date))
    }
}
