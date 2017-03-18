#' Read a single htseq-counts result file.
#'
#' The htseq package is used extensively to count reads
#' relative to regions (see 
#' \url{http://www-huber.embl.de/HTSeq/doc/counting.html}).
#' The output of htseq-count is a simple two-column table
#' that includes features in column 1 and counts in column 2.
#' This function simply reads in the data from one such file
#' and assigns column names. 
#'
#' @param fname character(1), the path of the htseq-count file.
#' @param samplename character(1), the name of the sample. This will
#'     become the name of the second column on the resulting
#'     \code{data.frame}, making for easier merging if necessary.
#' @param ... passed to \code{\link[readr]{read_tsv})}
#' @return a two-column data frame
#'
#' @examples
#' fname = system.file(package='GenomicDataCommons',
#'                     'extdata/example.htseq.counts.gz')
#' dat = readHTSeqFile(fname)
#' head(dat)
#'
#' @export
readHTSeqFile <- function(fname, samplename = 'sample', ...) {
    if(!file.exists(fname))
        stop(sprintf('The specified file, %s, does not exist',fname))
    if(!((length(fname) == 1) & (is.character(fname))))
        stop('fname must be of type character(1)')
    tmp = read_tsv(fname,col_names = FALSE)
    if(ncol(tmp) != 2)
        stop(sprintf('%s had %d columns, expected 2 columns',fname, ncol(tmp)))
    colnames(tmp) = c('feature',samplename)
    tmp
}

