# GenomicDataCommons 0.99.7

## API changes

* `results()` now accepts `size`, `from` to allow paging

## New features

## Bug Fixes



# GenomicDataCommons 0.99.6

* Now using `fromJSON` with `simplifyDataFrame=TRUE` for parsing and
  returning values to R
* Parsed results now contain ids in the names (or rownames)
* `expand()` is now available, in addition to select.
  See
  [expand docs](https://docs.gdc.cancer.gov/API/Users_Guide/Search_and_Retrieval/#expand)

