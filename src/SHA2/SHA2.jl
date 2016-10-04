module SHA2

##############################################################################
##
## TODO
##
##############################################################################

# - Refactor RIPEMD-160 and SHA-256 to share boilerplate (E.g., read/write, padding)
# - Digest -> init, update, finalize

##############################################################################
##
## Refereces
##
##############################################################################

# - http://en.wikipedia.org/wiki/SHA-2

##############################################################################
##
## Exports
##
##############################################################################

export sha256

##############################################################################
##
## Notes
##
##############################################################################

# WARNING: This has only been tested on OS X 10.0.1 on a 64-bit machine.
#          The implementation below may die on a 32-bit machine.
# WARNING: This implementation assumes string inputs

# - All variables are 32-bit unsigned integers. From the Julia documentation 
#
#     http://docs.julialang.org/en/release-0.3/manual/integers-and-floating
#     -point-numbers/
#
#   we see that
#   
#   Unsigned integers are input and output using the 0x prefix and hexadecimal 
#   (base 16) digits 0-9a-f (the capitalized digits A-F also work for input). 
#   The size of the unsigned value is determined by the number of hex digits.
#
# - Addition is calculated modulo 2^32
#
# - For each round, there is one round constant k[i] and one entry in the 
#   message schedule array w[i], 0 ≤ i ≤ 63
#
# - The compression function uses 8 working variables, a through h
#
# - Big-endian convention is used when expressing the constants in this 
#   pseudocode, and when parsing message block data from bytes to chunks, 
#   for example, the first chunk of the input message "abc" after padding is 
#   0x61626380

##############################################################################
##
## Algorithm parameters
##
##############################################################################

const DIGEST_SIZE = 32 # SHA256 outputs a 32 byte (256 bit) digest
const BLOCK_SIZE = 64  # SHA256 operates on 64 (512 bit) blocks
const CHUNKS_PER_BLOCK = 16
const CHUNKS_PER_SCHEDULE = 64

##############################################################################
##
## Initialize array of round constants
##
##############################################################################

# First 32 bits of the fractional parts of the cube roots of the first 64 
# primes, 2 through 311. A sample generation function below:
#
# function initial_array_of_round_constraints(n)
#   fractional_cuberoot = cbrt(n) % 1
#   first_32_bits = floor(fractional_cube_root * 2^32)
#   @printf "%x" first_32_bits
#   return first_32_bits
# end

const k = [0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 
           0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 
           0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 
           0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
           0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 
           0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 
           0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b, 
           0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
           0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 
           0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 
           0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2]

##############################################################################
##
## Initialize helper functions
##
##############################################################################

# Hard-coding for 32-bit unsigned ints
# Technically, we could use the '>>' operator for right shift because
# we're only using unsigned ints, but we explicitly use logical right shift
ROTRIGHT(num, shift) = (num >>> shift) | (num << (32 - shift))
ROTLEFT(num, shift) = (num << shift) | (num >>> (32 - shift))

CH(x, y, z) = z $ (x & (y $ z))
MA(x, y, z) = ((x | y) & z) | (x & y)

E0(x) = (ROTRIGHT(x, 2) $ ROTRIGHT(x, 13) $ ROTRIGHT(x, 22))
E1(x) = (ROTRIGHT(x, 6) $ ROTRIGHT(x, 11) $ ROTRIGHT(x, 25))

S0(x) = (ROTRIGHT(x, 7) $ ROTRIGHT(x, 18) $ (x >>> 3))
S1(x) = (ROTRIGHT(x, 17) $ ROTRIGHT(x, 19) $ (x >>> 10))

##############################################################################
##
## Function definitions
##
##############################################################################

function transform!(state, block)

  # Pre-allocate the message schedule array (64 8-bit words)
  m = zeros(UInt32, CHUNKS_PER_SCHEDULE)

  for i = 1:CHUNKS_PER_BLOCK
    m[i] = uint32(block[4 * (i - 1) + 1]) << 24 +
           uint32(block[4 * (i - 1) + 2]) << 16 +
           uint32(block[4 * (i - 1) + 3]) << 8 +
           uint32(block[4 * (i - 1) + 4])
  end
  for i = CHUNKS_PER_BLOCK + 1:CHUNKS_PER_SCHEDULE
    s0 = S0(m[i-15])
    s1 = S1(m[i-2])

    m[i] = m[i-16] + s0 + m[i-7] + s1
  end

  a, b, c, d, e, f, g, h = state

  for i = 1:CHUNKS_PER_SCHEDULE
    t1 = h + E1(e) + CH(e, f, g) + k[i] + m[i]
    t2 = E0(a) + MA(a, b, c)

    h = g;
    g = f;
    f = e;
    e = uint32(d + t1)
    d = c;
    c = b;
    b = a;
    a = uint32(t1 + t2)
  end

  state[1] += a
  state[2] += b
  state[3] += c
  state[4] += d
  state[5] += e
  state[6] += f
  state[7] += g
  state[8] += h

  return
end

function sha256(msg::String; is_hex=false)

  if is_hex
    msg = [uint8(parseint(msg[2*i-1:2*i], 16)) for i in 1:length(msg)/2]
  else
    # We only want byte array literal (i.e., character array)
    msg = msg.data
  end

  # Get original length and bit lengths
  len = length(msg)
  bitlen = len * 8

  # Append the bit '1' to the message.
  append!(msg, [0x80])

  # First 32 bits of the fractional parts of the square roots of the first 8
  # primes, 2 through 19. A sample generation function below:
  #
  # function initial_hash_value(n)
  #   fractional_square_root = sqrt(n) % 1
  #   first_32_bits = floor(fractional_square_root * 2^32)
  #   @printf "%x" first_32_bits
  #   return first_32_bits
  # end

  state = [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
           0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19]

  # Divide up message into blocks of BLOCK_SIZE = 512 bits
  # and run through transformation
  while length(msg) >= BLOCK_SIZE
    transform!(state, msg[1:BLOCK_SIZE])
    msg = msg[BLOCK_SIZE + 1:end]
  end

  # Get the number of characters untransformed
  rem = length(msg)

  # If there are any characters remaining
  if rem > 0

    # Append k bits '0', where k is the minimum number >= 0 such that the 
    # resulting message length (modulo 512 in bits) is 448.
    if length(msg) > BLOCK_SIZE - 8
      msg = append!(msg, zeros(UInt8, BLOCK_SIZE - rem))
      transform!(state, msg)
      msg = zeros(UInt8, BLOCK_SIZE)
    else
      msg = append!(msg, zeros(UInt8, BLOCK_SIZE - rem))
    end

    # Append length of message (without the '1' bit or padding), in bits, as 
    # 64-bit big-endian integer (this will make the entire post-processed 
    # length a multiple of 512 bits)
    msg[57] = (bitlen >>> 56) & 0xff
    msg[58] = (bitlen >>> 48) & 0xff
    msg[59] = (bitlen >>> 40) & 0xff
    msg[60] = (bitlen >>> 32) & 0xff
    msg[61] = (bitlen >>> 24) & 0xff
    msg[62] = (bitlen >>> 16) & 0xff
    msg[63] = (bitlen >>> 8) & 0xff
    msg[64] = bitlen & 0xff

    # Process the last block
    transform!(state, msg)
  end

  # Assemble digest and return
  return reduce((x, y) -> string(x, y), map(x -> lpad(hex(uint32(x)), 8, "0"), state))
end

end # module SHA256
