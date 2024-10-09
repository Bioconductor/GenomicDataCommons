library(GenomicDataCommons)
library(magrittr)
context('API')

test_that("status returns correctly", {
    res <- status()
    metadata_nms <- c(
        "commit", "data_release", "data_release_version",
        "status", "tag", "version"
    )
    expect_identical(names(res), metadata_nms)
    expect_identical(res$status, "OK")
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
    idfield = "case_id"
    q = cases()
    resp = q %>% response()
    expect_gte(q %>% count(),1000)
    expect_equal(select(q,idfield)$fields,idfield)
    expect_equal(facet(q,idfield)$facets,idfield)
})

test_that("files", {
    q = files()
    idfield = "file_id"
    resp = q %>% response()
    expect_gte(q %>% count(),1000)
    expect_equal(select(q,idfield)$fields,idfield)
    expect_equal(facet(q,idfield)$facets,idfield)
})

test_that("annotations", {
    q = annotations()
    idfield = "annotation_id"
    resp = q %>% response()
    expect_gte(q %>% count(),1000)
    expect_equal(select(q,idfield)$fields,idfield)
    expect_equal(facet(q,idfield)$facets,idfield)
})

test_that("mapping", {
    res = mapping('files')
    expect_equal(class(res),'data.frame')
    expect_equal(ncol(res), 6)
    expect_equal(colnames(res),c('field','description','doc_type','full','type','defaults'))
})

test_that("projects", {
    q = projects()
    idfield = "project_id"
    resp = q %>% response()
    expect_gte(q %>% count(),35)
    expect_equal(select(q,idfield)$fields,idfield)
    expect_equal(facet(q,idfield)$facets,idfield)
})
