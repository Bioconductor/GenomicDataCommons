
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
#> [1] "d05a8530c733492e038fc2c3fda7c47a000652df"
#> 
#> $data_release
#> [1] "Data Release 32.0 - March 29, 2022"
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
    manifest()
ge_manifest
#> # A tibble: 762 × 5
#>    id                                   filename              md5     size state
#>  * <chr>                                <chr>                 <chr>  <dbl> <chr>
#>  1 7c69529f-2273-4dc4-b213-e84924d78bea d6472bd0-b4e2-4ed1-a… 19d5… 4.25e6 rele…
#>  2 0eff4634-f8c4-4db9-8a7c-331b21689bae 42165baf-b32c-4fc4-8… d89d… 4.26e6 rele…
#>  3 7d74b4c5-6391-4b3e-95a3-020ea0869e86 accf08d4-a784-4908-8… fb83… 3.11e6 rele…
#>  4 dc2aeea4-3cd0-4623-92f4-bbbc962851cc 8ab508b9-2993-4e66-b… 2623… 4.61e6 rele…
#>  5 0cf852be-d2e3-4fde-bba8-c93efae2961a 93831282-1dd1-49a3-a… 0507… 4.27e6 rele…
#>  6 d33ad23e-2413-419c-8b0b-93ed00583033 bffe7439-0f9b-422f-b… 1bba… 4.47e6 rele…
#>  7 d4cc00b7-5a9a-4efa-8334-708dbefe76fa fb8ee269-a38b-47ef-b… 2044… 4.25e6 rele…
#>  8 1b45742e-4c91-4b8f-8a2b-f144479557a4 cd96deaf-e1fa-40b4-8… 92d5… 3.80e6 rele…
#>  9 a1ea0a4b-cd16-4436-9e9f-dd7e718ee858 fb8ee269-a38b-47ef-b… 5980… 3.46e6 rele…
#> 10 fbeb5543-22e0-49e0-a77c-f050e748315c 09afd98b-1da0-4de9-b… 1438… 4.23e6 rele…
#> # … with 752 more rows
```

## Download data

This code block downloads the 762 gene expression files specified in the
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
#>                                      cause_of_death  race gender
#> 4829dd8c-5445-41b3-ae37-bbcc333e8c9e Cancer Related white female
#> d420e653-3fb2-432b-9e81-81232a80264d Cancer Related white female
#> bfe15f44-e1dd-46ed-b429-908822d0a781           <NA> white   male
#> 8b3b1f24-419e-4043-82be-2bd41268bb0e           <NA> white female
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8 Cancer Related white   male
#> 47322ea3-6bbe-442b-a656-c48469cc99c1           <NA> white   male
#>                                                   ethnicity
#> 4829dd8c-5445-41b3-ae37-bbcc333e8c9e                Unknown
#> d420e653-3fb2-432b-9e81-81232a80264d not hispanic or latino
#> bfe15f44-e1dd-46ed-b429-908822d0a781 not hispanic or latino
#> 8b3b1f24-419e-4043-82be-2bd41268bb0e not hispanic or latino
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8                Unknown
#> 47322ea3-6bbe-442b-a656-c48469cc99c1 not hispanic or latino
```

