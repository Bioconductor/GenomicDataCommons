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
#' @param token (optional) character(1) security token allowing access
#'     to restricted data. See
#'     \url{https://gdc-docs.nci.nih.gov/API/Users_Guide/Authentication_and_Authorization/}.
#' 
#' @examples
#' map <- mapping("projects")
#' map["default"]
#' @importFrom httr content
#' @export
mapping <- function(endpoint, token=NULL) {
    valid <- c("projects", "cases", "files", "annotations")
    stopifnot(is.character(endpoint), length(endpoint) == 1L,
              endpoint %in% valid)
    response <- .gdc_get(
        sprintf("%s/%s", endpoint, "_mapping"), token=token)
    json <- content(response, type="application/json")
    .response_mapping_as_list(json)
}
