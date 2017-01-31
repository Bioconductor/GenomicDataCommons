#' Start a query of GDC metadata
#'
#' The basis for all functionality in this package
#' starts with constructing a query in R. The GDCQuery
#' object contains the filters, facets, and other
#' parameters that define the returned results. A token
#' is required for accessing certain datasets.
#'
#' @aliases GDCQuery
#' 
#' @param entity character vector of 'cases','files','annotations',
#' or 'projects'
#' @param filters a filter list
#' @param facets a facets list
#' @param token a character string reprenting the token
#' @param fields a list of fields to return
#' 
#' @return An S3 object, the GDCQuery object. This is a list
#' with filters, facets, and fields as members.
#' \itemize{
#' \item{filters}
#' \item{facets}
#' \item{fields}
#' \item{token}
#' }
#'
#' @export
query = function(entity,
                    token=NULL,
                    filters=NULL,
                    facets=NULL,
                    fields=default_fields(entity)) {
    stopifnot(entity %in% c('cases','files','annotations','projects'))
    ret = structure(
        list(
            fields    = fields,
            filters   = filters,
            facets    = facets,
            token     = token),
        class = c(paste0('gdc_',entity),'GDCQuery','list')
    )
    return(ret)
}


#' @describeIn query convenience contructor for a GDCQuery for cases
#' @param ... passed through to \code{\link{query}}
#' 
#' @export
cases = function(...) {return(query('cases',...))}

#' @describeIn query convenience contructor for a GDCQuery for cases
#' @export
files = function(...) {return(query('files',...))}

#' @describeIn query convenience contructor for a GDCQuery for cases
#' @export
projects = function(...) {return(query('projects',...))}

#' @describeIn query convenience contructor for a GDCQuery for annotations
#' @export
annotations = function(...) {return(query('annotations',...))}


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
#' @examples
#' cases = cases()
#' projects = projects()
#' 
#' entity_name(cases)
#' entity_name(projects)
#' 
#' @export
entity_name = function(x) {
    cls = class(x)[1]
    return(substr(cls,5,nchar(cls)))
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
    return(sapply(results(x),'[[',fieldname))
}

#' @rdname ids
#' @export
ids.GDCResponse = function(x) {
    fieldname = paste0(sub('s$','',entity_name(x$query)),'_id')
    return(sapply(results(x),'[[',fieldname))
}
