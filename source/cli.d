module cli;

import std.stdio;
import std.string;
import std.conv;
import std.typecons;

struct CommandLineArgument {
	string name;
	char flag;
	string description;
	Nullable!string str = Nullable!string.init;
	bool acceptsStr = false;
	bool requiresStr = false;

	this(string name, char flag, string description, bool acceptsStr, bool requiresStr) {
		this.name = name;
		this.flag = flag;
		this.description = description;
		this.acceptsStr = acceptsStr;
		this.requiresStr = requiresStr;
	}
}

struct CommandLineResult {
	string command = "";
	CommandLineArgument[] arguments;
}

Nullable!CommandLineArgument parseFlag(char flag, CommandLineArgument[] arguments) {
	foreach(arg; arguments) {
		if (arg.flag == flag) {
			return arg.nullable;
		}
	}
	return Nullable!CommandLineArgument.init;
}

Nullable!CommandLineArgument parseArgument(string name, CommandLineArgument[] arguments) {
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

private enum CommandLineState { waiting, dash, flags, argument, argumentStr, command }

CommandLineResult parseArgv(string[] argv, CommandLineArgument[] arguments) {
	CommandLineResult result;

	CommandLineState state = CommandLineState.waiting;
	Nullable!CommandLineArgument pendingArgument = Nullable!CommandLineArgument.init;
	char[] buffer;
	foreach(arg; argv) {
		if (state == CommandLineState.flags) { state = CommandLineState.waiting; }
		foreach(ch; arg) {
			switch (state) {
				case CommandLineState.waiting:
					switch (ch) {
						case '-':
							state = CommandLineState.dash;
							break;
						default:
							if (result.command.length <= 0) {
								state = CommandLineState.command;
								buffer = [ch];
							} else {
								throw new CommandLineException("Unexpected char");
							}
					}
					break;
				case CommandLineState.command:
					buffer ~= ch;
					break;
				case CommandLineState.dash:
					switch (ch) {
						case '-':
							buffer = [];
							state = CommandLineState.argument;
							break;
						default:
							state = CommandLineState.flags;
							Nullable!CommandLineArgument parsedArgument = parseFlag(ch, arguments);
							if (!parsedArgument.isNull) {
								result.arguments ~= parsedArgument.get;								
							} else {
								throw new CommandLineException("Invalid char: " ~ ch);
							}
							break;
					}
					break;
				case CommandLineState.flags:
					Nullable!CommandLineArgument parsedArgument = parseFlag(ch, arguments);
					if (!parsedArgument.isNull) {
						result.arguments ~= parsedArgument.get;
					} else {
						throw new CommandLineException("invalid char: " ~ ch);
					}
					break;
				case CommandLineState.argumentStr:
					if (pendingArgument.isNull) {
						throw new CommandLineException("somethign went very wrong");
					}
					switch (ch) {
						case '-':
							if (pendingArgument.get.requiresStr) {
								throw new CommandLineException("Argument " ~ pendingArgument.get.name ~ " expects a following string");
							} else {
								state = CommandLineState.dash;
							}
							break;
						default:
							buffer ~= ch;
							break;
					}
					break;
				case CommandLineState.argument:
					buffer ~= ch;
					break;
				default:
					break;
			}
		}
		if (state == CommandLineState.command) {
			result.command = cast(string)buffer;
			buffer = [];
			state = CommandLineState.waiting;
		} else if (state == CommandLineState.argument) {
			if (buffer.length > 0) {
				Nullable!CommandLineArgument parsedArgument = parseArgument(cast(string)buffer, arguments);
				if (!parsedArgument.isNull) {
					if (parsedArgument.get.acceptsStr) {
						state = CommandLineState.argumentStr;
						pendingArgument = parsedArgument;
					} else {
						result.arguments ~= parsedArgument.get;
					}
					buffer = [];
				} else {
					throw new CommandLineException("invalid argument: " ~ cast(string)buffer);
				}
			} else {
				throw new CommandLineException("empty argument");
			}
		} else if (state == CommandLineState.argumentStr) {
			if (buffer.length > 0) {
				pendingArgument.get.str = cast(string)buffer;
				result.arguments ~= pendingArgument.get;
				buffer = [];
				pendingArgument = Nullable!CommandLineArgument.init;
				state = CommandLineState.waiting;
			} else {
				if (pendingArgument.get.requiresStr) {
					throw new CommandLineException("Argument " ~ pendingArgument.get.name ~ " expects a following string");
				}
			}
		}
	}
	if (result.command.length <= 0) {
		throw new CommandLineException("Must give a command");
	}
	return result;
}