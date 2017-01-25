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
gdcCases = function(...) {return(query('cases',...))}

#' @describeIn query convenience contructor for a GDCQuery for cases
#' @export
gdcFiles = function(...) {return(query('files',...))}

#' @describeIn query convenience contructor for a GDCQuery for cases
#' @export
gdcProjects = function(...) {return(query('projects',...))}

#' @describeIn query convenience contructor for a GDCQuery for annotations
#' @export
gdcAnnotations = function(...) {return(query('annotations',...))}


#' Get the entity name from a GDCQuery object
#'
#' @param x a \code{\link{GDCQuery}} object
#'
#' @export
entity_name = function(x) {
    cls = class(x)[1]
    return(substr(cls,5,nchar(cls)))
}


#' get the response from server
#'
#' @param x a \code{\link{GDCQuery}} object
#' @param from integer index from which to start returning data
#' @param size number of records to return
#' @param ... passed to httr (good for passing config info, etc.)
#' 
#' @rdname response
#' 
#' @export
response = function(x,...) {
    UseMethod('response',x)
}

count = function(x,...) {
    UseMethod('count',x)
}

count.GDCQuery = function(x) {
    body = Filter(function(z) !is.null(z),x)
    body[['facets']]=paste0(body[['facets']],collapse=",")
    body[['fields']]=paste0(body[['fields']],collapse=",")
    #body = lapply(l,toJSON)
    #names(body) = names(l)
    body[['from']]=1
    body[['size']]=1
    body[['format']]='JSON'
    body[['pretty']]='FALSE'
    httr::content(.gdc_post(entity_name(x),body=body,token=NULL))$data$pagination$total
}    

#' @rdname response
#' 
#' @importFrom magrittr %>%
#' @importFrom magrittr extract
#' @importFrom purrr map map_df
#' 
#' @export
response.GDCQuery = function(x,from=1,size=10,...) {
    body = Filter(function(z) !is.null(z),x)
    body[['facets']]=paste0(body[['facets']],collapse=",")
    body[['fields']]=paste0(body[['fields']],collapse=",")
    #body = lapply(l,toJSON)
    #names(body) = names(l)
    body[['from']]=from
    body[['size']]=size
    body[['format']]='JSON'
    body[['pretty']]='FALSE'
    tmp = httr::content(.gdc_post(entity_name(x),body=body,token=NULL,...))
    list(results = tmp$data$hits,
         query   = x,
         pages   = tmp$data$pagination,
         ### TODO: fix me
         aggregations = lapply(tmp$data$aggregations,function(x) {x$buckets %>% purrr::map_df(extract,c('key','doc_count'))})
         )
}

#' @rdname response
#' 
#' @export
response_all = function(x,...) {
    count = count(x)
    return(response(x,size=count,from=1,...))
}


#' aggregations
#'
#' @param x a \code{\link{GDCQuery}} object
#'
#' @export
aggregations = function(x) {
    if(is.null(x$facets))
        x$facets = subset(mapping(entity_name(x)),defaults)$field
    return(response(x)$aggregations)
}
