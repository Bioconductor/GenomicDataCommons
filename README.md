
# GenomicDataCommons

<!-- badges: start -->

[![R-CMD-check](https://github.com/Bioconductor/GenomicDataCommons/workflows/R-CMD-check/badge.svg)](https://github.com/Bioconductor/GenomicDataCommons/actions)
<!-- badges: end -->

# What is the GDC?

From the [Genomic Data Commons (GDC)
website](https://gdc.nci.nih.gov/about-gdc):

The National Cancer Institute’s (NCI’s) Genomic Data Commons (GDC) is a
data sharing platform that promotes precision medicine in oncology. It
is not just a database or a tool; it is an expandable knowledge network
supporting the import and standardization of genomic and clinical data
from cancer research programs.

The GDC contains NCI-generated data from some of the largest and most
comprehensive cancer genomic datasets, including The Cancer Genome Atlas
(TCGA) and Therapeutically Applicable Research to Generate Effective
Therapies (TARGET). For the first time, these datasets have been
harmonized using a common set of bioinformatics pipelines, so that the
data can be directly compared.

As a growing knowledge system for cancer, the GDC also enables
researchers to submit data, and harmonizes these data for import into
the GDC. As more researchers add clinical and genomic data to the GDC,
it will become an even more powerful tool for making discoveries about
the molecular basis of cancer that may lead to better care for patients.

The [data model for the GDC is
complex](https://gdc.cancer.gov/developers/gdc-data-model/gdc-data-model-components),
but it worth a quick overview. The data model is encoded as a so-called
property graph. Nodes represent entities such as Projects, Cases,
Diagnoses, Files (various kinds), and Annotations. The relationships
between these entities are maintained as edges. Both nodes and edges may
have Properties that supply instance details. The GDC API exposes these
nodes and edges in a somewhat simplified set of
[RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer)
endpoints.

# Quickstart

This software is available at Bioconductor.org and can be downloaded via
`BiocManager::install`.

To report bugs or problems, either [submit a new
issue](https://github.com/Bioconductor/GenomicDataCommons/issues) or
submit a `bug.report(package='GenomicDataCommons')` from within R (which
will redirect you to the new issue on GitHub).

## Installation

Installation can be achieved via Bioconductor’s `BiocManager` package.

``` r
if (!require("BiocManager"))
    install.packages("BiocManager")

BiocManager::install('GenomicDataCommons')
```

``` r
library(GenomicDataCommons)
```

## Check basic functionality

``` r
status()
#> $commit
#> [1] "4dd3680528a19ed33cfc83c7d049426c97bb903b"
#> 
#> $data_release
#> [1] "Data Release 34.0 - July 27, 2022"
#> 
#> $status
#> [1] "OK"
#> 
#> $tag
#> [1] "3.0.0"
#> 
#> $version
#> [1] 1
```

## Find data

The following code builds a `manifest` that can be used to guide the
download of raw data. Here, filtering finds gene expression files
quantified as raw counts using `STAR` from ovarian cancer patients.

``` r
ge_manifest <- files() |>
    filter( cases.project.project_id == 'TCGA-OV') |>
    filter( type == 'gene_expression' ) |>
    filter( analysis.workflow_type == 'STAR - Counts') |>
    manifest(size = 5)
ge_manifest
#>                                     id data_format     access                                                                   file_name
#> 1 7c69529f-2273-4dc4-b213-e84924d78bea         TSV       open d6472bd0-b4e2-4ed1-a892-e1702c195dc7.rna_seq.augmented_star_gene_counts.tsv
#> 2 0eff4634-f8c4-4db9-8a7c-331b21689bae         TSV       open 42165baf-b32c-4fc4-8b04-29c5b4e76de0.rna_seq.augmented_star_gene_counts.tsv
#> 3 7d74b4c5-6391-4b3e-95a3-020ea0869e86         TSV controlled   accf08d4-a784-4908-831a-7a08d4c5f0f5.rna_seq.star_splice_junctions.tsv.gz
#> 4 dc2aeea4-3cd0-4623-92f4-bbbc962851cc         TSV controlled   8ab508b9-2993-4e66-b8f9-81e32e936d4a.rna_seq.star_splice_junctions.tsv.gz
#> 5 0cf852be-d2e3-4fde-bba8-c93efae2961a         TSV       open 93831282-1dd1-49a3-acd7-dae2a49ca62e.rna_seq.augmented_star_gene_counts.tsv
#>                           submitter_id           data_category       acl            type file_size                 created_datetime                           md5sum
#> 1 7085a70b-2f63-4402-9e53-70f091f26fcb Transcriptome Profiling      open gene_expression   4254435 2021-12-13T20:53:42.329364-06:00 19d5596bba8949f4c138793608497d56
#> 2 f0d44930-b1ad-447a-86b9-27d0285954b9 Transcriptome Profiling      open gene_expression   4257461 2021-12-13T20:47:24.326497-06:00 d89d71b7c028c1643d7a3ee7857d8e01
#> 3 e6473134-6d65-414c-9f52-2c25057fac7d Transcriptome Profiling phs000178 gene_expression   3109435 2021-12-13T21:03:56.008440-06:00 fb8332d6413c44a9de02a1cbe6b018aa
#> 4 f99b93a9-70cb-44f8-bd1f-4edeee4425a4 Transcriptome Profiling phs000178 gene_expression   4607701 2021-12-13T21:02:23.944851-06:00 26231bed1ef67c093d3ce2b39def81cd
#> 5 fb4d7abe-b61a-4f35-9700-605f1bc1512f Transcriptome Profiling      open gene_expression   4265694 2021-12-13T20:50:55.234254-06:00 050763aabd36509f954137fbdc4eeb00
#>                   updated_datetime                              file_id                      data_type    state experimental_strategy
#> 1 2022-01-19T14:47:28.965154-06:00 7c69529f-2273-4dc4-b213-e84924d78bea Gene Expression Quantification released               RNA-Seq
#> 2 2022-01-19T14:47:07.478144-06:00 0eff4634-f8c4-4db9-8a7c-331b21689bae Gene Expression Quantification released               RNA-Seq
#> 3 2022-01-19T14:01:15.621847-06:00 7d74b4c5-6391-4b3e-95a3-020ea0869e86 Splice Junction Quantification released               RNA-Seq
#> 4 2022-01-19T14:01:15.621847-06:00 dc2aeea4-3cd0-4623-92f4-bbbc962851cc Splice Junction Quantification released               RNA-Seq
#> 5 2022-01-19T14:47:07.036781-06:00 0cf852be-d2e3-4fde-bba8-c93efae2961a Gene Expression Quantification released               RNA-Seq
```

## Download data

This code block downloads the 5 gene expression files specified in the
query above. Using multiple processes to do the download very
significantly speeds up the transfer in many cases. The following
completes in about 15 seconds.

``` r
library(BiocParallel)
register(MulticoreParam())
destdir <- tempdir()
fnames <- lapply(ge_manifest$id,gdcdata)
```

If the download had included controlled-access data, the download above
would have needed to include a `token`. Details are available in [the
authentication section below](#authentication).

## Metadata queries

Here we use a couple of ad-hoc helper functions to handle the output of
the query. See the `inst/script/README.Rmd` folder for the source.

First, create a `data.frame` from the clinical data:

``` r
expands <- c("diagnoses","annotations",
             "demographic","exposures")
clinResults <- cases() |>
    GenomicDataCommons::select(NULL) |>
    GenomicDataCommons::expand(expands) |>
    results(size=6)
demoDF <- filterAllNA(clinResults$demographic)
exposuresDF <- bindrowname(clinResults$exposures)
```

``` r
demoDF[, 1:4]
#>                                      cause_of_death         race gender              ethnicity
#> 2525bfef-6962-4b7f-8e80-6186400ce624           <NA> not reported female           not reported
#> 126507c3-c0d7-41fb-9093-7deed5baf431 Cancer Related not reported female           not reported
#> c43ac461-9f03-44bc-be7d-3d867eb708a0           <NA> not reported female           not reported
#> a59a90d9-f1b0-49dd-9c97-bcaa6ba55d44 Cancer Related not reported   male           not reported
#> 59122a43-606a-4669-806b-6747e0ac9985           <NA>        white   male not hispanic or latino
#> 4447a969-e5c8-4291-b83c-53a0f7e77cbc Cancer Related        white female not hispanic or latino
```

``` r
exposuresDF[, 1:4]
#>                                       submitter_id                 created_datetime    alcohol_intensity pack_years_smoked
#> 2525bfef-6962-4b7f-8e80-6186400ce624 C3N-03839-EXP 2019-12-30T10:23:07.190853-06:00 Lifelong Non-Drinker                NA
#> 126507c3-c0d7-41fb-9093-7deed5baf431 C3N-01518-EXP 2018-06-21T14:27:48.817254-05:00 Lifelong Non-Drinker                NA
#> c43ac461-9f03-44bc-be7d-3d867eb708a0 C3N-03933-EXP 2019-03-14T08:23:14.054975-05:00 Lifelong Non-Drinker                NA
#> a59a90d9-f1b0-49dd-9c97-bcaa6ba55d44 C3N-02695-EXP 2019-03-14T08:23:14.054975-05:00   Occasional Drinker              16.8
#> 59122a43-606a-4669-806b-6747e0ac9985 C3L-03642-EXP 2019-06-24T07:53:15.534197-05:00 Lifelong Non-Drinker              39.0
#> 4447a969-e5c8-4291-b83c-53a0f7e77cbc C3L-03728-EXP 2019-06-24T07:53:15.534197-05:00 Lifelong Non-Drinker                NA
```

Note that the diagnoses data has multiple lines per patient:

``` r
diagDF <- bindrowname(clinResults$diagnoses)
diagDF[, 1:4]
#>                                      ajcc_pathologic_stage                 created_datetime tissue_or_organ_of_origin age_at_diagnosis
#> 2525bfef-6962-4b7f-8e80-6186400ce624             Stage IIB 2019-07-22T06:40:02.183501-05:00          Head of pancreas            19956
#> 126507c3-c0d7-41fb-9093-7deed5baf431          Not Reported 2018-12-03T12:05:16.846188-06:00             Temporal lobe            26312
#> c43ac461-9f03-44bc-be7d-3d867eb708a0             Stage III 2019-03-14T10:37:34.405260-05:00       Floor of mouth, NOS            25635
#> a59a90d9-f1b0-49dd-9c97-bcaa6ba55d44          Not Reported 2019-03-14T10:37:34.405260-05:00       Floor of mouth, NOS            16652
#> 59122a43-606a-4669-806b-6747e0ac9985          Not Reported 2019-07-22T06:40:02.183501-05:00          Upper lobe, lung            23384
#> 4447a969-e5c8-4291-b83c-53a0f7e77cbc          Not Reported 2019-05-07T07:41:33.411909-05:00              Frontal lobe            29326
```

# Basic design

This package design is meant to have some similarities to the
“tidyverse” approach of dplyr. Roughly, the functionality for finding
and accessing files and metadata can be divided into:

1.  Simple query constructors based on GDC API endpoints.
2.  A set of verbs that when applied, adjust filtering, field selection,
    and faceting (fields for aggregation) and result in a new query
    object (an endomorphism)
3.  A set of verbs that take a query and return results from the GDC

In addition, there are auxiliary functions for asking the GDC API for
information about available and default fields, slicing BAM files, and
downloading actual data files. Here is an overview of functionality[^1].

-   Creating a query
    -   `projects()`
    -   `cases()`
    -   `files()`
    -   `annotations()`
-   Manipulating a query
    -   `filter()`
    -   `facet()`
    -   `select()`
-   Introspection on the GDC API fields
    -   `mapping()`
    -   `available_fields()`
    -   `default_fields()`
    -   `grep_fields()`
    -   `available_values()`
    -   `available_expand()`
-   Executing an API call to retrieve query results
    -   `results()`
    -   `count()`
    -   `response()`
-   Raw data file downloads
    -   `gdcdata()`
    -   `transfer()`
    -   `gdc_client()`
-   Summarizing and aggregating field values (faceting)
    -   `aggregations()`
-   Authentication
    -   `gdc_token()`
-   BAM file slicing
    -   `slicing()`

[^1]: See individual function and methods documentation for specific
    details.
