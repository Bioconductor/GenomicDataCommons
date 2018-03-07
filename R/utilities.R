.cat0 <- function(..., sep=NULL)
    cat(..., sep="")

.wrapstr <- function(x)
    paste(strwrap(paste(x, collapse=", "), indent=4, exdent=4), collapse="\n")

.dir_validate_or_create <- function(destination_dir) {
    stopifnot(is.character(destination_dir), length(destination_dir) == 1L,
              nzchar(destination_dir))
    if (!dir.exists(destination_dir)) {
        if (!file.exists(destination_dir))
            dir.create(destination_dir, recursive = TRUE)
        else
            stop("'destination_dir' exists but is not a directory")
    }
}

#" (internal) return character(0) instead of NULL
#"
#" Always return a vector and not NULL.
.ifNullCharacterZero <- function(x) {
    if(is.null(x))
        return(character(0))
    return(x)
}

#' @import BiocFileCache
.get_cache <- function() {
    cache <- rappdirs::user_cache_dir(appname="GenomicDataCommons")
    x = BiocFileCache::BiocFileCache(cache)
}
