#' rbindlist, but with null values allowed
#' @importFrom data.table rbindlist
rbindlist2 = function(x,...) {rbindlist(Filter(Negate(is.null),x),...)}

#' Convert GDC results to data.frame
#'
#' GDC results are typically returned as an R list
#' structure. This method converts that 
#' R list structure to a data.frame. Some columns
#' in the resulting data.frame may remain lists, but
#' there will be one list element for each row though
#' that list element may contain multiple values.  
#'
#' @param res a \code{GDCResults} object to be converted to a 
#'     data.frame.
#'
#' @return a data.frame, potentially with list columns still
#'     present.
#'
#' @examples 
#' expands = c("diagnoses","diagnoses.treatments","annotations",
#'             "demographic","exposures")
#' head(cases() %>% expand(expands) %>% as.data.frame())
#' 
#' @export
as.data.frame.GDCResults <- function(res) {
    # get the value of the id column from results
    namecol = res[[id_field(res)]]
    
    # deal with list elements that are already data.frames
    alreadydfs = lapply(Filter(is.data.frame,res),function(df) {
        df = cbind(data.frame(namecol),df)
        colnames(df)[1] = id_field(res)
        return(df)
    })
    
    # Deal with all vector columns by simply making a data
    # frame of them.
    # this will include the idfield, so no need to explicitly add
    vecdf = as.data.frame(Filter(Negate(is.list),res))
    
    # need the names for making data.frame columns,
    # so loop over names
    listcolnames = Filter(function(n) {is.list(res[[n]]) & !is.data.frame(res[[n]])},names(res))
    otherdfs = lapply(listcolnames,function(n) {
        tryCatch(
        expr = {
            df = rbindlist2(res[[n]],idcol=id_field(res))
            otherfields = !(colnames(df) %in% id_field(res))
            colnames(df)[otherfields] = paste(n,colnames(df)[otherfields],sep='.')
            return(df)
        },
        error = function(e) {
            df = data.frame(I(res[[n]]),namecol)
            colnames(df) = c(n,id_field(res))
            return(df)
        })
    })
    names(otherdfs) = listcolnames
    
    Reduce(function(left,right) merge(left,right,all.x=TRUE,all.y=TRUE,by=id_field(res)),
           c(list(vecdf),otherdfs,alreadydfs))    
    
}
