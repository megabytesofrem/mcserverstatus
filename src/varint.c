#include "varint.h"

struct varIntResult readVarInt(unsigned char *input) {
    int numRead = 0;
    int result = 0;

    unsigned char read;

    do {
    	read = input[numRead];

    	int value = (read & 0b01111111);
        result |= (value << (7 * numRead));

        numRead++;
        if (numRead > 5) {
        	printf("index exceeds the max bytes for varint\n");
            exit(1);
        }
    } while ((read & 0b10000000) != 0);

    struct varIntResult varInt;
    varInt.result = result;
    varInt.endIndex = numRead - 1;

    return varInt;
}

char *writeVarInt(int value) {
	char *varInt = malloc(sizeof(char) * 5);
	int index = 0;

	while (value != 0) {
		unsigned char temp = (unsigned char)(value & 0b01111111);
        // Note: >>> means that the sign bit is shifted with the rest of the number rather than being left alone
        value = (unsigned int)value >> 7;
        if (value != 0) {
            temp |= 0b10000000;
        }
        varInt[index] = temp;
        index++;
	}

	return varInt;
}