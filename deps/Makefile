shared: 
	gcc -Wno-deprecated-declarations -std=c99 -shared -fPIC digest.c ecdsa.c -o libcryptojl.$(LIBEXT) -lcrypto

platform=$(shell uname)
ifeq ($(platform),Linux)
        LIBEXT=so
else ifeq ($(platform),Darwin)
        LIBEXT=dylib
else
        LIBEXT=dll
endif

clean:
	-rm libcryptojl.$(LIBEXT)
