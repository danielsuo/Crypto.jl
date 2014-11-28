module FiniteFields

# NOTE: From from @wwilson, based on Jeremy Kun

export IntegerModN, makeModular, Polynomial, extendedEuclideanAlgorithm, gcd, isIrreducible, FiniteField, FiniteFieldElement, inverse 

import Base.show, 
     Base.length, 
     Base.convert, 
     Base.divrem, 
     Base.promote_rule, 
     Base.promote, 
     Base.abs,
     Base.div,
     Base.rem

### IntegerModN type ###

type IntegerModN{N} <: Number
    x::Int64
    function IntegerModN(n::Int64)
        new(mod(n,N))
    end
end

# It can be convenient not to have to think about the parametric types when working in the REPL
function makeModular(i::Int64, n::Integer)
    return IntegerModN{n}(i)
end

convert{N}(::Type{IntegerModN{N}}, x::Int64) = IntegerModN{N}(x)

promote_rule{N}(::Type{IntegerModN{N}}, ::Type{Int64}) = IntegerModN{N}

### Polynomial type ###

type Polynomial{T <: Number } <: Number
  coeffs::Vector{T}
  function Polynomial(coeffs::Vector{T})
    i = length(coeffs)
    while i > 0
      if coeffs[i] != 0
        break
      end
      i -= 1
    end
    new([coeffs[j] for j in 1:i])
  end
end

function Polynomial{T <: Number}(coeffs::Vector{T})
  return Polynomial{T}(coeffs)
end 

function Polynomial{T <: Number}(c::T)
  return Polynomial{T}([c])
end 

convert{T<:Number}(::Type{Polynomial{T}}, x::T) = Polynomial(x)
convert{T<:Number, S<:Number}(::Type{Polynomial{T}}, x::S) = Polynomial(convert(T, x))
convert{T<:Number, S<:Number}(::Type{Polynomial{T}}, x::Polynomial{S}) = Polynomial([convert(T,y) for y in x.coeffs])

promote_rule{T<:Number}(::Type{Polynomial{T}}, ::Type{T}) = Polynomial{T}
promote_rule{T<:Number, S<:Number}(::Type{Polynomial{T}}, ::Type{S}) = Polynomial{promote_type(T,S)}
promote_rule{T<:Number, S<:Number}(::Type{Polynomial{T}}, ::Type{Polynomial{S}}) = Polynomial{promote_type(T,S)}

type FiniteField{P,M}
  polynomialModulus::Polynomial{IntegerModN{P}}
  
  function FiniteField()
    poly::Polynomial{IntegerModN{P}} = generateIrreducibleModularPolynomial(M,P)
    new(poly)
  end
  function FiniteField(poly::Polynomial{IntegerModN{P}})
    @assert isIrreducible(poly)
    new(poly)
  end
end

function FiniteField(p::Integer, m::Integer)
  return FiniteField{p,m}()
end

type FiniteFieldElement{P,M} <: Number
  element::Polynomial{IntegerModN{P}}
  f::FiniteField{P,M}
  function FiniteFieldElement(e::Polynomial{IntegerModN{  P}}, f::FiniteField{P,M})
    mod = rem(e,f.polynomialModulus)
    new(mod,f)
  end
end

function FiniteFieldElement{P,M}(e::FiniteFieldElement{P,M}, f::FiniteField{P,M})
  FiniteFieldElement{P,M}(e.element,f)
end

function FiniteFieldElement{P,M}(i::IntegerModN{P}, f::FiniteField{P,M})
  FiniteFieldElement{P,M}(Polynomial(i),f)
end

function FiniteFieldElement{P,M}(i::Int64, f::FiniteField{P,M})
  FiniteFieldElement{P,M}(Polynomial(makeModular(i,P)),f)
end

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

function isIrreducible{N}(p::Polynomial{IntegerModN{N}})
  x = Polynomial([IntegerModN{N}(0), IntegerModN{N}(1)])
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
    firstRand::Array{IntegerModN{modulus}} = [[makeModular(rand(0:modulus-1), modulus) for i in 0:degree-1], makeModular(1,modulus)]
    p = Polynomial{IntegerModN{modulus}}(firstRand)
    if isIrreducible(p)
      return p
    end
  end
end

### Operators on Polynomial ###

function isZero{T <: Number}(p::Polynomial{T})
  return p.coeffs == []
end

function abs(p::Polynomial)
  return length(p.coeffs)
end

function length(p::Polynomial)
  return length(p.coeffs)
end

function degree(p::Polynomial)
  return length(p.coeffs) -1
end

function leadingCoefficient(p::Polynomial)
  return p.coeffs[length(p.coeffs)]
end

function show{T <: Number}(io::IO, p::Polynomial{T})
  if isZero(p)
    print(io, "0")
  else
    i = length(p)
    while i > 1
      if p.coeffs[i] != 0
        print(io, string(p.coeffs[i], "x^", i-1, " + "))
      end
      i -= 1
    end
    print(io, string(p.coeffs[1]))
  end
end

function =={T <: Number}(a::Polynomial{T}, b::Polynomial{T})
  length(a) == length(b) && (isZero(a ) || !(false in [a.coeffs[i] == b.coeffs[i] for i in 1:length(a)]))
end

function -{T <: Number}(p::Polynomial{T})
  return Polynomial{T}([-i for i in p.coeffs])
end

function -{T <: Number}(a::Polynomial{T}, b::Polynomial{T})
  return a+(-b)
end

function +{T <: Number}(a::Polynomial{T}, b::Polynomial{T})
  newcoeffs = zeros(T, max(length(a), length(b)))
  i = 1
  while i <= min(length(a), length(b))
    newcoeffs[i] += (a.coeffs[i] + b.coeffs[i])
    i += 1
  end
  while i <= length(a)
    newcoeffs[i] += a.coeffs[i]
    i += 1
  end
  while i <= length(b)
    newcoeffs[i] += b.coeffs[i]
    i += 1  
  end
  return Polynomial{T}(newcoeffs)
