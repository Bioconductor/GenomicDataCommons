.gdc_base <- "https://gdc-api.nci.nih.gov"
.gdc_endpoint <-
    c("status", "projects", "cases", "files", "annotations", "data",
      "manifest", "slicing", "submission")

.gdc_parameters <-
    list(format="JSON", pretty=FALSE, fields=NULL, size=10L, from=1L,
         sort=NULL, filters=NULL, facets=NULL)

#' Print available endpoints
#'
#' @rdname constants
#' @export
endpoints <- function()
    .cat0("available endpoints:\n", .wrapstr(.gdc_endpoint), "\n")

#' Parameters influencing result format
#'
#' Parameters include format (internal use only), pretty (internal use
#' only), fields, size (number of results returned), from (index of
#' rist result), sort, filters, and facets. See
#' \url{https://gdc-docs.nci.nih.gov/API/Users_Guide/Search_and_Retrieval/#query-parameters}
#'
#' @rdname constants
#' @examples
#' parameters()
#' cases(size=5, from=1)
#' cases(size=5, from=3)
#' @export
parameters <- function()
    .cat0("available parameters:\n", .wrapstr(names(.gdc_parameters)), "\n")

.parameter_string <- function(parameters) {
    if (is.null(parameters))
        return("")
    stopifnot(is.list(parameters),
              all(names(parameters) %in% names(.gdc_parameters)))

    default <- .gdc_parameters
    default[names(parameters)] <- parameters
    default <- Filter(Negate(is.null), default)
    string <- paste(names(default), unname(default), sep="=", collapse="&")
    sprintf("?%s", string)
}
