module ECDSA

using Crypto.Integers
using Crypto.EllipticCurves
using Crypto.FiniteFields
using Crypto.Polynomials

# F = FiniteField{3851, 1}
# a = F(324)
# b = F(1287)

# curve = Curve(F(324), F(1287))

a = makeModular(324, 3851)
b = makeModular(1287, 3851)
insecureCurve = Curve(a, b)
x = makeModular(920, 3851)
y = makeModular(303, 3851)
basePoint = ConcretePoint(x, y, insecureCurve)

# http://jeremykun.com/2014/04/14/sending-and-authenticating-messages-with-elliptic-curves/

# macro c(ret_type, func, arg_types, lib)
#   local args_in = Any[ symbol(string('a',x)) for x in 1:length(arg_types.args) ]

#   quote
#     $(esc(func))($(args_in...)) = ccall( ($(string(func)), $(Expr(:quote, lib)) ), $ret_type, $arg_types, $(args_in...) )
#   end
# end

# function sendDH(privateKey, generator, sendFunction)
#   return sendFunction(privateKey * generator)
# end

# function receiveDH(privateKey, receiveFunction)
#   return privateKey * receiveFunction()
# end

# function generate(numBits)
#   numBytes = fld(numBits, 8)
#   # @c Cint RAND_bytes (Ptr{Cuchar}, Cint) libcrypto
#   key = zeros(Cuchar, numBytes)
#   # RAND_bytes(key, numBytes)
#   key = reduce((x, y) -> BigInt(x) << 8 + BigInt(y), key)
#   return key
# end

# function sign(message, basePoint, basePointOrder, secretKey)
#   modR = FiniteField(basePointOrder, 1)
#   oneTimeSecret = generate(length(bin(basePointOrder)) - 1)
#   auxiliaryPoint = oneTimeSecret * basePoint
#   signature = inverse(modR(oneTimeSecret)) *
#          (modR(message) + modR(secretKey) * modR(auxiliaryPoint.x))
#   return (message, auxiliaryPoint, signature)
# end

# function authenticate(signedMessage, basePoint, basePointOrder, publicKey)
#   modR = FiniteField(basePointOrder, 1)
#   (message, auxiliary, signature) = signedMessage

#   sigInverse = inverse(modR(signature)) # sig can be an int or a modR already
#   c, d = sigInverse * modR(message), sigInverse * modR(auxiliary.x)

#   auxiliaryChecker = int(c) * basePoint + int(d) * publicKey
#   return auxiliaryChecker == auxiliary
# end
 
# # y^2 = x^3 + 3x + 181
# a = makeModular(3, 1061)
# b = makeModular(181, 1061)
# curve = Curve(a, b)
# x = makeModular(2, 1061)
# y = makeModular(81, 1061)
# basePoint = ConcretePoint(x, y, curve)
# basePointOrder = 349
# secretKey = generate(8)
# publicKey = secretKey * basePoint

# message = 123
# # signedMessage = sign(message, basePoint, basePointOrder, secretKey)

# modR = FiniteField(basePointOrder, 1)
#   # oneTimeSecret = generate(length(bin(basePointOrder)) - 1)
#   # auxiliaryPoint = oneTimeSecret * basePoint
#   # signature = inverse(modR(oneTimeSecret)) *
#          # (modR(message) + modR(secretKey) * modR(auxiliaryPoint.x))

# # aliceSecretKey = generateKey(8)
# # bobSecretKey = generateKey(8)

# # alicePublicKey = aliceSecretKey * basePoint
# # bobPublicKey = bobSecretKey * basePoint

# # sharedSecret1 = bobSecretKey * alicePublicKey
# # sharedSecret2 = aliceSecretKey * bobPublicKey

end # module ECDSA