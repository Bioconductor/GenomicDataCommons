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
#' 
#' @export
manifest <- function(x,from=0,size=count(x),...) {
    UseMethod('manifest',x)
}

#' @describeIn manifest
#'
#' @export
manifest.gdc_files <- function(x,from=0,size=count(x),...) {
    .manifestCall(x=x,from=from,size=size,...)
}

#' @describeIn manifest
#'
#' @export
manifest.GDCfilesResponse <- function(x,from=0,size=count(x),...) {
    .manifestCall(x=x$query,from=from,size=size,...)
}

#' @describeIn manifest
#'
#' @export
manifest.GDCcasesResponse <- function(x,from=0,size=count(x),...) {
    manifest(x=x$query,from=from,size=size,...)
}



#' @importFrom readr read_tsv 
.manifestCall <- function(x,from=0,size=count(x),...) {
    body = Filter(function(z) !is.null(z),x)
    body[['facets']]=NULL
    body[['fields']]=paste0(default_fields(x),collapse=",")
    body[['from']]=from
    body[['size']]=size
    # remove return_type for now
    # body[['return_type']]='manifest'
    legacy = x$legacy
    if (is.logical(legacy))
        .Defunct(
            msg = paste0("The 'legacy' argument is defunct.\n",
            "See help(\"GDC-defunct\")")
        )
    tmp <- httr::content(
        .gdc_post(entity_name(x), body=body, token=NULL, ...),
        as = "text", encoding = "UTF-8"
    )
    tmp <- jsonlite::fromJSON(tmp)[["data"]][["hits"]]
    if ("acl" %in% names(tmp))
        tmp <- tidyr::unnest_wider(data = tmp, col = "acl", names_sep = "_")
    if(ncol(tmp)<5) {
        tmp=data.frame()
    }
    class(tmp) <- c('GDCManifest',class(tmp))
    return(tmp)
}

#' write a manifest data.frame to disk
#' 
#' The \code{\link{manifest}} method creates a data.frame
#' that represents the data for a manifest file needed
#' by the GDC Data Transfer Tool. While the file format
#' is nothing special, this is a simple helper function
#' to write a manifest data.frame to disk. It returns
#' the path to which the file is written, so it can
#' be used "in-line" in a call to \code{\link{transfer}}.
#' 
#' @param manifest A data.frame with five columns, typically
#'     created by a call to \code{\link{manifest}}
#' 
#' @param destfile The filename for saving the manifest.
#'          
#' @return character(1) the destination file name.
#'
#' @importFrom utils write.table
#' 
#' @examples
#' mf = files() %>% manifest(size=10)
#' write_manifest(mf)
#' 
#' @export
write_manifest <- function(manifest,destfile=tempfile()) {
    stopifnot(
        all(.gdc_manifest_colnames %in% colnames(manifest)),
        ncol(manifest) > 5
    )
    write.table(manifest,file=destfile,sep="\t",
                col.names=TRUE,row.names=FALSE,quote=FALSE)
    destfile
}

