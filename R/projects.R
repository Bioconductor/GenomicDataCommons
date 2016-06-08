.project_fields <- 
    c("dbgap_accession_number", "disease_type", "released", "state",
      "primary_site", "project_id", "name")

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
projects <- function(...) {
    response <- .gdc_get("projects", parameters=list(format="XML", ...))
    xml <- content(response, type="application/xml")

    warnings <- as.character(xml_find_all(xml, "/response/warnings/text()"))
    if (length(warnings) && nzchar(warnings))
        warning("'projects' query warnings:\n",
                paste(strwrap(warnings, indent=4, exdent=4), collapse="\n"))

    xpaths <- setNames(sprintf("/response/data/hits/item/%s", .project_fields),
                       .project_fields)
    fields <- lapply(xpaths, function(xpath) {
        nodes <- xml_find_all(xml, xpath)
        vapply(nodes, xml_text, character(1))
    })

    as.data.frame(fields, stringsAsFactors=FALSE)
}
