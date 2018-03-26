# What is the GDC?

From the [Genomic Data Commons (GDC) website](https://gdc.nci.nih.gov/about-gdc):

The National Cancer Institute's (NCI's) Genomic Data Commons (GDC) is
a data sharing platform that promotes precision medicine in
oncology. It is not just a database or a tool; it is an expandable
knowledge network supporting the import and standardization of genomic
and clinical data from cancer research programs.

The GDC contains NCI-generated data from some of the largest and most
comprehensive cancer genomic datasets, including The Cancer Genome
Atlas (TCGA) and Therapeutically Applicable Research to Generate
Effective Therapies (TARGET). For the first time, these datasets have
been harmonized using a common set of bioinformatics pipelines, so
that the data can be directly compared.

As a growing knowledge system for cancer, the GDC also enables
researchers to submit data, and harmonizes these data for import into
the GDC. As more researchers add clinical and genomic data to the GDC,
it will become an even more powerful tool for making discoveries about
the molecular basis of cancer that may lead to better care for
patients.

The
[data model for the GDC is complex](https://gdc.cancer.gov/developers/gdc-data-model/gdc-data-model-components),
but it worth a quick overview. The data model is encoded as a
so-called property graph. Nodes represent entities such as Projects,
Cases, Diagnoses, Files (various kinds), and Annotations. The
relationships between these entities are maintained as edges.  Both
nodes and edges may have Properties that supply instance details.  The
GDC API exposes these nodes and edges in a somewhat simplified set
of
[RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer) endpoints.


# Quickstart

This software is in development and will *likely change in response to user feedback*. To report bugs or problems, either
[submit a new issue](https://github.com/Bioconductor/GenomicDataCommons/issues) or submit a `bug.report(package='GenomicDataCommons')` from within R (which will redirect you to the new issue on GitHub).

## Installation

Installation is available from GitHub as of now. 

```r
source('https://bioconductor.org/biocLite.R')
biocLite('Bioconductor/GenomicDataCommons')
```

```r
library(GenomicDataCommons)
```

## Check basic functionality

```r
GenomicDataCommons::status()
```

## Find data

The following code builds a `manifest` that can be used to guide the
download of raw data. Here, filtering finds gene expression files
quantified as raw counts using `HTSeq` from ovarian cancer patients.

```r
library(magrittr)
ge_manifest = files() %>% 
    filter( ~ cases.project.project_id == 'TCGA-OV' &
                type == 'gene_expression' &
                analysis.workflow_type == 'HTSeq - Counts') %>%
    manifest()
```

## Download data

This code block downloads the `r nrow(ge_manifest)` gene expression files specified in the query above. Using multiple processes to do the download very significantly speeds up the transfer in many cases.  On a standard 1Gb connection using 10 processes, the following completes in about 15 seconds.

```r
library(BiocParallel)
register(MulticoreParam())
destdir = tempdir()
fnames = bplapply(ge_manifest$id,gdcdata,
                  destination_dir=destdir,
                  BPPARAM = MulticoreParam(progressbar=TRUE))
```

If the download had included controlled-access data, the download above would have needed to include a `token`.  Details are available in [the authentication section below](#authentication).

## Metadata queries

```r
expands = c("diagnoses","annotations",
             "demographic","exposures")
clinResults = cases() %>% 
    GenomicDataCommons::select(NULL) %>%
    GenomicDataCommons::expand(expands) %>% 
    results(size=50)
clinDF = as.data.frame(clinResults)
library(DT)
datatable(clinDF, extensions = 'Scroller', options = list(
  deferRender = TRUE,
  scrollY = 200,
  scrollX = TRUE,
  scroller = TRUE
))
```
# Basic design

This package design is meant to have some similarities to the "hadleyverse" approach of dplyr. Roughly, the functionality for finding and accessing files and metadata can be divided into:

1. Simple query constructors based on GDC API endpoints.
2. A set of verbs that when applied, adjust filtering, field selection, and faceting (fields for aggregation) and result in a new query object (an endomorphism)
3. A set of verbs that take a query and return results from the GDC

In addition, there are exhiliary functions for asking the GDC API for information about available and default fields, slicing BAM files, and downloading actual data files.  Here is an overview of functionality[^1].


- Creating a query
    - `projects()`
    - `cases()`
    - `files()`
    - `annotations()`
- Manipulating a query
    - `filter()`
    - `facet()`
    - `select()`
- Introspection on the GDC API fields
    - `mapping()`
    - `available_fields()`
    - `default_fields()`
    - `grep_fields()`
    - `field_picker()`
    - `available_values()`
    - `available_expand()`
- Executing an API call to retrieve query results
    - `results()`
    - `count()`
    - `response()`
- Raw data file downloads
    - `gdcdata()`
    - `transfer()`
    - `gdc_client()`
- Summarizing and aggregating field values (faceting)
    - `aggregations()`
- Authentication
    - `gdc_token()`
- BAM file slicing
    - `slicing()`

[^1]: See individual function and methods documentation for specific details.
