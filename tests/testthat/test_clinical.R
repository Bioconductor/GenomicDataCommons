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
    
    expect_true(
        all(
            vapply(clinical_data, nrow, integer(1L)) >= sizen
        )
    )
    expect_true(
        all(
            vapply(clinical_data, is.data.frame, logical(1L))
        )
    )
})
