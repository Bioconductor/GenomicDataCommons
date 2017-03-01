
rbindlist2 = function(x,idfield,...) {rbindlist(Filter(Negate(is.null),x),idcol=idfield,...)}

#' as.data.frame for GDCResults objects
#'
#'
#' @importFrom data.table rbindlist
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
            df = rbindlist2(res[[n]],idfield=id_field(res))
            otherfields = Negate(colnames(df) %in% id_field(res))
            colnames(df)[otherfields] = paste(n,colnames(df),sep='.')
            return(df)
        },
        error = function(e) {
            df = data.frame(I(res[[n]]),namecol)
            colnames(df) = c(n,id_field(res))
            return(df)
        })
    })
    names(otherdfs) = listcolnames
    
    #return(list(vecdf,otherdfs,alreadydfs))
    Reduce(function(left,right) merge(left,right,all.x=TRUE,all.y=TRUE,by=id_field(res)),
           c(list(vecdf),otherdfs,alreadydfs))    
    
}