``` r
exposuresDF[, 1:4]
#>                                      alcohol_days_per_week
#> 4829dd8c-5445-41b3-ae37-bbcc333e8c9e                    NA
#> d420e653-3fb2-432b-9e81-81232a80264d                    NA
#> bfe15f44-e1dd-46ed-b429-908822d0a781                    NA
#> 8b3b1f24-419e-4043-82be-2bd41268bb0e                    NA
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8                     0
#> 47322ea3-6bbe-442b-a656-c48469cc99c1                    NA
#>                                                alcohol_drinks_per_day
#> 4829dd8c-5445-41b3-ae37-bbcc333e8c9e 2020-07-31T09:25:24.402855-05:00
#> d420e653-3fb2-432b-9e81-81232a80264d 2020-02-27T13:00:21.361098-06:00
#> bfe15f44-e1dd-46ed-b429-908822d0a781 2020-02-27T12:37:46.290948-06:00
#> 8b3b1f24-419e-4043-82be-2bd41268bb0e 2019-05-15T13:02:25.351730-05:00
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8 2020-06-15T12:57:49.021995-05:00
#> 47322ea3-6bbe-442b-a656-c48469cc99c1 2020-09-17T16:10:31.527022-05:00
#>                                      smokeless_tobacco_quit_age
#> 4829dd8c-5445-41b3-ae37-bbcc333e8c9e                       <NA>
#> d420e653-3fb2-432b-9e81-81232a80264d                       <NA>
#> bfe15f44-e1dd-46ed-b429-908822d0a781                       <NA>
#> 8b3b1f24-419e-4043-82be-2bd41268bb0e                       <NA>
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8                         No
#> 47322ea3-6bbe-442b-a656-c48469cc99c1                       <NA>
#>                                      created_datetime
#> 4829dd8c-5445-41b3-ae37-bbcc333e8c9e                4
#> d420e653-3fb2-432b-9e81-81232a80264d                1
#> bfe15f44-e1dd-46ed-b429-908822d0a781                1
#> 8b3b1f24-419e-4043-82be-2bd41268bb0e                1
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8                7
#> 47322ea3-6bbe-442b-a656-c48469cc99c1                2
```

Note that the diagnoses data has multiple lines per patient:

``` r
diagDF <- bindrowname(clinResults$diagnoses)
diagDF[, 1:4]
#>                                        gleason_patterns_percent
#> 4829dd8c-5445-41b3-ae37-bbcc333e8c9e                       <NA>
#> d420e653-3fb2-432b-9e81-81232a80264d                       <NA>
#> bfe15f44-e1dd-46ed-b429-908822d0a781                    Stage I
#> 8b3b1f24-419e-4043-82be-2bd41268bb0e                    Stage I
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8                   Stage IV
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8.1                     <NA>
#> 47322ea3-6bbe-442b-a656-c48469cc99c1                  Stage IIB
#> 47322ea3-6bbe-442b-a656-c48469cc99c1.1                     <NA>
#>                                                   ajcc_pathologic_stage
#> 4829dd8c-5445-41b3-ae37-bbcc333e8c9e   2020-07-31T09:25:24.402855-05:00
#> d420e653-3fb2-432b-9e81-81232a80264d   2020-02-27T13:00:21.361098-06:00
#> bfe15f44-e1dd-46ed-b429-908822d0a781   2020-02-27T12:37:46.290948-06:00
#> 8b3b1f24-419e-4043-82be-2bd41268bb0e   2019-05-15T13:02:25.351730-05:00
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8   2020-06-15T12:57:49.021995-05:00
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8.1 2020-06-15T12:57:49.021995-05:00
#> 47322ea3-6bbe-442b-a656-c48469cc99c1   2020-09-17T16:10:31.527022-05:00
#> 47322ea3-6bbe-442b-a656-c48469cc99c1.1 2020-09-17T16:10:31.527022-05:00
#>                                        ann_arbor_clinical_stage
#> 4829dd8c-5445-41b3-ae37-bbcc333e8c9e                Rectum, NOS
#> d420e653-3fb2-432b-9e81-81232a80264d                 Brain, NOS
#> bfe15f44-e1dd-46ed-b429-908822d0a781                 Colon, NOS
#> 8b3b1f24-419e-4043-82be-2bd41268bb0e                Rectum, NOS
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8                  Bone, NOS
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8.1                Bone, NOS
#> 47322ea3-6bbe-442b-a656-c48469cc99c1                  Skin, NOS
#> 47322ea3-6bbe-442b-a656-c48469cc99c1.1                Skin, NOS
#>                                        created_datetime
#> 4829dd8c-5445-41b3-ae37-bbcc333e8c9e              17316
#> d420e653-3fb2-432b-9e81-81232a80264d              19586
#> bfe15f44-e1dd-46ed-b429-908822d0a781              27431
#> 8b3b1f24-419e-4043-82be-2bd41268bb0e              25784
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8               3585
#> fa30fc7f-90b6-4ca0-93b6-1351eae9dfc8.1             4038
#> 47322ea3-6bbe-442b-a656-c48469cc99c1              22537
#> 47322ea3-6bbe-442b-a656-c48469cc99c1.1            22597
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
