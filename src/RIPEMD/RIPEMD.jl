module RIPEMD

##############################################################################
##
## TODO
##
##############################################################################

# - Fix bug for more than one chunk
# - Refactor RIPEMD-160 and SHA-256 to share boilerplate (E.g., read/write, padding)
# - Digest -> init, update, finalize

##############################################################################
##
## Refereces
##
##############################################################################

# - https://maemo.gitorious.org/maemo-pkg/python-crypto/source/8651b0eace17916fe7ba14923dbe4054f255ec2a:lib/Crypto/Hash/RIPEMD160.py
# - https://github.com/bitcoin/bitcoin/blob/master/src/crypto/ripemd160.cpp

##############################################################################
##
## Exports
##
##############################################################################

export ripemd160

##############################################################################
##
## Notes
##
##############################################################################

# WARNING: This module is in need of some clean up

# Pseudocode: http://homes.esat.kuleuven.be/~bosselae/ripemd/rmd160.txt
# Additional notes: https://en.bitcoin.it/wiki/RIPEMD-160
#
# RIPEMD-160 is an iterative hash function that operates on 32-bit words.
# The round function takes as input a 5-word chaining variable and a 16-word
# message block and maps this to a new chaining variable. All operations are
# defined on 32-bit words. Padding is identical to that of MD4.

##############################################################################
##
## Definitions
##
##############################################################################

const BLOCK_SIZE = 64  # SHA256 operates on 64 (512 bit) blocks
const WORDS_PER_BLOCK = 16

# Nonlinear functions at bit level: exor, mux, -, mux, -
const f = [(x, y, z) -> x $ y $ z,
           (x, y, z) -> (x & y) | (~x & z),
           (x, y, z) -> (x | ~y) $ z,
           (x, y, z) -> (x & z) | (y & ~z),
           (x, y, z) -> x $ (y | ~z)]

# Added constants (hexadecimal)
# NOTE: First 32 bits of the fractional parts of the square (K0)/cube (K1) 
# roots of the first 4 primes, 2 through 7. 
const K0 = [0x00000000, 0x5A827999, 0x6ED9EBA1, 0x8F1BBCDC, 0xA953FD4E]
const K1 = [0x50A28BE6, 0x5C4DD124, 0x6D703EF3, 0x7A6D76E9, 0x00000000]

# Selection of message word
# NOTE: Julia is 1-indexed
const r0 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
            8, 5, 14, 2, 11, 7, 16, 4, 13, 1, 10, 6, 3, 15, 12, 9,
            4, 11, 15, 5, 10, 16, 9, 2, 3, 8, 1, 7, 14, 12, 6, 13,
            2, 10, 12, 11, 1, 9, 13, 5, 14, 4, 8, 16, 15, 6, 7, 3,
            5, 1, 6, 10, 8, 13, 3, 11, 15, 2, 4, 9, 12, 7, 16, 14]
const r1 = [5, 15, 8, 1, 10, 3, 12, 5, 14, 7, 16, 9, 2, 11, 4, 13,
            7, 12, 4, 8, 1, 14, 6, 11, 15, 16, 9, 13, 5, 10, 2, 3,
            16, 6, 2, 4, 8, 15, 7, 10, 12, 9, 13, 3, 11, 1, 5, 14,
            9, 7, 5, 2, 4, 12, 16, 1, 6, 13, 3, 14, 10, 8, 11, 15,
            13, 16, 11, 5, 2, 6, 9, 8, 7, 3, 14, 15, 1, 4, 10, 12]

# Amount for rotate left (rol)
# NOTE: Julia is 1-indexed
const s0 = [11, 14, 15, 12, 5, 8, 7, 9, 11, 13, 14, 15, 6, 7, 9, 8,
            7, 6, 8, 13, 11, 9, 7, 15, 7, 12, 15, 9, 11, 7, 13, 12,
            11, 13, 6, 7, 14, 9, 13, 15, 14, 8, 13, 6, 5, 12, 7, 5,
            11, 12, 14, 15, 14, 15, 9, 8, 9, 14, 5, 6, 8, 6, 5, 12,
            9, 15, 5, 11, 6, 8, 13, 12, 5, 12, 13, 14, 11, 8, 5, 6]
