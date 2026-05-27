import Foundation

/// Represents the outcome of a conversation message exchange
enum SessionOutcome: Sendable, Equatable, Codable {
    case success(AIResponse)
    case failure(String)
    case noResponse

    /// Returns the AIResponse content if successful, otherwise an empty string
    var content: String {
        switch self {
        case .success(let response):
            return response.content
        case .failure, .noResponse:
            return ""
        }
    }

    /// Returns the formatted metrics if available, otherwise nil
    var formattedMetrics: String? {
        switch self {
        case .success(let response):
            return "\(response.formattedDuration) • \(response.formattedTokenCounts)"
        case .failure, .noResponse:
            return nil
        }
    }

    /// Returns true if this outcome has content to display
    var hasContent: Bool {
        switch self {
        case .success(let response):
            return !response.content.isEmpty
        case .failure, .noResponse:
            return false
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type, response, errorMessage
    }

    private enum CaseType: String, Codable {
        case success, failure, noResponse
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .success(let response):
            try container.encode(CaseType.success, forKey: .type)
            try container.encode(response, forKey: .response)
        case .failure(let message):
            try container.encode(CaseType.failure, forKey: .type)
            try container.encode(message, forKey: .errorMessage)
        case .noResponse:
            try container.encode(CaseType.noResponse, forKey: .type)
        }
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CaseType.self, forKey: .type)
        switch type {
        case .success:
            let response = try container.decode(AIResponse.self, forKey: .response)
            self = .success(response)
        case .failure:
            let message = try container.decode(String.self, forKey: .errorMessage)
            self = .failure(message)
        case .noResponse:
            self = .noResponse
        }
    }
}