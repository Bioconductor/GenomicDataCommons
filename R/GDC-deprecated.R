#' @name GDC-deprecated
#'
#' @title Deprecated functionality in the `GenomicDataCommons` package
#'
#' @aliases legacy legacy.GDCQuery
#' 
#' @description
#' The `legacy` endpoint was deprecated as part of the GDC API release version
#' `v3.28.0`. This means that legacy data is no longer available via the
#' GDC API.
#' 
#' @details
#' This includes the S3 generic and method for setting the legacy parameter
#' (`legacy` and `legacy.GDCQuery`)
#' 
#' @param x the objects on which to set fields
#'
#' @param legacy logical(1) DEPRECATED; Whether or not to use the GDC legacy
#'   archives
#' 
#' @return A \code{\link{GDCQuery}} object with the \code{legacy}
#' member altered.
#' 
#' @seealso
#'   \url{https://docs.gdc.cancer.gov/API/Release_Notes/API_Release_Notes/#v3280}
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

#' @describeIn GDC-deprecated set legacy field on a GDCQuery object
#' @export
legacy.GDCQuery <- function(x, legacy) {
    stopifnot(is.logical(legacy), length(legacy) == 1L, !is.na(legacy))
    if (legacy)
        .Deprecated(
            msg = paste0("The 'legacy' argument is deprecated.\n",
            "See help(\"GDC-deprecated\")")
        )
    return(x)
}
