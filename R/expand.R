#' Return valid values for "expand"
#'
#' The GDC allows a shorthand for specifying groups
#' of fields to be returned by the metadata queries.
#' These can be specified in a \code{\link{select}}
#' method call to easily supply groups of fields.
#'
#' @param entity Either a \code{\link{GDCQuery}} object
#' or a character(1) specifying a GDC entity ('cases', 'files',
#' 'annotations', 'projects')
#'
#' @return A character vector
#' 
#' @seealso See \url{https://docs.gdc.cancer.gov/API/Users_Guide/Search_and_Retrieval/#expand}
#' for details
#'
#' @examples
#' head(available_expand('files'))
#'
#' @export
available_expand <- function(entity) {
    UseMethod("available_expand",entity)
}   

#' @rdname available_expand
#'
#' @export
available_expand.character <- function(entity) {
    json = .get_mapping_json(entity)
    return(unlist(json[['expand']]))
}

#' @rdname available_expand
#'
#' @export
available_expand.GDCQuery <- function(entity) {
    return(available_expand(entity_name(entity)))
}

#" (internal) check expand values
.gdcCheckExpands <- function(entity,expand) {
    if(is.null(expand)) return(TRUE)
    stopifnot(entity %in% .gdc_entities)
    ae = available_expand(entity)
    mismatches = expand[!(expand %in% ae)]
    if(length(mismatches)>0)
        stop(sprintf('expand specified included expands not available in %s including (%s)',entity,mismatches))
    return(TRUE)
}

#' Set the \code{expand} parameter
#'
#' S3 generic to set GDCQuery expand parameter
#'
#' @param x the objects on which to set fields
#' @param expand a character vector specifying the fields
#' 
#'
#' @return A \code{\link{GDCQuery}} object, with the \code{expand}
#' member altered.
#' 
#' @examples
#' gProj = projects()
#' gProj$fields
#' head(available_fields(gProj))
#' default_fields(gProj)
#'
#' gProj %>%
#'   select(default_fields(gProj)[1:2]) %>%
#'   response() %>%
#'   str(max_level=2)
#' 
#' @export
expand <- function(x,expand) {
    UseMethod('expand',x)
}



#' @describeIn expand set expand fields on a GDCQuery object
#' @export
expand.GDCQuery <- function(x,expand) {
    .gdcCheckExpands(entity_name(x),expand)
    x$expand = expand
    return(x)
}

#' @export
expand.default <- function(x, ...) {
    tidyr::expand(x, ...)
}
