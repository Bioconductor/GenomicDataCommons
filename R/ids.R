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
#' ids(cases() %>% filter(~ project.project_id == "TCGA-CHOL"))
#' # also works for responses
#' ids(response(files()))
#' # and results
#' ids(results(cases()))
#'
#' 
#' @export
ids = function(x) {
    UseMethod('ids',x)
}




#' @rdname ids
#' @export
ids.GDCQuery = function(x) {
    fieldname = .id_field(x)
    res = x %>% GenomicDataCommons::select(fieldname) %>%
        results_all()
    return(.ifNullCharacterZero(res[[fieldname]]))
}


#' @rdname ids
#' @export
ids.GDCResults = function(x) {
    fieldname = .id_field(x)
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

.id_field = function(x) {
    return(paste0(sub('s$','',entity_name(x)),"_id"))
}

#' get the name of the id field
#' 
#' In many places in the GenomicDataCommons package,
#' the entity ids are stored in a column or a vector
#' with a specific name that corresponds to the field name 
#' at the GDC. The format is the entity name (singular) "_id".
#' This generic simply returns that name from a given object.
#' 
#' @param x An object representing the query or results 
#'     of an entity from the GDC ("cases", "files", "annotations", "projects")
#' 
#' @return character(1) such as "case_id", "file_id", etc.
#' 
#' @examples 
#' id_field(cases())
#' 
#' @export
id_field = function(x) {
    UseMethod('id_field',x)
}

#' @describeIn id_field GDCQuery method
#' @export
id_field.GDCQuery = function(x) {
    return(.id_field(x))
}

#' @describeIn id_field GDCResults method
#' @export
id_field.GDCResults = function(x) {
    return(.id_field(x))
}


