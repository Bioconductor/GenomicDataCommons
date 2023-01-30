test_that("clinical data is structured properly", {
    sizen <- 3
    case_ids <- cases() |> results(size=sizen) |> ids()
    clinical_data <- gdc_clinical(case_ids)
    # overview of clinical results
    expect_true(
        is(clinical_data, "GDCClinicalList")
    )
    expect_true(
        all(
            c("demographic", "diagnoses", "exposures", "main") %in%
                names(clinical_data)
        )
    )
    
    lapply(clinical_data, function(dataset) {
        expect_true(
            nrow(dataset) <= sizen
        )
    })
    
    lapply(clinical_data, function(dataset) {
        expect_true(
            is.data.frame(dataset)
        )
    })
})
