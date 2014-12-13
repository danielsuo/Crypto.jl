const POINT_CONVERSION_COMPRESSED = 2
const POINT_CONVERSION_UNCOMPRESSED = 4
# const POINT_CONVERSION_HYBRID = 6

const COMPRESSED_LENGTH = 66
const UNCOMPRESSED_LENGTH = 130

const NID_secp256k1 = 714

# form = POINT_CONVERSION_[UNCOMPRESSED|COMPRESSED]
function ec_public_key_create(secret_key; curve_id = NID_secp256k1, form = POINT_CONVERSION_UNCOMPRESSED)
  public_key_length = form == POINT_CONVERSION_UNCOMPRESSED ? UNCOMPRESSED_LENGTH : COMPRESSED_LENGTH
  public_key = zeros(Uint8, public_key_length)

  ccall((:ec_public_key_create, "deps/libcryptojl"),          # Function call
          Void,                                           # Return type Void
          (Ptr{Uint8}, Ptr{Uint8}, Int, Int, Int),        # Argument types
          secret_key, public_key, public_key_length, curve_id, form)  # Arguments

  public_key = join([char(x) for x in public_key])

  return public_key
end