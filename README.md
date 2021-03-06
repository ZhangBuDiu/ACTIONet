
# Installation

## Prerequisites 
1. For optimal performance, link this library with the [MKL](https://software.intel.com/en-us/mkl). Please follow [this](https://software.intel.com/en-us/articles/installing-intel-free-libs-and-python-apt-repo) and [this](https://github.com/eddelbuettel/mkl4deb) links to install MKL on ubuntu-like systems.

2. For running batch-correction and graph-based clustering (Leiden), you need to install [Harmony](https://github.com/immunogenomics/harmony) and [NetLibR](https://github.com/shmohammadi86/NetLibR), respectively.


## Installing from the main repository

```{r}
install.packages("devtools")
devtools::install_github("shmohammadi86/ACTIONet")
```

# Basic Usage
## Import single-cell expression
ACTIONet uses [SingleCellExperiment (SCE)](https://www.bioconductor.org/packages/release/bioc/vignettes/SingleCellExperiment/inst/doc/intro.html) format to store and manipulate single-cell expression profiles. For convenience, a series of functions have been written as part of the ACTIONet package to import data from different sources:

- **Gene expression matrix**: Use `import.sce.from.count.matrix(counts, gene.names)` to construct an `SCE` object. Length of the `gene.names` character vector should match the number of rows in the `counts` matrix.

- **10X output folder**: Use `import.sce.from.10X(input_path)`, with `input_path` being the folder that contains the *.mtx.gz file. This function reads can optionally read data generated using Feature Barcoding (Total-Seq) as well. Additional -omic profiles (antibodies, etc.) will be added in the reducedDims() of the `SCE` object.

- **Seurat object**: Use `import.sce.from.Seurat(Seurat.obj)` to convert a Seurat object to `SCE` format. This function depends on the `Seurat` package for conversion.

` **Scanpy**: Use [RPy2](https://github.com/theislab/anndata2ri) to convert from AnnData to SingleCellExperiment.

## Running ACTIONet
Running ACTIONet consists of two consecutive steps: (1) **Reduction**, and (2) **ACTIONet Construction**

### Reduction
In this step, we preprocess the single-cell profile, stored in `SCE` format, to be compatible with the ACTIONet framework. This allows for usage of various -omics profiles, as well as to do simultaneous batch-correction (optional). For sc/sn-RNASeq, there are two main options for reduction:
	(i). **Without batch-correction**: In this case, you can use the main function `reduce.sce(sce)` to reduce the single-cell data stored in the sce object.
	(ii) **With batch-correction**: There are currently two methods supported within the ACTIONet framework for batch-correction: (a) [Harmony](https://github.com/immunogenomics/harmony), and (b) [Mutual Nearest Neighbor (MNN)](https://bioconductor.org/packages/release/bioc/html/batchelor.html). For the former, please use `reduce.and.batch.correct.sce.Harmony(sce, batch.vec)`, while for the latter you can use `reduce.and.batch.correct.sce.MNN(sce, batch.vec)` function. In both cases, `batch.vec` is encodes the batches and must have the same number of elements as the cells in the `sce` object (ncol(sce)). In all of these functions, if the sce object is not already normalized, you can specify a normalization method by passing the `norm.method` parameter. Current options are: **default** (log-normalization), *scran, linnorm, scone, SCnorm, DESeq2, TMM*, and *logCPM*.

### ACTIONet Construction
The input for this step is the **reduced sce** object. The main interface to run ACTIONet is through `run.ACTIONet(reduced.sce)` function. Additional options to consider are:
- `k_max`: defines the maximum resolution and is suggested to be set to 20 for most cases, and 30 for deeper analysis and identifying rare cell-types.
- `thread_no`: indicates the number of parallel processing threads that are used for parallelization. 
- `layout.compactness` is a value between *[0-100]* and controls the overall compactness in the graph layout stage (this can be re-adjusted afterward).

### Simple Example
```{r}
sce = import.sce.from.10X('my_10x_path')
sce = reduce.sce(sce)
ACTIONet.out = run.ACTIONet(sce)
```
## Interactive Exploration
There are a host of different options for visualization and interactive visualization of the `ACTIONet` output. One of the first entry points that allows simple interface can be accessed as follows:

```{r}
plot.ACTIONet.interactive(ACTIONet.out)
```

# Tutorials
ACTIONet is a comprehensive all-in-one framework that allows a host of different possible analyses. The following list is being updated as new functionalities are being added:

1. [Hands-on experience with PBMC 10X data](http://compbio.mit.edu/ACTIONet/tutorials/Tutorial1_HandsOn.html)
2. [Automated cell annotation using known markers](http://compbio.mit.edu/ACTIONet/tutorials/Tutorial2_CellAnnotation.html)
3. [Multi-resolution network-based clustering](http://compbio.mit.edu/ACTIONet/tutorials/Tutorial3_Clustering.html)
4. [Advanced visualization](http://compbio.mit.edu/ACTIONet/tutorials/Tutorial4_Visualization.html)
5. [Fast and scalable approach for differential analysis of cell states, clusters, and phenotypes](http://compbio.mit.edu/ACTIONet/tutorials/Tutorial5_Differential.html)
6. [Pathway enrichment analysis -- the easy way](http://compbio.mit.edu/ACTIONet/tutorials/Tutorial6_Enrichment.html)
7. [Gene expression imputation and gene-gene correlation analysys](http://compbio.mit.edu/ACTIONet/tutorials/Tutorial7_Imputation.html)
8. [Constructing cell-type/state-specific interactomes](http://compbio.mit.edu/ACTIONet/tutorials/Tutorial8_SCINET.html)
