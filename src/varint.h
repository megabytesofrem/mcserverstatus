#ifndef VARINT_H
#define VARINT_H

#include <stdio.h>
#include <stdlib.h>

struct varIntResult {
	int result;
	size_t endIndex;
};

char *writeVarInt(int value);
struct varIntResult readVarInt(unsigned char *input);

#endif