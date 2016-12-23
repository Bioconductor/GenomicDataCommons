.unary_op <- function(left) {
  force(left)
  function(e1) {
    force(e1)
    list(op=e1,content=c(field=left,value=c(right)))
  }
}

.binary_op <- function(sep) {
  force(sep)
  function(e1, e2) {
      force(e1)
      force(e2)
      list(op=unbox(sep),content=list(field=e1,value=e2))
  }
}

combine_op = function(sep) {
  force(sep)
  function(e1, e2) {
      force(e1)
      force(e2)
    return(list(op=unbox(sep),content=list(e1,e2)))
  }
}

.f_env = new.env(parent=emptyenv())
# .f_env=list()
.f_env$`==` = .binary_op('=')
.f_env$`!=` = .binary_op('!=')
.f_env$`<` = .binary_op('<')
.f_env$'>' = .binary_op('>')
.f_env$'&' = combine_op('and')
.f_env$'|' = combine_op('or')
.f_env$`<=` = .binary_op('<=')
.f_env$'>=' = .binary_op('>=')
.f_env$'%in%' = .binary_op('in')
.f_env$'%exclude%' = .binary_op('exclude')


#' Create GDC filters
#'
#' Create filters using standard R formatting
#'
#' This function makes arbitrarily complex filter functions for
#' and creates a list that is ready for easy conversion with
#' toJSON for use in queries of the GDC.
#'
#' @param filter_expression an R-like expression
#' @param endpoint one of the recognized endpoints; used to pull accepted fields for
#'   use in query construction
#' @param ... passed to \code{jsonlite::toJSON}
#' @return either a JSON string or the R list prior to conversion to JSON
#'
#' @importFrom jsonlite toJSON
#'
#' @examples
#' #filter_expr(diagnoses.age_at_diagnosis <= 10*365,endpoint='cases')
#' #filter_expr(project.primary_site %in% c('blood','brain'),endpoint='cases')
#' @export
filter_expr = function(expr,available_fields,endpoint) {
    x = substitute(expr)
    available_fields=list(available_fields)
    names(available_fields)=available_fields
    filt_env = list2env(as.list(.f_env),parent=list2env(available_fields))
    eval(x,filt_env,enclos = parent.frame())
}
    
