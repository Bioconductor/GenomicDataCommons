#' Import multiple files of HTSeq-counts format
#' 
#' @importFrom dplyr bind_cols
#' @importFrom readr read_tsv
#' 
.htseq_importer = function(fnames) {
    if(is.list(fnames))
        fnames = unlist(fnames)
    first = readr::read_tsv(fnames[1], col_names = FALSE)
    gene_ids = first[[1]]
    res = dplyr::bind_cols(lapply(fnames, function(fname){
        readr::read_tsv(fname, col_names = FALSE)[,2]
    }))
    colnames(res) = names(fnames)
    res = data.frame(gene_ids,res)
    return(res)
}


#' @describeIn gdc_rnaseq Show possible RNA-seq workflow types
#' 
#' 
#' @examples
#' available_rnaseq_workflows()
#' 
#' @export
available_rnaseq_workflows = function() {
    possible_workflows = files() %>% 
        GenomicDataCommons::filter( ~ data_type=="Gene Expression Quantification" & 
                                        data_type=="Gene Expression Quantification") %>% 
        facet("analysis.workflow_type") %>% 
        aggregations() 
    return(possible_workflows[['key']])
}


#' Get RNA-seq quantification from the NCI GDC.
#' 
#' \code{gdc_rnaseq} is a high-level function for accessing the NCI GDC 
#' RNA-seq data and summarizing as a
#' \code{\link[SummarizedExperiment]{SummarizedExperiment}}. 
#' 
#' @details The RNA-seq data are downloaded using \code{\link{gdcdata}} 
#'     with caching used as available. The resulting files are read and combined
#'     without any transformation. It us up to the user to perform further 
#'     normalization or transformation if needed.
#'     
#'     Clinical information for each file (see \code{\link{gdc_clinical}} for 
#'     details) is loaded into the \code{colData} slot. Quality control mapping 
#'     information is also stored in the \code{colData} with column names beginning
#'     with "qc__". 
#' 
#' @references See \url{https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/Expression_mRNA_Pipeline/} 
#'     for details of data processing that occurs at the GDC.
#' 
#' @param project_id character() vector with one or more project ids. Available 
#'     project_ids can be found using \code{ids(projects())}. Note that 
#'     not all projects contain RNA-seq data.
#'     
#' @param workflow_type character(1) with the workflow type. Possible values
#'     can be accessed using \code{available_rnaseq_workflows}
#'     
#' @return a \code{SummarizedExperiment} object, populated with the expression
#'     values, the gene ids in the \code{rowData}, and the clinical data associated 
#'     with each sample in the \code{colData}.
#' 
#' 
#' 
#' @importFrom SummarizedExperiment SummarizedExperiment
#' @importFrom S4Vectors DataFrame
#' @importFrom dplyr bind_rows bind_cols select
#' 
#' @examples
#' \dontrun{
#' tcga_se = gdc_rnaseq('TCGA-ACC', 'HTSeq - Counts')
#' tcga_se
#' }
#' 
#' @export
gdc_rnaseq = function(project_id, workflow_type) {
    
    # Just double-check that the specified workflow is available
    possible_workflows = files() %>% 
        GenomicDataCommons::filter( ~ data_type=="Gene Expression Quantification" & 
                    data_type=="Gene Expression Quantification") %>% 
        facet("analysis.workflow_type") %>% 
        aggregations()
    possible_workflows = possible_workflows[['analysis.workflow_type']][['key']]
    if(!(workflow_type %in% possible_workflows)) 
        stop(sprintf("Workflow type must be one of: %s",paste(possible_workflows,"\n")))
    
    # fetch the actual data
    # Will use cached data if available
    fnames = files() %>% 
        GenomicDataCommons::filter( ~ cases.project.project_id %in% project_id & 
                  analysis.workflow_type==workflow_type) %>%
        ids() %>%
        gdcdata()
    
    # This retrieves basic case info for each file.
    # Assumes that file_id is 1-1 with case_id
    file_and_case_info = files() %>% 
        expand('cases') %>%
        GenomicDataCommons::filter(~ file_id %in% names(fnames)) %>% 
        results_all()
    case_df = dplyr::bind_rows(file_and_case_info$cases, .id='file_id') %>%
        dplyr::select(case_id,file_id)
    
    # Expand the coldata with clinical data
    clin_data_list = gdc_clinical(case_df[['case_id']])
    # Some clinical data.frames may not be 1-1 with the case_ids.
    # This just filters out those data.frames that do not have
    # the same number of rows.
    number_of_cases = nrow(clin_data_list$demographic)
    
    clin_data_list = clin_data_list[sapply(clin_data_list,nrow) == number_of_cases]
    
    # This is just to rename columns. A column like "submitter_id"
    # is included in several of the clinical data.frames, but the 
    # information is different in each. This code disambiguates by
    # attaching a suffix.
    all_colnames = unlist(sapply(clin_data_list,colnames))
    duped_colnames = unique(all_colnames[duplicated(all_colnames)])
    duped_colnames = duped_colnames[! duped_colnames=='case_id']
    clin_data_list_renamed = lapply(names(clin_data_list), function(n) {
        df = clin_data_list[[n]]
        df_colnames = colnames(df)
        idx = df_colnames %in% duped_colnames
        df_colnames[idx] = paste(df_colnames[idx],n,sep='.')
        colnames(df) = df_colnames
        return(df)
    })
    names(clin_data_list_renamed) = names(clin_data_list)
    for(i in names(clin_data_list_renamed)) {
        case_df = case_df %>% dplyr::left_join(clin_data_list_renamed[[i]], 
                                               by = c('case_id' = 'case_id'),
                                               suffix = c(paste0('.',i),'.case'))
    }
    coldata = case_df
    
    # probably not needed, but reorder based on file_ids from fname
    # vector to match up columns in the assays matrix
    coldata = coldata[match(names(fnames), coldata$file_id),]
    mat = .htseq_importer(fnames)
    qc_idx = grepl("^__",mat[[1]])
    mat_qc = data.frame(t(mat[qc_idx, -1]))
    colnames(mat_qc) = paste0('qc',mat[qc_idx,1])
    coldata = dplyr::bind_cols(coldata,mat_qc)
    mat = mat[!qc_idx, ]
    rowdata = S4Vectors::DataFrame(gene_id = mat[[1]])
    se = SummarizedExperiment::SummarizedExperiment(list(exprs=as.matrix(mat[,-1])), 
                                                    rowData = rowdata, colData = coldata)
    rownames(se) = rowdata[['gene_id']]
    colnames(se) = names(fnames)
    return(se)
}