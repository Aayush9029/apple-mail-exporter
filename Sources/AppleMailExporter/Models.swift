import Foundation

public struct EmailRecord {
    public let msgID: Int
    public let subject: String?
    public let senderAddress: String?
    public let senderName: String?
    public let dateSentRaw: Double?
    public let mailboxURL: String?

    public init(
        msgID: Int, subject: String? = nil, senderAddress: String? = nil,
        senderName: String? = nil, dateSentRaw: Double? = nil, mailboxURL: String? = nil
    ) {
        self.msgID = msgID
        self.subject = subject
        self.senderAddress = senderAddress
        self.senderName = senderName
        self.dateSentRaw = dateSentRaw
        self.mailboxURL = mailboxURL
    }
}

public struct ParsedEmail {
    public let headers: [String: String]
    public let body: String

    public init(headers: [String: String], body: String) {
        self.headers = headers
        self.body = body
    }
}
