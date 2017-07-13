library(GenomicDataCommons)
library(magrittr)
context('legacy endpoint')

## IDs here were selected interactively, just for testing.
## If GDC removes these IDs, expect tests to fail.

files_legacy_ids = files(legacy = TRUE) %>% results(size = 10) %>% ids()

cases_legacy_ids = cases(legacy = TRUE) %>% results(size = 10) %>% ids()

###########################
##
## FILES
##
###########################

## ID functionality

test_that("legacy file ids in regular archive, also", {
    fquery = files(legacy = FALSE) %>% filter( ~ file_id %in% files_legacy_ids) 
    fres = fquery %>% ids()
    expect_length(fres,10)
})

test_that("legacy file ids found", {
    fquery = files()
    fquery$legacy = TRUE
    fres = fquery %>% filter( ~ file_id %in% files_legacy_ids) %>% ids()
    expect_length(fres,length(files_legacy_ids))
    rm(fquery,fres)
})


## Manifest functionality

test_that("legacy manifest matches legacy ids", {
    fquery = files()
    fquery$legacy = TRUE
    fres = fquery %>% filter( ~ file_id %in% files_legacy_ids) %>% manifest()
    expect_equal(nrow(fres),length(files_legacy_ids))
    expect_true(all(fres$id %in% files_legacy_ids))
})

###########################
##
## Cases
##
###########################


## ID functionality

test_that("legacy case ids found", {
    cquery = cases()
    cquery$legacy = TRUE
    cres = cquery %>% filter( ~ case_id %in% cases_legacy_ids) %>% ids()
    expect_equal(length(cres),length(cases_legacy_ids))
})

# Note that case ids may be in both legacy and default archives
test_that("legacy case ids in default archive, also", {
    cquery = cases()
    cquery$legacy = FALSE
    cres = cquery %>% filter( ~ case_id %in% cases_legacy_ids) %>% ids()
    expect_equal(length(cres),10)
})

