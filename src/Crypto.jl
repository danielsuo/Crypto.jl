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

@c Void RAND_poll () "libcrypto"
# RAND_poll()
@c Int RAND_load_file (ASCIIString, Int) "libcrypto"
# RAND_load_file("/dev/random", 32)
@c Void RAND_bytes (Ptr{Uint8}, Int) "libcrypto"
# a = zeros(Uint8, 10)
# RAND_bytes(a, 10)
@c Void RAND_cleanup () "libcrypto"

end