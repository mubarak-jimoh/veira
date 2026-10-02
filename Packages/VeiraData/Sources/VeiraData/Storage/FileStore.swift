import Foundation
import VeiraCore

/// File-system storage for larger blobs (progress photos metadata caches, etc.).
public protocol FileStore: Sendable {
    func url(for filename: String, in directory: FileStoreDirectory) async throws -> URL
    func write(_ data: Data, to filename: String, in directory: FileStoreDirectory) async throws
    func read(from filename: String, in directory: FileStoreDirectory) async throws -> Data?
    func delete(_ filename: String, in directory: FileStoreDirectory) async throws
    func exists(_ filename: String, in directory: FileStoreDirectory) async -> Bool
}

public enum FileStoreDirectory: String, Sendable {
    case caches
    case documents
    case applicationSupport
}

/// Disk-backed file store — actor-isolated for safe concurrent writers.
public actor DiskFileStore: FileStore {
    private let logger: any Logging

    public init(logger: any Logging) {
        self.logger = logger
    }

    public func url(for filename: String, in directory: FileStoreDirectory) throws -> URL {
        let base = try baseURL(for: directory)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base.appendingPathComponent(filename, isDirectory: false)
    }

    public func write(_ data: Data, to filename: String, in directory: FileStoreDirectory) throws {
        let destination = try url(for: filename, in: directory)
        try data.write(to: destination, options: [.atomic])
        logger.debug("Wrote \(data.count) bytes to \(filename)", category: .storage)
    }

    public func read(from filename: String, in directory: FileStoreDirectory) throws -> Data? {
        let destination = try url(for: filename, in: directory)
        guard FileManager.default.fileExists(atPath: destination.path) else { return nil }
        return try Data(contentsOf: destination)
    }

    public func delete(_ filename: String, in directory: FileStoreDirectory) throws {
        let destination = try url(for: filename, in: directory)
        guard FileManager.default.fileExists(atPath: destination.path) else { return }
        try FileManager.default.removeItem(at: destination)
    }

    public func exists(_ filename: String, in directory: FileStoreDirectory) -> Bool {
        (try? url(for: filename, in: directory)).map {
            FileManager.default.fileExists(atPath: $0.path)
        } ?? false
    }

    private func baseURL(for directory: FileStoreDirectory) throws -> URL {
        let search: FileManager.SearchPathDirectory = switch directory {
        case .caches: .cachesDirectory
        case .documents: .documentDirectory
        case .applicationSupport: .applicationSupportDirectory
        }

        guard let root = FileManager.default.urls(for: search, in: .userDomainMask).first else {
            throw InfrastructureError.underlying(message: "Missing directory \(directory.rawValue)")
        }

        return root.appendingPathComponent("Veira", isDirectory: true)
    }
}

/// In-memory file store for unit tests.
public actor InMemoryFileStore: FileStore {
    private var files: [String: Data] = [:]

    public init() {}

    public func url(for filename: String, in directory: FileStoreDirectory) -> URL {
        URL(fileURLWithPath: "/memory/\(directory.rawValue)/\(filename)")
    }

    public func write(_ data: Data, to filename: String, in directory: FileStoreDirectory) {
        files[key(filename, directory)] = data
    }

    public func read(from filename: String, in directory: FileStoreDirectory) -> Data? {
        files[key(filename, directory)]
    }

    public func delete(_ filename: String, in directory: FileStoreDirectory) {
        files.removeValue(forKey: key(filename, directory))
    }

    public func exists(_ filename: String, in directory: FileStoreDirectory) -> Bool {
        files[key(filename, directory)] != nil
    }

    private func key(_ filename: String, _ directory: FileStoreDirectory) -> String {
        "\(directory.rawValue)/\(filename)"
    }
}
