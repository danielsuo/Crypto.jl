module EllipticCurves

# NOTE: From from @wwilson, based on Jeremy Kun

##############################################################################
##
## Exported functions and types
##
##############################################################################

export Curve, ConcretePoint, IdealPoint

##############################################################################
##
## Elliptic curve type definition
##
##############################################################################

immutable Curve
  a::Number
  b::Number
  discriminant

  function Curve(a::Number, b::Number)
    d = -16 * (4 * a*a*a + 27 * b * b)
    if d == 0
      error("Curve is singular.")
    end
    new(a, b, d)
  end
end

function show(io::IO, e::Curve)
    print(io, "y^2 = x^3 + ", e.a, "x + ", e.b, "\n")
end

function ==(e::Curve, f::Curve)
  return e.a == f.a && e.b == f.b
end

##############################################################################
##
## Point type definition
##
##############################################################################

abstract Point

type ConcretePoint <: Point
  x::Number
  y::Number
  c::Curve
  
  function ConcretePoint(x::Number, y::Number, c::Curve)
    y * y == x * x * x + c.a * x + c.b ? new(x, y, c) : error("Point is not on curve.")
  end
end

type IdealPoint <: Point
  c::Curve
  IdealPoint(c::Curve) = new(c)
end

function ==(p::IdealPoint, q::IdealPoint)
  return p.c == q.c
end

function ==(p::IdealPoint, q::ConcretePoint)
  return false
end

function ==(p::ConcretePoint, q::IdealPoint)
  return false
end

function ==(p::ConcretePoint, q::ConcretePoint)
  return p.x == q.x && p.y == q.y && p.c == q.c
end

function -(p::IdealPoint)
  return p
end

function -(p::ConcretePoint)
  return ConcretePoint(p.x,-p.y,p.c)
end

function +(p1::IdealPoint, p2::IdealPoint)
  @assert p1.c == p2.c
  return p1
end

function +(p1::IdealPoint, p2::ConcretePoint)
  @assert p1.c == p2.c
  return p2
end

function +(p1::ConcretePoint, p2::IdealPoint)
  @assert p1.c == p2.c
  return p1
end

function +(p1::ConcretePoint, p2::ConcretePoint)
  @assert p1.c == p2.c
  if p1 == p2
    if p1.y == 0
      return IdealPoint(p1.c)
    end
    m = (3*p1.x*p1.x+p1.c.a) / (2*p1.y)
  else
    if p1.x == p2.x
      return IdealPoint(p1.c)
    end
    m = (p2.y-p1.y) / (p2.x-p1.x)
  end
  
  new_x = m * m - p2.x - p1.x
  new_y = m * (new_x - p1.x) + p1.y
  
  return ConcretePoint(new_x, -new_y, p1.c)
end

function -(p1::Point, p2::Point)
  return p1 + (-p2)
end

function *(p::IdealPoint, n::Integer)
  return p
end

function *(n::Integer, p::IdealPoint)
  return p
end

function *(p::ConcretePoint, n::Integer)
  if n == 0
    return IdealPoint(p.c)
  elseif n < 0
    return -p * -n
  else
    q::Point = p
    r::Point = ( n & 1 == 1 ? p : IdealPoint(p.c))
    i = 2
    while i <= n
      q = q+q
      if n & i == i
        r = q+r
      end
      i = i << 1
    end
    return r
  end
end

function *(n::Integer, p::ConcretePoint)
  return p*n
end

end # module EllipticCurves