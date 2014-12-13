module FiniteFields

##############################################################################
##
## TODO
##
##############################################################################

# - Should remove module and rely on package-level module as per convention
# - Methods e.g., promote, convert, macro +, -, *, /

##############################################################################
##
## Exports
##
##############################################################################

export isIrreducible, 
       FiniteField, 
       FiniteFieldElement, 
       inverse

##############################################################################
##
## Implementation
##
##############################################################################

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

# TODO: Should make another type, not Number
type FiniteField{P, M}
  polynomial::Polynomial{IntegerMod{P}}
  polynomialModulus::Polynomial{IntegerMod{P}}
  
  function FiniteField()
    polyMod::Polynomial{IntegerMod{P}} = generateIrreducibleModularPolynomial(P, M)
    new(Polynomial{IntegerMod{P}}(), polyMod)
  end
  function FiniteField(poly::Number)
    polyMod::Polynomial{IntegerMod{P}} = generateIrreducibleModularPolynomial(P, M)
    new(Polynomial{IntegerMod{P}}([poly]), polyMod)
  end
  function FiniteField(poly::Array)
    polyMod::Polynomial{IntegerMod{P}} = generateIrreducibleModularPolynomial(P, M)
    new(Polynomial{IntegerMod{P}}([poly]), polyMod)
  end
  function FiniteField(poly::Polynomial)
    polyMod::Polynomial{IntegerMod{P}} = generateIrreducibleModularPolynomial(P, M)
    new(poly, polyMod)
  end
end

function FiniteField(p::Integer, m::Integer)
  return FiniteField{p, m}
end

# convert{P, M}(::Type{FiniteField{P, M}}, n::Number) = FiniteField{P, M}(n)
# promote_rule{P, M}(::Type{FiniteField{P, M}}, ::Type{Number} ) = FiniteField{P, M}

### Functions ###

function isIrreducible{P}(poly::Polynomial{IntegerMod{P}})
  Zp = IntegerMod{P}
  x = Polynomial([Zp(0), Zp(1)])
  powerTerm = x
  isUnit(pol::Polynomial) = degree(pol) == 0
  
  for _ in 1:int(degree(poly) / 2)
    powerTerm = powerTerm ^ P
    powerTerm = rem(powerTerm, poly)
    gcdModP = gcd(poly, powerTerm - x)
    if !isUnit(gcdModP)
      return false
    end
  end
  
  return true
end

function generateIrreducibleModularPolynomial(p::Integer, m::Integer)
  modulus = p
  degree = m

  Zp = IntegerMod{modulus}
  while true
    firstRand::Array{Zp} = [Zp(rand(0:modulus - 1)) for i in 1:degree]
    append!(firstRand, [Zp(1)])



    p = Polynomial{Zp}(firstRand)
    if degree <= 1 || isIrreducible(p)
      return p
    end
  end
end
  
### Operators on FiniteField and FiniteFieldElement ###

function show{P, M}(io::IO, f::FiniteField{P, M})
  print(io, string(f.polynomial, ' ', '\u2208', ' ', "F_{", P, "^", M, "}"))
end

function +{P, M}(a::FiniteField{P, M}, b::FiniteField{P, M})
  return FiniteField{P, M}(a.polynomial + b.polynomial)
end

function +{P, M}(a::FiniteField{P, M}, b::Number)
  return FiniteField{P, M}(a.polynomial + Polynomial{IntegerMod{P}}(b))
end

function +{P, M}(a::Number, b::FiniteField{P, M})
  return FiniteField{P, M}(Polynomial{IntegerMod{P}(a)} + b.polynomial)
end

function -{P, M}(a::FiniteField{P, M}, b::FiniteField{P, M})
  return FiniteField{P, M}(a.polynomial - b.polynomial)
end

function -{P, M}(a::FiniteField{P, M}, b::Number)
  return FiniteField{P, M}(a.polynomial - Polynomial{IntegerMod{P}}(b))
end

function -{P, M}(a::Number, b::FiniteField{P, M})
  return FiniteField{P, M}(Polynomial{IntegerMod{P}(a)} - b.polynomial)
end

function *{P, M}(a::FiniteField{P, M}, b::FiniteField{P, M})
  return FiniteField{P, M}(a.polynomial * b.polynomial)
end

function *{P, M}(a::FiniteField{P, M}, b::Number)
  return FiniteField{P, M}(a.polynomial * Polynomial{IntegerMod{P}}(b))
end

function *{P, M}(a::Number, b::FiniteField{P, M})
  return FiniteField{P, M}(Polynomial{IntegerMod{P}(a)} * b.polynomial)
end

function =={P, M}(a::FiniteField{P, M}, b::FiniteField{P, M})
  return FiniteField{P, M}(a.polynomial == b.polynomial)
end

function ^{P, M}(a::FiniteField{P, M}, b::Integer)
  return FiniteField{P, M}(a.polynomial ^ b)
end

function -{P, M}(a::FiniteField{P, M})
  return FiniteField{P, M}(-a.polynomial)
end

function divrem{P, M}(a::FiniteField{P, M}, b::FiniteField{P, M})
  q, r = divrem(a.polynomial, b.polynomial)
  return (FiniteField{P, M}(q), FiniteField{P, M}(r))
end

function inverse{P, M}(a::FiniteField{P, M})
  if a.polynomial == Polynomial{IntegerMod{P}}()
    return Inf # TODO: Should this be an error?
  end

  x, y, d = extendedEuclideanAlgorithm(a.polynomial, a.polynomialModulus)
  # ERROR: inverse of d.coefficients?
  return FiniteField{P, M}(x) * FiniteField{P, M}(inverse(d.coefficients[1]))
end

end # module FiniteFields

# type FiniteFieldElement{P, M} <: Number
#   element::Polynomial{IntegerMod{P}}
#   f::FiniteField{P,M}
#   function FiniteFieldElement(e::Polynomial{IntegerMod{P}}, f::FiniteField{P,M})
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