library(GenomicDataCommons)
context('API')

test_that("status returns correctly", {
    res = status()
    expect_equal(length(res), 4)
})

test_that("cases", {
    res = cases()
    expect_equal(length(res), 10)
    expect_equal(class(res),c('cases_list','gdc_list','list'))
    expect_equal(class(res[1]),c('cases_list','gdc_list','list'))
    expect_equal(length(res[1]),1)
    expect_equal(class(res[[1]]),'list')
})

test_that("files", {
    res = files()
    expect_equal(length(res), 10)
    expect_equal(class(res),c('files_list','gdc_list','list'))
    expect_equal(class(res[1]),c('files_list','gdc_list','list'))
    expect_equal(length(res[1]),1)
    expect_equal(class(res[[1]]),'list')
})

test_that("annotations", {
    res = annotations()
    expect_equal(length(res), 10)
    expect_equal(class(res),c('annotations_list','gdc_list','list'))
    expect_equal(class(res[1]),c('annotations_list','gdc_list','list'))
    expect_equal(length(res[1]),1)
    expect_equal(class(res[[1]]),'list')
})

test_that("mapping", {
    res = mapping('files')
    expect_equal(class(res),'data.frame')
    expect_equal(ncol(res), 9)
    expect_equal(colnames(res),c('description','doc_type','field','full','type','defaults','expand','multi','nested'))
})
