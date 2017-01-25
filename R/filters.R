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
#' Create filters using standard R formatting
#'
#' Searching the NCI GDC allows for complex filtering based
#' on logical operations and simple comparisons.  This function
#' facilitates writing such filter expressions in R-like syntax
#' with R code evaluation.
#'
#' @details
#' This function can be used in several different ways.
#'
#' \itemize{
#' \item{If used with available_fields, "bare" fields that are
#' named in the available_fields character vector can be used
#' in the filter expression without quotes.}
#' \item{If toJSON==TRUE, then the appropriate JSON for using
#' in a query filter (filter = make_filter(....,)) is returned.}
#' \item{If toJSON==FALSE, then a list is returned that could
#' be manipulated further before converrsion to JSON for use in
#' a query. Note that the appropriate toJSON() will likely need
#' to include \dQuote{auto_unbox=TRUE}.}
#' }
#' 
#'
#' @param expr an R expression
#' @param toJSON boolean, return JSON (if true) or just a list
#' 
#' @param available_fields A character vector of field names that, if specified,
#' can be used unquoted in creating filter expressions
#'
#' @return a JSON data object (if toJSON==TRUE, the default)
#' can be used as the filter parameter in an NCI GDC search or other query.
#'
#' @importFrom jsonlite toJSON
#' @importFrom lazyeval f_eval
#'
#' @examples
#' make_filter("diagnoses.age_at_diagnosis" <= 10*365)
#' make_filter("project.primary_site" %in% c('blood','brain'))
#' fe = make_filter("project.primary_site" %in% c('blood','brain')
#'                  & "diagnosis.age_at_diagnosis" <= 10*365)
#' fe
#'
#' fe = make_filter("project.primary_site" %in% c('blood','brain')
#'                  & "diagnosis.age_at_diagnosis" <= 10*365,toJSON=FALSE)
#' fe
#'
#' @export
make_filter = function(expr,available_fields=NULL,toJSON=TRUE) {
    x = substitute(expr)
    available_fields=as.list(available_fields)
    names(available_fields)=available_fields
    filt_env = list2env(as.list(.f_env),parent=list2env(available_fields))
    ret=eval(x,filt_env,enclos = parent.frame())
    if(toJSON) return(toJSON(ret,auto_unbox=TRUE))
    else return(ret)
}

#' makefilter2
#'
#' @param expr a filter expression
#' @param available_fields a character vector of the
#' additional names that will be injected into the
#' filter evaluation environment
#' 
#' @importFrom lazyeval f_eval
#' 
#' @export
make_filter2 = function(expr,available_fields) {
    available_fields=as.list(available_fields)
    names(available_fields)=available_fields
    filt_env = c(as.list(.f_env),available_fields)
    f_eval(expr,data=filt_env)
}



#' Manipulating GDCQuery filters
#'
#' @name filtering
#' @examples
#' # make a GDCQuery object to start
#' #
#' # Projects
#' #
#' pQuery = gdcProjects()
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
#' fQuery = gdcFiles()
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
#' @param expr a filter expression, where bare names
#' (without quotes) are allowed if they are available
#' fields associated with the \code{x}
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
    filt = make_filter2(expr,available_fields(x))
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



