#' GDC manifest file creation and file download
#'
#' \code{manifest()} creates a manifest of files to be downloaded
#' using the GDC Data Transfer Tool.
#' 
#' @param uuids character() of GDC file UUIDs.
#'
#' @param destination_dir character(1) file path to a directory for
#'     downloading the manifest or files. The manifest file name, of
#'     the form \sQuote{gdc_manifest_20160610_12345.txt}, must not
#'     exist.
#'
#' @param token (optional) character(1) security token allowing access
#'     to restricted data. See
#'     \url{https://docs.gdc.cancer.gov/API/Users_Guide/Getting_Started/#authentication}.
#'
#' @examples
#' uuids <- c("e3228020-1c54-4521-9182-1ea14c5dc0f7",
#'            "18e1e38e-0f0a-4a0e-918f-08e6201ea140")
#' (manifest <- manifest(uuids))
#' @export
manifest <- function(uuids, destination_dir=tempfile(), token=NULL) {
    stopifnot(is.character(uuids))
    .dir_validate_or_create(destination_dir)
    endpoint <- "manifest"

    uuids <- trimws(uuids)
    uri <- sprintf("%s/%s", endpoint, paste(uuids, collapse=","))
    destination <- tempfile(tmpdir=destination_dir)

    .gdc_download_one(uri, destination, overwrite=FALSE,
                      progress=FALSE, token=token)
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
