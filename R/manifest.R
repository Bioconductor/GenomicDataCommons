#' GDC manifest file creation and file download
#'
#' \code{manifest()} creates a manifest of files to be downloaded
#' using the GDC Data Transfer Tool.
#' 
#' @param x An \code{\link{GDCQuery}} object of type 'gdc_files'.
#'
#' @param size The total number of records to return.  Default will return the usually desirable full set of records.
#'
#' @param from Record number from which to start when returning the manifest.
#'
#' @param ... passed to \code{\link[httr]{PUT}}.
#'
#' @return A \code{\link[tibble]{tibble}} with five columns:
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
#' @export
manifest.GDCResponse <- function(x,from=1,size=count(x),...) {
    .manifestCall(x=x$query,from=from,size=size,...)
}



#' @importFrom readr read_tsv 
.manifestCall <- function(x,from=1,size=count(x),...) {
    body = Filter(function(z) !is.null(z),x)
    body[['facets']]=paste0(body[['facets']],collapse=",")
    body[['fields']]=paste0(body[['fields']],collapse=",")
    body[['from']]=from
    body[['size']]=size
    body[['return_type']]='manifest'
    tmp = httr::content(.gdc_post(entity_name(x),body=body,token=NULL,...))
    tmp = readr::read_tsv(tmp)
    structure(
        tmp,
        class = c('gdc_manifest',class(tmp))
    )
}

#' \code{transfer()} retrieves files from the manifest using the GDC
#' Data Transfer Tool.
#'
#' @param manifest character(1) file path to manifest created by
#'     \code{manifest()}
#'
#' @param args character() vector specifying command-line arguments to
#'     be passed to \code{gdc-client}. See \code{transfer_help} for
#'     possible values. The arguments \code{--manifest}, \code{--dir},
#'     and \code{--token-file} are determined by \code{manifest},
#'     \code{destination_dir}, and \code{token}, respectively, and
#'     should NOT be provided as elements of \code{args}.
#'
#' @param token_file character(1) path to a file containing security
#'     token allowing access to restricted data. See
#'     \url{https://gdc-docs.nci.nih.gov/API/Users_Guide/Authentication_and_Authorization/}.
#'
#' @param gdc_client character(1) name or path to \code{gdc-client}
#'     executable. On Windows, use \code{/} or \code{\\\\} as the file
#'     separator.
#'
#' @param destination_dir The path into which to place the transfered files.
#'
#' @return character(1) directory path to which the files were
#'     downloaded.
#' 
#' @examples
#' \donttest{
#' destination <- transfer(manifest)
#' dir(destination)
#' }
#' @rdname manifest
#' @export
transfer <-
    function(manifest, destination_dir=tempfile(), args=character(),
             token_file=NULL, gdc_client="gdc-client")
{
    stopifnot(is.character(manifest), length(manifest) == 1L,
              file.exists(manifest))
    .dir_validate_or_create(destination_dir)

    dir <- sprintf("--dir %s", destination_dir)
    manifest <- sprintf("--manifest %s", manifest)
    if (!is.null(token)) {
        stopifnot(file.exists(token))
        token <- sprintf("--token-file %s", token)
    }
    args <- paste(c("download", dir, manifest, args), collapse=" ")
    system2("gdc-client", args)

    destination_dir
}

#' \code{transfer_help()} queries the the command line GDC Data
#' Transfer Tool, \code{gdc-client}, for available options to be used
#' in the \code{transfer()} command.
#' 
#' @rdname manifest
#' @export
transfer_help <- function(gdc_client="gdc-client") {
    system2(gdc_client, "download -h")
}
