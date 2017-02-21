library(GenomicDataCommons)
context('API')

## IDs here were selected interactively, just for testing.
## If GDC removes these IDs, expect tests to fail.

files_legacy_ids =
    c("97a4a0b6-e20c-41c0-a275-e0c51cd01235", "0b0eb3ed-8eee-48b1-b32a-3a6eb322742c", 
      "d91f771a-a2df-4105-bff3-f0b97576c96e", "e2f4c25f-7f30-4c11-bbd3-60813cb14ec8", 
      "54f75458-3ea1-476c-abca-859f90bff51a", "505a4951-0490-4128-a54e-96aaccbccf29", 
      "fa8af763-e424-4efa-a9d8-c73c5c54ce81", "2aa175f4-ebd4-4159-addd-f03f4a201e56", 
      "efa7f252-11b3-46cb-a3de-69bfbc6dc814", "99e1b6c1-421d-427e-8402-4cedaf4df865"
      )

cases_legacy_ids =
    c("eb7c3b35-7a5e-4621-b31f-9775c51f9a23", "c7b3ac87-5260-4042-895a-279cd8cda620", 
      "8631bb5e-6d08-4c20-a85e-cb84f5dac290", "aeec3005-25d7-45fc-a9ff-014d57960216", 
      "d8f028b9-b958-5d3b-b384-864e67f1d13b", "d7641ca1-a062-4dd2-9414-447af7311a84", 
      "7fd45d0f-75b9-50b0-a232-a725663cf2ae", "3d5a904a-3834-45bf-9212-c06d46d917f9", 
      "c777a777-373a-4773-9566-6c373261f00a", "c781b49e-d08f-49e6-b774-7cfe4100e92d"
      )

###########################
##
## FILES
##
###########################

## ID functionality

test_that("legacy file ids only in legacy archive", {
    fquery = files() %>% filter( ~ file_id %in% files_legacy_ids) 
    fres = fquery %>% ids()
    expect_length(fres,0)
})

test_that("legacy file ids found", {
    fquery = files()
    fquery$archive = "legacy"
    fres = fquery %>% filter( ~ file_id %in% files_legacy_ids) %>% ids()
    expect_length(fres,length(files_legacy_ids))
    rm(fquery,fres)
})


## Manifest functionality

test_that("legacy manifest matches legacy ids", {
    fquery = files()
    fquery$archive = "legacy"
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
    cquery$archive = "legacy"
    cres = cquery %>% filter( ~ case_id %in% cases_legacy_ids) %>% ids()
    expect_equal(length(cres),length(cases_legacy_ids))
})

# Note that case ids may be in both legacy and default archives
test_that("legacy case ids in default archive, also", {
    cquery = cases()
    cquery$archive = "default"
    cres = cquery %>% filter( ~ case_id %in% cases_legacy_ids) %>% ids()
    expect_equal(length(cres),10)
})

## Manifest functionality

test_that("legacy cases manifest matches", {
    cquery = cases()
    cquery$archive = "legacy"
    cres = cquery %>% filter( ~ files.file_id %in% files_legacy_ids) %>% manifest()
    # note that this is not a one-to-one, so use gte rather than equal
    expect_gte(nrow(cres),length(files_legacy_ids))
    expect_true(all(files_legacy_ids %in% cres$id))
})
