# GenomicDataCommons

Travis: [![Build Status](https://travis-ci.org/seandavi/GenomicDataCommons.svg?branch=master)](https://travis-ci.org/seandavi/GenomicDataCommons)

Provide _R_ access to the NCI [Genomic Data Commons][] portal. Some
additional detail from the [API Users Guide][] documentation may help.

This package is under development.

## QuickStart

```{r}
library(GenomicDataCommons)
endpoints()            # what can you do? See help page for each endpoint
status()               # is the service up?
experiments(size=100)  # available experiments
lst = cases()          # first 10 cases
lst
lst[1]
lst[[1]]
lst <-                 # submitter_id, sorted descending order
    cases(fields="submitter_id", sort="submitter_id:desc")
lst
sapply(lst, "[[", "submitter_id")
```

Accessing restricted data requires an [authentication token][]. This
in turn requires eRA and dbGAP access. Provide the token as a
character string (or, for `manifest()`, a file path).

```{r}
slicing("df80679e-c4d3-487b-934c-fcc782e5d46e", symbols=c("BRCA1", "BRCA2"),
        token=token)
```

See [vignette](https://github.com/Bioconductor/GenomicDataCommons/blob/master/vignettes/overview.Rmd) for more details.


## TODO

- [x] `manifest()` endpoint
- [x] `transfer()`: download manifest files via GDC Data Transfer Tool
- [x] Authentication
- [x] `slicing()` endpoint
- [ ] filters
- [ ] `gdcdata()` (data endpoint) download md5sums validation
- [ ] validate slicing 'regions' argument
- [ ] Rename as 'gdc' -- accessing gdc portal, without _Bioconductor_
  dependencies
- [ ] Develop `GenomicDataCommons` -- _Bioconductor_ API supporting
  [GenomicRanges][], [GenomicAlignments][], [VariantAnnotation][].

## WON'T DO

- [ ] implement submission

[Genomic Data Commons]: https://gdc-portal.nci.nih.gov/
[API Users Guide]: https://gdc-docs.nci.nih.gov/API/Users_Guide/Getting_Started/
[GenomicRanges]: https://bioconductor.org/packages/GenomicRanges
[GenomicAlignments]: https://bioconductor.org/packages/GenomicAlignments
[VariantAnnotation]: https://bioconductor.org/packages/VariantAnnotation
[authentication token]: https://gdc-docs.nci.nih.gov/API/Users_Guide/Authentication_and_Authorization/
