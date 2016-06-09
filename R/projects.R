.project_primary_fields <- 
    c("dbgap_accession_number", "disease_type", "released", "state",
      "primary_site", "project_id", "name")

#' @param primary logical(1) when TRUE (default) return commonly
#'     populated field names. Otherwise, return all field names
#'     defined in the API.
#' 
#' @rdname projects
#' @export
project_fields <- function(primary=TRUE) {
    if (primary)
        .project_primary_fields
    else
        .project_fields
}

#' Query GDC for projects
#'
#' @param \dots (optional) additional parameters influencing project
#'     selection. See \code{\link{parameters}}.
#' @param fields character() vector of requested fields. See
#'     \code{project_fields()} for defined fields.
#'
#' @examples
#' projects()                        # first 10 projects, as a data.frame
#' df <- projects(from=10, size=20)  # projects 10, 11, ... 29
#' dim(df)
#' 
#' @importFrom httr content
#' @export
projects <- function(..., fields=project_fields())
{
    stopifnot(all(fields %in% project_fields(primary=FALSE)))
    fields0 <- paste(fields, collapse=",")

    response <- .gdc_get(
        "projects", parameters=list(format="XML", fields=fields0, ...))
    xml <- content(response, type="application/xml")

    warnings <- xml_find_all(xml, "/response/warnings/text()")
    .response_warnings(warnings, "projects")
    .response_xml_as_data_frame(xml, fields)
}
