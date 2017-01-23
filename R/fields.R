#' S3 Generic to return all GDC fields
#'
#' @param x A character string ('cases','files','projects',
#' 'annotations') or an subclass of \code{\link{gdcQuery-class}}.
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
gdcAvailableFields.GDCQuery = function(x) {
    return(mapping(gdcEntityName(x))$field)
}

#' @describeIn gdcAvailableFields character method
gdcAvailableFields.character = function(x) {
    stopifnot(length(x)==1)
    return(mapping(x)$field)
}


#' S3 Generic to return default GDC fields
#'
#' @param x A character string ('cases','files','projects',
#' 'annotations') or an subclass of \code{\link{gdcQuery-class}}.
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
gdcDefaultFields.character = function(x) {
    stopifnot(length(x)==1)
    return(subset(mapping(x),defaults)$field)
}

#' @describeIn gdcDefaultFields GDCQuery method
gdcDefaultFields.GDCQuery = function(x) {
    return(gdcDefaultFields(gdcEntityName(x)))
}

#' S3 generic to set GDCQuery fields
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
    
    
