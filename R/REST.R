#' (internal) GET endpoint / uri
#'
#' @importFrom httr GET stop_for_status
.gdc_get <- function(endpoint, query=NULL, ..., base=.gdc_base) {
    stopifnot(is.character(endpoint), length(endpoint) == 1L)
    uri <- sprintf("%s%s%s", base, endpoint,
                   if (!is.null(query)) sprintf("?%s", query) else "")
    response <- GET(uri, ...)
    stop_for_status(response)
    response
}

.gdc_put <- function() {
}
    
