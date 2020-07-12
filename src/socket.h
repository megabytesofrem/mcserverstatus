#ifndef SOCKET_H
#define SOCKET_H

#include <stdio.h>
#include <string.h>
#include <unistd.h>

#ifdef _WIN32
	#include <winsock2.h>
	#include <Ws2tcpip.h>
#else
	#include <sys/socket.h>
	#include <arpa/inet.h>

  #include <stdio.h>
  #include <stdlib.h>
  #include <sys/types.h>
  // #include <sys/socket.h>
  #include <netdb.h>
#endif

#include "varint.h"
#include "packet.h"

char *handshakeRequest(char *address, unsigned short port);

#endif