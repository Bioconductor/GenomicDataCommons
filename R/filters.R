.filterOps = c('&'  = 'and',
               '==' = '=',
               '!=' = '!=',
               '>=' = '>=',
               '<=' = '<=',
               '>'  = '>',
               '<'  = '<',
               '%is%' = 'is',
               '!'  = 'not',
               '|'  = 'or',
               '%in%' = 'in',
               '%exclude%' = 'exclude')

.dropDot = function(s) {
  return(strsplit(s,'\\.')[1])
}

.makeOp = function(op) {
  force(.makeOp)
  if(op %in% c('==','!=','>=','<=','>','<','%in%','%exclude%','%is%')) {
    return(function(x,y) {
      return(list(op=jsonlite::unbox(.filterOps[op]),
              content=list(field=jsonlite::unbox(x),value=y)))
    })
  }
  if(op=='(') {
    return(function(x) {
      return(list(x))
    })
  }
  if(op %in% c('&','|')) {
    return(function(x,y) {
      return(list(op=jsonlite::unbox(.filterOps[op]),
                  content=list(x,y)))
    })
  }
  return(function(op) {
    return(as.character(op))
  })
}

.endpoints = c('projects','files','cases','annotations')

#' Create GDC filters
#'
#' Create filters using standard R formatting
#'
#' This function makes arbitrarily complex filter functions for
#' and creates translated JSON for use in queries of the GDC.
#'
#' @param filter_expression an R expression
#' @param asJSON if TRUE, return the JSON.  If FALSE, return an R list
#' @param endpoint one of the recognized endpoints; used to pull accepted fields for
#'   use in query construction
#' @param ... passed to \code{jsonlite::toJSON}
#' @return either a JSON string or the R list prior to conversion to JSON
#'
#' @importFrom jsonlite toJSON
#'
#' @examples
#' filters(diagnoses.age_at_diagnosis <= 10*365,endpoint='cases')
#' filters(project.primary_site %in% c('blood','brain'),endpoint='cases')
#' @export
filters = function(filter_expression, endpoint, asJSON=TRUE, ...) {
  if(!(endpoint %in% .endpoints)) {
    stop(sprintf('endpoint must be one of %s',paste(.endpoints,sep=",")))
  }
  ca = match.call()
  ops = sapply(names(.filterOps),.makeOp)
  fields = mapping(endpoint)$fields
  names(fields) = fields
  ops = c(ops,fields)
  ## The eval and match.call combo keep R from
  ##   evaluating until we are in the right context 
  ##   (i.e., with ops in place)
  retlist = with(ops,eval(ca$filter_expression))
  if(asJSON) {
    return(jsonlite::toJSON(retlist,...))
  }
  return(retlist)
}
