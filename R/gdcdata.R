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
#' @param overwrite logical(1) default FALSE indicating whether
#'     existing files with identical name should be over-written.
#'
#' @param progress logical(1) default TRUE in interactive sessions,
#'     FALSE otherwise indicating whether a progress par should be
#'     produced for each file download.
#'
#' @param token (optional) character(1) security token allowing access
#'     to restricted data. See
#'     \url{https://gdc-docs.nci.nih.gov/API/Users_Guide/Authentication_and_Authorization/}.
#'
#' @seealso \code{\link{manifest}} for downloading large data.
#'
#' @return a named vector with file uuids as the names and paths as
#' the value
#'
#' @examples
#' uuids <- c("e3228020-1c54-4521-9182-1ea14c5dc0f7",
#'            "18e1e38e-0f0a-4a0e-918f-08e6201ea140")
#' (files <- gdcdata(uuids, overwrite=TRUE))
#' setNames(file.size(files), names(files))
#' @export
gdcdata <-
    function(uuids, overwrite=FALSE,
             progress=interactive(), token=NULL)
{
    stopifnot(is.character(uuids))
    endpoint <- "data"
    bfc <-  .get_cache()

    uuids <- trimws(uuids)
    destinations <- file.path(bfccache(bfc), uuids)

    uris <- sprintf("%s/%s", endpoint, uuids)
    value <- mapply(.gdc_download_one, uris, destinations,
                    MoreArgs=list(overwrite=overwrite, progress=progress,
                                  token=token, bfc=bfc),
                    SIMPLIFY=TRUE, USE.NAMES=FALSE)
    names(value) <- uuids
    value
}
