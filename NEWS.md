## Changes in version 1.28.0

* Defunct legacy function, methods, endpoints, and arguments (@LiNk-NY)

## Changes in version 1.26.0

### New features

* The GDC API has deprecated the legacy endpoint (#110, @LiNk-NY) 

## Changes in version 1.24.0

### Bug fixes and minor improvements

* `gdc_clinical` handles `NULL` responses when diagnoses are not available for
all IDs queried (#109, @zx8754).
* Minor updates to somatic mutations vignette and unit tests.

## Changes in version 1.20.0

### New features

* `gdcdata` has an ellipses argument to download data from the legacy archive,
  e.g., `legacy = TRUE` (#84, @LiNk-NY)
* `missing` (`is MISSING`) and `!missing` (`NOT MISSING`) operations implemented
for filtering queries, see vignette (#96, @LiNk-NY)
* `gdc-client` version can be validated against last known good version based on
data release (#99, @LiNk-NY)

### Bug fixes and minor improvements

* `gdc_clinical` uses `readr::type_convert` to handle columns with inconsistent
  types from the API.
* update examples in documentation and vignette based on new data release
