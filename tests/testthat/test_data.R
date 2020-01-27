library(GenomicDataCommons)
library(magrittr)
context('data handling')

case_ids = cases() %>% results(size=10) %>% ids()

test_that("manifest files", {
    q = files()
    m = manifest(q,size=10)
    expect_equal(nrow(m),10)
    expect_equal(ncol(m),5)
})

test_that("write_manifest", {
    m = files() %>% manifest(size=10)
    tf = tempfile()
    write_manifest(m, tf)
    expect_true(file.exists(tf))
})

d = tempdir()
gdc_set_cache(d)

few_file_ids = files() %>%
    filter( ~ cases.project.project_id == 'TCGA-SARC' &
                data_type == 'Copy Number Segment' &
                analysis.workflow_type == 'DNAcopy') %>% results(size=2) %>% ids()

test_that("gdcdata", {
    res = gdcdata(few_file_ids)
    expect_length(res, 2)
    expect_named(res)
})