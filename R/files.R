.file_primary_fields <-
    c("data_type", "updated_datetime", "created_datetime",
      "file_name", "md5sum", "data_format", "acl", "access", "state",
      "file_id", "data_category", "file_size", "submitter_id", "type",
      "file_state", "experimental_strategy")

#' @param primary logical(1) when TRUE (default) return commonly
#'     populated field names. Otherwise, return all field names
#'     defined in the API.
#'
#' @rdname files
#' @export
file_fields <- function(primary=TRUE) {
    if (primary)
        .file_primary_fields
    else
        c("type", .file_fields)
}

#' Query GDC for files
#'
#' @param \dots (optional) additional parameters influence file
#'     selection. See \code{\link{parameters}}.
#'
#' @param token (optional) character(1) security token allowing access
#'     to restricted data. See
#'     \url{https://gdc-docs.nci.nih.gov/API/Users_Guide/Authentication_and_Authorization/}.
#' 
#' @param fields character() vector of requested fields. See
#'     \code{file_fields()} for defined fields.
#'
#' @examples
#' files <- files()
#' files
#' files[1]
#' unlist(files[[1]])
#' 
#' @importFrom httr content
#' @export
files <- function(..., token=NULL, fields=file_fields()) {
    #stopifnot(all(fields %in% file_fields(primary=FALSE)))
    if (!"file_id" %in% fields)
        fields <- c("file_id", fields)
    fields0 <- paste(fields, collapse=",")

    response <- .gdc_get(
        "files", parameters=list(format="JSON", fields=fields0, ...),
        token=token)
    json <- content(response, type="application/json")

    .response_warnings(json[["warnings"]], "files")
    .response_json_as_list(json, "files")
}
