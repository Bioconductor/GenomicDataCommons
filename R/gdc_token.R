#' return a gdc token from file or environment
#' 
#' The GDC requires an auth token for downloading
#' data that are "controlled access". For example, 
#' BAM files for human datasets, germline variant calls,
#' and SNP array raw data all are protected as "controlled
#' access". For these files, a GDC access token is required.
#' See the \href{details on the GDC authentication and token information}{https://docs.gdc.cancer.gov/Data_Portal/Users_Guide/Authentication/#gdc-authentication-tokens}.
#' Note that this function simply returns a string value. 
#' It is possible to keep the GDC token in a variable in R
#' or to pass a string directly to the appropriate parameter.
#' This function is simply a convenience function for alternative 
#' approaches to get a token from an environment variable
#' or a file.  
#' 
#'
#' @details 
#' This function will resolve locations of the GDC token in the 
#' following order:
#' \itemize{
#' \item{from the environment variable, \code{GDC_TOKEN}, expected to 
#' contain the token downloaded from the GDC as a string}
#' \item{using \code{readLines} to read a file named in the environment
#' variable, \code{GDC_TOKEN_FILE}}
#' \item{using \code{readLines} to read from a file called \code{.gdc_token} in the user's
#' home directory}
#' }
#' If all of these fail, this function will return an error.
#' 
#' @return character(1) (invisibly, to protect against inadvertently printing) the GDC token.
#' 
#' @references \url{https://docs.gdc.cancer.gov/Data_Portal/Users_Guide/Authentication/#gdc-authentication-tokens}
#'
#' @examples 
#' # This will not run before a GDC token
#' # is in place.  
#' token = try(gdc_token(),silent=TRUE)
#' 
#'
#' @export
gdc_token <- function() {
  if(Sys.getenv('GDC_TOKEN')!='') return(Sys.getenv('GDC_TOKEN'))
  token_file = "~/.gdc_token"
  if(Sys.getenv('GDC_TOKEN_FILE')!='') 
    token_file = trimws(Sys.getenv('GDC_TOKEN_FILE'))
  stopifnot(file.exists(token_file))
  invisible(suppressWarnings(readLines(token_file,n=1)))
}
