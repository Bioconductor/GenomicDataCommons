#' Set facets for a \code{\link{GDCQuery}}
#'
#' @param x a \code{\link{GDCQuery}} object
#' @param facets a character vector of fields that
#' will be used for forming aggregations (facets).
#' Default is to set facets for all default fields.
#' See \code{\link{default_fields}} for details
#'
#' @return returns a \code{\link{GDCQuery}} object,
#' with facets field updated.
#' 
#' @rdname faceting
#'
#' @examples
#' # create a new GDCQuery against the projects endpoint
#' gProj = projects()
#'
#' # default facets are NULL
#' get_facets(gProj)
#'
#' # set facets and save result
#' gProjFacet = facet(gProj)
#'
#' # check facets
#' get_facets(gProjFacet)
#' 
#' # and get a response, noting that
#' # the aggregations list member contains
#' # tibbles for each facet
#' str(response(gProjFacet,size=2),max.level=2)
#' 
#' @export
facet = function(x,facets) {
    UseMethod('facet',x)
}


#' @export
facet.GDCQuery = function(x,facets=default_fields(x)) {
    x$facets = facets
    return(x)
}

#' Get facets for a \code{\link{GDCQuery}}
#'
#' @rdname faceting
#' 
#' @export
get_facets = function(x) {
    UseMethod('get_facets',x)
}

#' @rdname faceting
#'
#' @export
get_facets.GDCQuery = function(x) {
    return(x$facets)
}
