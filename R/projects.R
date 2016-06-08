.project_all_fields <-
    c("dbgap_accession_number", "disease_type", "name",
      "primary_site", "program.dbgap_accession_number",
      "program.name", "program.program_id", "project_id", "released",
      "state", "summary.case_count",
      "summary.data_categories.case_count",
      "summary.data_categories.data_category",
      "summary.data_categories.file_count",
      "summary.experimental_strategies.case_count",
      "summary.experimental_strategies.experimental_strategy",
      "summary.experimental_strategies.file_count",
      "summary.file_count", "summary.file_size")    

.project_primary_fields <- 
    c("dbgap_accession_number", "disease_type", "released", "state",
      "primary_site", "project_id", "name")

#' @export
project_fields <- function(primary=TRUE) {
    if (primary)
        .project_primary_fields
    else
        .project_all_fields
}

#' Query GDC for projects
#'
#' @param \dots (optional) additional parameters influencing project
#'     selection. See \code{\link{parameters}}.
#'
#' @importFrom stats setNames
#' @importFrom httr content
#' @importFrom xml2 xml_find_all xml_text
#'
#' @examples
#' projects()                        # first 10 projects, as a data.frame
#' df <- projects(from=10, size=20)  # projects 10, 11, ... 29
#' dim(df)
#' 
#' @export
projects <- function(..., fields=project_fields())
{
    stopifnot(all(fields %in% project_fields(primar=FALSE)))
    fields0 <- paste(fields, collapse=",")

    response <- .gdc_get(
        "projects", parameters=list(format="XML", fields=fields0, ...))
    xml <- content(response, type="application/xml")

    warnings <- as.character(xml_find_all(xml, "/response/warnings/text()"))
    if (length(warnings) && nzchar(warnings))
        warning("'projects' query warnings:\n",
                paste(strwrap(warnings, indent=4, exdent=4), collapse="\n"))

    xpaths <- setNames(sprintf("/response/data/hits/item/%s", fields), fields)
    columns <- lapply(xpaths, function(xpath) {
        nodes <- xml_find_all(xml, xpath)
        vapply(nodes, xml_text, character(1))
    })
    columns <- Filter(length, columns)

    dropped <- fields[!fields %in% names(columns)]
    if (length(dropped))
        warning("fields not available:\n",
                paste(strwrap(paste(dropped, collapse=", "), indent=4, exdent=4),
                      "\n"))

    as.data.frame(columns, stringsAsFactors=FALSE)
}
