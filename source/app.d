module main;

import std.stdio;

import packet;
import socket;
import server;
import varint;
import cli;

int main(string[] argv) {

	CommandLineResult cli = parseArgv(argv[1..$]);
	writeln("command: " ~ cli.command);
	foreach(arg; cli.arguments) {
		writeln("\nargument: " ~ arg.name);
		if (!arg.str.isNull) {
			writeln("str: " ~ arg.str.get);
		}
	}

	//ubyte[] data = handshakeRequest("localhost", 25565);
	//MinecraftServer server = MinecraftServer(data);

	//writefln("SERVER INFO\n\ntext: %s\n\nversion name: %s\nversion protocol: %d\n\nplayers: %d\nmax players: %d", server.text, server.versionName, server.versionProtocol, server.players, server.maxPlayers);

	//if (server.favicon.length > 0) {
	//	writeln("[server has a favicon]");
	//}

	return 0;
}
