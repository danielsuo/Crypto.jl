module Crypto

##############################################################################
##
## Load files
##
##############################################################################

include("Util/c.jl")
include("Util/Key.jl")

include("Theory/Integers.jl")
include("Theory/Polynomials.jl")
include("Theory/FiniteFields.jl")
include("Theory/EllipticCurves.jl")

include("SHA2/SHA2.jl")
include("RIPEMD/RIPEMD.jl")
include("ECDSA/ECDSA.jl")

end