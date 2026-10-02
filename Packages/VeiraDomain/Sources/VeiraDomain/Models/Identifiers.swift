import Foundation
import VeiraCore

/// Marker namespaces for typed identifiers.
public enum UserTag: Sendable {}
public enum ScanTag: Sendable {}
public enum ProductTag: Sendable {}
public enum RoutineTag: Sendable {}

public typealias UserID = Identifier<UserTag>
public typealias ScanID = Identifier<ScanTag>
public typealias ProductID = Identifier<ProductTag>
public typealias RoutineID = Identifier<RoutineTag>
