function random(numbits)
  numbytes = fld(numbits, 8)
  if numbits % 8 != 0
    warning("The requested number of random bits is not divisible by 8. Rounding to the nearest multiple of 8.")
    numbytes += 1
  end

  ret = zeros(Uint8, numbytes)
  ccall((:RAND_bytes, "libcrypto"), Void, (Ptr{Uint8}, Int), ret, numbytes)

  return ret
end