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
#' @param token (optional) character(1) security token allowing access
#'     to restricted data. See
#'     \url{https://docs.gdc.cancer.gov/API/Users_Guide/Getting_Started/#authentication}.
#'
#' @param fields character() vector of requested fields. See
#'     \code{case_fields()} for defined fields.
#'
#' @examples
#' cases <- cases()
#' cases
#' cases[1]
#' cases[[1]]$sample_ids
#'
#' lst <- cases(fields="submitter_id", sort="submitter_id:asc")
#' lst
#' sapply(lst, "[[", "submitter_id")
#' 
#' @importFrom httr content
#' @export
cases <- function(..., token=NULL, fields=case_fields()) {
    #stopifnot(all(fields %in% case_fields(primary=FALSE)))
    if (!"case_id" %in% fields)
        fields <- c("case_id", fields)
    fields0 <- paste(fields, collapse=",")

    response <- .gdc_get(
        "cases", parameters=list(format="JSON", fields=fields0, ...),
        token=token)
    json <- content(response, type="application/json")

    .response_warnings(json[["warnings"]], "cases")
    .response_json_as_list(json, "cases")
}
