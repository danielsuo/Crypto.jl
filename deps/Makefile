CC=gcc
CFLAGS=-Wl
LDFLAGS=
LINKLIBS=

shared: ecdsa.c
	$(CC) $(CFLAGS) -std=c99 -shared -fPIC -lcrypto ecdsa.c $(LDFLAGS) $(LINKLIBS) -o libecdsa.$(LIBEXT)

executable: ecdsa.c
	gcc -lcrypto -std=c99 ecdsa.c -o ecdsa

platform=$(shell uname)
ifeq ($(platform),Linux)
        LIBEXT=so
else ifeq ($(platform),Darwin)
        LIBEXT=dylib
else
        LIBEXT=dll
endif

clean:
	-rm libecdsa.$(LIBEXT)
