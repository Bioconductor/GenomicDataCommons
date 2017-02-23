.response_mapping_as_list <- function(json) {
    json <- lapply(json, unlist)
    structure(json, class=c("mapping_list", "gdc_list", "list"))
}


#' utility for returning _mapping json
#'
#' @importFrom httr content
.get_mapping_json <- function(endpoint) {
    valid <- .gdc_entities
    stopifnot(is.character(endpoint), length(endpoint) == 1L,
              endpoint %in% valid)
    response <- .gdc_get(
        sprintf("%s/%s", endpoint, "_mapping"), archive='default')
    content(response, type="application/json")
}


#' Query GDC for available endpoint fields
#'
#' @param endpoint character(1) corresponding to endpoints for which
#'     users may specify additional or alternative fields. Endpoints
#'     include \dQuote{projects}, \dQuote{cases}, \dQuote{files}, and
#'     \dQuote{annotations}.
#'
#' @return A data frame describing the field (field name), full (full
#'     data model name), type (data type), and four additional columns
#'     describing the "set" to which the fields belong--\dQuote{default},
#'     \dQuote{expand}, \dQuote{multi}, and \dQuote{nested}.
#'
#' @examples
#' map <- mapping("projects")
#' head(map)
#' # get only the "default" fields
#' subset(map,defaults)
#' # And get just the text names of the "default" fields
#' subset(map,defaults)$field
#' 
#' @importFrom httr content
#' @export
mapping <- function(endpoint) {
    json = .get_mapping_json(endpoint)
    maplist = list()
    fields = data.frame(field=unlist(json[['fields']]))
    mapdat = json[['_mapping']]
    for(cname in names(mapdat[[1]])) {
        maplist[[cname]] = as.character(sapply(mapdat,'[[',cname))
    }
    df = do.call(cbind,maplist)
    tmpdf = as.data.frame(matrix(FALSE, ncol = 1, nrow = nrow(df)),stringsAsFactors = FALSE)
    fieldtypes = c('defaults')
    colnames(tmpdf) = fieldtypes
    df = cbind(data.frame(df,stringsAsFactors=FALSE),tmpdf)
    df = as.data.frame(merge(fields,df,by.x='field',by.y='field',all.x=TRUE),stringsAsFactors = FALSE)
    df$field = as.character(df$field)
    for(i in fieldtypes) {
        df[df$field  %in% json[[i]],i] = TRUE
    }
    return(df)
}

