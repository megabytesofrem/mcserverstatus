module cli;

import std.stdio;
import std.string;
import std.conv;
import std.typecons;

struct CommandLineArgument {
	string name;
	char flag;
	string description;
	bool takesArgument = false;

	this(string name, char flag, string description) {
		this.name = name;
		this.flag = flag;
		this.description = description;
		this.takesArgument = takesArgument;
	}
}

CommandLineArgument[] arguments = [
	CommandLineArgument("verbose", 'v', "Verbose log")
];

Nullable!CommandLineArgument parseFlag(char flag) {
	foreach(arg; arguments) {
		if (arg.flag == flag) {
			return arg.nullable;
		}
	}
	return Nullable!CommandLineArgument.init;
}

Nullable!CommandLineArgument parseArgument(string name) {
	foreach(arg; arguments) {
		if (arg.name == name) {
			return arg.nullable;
		}
	}
	return Nullable!CommandLineArgument.init;
}

class CommandLineException: Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

private enum CommandLineState { waiting, dash, flags, argument }

void parseArgv(string[] argv) {
	CommandLineState state = CommandLineState.waiting;
	char[] buffer;
	foreach(arg; argv) {
		foreach(ch; arg) {
			switch (state) {
				case CommandLineState.waiting:
					switch (ch) {
						case '-':
							state = CommandLineState.dash;
							break;
						default:
							throw new CommandLineException("Unexpected char");
					}
					break;
				case CommandLineState.dash:
					switch (ch) {
						case '-':
							buffer = [];
							state = CommandLineState.argument;
							break;
						default:
							Nullable!CommandLineArgument parsedArgument = parseFlag(ch);
							if (!parsedArgument.isNull) {
								writeln("found flag: ", parsedArgument.get.name);
							} else {
								throw new CommandLineException("Invalid char: " ~ ch);
							}
							break;
					}
					break;
				case CommandLineState.flags:
					Nullable!CommandLineArgument parsedArgument = parseFlag(ch);
					if (!parsedArgument.isNull) {
						writeln("found flags: ", parsedArgument.get.name);
					} else {
						throw new CommandLineException("invalid char: " ~ ch);
					}
					break;
				case CommandLineState.argument:
					buffer ~= ch;
					break;
				default:
					break;
			}
		}
		if (state == CommandLineState.argument) {
			if (buffer.length > 0) {
				Nullable!CommandLineArgument parsedArgument = parseArgument(cast(string)buffer);
				if (!parsedArgument.isNull) {
					writeln("found argument: " ~ parsedArgument.get.name);
					buffer = [];
				} else {
					throw new CommandLineException("invalid argument: " ~ cast(string)buffer);
				}
			} else {
				throw new CommandLineException("empty argument");
			}
		}
	}
}