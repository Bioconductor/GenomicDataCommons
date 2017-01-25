library(GenomicDataCommons)
context('API')

test_that("status returns correctly", {
    res = status()
    expect_equal(length(res), 4)
})

test_that('query', {
    gCases = query('cases')
    expect_equal(class(gCases)[1],'gdc_cases')
    expect_equal(class(gCases)[2],'GDCQuery')
    expect_equal(class(gCases)[3],'list')
    gFiles = query('files')
    expect_equal(class(gFiles)[1],'gdc_files')
    expect_equal(class(gFiles)[2],'GDCQuery')
    expect_equal(class(gFiles)[3],'list')
    gProjects = query('projects')
    expect_equal(class(gProjects)[1],'gdc_projects')
    expect_equal(class(gProjects)[2],'GDCQuery')
    expect_equal(class(gProjects)[3],'list')
    gAnnotations = query('annotations')
    expect_equal(class(gAnnotations)[1],'gdc_annotations')
    expect_equal(class(gAnnotations)[2],'GDCQuery')
    expect_equal(class(gAnnotations)[3],'list')
})

test_that("cases", {
    res = cases()
})

test_that("files", {
    res = files()
})

test_that("annotations", {
    res = annotations()
})

test_that("mapping", {
    res = mapping('files')
    expect_equal(class(res),'data.frame')
    expect_equal(ncol(res), 9)
    expect_equal(colnames(res),c('description','doc_type','field','full','type','defaults','expand','multi','nested'))
})

test_that("projects", {
    res = projects()
})



