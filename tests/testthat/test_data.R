library(GenomicDataCommons)
context('data handling')

case_ids <- cases() |> results(size=10) |> ids()

test_that("manifest files", {
    m <- manifest(files(), size = 10)
    expect_identical(nrow(m), 10L)
    expect_true(ncol(m) > 5)
})

test_that("write_manifest", {
    m = files() |> manifest(size=10)
    tf = tempfile()
    write_manifest(m, tf)
    expect_true(file.exists(tf))
    unlink(tf)
})

test_that("gdcdata", {
    d = tempfile()
    if (!dir.exists(d))
        dir.create(d)
    gdc_set_cache(d)
    
    few_file_ids = files() |>
        filter( ~ cases.project.project_id == 'TCGA-SARC' &
            data_type == 'Copy Number Segment' &
            analysis.workflow_type == 'DNAcopy') |> results(size=2) |> ids()

    res = gdcdata(few_file_ids)
    expect_length(res, 2)
    expect_named(res)
    unlink(d, recursive = TRUE)
})