const s1 = [8, 9, 9, 11, 13, 15, 15, 5, 7, 7, 8, 11, 14, 14, 12, 6,
            9, 13, 15, 7, 12, 8, 9, 11, 7, 7, 12, 7, 6, 15, 13, 11,
            9, 7, 15, 11, 8, 6, 6, 14, 12, 13, 5, 14, 13, 13, 7, 5,
            15, 5, 8, 11, 14, 14, 6, 14, 6, 9, 12, 9, 12, 5, 15, 8,
            8, 5, 12, 9, 12, 5, 14, 6, 8, 13, 6, 5, 15, 13, 11, 11]

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

##############################################################################
##
## Function definitions
##
##############################################################################

function transform!(state, block)
  A0, B0, C0, D0, E0 = state
  A1, B1, C1, D1, E1 = state

  X = zeros(Uint32, WORDS_PER_BLOCK)

  for i = 1:WORDS_PER_BLOCK
    X[i] = uint32(block[4 * (i - 1) + 4]) << 24 +
           uint32(block[4 * (i - 1) + 3]) << 16 +
           uint32(block[4 * (i - 1) + 2]) << 8 +
           uint32(block[4 * (i - 1) + 1])
  end

  for j = 1:80
    # TODO: Replace with cld(j, 16) in Julia v0.4
    div, rem = divrem(j, 16)
    i = div + (rem == 0 ? 0 : 1)
    k = 5 - i + 1

    T = uint32(A0 + f[i](B0, C0, D0) + X[r0[j]] + K0[i])
    T = uint32(ROTLEFT(T, s0[j]) + E0)

    A0 = E0
    E0 = D0
    D0 = ROTLEFT(C0, 10)
    C0 = B0
    B0 = T

    T = uint32(A1 + f[k](B1, C1, D1) + X[r1[j]] + K1[i])
    T = uint32(ROTLEFT(T, s1[j]) + E1)

    A1 = E1
    E1 = D1
    D1 = ROTLEFT(C1, 10)
    C1 = B1
    B1 = T
  end

  T = uint32(state[2] + C0 + D1)
  state[2] = uint32(state[3] + D0 + E1)
  state[3] = uint32(state[4] + E0 + A1)
  state[4] = uint32(state[5] + A0 + B1)
  state[5] = uint32(state[1] + B0 + C1)
  state[1] = uint32(T)

  return
end

function ripemd160(msg::ASCIIString; is_hex=false)

  if is_hex
    len = int(length(msg) / 2)
    result = zeros(Uint8, len)
    for i = 1:len
      result[i] = uint8(parseint(msg[2 * i - 1: 2 * i],16))
    end
    msg = result
  else
    # We only want byte array literal (i.e., character array)
    msg = msg.data
  end

  # Get original length and bit lengths
  len = length(msg)
  bitlen = len * 8

  # Append the bit '1' to the message.
  append!(msg, [0x80])

  state = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0]

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
      msg = append!(msg, zeros(Uint8, BLOCK_SIZE - rem))
      transform!(state, msg)
      msg = zeros(Uint8, BLOCK_SIZE)
    else
      msg = append!(msg, zeros(Uint8, BLOCK_SIZE - rem))
    end

    # Append length of message (without the '1' bit or padding), in bits, as 
    # 64-bit big-endian integer (this will make the entire post-processed 
    # length a multiple of 512 bits)
    msg[64] = (bitlen >>> 56) & 0xff
    msg[63] = (bitlen >>> 48) & 0xff
    msg[62] = (bitlen >>> 40) & 0xff
    msg[61] = (bitlen >>> 32) & 0xff
    msg[60] = (bitlen >>> 24) & 0xff
    msg[59] = (bitlen >>> 16) & 0xff
    msg[58] = (bitlen >>> 8) & 0xff
    msg[57] = bitlen & 0xff

    # Process the last block
    transform!(state, msg)
  end

  # Assemble digest and return
  return reduce((x, y) -> string(x, y), map(x -> lpad(hex(ntoh(uint32(x))), 8, "0"), state))
end

end # module RIPEMD
