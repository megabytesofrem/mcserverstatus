module packet;

import varint;
import std.string;
import std.stdio;
import std.conv;
import std.bitmanip;

// Documented packet
// https://wiki.vg/Server_List_Ping

ubyte[] writeHandshakePacket(string serverAddress, ushort port) {

    int contentPacketSize = 0;

    // 1. Version number
    const ubyte[] versionNumber = VarInt(754).data;
    contentPacketSize += versionNumber.length;

    // 2. Server address len + server address
    const ubyte[] serverAddressLength = VarInt(to!int(serverAddress.length)).data;
    contentPacketSize += serverAddress.length;
    contentPacketSize += serverAddressLength.length;

    // 3. (Little endian) port
    const ubyte[2] littleEndianPort = nativeToLittleEndian(port);
    contentPacketSize += littleEndianPort.length;

    // 4. Next state (0x01 = requesting server status)
    const ubyte nextState = 0x01;
    contentPacketSize += char.sizeof;

    // 5. Prefix with length
    
    contentPacketSize += 1; // Accounting for null byte (maybe)
    const ubyte[] prefixedLength = VarInt(contentPacketSize).data ~ '\0';
    // contentPacketSize += prefixedLengthVarInt.length;

    ubyte[] finalPacket =
        prefixedLength ~
        versionNumber ~
        serverAddressLength ~
        serverAddress.representation ~
        littleEndianPort[0] ~ littleEndianPort[1] ~
        nextState;

    return finalPacket;
}