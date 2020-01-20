#include "socket.h"

char *handshakeRequest(char *address, unsigned short port) {
    int sock = 0;

    struct sockaddr_in serverAddress;
    char *buffer = malloc(sizeof(char) * 10240);
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("socket creation error\n");
        return NULL;
    }
   
    serverAddress.sin_family = AF_INET;
    serverAddress.sin_port = htons(port);
       
    // Convert IPv4 and IPv6 addresses from text to binary form
    if (inet_pton(AF_INET, address, &serverAddress.sin_addr) <= 0) {
        printf("address not supported\n");
        return NULL;
    }
   
    if (connect(sock, (struct sockaddr *)&serverAddress, sizeof((serverAddress))) < 0) {
        printf("socket connection failed\n");
        return NULL;
    }

    struct packet handshakePacket = writeHandshakePacket(address, port);
    if (handshakePacket.content == NULL) {
        printf("handshake packet creation failed\n");
        return NULL;
    }

    send(sock, handshakePacket.content, handshakePacket.size, 0);

    unsigned char *followUp = malloc(sizeof(unsigned char) * 2);
    followUp[0] = 0x01;
    followUp[1] = 0x00;
    send(sock, followUp, 2, 0);

    /*int readStatus =*/read(sock, buffer, 10240);

    struct varIntResult strSize = readVarInt((unsigned char *)buffer);
    char *jsonServerData = malloc(sizeof(char) * strSize.result);
    memcpy(jsonServerData, buffer + 5, strSize.result);

    return jsonServerData;
}