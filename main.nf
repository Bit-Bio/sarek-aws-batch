#!/usr/bin/env nextflow

/*
================================================================================
                                  nf-core/sarek
================================================================================
Started March 2016.
Ported to nf-core May 2019.
--------------------------------------------------------------------------------
nf-core/sarek:
  An open-source analysis pipeline to detect germline or somatic variants
  from whole genome or targeted sequencing
--------------------------------------------------------------------------------
 @Homepage
 https://nf-co.re/sarek
--------------------------------------------------------------------------------
 @Documentation
 https://nf-co.re/sarek/docs
--------------------------------------------------------------------------------
*/

def helpMessage() {
    log.info nfcoreHeader()
    log.info"""

    Usage:

    The typical command for running the pipeline is as follows:

    nextflow run nf-core/sarek --input sample.tsv -profile docker

    Mandatory arguments:
      --input                  [file] Path to input TSV file on mapping, recalibrate and variantcalling steps
                                      Multiple TSV files can be specified with quotes
                                      Works also with the path to a directory on mapping step with a single germline sample only
                                      Alternatively, path to VCF input file on annotate step
                                      Multiple VCF files can be specified with quotes
      -profile                  [str] Configuration profile to use
                                      Can use multiple (comma separated)
                                      Available: conda, docker, singularity, test and more
      --genome                  [str] Name of iGenomes reference
      --step                    [str] Specify starting step
                                      Available: Mapping, Recalibrate, VariantCalling, Annotate
                                      Default: Mapping

    Options:
      --no_gvcf                [bool] No g.vcf output from HaplotypeCaller
      --no_strelka_bp          [bool] Will not use Manta candidateSmallIndels for Strelka as Best Practice
      --no_intervals           [bool] Disable usage of intervals
      --nucleotides_per_second  [int] To estimate interval size
                                      Default: 1000.0
      --target_bed             [file] Target BED file for targeted or whole exome sequencing
      --tools                   [str] Specify tools to use for variant calling:
                                      Available: ASCAT, ControlFREEC, FreeBayes, HaplotypeCaller
                                      Manta, mpileup, Mutect2, Strelka, TIDDIT
                                      and/or for annotation:
                                      snpEff, VEP, merge
                                      Default: None
      --skip_qc                 [str] Specify which QC tools to skip when running Sarek
                                      Available: all, bamQC, BaseRecalibrator, BCFtools, Documentation, FastQC, MultiQC, samtools, vcftools, versions
                                      Default: None
      --annotate_tools          [str] Specify from which tools Sarek will look for VCF files to annotate, only for step annotate
                                      Available: HaplotypeCaller, Manta, Mutect2, Strelka, TIDDIT
                                      Default: None
      --sentieon               [bool] If sentieon is available, will enable it for preprocessing, and variant calling
                                      Adds the following tools for --tools: DNAseq, DNAscope and TNscope
      --annotation_cache       [bool] Enable the use of cache for annotation, to be used with --snpeff_cache and/or --vep_cache
      --snpeff_cache           [file] Specity the path to snpEff cache, to be used with --annotation_cache
      --vep_cache              [file] Specity the path to VEP cache, to be used with --annotation_cache
      --pon                    [file] Panel-of-normals VCF (bgzipped, indexed). See: https://software.broadinstitute.org/gatk/documentation/tooldocs/current/org_broadinstitute_hellbender_tools_walkers_mutect_CreateSomaticPanelOfNormals.php
      --pon_index              [file] Index of pon panel-of-normals VCF
      --ascat_ploidy            [int] Use this parameter together with to overwrite default behavior from ASCAT regarding ploidy. Note: Also requires that --ascat_purity is set.
      --ascat_purity            [int] Use this parameter to overwrite default behavior from ASCAT regarding purity. Note: Also requires that --ascat_ploidy is set.

    Trimming:
      --trim_fastq             [bool] Run Trim Galore
      --clip_r1                 [int] Instructs Trim Galore to remove bp from the 5' end of read 1 (or single-end reads)
      --clip_r2                 [int] Instructs Trim Galore to remove bp from the 5' end of read 2 (paired-end reads only)
      --three_prime_clip_r1     [int] Instructs Trim Galore to remove bp from the 3' end of read 1 AFTER adapter/quality trimming has been performed
      --three_prime_clip_r2     [int] Instructs Trim Galore to remove bp from the 3' end of read 2 AFTER adapter/quality trimming has been performed
      --trim_nextseq            [int] Instructs Trim Galore to apply the --nextseq=X option, to trim based on quality after removing poly-G tails
      --save_trimmed           [bool] Save trimmed FastQ file intermediates

    References                        If not specified in the configuration file or you wish to overwrite any of the references.
      --ac_loci                [file] acLoci file
      --ac_loci_gc             [file] acLoci GC file
      --bwa                    [file] bwa indexes
                                      If none provided, will be generated automatically from the fasta reference
      --dbsnp                  [file] dbsnp file
      --dbsnp_index            [file] dbsnp index
                                      If none provided, will be generated automatically if a dbsnp file is provided
      --dict                   [file] dict from the fasta reference
                                      If none provided, will be generated automatically from the fasta reference
      --fasta                  [file] fasta reference
      --fasta_fai              [file] reference index
                                      If none provided, will be generated automatically from the fasta reference
      --germline_resource      [file] Germline Resource File
      --germline_resource_index       Germline Resource Index
                               [file] if none provided, will be generated automatically if a germlineResource file is provided
      --intervals              [file] intervals
                                      If none provided, will be generated automatically from the fasta reference
                                      Use --no_intervals to disable automatic generation
      --known_indels           [file] knownIndels file
      --known_indels_index     [file] knownIndels index
                                      If none provided, will be generated automatically if a knownIndels file is provided
      --species                 [str] Species for VEP
      --snpeff_db               [str] snpEff Database version
      --vep_cache_version       [str] VEP Cache version

    Other options:
      --outdir                 [file] The output directory where the results will be saved
      --publish_dir_mode        [str] Mode of publishing data in the output directory.
                                      Available: symlink, rellink, link, copy, copyNoFollow, move
                                      Default: copy
      --sequencing_center       [str] Name of sequencing center to be displayed in BAM file
      --multiqc_config         [file] Specify a custom config file for MultiQC
      --monochrome_logs        [bool] Logs will be without colors
      --email                   [str] Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits
      --max_multiqc_email_size  [str] Theshold size for MultiQC report to be attached in notification email. If file generated by pipeline exceeds the threshold, it will not be attached (Default: 25MB)
      -name                     [str] Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic

    AWSBatch options:
      --awsqueue [str]                The AWSBatch JobQueue that needs to be set when running on AWSBatch
      --awsregion [str]               The AWS Region for your AWS Batch job to run on
      --awscli [str]                  Path to the AWS CLI tool
    """.stripIndent()
}

// Show help message
if (params.help) exit 0, helpMessage()

/*
================================================================================
                                HANDLE OLD PARAMS
================================================================================
*/

// Warnings for deprecated params

params.annotateTools = null
if (params.annotateTools) {
    log.warn "The params `--annotateTools` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--annotate_tools"
    params.annotate_tools = params.annotateTools
}

params.annotateVCF = null
if (params.annotateVCF) {
    log.warn "The params `--annotateVCF` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--input"
    input = params.annotateVCF
}

params.cadd_InDels = null
if (params.cadd_InDels) {
    log.warn "The params `--cadd_InDels is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--cadd_indels"
    params.cadd_indels = params.cadd_InDels
}

params.cadd_InDels_tbi = null
if (params.cadd_InDels_tbi) {
    log.warn "The params `--cadd_InDels_tbi is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--cadd_indels_tbi"
    params.cadd_indels_tbi = params.cadd_InDels_tbi
}

params.cadd_WG_SNVs = null
if (params.cadd_WG_SNVs) {
    log.warn "The params `--cadd_WG_SNVs is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--cadd_wg_snvs"
    params.cadd_wg_snvs = params.cadd_WG_SNVs
}

params.cadd_WG_SNVs_tbi = null
if (params.cadd_WG_SNVs_tbi) {
    log.warn "The params `--cadd_WG_SNVs_tbi is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--cadd_wg_snvs_tbi"
    params.cadd_wg_snvs_tbi = params.cadd_WG_SNVs_tbi
}

params.maxMultiqcEmailFileSize = null
if (params.maxMultiqcEmailFileSize) {
    log.warn "The params `--maxMultiqcEmailFileSize` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--max_multiqc_email_size"
    params.max_multiqc_email_size = params.maxMultiqcEmailFileSize
}

params.noGVCF = null
if (params.noGVCF) {
    log.warn "The params `--noGVCF` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--no_gvcf"
    params.no_gvcf = params.noGVCF
}

params.noReports = null
if (params.noReports) {
    log.warn "The params `--noReports` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--skip_qc"
    params.skip_qc = 'all'
}

params.noStrelkaBP = null
if (params.noStrelkaBP) {
    log.warn "The params `--noStrelkaBP` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--no_strelka_bp"
    params.no_strelka_bp = params.noStrelkaBP
}

params.nucleotidesPerSecond = null
if (params.nucleotidesPerSecond) {
    log.warn "The params `--nucleotidesPerSecond` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--nucleotides_per_second"
    params.nucleotides_per_second = params.nucleotidesPerSecond
}

params.publishDirMode = null
if (params.publishDirMode) {
    log.warn "The params `--publishDirMode` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--publish_dir_mode"
    params.publish_dir_mode = params.publishDirMode
}

params.sample = null
if (params.sample) {
    log.warn "The params `--sample` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--input"
    params.input = params.sample
}

params.sampleDir = null
if (params.sampleDir) {
    log.warn "The params `--sampleDir` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--input"
    params.input = params.sampleDir
}

params.saveGenomeIndex = null
if (params.saveGenomeIndex) {
    log.warn "The params `--saveGenomeIndex` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--save_reference"
    params.save_reference = params.saveGenomeIndex
}

params.skipQC = null
if (params.skipQC) {
    log.warn "The params `--skipQC` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--skip_qc"
    params.skip_qc = params.skipQC
}

params.snpEff_cache = null
if (params.snpEff_cache) {
    log.warn "The params `--snpEff_cache` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--snpeff_cache"
    params.snpeff_cache = params.snpEff_cache
}

params.targetBed = null
if (params.targetBed) {
    log.warn "The params `--targetBed` is deprecated -- it will be removed in a future release."
    log.warn "\tPlease check: https://nf-co.re/sarek/docs/usage.md#--target_bed"
    params.target_bed = params.targetBed
}

// Errors for removed params

params.acLoci = null
if (params.acLoci) exit 1, "The params `--acLoci` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--ac_loci"

params.acLociGC = null
if (params.acLociGC) exit 1, "The params `--acLociGC` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--ac_loci_gc"

params.bwaIndex = null
if (params.bwaIndex) exit 1, "The params `--bwaIndex` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--bwa"

params.chrDir = null
if (params.chrDir) exit 1, "The params `--chrDir` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--chr_dir"

params.chrLength = null
if (params.chrLength) exit 1, "The params `--chrLength` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--chr_length"

params.dnsnpIndex = null
if (params.dnsnpIndex) exit 1, "The params `--dnsnpIndex` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--dnsnp_index"

params.fastaFai = null
if (params.fastaFai) exit 1, "The params `--fastaFai` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--fasta_fai"

params.genomeDict = null
if (params.genomeDict) exit 1, "The params `--genomeDict` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--dict"

params.genomeFile = null
if (params.genomeFile) exit 1, "The params `--genomeFile` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--fasta"

params.genomeIndex = null
if (params.genomeIndex) exit 1, "The params `--genomeIndex` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--fasta_fai"

params.germlineResource = null
if (params.germlineResource) exit 1, "The params `--germlineResource` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--germline_resource"

params.germlineResourceIndex = null
if (params.germlineResourceIndex) exit 1, "The params `--germlineResourceIndex` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--germline_resource_index"

params.igenomesIgnore = null
if (params.igenomesIgnore) exit 1, "The params `--igenomesIgnore` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--igenomes_ignore"

params.knownIndels = null
if (params.knownIndels) exit 1, "The params `--knownIndels` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--known_indels"

params.knownIndelsIndex = null
if (params.knownIndelsIndex) exit 1, "The params `--knownIndelsIndex` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--known_indels_index"

params.snpeffDb = null
if (params.snpeffDb) exit 1, "The params `--snpeffDb` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--snpeff_db"

params.singleCPUMem = null
if (params.singleCPUMem) exit 1, "The params `--singleCPUMem` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--single_cpu_mem"

params.vepCacheVersion = null
if (params.vepCacheVersion) exit 1, "The params `--vepCacheVersion` has been removed.\n\tPlease check: https://nf-co.re/sarek/docs/usage.md#--vep_cache_version"

/*
================================================================================
                         SET UP CONFIGURATION VARIABLES
================================================================================
*/

// Check if genome exists in the config file
if (params.genomes && params.genome && !params.genomes.containsKey(params.genome)) {
    exit 1, "The provided genome '${params.genome}' is not available in the iGenomes file. Currently the available genomes are ${params.genomes.keySet().join(", ")}"
}

stepList = defineStepList()
step = params.step ? params.step.toLowerCase() : ''

// Handle deprecation
if (step == 'preprocessing') step = 'mapping'

if (step.contains(',')) exit 1, 'You can choose only one step, see --help for more information'
if (!checkParameterExistence(step, stepList)) exit 1, "Unknown step ${step}, see --help for more information"

toolList = defineToolList()
tools = params.tools ? params.tools.split(',').collect{it.trim().toLowerCase()} : []
if (!checkParameterList(tools, toolList)) exit 1, 'Unknown tool(s), see --help for more information'

skipQClist = defineSkipQClist()
skipQC = params.skip_qc ? params.skip_qc == 'all' ? skipQClist : params.skip_qc.split(',').collect{it.trim().toLowerCase()} : []
if (!checkParameterList(skipQC, skipQClist)) exit 1, 'Unknown QC tool(s), see --help for more information'

annoList = defineAnnoList()
annotateTools = params.annotate_tools ? params.annotate_tools.split(',').collect{it.trim().toLowerCase()} : []
if (!checkParameterList(annotateTools,annoList)) exit 1, 'Unknown tool(s) to annotate, see --help for more information'

// Check parameters
if ((params.ascat_ploidy && !params.ascat_purity) || (!params.ascat_ploidy && params.ascat_purity)) exit 1, 'Please specify both --ascat_purity and --ascat_ploidy, or none of them'

// Has the run name been specified by the user?
// This has the bonus effect of catching both -name and --name
custom_runName = params.name
if (!(workflow.runName ==~ /[a-z]+_[a-z]+/)) custom_runName = workflow.runName

if (workflow.profile.contains('awsbatch')) {
    // AWSBatch sanity checking
    if (!params.awsqueue || !params.awsregion) exit 1, "Specify correct --awsqueue and --awsregion parameters on AWSBatch!"
    // Check outdir paths to be S3 buckets if running on AWSBatch
    // related: https://github.com/nextflow-io/nextflow/issues/813
    if (!params.outdir.startsWith('s3:')) exit 1, "Outdir not on S3 - specify S3 Bucket to run on AWSBatch!"
    // Prevent trace files to be stored on S3 since S3 does not support rolling files.
    if (params.tracedir.startsWith('s3:')) exit 1, "Specify a local tracedir or run without trace! S3 cannot be used for tracefiles."
}

// Stage config files
ch_multiqc_config = file("$baseDir/assets/multiqc_config.yaml", checkIfExists: true)
ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config, checkIfExists: true) : Channel.empty()
ch_output_docs = file("$baseDir/docs/output.md", checkIfExists: true)

tsvPath = null
if (params.input && (hasExtension(params.input, "tsv") || hasExtension(params.input, "vcf") || hasExtension(params.input, "vcf.gz"))) tsvPath = params.input
if (params.input && (hasExtension(params.input, "vcf") || hasExtension(params.input, "vcf.gz"))) step = "annotate"

// If no input file specified, trying to get TSV files corresponding to step in the TSV directory
// only for steps recalibrate and variantCalling
if (!params.input && step != 'mapping' && step != 'annotate') {
    if (params.sentieon) {
        if (step == 'variantcalling') tsvPath =  "${params.outdir}/Preprocessing/TSV/recalibrated_sentieon.tsv"
        else exit 1, "Not possible to restart from that step"
    }
    else {
        tsvPath = step == 'recalibrate' ? "${params.outdir}/Preprocessing/TSV/duplicateMarked.tsv" : "${params.outdir}/Preprocessing/TSV/recalibrated.tsv"
    }
}

inputSample = Channel.empty()
if (tsvPath) {
    tsvFile = file(tsvPath)
    switch (step) {
        case 'mapping': inputSample = extractFastq(tsvFile); break
        case 'recalibrate': inputSample = extractRecal(tsvFile); break
        case 'variantcalling': inputSample = extractBam(tsvFile); break
        case 'annotate': break
        default: exit 1, "Unknown step ${step}"
    }
} else if (params.input && !hasExtension(params.input, "tsv")) {
    log.info "No TSV file"
    if (step != 'mapping') exit 1, 'No other step than "mapping" support a dir as an input'
    log.info "Reading ${params.input} directory"
    inputSample = extractFastqFromDir(params.input)
    (inputSample, fastqTMP) = inputSample.into(2)
    fastqTMP.toList().subscribe onNext: {
        if (it.size() == 0) exit 1, "No FASTQ files found in --input directory '${params.input}'"
    }
    tsvFile = params.input  // used in the reports
} else if (tsvPath && step == 'annotate') {
    log.info "Annotating ${tsvPath}"
} else if (step == 'annotate') {
    log.info "Trying automatic annotation on file in the VariantCalling directory"
} else exit 1, 'No sample were defined, see --help'

(genderMap, statusMap, inputSample) = extractInfos(inputSample)



/*
================================================================================
                               CHECKING REFERENCES
================================================================================
*/

// Initialize each params in params.genomes, catch the command line first if it was defined
// params.fasta has to be the first one
params.fasta = params.genome && !('annotate' in step) ? params.genomes[params.genome].fasta ?: null : null
// The rest can be sorted
params.ac_loci = params.genome && 'ascat' in tools ? params.genomes[params.genome].ac_loci ?: null : null
params.ac_loci_gc = params.genome && 'ascat' in tools ? params.genomes[params.genome].ac_loci_gc ?: null : null
params.bwa = params.genome && params.fasta && 'mapping' in step ? params.genomes[params.genome].bwa ?: null : null
params.chr_dir = params.genome && 'controlfreec' in tools ? params.genomes[params.genome].chr_dir ?: null : null
params.chr_length = params.genome && 'controlfreec' in tools ? params.genomes[params.genome].chr_length ?: null : null
params.dbsnp = params.genome && ('mapping' in step || 'controlfreec' in tools || 'haplotypecaller' in tools || 'mutect2' in tools) ? params.genomes[params.genome].dbsnp ?: null : null
params.dbsnp_index = params.genome && params.dbsnp ? params.genomes[params.genome].dbsnp_index ?: null : null
params.dict = params.genome && params.fasta ? params.genomes[params.genome].dict ?: null : null
params.fasta_fai = params.genome && params.fasta ? params.genomes[params.genome].fasta_fai ?: null : null
params.germline_resource = params.genome && 'mutect2' in tools ? params.genomes[params.genome].germline_resource ?: null : null
params.germline_resource_index = params.genome && params.germline_resource ? params.genomes[params.genome].germline_resource_index ?: null : null
params.intervals = params.genome && !('annotate' in step) ? params.genomes[params.genome].intervals ?: null : null
params.known_indels = params.genome && 'mapping' in step ? params.genomes[params.genome].known_indels ?: null : null
params.known_indels_index = params.genome && params.known_indels ? params.genomes[params.genome].known_indels_index ?: null : null
params.snpeff_db = params.genome && 'snpeff' in tools ? params.genomes[params.genome].snpeff_db ?: null : null
params.species = params.genome && 'vep' in tools ? params.genomes[params.genome].species ?: null : null
params.vep_cache_version = params.genome && 'vep' in tools ? params.genomes[params.genome].vep_cache_version ?: null : null

