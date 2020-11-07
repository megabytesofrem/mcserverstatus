module main;

import std.stdio;

import packet;
import socket;
import server;
import varint;

int main(string[] args) {
	ubyte[] data = handshakeRequest("local.harry.city", 25565);
	MinecraftServer server = MinecraftServer(data);

    // string text = "none";

    // string versionName;
    // long versionProtocol;

    // long players;
    // long maxPlayers;

	writefln("SERVER INFO\n\ntext: %s\n\nversion name: %s\nversion protocol: %d\n\nplayers: %d\nmax players: %d", server.text, server.versionName, server.versionProtocol, server.players, server.maxPlayers);

	return 0;
}
