# GenomicDataCommons

| branch | status | 
| ------ | ------ |
| Travis develop | [![Build Status](https://travis-ci.org/seandavi/GenomicDataCommons.svg?branch=develop)](https://travis-ci.org/seandavi/GenomicDataCommons)|
| Travis master  | [![Build Status](https://travis-ci.org/seandavi/GenomicDataCommons.svg?branch=master)](https://travis-ci.org/seandavi/GenomicDataCommons) |
| Appveyor develop | [![Build status](https://ci.appveyor.com/api/projects/status/2jy3whdaw6dd18fk/branch/develop?svg=true)](https://ci.appveyor.com/project/seandavi/genomicdatacommons/branch/develop) |



Provide _R_ access to the NCI [Genomic Data Commons][] portal. Some
additional detail from the [API Users Guide][] documentation may help.

This package is under development.

## Install

The package is not yet available on Bioconductor, so install directly from GitHub.

```{r}
devtools::install_github('Bioconductor/GenomicDataCommons')
```

## QuickStart

See [vignette](https://github.com/Bioconductor/GenomicDataCommons/blob/master/vignettes/overview.Rmd) for more details.

```{r}
library(GenomicDataCommons)
endpoints()            # what can you do? See help page for each endpoint
status()               # is the service up?
files(size=8)          # available experiments
lst = cases()          # first 10 cases
lst
lst[1]
lst[[1]]
lst <-                 # submitter_id, sorted descending order
    cases(fields="submitter_id", sort="submitter_id:desc")
lst
sapply(lst, "[[", "submitter_id")
```

## TODO

### Done
- [x] `manifest()` endpoint
- [x] `transfer()`: download manifest files via GDC Data Transfer Tool
- [x] Authentication
- [x] `slicing()` endpoint -- needs cleanup
- [x] filters implemented using R expression syntax
- [x] `gdcdata()` (data endpoint) -- needs download md5sums validation

### Still to go

- [ ] Develop `GenomicDataCommons` -- _Bioconductor_ API supporting
  [GenomicRanges][], [GenomicAlignments][], [VariantAnnotation][].

### WON'T DO

- [ ] implement submission

## Reference materials

[Genomic Data Commons]: https://gdc-portal.nci.nih.gov/
[API Users Guide]: https://gdc-docs.nci.nih.gov/API/Users_Guide/Getting_Started/
[GenomicRanges]: https://bioconductor.org/packages/GenomicRanges
[GenomicAlignments]: https://bioconductor.org/packages/GenomicAlignments
[VariantAnnotation]: https://bioconductor.org/packages/VariantAnnotation
[authentication token]: https://docs.gdc.cancer.gov/Data_Portal/Users_Guide/Authentication/
