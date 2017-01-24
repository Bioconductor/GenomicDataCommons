#' Construct a GDCQuery
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
#'
#' @export
gdcQuery = function(entity,
                    token=NULL,
                    filters=NULL,
                    facets=NULL,
                    fields=subset(mapping(entity),defaults)$field) {
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


#' @describeIn gdcQuery convenience contructor for a GDCQuery for cases
#' @param ... passed through to \code{\link{gdcQuery}}
#' 
#' @export
gdcCases = function(...) {return(gdcQuery('cases',...))}

#' @describeIn gdcQuery convenience contructor for a GDCQuery for cases
#' @export
gdcFiles = function(...) {return(gdcQuery('files',...))}

#' @describeIn gdcQuery convenience contructor for a GDCQuery for cases
#' @export
gdcProjects = function(...) {return(gdcQuery('projects',...))}

#' @describeIn gdcQuery convenience contructor for a GDCQuery for annotations
#' @export
gdcAnnotations = function(...) {return(gdcQuery('annotations',...))}


#' Get the entity name from a GDCQuery object
#'
#' @param x a \code{\link{GDCQuery}} object
#'
#' @export
gdcEntityName = function(x) {
    cls = class(x)[1]
    return(substr(cls,5,nchar(cls)))
}

facet = function(x,...) {
    UseMethod('facet',x)
}

facet.gdc_entity = function(gdc,facets=default_fields(gdc)) {
    gdc$facets = facets
    invisible(gdc)
}

fetch = function(x,...) {
    UseMethod('fetch',x)
}

count = function(x,...) {
    UseMethod('count',x)
}

count.gdc_entity = function(x) {
    body = Filter(function(z) !is.null(z),x)
    body[['facets']]=paste0(body[['facets']],collapse=",")
    #body = lapply(l,toJSON)
    #names(body) = names(l)
    body[['from']]=1
    body[['size']]=1
    body[['format']]='JSON'
    body[['pretty']]='FALSE'
    httr::content(.gdc_post(.gdc_entity_name(x),body=body,token=NULL))$data$pagination$total
}    

fetch = function(x,from=1,size=10,pretty=FALSE) {
    body = Filter(function(z) !is.null(z),x)
    body[['facets']]=paste0(body[['facets']],collapse=",")
    #body = lapply(l,toJSON)
    #names(body) = names(l)
    body[['from']]=from
    body[['size']]=size
    body[['format']]='JSON'
    body[['pretty']]='FALSE'
    tmp = httr::content(.gdc_post(.gdc_entity_name(x),body=body,token=NULL,httr::verbose()))
    ret=list(results = tmp$data$hits,
             query   = x,
             pages   = tmp$data$pagination,
             ### TODO: fix me
             aggregations = tmp %>%
                 purrr::map('aggregations') %>% 
                 lapply(function(x) {purrr::map_df(as.list(x[['buckets']]),extract,c('key','doc_count'))})
             )
    
}

fetch_all = function(x,...) {
    count = count(x)
    return(fetch(x,size=count,from=1,...))
}

aggregations = function(x) {
    if(is.null(x$facets)) x$facets = subset(mapping(.gdc_entity_name(x)),defaults)$field
    res = httr::content(fetch(x)) %>% purrr::map('aggregations')
    return(lapply(res$data,function(x) {map_df(as.list(x[['buckets']]),extract,c('key','doc_count'))}))
}