// Initialize channels based on params
ch_ac_loci = params.ac_loci && 'ascat' in tools ? Channel.value(file(params.ac_loci)) : "null"
ch_ac_loci_gc = params.ac_loci_gc && 'ascat' in tools ? Channel.value(file(params.ac_loci_gc)) : "null"
ch_chr_dir = params.chr_dir && 'controlfreec' in tools ? Channel.value(file(params.chr_dir)) : "null"
ch_chr_length = params.chr_length && 'controlfreec' in tools ? Channel.value(file(params.chr_length)) : "null"
ch_dbsnp = params.dbsnp && ('mapping' in step || 'controlfreec' in tools || 'haplotypecaller' in tools || 'mutect2' in tools) ? Channel.value(file(params.dbsnp)) : "null"
ch_fasta = params.fasta && !('annotate' in step) ? Channel.value(file(params.fasta)) : "null"
ch_fai = params.fasta_fai && !('annotate' in step) ? Channel.value(file(params.fasta_fai)) : "null"
ch_germline_resource = params.germline_resource && 'mutect2' in tools ? Channel.value(file(params.germline_resource)) : "null"
ch_intervals = params.intervals && !params.no_intervals && !('annotate' in step) ? Channel.value(file(params.intervals)) : "null"
ch_known_indels = params.known_indels && 'mapping' in step ? Channel.value(file(params.known_indels)) : "null"

ch_snpeff_cache = params.snpeff_cache ? Channel.value(file(params.snpeff_cache)) : "null"
ch_snpeff_db = params.snpeff_db ? Channel.value(params.snpeff_db) : "null"
ch_vep_cache_version = params.vep_cache_version ? Channel.value(params.vep_cache_version) : "null"
ch_vep_cache = params.vep_cache ? Channel.value(file(params.vep_cache)) : "null"

// Optional files, not defined within the params.genomes[params.genome] scope
ch_cadd_indels = params.cadd_indels ? Channel.value(file(params.cadd_indels)) : "null"
ch_cadd_indels_tbi = params.cadd_indels_tbi ? Channel.value(file(params.cadd_indels_tbi)) : "null"
ch_cadd_wg_snvs = params.cadd_wg_snvs ? Channel.value(file(params.cadd_wg_snvs)) : "null"
ch_cadd_wg_snvs_tbi = params.cadd_wg_snvs_tbi ? Channel.value(file(params.cadd_wg_snvs_tbi)) : "null"
ch_pon = params.pon ? Channel.value(file(params.pon)) : "null"
ch_target_bed = params.target_bed ? Channel.value(file(params.target_bed)) : "null"


/*
================================================================================
                                PRINTING SUMMARY
================================================================================
*/

// Header log info
log.info nfcoreHeader()
def summary = [:]
if (workflow.revision)          summary['Pipeline Release']    = workflow.revision
summary['Run Name']          = custom_runName ?: workflow.runName
summary['Max Resources']     = "${params.max_memory} memory, ${params.max_cpus} cpus, ${params.max_time} time per job"
if (workflow.containerEngine)   summary['Container']         = "${workflow.containerEngine} - ${workflow.container}"
if (params.input)               summary['Input']             = params.input
if (params.target_bed)          summary['Target BED']        = params.target_bed
if (step)                       summary['Step']              = step
if (params.tools)               summary['Tools']             = tools.join(', ')
if (params.skip_qc)             summary['QC tools skip']     = skipQC.join(', ')

if (params.trim_fastq) {
    summary['Fastq trim']         = "Fastq trim selected"
    summary['Trim R1']            = "$params.clip_r1 bp"
    summary['Trim R2']            = "$params.clip_r2 bp"
    summary["Trim 3' R1"]         = "$params.three_prime_clip_r1 bp"
    summary["Trim 3' R2"]         = "$params.three_prime_clip_r2 bp"
    summary["NextSeq Trim"]       = "$params.trim_nextseq bp"
    summary['Saved Trimmed Fastq'] = params.saveTrimmed ? 'Yes' : 'No'
}

if (params.no_intervals && step != 'annotate') summary['Intervals']         = 'Do not use'
if ('haplotypecaller' in tools)                summary['GVCF']              = params.no_gvcf ? 'No' : 'Yes'
if ('strelka' in tools && 'manta' in tools )   summary['Strelka BP']        = params.no_strelka_bp ? 'No' : 'Yes'
if (params.ascat_purity)                       summary['ASCAT purity']      = params.ascat_purity
if (params.ascat_ploidy)                       summary['ASCAT ploidy']      = params.ascat_ploidy
if (params.sequencing_center)                  summary['Sequenced by']      = params.sequencing_center
if (params.pon && 'mutect2' in tools)          summary['Panel of normals']  = params.pon

summary['Save Reference']    = params.save_reference ? 'Yes' : 'No'
summary['Nucleotides/s']     = params.nucleotides_per_second
summary['Output dir']        = params.outdir
summary['Launch dir']        = workflow.launchDir
summary['Working dir']       = workflow.workDir
summary['Script dir']        = workflow.projectDir
summary['User']              = workflow.userName
summary['genome']            = params.genome

if (params.fasta)                   summary['fasta']                 = params.fasta
if (params.fasta_fai)               summary['fastaFai']              = params.fasta_fai
if (params.dict)                    summary['dict']                  = params.dict
if (params.bwa)                     summary['bwa']                   = params.bwa
if (params.germline_resource)       summary['germlineResource']      = params.germline_resource
if (params.germline_resource_index) summary['germlineResourceIndex'] = params.germline_resource_index
if (params.intervals)               summary['intervals']             = params.intervals
if (params.ac_loci)                 summary['acLoci']                = params.ac_loci
if (params.ac_loci_gc)              summary['acLociGC']              = params.ac_loci_gc
if (params.chr_dir)                 summary['chrDir']                = params.chr_dir
if (params.chr_length)              summary['chrLength']             = params.chr_length
if (params.dbsnp)                   summary['dbsnp']                 = params.dbsnp
if (params.dbsnp_index)             summary['dbsnpIndex']            = params.dbsnp_index
if (params.known_indels)            summary['knownIndels']           = params.known_indels
if (params.known_indels_index)      summary['knownIndelsIndex']      = params.known_indels_index
if (params.snpeff_db)               summary['snpeffDb']              = params.snpeff_db
if (params.species)                 summary['species']               = params.species
if (params.vep_cache_version)       summary['vepCacheVersion']       = params.vep_cache_version
if (params.species)                 summary['species']               = params.species
if (params.snpeff_cache)            summary['snpEff_cache']          = params.snpeff_cache
if (params.vep_cache)               summary['vep_cache']             = params.vep_cache

if (workflow.profile.contains('awsbatch')) {
    summary['AWS Region']   = params.awsregion
    summary['AWS Queue']    = params.awsqueue
    summary['AWS CLI']      = params.awscli
}

summary['Config Profile'] = workflow.profile
if (params.config_profile_description) summary['Config Description'] = params.config_profile_description
if (params.config_profile_contact)     summary['Config Contact']     = params.config_profile_contact
if (params.config_profile_url)         summary['Config URL']         = params.config_profile_url
if (params.email || params.email_on_fail) {
    summary['E-mail Address']    = params.email
    summary['E-mail on failure'] = params.email_on_fail
    summary['MultiQC maxsize']   = params.max_multiqc_email_size
}

log.info summary.collect { k, v -> "${k.padRight(18)}: $v" }.join("\n")
if (params.monochrome_logs) log.info "----------------------------------------------------"
else log.info "-\033[2m--------------------------------------------------\033[0m-"

if ('mutect2' in tools && !(params.pon)) log.warn "[nf-core/sarek] Mutect2 was requested, but as no panel of normals were given, results will not be optimal"

// Check the hostnames against configured profiles
checkHostname()

Channel.from(summary.collect{ [it.key, it.value] })
    .map { k,v -> "<dt>$k</dt><dd><samp>${v ?: '<span style=\"color:#999999;\">N/A</a>'}</samp></dd>" }
    .reduce { a, b -> return [a, b].join("\n            ") }
    .map { x -> """
    id: 'sarek-summary'
    description: " - this information is collected when the pipeline is started."
    section_name: 'nf-core/sarek Workflow Summary'
    section_href: 'https://github.com/nf-core/sarek'
    plot_type: 'html'
    data: |
        <dl class=\"dl-horizontal\">
            $x
        </dl>
    """.stripIndent() }
    .set { ch_workflow_summary }

// Parse software version numbers

process Get_software_versions {
    publishDir path:"${params.outdir}/pipeline_info", mode: params.publish_dir_mode,
        saveAs: { it.indexOf(".csv") > 0 ? it : null }

    output:
        file 'software_versions_mqc.yaml' into ch_software_versions_yaml
        file "software_versions.csv"

    when: !('versions' in skipQC)

    script:
    """
    alleleCounter --version &> v_allelecount.txt  || true
    bcftools version > v_bcftools.txt 2>&1 || true
    bwa &> v_bwa.txt 2>&1 || true
    configManta.py --version > v_manta.txt 2>&1 || true
    configureStrelkaGermlineWorkflow.py --version > v_strelka.txt 2>&1 || true
    echo "${workflow.manifest.version}" &> v_pipeline.txt 2>&1 || true
    echo "${workflow.nextflow.version}" &> v_nextflow.txt 2>&1 || true
    echo "SNPEFF version"\$(snpEff -h 2>&1) > v_snpeff.txt
    fastqc --version > v_fastqc.txt 2>&1 || true
    freebayes --version > v_freebayes.txt 2>&1 || true
    gatk ApplyBQSR --help 2>&1 | grep Version: > v_gatk.txt 2>&1 || true
    multiqc --version &> v_multiqc.txt 2>&1 || true
    qualimap --version &> v_qualimap.txt 2>&1 || true
    R --version &> v_r.txt  || true
    R -e "library(ASCAT); help(package='ASCAT')" &> v_ascat.txt
    samtools --version &> v_samtools.txt 2>&1 || true
    tiddit &> v_tiddit.txt 2>&1 || true
    trim_galore -v &> v_trim_galore.txt 2>&1 || true
    vcftools --version &> v_vcftools.txt 2>&1 || true
    vep --help &> v_vep.txt 2>&1 || true

    scrape_software_versions.py &> software_versions_mqc.yaml
    """
}

ch_software_versions_yaml = ch_software_versions_yaml.dump(tag:'SOFTWARE VERSIONS')

/*
================================================================================
                                BUILDING INDEXES
================================================================================
*/

// And then initialize channels based on params or indexes that were just built

process BuildBWAindexes {
    tag {fasta}

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: {params.save_reference ? "reference_genome/BWAIndex/${it}" : null }

    input:
        file(fasta) from ch_fasta

    output:
        file("${fasta}.*") into bwaBuilt

    when: !(params.bwa) && params.fasta && 'mapping' in step

    script:
    """
    bwa index ${fasta}
    """
}

ch_bwa = params.bwa ? Channel.value(file(params.bwa)) : bwaBuilt

process BuildDict {
    tag {fasta}

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: {params.save_reference ? "reference_genome/${it}" : null }

    input:
        file(fasta) from ch_fasta

    output:
        file("${fasta.baseName}.dict") into dictBuilt

    when: !(params.dict) && params.fasta && !('annotate' in step)

    script:
    """
    gatk --java-options "-Xmx${task.memory.toGiga()}g" \
        CreateSequenceDictionary \
        --REFERENCE ${fasta} \
        --OUTPUT ${fasta.baseName}.dict
    """
}

ch_dict = params.dict ? Channel.value(file(params.dict)) : dictBuilt

process BuildFastaFai {
    tag {fasta}

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: {params.save_reference ? "reference_genome/${it}" : null }

    input:
        file(fasta) from ch_fasta

    output:
        file("${fasta}.fai") into faiBuilt

    when: !(params.fasta_fai) && params.fasta && !('annotate' in step)

    script:
    """
    samtools faidx ${fasta}
    """
}

ch_fai = params.fasta_fai ? Channel.value(file(params.fasta_fai)) : faiBuilt

process BuildDbsnpIndex {
    tag {dbsnp}

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: {params.save_reference ? "reference_genome/${it}" : null }

    input:
        file(dbsnp) from ch_dbsnp

    output:
        file("${dbsnp}.tbi") into dbsnp_tbi

    when: !(params.dbsnp_index) && params.dbsnp && ('mapping' in step || 'controlfreec' in tools || 'haplotypecaller' in tools || 'mutect2' in tools)

    script:
    """
    tabix -p vcf ${dbsnp}
    """
}

ch_dbsnp_tbi = params.dbsnp ? params.dbsnp_index ? Channel.value(file(params.dbsnp_index)) : dbsnp_tbi : "null"

process BuildGermlineResourceIndex {
    tag {germlineResource}

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: {params.save_reference ? "reference_genome/${it}" : null }

    input:
        file(germlineResource) from ch_germline_resource

    output:
        file("${germlineResource}.tbi") into germline_resource_tbi

    when: !(params.germline_resource_index) && params.germline_resource && 'mutect2' in tools

    script:
    """
    tabix -p vcf ${germlineResource}
    """
}

ch_germline_resource_tbi = params.germline_resource ? params.germline_resource_index ? Channel.value(file(params.germline_resource_index)) : germline_resource_tbi : "null"

process BuildKnownIndelsIndex {
    tag {knownIndels}

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: {params.save_reference ? "reference_genome/${it}" : null }

    input:
        each file(knownIndels) from ch_known_indels

    output:
        file("${knownIndels}.tbi") into known_indels_tbi

    when: !(params.known_indels_index) && params.known_indels && 'mapping' in step

    script:
    """
    tabix -p vcf ${knownIndels}
    """
}

ch_known_indels_tbi = params.known_indels ? params.known_indels_index ? Channel.value(file(params.known_indels_index)) : known_indels_tbi.collect() : "null"

process BuildPonIndex {
    tag {pon}

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: {params.save_reference ? "reference_genome/${it}" : null }

    input:
        file(pon) from ch_pon

    output:
        file("${pon}.tbi") into pon_tbi

    when: !(params.pon_index) && params.pon && ('tnscope' in tools || 'mutect2' in tools)

    script:
    """
    tabix -p vcf ${pon}
    """
}

ch_pon_tbi = params.pon ? params.pon_index ? Channel.value(file(params.pon_index)) : pon_tbi : "null"

process BuildIntervals {
  tag {fastaFai}

  publishDir params.outdir, mode: params.publish_dir_mode,
    saveAs: {params.save_reference ? "reference_genome/${it}" : null }

  input:
    file(fastaFai) from ch_fai

  output:
    file("${fastaFai.baseName}.bed") into intervalBuilt

  when: !(params.intervals) && !('annotate' in step) && !(params.no_intervals)

  script:
  """
  awk -v FS='\t' -v OFS='\t' '{ print \$1, \"0\", \$2 }' ${fastaFai} > ${fastaFai.baseName}.bed
  """
}

ch_intervals = params.no_intervals ? "null" : params.intervals && !('annotate' in step) ? Channel.value(file(params.intervals)) : intervalBuilt

/*
================================================================================
                                  PREPROCESSING
================================================================================
*/

// STEP 0: CREATING INTERVALS FOR PARALLELIZATION (PREPROCESSING AND VARIANT CALLING)

process CreateIntervalBeds {
    tag {intervals.fileName}

    input:
        file(intervals) from ch_intervals

    output:
        file '*.bed' into bedIntervals mode flatten

    when: (!params.no_intervals) && step != 'annotate'

    script:
    // If the interval file is BED format, the fifth column is interpreted to
    // contain runtime estimates, which is then used to combine short-running jobs
    if (hasExtension(intervals, "bed"))
        """
        awk -vFS="\t" '{
          t = \$5  # runtime estimate
          if (t == "") {
            # no runtime estimate in this row, assume default value
            t = (\$3 - \$2) / ${params.nucleotides_per_second}
          }
          if (name == "" || (chunk > 600 && (chunk + t) > longest * 1.05)) {
            # start a new chunk
            name = sprintf("%s_%d-%d.bed", \$1, \$2+1, \$3)
            chunk = 0
            longest = 0
          }
          if (t > longest)
            longest = t
          chunk += t
          print \$0 > name
        }' ${intervals}
        """
    else if (hasExtension(intervals, "interval_list"))
        """
        grep -v '^@' ${intervals} | awk -vFS="\t" '{
          name = sprintf("%s_%d-%d", \$1, \$2, \$3);
          printf("%s\\t%d\\t%d\\n", \$1, \$2-1, \$3) > name ".bed"
        }'
        """
    else
        """
        awk -vFS="[:-]" '{
          name = sprintf("%s_%d-%d", \$1, \$2, \$3);
          printf("%s\\t%d\\t%d\\n", \$1, \$2-1, \$3) > name ".bed"
        }' ${intervals}
        """
}

bedIntervals = bedIntervals
    .map { intervalFile ->
        def duration = 0.0
        for (line in intervalFile.readLines()) {
            final fields = line.split('\t')
            if (fields.size() >= 5) duration += fields[4].toFloat()
            else {
                start = fields[1].toInteger()
                end = fields[2].toInteger()
                duration += (end - start) / params.nucleotides_per_second
            }
        }
        [duration, intervalFile]
        }.toSortedList({ a, b -> b[0] <=> a[0] })
    .flatten().collate(2)
    .map{duration, intervalFile -> intervalFile}

bedIntervals = bedIntervals.dump(tag:'bedintervals')

if (params.no_intervals && step != 'annotate') bedIntervals = Channel.from(file("no_intervals.bed"))

(intBaseRecalibrator, intApplyBQSR, intHaplotypeCaller, intMpileup, bedIntervals) = bedIntervals.into(5)

// PREPARING CHANNELS FOR PREPROCESSING AND QC

inputBam = Channel.create()
inputPairReads = Channel.create()

if (step in ['recalibrate', 'variantcalling', 'annotate']) {
    inputBam.close()
    inputPairReads.close()
} else inputSample.choice(inputPairReads, inputBam) {hasExtension(it[3], "bam") ? 1 : 0}

(inputBam, inputBamFastQC) = inputBam.into(2)

