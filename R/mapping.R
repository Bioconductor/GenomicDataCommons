.response_mapping_as_list <- function(json) {
    json <- lapply(json, unlist)
    structure(json, class=c("mapping_list", "gdc_list", "list"))
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
    valid <- c("projects", "cases", "files", "annotations")
    stopifnot(is.character(endpoint), length(endpoint) == 1L,
              endpoint %in% valid)
    response <- .gdc_get(
        sprintf("%s/%s", endpoint, "_mapping"))
    json <- content(response, type="application/json")
    mapdat = json[['_mapping']]
    maplist = list()
    for(cname in names(mapdat[[1]])) {
        maplist[[cname]] = as.character(lapply(mapdat,'[[',cname))
    }
    df = do.call(cbind,maplist)
    tmpdf = as.data.frame(matrix(FALSE, ncol = 4, nrow = nrow(df)))
    fieldtypes = c('defaults', 'expand', 'multi', 'nested')
    colnames(tmpdf) = fieldtypes
    df = cbind(df,tmpdf)
    for(i in fieldtypes) {
        df[df$field  %in% json[[i]],i] = TRUE
    }
    return(df)
}
