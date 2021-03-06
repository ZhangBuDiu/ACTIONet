scran.normalize <- function(sce) {
    library(scran)
    
    sce = computeSumFactors(sce)
    sce = normalize(sce)
    
    return(sce)
}

DESeq2.normalize <- function(sce) {
    library(DESeq2)
    
    sizeFactors(sce) <- estimateSizeFactorsForMatrix(counts(sce))
    sce <- normalize(sce)
    
    return(sce)
}

TMM.normalize <- function(sce) {
    library(edgeR)
    
    sizeFactors(sce) <- calcNormFactors(counts(sce), method = "TMM")
    sce <- normalize(sce)
    
    return(sce)
}

logCPM.normalize <- function(sce) {
    library(edgeR)
    
    logcounts(sce) = log2(edgeR::cpm(counts(sce)) + 1)
    
    return(sce)
}

linnorm.normalize <- function(sce) {
    library(Linnorm)
    
    logcounts(sce) = Linnorm(counts(sce))
    
    return(sce)
}

SCnorm.normalize <- function(sce) {
    SCnorm_out = SCnorm(Data = counts(sce), Conditions = rep(1, ncol(sce)), FilterCellNum = 10, NCores = NUM_OF_THREAD)
    logcounts(sce) = log2(normcounts(SCnorm_out) + 1)
    
    return(sce)
}

scone.normalize <- function(sce) {
    library(scone)
    
    scaling = list(none = identity, sum = SUM_FN, tmm = TMM_FN, uq = UQ_FN, fq = FQT_FN, deseq = DESEQ_FN)
    results = scone(SconeExperiment(counts(sce)), scaling = scaling, run = TRUE, k_qc = 0, k_ruv = 0, return.normalize = "in_memory", 
        zero = "postadjust", bpparam = BiocParallel::SerialParam())
    out.normalize = get.normalizealized(results, method = rownames(get_params(results))[1])
    logcounts(sce) = log2(out.normalize + 1)
    
    return(sce)
}

normalize.sce <- function(sce, norm.method = "default") {
    
    if (norm.method == "scran") {
        sce.norm = scran.normalize(sce)
    } else if (norm.method == "DESeq2") {
        sce.norm = DESeq2.normalize(sce)
    } else if (norm.method == "TMM") {
        sce.norm = TMM.normalize(sce)
    } else if (norm.method == "logCPM") {
        sce.norm = logCPM.normalize(sce)
    } else if (norm.method == "linnorm") {
        sce.norm = linnorm.normalize(sce)
    } else if (norm.method == "SCnorm") {
        sce.norm = SCnorm.normalize(sce)
    } else if (norm.method == "scone") {
        sce.norm = scone.normalize(sce)
    } else {
        sce.norm = sce
        A = as(SummarizedExperiment::assays(sce.norm)$counts, "dgTMatrix")
        cs = Matrix::colSums(A)
        cs[cs == 0] = 1
        B = Matrix::sparseMatrix(i = A@i + 1, j = A@j + 1, x = log1p(median(cs) * (A@x/cs[A@j + 1])), dims = dim(A))
        SummarizedExperiment::assays(sce.norm)$logcounts = B
    }
    
    metadata(sce.norm)$normalization.method = norm.method
    metadata(sce.norm)$normalization.time = Sys.time()
    
    return(sce.norm)
}

renormalize.sce <- function(ACTIONet.out, sce) {
	library(scater)

	system.time({sce <- computeSumFactors(sce, clusters=ACTIONet.out$unification.out$assignments.core)})
	summary(sizeFactors(sce))

	final.sce = normalize(sce)
	
    metadata(final.sce)$normalization.method = 'renormalized'
    metadata(final.sce)$sizeFactors = sizeFactors(final.sce)
    metadata(final.sce)$normalization.time = Sys.time()
	
	return(final.sce)
}

