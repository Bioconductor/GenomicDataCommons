#.unary_op <- function(left) {
#  force(left)
#  function(e1) {
#    force(e1)
#    list(op=e1,content=c(field=left,value=c(right)))
#  }
#}

#' @importFrom jsonlite unbox
.binary_op <- function(sep) {
  force(sep)
  function(e1, e2) {
      force(e1)
      force(e2)
      list(op=unbox(sep),content=list(field=e1,value=e2))
  }
}

#' @importFrom jsonlite unbox
.combine_op <- function(sep) {
  force(sep)
  function(e1, e2) {
      force(e1)
      force(e2)
    return(list(op=unbox(sep),content=list(e1,e2)))
  }
}

#.f_env = new.env(parent=emptyenv())
.f_env = list()
.f_env$`==` = .binary_op('=')
.f_env$`!=` = .binary_op('!=')
.f_env$`<` = .binary_op('<')
.f_env$'>' = .binary_op('>')
.f_env$'&' = .combine_op('and')
.f_env$'|' = .combine_op('or')
.f_env$`<=` = .binary_op('<=')
.f_env$'>=' = .binary_op('>=')
.f_env$'%in%' = .binary_op('in')
.f_env$'%exclude%' = .binary_op('exclude')


#' Create NCI GDC filters for limiting GDC query results
#'
#' Searching the NCI GDC allows for complex filtering based
#' on logical operations and simple comparisons.  This function
#' facilitates writing such filter expressions in R-like syntax
#' with R code evaluation.
#'
#' If used with available_fields, "bare" fields that are
#' named in the available_fields character vector can be used
#' in the filter expression without quotes.
#'
#' @param expr a filter expression
#'
#' @param available_fields a character vector of the
#' additional names that will be injected into the
#' filter evaluation environment
#'
#' @return a \code{list} that represents an R version
#' of the JSON that will ultimately be used in an
#' NCI GDC search or other query.
#' 
#' @importFrom lazyeval f_eval
#' 
#' @export
make_filter = function(expr,available_fields) {
    available_fields=as.list(available_fields)
    names(available_fields)=available_fields
    filt_env = c(as.list(.f_env),available_fields)
    f_eval(expr,data=filt_env)
}



#' Manipulating GDCQuery filters
#'
#' @name filtering
#' 
#' @return A \code{\link{GDCQuery}} object with the filter
#' field replaced by specified filter expression
#' 
#' @examples
#' # make a GDCQuery object to start
#' #
#' # Projects
#' #
#' pQuery = projects()
#'
#' # check for the default fields
#' # so that we can use one of them to build a filter
#' default_fields(pQuery)
#' pQuery = filter(pQuery,~ project_id == 'TCGA-LUAC')
#' get_filter(pQuery)
#'
#' #
#' # Files
#' #
#' fQuery = files()
#' default_fields(fQuery)
#'
#' fQuery = filter(fQuery,~ data_format == 'VCF')
#' get_filter(fQuery)
#'
#' fQuery = filter(fQuery,~ data_format == 'VCF' & experimental_strategy == 'WXS' & type == 'simple_somatic_mutation')
#' 
#' # Use str() to get a cleaner picture
#' str(get_filter(fQuery))
NULL

#' The \code{filter} is simply a safe accessor for
#' the filter element in \code{\link{GDCQuery}} objects.
#'
#' @param x the object on which to set the filter list
#' member
#' @param expr a filter expression in the form of
#' the right hand side of a formula, where bare names
#' (without quotes) are allowed if they are available
#' fields associated with the GDCQuery object, \code{x}
#' 
#' @rdname filtering
#' 
#' @export
filter = function(x,expr) {
    UseMethod('filter',x)
}

#' @rdname filtering
#'
#' @export
filter.GDCQuery = function(x,expr) {
    filt = make_filter(expr,available_fields(x))
    x$filters = filt
    return(x)
}

#' The \code{get_filter} is simply a safe accessor for
#' the filter element in \code{\link{GDCQuery}} objects.
#'
#' @rdname filtering
#'
#' 
#' @export
get_filter = function(x) {
    UseMethod('get_filter',x)
}

#' @rdname filtering
#' 
#' @export
get_filter.GDCQuery = function(x) {
    return(x$filters)
}



