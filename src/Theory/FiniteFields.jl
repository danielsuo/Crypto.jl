module FiniteFields

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

using Crypto
using Crypto.Integers
using Crypto.Polynomials

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

# convert{T<:Number}(::Type{Polynomial}, x::T) = Polynomial(x)
# convert{T<:Number, S<:Number}(::Type{Polynomial}, x::S) = Polynomial(convert(T, x))
# convert{T<:Number, S<:Number}(::Type{Polynomial}, x::Polynomial{S}) = Polynomial([convert(T,y) for y in x.coefficients])

# promote_rule{T<:Number}(::Type{Polynomial}, ::Type{T}) = Polynomial
# promote_rule{T<:Number, S<:Number}(::Type{Polynomial}, ::Type{S}) = Polynomial{promote_type(T,S)}
# promote_rule{T<:Number, S<:Number}(::Type{Polynomial}, ::Type{Polynomial{S}}) = Polynomial{promote_type(T,S)}

type FiniteField{P,M}
  polynomialModulus::Polynomial{IntegerMod{P}}
  
  function FiniteField()
    poly::Polynomial{IntegerMod{P}} = generateIrreducibleModularPolynomial(P,M)
    new(poly)
  end
  function FiniteField(poly::Polynomial{IntegerMod{P}})
    @assert isIrreducible(poly)
    new(poly)
  end
end

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
    powerTerm = powerTerm ^ P
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

end # method FiniteFields