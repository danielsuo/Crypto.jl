import Base.convert

function hex2oct(hex_string::String)
  hex_length = length(hex_string)

  # Left pad with 0 to make hex_string even length
  if hex_length % 2 != 0
    hex_string = string("0", hex_string)
    hex_length += 1
  end

  hex_length = div(hex_length, 2)

  #return [@compat(parse(@compat(UInt8), hex_string[2i-1:2i], 16)) for i in 1:hex_length]
  return [@compat(parse(@compat(UInt8), SubString(hex_string, 2i-1, 2i), 16)) for i in 1:hex_length]
end

function oct2hex(hex_array::Array{@compat(UInt8)})
  return join([hex(h, 2) for h in hex_array], "")
end
oct2hex(s::ByteString) = oct2hex(s.data)

# TODO: String manipulation is really not the best way
function int2oct(x::Integer)
  padding = 0
  if typeof(x) != BigInt
    padding = sizeof(x) * 2
    hex_string = hex(x, padding)
  else
    hex_string = hex(x)
  end
  return hex2oct(hex_string)
end

function oct2int(x::Array{@compat(UInt8)})
  result = BigInt(0)

  for i in 1:length(x)
    result <<= 8
    result += x[i]
  end

  if length(x) <= 1
    return @compat(UInt8(result))
  elseif length(x) <= 2
    return @compat(UInt16(result))
  elseif length(x) <= 4
    return @compat(UInt32(result))
  elseif length(x) <= 8
    return @compat(UInt64(result))
  elseif length(x) <= 16
    return @compat(UInt128(result))
  else
    return result
  end
end
