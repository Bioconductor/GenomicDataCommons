library(GenomicDataCommons)
context('data handling')

test_that("manifest cases", {
    q = cases() %>% filter(~ case_id %in% "51ae5536-f55c-4fd6-b990-5d3add98de5c")
    m = manifest(q)
    expect_gt(nrow(m),1)
    expect_equal(ncol(m),5)
})

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
