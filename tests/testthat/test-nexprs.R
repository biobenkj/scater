## Test the nexprs() function. 
## library(scater); library(testthat); source("setup-sce.R"); source("test-nexprs.R")

original <- sce

test_that("nexprs works as expected", {
    expect_equal(nexprs(original), colSums(counts(original) > 0))
    expect_equal(nexprs(original), nexprs(counts(original)))

    expect_equal(nexprs(original, byrow = TRUE), rowSums(counts(original) > 0))
    expect_equal(nexprs(original, byrow = TRUE), nexprs(counts(original), byrow = TRUE))
})

test_that("nexprs responds to subsetting", {
    expect_equal(nexprs(original, subset_row = 20:40), colSums(counts(original)[20:40,] > 0))
    expect_equal(nexprs(original, byrow = TRUE, subset_col = 20:40), rowSums(counts(original)[,20:40] > 0))

    expect_equal(nexprs(original, subset_row = 20:40, subset_col=1:10), colSums(counts(original)[20:40,1:10] > 0))
    expect_equal(nexprs(original, byrow = TRUE, subset_row=1:10, subset_col = 20:40), rowSums(counts(original)[1:10,20:40] > 0))
})

test_that("nexprs responds to other options", {    
    expect_equal(nexprs(original, detection_limit=5), colSums(counts(original) > 5))
    expect_equal(nexprs(original, byrow = TRUE, detection_limit=5), rowSums(counts(original) > 5))

    # Handles parallelization.
    expect_equal(nexprs(original), nexprs(original, BPPARAM=safeBPParam(2)))
    expect_equal(nexprs(original), nexprs(original, BPPARAM=SnowParam(3)))
    expect_equal(nexprs(original, byrow=TRUE), nexprs(original, byrow=TRUE, BPPARAM=safeBPParam(2)))
    expect_equal(nexprs(original, byrow=TRUE), nexprs(original, byrow=TRUE, BPPARAM=SnowParam(3)))
})

test_that("nexprs works on a sparse matrix", {
    sparsified <- original
    counts(sparsified) <- as(counts(original), "dgCMatrix")
    expect_equal(nexprs(sparsified), Matrix::colSums(counts(sparsified) > 0))
    expect_equal(nexprs(sparsified, byrow=TRUE), Matrix::rowSums(counts(sparsified) > 0))
    expect_equal(nexprs(sparsified), nexprs(counts(sparsified)))
})

test_that("nexprs handles silly inputs properly", {
    expect_equivalent(nexprs(original, subset_row=integer(0)), integer(ncol(original)))
    expect_equivalent(nexprs(original, subset_col=integer(0)), integer(0))
    expect_equivalent(nexprs(original, subset_row=integer(0), byrow=TRUE), integer(0))
    expect_equivalent(nexprs(original, subset_col=integer(0), byrow=TRUE), integer(nrow(original)))
})

############################################

test_that("numDetectedAcrossCells works as expected", {
    ids <- sample(LETTERS[1:5], ncol(sce), replace=TRUE)

    expect_equal(numDetectedAcrossCells(counts(sce), ids),
        colsum((counts(sce) > 0)+0, ids)) 
    expect_identical(numDetectedAcrossCells(counts(sce), ids, average=TRUE),
        t(t(colsum((counts(sce) > 0)+0, ids))/as.integer(table(ids))))

    # Checking that it works direclty with SCEs.
    expect_equal(numDetectedAcrossCells(counts(sce), ids),
        numDetectedAcrossCells(sce, ids))
    expect_equal(numDetectedAcrossCells(counts(sce), ids, average=TRUE),
        numDetectedAcrossCells(sce, ids, average=TRUE))

    # Checking that subsetting works.
    expect_identical(numDetectedAcrossCells(counts(sce), ids, subset_row=10:1),
        numDetectedAcrossCells(counts(sce), ids)[10:1,])

    expect_identical(numDetectedAcrossCells(counts(sce), ids, subset_col=2:15),
        numDetectedAcrossCells(counts(sce)[,2:15], ids[2:15]))

    ids[c(1,3,5,6)] <- NA
    expect_identical(numDetectedAcrossCells(counts(sce), ids),
        numDetectedAcrossCells(counts(sce)[,!is.na(ids)], ids[!is.na(ids)]))

    # Comparing to sumCountsAcrossCells.
    expect_equal(numDetectedAcrossCells(counts(sce), ids),
        sumCountsAcrossCells((counts(sce) > 0)+0, ids))
    expect_equal(numDetectedAcrossCells(counts(sce), ids, average=TRUE),
        sumCountsAcrossCells((counts(sce) > 0)+0, ids, average=TRUE))
})

test_that("numDetectedAcrossFeatures works as expected", {
    ids <- sample(LETTERS[1:5], nrow(sce), replace=TRUE)

    expect_equal(numDetectedAcrossFeatures(counts(sce), ids),
        rowsum((counts(sce) > 0)+0, ids)) 
    expect_identical(numDetectedAcrossFeatures(counts(sce), ids, average=TRUE),
        rowsum((counts(sce) > 0)+0, ids)/as.integer(table(ids)))

    # Checking that it works direclty with SCEs.
    expect_equal(numDetectedAcrossFeatures(counts(sce), ids),
        numDetectedAcrossFeatures(sce, ids))
    expect_equal(numDetectedAcrossFeatures(counts(sce), ids, average=TRUE),
        numDetectedAcrossFeatures(sce, ids, average=TRUE))

    # Checking that subsetting works.
    expect_identical(numDetectedAcrossFeatures(counts(sce), ids, subset_col=10:1),
        numDetectedAcrossFeatures(counts(sce), ids)[,10:1])

    expect_identical(numDetectedAcrossFeatures(counts(sce), ids, subset_row=2:15),
        numDetectedAcrossFeatures(counts(sce)[2:15,], ids[2:15]))

    ids[c(1,3,5,6)] <- NA
    expect_identical(numDetectedAcrossFeatures(counts(sce), ids),
        numDetectedAcrossFeatures(counts(sce)[!is.na(ids),], ids[!is.na(ids)]))

    # Comparing to sumCountsAcrossFeatures.
    expect_equal(numDetectedAcrossFeatures(counts(sce), ids),
        sumCountsAcrossFeatures((counts(sce) > 0)+0, ids))
    expect_equal(numDetectedAcrossFeatures(counts(sce), ids, average=TRUE),
        sumCountsAcrossFeatures((counts(sce) > 0)+0, ids, average=TRUE))
})
