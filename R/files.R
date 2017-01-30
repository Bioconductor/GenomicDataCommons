.file_primary_fields <- tryCatch({
    subset(mapping('files'),defaults)$fields},
    error = function(e)
    c("data_type", "updated_datetime", "created_datetime",
      "file_name", "md5sum", "data_format", "acl", "access", "state",
      "file_id", "data_category", "file_size", "submitter_id", "type",
      "file_state", "experimental_strategy"))

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

#' Create GDC Files query
#'
#' @param token (optional) character(1) security token allowing access
#'     to restricted data. See
#'     \url{https://docs.gdc.cancer.gov/API/Users_Guide/Getting_Started/#authentication}.
#' 
#' @param fields character() vector of requested fields. See
#'     \code{file_fields()} for defined fields.
#'
#' @examples
#' # default file fields
#' gdcDefaultFields('files')
#'
#' # create a new query of the files endpoint
#' fQ = gdcFilesQuery()
#' str(fQ)
#'
#' # fetch a few records
#' fQResults = fetch(fQ,size=2)
#' str(fQResults)
#'
#' \dontrun{
#' library(listviewer)
#' editjson(fQResults)
#' }
#' 
#' @importFrom httr content
#' @export
gdcFilesQuery <- function(token = NULL, fields = gdcDefaultFields('files'),
                          filters = NULL, facets = NULL) {
    gdcQuery('files', token = NULL, fields = gdcDefaultFields('files'),
             filters = filters, facets = facets)
}
