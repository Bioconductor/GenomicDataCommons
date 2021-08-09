#' S3 Generic to return all GDC fields
#'
#' @param x A character(1) string ('cases','files','projects',
#' 'annotations') or an subclass of \code{\link{GDCQuery}}.
#' @return a character vector of the default fields
#'
#' @examples
#' available_fields('projects')
#' projQuery = query('projects')
#' available_fields(projQuery)
#' 
#' @export
available_fields = function(x) {
    UseMethod('available_fields',x)
}

#' @describeIn available_fields GDCQuery method
#' @export
available_fields.GDCQuery = function(x) {
    return(mapping(entity_name(x))$field)
}

#' @describeIn available_fields character method
#' @export
available_fields.character = function(x) {
    stopifnot(length(x)==1,x %in% .gdc_entities)
    return(mapping(x)$field)
}


#' S3 Generic to return default GDC fields
#'
#' @param x A character string ('cases','files','projects',
#' 'annotations') or an subclass of \code{\link{GDCQuery}}.
#' @return a character vector of the default fields
#'
#' @examples
#' default_fields('projects')
#' projQuery = query('projects')
#' default_fields(projQuery)
#' 
#' @export
default_fields = function(x) {
    UseMethod('default_fields',x)
}

#' @describeIn default_fields character method
#' @export
default_fields.character = function(x) {
    defaults=NA # just to avoid no visible binding note
    stopifnot(length(x)==1,x %in% .gdc_entities)
    return(subset(mapping(x),defaults)$field)
}

#' @describeIn default_fields GDCQuery method
#' @export
default_fields.GDCQuery = function(x) {
    return(default_fields(entity_name(x)))
}

#' S3 generic to set GDCQuery fields
#'
#' @param x the objects on which to set fields
#' @param fields a character vector specifying the fields
#' 
#'
#' @return A \code{\link{GDCQuery}} object, with the fields
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
select <- function(x,fields) {
    UseMethod('select',x)
}



#" (internal) rectify specified fields with available fields
.gdcRectifyFieldsForEntity <- function(entity,fields) {
    af = available_fields(entity)
    mismatches = fields[!(fields %in% af)]
    if(length(mismatches)>0)
        stop(sprintf('fields specified included fields not available in %s including (%s)',entity,mismatches))
    fields = union(paste0(sub('s$','',entity),"_id"),fields)
    return(fields)
}

#' @describeIn select set fields on a GDCQuery object
#' @export
select.GDCQuery <- function(x,fields) {
    x$fields = .gdcRectifyFieldsForEntity(entity_name(x),fields)
    return(x)
}

#' Find matching field names
#' 
#' This utility function allows quick text-based search of available
#' fields for using \code{\link{grep}}
#' 
#' @param entity one of the available gdc entities ('files','cases',...)
#'     against which to gather available fields for matching
#' 
#' @param pattern A regular expression that will be used
#' in a call to \code{\link{grep}}
#' 
#' @param ... passed on to grep
#' 
#' @param value logical(1) whether to return values as opposed
#' to indices (passed along to grep)
#'
#' @return character() vector of field names matching
#'     \code{pattern}
#' 
#' @examples 
#' grep_fields('files','analysis')
#' 
#' @export
grep_fields <- function(entity,pattern,...,value=TRUE) {
  stopifnot(entity %in% .gdc_entities)
  return(grep(pattern=pattern,
              x=available_fields(entity),
              value=TRUE,...))
}

#' Find common values for a GDC field
#' 
#' @param entity character(1), a GDC entity ("cases", "files", "annotations", "projects")
#' @param field character(1), a field that is present in the entity record
#' @param legacy logical(1), use the legacy endpoint or not.
#' 
#' @return character vector of the top 100 (or fewer) most frequent
#'     values for a the given field
#' 
#' @examples 
#' available_values('files','cases.project.project_id')[1:5]
#' 
#' @export
available_values <- function(entity,field,legacy=FALSE) {
    stopifnot(entity %in% .gdc_entities)
    agg = query(entity,legacy=legacy) %>% facet(field) %>% aggregations()
    agg[[field]]$key
}

#' S3 Generic that returns the field description text, if available
#'
#' @param entity character(1) string ('cases','files','projects',
#' 'annotations', etc.) or an subclass of \code{\link{GDCQuery}}.
#'
#' @param field character(1), the name of the field that will be used to look
#' up the description.
#' 
#' @return character(1) descriptive text or character(0) if no description
#' is available.
#'
#' @examples
#' field_description('cases', 'annotations.category')
#' casesQuery = query('cases')
#' field_description(casesQuery, 'annotations.category')
#' field_description(cases(), 'annotations.category')
#' 
#' @export
field_description = function(entity, field) {
    UseMethod('field_description',entity)
}

#' @describeIn field_description GDCQuery method
#' @export
field_description.GDCQuery = function(entity, field) {
    stopifnot(length(field)==1)
    m = mapping(entity_name(entity))
    return(m$description[m$field==field])
}

#' @describeIn field_description character method
#' @export
field_description.character = function(entity, field) {
    stopifnot(length(entity)==1,entity %in% .gdc_entities)
    stopifnot(length(field)==1)
    m = mapping(entity)
    return(m$description[m$field==field])
}
