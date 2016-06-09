#' @importFrom xml2 xml_find_all
.response_warnings <- function(warnings, endpoint)
{
    warnings <- vapply(warnings, as.character, character(1))
    if (length(warnings) && nzchar(warnings))
        warning("'", endpoint, "' query warnings:\n", .wrapstr(warnings))
    NULL
}

#' @importFrom stats setNames
#' @importFrom xml2 xml_find_all xml_text
.response_xml_as_data_frame <- function(xml, fields)
{
    xpaths <- setNames(sprintf("/response/data/hits/item/%s", fields), fields)

    columns <- lapply(xpaths, function(xpath, xml) {
        nodes <- xml_find_all(xml, xpath)
        vapply(nodes, xml_text, character(1))
    }, xml=xml)
    columns <- Filter(length, columns)

    dropped <- fields[!fields %in% names(columns)]
    if (length(dropped))
        warning("fields not available:\n", .wrapstr(dropped))
    if (!length(unique(lengths(columns)))) {
        lens <- paste(sprintf("%s = %d", names(columns), lengths(columns)),
                      collapse=", ")
        stop("fields are different lengths:\n", .wrapstr(lens))
    }

    as.data.frame(columns, stringsAsFactors=FALSE)
}
