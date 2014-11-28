module Key

  using Crypto

  export generate

  function generate(numBits)
    numBytes = fld(numBits, 8)
    # @c Cint RAND_bytes (Ptr{Cuchar}, Cint) libcrypto
    key = zeros(Cuchar, numBytes)
    RAND_bytes(key, numBytes)
    return key
  end

end