const libcryptojl = joinpath(Pkg.dir(), "Crypto", "deps", "libcryptojl")

const COMPRESSED = 2
const UNCOMPRESSED = 4
# const POINT_CONVERSION_HYBRID = 6

const COMPRESSED_LENGTH = 33
const UNCOMPRESSED_LENGTH = 65

const NID_secp256k1 = 714

# curve_id: https://github.com/openssl/openssl/blob/master/crypto/objects/obj_mac.h
# form: POINT_CONVERSION_[UNCOMPRESSED|COMPRESSED]
function ec_public_key_create(secret_key; curve_id = NID_secp256k1, form = UNCOMPRESSED)
  public_key_length = form == UNCOMPRESSED ? UNCOMPRESSED_LENGTH : COMPRESSED_LENGTH
  public_key = zeros(Uint8, public_key_length)

  ccall((:ec_public_key_create, libcryptojl),                         # Function call
          Void,                                                       # Return type Void
          (Ptr{Uint8}, Ptr{Uint8}, Int, Int, Int),                    # Argument types
          secret_key, public_key, public_key_length, curve_id, form)  # Arguments

  return join([hex(x, 2) for x in public_key])
end