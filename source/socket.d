module socket;

import std.stdio;
import std.string;
import std.socket;
import std.conv;

import varint;
import packet;

ubyte[] handshakeRequest(string serverAddress, ushort port) {
    Socket listener = new TcpSocket;
    assert(listener.isAlive);
    
    listener.connect(new InternetAddress(serverAddress, port));

    // Send initial handshake packet
    ubyte[] req = writeHandshakePacket(serverAddress, port);
    listener.send(req);

    // Send followup
    ubyte[2] followup = [ 0x01, 0x00 ];
    listener.send(followup);

    while (true) {
        long bytes;
        // NOTE: this is temporary, will most likely loop with 2k buffer until data complete or read initial varint to determine size
        ubyte[20000] buf;
        bytes = listener.receive(buf);
        if (bytes == Socket.ERROR) {
            listener.close();
            throw new StringException("Connection Error: ", lastSocketError());
        } else if (bytes == 0) {
            listener.close();
            try {
                throw new StringException("Lost connection");
            } catch (SocketException) {
                throw new StringException("Connection closed");
            }
        } else {
            // writeln("Recieved ", bytes, "bytes from ", to!string(listener.remoteAddress()));
            // NOTE: not sure if .dup is best idea, may need to change
            return buf.dup;
        }
    }
}