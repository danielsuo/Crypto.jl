module Integers

export IntegerMod, makeModular

##############################################################################
##
## Modular arithmetic (IntegerMod)
##
##############################################################################

import Base.show, 
       Base.length, 
       Base.convert, 
       Base.divrem, 
       Base.promote_rule, 
       Base.promote, 
       Base.abs,
       Base.div,
       Base.rem,
       Base.zero,
       Base.zeros

type IntegerMod{P} <: Number
    n::Integer
    p::Integer

    function IntegerMod(N::Integer)
        new(mod(N,P), P)
    end
end

function makeModular(n::Integer, p::Integer)
    return IntegerMod{p}(n)
end

convert{P}(::Type{IntegerMod{P}}, n::Integer) = IntegerMod{P}(n)
convert{P}(::Type{IntegerMod{P}}, a::Array) = [IntegerMod{P}(n) for n in a]

promote_rule{P}(::Type{IntegerMod{P}}, ::Type{Integer}) = IntegerMod{P}

function show{P}(io::IO, a::IntegerMod{P})
    print(io, string(a.n, " (mod ", P, ")"))
end

function =={P}(a::IntegerMod{P}, b::IntegerMod{P})
  return a.n == b.n
end

function =={P}(a::IntegerMod{P}, b::Integer)
  return a.n == mod(b, P)
end

function =={P}(a::Integer, b::IntegerMod{P})
  return mod(a, P) == b.n
end

function +{P}(a::IntegerMod{P}, b::IntegerMod{P})
  return IntegerMod{P}(a.n + b.n)
end

function +{P}(a::IntegerMod{P}, b::Integer)
  return IntegerMod{P}(a.n + b)
end

function +{P}(a::Integer, b::IntegerMod{P})
  return IntegerMod{P}(a + b.n)
end

function -{P}(a::IntegerMod{P})
  return IntegerMod{P}(-a.n)
end

function -{P}(a::IntegerMod{P}, b::IntegerMod{P})
  return IntegerMod{P}(a.n - b.n)
end

function -{P}(a::IntegerMod{P}, b::Integer)
  return IntegerMod{P}(a.n - b)
end

function -{P}(a::IntegerMod{P}, b::IntegerMod{P})
  return return IntegerMod{P}(a - b.n)
end

function *{P}(a::IntegerMod{P}, b::IntegerMod{P})
  return IntegerMod{P}(a.n * b.n)
end

function *{P}(a::IntegerMod{P}, b::Bool)
  return
end

function *{P}(a::Bool, b::IntegerMod{P})
  return
end

function *{P}(a::IntegerMod{P}, b::Integer)
  return IntegerMod{P}(a.n * b)
end

function *{P}(a::Integer, b::IntegerMod{P})
  return IntegerMod{P}(a * b.n)
end

function zero{P}(a::IntegerMod{P})
  return IntegerMod{P}(0)
end

function zero{P}(a::Type{IntegerMod{P}})
  return IntegerMod{P}(0)
end

function zeros{P}(T::Type{IntegerMod{P}}, n = 0)
  result = Array(IntegerMod{P}, n)
  for i in 1:n
    result[i] = 0
  end
  return result
end

function divrem{P}(a::IntegerMod{P}, b::IntegerMod{P})
    q, r = divrem(a.n, b.n)
  return (IntegerMod{P}(q), IntegerMod{P}(r))
end

function /{P}(a::IntegerMod{P}, b::IntegerMod{P})
    return a * inverse(b)
end

function abs{P}(a::IntegerMod{P})
  return abs(a.n)
end

function inverse{P}(a::IntegerMod{P})
    x, y, d = extendedEuclideanAlgorithm(a.n, P)
    return IntegerMod{P}(x)
end

end # module Integer