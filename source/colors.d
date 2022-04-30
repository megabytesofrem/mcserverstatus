/**
    Minecraft color code to ANSI color code parser.
    Authors: Rem
*/

module colors;

// Color codes only supported when running on Linux/OSX
version (Posix)
{
    enum string[string] colorCodes = [
        "0": "\033[30m", // black
        "1": "\033[34m", // dark blue
        "2": "\033[32m", // dark green
        "3": "\033[36m", // dark aqua/cyan
        "4": "\033[31m", // dark red
        "5": "\033[35m", // dark purple
        "6": "\033[93m", // gold
        "7": "\033[90m", // gray
        "8": "\033[90m", // dark gray
        "9": "\033[34m", // blue
        "a": "\033[92m", // green
        "b": "\033[96m", // cyan
        "c": "\033[91m", // red
        "d": "\033[95m", // purple
        "e": "\033[33m", // yellow
        "f": "\033[97m", // white
    ];

    string colorize(string input) @safe pure {
        import std.algorithm : each, canFind;
        import std.array : replace;

        // Check if we have color codes starting with section or \u00A
        if (canFind(input, "§")) {
            colorCodes.byKeyValue.each!(it => input = input.replace("§" ~ it.key, it.value));
        }
        else if (canFind(input, "\\u00A")) {
            colorCodes.byKeyValue.each!(it => input = input.replace("\\u00A" ~ it.key, it.value));
        }

        // Tack on a reset character so we reset the color afterwards 
        return input ~ "\033[0m";
    }
}

version (Windows) 
{
    // Dummy implementation, without color codes because Windows
    // does not support ANSI color codes

    string colorize(string input) @safe {
        return input;
    }
}