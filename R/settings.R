#' Settings for the GenomicDataCommons package
#' 
#' @importFrom rappdirs app_dir
#' 
#' @rdname settings
#' 
#' @export
cache_dir <- function() {
    getOption('gdc_cache_dir',set_cache_dir())
}


#' @describeIn settings
#' @export
set_cache_dir <- function(dir = app_dir("GenomicDataCommons")) {
    dir.create(dir, recursive = TRUE)
    options(gdc_cache_dir = dir)
    invisible(dir)
}