end

function *{T <: Number}(a::Polynomial{T}, b::Polynomial{T})
  if isZero(a) || isZero(b)
    return Polynomial{T}(Array(T, 0))
  else
    newcoeffs = zeros(T, length(a) + length(b) - 1)
    for i in 0:length(a)-1
      for j in 0:length(b)-1
        newcoeffs[i+j+1] += a.coeffs[i+1]*b.coeffs[j+1]
      end
    end
    return Polynomial{T}(newcoeffs)
  end
end

function divrem{T <: Number}(a::Polynomial{T}, b::Polynomial{T})
  quotient = Polynomial{T}(Array(T, 0))
  remainder = a
  divisorDeg = degree(b)
  divisorLC = leadingCoefficient(b)
  
  while degree(remainder) >= divisorDeg
    monomialExponent = degree(remainder) - divisorDeg
    monomialZeros = zeros(T, monomialExponent)
    monomialDivisor = Polynomial{T}([monomialZeros,[convert(T,leadingCoefficient(remainder)/divisorLC)]] )
    
    quotient += monomialDivisor
    remainder -= (monomialDivisor*b)
  end
  
  return (quotient, remainder)
end

function rem{T <: Number}(a::Polynomial{T}, b::Polynomial{T})
  q,r = divrem(a,b)
  return r
end

function /{T <: Number}(a::Polynomial{T}, b::Polynomial{T})
  q,r = divrem(a,b)
  return q
end

function div{T <: Number}(a::Polynomial{T}, b::Polynomial{T})
  q,r = divrem(a,b)
  return q
end

function ^{T <: Number}(a::Polynomial{T}, n::Integer)
  ret = Polynomial(convert(T,1))
  for i in 1:n
    ret = ret*a
  end
  return ret
end
  
### Operators on FiniteField and FiniteFieldElement ###

function show{P,M}(io::IO, f::FiniteField{P,M})
  print(io, string("F_{",P,"^",M,"}"))
end

function =={P,M}(f1::FiniteField{P,M}, f2::FiniteField{P,M})
  return f1.polynomialModulus == f2.polynomialModulus
end

function show(io::IO, e::FiniteFieldElement)
  print(io, e.element, " \u2208 ", e.f)
end

function =={P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
  return e1.element == e2.element && e1.f == e2.f
end

function +{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
  @assert e1.f == e2.f
  return FiniteFieldElement{P,M}(e1.element+e2.element,e1.f)
end

function -{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
  @assert e1.f == e2.f
  return FiniteFieldElement{P,M}(e1.element-e2.element,e1.f)
end

function *{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
  @assert e1.f == e2.f
  return FiniteFieldElement{P,M}(e1.element*e2.element,e1.f)
end

function divrem{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
  @assert e1.f == e2.f
  q,r = divrem(e1.element,e2.element)
  return (FiniteFieldElement{P,M}(q,e1.f), FiniteFieldElement{P,M}(r,e1.f)) 
end

function div{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
  q,_ = divrem(e1,e2)
  return q
end

function rem{P,M}(e1::FiniteFieldElement{P,M}, e2::FiniteFieldElement{P,M})
  q,r = divrem(e1,e2)
  return r
end

function -{P,M}(e::FiniteFieldElement{P,M})
  return FiniteFieldElement{P,M}(-e.element,e1.f)
end

function abs{P,M}(e::FiniteFieldElement{P,M})
  return abs(e.element)
end

function ^{P,M}(e::FiniteFieldElement{P,M}, n::Integer)
  return FiniteFieldElement{P,M}(e.element^n, e.f)
end

function inverse{P,M}(e::FiniteFieldElement{P,M})
  if e == FiniteFieldElement{P,M}(Polynomial([makeModular(0,P)]),e.f)
    error("Divide by zero")
  end
  
  x,y,d = extendedEuclideanAlgorithm(e.element, e.f.polynomialModulus)
  return FiniteFieldElement{P,M}(x, e.f) * FiniteFieldElement{P,M}(Polynomial([inverse(d.coeffs[1])]), e.f)
end
  
### Operators on IntegerModN ###

function show{N}(io::IO, a::IntegerModN{N})
    print(io, string(a.x, " (mod ", N, ")"))
end

function =={N}(a::IntegerModN{N}, b::IntegerModN{N})
  return a.x == b.x
end

function +{N}(a::IntegerModN{N}, b::IntegerModN{N})
    return IntegerModN{N}(a.x+b.x)
end

function -{N}(a::IntegerModN{N})
    return IntegerModN{N}(-a.x)
end

function -{N}(a::IntegerModN{N}, b::IntegerModN{N})
    return a+(-b)
end

function *{N}(a::IntegerModN{N}, b::IntegerModN{N})
    return IntegerModN{N}(a.x*b.x)
end

function divrem{N}(a::IntegerModN{N}, b::IntegerModN{N})
    q,r = divrem(a.x, b.x)
  return (IntegerModN{N}(q), IntegerModN{N}(r))
end

#function div{T<:Integer, N}(a::IntegerModN{T,N}, b::IntegerModN{T,N})
#    return a*inverse(b)
#end

function /{N}(a::IntegerModN{N}, b::IntegerModN{N})
    return a*inverse(b)
end

function abs{N}(a::IntegerModN{N})
  return abs(a.x)
end

function inverse{N}(a::IntegerModN{N})
    x,y,d = extendedEuclideanAlgorithm(a.x, N)
    return IntegerModN{N}(x)
end

end