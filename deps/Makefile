shared: 
	gcc -Wno-deprecated-declarations -std=c99 -shared -fPIC -lcrypto digest.c ecdsa.c -o libcryptojl.$(LIBEXT)

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
