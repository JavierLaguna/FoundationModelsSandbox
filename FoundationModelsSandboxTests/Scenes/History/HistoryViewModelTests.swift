import Testing
import Foundation
import FoundationModels
import Mockable
@testable import FoundationModelsSandbox

@MainActor
struct HistoryViewModelTests {

    init() {
        MockerPolicy.default = .relaxed
    }

    // MARK: - Helpers

    private static func makeSUT(
        sessions: [ConversationSession] = []
    ) -> HistoryViewModel {
        let mock = MockSessionRepository()
        given(mock).allSessions().willReturn(sessions)
        return HistoryViewModel(sessionRepository: mock)
    }

    // MARK: - loadSessions

    @Test
    func loadSessions_withStoredSessions_populatesList() async {
        let session1 = ConversationSession(id: UUID(), createdAt: Date().addingTimeInterval(-100))
        let session2 = ConversationSession(id: UUID(), createdAt: Date())

        let sut = Self.makeSUT(sessions: [session1, session2])

        await Task.yield()

        #expect(sut.sessions.count == 2)
        #expect(sut.isLoading == false)
        #expect(sut.error == nil)
    }

    @Test
    func loadSessions_withEmptyStore_keepsEmptyList() async {
        let sut = Self.makeSUT(sessions: [])

        await Task.yield()

        #expect(sut.sessions.isEmpty)
        #expect(sut.isLoading == false)
    }

    @Test
    func loadSessions_ordersByCreationDateDescending() async {
        let older = ConversationSession(id: UUID(), createdAt: Date().addingTimeInterval(-200))
        let newer = ConversationSession(id: UUID(), createdAt: Date())

        let mock = MockSessionRepository()
        given(mock).allSessions().willReturn([newer, older])

        let sut = HistoryViewModel(sessionRepository: mock)

        await Task.yield()

        #expect(sut.sessions.count == 2)
        #expect(sut.sessions[0].id == newer.id)
        #expect(sut.sessions[1].id == older.id)
    }

    @Test
    func loadSessions_setsErrorOnFailure() async {
        let mock = MockSessionRepository()
        given(mock).allSessions().willThrow(RepositoryError.invalidSessionID)

        let sut = HistoryViewModel(sessionRepository: mock)

        await Task.yield()

        #expect(sut.sessions.isEmpty)
        #expect(sut.error != nil)
    }

    // MARK: - deleteSession

    // MARK: - deleteAllSessions

    @Test
    func deleteAllSessions_clearsAllSessions() async {
        let session = ConversationSession()
        let mock = MockSessionRepository()
        given(mock).allSessions().willReturn([session])

        let sut = HistoryViewModel(sessionRepository: mock)

        await Task.yield()
        #expect(sut.sessions.count == 1)

        sut.deleteAllSessions()

        await Task.yield()

        #expect(sut.sessions.isEmpty)
    }
}
