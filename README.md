# GenomicDataCommons

Provide _R_ access to the NCI [Genomic Data Commons][] portal.

This package is under development.

## TODO

- [x] manifest endpoint
- [ ] slicing endpoint
- [x] `transfer()`: download manifest files via GDC Data Transfer Tool
- [ ] Authentication
- [ ] gdcdata() (data endpoint) download md5sums validation
- [ ] Rename as 'gdc' -- accessing gdc portal, without _Bioconductor_
  dependencies
- [ ] Develop `GenomicDataCommons` -- _Bioconductor_ API supporting
  [GenomicRanges][], [GenomicAlignments][], [VariantAnnotation][].

Will not implement submission.

[Genomic Data Commons]: https://gdc-portal.nci.nih.gov/
[GenomicRanges]: https://bioconductor.org/packages/GenomicRanges
[GenomicAlignments]: https://bioconductor.org/packages/GenomicAlignments
[VariantAnnotation]: https://bioconductor.org/packages/VariantAnnotation
