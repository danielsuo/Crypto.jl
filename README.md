Crypto.jl
=========

[![Build Status](https://travis-ci.org/danielsuo/Crypto.jl.svg?branch=master)](https://travis-ci.org/danielsuo/Crypto.jl)
[![Coverage Status](https://coveralls.io/repos/danielsuo/Crypto.jl/badge.png)](https://coveralls.io/r/danielsuo/Crypto.jl)

A library that wraps OpenSSL (libcrypto), but also has pure Julia implementations for reference (not recommended)

WARNING:

- Make cryptographically secure
- Continue to add Julia implementations
- Add more functionality from libcrypto
- if you use, please lock version
- Switch default to is_hex=false

For more ECDSA curves, see [here](http://git.openssl.org/gitweb/?p=openssl.git;a=blob;f=crypto/objects/obj_mac.h)

# Docs
- Run init()

# To do
- Reflect Julia standard packages e.g., only one module / package
- Init, update, finalize
- Get build process working for deps
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
- Add versioning / tags
- Package
- Publish to Julia package repo