// Removing inputFile2 wich is null in case of uBAM
inputBamFastQC = inputBamFastQC.map {
    idPatient, idSample, idRun, inputFile1, inputFile2 ->
    [idPatient, idSample, idRun, inputFile1]
}

if (params.split_fastq){
    inputPairReads = inputPairReads
        // newly splitfastq are named based on split, so the name is easier to catch
        .splitFastq(by: params.split_fastq, compress:true, file:"split", pe:true)
        .map {idPatient, idSample, idRun, reads1, reads2 ->
            // The split fastq read1 is the 4th element (indexed 3) its name is split_3
            // The split fastq read2's name is split_4
            // It's followed by which split it's acutally based on the mother fastq file
            // Index start at 1
            // Extracting the index to get a new IdRun
            splitIndex = reads1.fileName.toString().minus("split_3.").minus(".gz")
            newIdRun = idRun + "_" + splitIndex
            // Giving the files a new nice name
            newReads1 = file("${idSample}_${newIdRun}_R1.fastq.gz")
            newReads2 = file("${idSample}_${newIdRun}_R2.fastq.gz")
            [idPatient, idSample, newIdRun, reads1, reads2]}
}

inputPairReads = inputPairReads.dump(tag:'INPUT')

(inputPairReads, inputPairReadsTrimGalore, inputPairReadsFastQC) = inputPairReads.into(3)

// STEP 0.5: QC ON READS

// TODO: Use only one process for FastQC for FASTQ files and uBAM files
// FASTQ and uBAM files are renamed based on the sample name

process FastQCFQ {
    label 'FastQC'
    label 'cpus_2'

    tag {idPatient + "-" + idRun}

    publishDir "${params.outdir}/Reports/${idSample}/FastQC/${idSample}_${idRun}", mode: params.publish_dir_mode

    input:
        set idPatient, idSample, idRun, file("${idSample}_${idRun}_R1.fastq.gz"), file("${idSample}_${idRun}_R2.fastq.gz") from inputPairReadsFastQC

    output:
        file("*.{html,zip}") into fastQCFQReport

    when: !('fastqc' in skipQC)

    script:
    """
    fastqc -t 2 -q ${idSample}_${idRun}_R1.fastq.gz ${idSample}_${idRun}_R2.fastq.gz
    """
}

process FastQCBAM {
    label 'FastQC'
    label 'cpus_2'

    tag {idPatient + "-" + idRun}

    publishDir "${params.outdir}/Reports/${idSample}/FastQC/${idSample}_${idRun}", mode: params.publish_dir_mode

    input:
        set idPatient, idSample, idRun, file("${idSample}_${idRun}.bam") from inputBamFastQC

    output:
        file("*.{html,zip}") into fastQCBAMReport

    when: !('fastqc' in skipQC)

    script:
    """
    fastqc -t 2 -q ${idSample}_${idRun}.bam
    """
}

fastQCReport = fastQCFQReport.mix(fastQCBAMReport)

fastQCReport = fastQCReport.dump(tag:'FastQC')

outputPairReadsTrimGalore = Channel.create()

if (params.trim_fastq) {
process TrimGalore {
    label 'TrimGalore'

    tag {idPatient + "-" + idRun}

    publishDir "${params.outdir}/Reports/${idSample}/TrimGalore/${idSample}_${idRun}", mode: params.publish_dir_mode,
      saveAs: {filename ->
        if (filename.indexOf("_fastqc") > 0) "FastQC/$filename"
        else if (filename.indexOf("trimming_report.txt") > 0) "logs/$filename"
        else if (params.save_trimmed) filename
        else null
      }

    input:
        set idPatient, idSample, idRun, file("${idSample}_${idRun}_R1.fastq.gz"), file("${idSample}_${idRun}_R2.fastq.gz") from inputPairReadsTrimGalore

    output:
        file("*.{html,zip,txt}") into trimGaloreReport
        set idPatient, idSample, idRun, file("${idSample}_${idRun}_R1_val_1.fq.gz"), file("${idSample}_${idRun}_R2_val_2.fq.gz") into outputPairReadsTrimGalore

    script:
    // Calculate number of --cores for TrimGalore based on value of task.cpus
    // See: https://github.com/FelixKrueger/TrimGalore/blob/master/Changelog.md#version-060-release-on-1-mar-2019
    // See: https://github.com/nf-core/atacseq/pull/65
    def cores = 1
    if (task.cpus) {
      cores = (task.cpus as int) - 4
      if (cores < 1) cores = 1
      if (cores > 4) cores = 4
      }
    c_r1 = params.clip_r1 > 0 ? "--clip_r1 ${params.clip_r1}" : ''
    c_r2 = params.clip_r2 > 0 ? "--clip_r2 ${params.clip_r2}" : ''
    tpc_r1 = params.three_prime_clip_r1 > 0 ? "--three_prime_clip_r1 ${params.three_prime_clip_r1}" : ''
    tpc_r2 = params.three_prime_clip_r2 > 0 ? "--three_prime_clip_r2 ${params.three_prime_clip_r2}" : ''
    nextseq = params.trim_nextseq > 0 ? "--nextseq ${params.trim_nextseq}" : ''
    """
    trim_galore --cores $cores --paired --fastqc --gzip $c_r1 $c_r2 $tpc_r1 $tpc_r2 $nextseq  ${idSample}_${idRun}_R1.fastq.gz ${idSample}_${idRun}_R2.fastq.gz
    mv *val_1_fastqc.html "${idSample}_${idRun}_R1.trimmed_fastqc.html"
    mv *val_2_fastqc.html "${idSample}_${idRun}_R2.trimmed_fastqc.html"
    mv *val_1_fastqc.zip "${idSample}_${idRun}_R1.trimmed_fastqc.zip"
    mv *val_2_fastqc.zip "${idSample}_${idRun}_R2.trimmed_fastqc.zip"
    """
  }
} else {
  inputPairReadsTrimGalore
   .set{outputPairReadsTrimGalore}
   trimGaloreReport = Channel.empty()
}

// STEP 1: MAPPING READS TO REFERENCE GENOME WITH BWA MEM

inputPairReads = outputPairReadsTrimGalore.mix(inputBam)
inputPairReads = inputPairReads.dump(tag:'INPUT')

(inputPairReads, inputPairReadsSentieon) = inputPairReads.into(2)
if (params.sentieon) inputPairReads.close()
else inputPairReadsSentieon.close()

process MapReads {
    label 'cpus_max'

    tag {idPatient + "-" + idRun}

    input:
        set idPatient, idSample, idRun, file(inputFile1), file(inputFile2) from inputPairReads
        file(bwaIndex) from ch_bwa
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
        set idPatient, idSample, idRun, file("${idSample}_${idRun}.bam") into bamMapped
        set idPatient, val("${idSample}_${idRun}"), file("${idSample}_${idRun}.bam") into bamMappedBamQC

    script:
    // -K is an hidden option, used to fix the number of reads processed by bwa mem
    // Chunk size can affect bwa results, if not specified,
    // the number of threads can change which can give not deterministic result.
    // cf https://github.com/CCDG/Pipeline-Standardization/blob/master/PipelineStandard.md
    // and https://github.com/gatk-workflows/gatk4-data-processing/blob/8ffa26ff4580df4ac3a5aa9e272a4ff6bab44ba2/processing-for-variant-discovery-gatk4.b37.wgs.inputs.json#L29
    CN = params.sequencing_center ? "CN:${params.sequencing_center}\\t" : ""
    readGroup = "@RG\\tID:${idRun}\\t${CN}PU:${idRun}\\tSM:${idSample}\\tLB:${idSample}\\tPL:illumina"
    // adjust mismatch penalty for tumor samples
    status = statusMap[idPatient, idSample]
    extra = status == 1 ? "-B 3" : ""
    convertToFastq = hasExtension(inputFile1, "bam") ? "gatk --java-options -Xmx${task.memory.toGiga()}g SamToFastq --INPUT=${inputFile1} --FASTQ=/dev/stdout --INTERLEAVE=true --NON_PF=true | \\" : ""
    input = hasExtension(inputFile1, "bam") ? "-p /dev/stdin - 2> >(tee ${inputFile1}.bwa.stderr.log >&2)" : "${inputFile1} ${inputFile2}"
    """
        ${convertToFastq}
        bwa mem -K 100000000 -R \"${readGroup}\" ${extra} -t ${task.cpus} -M ${fasta} \
        ${input} | \
        samtools sort --threads ${task.cpus} -m 2G - > ${idSample}_${idRun}.bam
    """
}

bamMapped = bamMapped.dump(tag:'Mapped BAM')
// Sort BAM whether they are standalone or should be merged

singleBam = Channel.create()
multipleBam = Channel.create()
bamMapped.groupTuple(by:[0, 1])
    .choice(singleBam, multipleBam) {it[2].size() > 1 ? 1 : 0}
singleBam = singleBam.map {
    idPatient, idSample, idRun, bam ->
    [idPatient, idSample, bam]
}
singleBam = singleBam.dump(tag:'Single BAM')

// STEP 1': MAPPING READS TO REFERENCE GENOME WITH SENTIEON BWA MEM

process SentieonMapReads {
    label 'cpus_max'
    label 'memory_max'
    label 'sentieon'

    tag {idPatient + "-" + idRun}

    input:
        set idPatient, idSample, idRun, file(inputFile1), file(inputFile2) from inputPairReadsSentieon
        file(bwaIndex) from ch_bwa
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
        set idPatient, idSample, idRun, file("${idSample}_${idRun}.bam") into bamMappedSentieon
        set idPatient, idSample, file("${idSample}_${idRun}.bam") into bamMappedSentieonBamQC

    when: params.sentieon

    script:
    // -K is an hidden option, used to fix the number of reads processed by bwa mem
    // Chunk size can affect bwa results, if not specified,
    // the number of threads can change which can give not deterministic result.
    // cf https://github.com/CCDG/Pipeline-Standardization/blob/master/PipelineStandard.md
    // and https://github.com/gatk-workflows/gatk4-data-processing/blob/8ffa26ff4580df4ac3a5aa9e272a4ff6bab44ba2/processing-for-variant-discovery-gatk4.b37.wgs.inputs.json#L29
    CN = params.sequencing_center ? "CN:${params.sequencing_center}\\t" : ""
    readGroup = "@RG\\tID:${idRun}\\t${CN}PU:${idRun}\\tSM:${idSample}\\tLB:${idSample}\\tPL:illumina"
    // adjust mismatch penalty for tumor samples
    status = statusMap[idPatient, idSample]
    extra = status == 1 ? "-B 3" : ""
    """
    sentieon bwa mem -K 100000000 -R \"${readGroup}\" ${extra} -t ${task.cpus} -M ${fasta} \
    ${inputFile1} ${inputFile2} | \
    sentieon util sort -r ${fasta} -o ${idSample}_${idRun}.bam -t ${task.cpus} --sam2bam -i -
        """
}

bamMappedSentieon = bamMappedSentieon.dump(tag:'Sentieon Mapped BAM')
// Sort BAM whether they are standalone or should be merged

singleBamSentieon = Channel.create()
multipleBamSentieon = Channel.create()
bamMappedSentieon.groupTuple(by:[0, 1])
    .choice(singleBamSentieon, multipleBamSentieon) {it[2].size() > 1 ? 1 : 0}
singleBamSentieon = singleBamSentieon.map {
    idPatient, idSample, idRun, bam ->
    [idPatient, idSample, bam]
}
singleBamSentieon = singleBamSentieon.dump(tag:'Single BAM')

// STEP 1.5: MERGING BAM FROM MULTIPLE LANES

multipleBam = multipleBam.mix(multipleBamSentieon)

process MergeBamMapped {
    label 'cpus_8'

    tag {idPatient + "-" + idSample}

    input:
        set idPatient, idSample, idRun, file(bam) from multipleBam

    output:
        set idPatient, idSample, file("${idSample}.bam") into mergedBam

    script:
    """
    samtools merge --threads ${task.cpus} ${idSample}.bam ${bam}
    """
}

mergedBam = mergedBam.dump(tag:'Merged BAM')

mergedBam = mergedBam.mix(singleBam,singleBamSentieon)

(mergedBam, mergedBamForSentieon) = mergedBam.into(2)

if (!params.sentieon) mergedBamForSentieon.close()
else mergedBam.close()

mergedBam = mergedBam.dump(tag:'BAMs for MD')
mergedBamForSentieon = mergedBamForSentieon.dump(tag:'Sentieon BAMs to Index')

process IndexBamMergedForSentieon {
    label 'cpus_8'

    tag {idPatient + "-" + idSample}

    input:
        set idPatient, idSample, file(bam) from mergedBamForSentieon

    output:
        set idPatient, idSample, file(bam), file("${idSample}.bam.bai") into bamForSentieonDedup

    script:
    """
    samtools index ${bam}
    """
}

(mergedBam, mergedBamToIndex) = mergedBam.into(2)

process IndexBamFile {
    label 'cpus_8'

    tag {idPatient + "-" + idSample}

    input:
        set idPatient, idSample, file(bam) from mergedBamToIndex

    output:
        set idPatient, idSample, file(bam), file("*.bai") into indexedBam

    when: !params.known_indels

    script:
    """
    samtools index ${bam}
    mv ${bam}.bai ${bam.baseName}.bai
    """
}

// STEP 2: MARKING DUPLICATES

process MarkDuplicatesSpark {
    label 'cpus_16'

    tag {idPatient + "-" + idSample}

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: {
            if (it == "${idSample}.bam.metrics") "Reports/${idSample}/MarkDuplicates/${it}"
            else "Preprocessing/${idSample}/DuplicateMarked/${it}"
        }

    input:
        set idPatient, idSample, file("${idSample}.bam") from mergedBam

    output:
        set idPatient, idSample, file("${idSample}.md.bam"), file("${idSample}.md.bam.bai") into duplicateMarkedBams
        file ("${idSample}.bam.metrics") optional true into markDuplicatesReport

    when: params.known_indels

    script:
    markdup_java_options = task.memory.toGiga() > 8 ? params.markdup_java_options : "\"-Xms" +  (task.memory.toGiga() / 2).trunc() + "g -Xmx" + (task.memory.toGiga() - 1) + "g\""
    metrics = 'markduplicates' in skipQC ? '' : "-M ${idSample}.bam.metrics"
    """
    gatk --java-options ${markdup_java_options} \
        MarkDuplicatesSpark \
        -I ${idSample}.bam \
        -O ${idSample}.md.bam \
        ${metrics} \
        --tmp-dir . \
        --create-output-bam-index true
    """
}

if ('markduplicates' in skipQC) markDuplicatesReport.close()

duplicateMarkedBams = duplicateMarkedBams.dump(tag:'MD BAM')
markDuplicatesReport = markDuplicatesReport.dump(tag:'MD Report')

(bamMD, bamMDToJoin) = duplicateMarkedBams.into(2)

bamBaseRecalibrator = bamMD.combine(intBaseRecalibrator)

bamBaseRecalibrator = bamBaseRecalibrator.dump(tag:'BAM FOR BASERECALIBRATOR')

// STEP 2': SENTIEON DEDUP

process SentieonDedup {
    label 'cpus_max'
    label 'memory_max'
    label 'sentieon'

    tag {idPatient + "-" + idSample}

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: {
            if (it == "${idSample}_*.txt" && 'sentieon' in skipQC) null
            else if (it == "${idSample}_*.txt") "Reports/${idSample}/Sentieon/${it}"
            else null
        }

    input:
        set idPatient, idSample, file(bam), file(bai) from bamForSentieonDedup
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
        set idPatient, idSample, file("${idSample}.deduped.bam"), file("${idSample}.deduped.bam.bai") into bamDedupedSentieon
        file("${idSample}_*.txt") into bamDedupedSentieonQC

    when: params.sentieon

    script:
    """
    sentieon driver \
        -t ${task.cpus} \
        -i ${bam} \
        -r ${fasta} \
        --algo GCBias --summary ${idSample}_gc_summary.txt ${idSample}_gc_metric.txt \
        --algo MeanQualityByCycle ${idSample}_mq_metric.txt \
        --algo QualDistribution ${idSample}_qd_metric.txt \
        --algo InsertSizeMetricAlgo ${idSample}_is_metric.txt  \
        --algo AlignmentStat ${idSample}_aln_metric.txt

    sentieon driver \
        -t ${task.cpus} \
        -i ${bam} \
        --algo LocusCollector \
        --fun score_info ${idSample}_score.gz

    sentieon driver \
        -t ${task.cpus} \
        -i ${bam} \
        --algo Dedup \
        --rmdup \
        --score_info ${idSample}_score.gz  \
        --metrics ${idSample}_dedup_metric.txt ${idSample}.deduped.bam
    """
}

// STEP 3: CREATING RECALIBRATION TABLES

process BaseRecalibrator {
    label 'cpus_1'

    tag {idPatient + "-" + idSample + "-" + intervalBed.baseName}

    input:
        set idPatient, idSample, file(bam), file(bai), file(intervalBed) from bamBaseRecalibrator
        file(dbsnp) from ch_dbsnp
        file(dbsnpIndex) from ch_dbsnp_tbi
        file(fasta) from ch_fasta
        file(dict) from ch_dict
        file(fastaFai) from ch_fai
        file(knownIndels) from ch_known_indels
        file(knownIndelsIndex) from ch_known_indels_tbi

    output:
        set idPatient, idSample, file("${prefix}${idSample}.recal.table") into tableGatherBQSRReports
        set idPatient, idSample into recalTableTSVnoInt

    when: params.known_indels

    script:
    dbsnpOptions = params.dbsnp ? "--known-sites ${dbsnp}" : ""
    knownOptions = params.known_indels ? knownIndels.collect{"--known-sites ${it}"}.join(' ') : ""
    prefix = params.no_intervals ? "" : "${intervalBed.baseName}_"
    intervalsOptions = params.no_intervals ? "" : "-L ${intervalBed}"
    // TODO: --use-original-qualities ???
    """
    gatk --java-options -Xmx${task.memory.toGiga()}g \
        BaseRecalibrator \
        -I ${bam} \
        -O ${prefix}${idSample}.recal.table \
        --tmp-dir /tmp \
        -R ${fasta} \
        ${intervalsOptions} \
        ${dbsnpOptions} \
        ${knownOptions} \
        --verbosity INFO
    """
}

if (!params.no_intervals) tableGatherBQSRReports = tableGatherBQSRReports.groupTuple(by:[0, 1])

tableGatherBQSRReports = tableGatherBQSRReports.dump(tag:'BQSR REPORTS')

if (params.no_intervals) {
    (tableGatherBQSRReports, tableGatherBQSRReportsNoInt) = tableGatherBQSRReports.into(2)
    recalTable = tableGatherBQSRReportsNoInt
} else recalTableTSVnoInt.close()

// STEP 3.5: MERGING RECALIBRATION TABLES

