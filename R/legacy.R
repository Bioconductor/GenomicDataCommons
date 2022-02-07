#' Set the \code{legacy} parameter
#'
#' S3 generic to set GDCQuery legacy parameter
#'
#' @param x the objects on which to set fields
#' @param legacy logical(1) Whether or not to use the GDC legacy archives
#' 
#'
#' @return A \code{\link{GDCQuery}} object with the \code{legacy}
#' member altered.
#' 
#' @examples
#' qcases <- query("cases")
#'
#' legacy(qcases, legacy = FALSE)
#' 
#' @export
legacy <- function(x, legacy) {
    UseMethod('legacy')
}

#' @describeIn legacy set legacy field on a GDCQuery object
#' @export
legacy.GDCQuery <- function(x, legacy) {
    stopifnot(is.logical(legacy), length(legacy) == 1L, !is.na(legacy))
    x$legacy <- legacy
    return(x)
}
