module Integers

export IntegerMod, makeModular, extendedEuclideanAlgorithm, 
       gcd

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

    function IntegerMod()
      new(0, P)
    end
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

function gcd(a, b)
  if abs(b) > abs(a)
    return gcd(b, a)
  end
  
  while abs(b) > 0
    _, r = divrem(a,b)
    a, b = b, r
  end
  
  return a
end

function extendedEuclideanAlgorithm{T<:Number}(a::T, b::T)
    if abs(b) > abs(a)
        x, y, d = extendedEuclideanAlgorithm(b,a)
        return (y,x,d)
    end
    
    if abs(b) == 0
        return (1, 0, a)
    end
    
    x1, x2, y1, y2 = convert(T, 0), convert(T, 1), convert(T, 1), convert(T, 0) 
    while abs(b) > 0
        q, r = divrem(a, b)
        x = x2 - q*x1
        y = y2 - q*y1
        a, b, x2, x1, y2, y1 = b, r, x1, x, y1, y
    end
    
    return (x2, y2, a)
end

end # module Integer