process GatherBQSRReports {
    label 'memory_singleCPU_2_task'
    label 'cpus_2'

    tag {idPatient + "-" + idSample}

    publishDir "${params.outdir}/Preprocessing/${idSample}/DuplicateMarked", mode: params.publish_dir_mode, overwrite: false

    input:
        set idPatient, idSample, file(recal) from tableGatherBQSRReports

    output:
        set idPatient, idSample, file("${idSample}.recal.table") into recalTable
        file("${idSample}.recal.table") into baseRecalibratorReport
        set idPatient, idSample into recalTableTSV

    when: !(params.no_intervals)

    script:
    input = recal.collect{"-I ${it}"}.join(' ')
    """
    gatk --java-options -Xmx${task.memory.toGiga()}g \
        GatherBQSRReports \
        ${input} \
        -O ${idSample}.recal.table \
    """
}

if ('baserecalibrator' in skipQC) baseRecalibratorReport.close()

recalTable = recalTable.dump(tag:'RECAL TABLE')

(recalTableTSV, recalTableSampleTSV) = recalTableTSV.mix(recalTableTSVnoInt).into(2)

// Create TSV files to restart from this step
recalTableTSV.map { idPatient, idSample ->
    status = statusMap[idPatient, idSample]
    gender = genderMap[idPatient]
    bam = "${params.outdir}/Preprocessing/${idSample}/DuplicateMarked/${idSample}.md.bam"
    bai = "${params.outdir}/Preprocessing/${idSample}/DuplicateMarked/${idSample}.md.bam.bai"
    recalTable = "${params.outdir}/Preprocessing/${idSample}/DuplicateMarked/${idSample}.recal.table"
    "${idPatient}\t${gender}\t${status}\t${idSample}\t${bam}\t${bai}\t${recalTable}\n"
}.collectFile(
    name: 'duplicateMarked.tsv', sort: true, storeDir: "${params.outdir}/Preprocessing/TSV"
)

recalTableSampleTSV
    .collectFile(storeDir: "${params.outdir}/Preprocessing/TSV/") {
        idPatient, idSample ->
        status = statusMap[idPatient, idSample]
        gender = genderMap[idPatient]
        bam = "${params.outdir}/Preprocessing/${idSample}/DuplicateMarked/${idSample}.md.bam"
        bai = "${params.outdir}/Preprocessing/${idSample}/DuplicateMarked/${idSample}.md.bam.bai"
        recalTable = "${params.outdir}/Preprocessing/${idSample}/DuplicateMarked/${idSample}.recal.table"
        ["duplicateMarked_${idSample}.tsv", "${idPatient}\t${gender}\t${status}\t${idSample}\t${bam}\t${bai}\t${recalTable}\n"]
}

bamApplyBQSR = bamMDToJoin.join(recalTable, by:[0,1])

if (step == 'recalibrate') bamApplyBQSR = inputSample

bamApplyBQSR = bamApplyBQSR.dump(tag:'BAM + BAI + RECAL TABLE')

bamApplyBQSR = bamApplyBQSR.combine(intApplyBQSR)

bamApplyBQSR = bamApplyBQSR.dump(tag:'BAM + BAI + RECAL TABLE + INT')

// STEP 4: RECALIBRATING

process ApplyBQSR {
    label 'memory_singleCPU_2_task'
    label 'cpus_2'

    tag {idPatient + "-" + idSample + "-" + intervalBed.baseName}

    input:
        set idPatient, idSample, file(bam), file(bai), file(recalibrationReport), file(intervalBed) from bamApplyBQSR
        file(dict) from ch_dict
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
        set idPatient, idSample, file("${prefix}${idSample}.recal.bam") into bamMergeBamRecal

    script:
    prefix = params.no_intervals ? "" : "${intervalBed.baseName}_"
    intervalsOptions = params.no_intervals ? "" : "-L ${intervalBed}"
    """
    gatk --java-options -Xmx${task.memory.toGiga()}g \
        ApplyBQSR \
        -R ${fasta} \
        --input ${bam} \
        --output ${prefix}${idSample}.recal.bam \
        ${intervalsOptions} \
        --bqsr-recal-file ${recalibrationReport}
    """
}

bamMergeBamRecal = bamMergeBamRecal.groupTuple(by:[0, 1])
(bamMergeBamRecal, bamMergeBamRecalNoInt) = bamMergeBamRecal.into(2)

// STEP 4': SENTIEON BQSR

bamDedupedSentieon = bamDedupedSentieon.dump(tag:'deduped.bam')

process SentieonBQSR {
    label 'cpus_max'
    label 'memory_max'
    label 'sentieon'

    tag {idPatient + "-" + idSample}

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: {
            if (it == "${idSample}_recal_result.csv" && 'sentieon' in skipQC) "Reports/${idSample}/Sentieon/${it}"
            else "Preprocessing/${idSample}/RecalSentieon/${it}"
        }

    input:
        set idPatient, idSample, file(bam), file(bai) from bamDedupedSentieon
        file(dbsnp) from ch_dbsnp
        file(dbsnpIndex) from ch_dbsnp_tbi
        file(fasta) from ch_fasta
        file(dict) from ch_dict
        file(fastaFai) from ch_fai
        file(knownIndels) from ch_known_indels
        file(knownIndelsIndex) from ch_known_indels_tbi

    output:
        set idPatient, idSample, file("${idSample}.recal.bam"), file("${idSample}.recal.bam.bai") into bamRecalSentieon
                set idPatient, idSample into bamRecalSentieonTSV
        file("${idSample}_recal_result.csv") into bamRecalSentieonQC

    when: params.sentieon

    script:
    known = knownIndels.collect{"--known-sites ${it}"}.join(' ')
    """
    sentieon driver  \
        -t ${task.cpus} \
        -r ${fasta} \
        -i ${idSample}.deduped.bam \
        --algo QualCal \
        -k ${dbsnp} \
        ${idSample}.recal.table

    sentieon driver \
        -t ${task.cpus} \
        -r ${fasta} \
        -i ${idSample}.deduped.bam \
        -q ${idSample}.recal.table \
        --algo QualCal \
        -k ${dbsnp} \
        ${idSample}.table.post \
        --algo ReadWriter ${idSample}.recal.bam

    sentieon driver \
        -t ${task.cpus} \
        --algo QualCal \
        --plot \
        --before ${idSample}.recal.table \
        --after ${idSample}.table.post \
        ${idSample}_recal_result.csv
    """
}

(bamRecalSentieonTSV, bamRecalSentieonSampleTSV) = bamRecalSentieonTSV.into(2)

// Creating a TSV file to restart from this step
bamRecalSentieonTSV.map { idPatient, idSample ->
    gender = genderMap[idPatient]
    status = statusMap[idPatient, idSample]
    bam = "${params.outdir}/Preprocessing/${idSample}/RecalSentieon/${idSample}.recal.bam"
    bai = "${params.outdir}/Preprocessing/${idSample}/RecalSentieon/${idSample}.recal.bam.bai"
    "${idPatient}\t${gender}\t${status}\t${idSample}\t${bam}\t${bai}\n"
}.collectFile(
    name: 'recalibrated_sentieon.tsv', sort: true, storeDir: "${params.outdir}/Preprocessing/TSV"
)

bamRecalSentieonSampleTSV
    .collectFile(storeDir: "${params.outdir}/Preprocessing/TSV") {
        idPatient, idSample ->
        status = statusMap[idPatient, idSample]
        gender = genderMap[idPatient]
        bam = "${params.outdir}/Preprocessing/${idSample}/RecalSentieon/${idSample}.recal.bam"
        bai = "${params.outdir}/Preprocessing/${idSample}/RecalSentieon/${idSample}.recal.bam.bai"
        ["recalibrated_sentieon_${idSample}.tsv", "${idPatient}\t${gender}\t${status}\t${idSample}\t${bam}\t${bai}\n"]
}

// STEP 4.5: MERGING THE RECALIBRATED BAM FILES

process MergeBamRecal {
    label 'cpus_8'

    tag {idPatient + "-" + idSample}

    publishDir "${params.outdir}/Preprocessing/${idSample}/Recalibrated", mode: params.publish_dir_mode

    input:
        set idPatient, idSample, file(bam) from bamMergeBamRecal

    output:
        set idPatient, idSample, file("${idSample}.recal.bam"), file("${idSample}.recal.bam.bai") into bamRecal
        set idPatient, idSample, file("${idSample}.recal.bam") into bamRecalQC
        set idPatient, idSample into bamRecalTSV

    when: !(params.no_intervals)

    script:
    """
    samtools merge --threads ${task.cpus} ${idSample}.recal.bam ${bam}
    samtools index ${idSample}.recal.bam
    """
}

// STEP 4.5': INDEXING THE RECALIBRATED BAM FILES

process IndexBamRecal {
    label 'cpus_8'

    tag {idPatient + "-" + idSample}

    publishDir "${params.outdir}/Preprocessing/${idSample}/Recalibrated", mode: params.publish_dir_mode

    input:
        set idPatient, idSample, file("${idSample}.recal.bam") from bamMergeBamRecalNoInt

    output:
        set idPatient, idSample, file("${idSample}.recal.bam"), file("${idSample}.recal.bam.bai") into bamRecalNoInt
        set idPatient, idSample, file("${idSample}.recal.bam") into bamRecalQCnoInt
        set idPatient, idSample into bamRecalTSVnoInt

    when: params.no_intervals

    script:
    """
    samtools index ${idSample}.recal.bam
    """
}

bamRecal = bamRecal.mix(bamRecalNoInt)
bamRecalQC = bamRecalQC.mix(bamRecalQCnoInt)
bamRecalTSV = bamRecalTSV.mix(bamRecalTSVnoInt)

(bamRecalBamQC, bamRecalSamToolsStats) = bamRecalQC.into(2)
(bamRecalTSV, bamRecalSampleTSV) = bamRecalTSV.into(2)

// Creating a TSV file to restart from this step
bamRecalTSV.map { idPatient, idSample ->
    gender = genderMap[idPatient]
    status = statusMap[idPatient, idSample]
    bam = "${params.outdir}/Preprocessing/${idSample}/Recalibrated/${idSample}.recal.bam"
    bai = "${params.outdir}/Preprocessing/${idSample}/Recalibrated/${idSample}.recal.bam.bai"
    "${idPatient}\t${gender}\t${status}\t${idSample}\t${bam}\t${bai}\n"
}.collectFile(
    name: 'recalibrated.tsv', sort: true, storeDir: "${params.outdir}/Preprocessing/TSV"
)

bamRecalSampleTSV
    .collectFile(storeDir: "${params.outdir}/Preprocessing/TSV") {
        idPatient, idSample ->
        status = statusMap[idPatient, idSample]
        gender = genderMap[idPatient]
        bam = "${params.outdir}/Preprocessing/${idSample}/Recalibrated/${idSample}.recal.bam"
        bai = "${params.outdir}/Preprocessing/${idSample}/Recalibrated/${idSample}.recal.bam.bai"
        ["recalibrated_${idSample}.tsv", "${idPatient}\t${gender}\t${status}\t${idSample}\t${bam}\t${bai}\n"]
}

// STEP 5: QC

process SamtoolsStats {
    label 'cpus_2'

    tag {idPatient + "-" + idSample}

    publishDir "${params.outdir}/Reports/${idSample}/SamToolsStats", mode: params.publish_dir_mode

    input:
        set idPatient, idSample, file(bam) from bamRecalSamToolsStats

    output:
        file ("${bam}.samtools.stats.out") into samtoolsStatsReport

    when: !('samtools' in skipQC)

    script:
    """
    samtools stats ${bam} > ${bam}.samtools.stats.out
    """
}

samtoolsStatsReport = samtoolsStatsReport.dump(tag:'SAMTools')

bamBamQC = bamMappedBamQC.mix(bamRecalBamQC)

process BamQC {
    label 'memory_max'
    label 'cpus_16'

    tag {idPatient + "-" + idSample}

    publishDir "${params.outdir}/Reports/${idSample}/bamQC", mode: params.publish_dir_mode

    input:
        set idPatient, idSample, file(bam) from bamBamQC
        file(targetBED) from ch_target_bed

    output:
        file("${bam.baseName}") into bamQCReport

    when: !('bamqc' in skipQC)

    script:
    use_bed = params.target_bed ? "-gff ${targetBED}" : ''
    """
    qualimap --java-mem-size=${task.memory.toGiga()}G \
        bamqc \
        -bam ${bam} \
        --paint-chromosome-limits \
        --genome-gc-distr HUMAN \
        $use_bed \
        -nt ${task.cpus} \
        -skip-duplicated \
        --skip-dup-mode 0 \
        -outdir ${bam.baseName} \
        -outformat HTML
    """
}

bamQCReport = bamQCReport.dump(tag:'BamQC')

/*
================================================================================
                            GERMLINE VARIANT CALLING
================================================================================
*/

// When using sentieon for mapping, Channel bamRecal is bamRecalSentieon
if (params.sentieon && step == 'mapping') bamRecal = bamRecalSentieon

// When no knownIndels for mapping, Channel bamRecal is indexedBam
bamRecal = (params.known_indels && step == 'mapping') ? bamRecal : indexedBam

// When starting with variant calling, Channel bamRecal is inputSample
if (step == 'variantcalling') bamRecal = inputSample

bamRecal = bamRecal.dump(tag:'BAM for Variant Calling')

// Here we have a recalibrated bam set
// The TSV file is formatted like: "idPatient status idSample bamFile baiFile"
// Manta will be run in Germline mode, or in Tumor mode depending on status
// HaplotypeCaller, TIDDIT and Strelka will be run for Normal and Tumor samples

(bamSentieonDNAscope, bamSentieonDNAseq, bamMantaSingle, bamStrelkaSingle, bamTIDDIT, bamRecalAll, bamRecalAllTemp) = bamRecal.into(7)

// To speed Variant Callers up we are chopping the reference into smaller pieces
// Do variant calling by this intervals, and re-merge the VCFs

bamHaplotypeCaller = bamRecalAllTemp.combine(intHaplotypeCaller)

// STEP GATK HAPLOTYPECALLER.1

process HaplotypeCaller {
    label 'memory_singleCPU_task_sq'
    label 'cpus_2'

    tag {idSample + "-" + intervalBed.baseName}

    input:
        set idPatient, idSample, file(bam), file(bai), file(intervalBed) from bamHaplotypeCaller
        file(dbsnp) from ch_dbsnp
        file(dbsnpIndex) from ch_dbsnp_tbi
        file(dict) from ch_dict
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
        set val("HaplotypeCallerGVCF"), idPatient, idSample, file("${intervalBed.baseName}_${idSample}.g.vcf") into gvcfHaplotypeCaller
        set idPatient, idSample, file(intervalBed), file("${intervalBed.baseName}_${idSample}.g.vcf") into gvcfGenotypeGVCFs

    when: 'haplotypecaller' in tools

    script:
    """
    gatk --java-options "-Xmx${task.memory.toGiga()}g -Xms6000m -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10" \
        HaplotypeCaller \
        -R ${fasta} \
        -I ${bam} \
        -L ${intervalBed} \
        -D ${dbsnp} \
        -O ${intervalBed.baseName}_${idSample}.g.vcf \
        -ERC GVCF
    """
}

gvcfHaplotypeCaller = gvcfHaplotypeCaller.groupTuple(by:[0, 1, 2])

if (params.no_gvcf) gvcfHaplotypeCaller.close()
else gvcfHaplotypeCaller = gvcfHaplotypeCaller.dump(tag:'GVCF HaplotypeCaller')

// STEP GATK HAPLOTYPECALLER.2

process GenotypeGVCFs {
    tag {idSample + "-" + intervalBed.baseName}

    input:
        set idPatient, idSample, file(intervalBed), file(gvcf) from gvcfGenotypeGVCFs
        file(dbsnp) from ch_dbsnp
        file(dbsnpIndex) from ch_dbsnp_tbi
        file(dict) from ch_dict
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
    set val("HaplotypeCaller"), idPatient, idSample, file("${intervalBed.baseName}_${idSample}.vcf") into vcfGenotypeGVCFs

    when: 'haplotypecaller' in tools

    script:
    // Using -L is important for speed and we have to index the interval files also
    """
    gatk --java-options -Xmx${task.memory.toGiga()}g \
        IndexFeatureFile \
        -I ${gvcf}

    gatk --java-options -Xmx${task.memory.toGiga()}g \
        GenotypeGVCFs \
        -R ${fasta} \
        -L ${intervalBed} \
        -D ${dbsnp} \
        -V ${gvcf} \
        -O ${intervalBed.baseName}_${idSample}.vcf
    """
}

vcfGenotypeGVCFs = vcfGenotypeGVCFs.groupTuple(by:[0, 1, 2])

// STEP SENTIEON DNAseq

process SentieonDNAseq {
    label 'cpus_max'
    label 'memory_max'
    label 'sentieon'

    tag {idSample}

    input:
        set idPatient, idSample, file(bam), file(bai) from bamSentieonDNAseq
        file(dbsnp) from ch_dbsnp
        file(dbsnpIndex) from ch_dbsnp_tbi
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
    set val("SentieonDNAseq"), idPatient, idSample, file("DNAseq_${idSample}.vcf") into sentieonDNAseqVCF

    when: 'dnaseq' in tools && params.sentieon

    script:
    """
    sentieon driver \
        -t ${task.cpus} \
        -r ${fasta} \
        -i ${bam} \
        --algo Genotyper \
        -d ${dbsnp} \
        DNAseq_${idSample}.vcf
    """
}

sentieonDNAseqVCF = sentieonDNAseqVCF.dump(tag:'sentieon DNAseq')

// STEP SENTIEON DNAscope

process SentieonDNAscope {
    label 'cpus_max'
    label 'memory_max'
    label 'sentieon'

    tag {idSample}

    input:
        set idPatient, idSample, file(bam), file(bai) from bamSentieonDNAscope
        file(dbsnp) from ch_dbsnp
        file(dbsnpIndex) from ch_dbsnp_tbi
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
    set val("SentieonDNAscope"), idPatient, idSample, file("DNAscope_${idSample}.vcf") into sentieonDNAscopeVCF
    set val("SentieonDNAscope"), idPatient, idSample, file("DNAscope_SV_${idSample}.vcf") into sentieonDNAscopeSVVCF

    when: 'dnascope' in tools && params.sentieon

    script:
    """
    sentieon driver \
        -t ${task.cpus} \
        -r ${fasta} \
        -i ${bam} \
        --algo DNAscope \
        -d ${dbsnp} \
        DNAscope_${idSample}.vcf

    sentieon driver \
        -t ${task.cpus} \
        -r ${fasta}\
        -i ${bam} \
        --algo DNAscope \
        --var_type bnd \
        -d ${dbsnp} \
        DNAscope_${idSample}.temp.vcf

    sentieon driver \
        -t ${task.cpus} \
        -r ${fasta}\
        --algo SVSolver \
        -v DNAscope_${idSample}.temp.vcf \
        DNAscope_SV_${idSample}.vcf
    """
}

sentieonDNAscopeVCF = sentieonDNAscopeVCF.dump(tag:'sentieon DNAscope')
sentieonDNAscopeSVVCF = sentieonDNAscopeSVVCF.dump(tag:'sentieon DNAscope SV')

// STEP STRELKA.1 - SINGLE MODE

