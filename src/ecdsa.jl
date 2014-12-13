const POINT_CONVERSION_COMPRESSED = 2
const POINT_CONVERSION_UNCOMPRESSED = 4
# const POINT_CONVERSION_HYBRID = 6
const COMPRESSED_LENGTH = 66
const UNCOMPRESSED_LENGTH = 130

# TODO: generalize to compress/uncompress
# TODO: add parameter for different curves
function priv2pub(priv)
  ret = zeros(Uint8, 130)
  ccall((:priv2pub, "deps/libcryptojl"), Void, (Ptr{Uint8}, Int, Ptr{Uint8}), priv, 4, ret)
  ret = join([char(x) for x in ret])
  return ret
end