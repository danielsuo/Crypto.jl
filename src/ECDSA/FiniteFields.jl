# module FiniteFields

##############################################################################
##
## Exported functions and types
##
##############################################################################

# export IntegerMod, 
#        makeModular, 
#        Polynomial, 
#        extendedEuclideanAlgorithm, 
#        gcd, 
#        isIrreducible, 
#        FiniteField, 
#        FiniteFieldElement, 
#        inverse 

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

##############################################################################
##
## Modular arithmetic (IntegerMod)
##
##############################################################################

type IntegerMod{P}
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

##############################################################################
##
## Polynomial arithmetic
##
##############################################################################

type Polynomial{T}
  coefficients::Array{T}

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
    i = length(p)
    while i > 1
      if p.coefficients[i] != 0
        print(io, string(p.coefficients[i], "x^", i-1, " + "))
      end
      i -= 1
    end
    print(io, string(p.coefficients[1]))
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

# convert{T<:Number}(::Type{Polynomial}, x::T) = Polynomial(x)
# convert{T<:Number, S<:Number}(::Type{Polynomial}, x::S) = Polynomial(convert(T, x))
# convert{T<:Number, S<:Number}(::Type{Polynomial}, x::Polynomial{S}) = Polynomial([convert(T,y) for y in x.coefficients])

# promote_rule{T<:Number}(::Type{Polynomial}, ::Type{T}) = Polynomial
# promote_rule{T<:Number, S<:Number}(::Type{Polynomial}, ::Type{S}) = Polynomial{promote_type(T,S)}
# promote_rule{T<:Number, S<:Number}(::Type{Polynomial}, ::Type{Polynomial{S}}) = Polynomial{promote_type(T,S)}

# type FiniteField{P,M}
#   polynomialModulus::Polynomial{IntegerMod{P}}
  
#   function FiniteField()
#     poly::Polynomial{IntegerMod{P}} = generateIrreducibleModularPolynomial(P,M)
#     new(poly)
#   end
#   function FiniteField(poly::Polynomial{IntegerMod{P}})
#     @assert isIrreducible(poly)
#     new(poly)
#   end
# end

# function FiniteField(p::Integer, m::Integer)
#   return FiniteField{p,m}()
# end

# type FiniteFieldElement{P,M} <: Number
#   element::Polynomial{IntegerMod{P}}
#   f::FiniteField{P,M}
#   function FiniteFieldElement(e::Polynomial{IntegerMod{  P}}, f::FiniteField{P,M})
#     mod = rem(e,f.polynomialModulus)
#     new(mod,f)
#   end
# end

# function FiniteFieldElement{P,M}(e::FiniteFieldElement{P,M}, f::FiniteField{P,M})
#   FiniteFieldElement{P,M}(e.element,f)
# end

# function FiniteFieldElement{P,M}(i::IntegerMod{P}, f::FiniteField{P,M})
#   FiniteFieldElement{P,M}(Polynomial(i),f)
# end

# function FiniteFieldElement{P,M}(i::Int64, f::FiniteField{P,M})
#   FiniteFieldElement{P,M}(Polynomial(makeModular(i,P)),f)
# end

### Functions ###

function gcd(a::Number, b::Number)
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
        x,y,d = extendedEuclideanAlgorithm(b,a)
        return (y,x,d)
    end
    
    if abs(b) == 0
        return (1, 0, a)
    end
    
    x1, x2, y1, y2 = convert(T,0), convert(T,1), convert(T,1), convert(T,0) 
    while abs(b) > 0
        q, r = divrem(a, b)
        x = x2 - q*x1
        y = y2 - q*y1
        a, b, x2, x1, y2, y1 = b, r, x1, x, y1, y
    end
    
    return (x2, y2, a)
end

function isIrreducible{P}(p::Polynomial{IntegerMod{P}})
  x = Polynomial([IntegerMod{P}(0), IntegerMod{P}(1)])
  powerTerm = x
  isUnit(pol::Polynomial) = degree(pol) == 0
  
  for _ in 0:int(degree(p)/2)-1
    powerTerm = powerTerm ^ N
    powerTerm = rem(powerTerm, p)
    gcdModP = gcd(p, powerTerm-x)
    if !isUnit(gcdModP)
      return false
    end
  end
  
  return true
end

function generateIrreducibleModularPolynomial(degree::Integer, modulus::Integer)
  @assert degree > 1
  while true
    firstRand::Array{IntegerMod{modulus}} = [[makeModular(rand(0:modulus-1), modulus) for i in 0:degree-1], makeModular(1,modulus)]
    p = Polynomial{IntegerMod{modulus}}(firstRand)
    if isIrreducible(p)
      return p
    end
  end
end
  
### Operators on FiniteField and FiniteFieldElement ###

# function show{P,M}(io::IO, f::FiniteField{P,M})
#   print(io, string("F_{",P,"^",M,"}"))
# end

# function =={P,M}(f1::FiniteField{P,M}, f2::FiniteField{P,M})
#   return f1.polynomialModulus == f2.polynomialModulus
# end

# function show(io::IO, e::FiniteFieldElement)
#   print(io, e.element, " \u2208 ", e.f)
# end

# function =={P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
#   return e1.element == e2.element && e1.f == e2.f
# end

# function +{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
#   @assert e1.f == e2.f
#   return FiniteFieldElement{P,M}(e1.element+e2.element,e1.f)
# end

# function -{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
#   @assert e1.f == e2.f
#   return FiniteFieldElement{P,M}(e1.element-e2.element,e1.f)
# end

# function *{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
#   @assert e1.f == e2.f
#   return FiniteFieldElement{P,M}(e1.element*e2.element,e1.f)
# end

# function divrem{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
#   @assert e1.f == e2.f
#   q,r = divrem(e1.element,e2.element)
#   return (FiniteFieldElement{P,M}(q,e1.f), FiniteFieldElement{P,M}(r,e1.f)) 
# end

# function div{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
#   q,_ = divrem(e1,e2)
#   return q
# end

# function rem{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
#   q,r = divrem(e1,e2)
#   return r
# end

# function -{P,M}(e::FiniteFieldElement{P,M})
#   return FiniteFieldElement{P,M}(-e.element,e1.f)
# end

# function abs{P,M}(e::FiniteFieldElement{P,M})
#   return abs(e.element)
# end

# function ^{P,M}(e::FiniteFieldElement{P,M}, n::Integer)
#   return FiniteFieldElement{P,M}(e.element^n, e.f)
# end

# function inverse{P,M}(e::FiniteFieldElement{P,M})
#   if e == FiniteFieldElement{P,M}(Polynomial([makeModular(0,P)]),e.f)
#     error("Divide by zero")
#   end
  
#   x,y,d = extendedEuclideanAlgorithm(e.element, e.f.polynomialModulus)
#   return FiniteFieldElement{P,M}(x, e.f) * FiniteFieldElement{P,M}(Polynomial([inverse(d.coefficients[1])]), e.f)
# end

# end # method FiniteFields