process StrelkaSingle {
    label 'cpus_max'
    label 'memory_max'

    tag {idSample}

    publishDir "${params.outdir}/VariantCalling/${idSample}/Strelka", mode: params.publish_dir_mode

    input:
        set idPatient, idSample, file(bam), file(bai) from bamStrelkaSingle
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai
        file(targetBED) from ch_target_bed

    output:
        set val("Strelka"), idPatient, idSample, file("*.vcf.gz"), file("*.vcf.gz.tbi") into vcfStrelkaSingle

    when: 'strelka' in tools

    script:
    beforeScript = params.target_bed ? "bgzip --threads ${task.cpus} -c ${targetBED} > call_targets.bed.gz ; tabix call_targets.bed.gz" : ""
    options = params.target_bed ? "--exome --callRegions call_targets.bed.gz" : ""
    """
    ${beforeScript}
    configureStrelkaGermlineWorkflow.py \
        --bam ${bam} \
        --referenceFasta ${fasta} \
        ${options} \
        --runDir Strelka

    python Strelka/runWorkflow.py -m local -j ${task.cpus}

    mv Strelka/results/variants/genome.*.vcf.gz \
        Strelka_${idSample}_genome.vcf.gz
    mv Strelka/results/variants/genome.*.vcf.gz.tbi \
        Strelka_${idSample}_genome.vcf.gz.tbi
    mv Strelka/results/variants/variants.vcf.gz \
        Strelka_${idSample}_variants.vcf.gz
    mv Strelka/results/variants/variants.vcf.gz.tbi \
        Strelka_${idSample}_variants.vcf.gz.tbi
    """
}

vcfStrelkaSingle = vcfStrelkaSingle.dump(tag:'Strelka - Single Mode')

// STEP MANTA.1 - SINGLE MODE

process MantaSingle {
    label 'cpus_max'
    label 'memory_max'

    tag {idSample}

    publishDir "${params.outdir}/VariantCalling/${idSample}/Manta", mode: params.publish_dir_mode

    input:
        set idPatient, idSample, file(bam), file(bai) from bamMantaSingle
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai
        file(targetBED) from ch_target_bed

    output:
        set val("Manta"), idPatient, idSample, file("*.vcf.gz"), file("*.vcf.gz.tbi") into vcfMantaSingle

    when: 'manta' in tools

    script:
    beforeScript = params.target_bed ? "bgzip --threads ${task.cpus} -c ${targetBED} > call_targets.bed.gz ; tabix call_targets.bed.gz" : ""
    options = params.target_bed ? "--exome --callRegions call_targets.bed.gz" : ""
    status = statusMap[idPatient, idSample]
    inputbam = status == 0 ? "--bam" : "--tumorBam"
    vcftype = status == 0 ? "diploid" : "tumor"
    """
    ${beforeScript}
    configManta.py \
        ${inputbam} ${bam} \
        --reference ${fasta} \
        ${options} \
        --runDir Manta

    python Manta/runWorkflow.py -m local -j ${task.cpus}

    mv Manta/results/variants/candidateSmallIndels.vcf.gz \
        Manta_${idSample}.candidateSmallIndels.vcf.gz
    mv Manta/results/variants/candidateSmallIndels.vcf.gz.tbi \
        Manta_${idSample}.candidateSmallIndels.vcf.gz.tbi
    mv Manta/results/variants/candidateSV.vcf.gz \
        Manta_${idSample}.candidateSV.vcf.gz
    mv Manta/results/variants/candidateSV.vcf.gz.tbi \
        Manta_${idSample}.candidateSV.vcf.gz.tbi
    mv Manta/results/variants/${vcftype}SV.vcf.gz \
        Manta_${idSample}.${vcftype}SV.vcf.gz
    mv Manta/results/variants/${vcftype}SV.vcf.gz.tbi \
        Manta_${idSample}.${vcftype}SV.vcf.gz.tbi
    """
}

vcfMantaSingle = vcfMantaSingle.dump(tag:'Single Manta')

// STEP TIDDIT

process TIDDIT {
    tag {idSample}

    publishDir "${params.outdir}/VariantCalling/${idSample}/TIDDIT", mode: params.publish_dir_mode

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: {
            if (it == "TIDDIT_${idSample}.vcf") "VariantCalling/${idSample}/TIDDIT/${it}"
            else "Reports/${idSample}/TIDDIT/${it}"
        }

    input:
        set idPatient, idSample, file(bam), file(bai) from bamTIDDIT
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
        set val("TIDDIT"), idPatient, idSample, file("*.vcf.gz"), file("*.tbi") into vcfTIDDIT
        set file("TIDDIT_${idSample}.old.vcf"), file("TIDDIT_${idSample}.ploidy.tab"), file("TIDDIT_${idSample}.signals.tab"), file("TIDDIT_${idSample}.wig"), file("TIDDIT_${idSample}.gc.wig") into tidditOut

    when: 'tiddit' in tools

    script:
    """
    tiddit --sv -o TIDDIT_${idSample} --bam ${bam} --ref ${fasta}

    mv TIDDIT_${idSample}.vcf TIDDIT_${idSample}.old.vcf

    grep -E "#|PASS" TIDDIT_${idSample}.old.vcf > TIDDIT_${idSample}.vcf

    bgzip --threads ${task.cpus} -c TIDDIT_${idSample}.vcf > TIDDIT_${idSample}.vcf.gz

    tabix TIDDIT_${idSample}.vcf.gz
    """
}

vcfTIDDIT = vcfTIDDIT.dump(tag:'TIDDIT')

/*
================================================================================
                             SOMATIC VARIANT CALLING
================================================================================
*/

// Ascat, Control-FREEC
(bamAscat, bamMpileup, bamMpileupNoInt, bamRecalAll) = bamRecalAll.into(4)

// separate BAM by status
bamNormal = Channel.create()
bamTumor = Channel.create()

bamRecalAll
    .choice(bamTumor, bamNormal) {statusMap[it[0], it[1]] == 0 ? 1 : 0}

// Crossing Normal and Tumor to get a T/N pair for Somatic Variant Calling
// Remapping channel to remove common key idPatient
pairBam = bamNormal.cross(bamTumor).map {
    normal, tumor ->
    [normal[0], normal[1], normal[2], normal[3], tumor[1], tumor[2], tumor[3]]
}

pairBam = pairBam.dump(tag:'BAM Somatic Pair')

// Manta, Strelka, Mutect2
(pairBamManta, pairBamStrelka, pairBamStrelkaBP, pairBamCalculateContamination, pairBamFilterMutect2, pairBamTNscope, pairBam) = pairBam.into(7)

intervalPairBam = pairBam.spread(bedIntervals)

bamMpileup = bamMpileup.spread(intMpileup)

// intervals for Mutect2 calls, FreeBayes and pileups for Mutect2 filtering
(pairBamMutect2, pairBamFreeBayes, pairBamPileupSummaries) = intervalPairBam.into(3)

// STEP FREEBAYES

process FreeBayes {
    tag {idSampleTumor + "_vs_" + idSampleNormal + "-" + intervalBed.baseName}
    label 'cpus_1'

    input:
        set idPatient, idSampleNormal, file(bamNormal), file(baiNormal), idSampleTumor, file(bamTumor), file(baiTumor), file(intervalBed) from pairBamFreeBayes
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
        set val("FreeBayes"), idPatient, val("${idSampleTumor}_vs_${idSampleNormal}"), file("${intervalBed.baseName}_${idSampleTumor}_vs_${idSampleNormal}.vcf") into vcfFreeBayes

    when: 'freebayes' in tools

    script:
    """
    freebayes \
        -f ${fasta} \
        --pooled-continuous \
        --pooled-discrete \
        --genotype-qualities \
        --report-genotype-likelihood-max \
        --allele-balance-priors-off \
        --min-alternate-fraction 0.03 \
        --min-repeat-entropy 1 \
        --min-alternate-count 2 \
        -t ${intervalBed} \
        ${bamTumor} \
        ${bamNormal} > ${intervalBed.baseName}_${idSampleTumor}_vs_${idSampleNormal}.vcf
    """
}

vcfFreeBayes = vcfFreeBayes.groupTuple(by:[0,1,2])

// STEP GATK MUTECT2.1 - RAW CALLS

process Mutect2 {
    tag {idSampleTumor + "_vs_" + idSampleNormal + "-" + intervalBed.baseName}
    label 'cpus_1'

    input:
        set idPatient, idSampleNormal, file(bamNormal), file(baiNormal), idSampleTumor, file(bamTumor), file(baiTumor), file(intervalBed) from pairBamMutect2
        file(dict) from ch_dict
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai
        file(germlineResource) from ch_germline_resource
        file(germlineResourceIndex) from ch_germline_resource_tbi
        file(intervals) from ch_intervals
        file(pon) from ch_pon
        file(ponIndex) from ch_pon_tbi

    output:
        set val("Mutect2"), idPatient, val("${idSampleTumor}_vs_${idSampleNormal}"), file("${intervalBed.baseName}_${idSampleTumor}_vs_${idSampleNormal}.vcf") into mutect2Output
        set idPatient, idSampleNormal, idSampleTumor, file("${intervalBed.baseName}_${idSampleTumor}_vs_${idSampleNormal}.vcf.stats") optional true into intervalStatsFiles
        set idPatient, val("${idSampleTumor}_vs_${idSampleNormal}"), file("${intervalBed.baseName}_${idSampleTumor}_vs_${idSampleNormal}.vcf.stats"), file("${intervalBed.baseName}_${idSampleTumor}_vs_${idSampleNormal}.vcf") optional true into mutect2Stats

    when: 'mutect2' in tools

    script:
    // please make a panel-of-normals, using at least 40 samples
    // https://gatkforums.broadinstitute.org/gatk/discussion/11136/how-to-call-somatic-mutations-using-gatk4-mutect2
    PON = params.pon ? "--panel-of-normals ${pon}" : ""
    """
    # Get raw calls
    gatk --java-options "-Xmx${task.memory.toGiga()}g" \
      Mutect2 \
      -R ${fasta}\
      -I ${bamTumor}  -tumor ${idSampleTumor} \
      -I ${bamNormal} -normal ${idSampleNormal} \
      -L ${intervalBed} \
      --germline-resource ${germlineResource} \
      ${PON} \
      -O ${intervalBed.baseName}_${idSampleTumor}_vs_${idSampleNormal}.vcf
    """
}

mutect2Output = mutect2Output.groupTuple(by:[0,1,2])
mutect2Stats = mutect2Stats.groupTuple(by:[0,1])

// STEP GATK MUTECT2.2 - MERGING STATS

process MergeMutect2Stats {
    tag {idSamplePair}

    publishDir "${params.outdir}/VariantCalling/${idSamplePair}/Mutect2", mode: params.publish_dir_mode

    input:
        set idPatient, idSamplePair, file(statsFiles), file(vcf) from mutect2Stats // Actual stats files and corresponding VCF chunks
        file(dict) from ch_dict
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai
        file(germlineResource) from ch_germline_resource
        file(germlineResourceIndex) from ch_germline_resource_tbi
        file(intervals) from ch_intervals

    output:
        set idPatient, idSamplePair, file("${idSamplePair}.vcf.gz.stats") into mergedStatsFile

    when: 'mutect2' in tools

    script:   
               stats = statsFiles.collect{ "-stats ${it} " }.join(' ')
    """
    gatk --java-options "-Xmx${task.memory.toGiga()}g" \
        MergeMutectStats \
        ${stats} \
        -O ${idSamplePair}.vcf.gz.stats
    """
}

// we are merging the VCFs that are called separatelly for different intervals
// so we can have a single sorted VCF containing all the calls for a given caller

// STEP MERGING VCF - FREEBAYES, GATK HAPLOTYPECALLER & GATK MUTECT2 (UNFILTERED)

vcfConcatenateVCFs = mutect2Output.mix(vcfFreeBayes, vcfGenotypeGVCFs, gvcfHaplotypeCaller)
vcfConcatenateVCFs = vcfConcatenateVCFs.dump(tag:'VCF to merge')

process ConcatVCF {
    label 'cpus_8'

    tag {variantCaller + "-" + idSample}

    publishDir "${params.outdir}/VariantCalling/${idSample}/${"$variantCaller"}", mode: params.publish_dir_mode

    input:
        set variantCaller, idPatient, idSample, file(vcf) from vcfConcatenateVCFs
        file(fastaFai) from ch_fai
        file(targetBED) from ch_target_bed

    output:
    // we have this funny *_* pattern to avoid copying the raw calls to publishdir
        set variantCaller, idPatient, idSample, file("*_*.vcf.gz"), file("*_*.vcf.gz.tbi") into vcfConcatenated

    when: ('haplotypecaller' in tools || 'mutect2' in tools || 'freebayes' in tools)

    script:
    if (variantCaller == 'HaplotypeCallerGVCF')
          outputFile = "HaplotypeCaller_${idSample}.g.vcf"
    else if (variantCaller == "Mutect2")
          outputFile = "Mutect2_unfiltered_${idSample}.vcf"
    else
          outputFile = "${variantCaller}_${idSample}.vcf"
    options = params.target_bed ? "-t ${targetBED}" : ""
    """
    concatenateVCFs.sh -i ${fastaFai} -c ${task.cpus} -o ${outputFile} ${options}
    """
}

(vcfConcatenated, vcfConcatenatedForFilter) = vcfConcatenated.into(2)
vcfConcatenated = vcfConcatenated.dump(tag:'VCF')

// STEP GATK MUTECT2.3 - GENERATING PILEUP SUMMARIES

pairBamPileupSummaries = pairBamPileupSummaries.map{
    idPatient, idSampleNormal, bamNormal, baiNormal, idSampleTumor, bamTumor, baiTumor, intervalBed ->
    [idPatient, idSampleNormal, idSampleTumor, bamNormal, baiNormal, bamTumor, baiTumor, intervalBed]
}.join(intervalStatsFiles, by:[0,1,2])

process PileupSummariesForMutect2 {
    tag {idSampleTumor + "_vs_" + idSampleNormal + "_" + intervalBed.baseName }

    label 'cpus_1'

    input:
        set idPatient, idSampleNormal, idSampleTumor, file(bamNormal), file(baiNormal), file(bamTumor), file(baiTumor), file(intervalBed), file(statsFile) from pairBamPileupSummaries
        file(germlineResource) from ch_germline_resource
        file(germlineResourceIndex) from ch_germline_resource_tbi

    output:
        set idPatient, idSampleNormal, idSampleTumor, file("${intervalBed.baseName}_${idSampleTumor}_pileupsummaries.table") into pileupSummaries

    when: 'mutect2' in tools

    script:
    """
    gatk --java-options "-Xmx${task.memory.toGiga()}g" \
        GetPileupSummaries \
        -I ${bamTumor} \
        -V ${germlineResource} \
        -L ${intervalBed} \
        -O ${intervalBed.baseName}_${idSampleTumor}_pileupsummaries.table
    """
}

pileupSummaries = pileupSummaries.groupTuple(by:[0,1,2])

// STEP GATK MUTECT2.4 - MERGING PILEUP SUMMARIES

process MergePileupSummaries {
    label 'cpus_1'

    tag {idPatient + "_" + idSampleTumor}

    publishDir "${params.outdir}/VariantCalling/${idSampleTumor}/Mutect2", mode: params.publish_dir_mode

    input:
        set idPatient, idSampleNormal, idSampleTumor, file(pileupSums) from pileupSummaries
        file(dict) from ch_dict

    output:
        set idPatient, idSampleNormal, idSampleTumor, file("${idSampleTumor}_pileupsummaries.table") into mergedPileupFile

    when: 'mutect2' in tools
    script:
        allPileups = pileupSums.collect{ "-I ${it} " }.join(' ')
    """
    gatk --java-options "-Xmx${task.memory.toGiga()}g" \
        GatherPileupSummaries \
        --sequence-dictionary ${dict} \
        ${allPileups} \
        -O ${idSampleTumor}_pileupsummaries.table
    """
}

// STEP GATK MUTECT2.5 - CALCULATING CONTAMINATION

pairBamCalculateContamination = pairBamCalculateContamination.map{
    idPatient, idSampleNormal, bamNormal, baiNormal, idSampleTumor, bamTumor, baiTumor ->
    [idPatient, idSampleNormal, idSampleTumor, bamNormal, baiNormal, bamTumor, baiTumor]
}.join(mergedPileupFile, by:[0,1,2])

process CalculateContamination {
    label 'cpus_1'

    tag {idSampleTumor + "_vs_" + idSampleNormal}

    publishDir "${params.outdir}/VariantCalling/${idSampleTumor}/Mutect2", mode: params.publish_dir_mode

    input:
        set idPatient, idSampleNormal, idSampleTumor, file(bamNormal), file(baiNormal), file(bamTumor), file(baiTumor), file(mergedPileup) from pairBamCalculateContamination
 
     output:
        set idPatient, val("${idSampleTumor}_vs_${idSampleNormal}"), file("${idSampleTumor}_contamination.table") into contaminationTable

    when: 'mutect2' in tools

    script:   
             """
    # calculate contamination
    gatk --java-options "-Xmx${task.memory.toGiga()}g" \
        CalculateContamination \
        -I ${idSampleTumor}_pileupsummaries.table \
        -O ${idSampleTumor}_contamination.table
    """
}

// STEP GATK MUTECT2.6 - FILTERING CALLS

mutect2CallsToFilter = vcfConcatenatedForFilter.map{
    variantCaller, idPatient, idSamplePair, vcf, tbi ->
    [idPatient, idSamplePair, vcf, tbi]
}.join(mergedStatsFile, by:[0,1]).join(contaminationTable, by:[0,1])

process FilterMutect2Calls {
    label 'cpus_1'

    tag {idSamplePair}

    publishDir "${params.outdir}/VariantCalling/${idSamplePair}/Mutect2", mode: params.publish_dir_mode

    input:
        set idPatient, idSamplePair, file(unfiltered), file(unfilteredIndex), file(stats), file(contaminationTable) from mutect2CallsToFilter
        file(dict) from ch_dict
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai
        file(germlineResource) from ch_germline_resource
        file(germlineResourceIndex) from ch_germline_resource_tbi
        file(intervals) from ch_intervals
      
                  output:
        set val("Mutect2"), idPatient, idSamplePair, file("Mutect2_filtered_${idSamplePair}.vcf.gz"), file("Mutect2_filtered_${idSamplePair}.vcf.gz.tbi"), file("Mutect2_filtered_${idSamplePair}.vcf.gz.filteringStats.tsv") into filteredMutect2Output

    when: 'mutect2' in tools

    script:
    """
    # do the actual filtering
    gatk --java-options "-Xmx${task.memory.toGiga()}g" \
        FilterMutectCalls \
        -V ${unfiltered} \
        --contamination-table ${contaminationTable} \
        --stats ${stats} \
        -R ${fasta} \
        -O Mutect2_filtered_${idSamplePair}.vcf.gz
    """
}

// STEP SENTIEON TNSCOPE

