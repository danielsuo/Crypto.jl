Crypto.jl [Deprecated]
=========

[![Build Status](https://travis-ci.org/danielsuo/Crypto.jl.svg?branch=master)](https://travis-ci.org/danielsuo/Crypto.jl)
[![Coverage Status](https://coveralls.io/repos/danielsuo/Crypto.jl/badge.png)](https://coveralls.io/r/danielsuo/Crypto.jl)
[![Crypto](http://pkg.julialang.org/badges/Crypto_release.svg)](http://pkg.julialang.org/?pkg=Crypto&ver=release)

__Note that this package is deprecated and will not work with newer versions of Julia.__

A package that wraps OpenSSL (libcrypto), but also has pure Julia implementations for reference. Contributions welcome.

Check out @staticfloat's pure Julia [SHA](https://github.com/staticfloat/SHA.jl) package. We may simply require that package in this one rather than keep separate SHA implementations.

WARNING: This package experimental and is not ready for production use. The pure Julia implementations are not complete. Use at your own risk. 

# Prior to next release
- Update documentation to reflect new signatures and functions
- Clean up tests
- Fix RIPEMD160
- Swap input/output order for func params in c functions

# Usage
This package will likely be updated frequently and may break with previous versions. If you use the code, we recommend using
```julia
# Prevent Pkg.update from updating Crypto
Pkg.pin("Crypto")

# If used in a package's REQUIRE file
Crypto 0.0.1
```
when installing or requiring the package. Installing the package this way might be annoying, but will likely save trouble.

## Getting started
``` julia
using Crypto

# Add open OpenSSL algorithms to look-up table
# Required for using digests
Crypto.init()
```

## Creating digests
```julia
# Digests are available for MD2, MD5, SHA, SHA1, SHA224, SHA256, SHA384,
# SHA512, DSS, DSS1, MDC2, RIPEMD160
Crypto.digest("SHA256", "test")
# 9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08

# If provided string is hex
Crypto.digest("SHA256", "12eba", is_hex=true)
# 0c58bf613f25d049c7355f7e334866bd6ba8b13ab7c06fc79cf607a57116174b
```

## Using elliptic curve cryptography
So far, the package only generates public keys from private keys. We plan to add more functionality.
```julia
# Generate public key from private key
secret_key = "18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725"
Crypto.ec_public_key_create(secret_key)
# "0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6"

# Use curve secp256k1 (e.g., for Bitcoin) and generate uncompressed private key
# For more curves, see https://github.com/openssl/openssl/blob/master/crypto/objects/obj_mac.h
const NID_secp256k1 = 714
const COMPRESSED = 2
Crypto.ec_public_key_create(secret_key, curve_id = NID_secp256k1, form = COMPRESSED)
# 0250863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b2352
```

## Generating random numbers
```julia
# Returns array of 32 Uint8
Crypto.random(256)
```

# TODO
Detailed todos are noted in "TODO" sections found in the source code. Major todos:

- Review for cryptographic security (e.g., CSPRNG, memory cleanup)
- Add more Julia implementations
- Add more OpenSSL Libcrypto functions
- Implement ECDSA signing / authentication

# How to contribute
Let's figure that out together! Generally, testing and documentation are good. The TODOs list at the top of source files are one place to start. To help others review pull requests, please follow these guidelines:

- Add a summary of your changes to CHANGELOG.md in the 'Work in progress' section
- Make sure new code is tested and all tests pass

```julia
# Navigate to package directory
julia --code-coverage test/runtests.jl
```

Thank you for your help!

# Thanks
Shout out to @dirk, @amitmurthy, @j2kun, @wwilson, and @staticfloat for OpenSSL, Julia, and theory references.
