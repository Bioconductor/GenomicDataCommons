#' Interactive shiny gadget to pick metadata fields
#'
#' Since each of the metadata endpoints can have dozens or
#' even hundreds of fields, having an approach to quickly
#' find and choose these fields interactively is really
#' useful. When running this function, a browser window
#' will pop up or, if in RStudio, an interactive widget
#' will show up in the viewer pane. Type and choose your
#' fields of interest. When complete, the fields will
#' be returned to the R session for capture in a variable.
#'
#' @param entity One of the metadata entities or a GDCQuery
#'
#' @return a character vector of chosen fields. The entity
#' id field (eg., 'case_id' for cases) will be automatically
#' included.
#'
#' @import shiny
#' @import miniUI
#' 
#' @examples
#' \dontrun{
#' fchoices = field_picker('projects')
#' fchoices
#' q = projects() %>% select(fchoices)
#' results(q)[[1]]
#'
#' # or inline
#' q = projects() %>% select(field_picker('projects'))
#' head(q$fields)
#' }
#' @export
field_picker <- function(entity) {

    fields = mapping(entity)$field
    setNames(fields,fields)
    idfield = paste0(entity,'_id')

    
    ui <- miniPage(
        gadgetTitleBar("My Gadget"),
        miniContentPanel(
            selectizeInput(
                'field_choice', '2. Multi-select', choices = fields, multiple = TRUE,
                width='100%', selected = idfield
            )
        )
    )

    server <- function(input, output, session) {
        # Define reactive expressions, outputs, etc.
        # When the Done button is clicked, return a value
        observeEvent(input$done, {
            returnValue <- union(paste0(entity,'_id'),input$field_choice)
            stopApp(returnValue)
        })
    }

    runGadget(ui, server)
}
