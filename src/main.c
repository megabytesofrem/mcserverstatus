#include <stdio.h>
#include "socket.h"

int main(/*int argc, char const *argv[]*/) {

	char *resp = handshakeRequest("127.0.0.1", 25565);
	printf("resp: %s\n", resp);

	return 0;
}