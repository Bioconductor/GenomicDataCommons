.annotation_primary_fields <-
    c("status", "category", "entity_id", "classification",
      "updated_datetime", "created_datetime", "annotation_id",
      "notes", "entity_type", "submitter_id", "case_id",
      "entity_submitter_id", "case_submitter_id")

#' @param primary logical(1) when TRUE (default) return commonly
#'     populated field names. Otherwise, return all field names
#'     defined in the API.
#'
#' @rdname cases
#' @export
annotation_fields <- function(primary=TRUE) {
    if (primary)
        .annotation_primary_fields
    else
        c("type", .annotation_fields)
}

#' Query GDC for annotations
#'
#' @param \dots (optional) additional parameters influence annotation
#'     selection. See \code{\link{parameters}}.
#'
#' @param fields character() vector of requested fields. See
#'     \code{annotation_fields()} for defined fields.
#'
#' @examples
#' annotations <- annotations()
#' annotations
#' annotations[1]
#' unlist(annotations[[1]])
#' 
#' @importFrom httr content
#' @export
annotations <- function(..., fields=annotation_fields()) {
    stopifnot(all(fields %in% annotation_fields(primary=FALSE)))
    if (!"annotation_id" %in% fields)
        fields <- c("annotation_id", fields)
    fields0 <- paste(fields, collapse=",")

    response <- .gdc_get(
        "annotations", parameters=list(format="JSON", fields=fields0, ...))
    json <- content(response, type="application/json")

    .response_warnings(json[["warnings"]], "cases")
    .response_json_as_list(json, "annotations")
}
