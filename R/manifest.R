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
    body[['return_type']]='manifest'
    tmp = httr::content(.gdc_post(entity_name(x), body=body, archive=x$archive, token=NULL, ...))
    tmp = readr::read_tsv(tmp)
    structure(
        tmp,
        class = c('GDCManifest',class(tmp))
    )
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
    stopifnot(colnames(manifest) %in% .gdc_manifest_colnames,
              ncol(manifest) == 5)
    write.table(manifest,file=destfile,sep="\t",
                col.names=TRUE,row.names=FALSE,quote=FALSE)
    destfile
}

#' return gdc-client executable path
#' 
#' This function is a convenience function to 
#' find and return the path to the GDC Data Transfer
#' Tool executable assumed to be named 'gdc-client'. 
#' The assumption is that the appropriate version of the
#' GDC Data Transfer Tool is a separate download available
#' from \href{the GDC website}{https://gdc.cancer.gov/access-data/gdc-data-transfer-tool}
#' and as a backup from \href{on github}{https://github.com/NCI-GDC/gdc-client}.
#' The following locations are checked:
#' 
#' \itemize{
#' \item{Sys.which() to see if gdc-client is on the path}
#' \item{The current working directory}
#' \item{The file name specified in the environment variable \code{GDC_CLIENT}}
#' }
#' 
#' @return character(1) the path to the gdc-client executable.
#'
#' @examples
#' # this cannot run without first
#' # downloading the GDC Data Transfer Tool
#' gdc_client = try(gdc_client(),silent=TRUE)
#' 
#' @export
gdc_client <- function() {
    client = Sys.which('gdc-client')
    if(basename(client['gdc-client'])=="gdc-client") 
        return(client)
    client=dir('.',pattern='^gdc-client$',full.names=TRUE)
    if(length(client)==1) 
        if(client=='./gdc-client')
            return(client)
    if(file.exists(Sys.getenv('GDC_CLIENT')))
        return(Sys.getenv('GDC_CLIENT'))
    stop('gdc-client not found')
}

