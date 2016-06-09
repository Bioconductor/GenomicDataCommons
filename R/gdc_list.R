#' @importFrom utils head tail
#' @export
print.gdc_list <- function(x, ...) {
    nms <- names(x)
    .cat0("cases: ", length(nms), "\n")
    .cat0("names:\n",
          .wrapstr(
              if (length(nms) > 5) {
                  c(head(nms, 3), "...", tail(nms, 2))
              } else nms))
    if (length(x) == 1L) {
        lens <- lengths(x[[1]])
        names(lens) <- names(x[[1]])
        .cat0("\nfields:")
        for (i in seq_along(lens))
            .cat0("\n    ", names(lens)[i], "(", lens[i], ")")
    }
    .cat0("\n")
}

#' @export
`[.gdc_list` <- function(x, i, j, ..., drop=TRUE) {
    cls <- class(x)
    x <- unclass(x)[i]
    class(x) <- cls
    x
}
