import Foundation
import GRDB
import SQLiteData

// MARK: - SQLite-backed Session Repository

/// Concrete implementation of `SessionRepository` backed by SQLite via GRDB.
///
/// The repository owns a `DatabaseQueue` and manages its own schema through
/// a migrator. Domain models (`ConversationSession`) are mapped to/from
/// a flat `SessionRow` where the messages array is stored as a JSON string.
final class LiveSessionRepository: SessionRepository {

    // MARK: - Internal row entity (SQLite schema)

    struct SessionRow: Codable, Sendable {
        var id: String
        var createdAt: Date
        var modelName: String
        var instructions: String
        var messagesData: String
        var transcriptData: String?
        var truncationStrategy: String?
    }

    // MARK: - Properties

    private let database: DatabaseQueue

    // MARK: - Lifecycle

    init(database: DatabaseQueue) {
        self.database = database
        
        setupDatabase()
    }

    /// Creates a `LiveSessionRepository` with the database stored at the
    /// standard application-support directory.
    static func makeDefault() -> LiveSessionRepository {
        let dbURL = URL.applicationSupportDirectory
            .appending(component: "FoundationModelsSandbox")
            .appending(component: "sessions.db")

        try? FileManager.default.createDirectory(
            at: dbURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let database = try! DatabaseQueue(path: dbURL.path)
        return LiveSessionRepository(database: database)
    }

    // MARK: - Schema setup

    private func setupDatabase() {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("createSessionRow") { db in
            try db.create(table: "sessionRow", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("createdAt", .datetime).notNull()
                t.column("modelName", .text).notNull()
                t.column("instructions", .text).notNull()
                t.column("messagesData", .text).notNull()
            }
        }
        migrator.registerMigration("addTranscriptColumns") { db in
            // Check if columns exist using PRAGMA table_info
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info('sessionRow')")
            let columnNames = Set(columns.compactMap { $0["name"] as? String })
            if !columnNames.contains("transcriptData") {
                try db.execute(sql: "ALTER TABLE sessionRow ADD COLUMN transcriptData TEXT")
            }
            if !columnNames.contains("truncationStrategy") {
                try db.execute(sql: "ALTER TABLE sessionRow ADD COLUMN truncationStrategy TEXT DEFAULT 'dropOldest'")
            }
        }
        try? migrator.migrate(database)
    }

    // MARK: - SessionRepository

    func saveSession(_ session: ConversationSession) throws {
        let row = try encodeRow(session)
        try database.write { db in
            try db.execute(
                sql: """
                    INSERT OR REPLACE INTO sessionRow (id, createdAt, modelName, instructions, messagesData, transcriptData, truncationStrategy)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                arguments: [row.id, row.createdAt, row.modelName, row.instructions, row.messagesData, row.transcriptData, row.truncationStrategy]
            )
        }
    }

    func updateSession(_ session: ConversationSession) throws {
        let row = try encodeRow(session)
        try database.write { db in
            try db.execute(
                sql: """
                    UPDATE sessionRow
                    SET createdAt = ?, modelName = ?, instructions = ?, messagesData = ?, transcriptData = ?, truncationStrategy = ?
                    WHERE id = ?
                    """,
                arguments: [row.createdAt, row.modelName, row.instructions, row.messagesData, row.transcriptData, row.truncationStrategy, row.id]
            )
        }
    }

    func session(id: UUID) throws -> ConversationSession? {
        let idString = id.uuidString
        let rows = try database.read { db in
            try Row.fetchAll(db, sql: "SELECT * FROM sessionRow WHERE id = ?", arguments: [idString])
        }
        return try rows.first.map { try decodeRow($0) }
    }

    func allSessions() throws -> [ConversationSession] {
        let rows = try database.read { db in
            try Row.fetchAll(db, sql: "SELECT * FROM sessionRow ORDER BY createdAt DESC")
        }
        return try rows.map { try decodeRow($0) }
    }

    func lastSession() throws -> ConversationSession? {
        let rows = try database.read { db in
            try Row.fetchAll(db, sql: "SELECT * FROM sessionRow ORDER BY createdAt DESC LIMIT 1")
        }
        return try rows.first.map { try decodeRow($0) }
    }

    /// Decodes a GRDB `Row` into a domain `ConversationSession`.
    private func decodeRow(_ row: Row) throws -> ConversationSession {
        guard let id = UUID(uuidString: row["id"] as? String ?? "") else {
            throw RepositoryError.invalidSessionID
        }
        let messagesData = row["messagesData"] as? String ?? "[]"
        let messages = try JSONDecoder().decode(
            [MessageEntry].self,
            from: Data(messagesData.utf8)
        )
        let strategy = (row["truncationStrategy"] as? String)
            .flatMap { ContextTruncationStrategy(rawValue: $0) } ?? .dropOldest
        let transcriptData = (row["transcriptData"] as? String)
            .flatMap { Data($0.utf8) }

        var session = ConversationSession(
            id: id,
            createdAt: row["createdAt"] as? Date ?? Date(),
            modelName: row["modelName"] as? String ?? "",
            instructions: row["instructions"] as? String ?? "",
            truncationStrategy: strategy
        )
        session.messages = messages
        session.transcriptData = transcriptData
        return session
    }

    /// Encodes a domain `ConversationSession` into a `SessionRow`.
    private func encodeRow(_ session: ConversationSession) throws -> SessionRow {
        let data = try JSONEncoder().encode(session.messages)
        let jsonString = String(data: data, encoding: .utf8) ?? "[]"
        let transcriptString = session.transcriptData.flatMap { String(data: $0, encoding: .utf8) }
        let strategyString = session.truncationStrategy.rawValue
        return SessionRow(
            id: session.id.uuidString,
            createdAt: session.createdAt,
            modelName: session.modelName,
            instructions: session.instructions,
            messagesData: jsonString,
            transcriptData: transcriptString,
            truncationStrategy: strategyString
        )
    }

    func deleteSession(id: UUID) throws {
        let idString = id.uuidString
        try database.write { db in
            try db.execute(sql: "DELETE FROM sessionRow WHERE id = ?", arguments: [idString])
        }
    }

    func deleteAllSessions() throws {
        try database.write { db in
            try db.execute(sql: "DELETE FROM sessionRow")
        }
    }

}

// MARK: - Error

enum RepositoryError: Error, LocalizedError {
    case invalidSessionID

    var errorDescription: String? {
        switch self {
        case .invalidSessionID:
            return "The session data contains an invalid identifier."
        }
    }
}