process SentieonTNscope {
    label 'cpus_max'
    label 'memory_max'
    label 'sentieon'

    tag {idSampleTumor + "_vs_" + idSampleNormal}

    input:
        set idPatient, idSampleNormal, file(bamNormal), file(baiNormal), idSampleTumor, file(bamTumor), file(baiTumor) from pairBamTNscope
        file(dict) from ch_dict
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai
        file(dbsnp) from ch_dbsnp
        file(dbsnpIndex) from ch_dbsnp_tbi
        file(pon) from ch_pon
        file(ponIndex) from ch_pon_tbi

    output:
        set val("SentieonTNscope"), idPatient, val("${idSampleTumor}_vs_${idSampleNormal}"), file("*.vcf") into vcfTNscope

    when: 'tnscope' in tools && params.sentieon

    script:
    PON = params.pon ? "--pon ${pon}" : ""
    """
    sentieon driver \
        -t ${task.cpus} \
        -r ${fasta} \
        -i ${bamTumor} \
        -i ${bamNormal} \
        --algo TNscope \
        --tumor_sample ${idSampleTumor} \
        --normal_sample ${idSampleNormal} \
        --dbsnp ${dbsnp} \
        ${PON} \
        TNscope_${idSampleTumor}_vs_${idSampleNormal}.vcf
    """
}

vcfTNscope = vcfTNscope.dump(tag:'Sentieon TNscope')

sentieonVCF = sentieonDNAseqVCF.mix(sentieonDNAscopeVCF, sentieonDNAscopeSVVCF, vcfTNscope)

process CompressSentieonVCF {
    tag {"${idSample} - ${vcf}"}

    publishDir "${params.outdir}/VariantCalling/${idSample}/${variantCaller}", mode: params.publish_dir_mode

    input:
        set variantCaller, idPatient, idSample, file(vcf) from sentieonVCF

    output:
        set variantCaller, idPatient, idSample, file("*.vcf.gz"), file("*.vcf.gz.tbi") into vcfSentieon

    when: params.sentieon

    script:
    """
    bgzip < ${vcf} > ${vcf}.gz
    tabix ${vcf}.gz
    """
}

vcfSentieon = vcfSentieon.dump(tag:'Sentieon VCF indexed')

// STEP STRELKA.2 - SOMATIC PAIR

process Strelka {
    label 'cpus_max'
    label 'memory_max'

    tag {idSampleTumor + "_vs_" + idSampleNormal}

    publishDir "${params.outdir}/VariantCalling/${idSampleTumor}_vs_${idSampleNormal}/Strelka", mode: params.publish_dir_mode

    input:
        set idPatient, idSampleNormal, file(bamNormal), file(baiNormal), idSampleTumor, file(bamTumor), file(baiTumor) from pairBamStrelka
        file(dict) from ch_dict
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai
        file(targetBED) from ch_target_bed

    output:
        set val("Strelka"), idPatient, val("${idSampleTumor}_vs_${idSampleNormal}"), file("*.vcf.gz"), file("*.vcf.gz.tbi") into vcfStrelka

    when: 'strelka' in tools

    script:
    beforeScript = params.target_bed ? "bgzip --threads ${task.cpus} -c ${targetBED} > call_targets.bed.gz ; tabix call_targets.bed.gz" : ""
    options = params.target_bed ? "--exome --callRegions call_targets.bed.gz" : ""
    """
    ${beforeScript}
    configureStrelkaSomaticWorkflow.py \
        --tumor ${bamTumor} \
        --normal ${bamNormal} \
        --referenceFasta ${fasta} \
        ${options} \
        --runDir Strelka

    python Strelka/runWorkflow.py -m local -j ${task.cpus}

    mv Strelka/results/variants/somatic.indels.vcf.gz \
        Strelka_${idSampleTumor}_vs_${idSampleNormal}_somatic_indels.vcf.gz
    mv Strelka/results/variants/somatic.indels.vcf.gz.tbi \
        Strelka_${idSampleTumor}_vs_${idSampleNormal}_somatic_indels.vcf.gz.tbi
    mv Strelka/results/variants/somatic.snvs.vcf.gz \
        Strelka_${idSampleTumor}_vs_${idSampleNormal}_somatic_snvs.vcf.gz
    mv Strelka/results/variants/somatic.snvs.vcf.gz.tbi \
        Strelka_${idSampleTumor}_vs_${idSampleNormal}_somatic_snvs.vcf.gz.tbi
    """
}

vcfStrelka = vcfStrelka.dump(tag:'Strelka')

// STEP MANTA.2 - SOMATIC PAIR

process Manta {
    label 'cpus_max'
    label 'memory_max'

    tag {idSampleTumor + "_vs_" + idSampleNormal}

    publishDir "${params.outdir}/VariantCalling/${idSampleTumor}_vs_${idSampleNormal}/Manta", mode: params.publish_dir_mode

    input:
        set idPatient, idSampleNormal, file(bamNormal), file(baiNormal), idSampleTumor, file(bamTumor), file(baiTumor) from pairBamManta
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai
        file(targetBED) from ch_target_bed

    output:
        set val("Manta"), idPatient, val("${idSampleTumor}_vs_${idSampleNormal}"), file("*.vcf.gz"), file("*.vcf.gz.tbi") into vcfManta
        set idPatient, idSampleNormal, idSampleTumor, file("*.candidateSmallIndels.vcf.gz"), file("*.candidateSmallIndels.vcf.gz.tbi") into mantaToStrelka

    when: 'manta' in tools

    script:
    beforeScript = params.target_bed ? "bgzip --threads ${task.cpus} -c ${targetBED} > call_targets.bed.gz ; tabix call_targets.bed.gz" : ""
    options = params.target_bed ? "--exome --callRegions call_targets.bed.gz" : ""
    """
    ${beforeScript}
    configManta.py \
        --normalBam ${bamNormal} \
        --tumorBam ${bamTumor} \
        --reference ${fasta} \
        ${options} \
        --runDir Manta

    python Manta/runWorkflow.py -m local -j ${task.cpus}

    mv Manta/results/variants/candidateSmallIndels.vcf.gz \
        Manta_${idSampleTumor}_vs_${idSampleNormal}.candidateSmallIndels.vcf.gz
    mv Manta/results/variants/candidateSmallIndels.vcf.gz.tbi \
        Manta_${idSampleTumor}_vs_${idSampleNormal}.candidateSmallIndels.vcf.gz.tbi
    mv Manta/results/variants/candidateSV.vcf.gz \
        Manta_${idSampleTumor}_vs_${idSampleNormal}.candidateSV.vcf.gz
    mv Manta/results/variants/candidateSV.vcf.gz.tbi \
        Manta_${idSampleTumor}_vs_${idSampleNormal}.candidateSV.vcf.gz.tbi
    mv Manta/results/variants/diploidSV.vcf.gz \
        Manta_${idSampleTumor}_vs_${idSampleNormal}.diploidSV.vcf.gz
    mv Manta/results/variants/diploidSV.vcf.gz.tbi \
        Manta_${idSampleTumor}_vs_${idSampleNormal}.diploidSV.vcf.gz.tbi
    mv Manta/results/variants/somaticSV.vcf.gz \
        Manta_${idSampleTumor}_vs_${idSampleNormal}.somaticSV.vcf.gz
    mv Manta/results/variants/somaticSV.vcf.gz.tbi \
        Manta_${idSampleTumor}_vs_${idSampleNormal}.somaticSV.vcf.gz.tbi
    """
}

vcfManta = vcfManta.dump(tag:'Manta')

// Remmaping channels to match input for StrelkaBP
pairBamStrelkaBP = pairBamStrelkaBP.map {
    idPatientNormal, idSampleNormal, bamNormal, baiNormal, idSampleTumor, bamTumor, baiTumor ->
    [idPatientNormal, idSampleNormal, idSampleTumor, bamNormal, baiNormal, bamTumor, baiTumor]
}.join(mantaToStrelka, by:[0,1,2]).map {
    idPatientNormal, idSampleNormal, idSampleTumor, bamNormal, baiNormal, bamTumor, baiTumor, mantaCSI, mantaCSIi ->
    [idPatientNormal, idSampleNormal, bamNormal, baiNormal, idSampleTumor, bamTumor, baiTumor, mantaCSI, mantaCSIi]
}

// STEP STRELKA.3 - SOMATIC PAIR - BEST PRACTICES

process StrelkaBP {
    label 'cpus_max'
    label 'memory_max'

    tag {idSampleTumor + "_vs_" + idSampleNormal}

    publishDir "${params.outdir}/VariantCalling/${idSampleTumor}_vs_${idSampleNormal}/Strelka", mode: params.publish_dir_mode

    input:
        set idPatient, idSampleNormal, file(bamNormal), file(baiNormal), idSampleTumor, file(bamTumor), file(baiTumor), file(mantaCSI), file(mantaCSIi) from pairBamStrelkaBP
        file(dict) from ch_dict
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai
        file(targetBED) from ch_target_bed

    output:
        set val("Strelka"), idPatient, val("${idSampleTumor}_vs_${idSampleNormal}"), file("*.vcf.gz"), file("*.vcf.gz.tbi") into vcfStrelkaBP

    when: 'strelka' in tools && 'manta' in tools && !params.no_strelka_bp

    script:
    beforeScript = params.target_bed ? "bgzip --threads ${task.cpus} -c ${targetBED} > call_targets.bed.gz ; tabix call_targets.bed.gz" : ""
    options = params.target_bed ? "--exome --callRegions call_targets.bed.gz" : ""
    """
    ${beforeScript}
    configureStrelkaSomaticWorkflow.py \
        --tumor ${bamTumor} \
        --normal ${bamNormal} \
        --referenceFasta ${fasta} \
        --indelCandidates ${mantaCSI} \
        ${options} \
        --runDir Strelka

    python Strelka/runWorkflow.py -m local -j ${task.cpus}

    mv Strelka/results/variants/somatic.indels.vcf.gz \
        StrelkaBP_${idSampleTumor}_vs_${idSampleNormal}_somatic_indels.vcf.gz
    mv Strelka/results/variants/somatic.indels.vcf.gz.tbi \
        StrelkaBP_${idSampleTumor}_vs_${idSampleNormal}_somatic_indels.vcf.gz.tbi
    mv Strelka/results/variants/somatic.snvs.vcf.gz \
        StrelkaBP_${idSampleTumor}_vs_${idSampleNormal}_somatic_snvs.vcf.gz
    mv Strelka/results/variants/somatic.snvs.vcf.gz.tbi \
        StrelkaBP_${idSampleTumor}_vs_${idSampleNormal}_somatic_snvs.vcf.gz.tbi
    """
}

vcfStrelkaBP = vcfStrelkaBP.dump(tag:'Strelka BP')

// STEP ASCAT.1 - ALLELECOUNTER

// Run commands and code from Malin Larsson
// Based on Jesper Eisfeldt's code
process AlleleCounter {
    label 'memory_singleCPU_2_task'

    tag {idSample}

    input:
        set idPatient, idSample, file(bam), file(bai) from bamAscat
        file(acLoci) from ch_ac_loci
        file(dict) from ch_dict
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
        set idPatient, idSample, file("${idSample}.alleleCount") into alleleCounterOut

    when: 'ascat' in tools

    script:
    """
    alleleCounter \
        -l ${acLoci} \
        -r ${fasta} \
        -b ${bam} \
        -o ${idSample}.alleleCount;
    """
}

alleleCountOutNormal = Channel.create()
alleleCountOutTumor = Channel.create()

alleleCounterOut
    .choice(alleleCountOutTumor, alleleCountOutNormal) {statusMap[it[0], it[1]] == 0 ? 1 : 0}

alleleCounterOut = alleleCountOutNormal.combine(alleleCountOutTumor)

alleleCounterOut = alleleCounterOut.map {
    idPatientNormal, idSampleNormal, alleleCountOutNormal,
    idPatientTumor, idSampleTumor, alleleCountOutTumor ->
    [idPatientNormal, idSampleNormal, idSampleTumor, alleleCountOutNormal, alleleCountOutTumor]
}

// STEP ASCAT.2 - CONVERTALLELECOUNTS

// R script from Malin Larssons bitbucket repo:
// https://bitbucket.org/malinlarsson/somatic_wgs_pipeline
process ConvertAlleleCounts {
    label 'memory_singleCPU_2_task'

    tag {idSampleTumor + "_vs_" + idSampleNormal}

    publishDir "${params.outdir}/VariantCalling/${idSampleTumor}_vs_${idSampleNormal}/ASCAT", mode: params.publish_dir_mode

    input:
        set idPatient, idSampleNormal, idSampleTumor, file(alleleCountNormal), file(alleleCountTumor) from alleleCounterOut

    output:
        set idPatient, idSampleNormal, idSampleTumor, file("${idSampleNormal}.BAF"), file("${idSampleNormal}.LogR"), file("${idSampleTumor}.BAF"), file("${idSampleTumor}.LogR") into convertAlleleCountsOut

    when: 'ascat' in tools

    script:
    gender = genderMap[idPatient]
    """
    Rscript ${workflow.projectDir}/bin/convertAlleleCounts.r ${idSampleTumor} ${alleleCountTumor} ${idSampleNormal} ${alleleCountNormal} ${gender}
    """
}

// STEP ASCAT.3 - ASCAT

// R scripts from Malin Larssons bitbucket repo:
// https://bitbucket.org/malinlarsson/somatic_wgs_pipeline
process Ascat {
    label 'memory_singleCPU_2_task'

    tag {idSampleTumor + "_vs_" + idSampleNormal}

    publishDir "${params.outdir}/VariantCalling/${idSampleTumor}_vs_${idSampleNormal}/ASCAT", mode: params.publish_dir_mode

    input:
        set idPatient, idSampleNormal, idSampleTumor, file(bafNormal), file(logrNormal), file(bafTumor), file(logrTumor) from convertAlleleCountsOut
        file(acLociGC) from ch_ac_loci_gc

    output:
        set val("ASCAT"), idPatient, idSampleNormal, idSampleTumor, file("${idSampleTumor}.*.{png,txt}") into ascatOut

    when: 'ascat' in tools

    script:
    gender = genderMap[idPatient]
    purity_ploidy = (params.ascat_purity && params.ascat_ploidy) ? "--purity ${params.ascat_purity} --ploidy ${params.ascat_ploidy}" : ""
    """
    for f in *BAF *LogR; do sed 's/chr//g' \$f > tmpFile; mv tmpFile \$f;done
    Rscript ${workflow.projectDir}/bin/run_ascat.r \
        --tumorbaf ${bafTumor} \
        --tumorlogr ${logrTumor} \
        --normalbaf ${bafNormal} \
        --normallogr ${logrNormal} \
        --tumorname ${idSampleTumor} \
        --basedir ${baseDir} \
        --gcfile ${acLociGC} \
        --gender ${gender} \
        ${purity_ploidy}
    """
}

ascatOut.dump(tag:'ASCAT')

// STEP MPILEUP.1

process Mpileup {
    label 'memory_singleCPU_2_task'

    tag {idSample + "-" + intervalBed.baseName}

    input:
        set idPatient, idSample, file(bam), file(bai), file(intervalBed) from bamMpileup
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
        set idPatient, idSample, file("${prefix}${idSample}.pileup.gz") into mpileupMerge

    when: 'controlfreec' in tools || 'mpileup' in tools

    script:
    prefix = params.no_intervals ? "" : "${intervalBed.baseName}_"
    intervalsOptions = params.no_intervals ? "" : "-l ${intervalBed}"
    """
    samtools mpileup \
        -f ${fasta} ${bam} \
        ${intervalsOptions} \
    | bgzip --threads ${task.cpus} -c > ${prefix}${idSample}.pileup.gz
    """
}

if (!params.no_intervals) {
    mpileupMerge = mpileupMerge.groupTuple(by:[0, 1])
    mpileupNoInt = Channel.empty()
} else {
    (mpileupMerge, mpileupNoInt) = mpileupMerge.into(2)
    mpileupMerge.close()
}

// STEP MPILEUP.2 - MERGE

process MergeMpileup {
    tag {idSample}

    publishDir params.outdir, mode: params.publish_dir_mode, saveAs: { it == "${idSample}.pileup.gz" ? "VariantCalling/${idSample}/mpileup/${it}" : '' }

    input:
        set idPatient, idSample, file(mpileup) from mpileupMerge

    output:
        set idPatient, idSample, file("${idSample}.pileup.gz") into mpileupOut

    when: !(params.no_intervals) && 'controlfreec' in tools || 'mpileup' in tools

    script:
    """
    for i in `ls -1v *.pileup.gz`;
        do zcat \$i >> ${idSample}.pileup
    done

    bgzip --threads ${task.cpus} -c ${idSample}.pileup > ${idSample}.pileup.gz

    rm ${idSample}.pileup
    """
}

mpileupOut = mpileupOut.mix(mpileupNoInt)
mpileupOut = mpileupOut.dump(tag:'mpileup')

mpileupOutNormal = Channel.create()
mpileupOutTumor = Channel.create()

mpileupOut
    .choice(mpileupOutTumor, mpileupOutNormal) {statusMap[it[0], it[1]] == 0 ? 1 : 0}

mpileupOut = mpileupOutNormal.combine(mpileupOutTumor)

mpileupOut = mpileupOut.map {
    idPatientNormal, idSampleNormal, mpileupOutNormal,
    idPatientTumor, idSampleTumor, mpileupOutTumor ->
    [idPatientNormal, idSampleNormal, idSampleTumor, mpileupOutNormal, mpileupOutTumor]
}

// STEP CONTROLFREEC.1 - CONTROLFREEC

process ControlFREEC {
    label 'memory_singleCPU_2_task'

    tag {idSampleTumor + "_vs_" + idSampleNormal}

    publishDir "${params.outdir}/VariantCalling/${idSampleTumor}_vs_${idSampleNormal}/controlFREEC", mode: params.publish_dir_mode

    input:
        set idPatient, idSampleNormal, idSampleTumor, file(mpileupNormal), file(mpileupTumor) from mpileupOut
        file(chrDir) from ch_chr_dir
        file(chrLength) from ch_chr_length
        file(dbsnp) from ch_dbsnp
        file(dbsnpIndex) from ch_dbsnp_tbi
        file(fasta) from ch_fasta
        file(fastaFai) from ch_fai

    output:
        set idPatient, idSampleNormal, idSampleTumor, file("${idSampleTumor}.pileup.gz_CNVs"), file("${idSampleTumor}.pileup.gz_ratio.txt"), file("${idSampleTumor}.pileup.gz_normal_CNVs"), file("${idSampleTumor}.pileup.gz_normal_ratio.txt"), file("${idSampleTumor}.pileup.gz_BAF.txt"), file("${idSampleNormal}.pileup.gz_BAF.txt") into controlFreecViz
        set file("*.pileup.gz*"), file("${idSampleTumor}_vs_${idSampleNormal}.config.txt") into controlFreecOut

    when: 'controlfreec' in tools

    script:
    config = "${idSampleTumor}_vs_${idSampleNormal}.config.txt"
    gender = genderMap[idPatient]
    """
    touch ${config}
    echo "[general]" >> ${config}
    echo "BedGraphOutput = TRUE" >> ${config}
    echo "chrFiles = \${PWD}/${chrDir.fileName}" >> ${config}
    echo "chrLenFile = \${PWD}/${chrLength.fileName}" >> ${config}
    echo "coefficientOfVariation = 0.05" >> ${config}
    echo "contaminationAdjustment = TRUE" >> ${config}
    echo "forceGCcontentNormalization = 0" >> ${config}
    echo "maxThreads = ${task.cpus}" >> ${config}
    echo "minimalSubclonePresence = 20" >> ${config}
    echo "ploidy = 2,3,4" >> ${config}
    echo "sex = ${gender}" >> ${config}
    echo "window = 50000" >> ${config}
    echo "" >> ${config}

    echo "[control]" >> ${config}
    echo "inputFormat = pileup" >> ${config}
    echo "mateFile = \${PWD}/${mpileupNormal}" >> ${config}
    echo "mateOrientation = FR" >> ${config}
    echo "" >> ${config}

    echo "[sample]" >> ${config}
    echo "inputFormat = pileup" >> ${config}
    echo "mateFile = \${PWD}/${mpileupTumor}" >> ${config}
    echo "mateOrientation = FR" >> ${config}
    echo "" >> ${config}

    echo "[BAF]" >> ${config}
    echo "SNPfile = ${dbsnp.fileName}" >> ${config}

    freec -conf ${config}
    """
}

