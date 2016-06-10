#' (internal) GET endpoint / uri
#'
#' @importFrom httr GET stop_for_status
.gdc_get <-
    function(endpoint, parameters=list(), ..., base=.gdc_base)
{
    stopifnot(is.character(endpoint), length(endpoint) == 1L)
    uri <- sprintf("%s/%s%s", base, endpoint, .parameter_string(parameters))
    response <- GET(uri, ...)
    stop_for_status(response)
    response
}

.gdc_put <- function() {
}

#' @importFrom httr headers
.gdc_header_elt <- function(response, field, element) {
    value <- headers(response)[[field]]
    if (is.null(value))
        stop("response header does not contain field '", field, "'")

    value <- strsplit(strsplit(value, "; *")[[1L]], "= *")
    key <- vapply(value, `[[`, character(1), 1L)
    idx <- element == key
    if (sum(idx) != 1L)
        stop("response header field '", field,
             "' does not contain unique element '", element, "'")

    value[[which(idx)]][[2]]
}
    
#' @importFrom httr GET write_disk stop_for_status
.gdc_download_one <-
    function(uri, destination, overwrite, progress, base=.gdc_base)
{
    uri <- sprintf("%s/%s", base, uri)
    response <- GET(uri, write_disk(destination, overwrite),
                    if (progress) progress() else NULL)
    stop_for_status(response)
    if (progress) cat("\n")

    filename <- .gdc_header_elt(response, "content-disposition", "filename")
    to <- file.path(dirname(destination), filename)
    if (overwrite && file.exists(to))
        unlink(to)
    if (!file.rename(destination, to))
        stop("failed to rename downloaded file:\n",
             "\n  from: '", destination, "'",
             "\n  to: '", to, "'")
    to
}
