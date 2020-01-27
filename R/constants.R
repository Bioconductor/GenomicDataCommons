.gdc_base <- "https://api.gdc.cancer.gov"
.gdc_endpoint <-
    structure(
        c("status", "projects", "cases", "files", "annotations", "data",
          "manifest", "slicing"), ##, submission
        class="gdc_endpoints")

.gdc_parameters <-
    structure(
        list(format="JSON", pretty=FALSE, fields=NULL, size=10L, from=0L,
             sort=NULL, filters=NULL, facets=NULL),
        class="gdc_parameters")

.gdc_flat_parameters <-
    structure(
        c('fields','facets'),
        class = "gdc_flat_params")

.gdc_entities =
    structure(
        c('projects','cases',"files","annotations", 
          "ssms", "cnvs", "ssm_occurrences", "cnv_occurrences",
          "genes"),
        class = "gdc_entities")

.gdc_manifest_colnames = 
    structure(
        c("id", "filename", "md5", "size", "state"),
        class = 'gdc_manifest_colnames')


#' Endpoints and Parameters
#'
#' \code{endpoints()} returns available endpoints.
#'
#' @return \code{endpoints()} returns a character vector of possible
#'     endpoints.
#'
#' @rdname constants
#' @examples
#' endpoints()
#' @export
endpoints <- function()
    .gdc_endpoint

#' @export
print.gdc_endpoints <- function(x, ...)
    .cat0("available endpoints:\n", .wrapstr(x), "\n")

#' \code{parameters()} include format (internal use only), pretty
#' (internal use only), fields, size (number of results returned),
#' from (index of rist result), sort, filters, and facets. See
#' \url{https://gdc-docs.nci.nih.gov/API/Users_Guide/Search_and_Retrieval/#query-parameters}
#'
#' @return \code{parameters()} returns a list of possible parameters
#'     and their default values.
#' @keywords internal
#' 
#' @rdname constants
#' @examples
#' parameters()
#' @export
parameters <- function()
    .gdc_parameters

#' @export
print.gdc_parameters <- function(x, ...) {
    cat("available parameters:\n")
    for (nm in names(x))
        .cat0("    ", nm, ": ",
              if (is.null(x[[nm]])) "NULL" else x[[nm]], "\n")
}

#" (internal)
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

