#' Bulk data download
#'
#' The GDC maintains a special tool,
#' \href{the GDC Data Transfer Tool}{https://docs.gdc.cancer.gov/Data_Transfer_Tool/Users_Guide/Getting_Started/},
#' that enables high-performance, potentially parallel, and
#' resumable downloads. The Data Transfer Tool is an external
#' program that requires separate download. Due to recent changes in the
#' GDC API, the transfer function now validates the version of the `gdc-client`
#' to ensure reliable downloads.
#'
#' @param uuids character() vector of GDC file UUIDs
#'
#' @param args character() vector specifying command-line arguments to
#'     be passed to \code{gdc-client}. See \code{\link{transfer_help}} for
#'     possible values. The arguments \code{--manifest}, \code{--dir},
#'     and \code{--token-file} are determined by \code{manifest},
#'     \code{destination_dir}, and \code{token}, respectively, and
#'     should NOT be provided as elements of \code{args}.
#'
#' @param token character(1) containing security
#'     token allowing access to restricted data. See
#'     \url{https://gdc-docs.nci.nih.gov/API/Users_Guide/Authentication_and_Authorization/}.
#'     Note that the GDC transfer tool requires a file for data
#'     transfer. Therefore, this token will be written to a temporary
#'     file (with appropriate permissions set).
#'
#' @param overwrite logical(1) default FALSE indicating whether
#'     existing files with identical name should be over-written.
#'
#' @return character(1) directory path to which the files were
#'     downloaded.
#'
#' @examples
#' \dontrun{
#' uuids = files() |> 
#'   filter(access == "open") |> 
#'   results() |>
#'   ids()
#' file_paths <- transfer(uuids)
#' file_paths
#' names(file_paths)
#' # and with authenication
#' # REQUIRES gdc_token 
#' # destination <- transfer(uuids,token=gdc_token())
#' }
#'
#' @importFrom utils read.table
#' @export
transfer <-
    function(uuids, args=character(), token=NULL, overwrite=FALSE)
    {
        stopifnot(is.character(uuids))
        destination_dir <- gdc_cache()

        manifest = files() |>
            GenomicDataCommons::filter( ~ file_id %in% uuids ) |>
            GenomicDataCommons::manifest()
        manifest_file = write_manifest(manifest)
        

        dir_arg <- sprintf("--dir %s", destination_dir)
        manifest_arg <- sprintf("--manifest %s", manifest_file)
        token_file = tempfile()
        if (!is.null(token)) {
            writeLines(token,con=token_file)
            stopifnot(file.exists(token_file))
            Sys.chmod(token_file,mode="600")
            token <- sprintf("--token-file %s", token_file)
        }
        gdc_client_version_validate()
        args <- paste(c("download", dir_arg, manifest_arg, args, token), collapse=" ")
        system2(gdc_client(), args)

        if(!is.null(token))
            unlink(token_file)

        filepaths <- file.path(gdc_cache(), uuids,
                               as.character(manifest[[2]]))
        names(filepaths) = uuids
        return(filepaths)
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
#'
#' @details
#' The path is checked in the following order:
#' \enumerate{
#' \item an R option("gdc_client")
#' \item an environment variable GDC_CLIENT
#' \item from the search PATH
#' \item in the current working directory
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
gdc_client = function() {
    if(!is.null(getOption('gdc_client')))
        if(file.exists(getOption('gdc_client')))
            return(getOption('gdc_client'))
    if(file.exists(Sys.getenv("GDC_CLIENT")))
        return(Sys.getenv("GDC_CLIENT"))
    if(!(Sys.which("gdc-client")==''))
        return(Sys.which("gdc-client"))
    client=dir('.',pattern='^gdc-client$',full.names=TRUE)
    if(length(client)==1)
        if(client=='./gdc-client')
            return(client)
    stop('gdc_client not found. Be sure to install the command \nline GDC client available from the GDC website.')
}

gdc_client_version <- function() {
    gc_loc <- gdc_client()
    vers <- system2(gc_loc, "--version", stdout = TRUE, stderr = TRUE)
    vers <- gsub("^v", "", vers)
    package_version(vers)
}

.GDC_COMPATIBLE_VERSION <- "1.3.0"

#' @describeIn transfer
#'
#' If you are using the 'client' option, your `gdc-client` should be
#' up-to-date (>= 1.3.0).
#'
#' @param valid_version character(1) The last known version that works for the
#'     current data release for which to validate against, not typically changed
#'     by the end-user.
#'
#' @export
gdc_client_version_validate <-
    function(valid_version = .GDC_COMPATIBLE_VERSION)
{
    client_ver <- gdc_client_version()
    if (client_ver < package_version(valid_version))
        stop("Update the 'gdc_client' to a version >= ", valid_version)
}

#' \code{transfer_help()} queries the the command line GDC Data
#' Transfer Tool, \code{gdc-client}, for available options to be used
#' in the \code{\link{transfer}} command.
#'
#' @describeIn transfer
#'
#' @export
transfer_help <- function() {
    system2(gdc_client(), "download -h")
}
