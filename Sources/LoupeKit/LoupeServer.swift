import Foundation
import LoupeCore

#if canImport(UIKit)
import Darwin
import UIKit

public final class LoupeServer: @unchecked Sendable {
    public static let defaultPort: UInt16 = 8765

    private let queue = DispatchQueue(label: "dev.loupe.server")
    private var socketFD: Int32 = -1

    public init() {}

    public func start(port: UInt16 = LoupeServer.defaultPort) throws {
        stop()

        let fd = Darwin.socket(AF_INET, SOCK_STREAM, 0)
        guard fd >= 0 else {
            throw LoupeServerError.socketFailed(errno)
        }

        var reuse: Int32 = 1
        Darwin.setsockopt(
            fd,
            SOL_SOCKET,
            SO_REUSEADDR,
            &reuse,
            socklen_t(MemoryLayout<Int32>.size)
        )

        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        address.sin_port = port.bigEndian
        address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))

        let bindResult = withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
                Darwin.bind(fd, sockaddrPointer, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        guard bindResult == 0 else {
            let error = errno
            Darwin.close(fd)
            throw LoupeServerError.bindFailed(error)
        }

        guard Darwin.listen(fd, 8) == 0 else {
            let error = errno
            Darwin.close(fd)
            throw LoupeServerError.listenFailed(error)
        }

        socketFD = fd
        queue.async { [weak self] in
            self?.acceptLoop(socketFD: fd)
        }
    }

    public func stop() {
        guard socketFD >= 0 else {
            return
        }

        Darwin.close(socketFD)
        socketFD = -1
    }

    private func acceptLoop(socketFD: Int32) {
        while true {
            let clientFD = Darwin.accept(socketFD, nil, nil)
            if clientFD < 0 {
                break
            }

            handleClient(clientFD)
        }
    }

    private func handleClient(_ clientFD: Int32) {
        defer {
            Darwin.close(clientFD)
        }

        var buffer = [UInt8](repeating: 0, count: 16 * 1024)
        let bytesRead = Darwin.read(clientFD, &buffer, buffer.count)
        guard bytesRead > 0 else {
            return
        }

        let request = HTTPRequest(data: Data(buffer.prefix(Int(bytesRead))))
        let payload = responsePayload(for: request)
        let responseText = """
        HTTP/1.1 \(payload.status) \(reasonPhrase(for: payload.status))\r
        Content-Type: application/json; charset=utf-8\r
        Content-Length: \(payload.body.utf8.count)\r
        Connection: close\r
        \r
        \(payload.body)
        """
        write(Data(responseText.utf8), to: clientFD)
    }

    private func responsePayload(for request: HTTPRequest) -> ResponsePayload {
        let box = ResponseBox()
        let semaphore = DispatchSemaphore(value: 0)

        Task { @MainActor in
            box.payload = self.response(for: request)
            semaphore.signal()
        }

        semaphore.wait()
        return box.payload ?? ResponsePayload(status: 500, body: #"{"error":"empty_response"}"#)
    }

    @MainActor
    private func response(for request: HTTPRequest) -> ResponsePayload {
        switch request.path {
        case "/health":
            return ResponsePayload(status: 200, body: #"{"status":"ok","name":"LoupeKit"}"#)
        case "/snapshot":
            do {
                let data = try makeLoupeJSONEncoder().encode(LoupeAgent().captureSnapshot())
                return ResponsePayload(status: 200, body: String(decoding: data, as: UTF8.self))
            } catch {
                return ResponsePayload(status: 500, body: errorBody("snapshot_encoding_failed", error: error))
            }
        case "/observation":
            do {
                let data = try makeLoupeJSONEncoder().encode(LoupeAgent().captureCompactObservation())
                return ResponsePayload(status: 200, body: String(decoding: data, as: UTF8.self))
            } catch {
                return ResponsePayload(status: 500, body: errorBody("observation_encoding_failed", error: error))
            }
        default:
            return ResponsePayload(status: 404, body: #"{"error":"not_found"}"#)
        }
    }

    private func write(_ data: Data, to fd: Int32) {
        data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                return
            }

            var written = 0
            while written < rawBuffer.count {
                let result = Darwin.write(
                    fd,
                    baseAddress.advanced(by: written),
                    rawBuffer.count - written
                )

                if result <= 0 {
                    break
                }

                written += result
            }
        }
    }

    private func reasonPhrase(for status: Int) -> String {
        switch status {
        case 200:
            return "OK"
        case 404:
            return "Not Found"
        case 500:
            return "Internal Server Error"
        default:
            return "OK"
        }
    }

    private func errorBody(_ code: String, error: Error) -> String {
        let message = String(describing: error)
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
        return #"{"error":""# + code + #"","message":""# + message + #""}"#
    }
}

public enum LoupeServerError: Error, Equatable {
    case socketFailed(Int32)
    case bindFailed(Int32)
    case listenFailed(Int32)
}

private final class ResponseBox: @unchecked Sendable {
    var payload: ResponsePayload?
}

private struct ResponsePayload: Sendable {
    var status: Int
    var body: String
}

private struct HTTPRequest: Sendable {
    var method: String
    var path: String

    init(data: Data) {
        let text = String(decoding: data, as: UTF8.self)
        let requestLine = text
            .split(separator: "\r\n", maxSplits: 1, omittingEmptySubsequences: false)
            .first ?? ""
        let parts = requestLine.split(separator: " ")
        method = parts.indices.contains(0) ? String(parts[0]) : "GET"
        path = parts.indices.contains(1) ? String(parts[1]) : "/"

        if let queryIndex = path.firstIndex(of: "?") {
            path = String(path[..<queryIndex])
        }
    }
}

#endif