controlFreecOut.dump(tag:'ControlFREEC')

// STEP CONTROLFREEC.3 - VISUALIZATION

process ControlFreecViz {
    label 'memory_singleCPU_2_task'

    tag {idSampleTumor + "_vs_" + idSampleNormal}

    publishDir "${params.outdir}/VariantCalling/${idSampleTumor}_vs_${idSampleNormal}/controlFREEC", mode: params.publish_dir_mode

    input:
        set idPatient, idSampleNormal, idSampleTumor, file(cnvTumor), file(ratioTumor), file(cnvNormal), file(ratioNormal), file(bafTumor), file(bafNormal) from controlFreecViz

    output:
        set file("*.txt"), file("*.png"), file("*.bed") into controlFreecVizOut

    when: 'controlfreec' in tools

    """
    cat /opt/conda/envs/nf-core-sarek-${workflow.manifest.version}/bin/assess_significance.R | R --slave --args ${cnvTumor} ${ratioTumor}
    cat /opt/conda/envs/nf-core-sarek-${workflow.manifest.version}/bin/assess_significance.R | R --slave --args ${cnvNormal} ${ratioNormal}
    cat /opt/conda/envs/nf-core-sarek-${workflow.manifest.version}/bin/makeGraph.R | R --slave --args 2 ${ratioTumor} ${bafTumor}
    cat /opt/conda/envs/nf-core-sarek-${workflow.manifest.version}/bin/makeGraph.R | R --slave --args 2 ${ratioNormal} ${bafNormal}
    perl /opt/conda/envs/nf-core-sarek-${workflow.manifest.version}/bin/freec2bed.pl -f ${ratioTumor} > ${idSampleTumor}.bed
    perl /opt/conda/envs/nf-core-sarek-${workflow.manifest.version}/bin/freec2bed.pl -f ${ratioNormal} > ${idSampleNormal}.bed
    """
}

controlFreecVizOut.dump(tag:'ControlFreecViz')

// Remapping channels for QC and annotation

(vcfStrelkaIndels, vcfStrelkaSNVS) = vcfStrelka.into(2)
(vcfStrelkaBPIndels, vcfStrelkaBPSNVS) = vcfStrelkaBP.into(2)
(vcfMantaSomaticSV, vcfMantaDiploidSV) = vcfManta.into(2)

vcfKeep = Channel.empty().mix(
    vcfSentieon.map {
        variantcaller, idPatient, idSample, vcf, tbi ->
        [variantcaller, idSample, vcf]
    },
    vcfStrelkaSingle.map {
        variantcaller, idPatient, idSample, vcf, tbi ->
        [variantcaller, idSample, vcf[1]]
    },
    vcfMantaSingle.map {
        variantcaller, idPatient, idSample, vcf, tbi ->
        [variantcaller, idSample, vcf[2]]
    },
    vcfMantaDiploidSV.map {
        variantcaller, idPatient, idSample, vcf, tbi ->
        [variantcaller, idSample, vcf[2]]
    },
    vcfMantaSomaticSV.map {
        variantcaller, idPatient, idSample, vcf, tbi ->
        [variantcaller, idSample, vcf[3]]
    },
    vcfStrelkaIndels.map {
        variantcaller, idPatient, idSample, vcf, tbi ->
        [variantcaller, idSample, vcf[0]]
    },
    vcfStrelkaSNVS.map {
        variantcaller, idPatient, idSample, vcf, tbi ->
        [variantcaller, idSample, vcf[1]]
    },
    vcfStrelkaBPIndels.map {
        variantcaller, idPatient, idSample, vcf, tbi ->
        [variantcaller, idSample, vcf[0]]
    },
    vcfStrelkaBPSNVS.map {
        variantcaller, idPatient, idSample, vcf, tbi ->
        [variantcaller, idSample, vcf[1]]
    },
    vcfTIDDIT.map {
        variantcaller, idPatient, idSample, vcf, tbi ->
        [variantcaller, idSample, vcf]
    })

(vcfBCFtools, vcfVCFtools, vcfAnnotation) = vcfKeep.into(3)

// STEP VCF.QC

process BcftoolsStats {
    label 'cpus_1'

    tag {"${variantCaller} - ${vcf}"}

    publishDir "${params.outdir}/Reports/${idSample}/BCFToolsStats", mode: params.publish_dir_mode

    input:
        set variantCaller, idSample, file(vcf) from vcfBCFtools

    output:
        file ("*.bcf.tools.stats.out") into bcftoolsReport

    when: !('bcftools' in skipQC)

    script:
    """
    bcftools stats ${vcf} > ${reduceVCF(vcf.fileName)}.bcf.tools.stats.out
    """
}

bcftoolsReport = bcftoolsReport.dump(tag:'BCFTools')

process Vcftools {
    label 'cpus_1'

    tag {"${variantCaller} - ${vcf}"}

    publishDir "${params.outdir}/Reports/${idSample}/VCFTools", mode: params.publish_dir_mode

    input:
        set variantCaller, idSample, file(vcf) from vcfVCFtools

    output:
        file ("${reduceVCF(vcf.fileName)}.*") into vcftoolsReport

    when: !('vcftools' in skipQC)

    script:
    """
    vcftools \
    --gzvcf ${vcf} \
    --TsTv-by-count \
    --out ${reduceVCF(vcf.fileName)}

    vcftools \
    --gzvcf ${vcf} \
    --TsTv-by-qual \
    --out ${reduceVCF(vcf.fileName)}

    vcftools \
    --gzvcf ${vcf} \
    --FILTER-summary \
    --out ${reduceVCF(vcf.fileName)}
    """
}

vcftoolsReport = vcftoolsReport.dump(tag:'VCFTools')

/*
================================================================================
                                   ANNOTATION
================================================================================
*/

if (step == 'annotate') {
    vcfToAnnotate = Channel.create()
    vcfNoAnnotate = Channel.create()

    if (tsvPath == []) {
    // Sarek, by default, annotates all available vcfs that it can find in the VariantCalling directory
    // Excluding vcfs from FreeBayes, and g.vcf from HaplotypeCaller
    // Basically it's: results/VariantCalling/*/{HaplotypeCaller,Manta,Mutect2,SentieonDNAseq,SentieonDNAscope,SentieonTNscope,Strelka,TIDDIT}/*.vcf.gz
    // Without *SmallIndels.vcf.gz from Manta, and *.genome.vcf.gz from Strelka
    // The small snippet `vcf.minus(vcf.fileName)[-2]` catches idSample
    // This field is used to output final annotated VCFs in the correct directory
      Channel.empty().mix(
        Channel.fromPath("${params.outdir}/VariantCalling/*/HaplotypeCaller/*.vcf.gz")
          .flatten().map{vcf -> ['HaplotypeCaller', vcf.minus(vcf.fileName)[-2].toString(), vcf]},
        Channel.fromPath("${params.outdir}/VariantCalling/*/Manta/*[!candidate]SV.vcf.gz")
          .flatten().map{vcf -> ['Manta', vcf.minus(vcf.fileName)[-2].toString(), vcf]},
        Channel.fromPath("${params.outdir}/VariantCalling/*/Mutect2/*.vcf.gz")
          .flatten().map{vcf -> ['Mutect2', vcf.minus(vcf.fileName)[-2].toString(), vcf]},
        Channel.fromPath("${params.outdir}/VariantCalling/*/SentieonDNAseq/*.vcf.gz")
          .flatten().map{vcf -> ['SentieonDNAseq', vcf.minus(vcf.fileName)[-2].toString(), vcf]},
        Channel.fromPath("${params.outdir}/VariantCalling/*/SentieonDNAscope/*.vcf.gz")
          .flatten().map{vcf -> ['SentieonDNAscope', vcf.minus(vcf.fileName)[-2].toString(), vcf]},
        Channel.fromPath("${params.outdir}/VariantCalling/*/SentieonTNscope/*.vcf.gz")
          .flatten().map{vcf -> ['SentieonTNscope', vcf.minus(vcf.fileName)[-2].toString(), vcf]},
        Channel.fromPath("${params.outdir}/VariantCalling/*/Strelka/*{somatic,variant}*.vcf.gz")
          .flatten().map{vcf -> ['Strelka', vcf.minus(vcf.fileName)[-2].toString(), vcf]},
        Channel.fromPath("${params.outdir}/VariantCalling/*/TIDDIT/*.vcf.gz")
          .flatten().map{vcf -> ['TIDDIT', vcf.minus(vcf.fileName)[-2].toString(), vcf]}
      ).choice(vcfToAnnotate, vcfNoAnnotate) {
        annotateTools == [] || (annotateTools != [] && it[0] in annotateTools) ? 0 : 1
      }
    } else if (annotateTools == []) {
    // Annotate user-submitted VCFs
    // If user-submitted, Sarek assume that the idSample should be assumed automatically
      vcfToAnnotate = Channel.fromPath(tsvPath)
        .map{vcf -> ['userspecified', vcf.minus(vcf.fileName)[-2].toString(), vcf]}
    } else exit 1, "specify only tools or files to annotate, not both"

    vcfNoAnnotate.close()
    vcfAnnotation = vcfAnnotation.mix(vcfToAnnotate)
}

// as now have the list of VCFs to annotate, the first step is to annotate with allele frequencies, if there are any

(vcfSnpeff, vcfVep) = vcfAnnotation.into(2)

vcfVep = vcfVep.map {
  variantCaller, idSample, vcf ->
  [variantCaller, idSample, vcf, null]
}

// STEP SNPEFF

process Snpeff {
    tag {"${idSample} - ${variantCaller} - ${vcf}"}

    publishDir params.outdir, mode: params.publish_dir_mode, saveAs: {
        if (it == "${reducedVCF}_snpEff.ann.vcf") null
        else "Reports/${idSample}/snpEff/${it}"
    }

    input:
        set variantCaller, idSample, file(vcf) from vcfSnpeff
        file(dataDir) from ch_snpeff_cache
        val snpeffDb from ch_snpeff_db

    output:
        set file("${reducedVCF}_snpEff.genes.txt"), file("${reducedVCF}_snpEff.html"), file("${reducedVCF}_snpEff.csv") into snpeffReport
        set variantCaller, idSample, file("${reducedVCF}_snpEff.ann.vcf") into snpeffVCF

    when: 'snpeff' in tools || 'merge' in tools

    script:
    reducedVCF = reduceVCF(vcf.fileName)
    cache = (params.snpeff_cache && params.annotation_cache) ? "-dataDir \${PWD}/${dataDir}" : ""
    """
    snpEff -Xmx${task.memory.toGiga()}g \
        ${snpeffDb} \
        -csvStats ${reducedVCF}_snpEff.csv \
        -nodownload \
        ${cache} \
        -canon \
        -v \
        ${vcf} \
        > ${reducedVCF}_snpEff.ann.vcf

    mv snpEff_summary.html ${reducedVCF}_snpEff.html
    """
}

snpeffReport = snpeffReport.dump(tag:'snpEff report')

// STEP COMPRESS AND INDEX VCF.1 - SNPEFF

process CompressVCFsnpEff {
    tag {"${idSample} - ${vcf}"}

    publishDir "${params.outdir}/Annotation/${idSample}/snpEff", mode: params.publish_dir_mode

    input:
        set variantCaller, idSample, file(vcf) from snpeffVCF

    output:
        set variantCaller, idSample, file("*.vcf.gz"), file("*.vcf.gz.tbi") into (compressVCFsnpEffOut)

    script:
    """
    bgzip < ${vcf} > ${vcf}.gz
    tabix ${vcf}.gz
    """
}

compressVCFsnpEffOut = compressVCFsnpEffOut.dump(tag:'VCF')

// STEP VEP.1

process VEP {
    label 'VEP'
    label 'cpus_4'

    tag {"${idSample} - ${variantCaller} - ${vcf}"}

    publishDir params.outdir, mode: params.publish_dir_mode, saveAs: {
        if (it == "${reducedVCF}_VEP.summary.html") "Reports/${idSample}/VEP/${it}"
        else null
    }

    input:
        set variantCaller, idSample, file(vcf), file(idx) from vcfVep
        file(dataDir) from ch_vep_cache
        val cache_version from ch_vep_cache_version
        file(cadd_InDels) from ch_cadd_indels
        file(cadd_InDels_tbi) from ch_cadd_indels_tbi
        file(cadd_WG_SNVs) from ch_cadd_wg_snvs
        file(cadd_WG_SNVs_tbi) from ch_cadd_wg_snvs_tbi

    output:
        set variantCaller, idSample, file("${reducedVCF}_VEP.ann.vcf") into vepVCF
        file("${reducedVCF}_VEP.summary.html") into vepReport

    when: 'vep' in tools

    script:
    reducedVCF = reduceVCF(vcf.fileName)
    genome = params.genome == 'smallGRCh37' ? 'GRCh37' : params.genome

    dir_cache = (params.vep_cache && params.annotation_cache) ? " \${PWD}/${dataDir}" : "/.vep"
    cadd = (params.cadd_cache && params.cadd_wg_snvs && params.cadd_indels) ? "--plugin CADD,whole_genome_SNVs.tsv.gz,InDels.tsv.gz" : ""
    genesplicer = params.genesplicer ? "--plugin GeneSplicer,/opt/conda/envs/nf-core-sarek-${workflow.manifest.version}/bin/genesplicer,/opt/conda/envs/nf-core-sarek-${workflow.manifest.version}/share/genesplicer-1.0-1/human,context=200,tmpdir=\$PWD/${reducedVCF}" : "--offline"
    """
    mkdir ${reducedVCF}

    vep \
        -i ${vcf} \
        -o ${reducedVCF}_VEP.ann.vcf \
        --assembly ${genome} \
        --species ${params.species} \
        ${cadd} \
        ${genesplicer} \
        --cache \
        --cache_version ${cache_version} \
        --dir_cache ${dir_cache} \
        --everything \
        --filter_common \
        --fork ${task.cpus} \
        --format vcf \
        --per_gene \
        --stats_file ${reducedVCF}_VEP.summary.html \
        --total_length \
        --vcf

    rm -rf ${reducedVCF}
    """
}

vepReport = vepReport.dump(tag:'VEP')

// STEP VEP.2 - VEP AFTER SNPEFF

process VEPmerge {
    label 'VEP'
    label 'cpus_4'

    tag {"${idSample} - ${variantCaller} - ${vcf}"}

    publishDir params.outdir, mode: params.publish_dir_mode, saveAs: {
        if (it == "${reducedVCF}_VEP.summary.html") "Reports/${idSample}/VEP/${it}"
        else null
    }

    input:
        set variantCaller, idSample, file(vcf), file(idx) from compressVCFsnpEffOut
        file(dataDir) from ch_vep_cache
        val cache_version from ch_vep_cache_version
        file(cadd_InDels) from ch_cadd_indels
        file(cadd_InDels_tbi) from ch_cadd_indels_tbi
        file(cadd_WG_SNVs) from ch_cadd_wg_snvs
        file(cadd_WG_SNVs_tbi) from ch_cadd_wg_snvs_tbi

    output:
        set variantCaller, idSample, file("${reducedVCF}_VEP.ann.vcf") into vepVCFmerge
        file("${reducedVCF}_VEP.summary.html") into vepReportMerge

    when: 'merge' in tools

    script:
    reducedVCF = reduceVCF(vcf.fileName)
    genome = params.genome == 'smallGRCh37' ? 'GRCh37' : params.genome
    dir_cache = (params.vep_cache && params.annotation_cache) ? " \${PWD}/${dataDir}" : "/.vep"
    cadd = (params.cadd_cache && params.cadd_wg_snvs && params.cadd_indels) ? "--plugin CADD,whole_genome_SNVs.tsv.gz,InDels.tsv.gz" : ""
    genesplicer = params.genesplicer ? "--plugin GeneSplicer,/opt/conda/envs/nf-core-sarek-${workflow.manifest.version}/bin/genesplicer,/opt/conda/envs/nf-core-sarek-${workflow.manifest.version}/share/genesplicer-1.0-1/human,context=200,tmpdir=\$PWD/${reducedVCF}" : "--offline"
    """
    mkdir ${reducedVCF}

    vep \
        -i ${vcf} \
        -o ${reducedVCF}_VEP.ann.vcf \
        --assembly ${genome} \
        --species ${params.species} \
        ${cadd} \
        ${genesplicer} \
        --cache \
        --cache_version ${cache_version} \
        --dir_cache ${dir_cache} \
        --everything \
        --filter_common \
        --fork ${task.cpus} \
        --format vcf \
        --per_gene \
        --stats_file ${reducedVCF}_VEP.summary.html \
        --total_length \
        --vcf

    rm -rf ${reducedVCF}
    """
}

vepReportMerge = vepReportMerge.dump(tag:'VEP')

vcfCompressVCFvep = vepVCF.mix(vepVCFmerge)

// STEP COMPRESS AND INDEX VCF.2 - VEP

process CompressVCFvep {
    tag {"${idSample} - ${vcf}"}

    publishDir "${params.outdir}/Annotation/${idSample}/VEP", mode: params.publish_dir_mode

    input:
        set variantCaller, idSample, file(vcf) from vcfCompressVCFvep

    output:
        set variantCaller, idSample, file("*.vcf.gz"), file("*.vcf.gz.tbi") into compressVCFOutVEP

    script:
    """
    bgzip < ${vcf} > ${vcf}.gz
    tabix ${vcf}.gz
    """
}

compressVCFOutVEP = compressVCFOutVEP.dump(tag:'VCF')

/*
================================================================================
                                     MultiQC
================================================================================
*/

// STEP MULTIQC

