.gdc_base <- "https://gdc-api.nci.nih.gov"
.gdc_endpoint <-
    c("status", "projects", "cases", "files", "annotations", "data",
      "manifest", "slicing", "submission")

#' Print available endpoints
#'
#' @rdname constants
#' @export
endpoints <- function() {
    txt <- strwrap(paste(.gdc_endpoint, collapse=", "), indent=4, exdent=4)
    cat("available endpoints:", paste(txt, collapse="\n"), sep="\n")
}
