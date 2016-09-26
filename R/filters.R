opList = c('in','==','<=','>=','!=','<','>','is','not','in','exclude')

.andCall = function(x) {
    return(list(op='and',content=list(recurse_call(x[[2]]),recurse_call(x[[3]]))))
}
.orCall = function(x) {
    return(list(op='or',content=list(recurse_call(x[[2]]),recurse_call(x[[3]]))))
}
.inCall = function(x) {
    return(list(op='in',content=list(field=as.character(x[[2]]),value=recurse_call(x[[3]]))))
}
.missingCall = function(x) {
    return(list(op='is',content=list(field=as.character(x[[2]]),value=I('missing'))))
}

.checkOps = function(op) {
    return(op %in% oplist)
}

recurse_call <- function(x) {
  if (is.atomic(x)) {
    return(x)
  } else if (is.name(x)) {
    return(as.character(x))
  } else if (is.call(x)) {
      if(x[[1]]=='(') x = x[[2]]
      if(x[[1]]=='==') x[[1]]='='
      if(x[[1]]=='is.null') return(.missingCall(x))
      if(x[[1]]=='&') return(.andCall(x))
      if(x[[1]]=='|') return(.orCall(x))
      if(x[[1]]=='%in%') return(.inCall(x))
      if(x[[1]]=='c') return(as.list(x)[-1])
      l = lapply(x,recurse_call)
      l = list(op=l[[1]],
               content=list(field=l[[2]],value=I(l[[3]])))
      return(l)
  } else if (is.pairlist(x)) {
      print('pairlist')
    print(x)
  } else {
    # User supplied incorrect input
    stop("Don't know how to handle type ", typeof(x), 
      call. = FALSE)
  }
}

#' Create GDC filters
#'
#' Create filters using standard R formatting
#'
#' This function makes arbitrarily complex filter functions for
#' and creates translated JSON for use in queries of the GDC.
#'
#' @param filter_expression a \code{quote}d expression
#' @param pretty create "pretty" json or not, passed to jsonlite::toJSON
#' @return json suitable for including in a GDC query
#'
#' @examples
#' filters(quote(cases.clinical.age_at_diagnosis >= 14600 & cases.clinical.age_at_diagnosis <= 25500))
#' filters(quote(primary_site %in% c('blood','brain')))
filters = function(filter_expression,pretty=FALSE) {
    return(jsonlite::toJSON(recurse_call(filter_expression),auto_unbox=TRUE,pretty=pretty))
}

