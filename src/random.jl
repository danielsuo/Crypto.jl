function random(numbits)
  numbytes = fld(numbits, 8)
  if numbits % 8 != 0
    warn("The requested number of random bits is not divisible by 8. Rounding to the nearest multiple of 8.")
    numbytes += 1
  end

  ret = zeros(UInt8, numbytes)
  ccall((:RAND_bytes, "libcrypto"), Void, (Ptr{UInt8}, Int), ret, numbytes)

  return ret
end
