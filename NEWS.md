# GenomicDataCommons 0.99.8

## API changes

* `results()` now accepts `size`, `from` to allow paging
* legacy archive now supported throughout by setting `legacy=TRUE` on any
  query object.

## New features

* `as.data.frame()` allows a robust if not entirely complete conversion
  of `GDCResults` to `data.frame`.


## Bug Fixes

* many--this is beta software

# GenomicDataCommons 0.99.6

* Now using `fromJSON` with `simplifyDataFrame=TRUE` for parsing and
  returning values to R
* Parsed results now contain ids in the names (or rownames)
* `expand()` is now available, in addition to select.
  See
  [expand docs](https://docs.gdc.cancer.gov/API/Users_Guide/Search_and_Retrieval/#expand)

