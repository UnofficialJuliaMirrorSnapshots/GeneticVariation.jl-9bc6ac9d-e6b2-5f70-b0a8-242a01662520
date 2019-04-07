# minhash.jl
# ==========
#
# Distance measures for MinHash sketches
#
# see DOI: 10.1186/s13059-016-0997-x
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/GeneticVariation.jl/blob/master/LICENSE.md

struct Jaccard end

"""
[MASH distances](http://doi.org/10.1186/s13059-016-0997-x), based on MinHash
sketches of genome sequences provide rapid genome-scale sequence comparisons
when sequence distance (not specific mutations) are all that's required.

A MinHash sketch is made by taking the `s` smallest hash values for kmers of
length `k` for a given sequence. The genome distance for two genomes is then
essentially the [Jaccard index](https://en.wikipedia.org/wiki/Jaccard_index)
of the minhashes, with some additional modification to account for the size of
the kmers used.
"""
struct MASH end

@inline function distance(::Type{Jaccard}, sketch1::MinHashSketch, sketch2::MinHashSketch)
    sketch1.kmersize == sketch2.kmersize || error("sketches must have same kmer length")
    length(sketch1) == length(sketch2) || error("sketches must be the same size")

    matches = 0
    sketchlen = length(sketch1)
    i = 1
    j = 1

    while i <= sketchlen && j <= sketchlen
        if sketch1.sketch[i] == sketch2.sketch[j]
            matches += 1
            i += 1
            j += 1
        elseif sketch1.sketch[i] < sketch2.sketch[j]
            while i <= sketchlen && sketch1.sketch[i] < sketch2.sketch[j]
                i += 1
            end
        elseif sketch2.sketch[j] < sketch1.sketch[i]
            while j <= sketchlen && sketch2.sketch[j] < sketch1.sketch[i]
                j += 1
            end
        end
    end

    if matches == sketchlen
        return 1.0
    else
        return matches / (2 * sketchlen - matches)
    end
end

@inline function distance(::Type{MASH}, sketch1::MinHashSketch, sketch2::MinHashSketch)
    j = distance(Jaccard, sketch1, sketch2)
    k = sketch1.kmersize
    return -1/k * log(2j / (1+j))
end

@inline mash(sketch1::MinHashSketch, sketch2::MinHashSketch) = distance(MASH, sketch1, sketch2)
@inline jaccard(sketch1::MinHashSketch, sketch2::MinHashSketch) = distance(Jaccard, sketch1, sketch2)
