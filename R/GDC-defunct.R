#' @name GDC-defunct
#'
#' @title Defunct functionality in the `GenomicDataCommons` package
#'
#' @aliases legacy legacy.GDCQuery
#' 
#' @description
#' The `legacy` endpoint was removed after the GDC API release version
#' `v3.28.0`. This means that legacy data is no longer available via the
#' GDC API. The `legacy` features in the `GenomicDataCommons` package are
#' defunct.
#' 
#' @details
#' This includes the S3 generic and method for setting the legacy parameter
#' (`legacy` and `legacy.GDCQuery`)
#' 
#' @param x the objects on which to set fields
#'
#' @param legacy logical(1) DEFUNCT; no longer in use.
#' 
#' @return An error. This feature is no longer used.
#' 
#' @seealso
#'   \url{https://docs.gdc.cancer.gov/API/Release_Notes/API_Release_Notes/#v3280}
#' 
#' @examples
#' qcases <- query("cases")
#' @export
legacy <- function(x, legacy) {
    UseMethod('legacy')
}

#' @describeIn GDC-defunct set legacy field on a GDCQuery object
#' @export
legacy.GDCQuery <- function(x, legacy) {
    if (!missing(legacy))
        .Defunct(
            msg = paste0("The 'legacy' argument is defunct.\n",
            "See help(\"GDC-defunct\")")
        )
    return(x)
}
