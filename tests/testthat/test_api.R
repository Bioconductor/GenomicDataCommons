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

test_that("projects", {
    res = projects()
    expect_equal(class(res),'data.frame')
    expect_equal(ncol(res), 7)
    expect_equal(colnames(res),c('dbgap_accession_number','disease_type','released','state','primary_site','project_id','name'))
})


test_that('make_filter', {
    res = make_filter('a'=='b',toJSON = FALSE)
    expect_equal(class(res),'list')
    expect_equal(names(res),c('op','content'))
    expect_equal(res$op,jsonlite::unbox('='))
    expect_equal(res$content$field,'a')
    expect_equal(res$content$value,'b')
})


