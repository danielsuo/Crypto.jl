Crypto.jl
=========

[![Build Status](https://travis-ci.org/danielsuo/Crypto.jl.svg?branch=master)](https://travis-ci.org/danielsuo/Crypto.jl)
[![Coverage Status](https://coveralls.io/repos/danielsuo/Crypto.jl/badge.png)](https://coveralls.io/r/danielsuo/Crypto.jl)

A library that wraps OpenSSL (libcrypto), but also has pure Julia implementations for reference (not recommended)

# To do
- Implement ECDSA signing / authentication
- Add libssl and libcrypto bindings
- Test and examples
  - libssl and libcrypto
  - EDCSA
- Documentation
- Clean up code
  - Methods e.g., promote, convert, macro +, -, *, /
  - Fix RIPEMD
- Update README
  - Purpose
  - Audience
  - Use cases
  - Contributing (PR, issues, suggestions, questions, )
  - Contact
  - Thanks / Credit
- Dependencies (libcrypto)?
- Update tagline text
- Add versioning
- Package
- Publish to Julia package repo

# Status
- ~~RIPEMD-160 [ref](https://github.com/bitcoin/bitcoin/blob/master/src/crypto/ripemd160.cpp)~~
  - Clean up [ref](https://maemo.gitorious.org/maemo-pkg/python-crypto/source/8651b0eace17916fe7ba14923dbe4054f255ec2a:lib/Crypto/Hash/RIPEMD160.py)
  - Fix bug for more than one chunk
- Elliptic Curve DSA
  - [ref](https://github.com/bitcoin/secp256k1/blob/master/src/secp256k1.c)
  - [ref](http://www.ijcaonline.org/allpdf/pxc387876.pdf)
  - [ref](http://jeremykun.com/2014/02/08/introducing-elliptic-curves/)
  - [ref](https://gist.github.com/anonymous/a3799a5a2b0354022eac)
  - [ref](https://github.com/wwilson/Catacomb.jl)
  - Add tests
  - Implement secp256k1
- ~~Wallet Interchange Format [ref](https://en.bitcoin.it/wiki/WIF)~~
- ~~Base58 encoding / decoding [ref](https://github.com/bitcoin/bitcoin/blob/master/src/base58.cpp)~~
- ~~SHA-256 [ref](http://en.wikipedia.org/wiki/SHA-2)~~
- Refactor RIPEMD-160 and SHA-256 to share boilerplate
  - Read/write is the same
  - Padding is the same
  - Transform, constants, functions are different
- BIP 32 HD Wallets [ref](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)