module socket;

import std.stdio;
import std.string;
import std.socket;
import std.conv;

import varint;
import packet;

// https://wiki.vg/Server_List_Ping

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

    ubyte[20000] buf;
    ubyte[] data;

    while (true) {
        long bytes;
        bytes = listener.receive(buf);

        if (bytes == Socket.ERROR) {
            listener.close();
            throw new StringException("Connection Error: ", lastSocketError());
        } else if (bytes == 0) {
            listener.close();
            throw new StringException("Connection closed");
        } else {
             writeln("Recieved ", bytes, "bytes from ", to!string(listener.remoteAddress()));
             data = data ~ buf[0..bytes+1];
             if (data[data.length - 1] == 0) {
                // End of string
                listener.close();
                return data.dup;
             }
        }
    }
}