#' Query the GDC for current status
#'
#' @param version (optional) character(1) version of GDC
#'
#' @return List describing current status.
#' @importFrom httr content
#' @export
status <- function(version=NULL) {
    response <- .gdc_get(paste(version, "status", sep="/"))
    content(response, type="application/json")
}
