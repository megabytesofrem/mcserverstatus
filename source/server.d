module server;

import std.stdio;
import std.json;
import std.conv;
import std.string;
import std.utf;
import std.base64;
import std.file;

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

private enum FaviconReadState { initial, dataType, encoding, data };

private ubyte[] readFavicon(immutable(ubyte[]) favicon) {
    FaviconReadState state = FaviconReadState.initial;
    ubyte[] buf;
    foreach (favByte; favicon) {
        buf = buf ~ favByte;
        switch (state) {
            case FaviconReadState.initial:
                if (cast(char)favByte == ':') {
                    if (cast(string)buf == "data:") {
                        writeln("debug: state moving to dataType");
                        buf = [];
                        state = FaviconReadState.dataType;
                    }
                } else {
                    // error
                }
                break;
            case FaviconReadState.dataType:
                if (cast(char)favByte == ';') {
                    if (cast(string)buf == "image/png;") {
                        writeln("debug: state moving to encoding");
                        state = FaviconReadState.encoding;
                        buf = [];
                    } else {
                        // error
                    }
                }
                break;
            case FaviconReadState.encoding:
                if (cast(byte)favByte == ',') {
                    if (cast(string)buf == "base64,") {
                        writeln("debug: state moving to data");
                        state = FaviconReadState.data;
                        buf = [];
                    } else {
                        // error
                    }
                }
                break;
            case FaviconReadState.data:
                // do nothing until the foreach ends
                break;
            default:
                break;
        }
    }

    if (state == FaviconReadState.data) {
        return Base64.decode(buf);
    } else {
        return [];
    }
}

struct MinecraftServer {
    string text = "";

    string versionName;
    long versionProtocol;

    long players;
    long maxPlayers;

    ubyte[] favicon = [];

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

        try {
            ubyte[] faviconData = readFavicon(data["favicon"].str.representation);
            this.favicon = faviconData;
        } catch (JSONException) { }
    }
}