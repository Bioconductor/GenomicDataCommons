#' Get the entity name from a GDCQuery object
#'
#' An "entity" is simply one of the four medata endpoints.
#' \itemize{
#' \item{cases}
#' \item{projects}
#' \item{files}
#' \item{annotations}
#' }
#' All \code{\link{GDCQuery}} objects will have an entity name. This S3 method
#' is simply a utility accessor for those names.
#' 
#' @param x a \code{\link{GDCQuery}} object
#'
#' @return character(1) name of an associated entity; one of
#' "cases", "files", "projects", "annotations".
#' 
#' @examples
#' cases = cases()
#' projects = projects()
#' 
#' entity_name(cases)
#' entity_name(projects)
#' 
#' @export
entity_name = function(x) {
    UseMethod('entity_name',x)
}


#' @rdname entity_name
#' @export
entity_name.GDCQuery = function(x) {
    cls = class(x)[1]
    return(substr(cls,5,nchar(cls)))
}

#' @rdname entity_name
#' @export
entity_name.GDCResults = function(x) {
    cls = class(x)[1]
    return(substr(cls,4,nchar(cls)-8))
}


#' return character(0) instead of NULL
#'
#' Always return a vector and not
#' NULL.
#'
#' @param x an object
#' 
.ifNullCharacterZero <- function(x) {
    if(is.null(x))
        return(character(0))
    return(x)
}

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
