#' Sorting a DNA alignment by similarity
#'
#' When checking sequences and looking for issues with alignments, it
#' helps to have a sorted set of alignments such that simliar
#' alignments are close to one-another. This function sorts data to
#' create just such an alignment, albeit somewhat stupidly.
#' @param input the path to a FASTA formatted DNA alignment
#' @param output the path to write the resulting sorted DNA
#'     alignment (to be written as a FASTA file)
#' @export
sort.alignment <- function(input, output){
    require(ape)
    dna <- read.FASTA(input)
    dist <- dist.dna(dna)
    pca <- prcomp(dist)
    dna <- dna[order(pca$x[,1])]
    write.dna(dna, output, "fasta")
    invisible(dna)
}
