.project_fields <- 
    c("dbgap_accession_number", "disease_type", "released", "state",
      "primary_site", "project_id", "name")

#' Query GDC for projects
#'
#' @param \dots (optional) additional parameters influencing project
#'     selection. See \code{\link{parameters}}.
#' 
#' @importFrom httr content
#' 
#' @export
projects <- function(...) {
    response <- .gdc_get("projects", parameters=list(format="XML", ...))
    xml <- content(response, type="application/xml")
    xpaths <- setNames(sprintf("//%s", .project_fields), .project_fields)
    fields <- lapply(xpaths, function(xpath) {
        nodes <- xml_find_all(xml, xpath)
        vapply(nodes, xml_text, character(1))
    })
    as.data.frame(fields, stringsAsFactors=FALSE)
}
