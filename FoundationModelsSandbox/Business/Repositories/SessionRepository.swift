import Foundation
import Mockable

/// Repository for persisting and loading conversation sessions.
/// Abstracts the storage layer so the domain never depends on the database.
@Mockable
protocol SessionRepository: Sendable {
    /// Persists a session (insert or replace).
    func saveSession(_ session: ConversationSession) throws

    /// Updates an existing session.
    func updateSession(_ session: ConversationSession) throws

    /// Fetches a single session by its ID.
    func session(id: UUID) throws -> ConversationSession?

    /// Returns all sessions ordered by creation date (newest first).
    func allSessions() throws -> [ConversationSession]

    /// Deletes a single session.
    func deleteSession(id: UUID) throws

    /// Removes every session from the store.
    func deleteAllSessions() throws
}
