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

#' Print available parameters
#'
#' @rdname constants
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
