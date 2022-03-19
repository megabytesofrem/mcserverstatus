module varint;

import std.stdio;
import std.string;
import std.conv;

// https://wiki.vg/Data_types#VarInt_and_VarLong

struct VarInt {
    int value;
    ubyte[] data;

    this(int value) {
        this.value = value;

        ubyte[] varInt;
        int index = 0;
        do {
            ubyte temp = to!ubyte(value & 0b01111111);
            value >>>= 7;
            if (value != 0) {
                temp |= 0b10000000;
            }
            varInt ~= temp;
            index++;
        } while (value != 0);
        
        this.data = varInt;
    }

    this(ubyte[] data) {
        int numRead = 0;
        int result = 0;

        ubyte read;
        do {
            read = data[numRead];
            int value = (read & 0b01111111);
            result |= (value << (7 * numRead));

            numRead++;
            if (numRead > 5) {
                throw new StringException("VarInt is too big");
            }
        } while ((read & 0b10000000) != 0);

        this.value = result;
        this.data = data[0 .. numRead];
    }
}