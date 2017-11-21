#' Work with gdc cache directory
#'
#' The GenomicDataCommons package will cache downloaded
#' files to minimize network and allow for
#' offline work. These functions 
#' 
#'
#' @param directory character(1) directory path, will be
#' created recursively if not present.
#' 
#' @return character(1) directory path that serves as
#' the base directory for GenomicDataCommons downloads.
#' 
#' @importFrom rappdirs app_dir
#' 
#' @examples
#' gdc_cache()
#' \dontrun{
#' gdc_set_cache(getwd())
#' }
#' 
#' @export
gdc_cache = function(directory = NULL)
{
    return(getOption('gdc_cache',rappdirs::app_dir(appname = "GenomicDataCommons")$cache()))
}

#' @describeIn gdc_cache (Re)set the GenomicDataCommons cache directory
#' @export
gdc_set_cache = function(directory)
{
    if(is.character(directory) & length(directory)==1) {
        dir.create(directory, recursive = TRUE, showWarnings = FALSE)
        options('gdc_cache' = directory)
    } else {
        stop("directory should be a character(1)")
    }
    invisible(directory)
}
