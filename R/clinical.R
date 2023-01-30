#' Get clinical information from GDC
#'
#' The NCI GDC has a complex data model that allows various studies to
#' supply numerous clinical and demographic data elements. However,
#' across all projects that enter the GDC, there are
#' similarities. This function returns four data.frames associated
#' with case_ids from the GDC.
#'
#' @param case_ids a character() vector of case_ids, typically from
#'     "cases" query.
#'
#' @param include_list_cols logical(1), whether to include list
#'     columns in the "main" data.frame. These list columns have
#'     values for aliquots, samples, etc. While these may be useful
#'     for some situations, they are generally not that useful as
#'     clinical annotations.
#' 
#' @importFrom jsonlite fromJSON
#' @importFrom dplyr bind_rows
#' @importFrom tibble as_tibble
#'
#' @details
#' Note that these data.frames can, in general, have different numbers
#' of rows (or even no rows at all). If one wishes to combine to
#' produce a single data.frame, using the approach of left joining to
#' the "main" data.frame will yield a useful combined data.frame. We
#' do not do that directly given the potential for 1:many
#' relationships. It is up to the user to determine what the best
#' approach is for any given dataset.
#'
#'
#' @return
#' A list of four data.frames:
#' \enumerate{
#' \item main, representing basic case identification and metadata
#'     (update date, etc.)
#' \item diagnoses
#' \item esposures
#' \item demographic
#' }
#'
#'
#' @examples
#' case_ids = cases() %>% results(size=10) %>% ids()
#' clinical_data = gdc_clinical(case_ids)
#'
#' # overview of clinical results
#' class(clinical_data)
#' names(clinical_data)
#' sapply(clinical_data, class)
#' sapply(clinical_data, nrow)
#'
#' # available data
#' head(clinical_data$main)
#' head(clinical_data$demographic)
#' head(clinical_data$diagnoses)
#' head(clinical_data$exposures)
#' 
#' @export
gdc_clinical = function(case_ids, include_list_cols = FALSE) {
    stopifnot(is.character(case_ids))
    stopifnot(is.logical(include_list_cols) & length(include_list_cols)==1)
    resp = cases() %>%
        filter( ~ case_id %in% case_ids) %>%
        expand(c("diagnoses",
                 "demographic",
                 "exposures")) %>%
        response_all(response_handler = function(x) jsonlite::fromJSON(x, simplifyDataFrame = TRUE))
    demographic = resp$results$demographic
    demographic$case_id = rownames(demographic)

    nodx <- vapply(resp$results$diagnoses, is.null, logical(1L))
    if (any(nodx))
        resp$results$diagnoses[nodx] <- list(data.frame())

    diagnoses <- suppressMessages({
        bind_rows(
            lapply(resp$results$diagnoses, readr::type_convert),
            .id = "case_id"
        )
    })

    exposures = bind_rows(resp$results$exposures, .id = "case_id")

    # set up main table by removing data.frame columns
    cnames = setdiff(colnames(resp$results), c('exposures', 'diagnoses', 'demographic'))
    main = resp$results[, cnames]

    if(!include_list_cols) {
        non_list_cols = names(Filter(function(cname) cname!='list', sapply(main, class)))
        main = main[, non_list_cols]
    }
    
    y = list(demographic = as_tibble(demographic),
             diagnoses = as_tibble(diagnoses),
             exposures = as_tibble(exposures),
             main = as_tibble(main))
    class(y) = c('GDCClinicalList', class(y))
    return(y)
}
