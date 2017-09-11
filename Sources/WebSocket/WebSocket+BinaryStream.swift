import Foundation
import Core

final class BinaryStream : Core.Stream {
    /// Sends this binary data to the other party
    func inputStream(_ input: ByteBuffer) {
        do {
            let mask = self.masking ? randomMask() : nil
            
            let frame = try Frame(op: .binary, payload: input, mask: mask)
            
            if masking {
                frame.mask()
            }
            
            frameStream?.inputStream(frame)
        } catch {
            self.errorStream?(error)
        }
    }
    
    /// A stream of incoming binary data
    var outputStream: ((ByteBuffer) -> ())?
    
    internal weak var frameStream: Connection?
    
    /// A stream of errors
    ///
    /// Will only be called if there's a problem creating a frame for output
    var errorStream: ErrorHandler?
    
    typealias Input = ByteBuffer
    typealias Output = ByteBuffer
    
    /// Returns whether to add mask a mask to this message
    var masking: Bool {
        return frameStream?.serverSide == false
    }
    
    /// Creates a new BinaryStream that has yet to be linked up with other streams
    init() { }
}


extension WebSocket {
    /// Sends a `ByteBuffer` to the server
    public func send(_ buffer: ByteBuffer) {
        self.binaryStream.inputStream(buffer)
    }
    
    /// Sends `Data` to the server
    public func send(_ data: Data) {
        data.withUnsafeBytes { buffer in
            self.binaryStream.inputStream(ByteBuffer(start: buffer, count: data.count))
        }
    }
    
    /// Drains the BinaryStream into this closure.
    ///
    /// Any previously listening closures will be overridden
    public func onBinary(_ closure: @escaping ((ByteBuffer) -> ())) {
        self.binaryStream.drain(closure)
    }
    
    /// Drains the BinaryStream into this closure.
    ///
    /// Any previously listening closures will be overridden
    public func onData(_ closure: @escaping ((Data) -> ())) {
        self.binaryStream.drain { buffer in
            closure(Data(buffer))
        }
    }
}
