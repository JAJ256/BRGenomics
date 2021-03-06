% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deseq_functions.R
\name{getDESeqResults}
\alias{getDESeqResults}
\title{Get DESeq2 results using reduced dispersion matrices}
\usage{
getDESeqResults(
  dds,
  contrast.numer,
  contrast.denom,
  comparisons = NULL,
  sizeFactors = NULL,
  alpha = 0.1,
  lfcShrink = FALSE,
  args.DESeq = NULL,
  args.results = NULL,
  args.lfcShrink = NULL,
  ncores = getOption("mc.cores", 2L),
  quiet = FALSE
)
}
\arguments{
\item{dds}{A DESeqDataSet object, produced using either
\code{\link[BRGenomics:getDESeqDataSet]{getDESeqDataSet}} from this package
or \code{\link[DESeq2:DESeqDataSet]{DESeqDataSet}} from \code{DESeq2}. If
\code{dds} was not created using \code{getDESeqDataSet}, \code{dds} must be
made with \code{design = ~condition} such that a unique \code{condition}
level exists for each sample/treatment condition.}

\item{contrast.numer}{A string naming the \code{condition} to use as the
numerator in the DESeq2 comparison, typically the perturbative condition.}

\item{contrast.denom}{A string naming the \code{condition} to use as the
denominator in the DESeq2 comparison, typically the control condition.}

\item{comparisons}{As an optional alternative to supplying a single
\code{contrast.numer} and \code{contrast.denom}, users can supply a list of
character vectors containing numerator-denominator pairs, e.g.
\code{list(c("B", "A"), c("C", "A"), c("C", "B"))}. \code{comparisons} can
also be a dataframe in which each row is a comparison, the first column
contains the numerators, and  the second column contains the denominators.}

\item{sizeFactors}{A vector containing DESeq2 \code{sizeFactors} to apply to
each sample. Each sample's readcounts are \emph{divided} by its respective
DESeq2 \code{sizeFactor}. A warning will be generated if the
\code{DESeqDataSet} already contains \code{sizeFactors}, and the previous
\code{sizeFactors} will be over-written.}

\item{alpha}{The significance threshold passed to \code{DESeqResults}, which
is used for independent filtering of results (see DESeq2 documentation).}

\item{lfcShrink}{Logical indicating if log2FoldChanges and their standard
errors should be shrunk using \code{\link[DESeq2:lfcShrink]{lfcShrink}}.
LFC shrinkage is very useful for making fold-change values meaningful, as
low-expression/high variance genes are given low fold-changes.
Set to \code{FALSE} by default.}

\item{args.DESeq}{Additional arguments passed to
\code{\link[DESeq2:DESeq]{DESeq}}, given as a list of argument-value pairs,
e.g. \code{list(fitType = "local", useT = TRUE)}. All arguments given here
will be passed to \code{DESeq} except for \code{object} and
\code{parallel}. If no arguments are given, all defaults will be used.}

\item{args.results}{Additional arguments passed to
\link[DESeq2:results]{DESeq2::results}, given as a list of argument-value
pairs, e.g. \code{list(altHypothesis = "greater", lfcThreshold = 1.5)}. All
arguments given here will be passed to \code{results} except for
\code{object}, \code{contrast}, \code{alpha}, and \code{parallel}. If no
arguments are given, all defaults will be used.}

\item{args.lfcShrink}{Additional arguments passed to
\code{\link[DESeq2:lfcShrink]{lfcShrink}}, given as a list of
argument-value pairs. All arguments given here will be passed to
\code{lfcShrink} except for \code{dds}, \code{coef}, \code{contrast}, and
\code{parallel}. If no arguments are given, all defaults will be used.}

\item{ncores}{The number of cores to use for parallel processing. Multicore
processing is only used if more than one comparison is being made (i.e.
argument \code{comparisons} is used), and the number of cores utilized will
not be greater than the number of comparisons being performed.}

\item{quiet}{If \code{TRUE}, all output messages from calls to \code{DESeq}
and \code{results} will be suppressed, although passing option \code{quiet}
in \code{args.DESeq} will supersede this option for the call to
\code{DESeq}.}
}
\value{
For a single comparison, the output is the \code{DESeqResults} result
  table. If a \code{comparisons} is used to make multiple comparisons, the
  output is a named list of \code{DESeqResults} objects, with elements named
  following the pattern \code{"X_vs_Y"}, where \code{X} is the name of the
  numerator condition, and \code{Y} is the name of the denominator condition.
}
\description{
This function calls \code{\link[DESeq2:DESeq]{DESeq2::DESeq}} and
\code{\link[DESeq2:results]{DESeq2::results}} on a pre-existing
\code{DESeqDataSet} object and returns a \code{DESeqResults} table for one or
more pairwise comparisons. However, unlike a standard call to
\code{DESeq2::results} using the \code{contrast} argument, this function
subsets the dataset so that DESeq2 only estimates dispersion for the samples
being compared, and not for all samples present.
}
\section{Errors when \code{ncores > 1}}{
 If this function returns an error,
  set \code{ncores = 1}. Whether or not this occurs can depend on whether
  users are using alternative BLAS libraries (e.g. OpenBLAS or Apple's
  Accelerate framework) and/or how DESeq2 was installed. This is because some
  DESeq2 functions (e.g. \code{\link[DESeq2:nbinomWaldTest]{
  nbinomWaldTest}}) use C code that can be compiled to use parallelization,
  and this conflicts with our use of process forking (via the
  \code{\link[parallel:parallel-package]{parallel package}}) when
  \code{ncores > 1}.
}

