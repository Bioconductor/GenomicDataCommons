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
#' @param use_cached logical(1) default TRUE indicating that,
#'     if found in the cache, the file will not be downloaded
#'     again. If FALSE, all supplied uuids will be re-downloaded.
#'
#' @param progress logical(1) default TRUE in interactive sessions,
#'     FALSE otherwise indicating whether a progress par should be
#'     produced for each file download.
#'
#' @param access_method character(1), either 'api' or 'client'. See details.
#'
#' @param transfer_args character(1), additional arguments to pass to
#'     the gdc-client command line. See \code{\link{gdc_client}} and
#'     \code{\link{transfer_help}} for details.
#' 
#' @param token (optional) character(1) security token allowing access
#'     to restricted data. See
#'     \url{https://gdc-docs.nci.nih.gov/API/Users_Guide/Authentication_and_Authorization/}.
#'
#' @param ... further arguments passed to files
#'
#' @seealso \code{\link{manifest}} for downloading large data.
#'
#' @return a named vector with file uuids as the names and paths as
#' the value
#'
#' @details When access_method is "api", the GDC "data" endpoint is the
#'     transfer mechanism used. The alternative access_method, "client", will
#'     utilize the \code{gdc-client} transfer tool, which must be
#'     downloaded separately and available. See
#'     \code{\link{gdc_client}} for details on specifying the location
#'     of the gdc-client executable.
#'
#' 
#' @examples
#' # get some example file uuids
#' uuids <- files() %>%
#'     filter(~ access == 'open' & file_size < 100000) %>%
#'     results(size = 3) %>%
#'     ids()
#'
#' # and get the data, placing it into the gdc_cache() directory
#' gdcdata(uuids, use_cached=TRUE)
#'
#' @export
gdcdata <-
    function(uuids, use_cached=TRUE,
             progress=interactive(), token=NULL, access_method='api',
             transfer_args = character(), ...)
{
    stopifnot(is.character(uuids))

    uuids = trimws(uuids)
    manifest = files(...) %>%
            GenomicDataCommons::filter( ~ file_id %in% uuids ) %>%
            GenomicDataCommons::manifest()
    # files from previous downloads should have the following
    # path and filenames
    fs = file.path(gdc_cache(), manifest[["id"]], manifest[["file_name"]])

    # Restrict new manifest to those that we need to download,
    to_do_manifest = manifest[!file.exists(fs),]

    # These are the uuids of the cache misses
    missing_uuids = to_do_manifest[["id"]]

    # And these are the cache hits
    names(fs) = manifest[["id"]]

    # Using API download to fetch missing uuids
    endpoint <- "data"
    cache_dir <-  gdc_cache()

    destinations <- file.path(cache_dir, missing_uuids)
    if(access_method == 'api') {
        uris <- sprintf("%s/%s", endpoint, missing_uuids)
        value <- mapply(.gdc_download_one, uris, destinations,
                        MoreArgs=list(overwrite=!use_cached, progress=progress,
                                      token=token),
                        SIMPLIFY=TRUE, USE.NAMES=FALSE)
        names(value) <- missing_uuids
    } else {
        ## in the future, may want to transition to
        ## passing the actual manifest, since we
        ## are going to regenerate it, anyway.
        value = NULL
        if(length(missing_uuids)>0) 
            value = transfer(missing_uuids, token = token, args = transfer_args)
    }

    # combine cache hits with cache misses
    #
    # Return vector of file file path, name=uuid
    fs
}
