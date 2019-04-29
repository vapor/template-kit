/// Formats a floating-point time interval since epoch date to a specified format.
///
///     dateFormat(<timeIntervalSinceEpoch>, <dateFormat?>)
///
/// If no date format is supplied, a default will be used.
public final class DateFormat: TagRenderer {
    public typealias DateFormatterFactory = () -> DateFormatter

    private let defaultDateFormatterFactory: DateFormatterFactory

    private static let dateAndTimeFormatterFactory: DateFormatterFactory = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }

    private static let iso8601FormatterFactory: DateFormatterFactory = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return dateFormatter
    }

    /// Creates a new `DateFormat` tag renderer.
    public convenience init() {
        self.init(defaultDateFormatterFactory: DateFormat.dateAndTimeFormatterFactory)
    }

    /// Creates a new `DateFormat` tag renderer.
    /// - parameter defaultDateFormatter: The date formatter to use when the tag invocation
    ///   does not specify a date format.
    public init(defaultDateFormatterFactory: @escaping DateFormatterFactory) {
        self.defaultDateFormatterFactory = defaultDateFormatterFactory
    }

    /// A `DateFormat` tag renderer that uses ISO 8601 date formatting by default.
    public static let iso8601 = DateFormat(defaultDateFormatterFactory: DateFormat.iso8601FormatterFactory)

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

        let dateFormatter: DateFormatter
        var dateFormat: String?
        if tag.parameters.count == 2 {
            /// Set format as the second param. If that's not available, we'll use `self.defaultDateFormatterFactory`.
            dateFormat = tag.parameters[1].string
        }

        let cacheKey = dateFormat ?? DateFormatterCache.defaultFormatterPlaceholderKey
        if let formatter = dateFormatterCache.dateFormatters[cacheKey] {
            dateFormatter = formatter
        } else {
            if let dateFormat = dateFormat {
                dateFormatter = DateFormatter()
                dateFormatter.dateFormat = dateFormat
            } else {
                dateFormatter = self.defaultDateFormatterFactory()
            }
            dateFormatterCache.dateFormatters[cacheKey] = dateFormatter
        }

        /// Return formatted date
        return Future.map(on: tag) { .string(dateFormatter.string(from: date)) }
    }
}

private class DateFormatterCache {
    static let userInfoKey = "TemplateKit.DateFormatterCache"
    static let defaultFormatterPlaceholderKey = "DEFAULT"

    var dateFormatters: [String: DateFormatter] = [:]
}
