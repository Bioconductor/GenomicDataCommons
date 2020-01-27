library(GenomicDataCommons)
context('cache_control')

cache = gdc_cache()

test_that("getting cache returns length 1 char vector", {
    expect_length(gdc_cache(),1)
    expect_true(is.character(gdc_cache()))
})

test_that("setting cache works", {
    expect_equal(gdc_set_cache('/tmp'),'/tmp')
    expect_equal(gdc_cache(),'/tmp')
})

test_that("setting cache error checking works", {
    expect_error(gdc_set_cache(1))
    expect_error(gdc_set_cache(c('a','b')))
})

gdc_set_cache(cache)

