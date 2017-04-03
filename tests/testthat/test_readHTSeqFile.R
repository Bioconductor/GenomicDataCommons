library(GenomicDataCommons)
context('readHTSeqFile')

test_that("readHTSeqFile works on example data", {
    dat = readHTSeqFile(system.file(package="GenomicDataCommons",
                                    'extdata/example.htseq.counts.gz'))
    expect_equal(nrow(dat),50)
    expect_equal(ncol(dat),2)
})
