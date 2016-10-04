##############################################################################
##
## TODO
##
##############################################################################

# - Convert to c function. Hard to read so many ccall's.

function init()
  ccall((:OpenSSL_add_all_digests, "libcrypto"), Void, ())
end

function cleanup()
  ccall((:EVP_cleanup, "libcrypto"), Void, ())
end

function digest(name::AbstractString, data::AbstractString; is_hex=false)
  if is_hex
    L = round(Int,length(data)/2)
    data = [@compat(parse(@compat(UInt8),SubString(data,2*i-1,2*i), 16)) for i in 1:L]
  else
    data = data.data
  end
  digest(name, data)
end

function digest(name::AbstractString, data::Array{@compat(UInt8)})
  ctx = ccall((:EVP_MD_CTX_create, "libcrypto"), Ptr{Void}, ())
  try
    # Get the message digest struct
    md = ccall((:EVP_get_digestbyname, "libcrypto"), Ptr{Void}, (Ptr{UInt8},), string(name))
    if(md == C_NULL)
      error("Unknown message digest $name")
    end

    # Add the digest struct to the context
    ccall((:EVP_DigestInit_ex, "libcrypto"), Void, (Ptr{Void}, Ptr{Void}, Ptr{Void}), ctx, md, C_NULL)

    # Update the context with the input data
    ccall((:EVP_DigestUpdate, "libcrypto"), Void, (Ptr{Void}, Ptr{UInt8}, UInt), ctx, data, length(data))

    # Figure out the size of the output string for the digest
    size = ccall((:EVP_MD_size, "libcrypto"), UInt, (Ptr{Void},), md)
    uval = Array(UInt8, size)

    # Calculate the digest and store it in the uval array
    ccall((:EVP_DigestFinal_ex, "libcrypto"), Void, (Ptr{Void}, Ptr{UInt8}, Ptr{UInt}), ctx, uval, C_NULL)

    return uval
  finally
    ccall((:EVP_MD_CTX_destroy, "libcrypto"), Void, (Ptr{Void},), ctx)
  end
end

digest(name::AbstractString, data::IOBuffer) = digest(name, takebuf_array(data))