process MultiQC {
    publishDir "${params.outdir}/Reports/MultiQC", mode: params.publish_dir_mode

    input:
        file (multiqcConfig) from ch_multiqc_config
        file (mqc_custom_config) from ch_multiqc_custom_config.collect().ifEmpty([])
        file (versions) from ch_software_versions_yaml.collect()
        file workflow_summary from ch_workflow_summary.collectFile(name: "workflow_summary_mqc.yaml")
        file ('bamQC/*') from bamQCReport.collect().ifEmpty([])
        file ('BCFToolsStats/*') from bcftoolsReport.collect().ifEmpty([])
        file ('FastQC/*') from fastQCReport.collect().ifEmpty([])
        file ('TrimmedFastQC/*') from trimGaloreReport.collect().ifEmpty([])
        file ('MarkDuplicates/*') from markDuplicatesReport.collect().ifEmpty([])
        file ('DuplicateMarked/*.recal.table') from baseRecalibratorReport.collect().ifEmpty([])
        file ('SamToolsStats/*') from samtoolsStatsReport.collect().ifEmpty([])
        file ('snpEff/*') from snpeffReport.collect().ifEmpty([])
        file ('VCFTools/*') from vcftoolsReport.collect().ifEmpty([])

    output:
        file "*multiqc_report.html" into ch_multiqc_report
        file "*_data"
        file "multiqc_plots"

    when: !('multiqc' in skipQC)

    script:
    rtitle = custom_runName ? "--title \"$custom_runName\"" : ''
    rfilename = custom_runName ? "--filename " + custom_runName.replaceAll('\\W','_').replaceAll('_+','_') + "_multiqc_report" : ''
    custom_config_file = params.multiqc_config ? "--config $mqc_custom_config" : ''
    """
    multiqc -f ${rtitle} ${rfilename} ${custom_config_file} .
    """
}

ch_multiqc_report.dump(tag:'MultiQC')

// Output Description HTML
process Output_documentation {
    publishDir "${params.outdir}/pipeline_info", mode: params.publish_dir_mode

    input:
        file output_docs from ch_output_docs

    output:
        file "results_description.html"

    when: !('documentation' in skipQC)

    script:
    """
    markdown_to_html.py $output_docs -o results_description.html
    """
}

// Completion e-mail notification
workflow.onComplete {

    // Set up the e-mail variables
    def subject = "[nf-core/sarek] Successful: $workflow.runName"
    if (!workflow.success) {
        subject = "[nf-core/sarek] FAILED: $workflow.runName"
    }
    def email_fields = [:]
    email_fields['version'] = workflow.manifest.version
    email_fields['runName'] = custom_runName ?: workflow.runName
    email_fields['success'] = workflow.success
    email_fields['dateComplete'] = workflow.complete
    email_fields['duration'] = workflow.duration
    email_fields['exitStatus'] = workflow.exitStatus
    email_fields['errorMessage'] = (workflow.errorMessage ?: 'None')
    email_fields['errorReport'] = (workflow.errorReport ?: 'None')
    email_fields['commandLine'] = workflow.commandLine
    email_fields['projectDir'] = workflow.projectDir
    email_fields['summary'] = summary
    email_fields['summary']['Date Started'] = workflow.start
    email_fields['summary']['Date Completed'] = workflow.complete
    email_fields['summary']['Pipeline script file path'] = workflow.scriptFile
    email_fields['summary']['Pipeline script hash ID'] = workflow.scriptId
    if (workflow.repository) email_fields['summary']['Pipeline repository Git URL'] = workflow.repository
    if (workflow.commitId) email_fields['summary']['Pipeline repository Git Commit'] = workflow.commitId
    if (workflow.revision) email_fields['summary']['Pipeline Git branch/tag'] = workflow.revision
    email_fields['summary']['Nextflow Version'] = workflow.nextflow.version
    email_fields['summary']['Nextflow Build'] = workflow.nextflow.build
    email_fields['summary']['Nextflow Compile Timestamp'] = workflow.nextflow.timestamp

    def mqc_report = null
    try {
        if (workflow.success) {
            mqc_report = ch_multiqc_report.getVal()
            if (mqc_report.getClass() == ArrayList) {
                log.warn "[nf-core/sarek] Found multiple reports from process 'multiqc', will use only one"
                mqc_report = mqc_report[0]
            }
        }
    } catch (all) {
        log.warn "[nf-core/sarek] Could not attach MultiQC report to summary email"
    }

    // Check if we are only sending emails on failure
    email_address = params.email
    if (!params.email && params.email_on_fail && !workflow.success) {
        email_address = params.email_on_fail
    }

    // Render the TXT template
    def engine = new groovy.text.GStringTemplateEngine()
    def tf = new File("$baseDir/assets/email_template.txt")
    def txt_template = engine.createTemplate(tf).make(email_fields)
    def email_txt = txt_template.toString()

    // Render the HTML template
    def hf = new File("$baseDir/assets/email_template.html")
    def html_template = engine.createTemplate(hf).make(email_fields)
    def email_html = html_template.toString()

    // Render the sendmail template
    def smail_fields = [ email: email_address, subject: subject, email_txt: email_txt, email_html: email_html, baseDir: "$baseDir", mqcFile: mqc_report, mqcMaxSize: params.max_multiqc_email_size.toBytes() ]
    def sf = new File("$baseDir/assets/sendmail_template.txt")
    def sendmail_template = engine.createTemplate(sf).make(smail_fields)
    def sendmail_html = sendmail_template.toString()

    // Send the HTML e-mail
    if (email_address) {
        try {
            if (params.plaintext_email) { throw GroovyException('Send plaintext e-mail, not HTML') }
            // Try to send HTML e-mail using sendmail
            [ 'sendmail', '-t' ].execute() << sendmail_html
            log.info "[nf-core/sarek] Sent summary e-mail to $email_address (sendmail)"
        } catch (all) {
            // Catch failures and try with plaintext
            [ 'mail', '-s', subject, email_address ].execute() << email_txt
            log.info "[nf-core/sarek] Sent summary e-mail to $email_address (mail)"
        }
    }

    // Write summary e-mail HTML to a file
    def output_d = new File("${params.outdir}/pipeline_info/")
    if (!output_d.exists()) {
        output_d.mkdirs()
    }
    def output_hf = new File(output_d, "pipeline_report.html")
    output_hf.withWriter { w -> w << email_html }
    def output_tf = new File(output_d, "pipeline_report.txt")
    output_tf.withWriter { w -> w << email_txt }

    c_green  = params.monochrome_logs ? '' : "\033[0;32m";
    c_purple = params.monochrome_logs ? '' : "\033[0;35m";
    c_red    = params.monochrome_logs ? '' : "\033[0;31m";
    c_reset  = params.monochrome_logs ? '' : "\033[0m";

    if (workflow.stats.ignoredCount > 0 && workflow.success) {
        log.info "-${c_purple}Warning, pipeline completed, but with errored process(es) ${c_reset}-"
        log.info "-${c_red}Number of ignored errored process(es) : ${workflow.stats.ignoredCount} ${c_reset}-"
        log.info "-${c_green}Number of successfully ran process(es) : ${workflow.stats.succeedCount} ${c_reset}-"
    }

    if (workflow.success) {
        log.info "-${c_purple}[nf-core/sarek]${c_green} Pipeline completed successfully${c_reset}-"
    } else {
        checkHostname()
        log.info "-${c_purple}[nf-core/sarek]${c_red} Pipeline completed with errors${c_reset}-"
    }
}

/*
================================================================================
                                nf-core functions
================================================================================
*/

def create_workflow_summary(summary) {
    def yaml_file = workDir.resolve('workflow_summary_mqc.yaml')
    yaml_file.text  = """
    id: 'nf-core-sarek-summary'
    description: " - this information is collected when the pipeline is started."
    section_name: 'nf-core/sarek Workflow Summary'
    section_href: 'https://github.com/nf-core/sarek'
    plot_type: 'html'
    data: |
        <dl class=\"dl-horizontal\">
${summary.collect { k, v -> "            <dt>$k</dt><dd><samp>${v ?: '<span style=\"color:#999999;\">N/A</a>'}</samp></dd>" }.join("\n")}
        </dl>
    """.stripIndent()

   return yaml_file
}

def nfcoreHeader() {
    // Log colors ANSI codes
    c_black  = params.monochrome_logs ? '' : "\033[0;30m";
    c_blue   = params.monochrome_logs ? '' : "\033[0;34m";
    c_dim    = params.monochrome_logs ? '' : "\033[2m";
    c_green  = params.monochrome_logs ? '' : "\033[0;32m";
    c_purple = params.monochrome_logs ? '' : "\033[0;35m";
    c_reset  = params.monochrome_logs ? '' : "\033[0m";
    c_white  = params.monochrome_logs ? '' : "\033[0;37m";
    c_yellow = params.monochrome_logs ? '' : "\033[0;33m";

    return """    -${c_dim}--------------------------------------------------${c_reset}-
                                            ${c_green},--.${c_black}/${c_green},-.${c_reset}
    ${c_blue}        ___     __   __   __   ___     ${c_green}/,-._.--~\'${c_reset}
    ${c_blue}  |\\ | |__  __ /  ` /  \\ |__) |__         ${c_yellow}}  {${c_reset}
    ${c_blue}  | \\| |       \\__, \\__/ |  \\ |___     ${c_green}\\`-._,-`-,${c_reset}
                                            ${c_green}`._,._,\'${c_reset}
        ${c_white}____${c_reset}
      ${c_white}.´ _  `.${c_reset}
     ${c_white}/  ${c_green}|\\${c_reset}`-_ \\${c_reset}     ${c_blue} __        __   ___     ${c_reset}
    ${c_white}|   ${c_green}| \\${c_reset}  `-|${c_reset}    ${c_blue}|__`  /\\  |__) |__  |__/${c_reset}
     ${c_white}\\ ${c_green}|   \\${c_reset}  /${c_reset}     ${c_blue}.__| /¯¯\\ |  \\ |___ |  \\${c_reset}
      ${c_white}`${c_green}|${c_reset}____${c_green}\\${c_reset}´${c_reset}

    ${c_purple}  nf-core/sarek v${workflow.manifest.version}${c_reset}
    -${c_dim}--------------------------------------------------${c_reset}-
    """.stripIndent()
}

def checkHostname() {
    def c_reset       = params.monochrome_logs ? '' : "\033[0m"
    def c_white       = params.monochrome_logs ? '' : "\033[0;37m"
    def c_red         = params.monochrome_logs ? '' : "\033[1;91m"
    def c_yellow_bold = params.monochrome_logs ? '' : "\033[1;93m"
    if (params.hostnames) {
        def hostname = "hostname".execute().text.trim()
        params.hostnames.each { prof, hnames ->
            hnames.each { hname ->
                if (hostname.contains(hname) && !workflow.profile.contains(prof)) {
                    log.error "====================================================\n" +
                            "  ${c_red}WARNING!${c_reset} You are running with `-profile $workflow.profile`\n" +
                            "  but your machine hostname is ${c_white}'$hostname'${c_reset}\n" +
                            "  ${c_yellow_bold}It's highly recommended that you use `-profile $prof${c_reset}`\n" +
                            "============================================================"
                }
            }
        }
    }
}

/*
================================================================================
                                 sarek functions
================================================================================
*/

// Check if a row has the expected number of item
def checkNumberOfItem(row, number) {
    if (row.size() != number) exit 1, "Malformed row in TSV file: ${row}, see --help for more information"
    return true
}

// Check parameter existence
def checkParameterExistence(it, list) {
    if (!list.contains(it)) {
        log.warn "Unknown parameter: ${it}"
        return false
    }
    return true
}

// Compare each parameter with a list of parameters
def checkParameterList(list, realList) {
    return list.every{ checkParameterExistence(it, realList) }
}

// Define list of available tools to annotate
def defineAnnoList() {
    return [
        'HaplotypeCaller',
        'Manta',
        'Mutect2',
        'Strelka',
        'TIDDIT'
    ]
}

// Define list of skipable QC tools
def defineSkipQClist() {
    return [
        'bamqc',
        'baserecalibrator',
        'bcftools',
        'documentation',
        'fastqc',
        'markduplicates',
        'multiqc',
        'samtools',
        'sentieon',
        'vcftools',
        'versions'
    ]
}

// Define list of available step
def defineStepList() {
    return [
        'annotate',
        'mapping',
        'recalibrate',
        'variantcalling'
    ]
}

// Define list of available tools
def defineToolList() {
    return [
        'ascat',
        'controlfreec',
        'dnascope',
        'dnaseq',
        'freebayes',
        'haplotypecaller',
        'manta',
        'merge',
        'mpileup',
        'mutect2',
        'snpeff',
        'strelka',
        'tiddit',
        'tnscope',
        'vep'
    ]
}

// Channeling the TSV file containing BAM.
// Format is: "subject gender status sample bam bai"
def extractBam(tsvFile) {
    Channel.from(tsvFile)
        .splitCsv(sep: '\t')
        .map { row ->
            checkNumberOfItem(row, 6)
            def idPatient = row[0]
            def gender    = row[1]
            def status    = returnStatus(row[2].toInteger())
            def idSample  = row[3]
            def bamFile   = returnFile(row[4])
            def baiFile   = returnFile(row[5])

            if (!hasExtension(bamFile, "bam")) exit 1, "File: ${bamFile} has the wrong extension. See --help for more information"
            if (!hasExtension(baiFile, "bai")) exit 1, "File: ${baiFile} has the wrong extension. See --help for more information"

            return [idPatient, gender, status, idSample, bamFile, baiFile]
        }
}

// Create a channel of germline FASTQs from a directory pattern: "my_samples/*/"
// All FASTQ files in subdirectories are collected and emitted;
// they must have _R1_ and _R2_ in their names.
def extractFastqFromDir(pattern) {
    def fastq = Channel.create()
    // a temporary channel does all the work
    Channel
        .fromPath(pattern, type: 'dir')
        .ifEmpty { error "No directories found matching pattern '${pattern}'" }
        .subscribe onNext: { sampleDir ->
            // the last name of the sampleDir is assumed to be a unique sample id
            sampleId = sampleDir.getFileName().toString()

            for (path1 in file("${sampleDir}/**_R1_*.fastq.gz")) {
                assert path1.getName().contains('_R1_')
                path2 = file(path1.toString().replace('_R1_', '_R2_'))
                if (!path2.exists()) error "Path '${path2}' not found"
                (flowcell, lane) = flowcellLaneFromFastq(path1)
                patient = sampleId
                gender = 'ZZ'  // unused
                status = 0  // normal (not tumor)
                rgId = "${flowcell}.${sampleId}.${lane}"
                result = [patient, gender, status, sampleId, rgId, path1, path2]
                fastq.bind(result)
            }
    }, onComplete: { fastq.close() }
    fastq
}

// Extract gender and status from Channel
def extractInfos(channel) {
    def genderMap = [:]
    def statusMap = [:]
    channel = channel.map{ it ->
        def idPatient = it[0]
        def gender = it[1]
        def status = it[2]
        def idSample = it[3]
        genderMap[idPatient] = gender
        statusMap[idPatient, idSample] = status
        [idPatient] + it[3..-1]
    }
    [genderMap, statusMap, channel]
}

// Channeling the TSV file containing FASTQ or BAM
// Format is: "subject gender status sample lane fastq1 fastq2"
// or: "subject gender status sample lane bam"
def extractFastq(tsvFile) {
    Channel.from(tsvFile)
        .splitCsv(sep: '\t')
        .map { row ->
            def idPatient  = row[0]
            def gender     = row[1]
            def status     = returnStatus(row[2].toInteger())
            def idSample   = row[3]
            def idRun      = row[4]
            def file1      = returnFile(row[5])
            def file2      = "null"
            if (hasExtension(file1, "fastq.gz") || hasExtension(file1, "fq.gz") || hasExtension(file1, "fastq") || hasExtension(file1, "fq")) {
                checkNumberOfItem(row, 7)
                file2 = returnFile(row[6])
            if (!hasExtension(file2, "fastq.gz") && !hasExtension(file2, "fq.gz")  && !hasExtension(file2, "fastq") && !hasExtension(file2, "fq")) exit 1, "File: ${file2} has the wrong extension. See --help for more information"
            if (hasExtension(file1, "fastq") || hasExtension(file1, "fq") || hasExtension(file2, "fastq") || hasExtension(file2, "fq")) {
                exit 1, "We do recommend to use gziped fastq file to help you reduce your data footprint."
            }
        }
        else if (hasExtension(file1, "bam")) checkNumberOfItem(row, 6)
        else "No recognisable extention for input file: ${file1}"

        [idPatient, gender, status, idSample, idRun, file1, file2]
    }
}

// Channeling the TSV file containing Recalibration Tables.
// Format is: "subject gender status sample bam bai recalTables"
def extractRecal(tsvFile) {
    Channel.from(tsvFile)
        .splitCsv(sep: '\t')
        .map { row ->
            checkNumberOfItem(row, 7)
            def idPatient  = row[0]
            def gender     = row[1]
            def status     = returnStatus(row[2].toInteger())
            def idSample   = row[3]
            def bamFile    = returnFile(row[4])
            def baiFile    = returnFile(row[5])
            def recalTable = returnFile(row[6])

            if (!hasExtension(bamFile, "bam")) exit 1, "File: ${bamFile} has the wrong extension. See --help for more information"
            if (!hasExtension(baiFile, "bai")) exit 1, "File: ${baiFile} has the wrong extension. See --help for more information"
            if (!hasExtension(recalTable, "recal.table")) exit 1, "File: ${recalTable} has the wrong extension. See --help for more information"

            [idPatient, gender, status, idSample, bamFile, baiFile, recalTable]
    }
}

// Parse first line of a FASTQ file, return the flowcell id and lane number.
def flowcellLaneFromFastq(path) {
    // expected format:
    // xx:yy:FLOWCELLID:LANE:... (seven fields)
    // or
    // FLOWCELLID:LANE:xx:... (five fields)
    InputStream fileStream = new FileInputStream(path.toFile())
    InputStream gzipStream = new java.util.zip.GZIPInputStream(fileStream)
    Reader decoder = new InputStreamReader(gzipStream, 'ASCII')
    BufferedReader buffered = new BufferedReader(decoder)
    def line = buffered.readLine()
    assert line.startsWith('@')
    line = line.substring(1)
    def fields = line.split(' ')[0].split(':')
    String fcid
    int lane
    if (fields.size() == 7) {
        // CASAVA 1.8+ format
        fcid = fields[2]
        lane = fields[3].toInteger()
    } else if (fields.size() == 5) {
        fcid = fields[0]
        lane = fields[1].toInteger()
    }
    [fcid, lane]
}

// Check file extension
def hasExtension(it, extension) {
    it.toString().toLowerCase().endsWith(extension.toLowerCase())
}

// Return file if it exists
def returnFile(it) {
    if (!file(it).exists()) exit 1, "Missing file in TSV file: ${it}, see --help for more information"
    return file(it)
}

// Remove .ann .gz and .vcf extension from a VCF file
def reduceVCF(file) {
    return file.fileName.toString().minus(".ann").minus(".vcf").minus(".gz")
}

// Return status [0,1]
// 0 == Normal, 1 == Tumor
def returnStatus(it) {
    if (!(it in [0, 1])) exit 1, "Status is not recognized in TSV file: ${it}, see --help for more information"
    return it
}