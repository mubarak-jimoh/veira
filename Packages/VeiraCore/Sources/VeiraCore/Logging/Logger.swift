import Foundation
import OSLog

/// Abstraction over logging so feature code never depends on OSLog directly.
public protocol Logging: Sendable {
    func log(
        _ level: LogLevel,
        _ message: @autoclosure () -> String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    )
}

public extension Logging {
    func debug(
        _ message: @autoclosure () -> String,
        category: LogCategory = .app,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(.debug, message(), category: category, file: file, function: function, line: line)
    }

    func info(
        _ message: @autoclosure () -> String,
        category: LogCategory = .app,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(.info, message(), category: category, file: file, function: function, line: line)
    }

    func warning(
        _ message: @autoclosure () -> String,
        category: LogCategory = .app,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(.warning, message(), category: category, file: file, function: function, line: line)
    }

    func error(
        _ message: @autoclosure () -> String,
        category: LogCategory = .app,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(.error, message(), category: category, file: file, function: function, line: line)
    }

    func fault(
        _ message: @autoclosure () -> String,
        category: LogCategory = .app,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(.fault, message(), category: category, file: file, function: function, line: line)
    }
}

/// Production logger backed by Apple's unified logging system.
public struct OSLogger: Logging {
    private let subsystem: String
    private let minimumLevel: LogLevel
    private let store: OSLogStore

    public init(subsystem: String, minimumLevel: LogLevel) {
        self.subsystem = subsystem
        self.minimumLevel = minimumLevel
        self.store = OSLogStore(subsystem: subsystem)
    }

    public func log(
        _ level: LogLevel,
        _ message: @autoclosure () -> String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    ) {
        guard level >= minimumLevel else { return }

        let logger = store.logger(for: category)
        let composed = "[\(file):\(line)] \(function) — \(message())"

        switch level {
        case .debug:
            logger.debug("\(composed, privacy: .public)")
        case .info:
            logger.info("\(composed, privacy: .public)")
        case .warning:
            logger.warning("\(composed, privacy: .public)")
        case .error:
            logger.error("\(composed, privacy: .public)")
        case .fault:
            logger.fault("\(composed, privacy: .public)")
        }
    }
}

/// No-op logger for tests and previews.
public struct NoOpLogger: Logging {
    public init() {}

    public func log(
        _ level: LogLevel,
        _ message: @autoclosure () -> String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    ) {}
}

/// In-memory logger for unit tests.
public final class InMemoryLogger: Logging, @unchecked Sendable {
    public struct Entry: Sendable, Equatable {
        public let level: LogLevel
        public let message: String
        public let category: LogCategory
    }

    private let lock = NSLock()
    private var _entries: [Entry] = []

    public var entries: [Entry] {
        lock.lock()
        defer { lock.unlock() }
        return _entries
    }

    public init() {}

    public func log(
        _ level: LogLevel,
        _ message: @autoclosure () -> String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    ) {
        let entry = Entry(level: level, message: message(), category: category)
        lock.lock()
        _entries.append(entry)
        lock.unlock()
    }
}

private final class OSLogStore: @unchecked Sendable {
    private let subsystem: String
    private let lock = NSLock()
    private var loggers: [String: Logger] = [:]

    init(subsystem: String) {
        self.subsystem = subsystem
    }

    func logger(for category: LogCategory) -> Logger {
        lock.lock()
        defer { lock.unlock() }
        if let existing = loggers[category.rawValue] {
            return existing
        }
        let created = Logger(subsystem: subsystem, category: category.rawValue)
        loggers[category.rawValue] = created
        return created
    }
}
