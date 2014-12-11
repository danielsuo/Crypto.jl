module Crypto

##############################################################################
##
## Load files
##
##############################################################################

include("Util/c.jl")
include("Util/Key.jl")

include("Theory/Integers.jl")
include("Theory/Polynomials.jl")
include("Theory/FiniteFields.jl")
include("Theory/EllipticCurves.jl")

include("SHA2/SHA2.jl")
include("RIPEMD/RIPEMD.jl")
include("ECDSA/ECDSA.jl")

function init()
  ccall((:OpenSSL_add_all_digests, "libcrypto"), Void, ())
end
function cleanup()
  ccall((:EVP_cleanup, "libcrypto"), Void, ())
end

function hexstring(hexes::Array{Uint8,1})
  join([hex(h,2) for h in hexes], "")
end

function digest(name::String, data::String)
  ctx = ccall((:EVP_MD_CTX_create, "libcrypto"), Ptr{Void}, ())
  try
    # Get the message digest struct
    md = ccall((:EVP_get_digestbyname, "libcrypto"), Ptr{Void}, (Ptr{Uint8},), bytestring(name))
    if(md == C_NULL)
      error("Unknown message digest $name")
    end
    # Add the digest struct to the context
    ccall((:EVP_DigestInit_ex, "libcrypto"), Void, (Ptr{Void}, Ptr{Void}, Ptr{Void}), ctx, md, C_NULL)
    # Update the context with the input data
    bs = bytestring(data)
    ccall((:EVP_DigestUpdate, "libcrypto"), Void, (Ptr{Void}, Ptr{Uint8}, Uint), ctx, bs, length(bs))
    # Figure out the size of the output string for the digest
    size = ccall((:EVP_MD_size, "libcrypto"), Uint, (Ptr{Void},), md)
    uval = Array(Uint8, size)
    # Calculate the digest and store it in the uval array
    ccall((:EVP_DigestFinal_ex, "libcrypto"), Void, (Ptr{Void}, Ptr{Uint8}, Ptr{Uint}), ctx, uval, C_NULL)
    # bytestring(uval)
    # Convert the uval array to a string of hexes
    return hexstring(uval)
  finally
    ccall((:EVP_MD_CTX_destroy, "libcrypto"), Void, (Ptr{Void},), ctx)
  end
end

function digestinit(name::String)
  ctx = ccall((:EVP_MD_CTX_create, "libcrypto"), Ptr{Void}, ())
  try
    # Get the message digest struct
    md = ccall((:EVP_get_digestbyname, "libcrypto"), Ptr{Void}, (Ptr{Uint8},), bytestring(name))
    if(md == C_NULL)
      error("Unknown message digest $name")
    end
    # Add the digest struct to the context
    ccall((:EVP_DigestInit_ex, "libcrypto"), Void, (Ptr{Void}, Ptr{Void}, Ptr{Void}), ctx, md, C_NULL)
    # Update the context with the input data
    ctx
  catch
    ccall((:EVP_MD_CTX_destroy, "libcrypto"), Void, (Ptr{Void},), ctx)
    nothing
  end
end

function digestupdate(ctx,data::String)
  try
    # Update the context with the input data
    bs = bytestring(data)
    ccall((:EVP_DigestUpdate, "libcrypto"), Void, (Ptr{Void}, Ptr{Uint8}, Uint), ctx, bs, length(bs))
    ctx
  catch
    ccall((:EVP_MD_CTX_destroy, "libcrypto"), Void, (Ptr{Void},), ctx)
    nothing
  end
end

function digestfinalize(ctx)
  try
    # Get the message digest struct
    md = ccall((:EVP_MD_CTX_md, "libcrypto"), Ptr{Void}, (Ptr{Uint8},), ctx)
    if(md == C_NULL)
      error("Unknown message digest $name")
    end
    size = ccall((:EVP_MD_size, "libcrypto"), Uint, (Ptr{Void},), md)
    uval = Array(Uint8, size)
    # Calculate the digest and store it in the uval array
    ccall((:EVP_DigestFinal_ex, "libcrypto"), Void, (Ptr{Void}, Ptr{Uint8}, Ptr{Uint}), ctx, uval, C_NULL)
    # bytestring(uval)
    # Convert the uval array to a string of hexes
    return hexstring(uval)
  finally
    ccall((:EVP_MD_CTX_destroy, "libcrypto"), Void, (Ptr{Void},), ctx)
  end
end

macro c(ret_type, func, arg_types, lib)
  local args_in = Any[ symbol(string('a',x)) for x in 1:length(arg_types.args) ]

  quote
    $(esc(func))($(args_in...)) = ccall( ($(string(func)), $(Expr(:quote, lib)) ), $ret_type, $arg_types, $(args_in...) )
  end
end

@c Void RAND_poll () libcrypto
# RAND_poll()
@c Int RAND_load_file (ASCIIString, Int) libcrypto
# RAND_load_file("/dev/random", 32)
@c Void RAND_bytes (Ptr{Uint8}, Int) libcrypto
# a = zeros(Uint8, 10)
# RAND_bytes(a, 10)
@c Void RAND_cleanup () libcrypto

# @c Void gcry_randomize (Ptr{Uint8}, Int, Int) "libgcrypt"

const NID_secp256k1 = 714
typealias BIGNUM Void
typealias BN_CTX Void
typealias EC_POINT Void
typealias EC_GROUP Void

@c Ptr{EC_GROUP} EC_GROUP_new_by_curve_name (Int,) libcrypto
ecgrp = EC_GROUP_new_by_curve_name(NID_secp256k1)

@c Ptr{BIGNUM} BN_new () libcrypto
priv_bn = BN_new()

@c Ptr{BN_CTX} BN_CTX_new () libcrypto

@c Ptr{EC_POINT} EC_POINT_new (Ptr{EC_GROUP},) libcrypto
pub = EC_POINT_new(ecgrp)

@c Int EC_POINT_mul (Ptr{EC_GROUP}, Ptr{EC_POINT}, Ptr{BIGNUM}, Ptr{EC_POINT}, Ptr{BIGNUM}, Ptr{BN_CTX}) libcrypto
# EC_POINT_mul(ecgrp, pub, priv_bn, Nothing, Nothing, Nothing)

@c Ptr{Uint8} EC_POINT_point2hex (Ptr{EC_GROUP}, Ptr{EC_POINT}, Int, Ptr{BN_CTX}) libcrypto
EC_POINT_point2hex(ecgrp, pub, 4, BN_CTX_new())

# @c Ptr{EVP_PKEY} EVP_PKEY_new () libcrypto
# a = Array(Uint8, 32)
# a = EVP_PKEY_new()

@c Ptr{Uint8} priv2pub (ASCIIString, Int) libecdsa

const libecdsa = joinpath(Pkg.dir(), "Crypto", "deps", "libecdsa.dylib")

const POINT_CONVERSION_COMPRESSED = 2
const POINT_CONVERSION_UNCOMPRESSED = 4
# const POINT_CONVERSION_HYBRID = 6
const COMPRESSED_LENGTH = 66
const UNCOMPRESSED_LENGTH = 130


a = zeros(Uint8, 130)
ccall((:priv2pub, libecdsa), Void, (Ptr{Uint8}, Int, Ptr{Uint8}), "18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725", 4, a)
a = hex(parseint(BigInt, join([char(x) for x in a]), 16))

hash = ""
for i in 1:length(a)/2
  hash = string(hash, char(parseint(a[2 * i - 1: 2 * i], 16)))
end
end