/// Formats a floating-point time interval since epoch date to a specified format.
///
///     dateFormat(<timeIntervalSinceEpoch>, <dateFormat?>)
///
/// If no date format is supplied, a default will be used.
public final class DateFormat: TagRenderer {
    /// Creates a new `DateFormat` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        /// Require at least one parameter.
        switch tag.parameters.count {
        case 1, 2: break
        default: throw tag.error(reason: "Invalid parameter count: \(tag.parameters.count). 1 or 2 required.")
        }

        let formatter = DateFormatter()
        /// Assume the date is a floating point number
        let date = Date(timeIntervalSince1970: tag.parameters[0].double ?? 0)
        /// Set format as the second param or default to ISO-8601 format.
        if tag.parameters.count == 2, let param = tag.parameters[1].string {
            formatter.dateFormat = param
        } else {
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        }

        /// Return formatted date
        return Future.map(on: tag) { .string(formatter.string(from: date)) }
    }
}
