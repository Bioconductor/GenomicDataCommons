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
#' @param entity character vector, including one of the entities in .gdc_entities
#' @param filters a filter list, typically created using \code{\link{make_filter}}, or added
#'     to an existing \code{GDCQuery} object using \code{\link{filter}}.
#' @param facets a character vector of facets for counting common values. 
#'     See \code{\link{available_fields}}. In general, one will not specify this parameter
#'     but will use \code{\link{facet}} instead.
#' @param legacy logical(1) DEFUNCT; no longer in use.
#' @param fields a character vector of fields to return. See \code{\link{available_fields}}.
#'     In general, one will not specify fields directly, but instead use \code{\link{select}}
#' @param expand a character vector of "expands" to include in returned data. See 
#'     \code{\link{available_expand}}
#' 
#' @return An S3 object, the GDCQuery object. This is a list
#' with the following members.
#' \itemize{
#' \item{filters}
#' \item{facets}
#' \item{fields}
#' \item{expand}
#' \item{archive}
#' \item{token}
#' }
#'
#' @examples
#' qcases = query('cases')
#' # equivalent to:
#' qcases = cases()
#' 
#' @export
query = function(entity,
                 filters=NULL,
                 facets=NULL,
                 expand = NULL,
                 fields=default_fields(entity),
                 ...,
                 legacy)
{
    stopifnot(entity %in% .gdc_entities)
    if (!missing(legacy))
        .Defunct(
            msg = paste0("The 'legacy' argument is defunct.\n",
            "See help(\"GDC-defunct\")")
        )
    ret = structure(
        list(
            fields    = fields,
            filters   = filters,
            facets    = facets,
            expand    = expand),
        class = c(paste0('gdc_',entity),'GDCQuery','list')
    )
    return(ret)
}


#' @describeIn query convenience constructor for a GDCQuery for cases
#'
#' @param ... passed through to \code{\link{query}}
#' 
#' @export
cases = function(...) {return(query('cases',...))}

#' @describeIn query convenience contructor for a GDCQuery for files
#' @export
files = function(...) {return(query('files',...))}

#' @describeIn query convenience contructor for a GDCQuery for projects
#' @export
projects = function(...) {return(query('projects',...))}

#' @describeIn query convenience contructor for a GDCQuery for annotations
#' @export
annotations = function(...) {return(query('annotations',...))}

#' @describeIn query convenience contructor for a GDCQuery for ssms
#' @export
ssms = function(...) {return(query("ssms", ...))}

#' @describeIn query convenience contructor for a GDCQuery for ssm_occurrences
#' @export
ssm_occurrences = function(...) {return(query("ssm_occurrences", ...))}

#' @describeIn query convenience contructor for a GDCQuery for cnvs
#' @export
cnvs = function(...) {return(query("cnvs", ...))}

#' @describeIn query convenience contructor for a GDCQuery for cnv_occurrences
#' @export
cnv_occurrences = function(...) {return(query("cnv_occurrences", ...))}

#' @describeIn query convenience contructor for a GDCQuery for genes
#' @export
genes = function(...) {return(query("genes", ...))}
