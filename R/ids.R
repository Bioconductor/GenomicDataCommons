#' Get the ids associated with a GDC query or response
#'
#' The GDC assigns ids (in the form of uuids) to objects in its database. Those
#' ids can be used for relationships, searching on the website, and as
#' unique ids.  All 
#'
#' @param x A \code{\link{GDCQuery}} or \code{\link{GDCResponse}} object
#'
#' @return a character vector of all the entity ids
#'
#' @examples
#' # use with a GDC query, in this case for "cases"
#' ids(cases())
#' # also works for responses
#' ids(response(files()))
#'
#' 
#' @export
ids = function(x) {
    UseMethod('ids',x)
}




#' @rdname ids
#' @export
ids.GDCQuery = function(x) {
    fieldname = paste0(sub('s$','',entity_name(x)),'_id')
    res = results(x)[[fieldname]]
    return(.ifNullCharacterZero(res))
}


#' @rdname ids
#' @export
ids.GDCResults = function(x) {
    fieldname = paste0(sub('s$','',entity_name(x)),'_id')
    res = x[[fieldname]]
    return(.ifNullCharacterZero(res))
}

#' @rdname ids
#' @export
ids.GDCResponse = function(x) {
    fieldname = paste0(sub('s$','',entity_name(x$query)),'_id')
    res = results(x)[[fieldname]]
    return(.ifNullCharacterZero(res))
}
