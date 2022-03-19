module server;

import std.stdio;
import std.json;
import std.conv;
import std.string;

import varint;

private struct ResponseStream {
    int index = 0;
    ubyte[] data;
    this(ubyte[] data) {
        this.data = data;
    }

    int readVarInt() {
        VarInt result = VarInt(this.data[this.index .. data.length]);
        this.index += result.data.length;
        return result.value;
    }

    string readString() {
        int nullByteOffset = this.index;
        foreach (dataIndex, char dataChar; this.data[index .. data.length]) {
            if (dataChar == '\0') {
                nullByteOffset += dataIndex;
                break;
            }
        }
        ubyte[] stringData = this.data[this.index .. nullByteOffset];
        this.index = nullByteOffset;
        return stringData.assumeUTF;
    }
}

struct MinecraftServer {
    string text = "";

    string versionName;
    long versionProtocol;

    long players;
    long maxPlayers;

    // ubyte[] favicon;

    this(ubyte[] response) {
        ResponseStream stream = ResponseStream(response);
        int packetLength = stream.readVarInt();
        // + 1 for the null byte after the packet length
        stream.index += 1;
        int packetId = stream.readVarInt();
        string jsonData = stream.readString();

        JSONValue data = parseJSON(jsonData);

        this.text = data["description"]["text"].str;

        this.versionName = data["version"]["name"].str;
        this.versionProtocol = data["version"]["protocol"].integer;

        this.players = data["players"]["online"].integer;
        this.maxPlayers = data["players"]["max"].integer;
    }
}