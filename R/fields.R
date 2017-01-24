#' S3 Generic to return all GDC fields
#'
#' @param x A character string ('cases','files','projects',
#' 'annotations') or an subclass of \code{\link{GDCQuery}}.
#' @return a character vector of the default fields
#'
#' @examples
#' gdcAvailableFields('projects')
#' projQuery = gdcQuery('projects')
#' gdcAvailableFields(projQuery)
#' 
#' @export
gdcAvailableFields = function(x) {
    UseMethod('gdcAvailableFields',x)
}

#' @describeIn gdcAvailableFields GDCQuery method
#' @export
gdcAvailableFields.GDCQuery = function(x) {
    return(mapping(gdcEntityName(x))$field)
}

#' @describeIn gdcAvailableFields character method
#' @export
gdcAvailableFields.character = function(x) {
    stopifnot(length(x)==1)
    return(mapping(x)$field)
}


#' S3 Generic to return default GDC fields
#'
#' @param x A character string ('cases','files','projects',
#' 'annotations') or an subclass of \code{\link{GDCQuery}}.
#' @return a character vector of the default fields
#'
#' @examples
#' gdcDefaultFields('projects')
#' projQuery = gdcQuery('projects')
#' gdcDefaultFields(projQuery)
#' 
#' @export
gdcDefaultFields = function(x) {
    UseMethod('gdcDefaultFields',x)
}

#' @describeIn gdcDefaultFields character method
#' @export
gdcDefaultFields.character = function(x) {
    stopifnot(length(x)==1)
    return(subset(mapping(x),defaults)$field)
}

#' @describeIn gdcDefaultFields GDCQuery method
#' @export
gdcDefaultFields.GDCQuery = function(x) {
    return(gdcDefaultFields(gdcEntityName(x)))
}

#' S3 generic to set GDCQuery fields
#'
#' @param x the objects on which to set fields
#' @param fields a character vector specifying the fields
#' 
#' @importFrom assertthat assert_that
#'
#' @export
gdcSetFields <- function(x,fields) {
    UseMethod('gdcSetFields',x)
}

#' rectify specified fields with available fields
#'
.gdcRectifyFieldsForEntity <- function(entity,fields) {
    stopifnot(entity %in% .gdc_entities)
    af = gdcAvailableFields(entity)
    mismatches = fields[!(fields %in% af)]
    if(length(mismatches)>0)
        stop(sprintf('fields specified included fields not available in %s including (%s)',entity,mismatches))
    fields = union(paste0(entity,"_id"),fields)
    return(fields)
}

#' @describeIn gdcSetFields set fields on a GDCQuery object
gdcSetFields.GDCQuery <- function(x,fields) {
    x$fields = .gdcRectifyFieldsForEntity(gdcEntityName(x),fields)
    return(x)
}

