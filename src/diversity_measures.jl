# diversity_measures.jl
# =====================
#
# Compute measures of genetic diversity with BioJulia data types.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/GeneticVariation.jl/blob/master/LICENSE.md


function pdist(d::Matrix{Tuple{Int,Int}})
    o = similar(d, Float64)
    @inbounds for i in eachindex(d)
        o[i] = d[i][1] / d[i][2]
    end
    return o
end

"""
    NL79(m::M, f::V) where {M<:AbstractMatrix{Float64},V<:AbstractVector{Float64}}

Compute nucleotide diversity using a matrix of the number of mutations
between sequence pairs, and a vector of the frequencies of each sequence
in the population.
"""
function NL79(m::AbstractMatrix{Float64}, f::AbstractVector{Float64})
    π = 0.0
    @inbounds for i = 1:lastindex(f), j = (i + 1):lastindex(f)
        π += m[i, j] * f[i] * f[j]
    end
    return 2 * π
end

"""
    NL79(sequences)

Compute nucleotide diversity, as described by Nei and Li in 1979.

This measure is defined as the average number of nucleotide differences per site
between two DNA sequences in all possible pairs in the sample population, and is
often denoted by the greek letter pi.

`Sequences` should be any iterable that yields biosequence types.

# Examples

```jldoctest
julia> testSeqs = [dna"AAAACTTTTACCCCCGGGGG",
                   dna"AAAACTTTTACCCCCGGGGG",
                   dna"AAAACTTTTACCCCCGGGGG",
                   dna"AAAACTTTTACCCCCGGGGG",
                   dna"AAAAATTTTACCCCCGTGGG",
                   dna"AAAAATTTTACCCCCGTGGG",
                   dna"AAAACTTTTTCCCCCGTAGG",
                   dna"AAAACTTTTTCCCCCGTAGG",
                   dna"AAAAATTTTTCCCCCGGAGG",
                   dna"AAAAATTTTTCCCCCGGAGG"]
10-element Array{BioSequences.BioSequence{BioSequences.DNAAlphabet{4}},1}:
 AAAACTTTTACCCCCGGGGG
 AAAACTTTTACCCCCGGGGG
 AAAACTTTTACCCCCGGGGG
 AAAACTTTTACCCCCGGGGG
 AAAAATTTTACCCCCGTGGG
 AAAAATTTTACCCCCGTGGG
 AAAACTTTTTCCCCCGTAGG
 AAAACTTTTTCCCCCGTAGG
 AAAAATTTTTCCCCCGGAGG
 AAAAATTTTTCCCCCGGAGG

 julia> NL79(testSeqs)
 0.096

```
"""
function NL79(sequences)
    frequencies = gene_frequencies(sequences)
    unique_sequences = collect(keys(frequencies))
    n = length(unique_sequences)
    if n < 2
        return 0.0
    else
        mutations = pdist(BioSequences.count_pairwise(Mutated, unique_sequences...))
        return NL79(mutations, collect(values(frequencies)))
    end
end

"""
    avg_mut(sequences)

The average number of mutations found in (n choose 2) pairwise comparisons of
sequences (i, j) in a sample of sequences.

`sequences` should be any indexable container of DNA sequence types.
"""
function avg_mut(sequences)
    s = length(sequences)
    @assert s ≥ 2 "At least 2 sequences are required."
    nmut = 0
    n = 0
    @inbounds for i in eachindex(sequences)
        si = sequences[i]
        for j in (i + 1):lastindex(sequences)
            nmut += count(Mutated, si, sequences[j])[1]
            n += 1
        end
    end
    return nmut / div(s * (s - 1), 2)
end
