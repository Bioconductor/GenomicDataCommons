## Changes in version 1.20.0

### New features

* `gdcdata` has an ellipses argument to download data from the legacy archive,
  e.g., `legacy = TRUE` (#84, @LiNk-NY)

### Bug fixes and minor improvements

* `gdc_clinical` uses `readr::type_convert` to handle columns with inconsistent
  types from the API.
