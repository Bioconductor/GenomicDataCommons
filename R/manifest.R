#' Prepare GDC manifest file for bulk download
#'
#' The \code{manifest} function/method creates a manifest of files to be downloaded
#' using the GDC Data Transfer Tool. There are methods for
#' creating manifest data frames from \code{\link{GDCQuery}} objects
#' that contain file information ("cases" and "files" queries).
#' 
#' @param x An \code{\link{GDCQuery}} object of subclass "gdc_files" or "gdc_cases".
#'
#' @param size The total number of records to return.  Default 
#' will return the usually desirable full set of records.
#'
#' @param from Record number from which to start when returning the manifest.
#'
#' @param ... passed to \code{\link[httr]{PUT}}.
#'
#' @return A \code{\link[tibble]{tibble}}, also of type "gdc_manifest", with five columns:
#' \itemize{
#' \item{id}
#' \item{filename}
#' \item{md5}
#' \item{size}
#' \item{state}
#'}
#' 
#' @examples
#' gFiles = files()
#' shortManifest = gFiles %>% manifest(size=10)
#' head(shortManifest,n=3)
#'
#' gCases = cases()
#' manifestFromCases = manifest(gCases,size=10)
#' manifestFromCases
#'
#' 
#' @export
manifest <- function(x,from=1,size=count(x),...) {
    UseMethod('manifest',x)
}

#' @describeIn manifest
#'
#' @export
manifest.gdc_files <- function(x,from=1,size=count(x),...) {
    .manifestCall(x=x,from=from,size=size,...)
}

#' @describeIn manifest
#'
#' @importFrom data.table rbindlist
#' 
#' @export
manifest.gdc_cases <- function(x,from=1,size=count(x),...) {
    fids = rbindlist((x %>%
        select('files.file_id') %>%
        response(from=from,size=size) %>%
        results())$files)$file_id
    q = files() %>% filter(~ file_id %in% fids)
    .manifestCall(x=q,from=from,size=size,...)
}

#' @describeIn manifest
#'
#' @export
manifest.GDCfilesResponse <- function(x,from=1,size=count(x),...) {
    .manifestCall(x=x$query,from=from,size=size,...)
}

#' @describeIn manifest
#'
#' @export
manifest.GDCcasesResponse <- function(x,from=1,size=count(x),...) {
    manifest(x=x$query,from=from,size=size,...)
}



#' @importFrom readr read_tsv 
.manifestCall <- function(x,from=1,size=count(x),...) {
    body = Filter(function(z) !is.null(z),x)
    body[['facets']]=NULL
    body[['fields']]=paste0(default_fields(x),collapse=",")
    body[['from']]=from
    body[['size']]=size
    body[['return_type']]='manifest'
    tmp = httr::content(.gdc_post(entity_name(x), body=body, archive=x$archive, token=NULL, ...))
    tmp = readr::read_tsv(tmp)
    structure(
        tmp,
        class = c('gdc_manifest',class(tmp))
    )
}


