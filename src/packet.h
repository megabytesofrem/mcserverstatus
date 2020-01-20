#ifndef PACKET_H
#define PACKET_H

#include <stdio.h>
#include <string.h>
#include "varint.h"

struct packet {
	unsigned char *content;
	size_t size;
};

struct packet writeHandshakePacket(char *address, unsigned short port);

#endif