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
#' qcases = cases()
#' qprojects = projects()
#' 
#' entity_name(qcases)
#' entity_name(qprojects)
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



