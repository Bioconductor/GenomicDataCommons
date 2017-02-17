#' Query GDC for data slices
#'
#' This function returns a BAM file representing reads overlapping
#' regions specified either as chromosomal regions or as gencode gene
#' symbols.
#'
#' @param uuid character(1) identifying the BAM file resource
#'
#' @param regions character() vector describing chromosomal regions,
#'     e.g., \code{c("chr1", "chr2:10000", "chr3:10000-20000")} (all
#'     of chromosome 1, chromosome 2 from position 10000 to the end,
#'     chromosome 3 from 10000 to 20000).
#'
#' @param symbols character() vector of gencode gene symbols, e.g.,
#'     \code{c("BRCA1", "PTEN")}
#'
#' @param destination character(1) default \code{tempfile()} file path
#'     for BAM file slice
#'
#' @param overwrite logical(1) default FALSE can destination be
#'     overwritten?
#'
#' @param progress logical(1) default \code{interactive()} should a
#'     progress bar be used?
#'
#' @param token character(1) security token allowing access to
#'     restricted data. Almost all BAM data is restricted, so a token is
#'     usually required. See
#'     \url{https://gdc-docs.nci.nih.gov/API/Users_Guide/Authentication_and_Authorization/}.
#'
#' @param archive character(1) label for either the "default" archive or the "legacy"
#'     archive, containing older, non-harmonized data.
#' 
#' @return character(1) destination to the downloaded BAM file
#'
#' @importFrom httr progress
#' 
#' @examples
#' \donttest{
#' slicing("df80679e-c4d3-487b-934c-fcc782e5d46e",
#'         regions="chr17:75000000-76000000",
#'         token=token)
#' }
#' @export
slicing <- function(uuid, regions, symbols, destination=tempfile(),
                    overwrite=FALSE, progress=interactive(), token=NULL, archive = 'default')
{
    stopifnot(is.character(uuid), length(uuid) == 1L)
    stopifnot(missing(regions) || missing(symbols),
              !(missing(regions) && missing(symbols)))
    stopifnot(is.character(destination), length(destination) == 1L,
              !overwrite && !file.exists(destination))
    stopifnot(!missing(token))

    if (!missing(symbols))
        body <- list(gencode=I(symbols))
    else
        ## FIXME: validate regions
        body <- list(regions=I(regions))
    print(toJSON(body))

    response <- .gdc_post(
        endpoint=sprintf("slicing/view/%s", uuid),
        add_headers('Content-type'='application/json'),
        write_disk(destination, overwrite),
        if (progress) progress() else NULL,
        body=toJSON(body), token=token, archive = archive)
    if (progress)
        cat("\n")

    destination
}
