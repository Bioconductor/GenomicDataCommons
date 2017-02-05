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

```{r libraries, message=FALSE}
library(GenomicDataCommons)
```

# Use Cases

## Cases endpoint

### How many cases are there per project_id?

```{r casesPerProject}
res = cases() %>% facet("project.project_id") %>% aggregations()
head(res)
library(ggplot2)
ggplot(res$project.project_id,aes(x = key, y = doc_count)) +
    geom_bar(stat='identity') +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) 
```

### How many cases are included in all TARGET projects?

```{r casesInTCGA}
cases() %>% filter(~ project.program.name=='TARGET') %>% count()
```

### How many cases are included in all TCGA projects?

```{r casesInTARGET}
cases() %>% filter(~ project.program.name=='TCGA') %>% count()
```

### What is the breakdown of sample types in TCGA-BRCA?

```{r casesTCGABRCASampleTypes}
# The need to do the "&" here is a requirement of the
# current version of the GDC API. I have filed a feature
# request to remove this requirement.
resp = cases() %>% filter(~ project.project_id=='TCGA-BRCA' &
                              project.project_id=='TCGA-BRCA' ) %>%
    facet('samples.sample_type') %>% aggregations()
resp$samples.sample_type
```

### Fetch all samples in TCGA-BRCA that use "Solid Tissue" as a normal.

```{r casesTCGABRCASolidNormal}
# The need to do the "&" here is a requirement of the
# current version of the GDC API. I have filed a feature
# request to remove this requirement.
resp = cases() %>% filter(~ project.project_id=='TCGA-BRCA' &
                              samples.sample_type=='Solid Tissue Normal') %>%
    GenomicDataCommons::select(c(default_fields(cases()),'samples.sample_type')) %>%
    response_all()
count(resp)
res = resp %>% results()
str(res[1],list.len=6)
head(ids(resp))
```

The `listviewer` package is a great way to look into moderately-sized result sets
in an interactive web page (or, as here, embedded in an rmarkdown document).

```{r casesListViewer}
library(listviewer)
jsonedit(res)
```

## Files endpoint

### How many of each type of file are available?

```{r filesTypeCount}
res = files() %>% facet(c('type','data_type')) %>% aggregations()
res$type
ggplot(res$type,aes(x = key,y = doc_count)) + geom_bar(stat='identity') +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))     
```

### How many of each type of file are available?

```{r filesVCFCount}
res = files() %>% facet('type') %>% aggregations()
res$type
ggplot(res$type,aes(x = key,y = doc_count)) + geom_bar(stat='identity') +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))     
```

### Find gene-level RNA-seq quantification files for GBM

```{r filesRNAseqGeneGBM}
q = files() %>%
    GenomicDataCommons::select(available_fields('files')) %>%
    filter(~ cases.project.project_id=='TCGA-GBM' &
               data_type=='Gene Expression Quantification')
q %>% facet('analysis.workflow_type') %>% aggregations()
# so need to add another filter
file_ids = q %>% filter(~ cases.project.project_id=='TCGA-GBM' &
                            data_type=='Gene Expression Quantification' &
                            analysis.workflow_type == 'HTSeq - Counts') %>%
    GenomicDataCommons::select('file_id') %>%
    response_all() %>%
    ids()
```

## Downloading data

See API vignette.

## Slicing 

### Get all BAM file ids from TCGA-GBM

**I need to figure out how to do slicing reproducibly in a testing environment and for vignette building**.

```{r filesRNAseqGeneGBMforBAM}
q = files() %>%
    GenomicDataCommons::select(available_fields('files')) %>%
    filter(~ cases.project.project_id == 'TCGA-GBM' &
               data_type == 'Aligned Reads' &
               experimental_strategy == 'RNA-Seq' &
               data_format == 'BAM')
file_ids = q %>% GenomicDataCommons::select('file_id') %>% response_all() %>% ids()
```


```{r slicing10}
# bamfile = slicing(file_ids[1],regions="chr12:6534405-6538375",token=token)
library(GenomicAlignments)
# aligns = readGAlignments(bamfile)
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
