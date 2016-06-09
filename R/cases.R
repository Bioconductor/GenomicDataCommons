.case_primary_fields <-
    c("sample_ids", "portion_ids", "submitter_portion_ids",
      "created_datetime", "submitter_aliquot_ids", "updated_datetime",
      "submitter_analyte_ids", "analyte_ids", "submitter_id",
      "case_id", "state", "aliquot_ids", "slide_ids",
      "submitter_sample_ids")


#' @param primary logical(1) when TRUE (default) return commonly
#'     populated field names. Otherwise, return all field names
#'     defined in the API.
#'
#' @rdname cases
#' @export
case_fields <- function(primary=TRUE) {
    if (primary)
        .case_primary_fields
    else
        .case_fields
}


#' Query GDC for cases
#'
#' @param \dots (optional) additional parameters influence case
#'     selection. See \code{\link{parameters}}.
#'
#' @param fields character() vector of requested fields. See
#'     \code{project_fields()} for defined fields.
#'
#'@examples
#' cases <- cases()
#' cases
#' cases[1]
#' cases[[1]]$sample_ids
#' 
#' @importFrom httr content
#' @export
cases <- function(..., fields=case_fields()) {
    stopifnot(all(fields %in% case_fields(primary=FALSE)))
    if (!"case_id" %in% fields)
        fields <- c("case_id", fields)
    fields0 <- paste(fields, collapse=",")

    response <- .gdc_get(
        "cases", parameters=list(format="JSON", fields=fields0, ...))
    json <- content(response, type="application/json")

    .response_warnings(json[["warnings"]], "cases")

    cases <- json[["data"]][["hits"]]
    names(cases) <- vapply(cases, "[[", character(1), "case_id")
    cases <- lapply(cases, "[[<-", "case_id", NULL)
    cases <- lapply(cases, lapply, unlist) # collapse field elt 'list'
    class(cases) <- c("cases_list", "gdc_list", "list")
    cases
}
