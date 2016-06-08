.gdc_base <- "https://gdc-api.nci.nih.gov"
.gdc_endpoint <-
    c("status", "projects", "cases", "files", "annotations", "data",
      "manifest", "slicing", "submission")

.gdc_parameters <-
    list(format="JSON", pretty=FALSE, fields=NULL, size=10L, from=1L,
         sort=NULL, filters=NULL, facets=NULL)

.constants_format <- function(names) {
    txt <- strwrap(paste(names, collapse=", "), indent=4, exdent=4)
    paste(txt, collapse="\n")
}

#' Print available endpoints
#'
#' @rdname constants
#' @export
endpoints <- function()
    cat("available endpoints:", .constants_format(.gdc_endpoint), sep="\n")

#' Print available parameters
#'
#' @rdname constants
#' @export
parameters <- function()
    cat("available parameters:", .constants_format(names(.gdc_parameters)),
        sep="\n")

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
