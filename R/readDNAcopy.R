#' Read DNAcopy results into GRanges object
#'
#' @param fname The path to a DNAcopy-like file.
#' @return a \code{\link[GenomicRanges]{GRanges}} object
#' 
#' @importFrom data.table fread
#' @import GenomicRanges
#' @importFrom IRanges IRanges
#'
#' @examples
#' fname = system.file(package='GenomicDataCommons',
#'                     'extdata/dnacopy.tsv.gz')
#' dnac = readDNAcopy(fname)
#' class(dnac)
#' seqnames(dnac)
#' length(dnac)
readDNAcopy <- function(fname,...) {
    stopifnot(file.exists(fname))
    res = read_tsv(fname,...)
    stopifnot(ncol(res)==6)
    return(GRanges(seqnames=res[[2]],
                   ranges=IRanges(start=res[[3]],end=res[[4]]),
                   sampleName = res[[1]],
                   Num_Probes = res[[5]],
                   value      = res[[6]]))
}
