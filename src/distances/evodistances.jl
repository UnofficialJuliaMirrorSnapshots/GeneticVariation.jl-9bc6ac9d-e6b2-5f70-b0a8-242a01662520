# evodistances.jl
# ===============
#
# Types and methods for computing evolutionary and genetic distances.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/GeneticVariation.jl/blob/master/LICENSE.md

# Types
# -----

abstract type EvolutionaryDistance end
abstract type TsTv <: EvolutionaryDistance end

include("proportion.jl")
