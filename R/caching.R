#' Work with gdc cache directory
#'
#' The GenomicDataCommons package will cache downloaded
#' files to minimize network and allow for
#' offline work. These functions are used to create a cache directory
#' if one does not exist, set a global option, and query that
#' option. The cache directory will default to the user "cache"
#' directory according to specifications in
#' \code{\link[rappdirs]{app_dir}}. However, the user may want to set
#' this to another direcotory with more or higher performance
#' storage. 
#'
#' @return character(1) directory path that serves as
#' the base directory for GenomicDataCommons downloads.
#'
#' @details
#' The cache structure is currently just a directory with each file
#'     being represented by a path constructed as:
#'     CACHEDIR/UUID/FILENAME. The cached files can be manipulated
#'     using standard file system commands (removing, finding,
#'     etc.). In this sense, the cache sytem is minimalist in design.
#' 
#' @examples
#' gdc_cache()
#' \dontrun{
#' gdc_set_cache(getwd())
#' }
#' 
#' @export
gdc_cache = function()
{
    cache_dir = getOption('gdc_cache',gdc_set_cache(verbose=FALSE))
    if(!dir.exists(cache_dir)) {
        gdc_set_cache(cache_dir)
    }
    return(cache_dir)
}

#' @describeIn gdc_cache (Re)set the GenomicDataCommons cache
#'     directory
#' 
#' @importFrom utils menu
#' @importFrom rappdirs app_dir
#'
#'
#' @param create_without_asking logical(1) specifying whether to allow
#'     the function to create the cache directory without asking the
#'     user first. In an interactive session, if the cache directory
#'     does not exist, the user will be prompted before creation.
#'
#' @param verbose logical(1) whether or not to message the location of
#'     the cache directory after creation.
#'
#' @param directory character(1) directory path, will be created
#'     recursively if not present.
#'
#'
#' @return the created directory (invisibly)
#' 
#' @export
gdc_set_cache = function(directory = rappdirs::app_dir(appname =
                                                           "GenomicDataCommons")$cache(),
                         verbose = TRUE,
                         create_without_asking = !interactive())
{

    create_path = function(directory) {
        dir.create(directory, recursive = TRUE, showWarnings =
                                                    FALSE)
    }
    
    if(is.character(directory) & length(directory)==1) {
        # if directory exists, move on
        if(!dir.exists(directory)) {
            # if not in an interactive session, go
            # ahead and create directory without user
            # input.
            if(create_without_asking) {
                create_path(directory)
            } else {
                # If in an interactive environment,
                # go ahead and ask user for agreement.
                response = menu(c("Yes", "No"),
                                title=sprintf("Would you like to create a GDC Cache directory at %s", directory))
                if(response == 1) {
                    create_path(directory)
                } else {
                    stop("GDC Cache directory cannot be created without user agreement")
                }
            }
        }
        options('gdc_cache' = directory)
    } else {
        stop("directory should be a character(1)")
    }
    if(verbose) message("GDC Cache directory set to: ", directory)
    invisible(directory)
}
