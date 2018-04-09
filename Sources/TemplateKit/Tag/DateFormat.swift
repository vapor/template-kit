/// Formats a floating-point time interval since epoch date to a specified format.
///
///     dateFormat(<timeIntervalSinceEpoch>, <dateFormat?>)
///
/// If no date format is supplied, a default will be used.
public final class DateFormat: TagRenderer {
    /// Creates a new `DateFormat` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag parsed: TagContext) throws -> TemplateData {
        /// Require at least one parameter.
        try parsed.requireParameterCount(1)

        let formatter = DateFormatter()
        /// Assume the date is a floating point number
        let date = Date(timeIntervalSinceReferenceDate: parsed.parameters[0].double ?? 0)
        /// Set format as the second param or default to ISO-8601 format.
        formatter.dateFormat = parsed.parameters[1].string ?? "yyyy-MM-dd HH:mm:ss"

        /// Return formatted date
        return .string(formatter.string(from: date))
    }
}
