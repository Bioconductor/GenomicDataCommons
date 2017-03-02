library(GenomicDataCommons)
context('data handling')

test_that("manifest cases", {
    q = cases()
    m = manifest(q,size=10)
    expect_equal(nrow(m),10)
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