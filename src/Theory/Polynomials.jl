module Polynomials

export Polynomial, degree

##############################################################################
##
## Polynomial arithmetic
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

# TODO: Rethink this subclassing; polynomial is a field element, not a number.
type Polynomial{T} <: Number
  coefficients::Array{T}

  function Polynomial()
    return new([0])
  end

  function Polynomial(c::Array)
    i = length(c)
    while i > 0
      if c[i] != 0
        break
      end
      i -= 1
    end

    a = Array(T, i)
    for j in 1:i
      a[j] = c[j]
    end

    new(a)
  end
end

convert{T<:Number}(::Type{Polynomial{T}}, x::T) = Polynomial(x)
convert{T<:Number, S<:Number}(::Type{Polynomial{T}}, x::S) = Polynomial(convert(T, x))
convert{T<:Number, S<:Number}(::Type{Polynomial{T}}, x::Polynomial{S}) = Polynomial([convert(T,y) for y in x.coefficients])

promote_rule{T<:Number}(::Type{Polynomial{T}}, ::Type{T}) = Polynomial
promote_rule{T<:Number, S<:Number}(::Type{Polynomial{T}}, ::Type{S}) = Polynomial{promote_type(T,S)}
promote_rule{T<:Number, S<:Number}(::Type{Polynomial{T}}, ::Type{Polynomial{S}}) = Polynomial{promote_type(T,S)}

function Polynomial{T}(c::Array{T})
  return Polynomial{T}([c])
end

function zero{T}(p::Polynomial{T})
  return Polynomial{T}([])
end

function zero{T}(a::Type{Polynomial{T}})
  return Polynomial{T}([])
end

function isZero(p::Polynomial)
  return p.coefficients == []
end

function abs(p::Polynomial)
  return length(p.coefficients)
end

function length(p::Polynomial)
  return length(p.coefficients)
end

function degree(p::Polynomial)
  return length(p.coefficients) - 1
end

function leadingCoefficient(p::Polynomial)
  return p.coefficients[length(p.coefficients)]
end

function show(io::IO, p::Polynomial)
  if isZero(p)
    print(io, "0")
  else
    print(io, string(p.coefficients[1]))
    for i in 2:length(p)
      if p.coefficients[i] != 0
        print(io, string(" + ", p.coefficients[i], "x^", i - 1))
      end
    end
  end
end

function ==(a::Polynomial, b::Polynomial)
  length(a) == length(b) && (isZero(a ) || !(false in [a.coefficients[i] == b.coefficients[i] for i in 1:length(a)]))
end

function -(p::Polynomial)
  return Polynomial([-i for i in p.coefficients])
end

function -(a::Polynomial, b::Polynomial)
  return a+(-b)
end

function +{T}(a::Polynomial{T}, b::Polynomial{T})
  newcoefficients = zeros(T, max(length(a), length(b)))
  i = 1
  while i <= min(length(a), length(b))
    newcoefficients[i] += (a.coefficients[i] + b.coefficients[i])
    i += 1
  end
  while i <= length(a)
    newcoefficients[i] += a.coefficients[i]
    i += 1
  end
  while i <= length(b)
    newcoefficients[i] += b.coefficients[i]
    i += 1  
  end
  return Polynomial{T}(newcoefficients)
end

function *{T}(a::Polynomial{T}, b::Polynomial{T})
  if isZero(a) || isZero(b)
    return Polynomial{T}(Array(T, 0))
  else
    newcoefficients = zeros(T, length(a) + length(b) - 1)
    for i in 0:length(a)-1
      for j in 0:length(b)-1
        newcoefficients[i + j + 1] += a.coefficients[i + 1] * b.coefficients[j + 1]
      end
    end
    return Polynomial{T}(newcoefficients)
  end
end

function divrem{T}(a::Polynomial{T}, b::Polynomial{T})
  quotient = Polynomial{T}(Array(T, 0))
  remainder = a
  divisorDeg = degree(b)
  divisorLC = leadingCoefficient(b)
  
  while degree(remainder) >= divisorDeg
    monomialExponent = degree(remainder) - divisorDeg
    monomialZeros = zeros(T, monomialExponent)
    monomialDivisor = Polynomial{T}([monomialZeros, [convert(T, leadingCoefficient(remainder)/divisorLC)]])
    
    quotient += monomialDivisor
    remainder -= (monomialDivisor*b)
  end
  
  return (quotient, remainder)
end

function rem{T}(a::Polynomial{T}, b::Polynomial{T})
  q,r = divrem(a,b)
  return r
end

function /{T}(a::Polynomial{T}, b::Polynomial{T})
  q,r = divrem(a,b)
  return q
end

function ^{T}(a::Polynomial{T}, n::Integer)
  ret = Polynomial{T}([1])
  for i in 1:n
    ret = ret*a
  end
  return ret
end

end # module Polynomial