\examples{
#--------------------------------------------------#
# getDESeqDataSet
#--------------------------------------------------#
suppressPackageStartupMessages(require(DESeq2))
data("PROseq") # import included PROseq data
data("txs_dm6_chr4") # import included transcripts

# divide PROseq data into 6 toy datasets
ps_a_rep1 <- PROseq[seq(1, length(PROseq), 6)]
ps_b_rep1 <- PROseq[seq(2, length(PROseq), 6)]
ps_c_rep1 <- PROseq[seq(3, length(PROseq), 6)]

ps_a_rep2 <- PROseq[seq(4, length(PROseq), 6)]
ps_b_rep2 <- PROseq[seq(5, length(PROseq), 6)]
ps_c_rep2 <- PROseq[seq(6, length(PROseq), 6)]

ps_list <- list(A_rep1 = ps_a_rep1, A_rep2 = ps_a_rep2,
                B_rep1 = ps_b_rep1, B_rep2 = ps_b_rep2,
                C_rep1 = ps_c_rep1, C_rep2 = ps_c_rep2)

# make flawed dataset (ranges in txs_dm6_chr4 not disjoint)
#    this means there is double-counting
# also using discontinuous gene regions, as gene_ids are repeated
dds <- getDESeqDataSet(ps_list,
                       txs_dm6_chr4,
                       gene_names = txs_dm6_chr4$gene_id,
                       ncores = 1)

dds

#--------------------------------------------------#
# getDESeqResults
#--------------------------------------------------#

res <- getDESeqResults(dds, "B", "A")

res

reslist <- getDESeqResults(dds, comparisons = list(c("B", "A"), c("C", "A")),
                           ncores = 1)
names(reslist)

reslist$B_vs_A

# or using a dataframe
reslist <- getDESeqResults(dds, comparisons = data.frame(num = c("B", "C"),
                                                         den = c("A", "A")),
                           ncores = 1)
reslist$B_vs_A
}
\seealso{
\code{\link[BRGenomics:getDESeqDataSet]{getDESeqDataSet}},
  \code{\link[DESeq2:results]{DESeq2::results}}
}
\author{
Mike DeBerardine
}
