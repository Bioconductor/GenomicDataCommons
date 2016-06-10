.gdcdata_download <-
    function(endpoint, uuids, destination_dir, overwrite, progress, ...,
             base=.gdc_base)
{
    stopifnot(is.character(endpoint), length(endpoint) == 1L)
    stopifnot(is.character(uuids))
    stopifnot(is.character(destination_dir), length(destination_dir) == 1L,
              nzchar(destination_dir), file.exists(destination_dir))
    
    uuids <- trimws(uuids)
    destinations <- file.path(destination_dir, uuids)
    if (!overwrite)
        stopifnot(all(!file.exists(destinations)))

    uris <- sprintf("%s/%s/%s", base, endpoint, uuids)
    value <- mapply(.gdc_download_one, uris, destinations,
                    MoreArgs=list(overwrite=overwrite, progress=progress),
                    SIMPLIFY=TRUE, USE.NAMES=FALSE)
    names(value) <- uuids
    value
}

#' Download GDC files
#'
#' Download one or more files from GDC. Files are downloaded using the
#' UUID and renamed to the file name on the remote system. By default,
#' neither the uuid nor the file name on the remote system can exist.
#'
#' This function is appropriate for one or several files; for large
#' downloads use \code{\link{manifest}} to create a manifest for and
#' the GDC Data Transfer Tool.
#'
#' @param uuids character() of GDC file UUIDs.
#'
#' @param destination_dir character(1) file path to an existing
#'     directory for downloading files to.
#'
#' @param overwrite logical(1) default FALSE indicating whether
#'     existing files with identical name should be over-written.
#'
#' @param progress logical(1) default TRUE in interactive sessions,
#'     FALSE otherwise indicating whether a progress par should be
#'     produced for each file download
#'
#' @seealso \code{\link{manifest}} for downloading large data.
#' 
#' @examples
#' uuids <- c("e3228020-1c54-4521-9182-1ea14c5dc0f7",
#'            "18e1e38e-0f0a-4a0e-918f-08e6201ea140")
#' (files <- gdcdata(uuids, overwrite=TRUE))
#' setNames(file.size(files), names(files))
#' @export
gdcdata <-
    function(uuids, destination_dir=tempdir(), overwrite=FALSE,
             progress=interactive())
{
    stopifnot(is.character(uuids))
    stopifnot(is.character(destination_dir), length(destination_dir) == 1L,
              nzchar(destination_dir), file.exists(destination_dir))
    endpoint <- "data"
    
    uuids <- trimws(uuids)
    destinations <- file.path(destination_dir, uuids)
    if (!overwrite)
        stopifnot(all(!file.exists(destinations)))

    uris <- sprintf("%s/%s", endpoint, uuids)
    value <- mapply(.gdc_download_one, uris, destinations,
                    MoreArgs=list(overwrite=overwrite, progress=progress),
                    SIMPLIFY=TRUE, USE.NAMES=FALSE)
    names(value) <- uuids
    value
}
