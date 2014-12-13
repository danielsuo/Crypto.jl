module Crypto

##############################################################################
##
## TODO
##
##############################################################################

# - Investigate why shared library libcryptojl isn't getting picked up without
#   @timholy's hack.

##############################################################################
##
## Experts
##
##############################################################################

export init, cleanup, digest, ec_public_key_create

##############################################################################
##
## Load files
##
##############################################################################

include("digest.jl")
include("ecdsa.jl")
include("random.jl")

##############################################################################
##
## Get libcryptojl path (borrowed from @timholy's Cpp package)
##
##############################################################################

# Get possible library extensions
fnames = ["libcryptojl.so", "libcryptojl.dylib", "libcryptojl.dll"]

# Search for libraries
path = joinpath(Pkg.dir(), "Crypto", "deps")
global libname

found = false

for fname in fnames
    libname = Base.find_in_path(joinpath(path, fname))
    if isfile(libname)
        break
    end
end

if !isfile(libname)
    error("Library cannot be found; it may not have been built correctly.\n Try include(\"build.jl\") from within the deps directory.")
end

const libcryptojl = libname

end # module Crypto