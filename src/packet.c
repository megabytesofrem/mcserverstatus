#include "packet.h"

struct packet writeHandshakePacket(char *address, unsigned short port) {

	size_t handshakeSize = 0;

	// version -1
	char *versionNumber = (char *)writeVarInt(-1);
	size_t versionNumberSize = strlen(versionNumber);
	handshakeSize += versionNumberSize;

	// serverAddress = (varInt)serverAddressLen + serverAddress
	char *serverAddressLenVarInt = (char *)writeVarInt(strlen(address));
	size_t serverAddressLenVarIntSize = strlen(serverAddressLenVarInt);
	size_t addressSize = strlen(address);
	size_t serverAddressSize = serverAddressLenVarIntSize + addressSize;

	unsigned char *serverAddress = malloc(sizeof(unsigned char) * (serverAddressLenVarIntSize + addressSize));
	memcpy(serverAddress, serverAddressLenVarInt, serverAddressLenVarIntSize);
	memcpy(serverAddress + serverAddressLenVarIntSize, address, addressSize);

	handshakeSize += serverAddressSize;

	// converting unsigned short to little endian bytes
	size_t portBytesSize = sizeof(port);
	unsigned char *portBytes = malloc(portBytesSize);
	portBytes[0] = (port >> 8) & 0xff;
	portBytes[1] = port & 0xff;

	handshakeSize += portBytesSize;

	// next state if 0x01 (requesting status)
	unsigned char nextState = 0x01;
	size_t nextStateSize = sizeof(nextState);
	handshakeSize += nextStateSize;

	// +1 for the 0x00 beginning byte
	// handshakeSize += sizeof(unsigned char);

	// the length of the packet should be prefixed in var int form
	char *prefixLenVarInt = writeVarInt(handshakeSize + 1);
	size_t prefixLenVarIntSize = strlen(prefixLenVarInt) + sizeof(unsigned char);
	prefixLenVarInt = realloc(prefixLenVarInt, prefixLenVarIntSize);
	prefixLenVarInt[prefixLenVarIntSize - 1] = '\0';
	handshakeSize += prefixLenVarIntSize;

	// crafting the handshake packet
	unsigned char *handshake = malloc(sizeof(unsigned char) * handshakeSize);
	int handshakeIndex = 0;
	memcpy(handshake, prefixLenVarInt, prefixLenVarIntSize);
	handshakeIndex += prefixLenVarIntSize;
	memcpy(handshake + handshakeIndex, versionNumber, versionNumberSize);
	handshakeIndex += versionNumberSize;
	memcpy(handshake + handshakeIndex, serverAddress, serverAddressSize);
	handshakeIndex += serverAddressSize;
	memcpy(handshake + handshakeIndex, portBytes, portBytesSize);
	handshakeIndex += portBytesSize;
	memcpy(handshake + handshakeIndex, &nextState, nextStateSize);
	handshakeIndex += handshakeSize;

	// debug: print packet in hex form
	#ifdef DEBUG
	for (int i = 0; i < handshakeSize; i++) {
		printf("\\x%02X", handshake[i]);
	}
	printf("\n");
	#endif

	struct packet handshakePacket;
	handshakePacket.content = handshake;
	handshakePacket.size = handshakeSize;

	return handshakePacket;

}