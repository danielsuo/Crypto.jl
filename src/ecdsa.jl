const COMPRESSED = 2
const UNCOMPRESSED = 4
# const POINT_CONVERSION_HYBRID = 6

const COMPRESSED_LENGTH = 33
const UNCOMPRESSED_LENGTH = 65

# TODO: Assume maximum signature size is 144 bytes (way overkill)
const SIGNATURE_SIZE = 144

const NID_secp256k1 = 714

# curve_id: https://github.com/openssl/openssl/blob/master/crypto/objects/obj_mac.h
# form: POINT_CONVERSION_[UNCOMPRESSED|COMPRESSED]
function ec_pub_key(priv_key::Array{Uint8}; curve_id = NID_secp256k1, form = UNCOMPRESSED)
  pub_key_length = form == UNCOMPRESSED ? UNCOMPRESSED_LENGTH : COMPRESSED_LENGTH
  pub_key = zeros(Uint8, pub_key_length)

  ccall((:ec_pub_key, libcryptojl),                               # Function call
          Void,                                                   # Return type Void
          (Ptr{Uint8}, Ptr{Uint8}, Int, Int, Int),                # Argument types
          pub_key, priv_key, length(priv_key), curve_id, form)     # Arguments

  return pub_key
end

# priv_key as hex string
function ec_pub_key(priv_key::String; curve_id = NID_secp256k1, form = UNCOMPRESSED)
  ec_pub_key(hex_string_to_array(priv_key), curve_id = curve_id, form = form)
end

# https://www.openssl.org/docs/crypto/ecdsa.html
function ec_sign(hash, priv_key; curve_id = NID_secp256k1)
  sig = zeros(Uint8, SIGNATURE_SIZE)
  siglen = ccall((:ec_sign, libcryptojl),
                  Uint,
                  (Ptr{Uint8}, Ptr{Uint8}, Int, Ptr{Uint8}, Int, Int),
                  sig, hash, length(hash), priv_key, length(priv_key), curve_id)
  return sig[1:siglen]
end

function ec_verify(hash, sig, pub_key; curve_id = NID_secp256k1)
  return true == ccall((:ec_verify, libcryptojl),
                        Int,
                        (Ptr{Uint8}, Int, Ptr{Uint8}, Int, Ptr{Uint8}, Int, Int),
                        hash, length(hash), sig, length(sig), pub_key, length(pub_key), curve_id)
end
