const POINT_CONVERSION_COMPRESSED = 2
const POINT_CONVERSION_UNCOMPRESSED = 4
# const POINT_CONVERSION_HYBRID = 6

const COMPRESSED_LENGTH = 66
const UNCOMPRESSED_LENGTH = 130

const NID_secp256k1 = 714

# form = POINT_CONVERSION_[UNCOMPRESSED|COMPRESSED]
function ec_pubkey_create(seckey; curve_id = NID_secp256k1, form = POINT_CONVERSION_UNCOMPRESSED)
  pubkey_length = form == POINT_CONVERSION_UNCOMPRESSED ? UNCOMPRESSED_LENGTH : COMPRESSED_LENGTH
  pubkey = zeros(Uint8, pubkey_length)

  ccall((:ec_pubkey_create, "deps/libcryptojl"),          # Function call
          Void,                                           # Return type Void
          (Ptr{Uint8}, Ptr{Uint8}, Int, Int, Int),        # Argument types
          seckey, pubkey, pubkey_length, curve_id, form)  # Arguments

  pubkey = join([char(x) for x in pubkey])

  return pubkey
end