library(httr)
library(xml2)

pkghome <- "~/a/GenomicDataCommons"

url <-
    "https://gdc-docs.nci.nih.gov/API/Users_Guide/Appendix_A_Available_Fields/"
xml = content(GET(url))

.get_field <- function(xml, xpath) {
    fields <- as.character(xml_find_all(xml, xpath))
    Filter(nzchar, trimws(fields))
}

.project_fields <- .get_field(xml, "//table[1]//tr/td[1]/text()")
.file_fields <- .get_field(xml, "//table[2]//tr/td[1]/text()")
.case_fields <- .get_field(xml, "//table[3]//tr/td[1]/text()")
.annotation_fields <- .get_field(xml, "//table[4]//tr/td[1]/text()")

save(.project_fields, .file_fields, .case_fields, .annotation_fields,
     file=file.path(pkghome, "R", "sysdata.rda"))
