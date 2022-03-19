module main;

import std.stdio;

import packet;
import socket;
import server;
import varint;

int main(string[] args) {
	ubyte[] data = handshakeRequest("localhost", 25565);
	MinecraftServer server = MinecraftServer(data);

	writefln("SERVER INFO\n\ntext: %s\n\nversion name: %s\nversion protocol: %d\n\nplayers: %d\nmax players: %d", server.text, server.versionName, server.versionProtocol, server.players, server.maxPlayers);

	return 0;
}
