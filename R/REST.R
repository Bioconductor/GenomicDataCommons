#' (internal) GET endpoint / uri
#'
#' @importFrom httr GET stop_for_status
.gdc_get <- function(endpoint, parameters=list(), ..., base=.gdc_base) {
    stopifnot(is.character(endpoint), length(endpoint) == 1L)
    uri <- sprintf("%s/%s%s", base, endpoint, .parameter_string(parameters))
    response <- GET(uri, ...)
    stop_for_status(response)
    response
}

.gdc_put <- function() {
}
    
