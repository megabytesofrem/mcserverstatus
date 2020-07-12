#include <stdio.h>
#include "socket.h"

int main(/*int argc, char const *argv[]*/) {

  char *address = "2b2t.org";
  // char *resp = handshakeRequest(address, 25565);
  // printf("resp: %s\n", resp);

    // getting ipv4 ip from address
  struct addrinfo hints, *infoptr;
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_protocol   = IPPROTO_TCP;
  int result = getaddrinfo(address, NULL, &hints, &infoptr);
  if (result) {
      printf("getaddrinfo error: %s\n", gai_strerror(result));
      return NULL;
  }

  struct addrinfo *p;
  char host[256];

  for (p = infoptr; p != NULL; p = p->ai_next) {
    getnameinfo(p->ai_addr, p->ai_addrlen, host, sizeof(host), NULL, 0, NI_NUMERICHOST);

    char *resp = handshakeRequest(host, 25565);

    if (resp) {
      printf("host: %s, resp: %s\n", host, resp);
      break;
    }
    
  }

  freeaddrinfo(infoptr);
	return 0;
}