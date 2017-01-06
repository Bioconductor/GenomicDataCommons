.unary_op <- function(left) {
  force(left)
  function(e1) {
    force(e1)
    list(op=e1,content=c(field=left,value=c(right)))
  }
}

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

.f_env = new.env(parent=emptyenv())
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
#' @param expr an R expression
#' @param available_fields A character vector of field names that, if specified,
#' can be used unquoted in creating filter expressions
#'
#' @return a (potentially nested) R list prior that, after converting to JSON
#' can be used as the filter parameter in an NCI GDC search or other query.
#'
#' @importFrom jsonlite toJSON
#'
#' @examples
#' filter_expr("diagnoses.age_at_diagnosis" <= 10*365)
#' filter_expr("project.primary_site" %in% c('blood','brain'))
#' fe = filter_expr("project.primary_site" %in% c('blood','brain')
#'                  & "diagnosis.age_at_diagnosis" <= 10*365)
#' jsonlite::toJSON(fe,auto_unbox=TRUE,pretty=TRUE)
#'
#' @export
filter_expr = function(expr,available_fields=NULL) {
    x = substitute(expr)
    available_fields=list(available_fields)
    names(available_fields)=available_fields
    filt_env = list2env(as.list(.f_env),parent=list2env(available_fields))
    eval(x,filt_env,enclos = parent.frame())
}

