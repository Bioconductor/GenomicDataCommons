.cat0 <- function(..., sep=NULL)
    cat(..., sep="")

.wrapstr <- function(x)
    paste(strwrap(paste(x, collapse=", "), indent=4, exdent=4), collapse="\n")
