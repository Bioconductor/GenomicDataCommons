#' rbindlist that deals with \code{NULL} rows
#'
#' This is a simple function that removes \code{null}
#' values from the input list
#' before applying \code{\link[data.table]{rbindlist}}.
#'
#' @param x a list that is appropriate for input
#'     to \code{\link[data.table]{rbindlist}}, but
#'     may include \code{NULL}s, which will be filtered.
#'
#' @param ... passed directly to \code{\link[data.table]{rbindlist}}.
#'
#' @importFrom data.table rbindlist
#' 
#' @return a \code{data.table,data.frame} object.
#'
#' @examples
#' input = list(list(a=1,b=2,d='only this row'),
#'              NULL,
#'              list(a=3,b=4))
#' rbindlist2(input)
#' 
#' @export
rbindlist2 = function(x,...) {
    rbindlist(Filter(Negate(is.null),x),...,fill=TRUE)
}

#' Convert GDC results to data.frame
#'
#' GDC results are typically returned as an R list
#' structure. This method converts that 
#' R list structure to a data.frame. Some columns
#' in the resulting data.frame may remain lists, but
#' there will be one list element for each row though
#' that list element may contain multiple values. 
#' 
#' @note The data.frame that is returned is the cartesian product 
#' of sub-data.frames that come from the GDC. This may lead to more
#' than one row per entity id. It is up to the user to determine 
#' how to make rows unique per entity, if that is desired.
#'
#' @param x a \code{GDCResults} object to be converted to a 
#'     data.frame.
#' @param row.names not used here; row.names are calculated
#'     from the data to maintain data integrity
#' @param optional not used here; just for matching method call for \code{\link{as.data.frame}}
#' @param ... not used here; just for matching method call for \code{\link{as.data.frame}}
#'
#' @return a data.frame, potentially with list columns still
#'     present.
#'
#' @examples
#' library(magrittr)
#' expands = c("diagnoses","diagnoses.treatments","annotations",
#'             "demographic","exposures")
#' head(cases() %>% expand(expands) %>% results() %>% as.data.frame())
#' 
#' @export
as.data.frame.GDCResults <- function(x, row.names, optional, ...) {
    # get the value of the id column from results
    namecol = x[[id_field(x)]]
    
    # deal with list elements that are already data.frames
    alreadydfs = lapply(Filter(is.data.frame,x),function(df) {
        df = cbind(data.frame(namecol),df)
        colnames(df)[1] = id_field(x)
        return(df)
    })
    
    # Deal with all vector columns by simply making a data
    # frame of them.
    # this will include the idfield, so no need to explicitly add
    vecdf = as.data.frame(Filter(Negate(is.list),x))
    
    # need the names for making data.frame columns,
    # so loop over names
    listcolnames = Filter(function(n) {is.list(x[[n]]) & !is.data.frame(x[[n]])},names(x))
    otherdfs = lapply(listcolnames,function(n) {
        tryCatch(
        expr = {
            df = rbindlist2(x[[n]],idcol=id_field(x))
            otherfields = !(colnames(df) %in% id_field(x))
            colnames(df)[otherfields] = paste(n,colnames(df)[otherfields],sep='.')
            return(df)
        },
        error = function(e) {
            df = data.frame(I(x[[n]]),namecol)
            colnames(df) = c(n,id_field(x))
            return(df)
        })
    })
    names(otherdfs) = listcolnames
    
    Reduce(function(left,right) merge(left,right,all.x=TRUE,all.y=TRUE,by=id_field(x)),
           c(list(vecdf),otherdfs,alreadydfs))    
    
}
