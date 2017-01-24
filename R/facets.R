#' Set facets for a \code{\link{GDCQuery}}
#'
#' @param x a \code{\link{GDCQuery}} object
#' @param facets a character vector of fields that
#' will be used for forming aggregations (facets).
#' Default is to set facets for all default fields.
#' See \code{\link{gdcDefaultFields}} for details
#'
#' @rdname faceting
#' 
#' @export
gdcSetFacet = function(x,facets) {
    UseMethod('facet',x)
}


#' @export
gdcSetFacet.GDCQuery = function(x,facets=default_fields(x)) {
    x$facets = facets
    return(x)
}



#' Get facets for a \code{\link{GDCQuery}}
#'
#' @rdname faceting
#' 
#' @export
gdcGetFacet = function(x) {
    UseMethod('gdcGetFacet',x)
}

#' @rdname faceting
#'
#' @export
gdcGetFacet.GDCQuery = function(x) {
    return(x$facets)
}
