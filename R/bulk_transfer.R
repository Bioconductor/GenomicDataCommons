#' Bulk data download
#'
#' The GDC maintains a special tool,
#' \href{the GDC Data Transfer Tool}{https://docs.gdc.cancer.gov/Data_Transfer_Tool/Users_Guide/Getting_Started/},
#' that enables high-performance, potentially parallel, and
#' resumable downloads. The Data Transfer Tool is an external
#' program that requires separate download.
#'
#' @param manifest character(1) file path to manifest created by
#'     \code{manifest()}. See \code{\link{write_manifest}} for
#'     a simple way to create a manifest file from a data.frame
#'     created with \code{\link{manifest}}.
#'
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
#' @param gdc_client character(1) name or path to \code{gdc-client}
#'     executable. On Windows, use \code{/} or \code{\\\\} as the file
#'     separator.
#'
#' @param overwrite logical(1) default FALSE indicating whether
#'     existing files with identical name should be over-written.
#'
#' @return character(1) directory path to which the files were
#'     downloaded.
#'
#' @examples
#' \donttest{
#' file_manifest = files() %>% filter(~ access == "open") %>% manifest(size=10)
#' manifest_file = tempfile()
#' write.table(file_manifest,file=manifest_file,col.names=TRUE,row.names=FALSE,quote=FALSE)
#' destination <- transfer(manifest_file)
#' dir(destination)
#' # and with authenication
#' destination <- transfer(manifest_file,token=gdc_token)
#' }
#'
#' @importFrom utils read.table
#' @export
transfer <-
    function(manifest, args=character(), token=NULL,
             gdc_client="gdc-client", overwrite=FALSE)
    {
        stopifnot(is.character(manifest), length(manifest) == 1L,
                  file.exists(manifest))
        bfc <- .get_cache()
        destination_dir <- bfccache(bfc)
        
        if (!overwrite){
            temptbl <- read.table(manifest, header=TRUE)
            uuids <- as.character(temptbl[,1])
            notfnd <- vapply(uuids, find_help, logical(1), bfc=bfc)
            
            if (all(!notfnd)){
                return(bfccache(bfc))
            }else if (all(notfnd)) {
                manifest <- manifest
            }else{                
                newman <- temptbl[notfnd,]
                write.table(newman, file=manifest,
                            col.names=TRUE,row.names=FALSE,quote=FALSE, sep="\t")
            }            
        }
        
        df <- manifest
        dir <- sprintf("--dir %s", destination_dir)
        manifest <- sprintf("--manifest %s", manifest)
        token_file = tempfile()
        if (!is.null(token)) {
            writeLines(token,con=token_file)
            stopifnot(file.exists(token_file))
            Sys.chmod(token_file,mode="600")
            token <- sprintf("--token-file %s", token_file)
        }
        args <- paste(c("download", dir, manifest, args, token), collapse=" ")
        system2(gdc_client, args)

        if(!is.null(token))
            unlink(token_file)

        temptbl <- read.table(df, header=TRUE)
        uuids <- as.character(temptbl[,1])
        filepaths <- file.path(bfccache(bfc), uuids,
                               as.character(temptbl[,2]))
        rid <- bfcadd(bfc, rname=uuids, fpath=filepaths, action="move")
        unlink(dirname(filepaths), recursive=TRUE)
        bfccache(bfc)
    }

#' \code{transfer_help()} queries the the command line GDC Data
#' Transfer Tool, \code{gdc-client}, for available options to be used
#' in the \code{\link{transfer}} command.
#'
#' @describeIn transfer
#'
#' @export
transfer_help <- function(gdc_client="gdc-client") {
    system2(gdc_client, "download -h")
}

find_help <- function(id, bfc){
    temp <- bfcquery(bfc, id, field="rname")
    return((nrow(temp) == 0))
}
