module main;

import std.stdio;
import std.algorithm;
import std.conv;
import std.array;

import packet;
import socket;
import server;
import varint;
import cli;

import colors;

CommandLineArgument argumentVerbose = CommandLineArgument("verbose", 'v', "Verbose log", true, false);

int main(string[] argv) {

	CommandLineArgument[] arguments = [
		argumentVerbose
	];

	CommandLineResult cli = parseArgv(argv[1..$], arguments);
	foreach (arg; cli.arguments) {
		if (arg == argumentVerbose) {
			writeln("verbose mode");
		}
	}

	string[] splitCommand = cli.command.split(":");
	if (splitCommand.length > 2) {
		throw new CommandLineException("invalid ip given");
	}
	string ip = splitCommand[0];
	ushort port = 25565;
	if (splitCommand.length > 1) {
		try {
			port = to!ushort(splitCommand[1]);
		} catch (ConvException) {
			throw new CommandLineException("invalid port given");
		}
	}

	ubyte[] data = handshakeRequest(ip, port);
	MinecraftServer server = MinecraftServer(data);

	writefln("SERVER INFO\n\ntext: %s\n\nversion name: %s\nversion protocol: %d\n\nplayers: %d\nmax players: %d", server.text, server.versionName, server.versionProtocol, server.players, server.maxPlayers);

	// Convert the minecraft colors to ANSI colors

	if (server.favicon.length > 0) {
		writeln("[server has a favicon]");
	}

	return 0;
}
