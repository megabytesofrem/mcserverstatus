CC=gcc
FLAGS=-Wall -Wextra

ifdef __MINGW32__
	LIBS=-lws2_32
else
	LIBS=
endif

OUTPUT=mcserverstatus
DEPS = src/main.c src/packet.c src/socket.c src/varint.c

all:
	$(CC) $(FLAGS) -o $(OUTPUT) $(DEPS) $(LIBS)