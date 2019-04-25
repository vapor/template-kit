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

        /// Expect the date to be a floating point number.
        guard let timestamp = tag.parameters[0].double
            else { return Future.map(on: tag) { .null } }
        let date = Date(timeIntervalSince1970: timestamp)

        let dateFormatterCache: DateFormatterCache
        if let cache = tag.context.userInfo[DateFormatterCache.userInfoKey] as? DateFormatterCache {
            dateFormatterCache = cache
        } else {
            dateFormatterCache = DateFormatterCache()
            tag.context.userInfo[DateFormatterCache.userInfoKey] = dateFormatterCache
        }

        let dateFormat: String
        /// Set format as the second param or default to ISO-8601 format.
        if tag.parameters.count == 2, let param = tag.parameters[1].string {
            dateFormat = param
        } else {
            dateFormat = "yyyy-MM-dd HH:mm:ss"
        }

        let dateFormatter: DateFormatter
        if let formatter = dateFormatterCache.dateFormatters[dateFormat] {
            dateFormatter = formatter
        } else {
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            dateFormatterCache.dateFormatters[dateFormat] = dateFormatter
        }

        /// Return formatted date
        return Future.map(on: tag) { .string(dateFormatter.string(from: date)) }
    }
}

private class DateFormatterCache {
    static let userInfoKey = "TemplateKit.DateFormatterCache"

    var dateFormatters: [String: DateFormatter] = [:]
}
