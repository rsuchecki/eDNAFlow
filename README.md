# eDNAFlow
## About the workflow
eDNAFlow is a fully automated pipeline that employs a number of state-of-the-art applications to process eDNA data from raw sequences (single-end or paired-end) to generation of curated and non-curated zero-radius operational taxonomic units (ZOTUs) and their abundance tables. As part of eDNAFlow, we also present an in-house Python script to assign taxonomy to ZOTUs based on user specified thresholds for assigning Lowest Common Ancestor (LCA). This pipeline is based on Nextflow and Singularity which enables a scalable, portable and reproducible workflow using software containers on a local computer, clouds and high-performance computing (HPC) clusters.

For more information on eDNAFlow and other software used as part of the workflow please read "eDNAFlow, an automated, reproducible and scalable workflow for analysis of environmental DNA (eDNA) sequences exploiting Nextflow and Singularity" in Molecular Ecology Resources with DOI: https://doi.org/10.1111/1755-0998.13356. If you use eDNAFlow, we appreciate if you could cite the eDNAFlow paper and the other papers describing the underlying software.

![alt text](https://github.com/mahsa-mousavi/eDNAFlow/blob/master/images/eDNAFlow.jpg)

## Setup and test the pipeline
To run the pipeline, first Nextflow and Singularity have to be installed or made available for loading as modules (e.g. in the case of running it on an HPC cluster) on your system. This pipeline was built and tested with versions 19.10 and 3.5.2 of Nextflow and Singularity, respectively. We strongly suggest that you first try the pipeline on your local machine using the test dataset provided. 

We are providing scripts that will install Nextflow and Singularity on your local machine if they don't already exist and will run the pipeline on the test dataset. The scripts have been successfully tested on Ubuntu 16, 18 and 20. 

Alternatively, for manual installation of Nextflow, follow the instructions at [nextflow installation](https://www.nextflow.io/docs/latest/getstarted.html). To install Singularity version 3.5.2 manually, follow the instructions at [singularity installation](https://sylabs.io/guides/3.5/admin-guide/installation.html). If working on HPC, you may need to contact your HPC helpdesk.  

**Follow the steps below:**

1- Clone the Git repository so that all the scripts and test data are downloaded and in one folder. To clone the repository to your directory, run this command: 

`git clone https://github.com/mahsa-mousavi/eDNAFlow.git` 

2- Next, in your terminal go to the "install" directory which is located inside the "eDNAFlow" directory (e.g. `cd eDNAFlow/install`) 

3- Once inside the install directory run: `bash install_and_se_testRun.sh` to try the pipeline on single-end test data or run `bash install_and_pe_testRun.sh` for testing it on paired-end test data. To test the lca script for taxonomy assignment run `bash install_and_lca_testRun.sh`. As every step gets completed you will see a ✔ next to the relavant step or ✘ if it fails.        

4- If all goes well you can now find all the results inside folder "testData2_Play"  

**What should you expect in result folders:**

In folders 00 to 09 you will find soft link(s) to the final result files of each step as explained below. To check any intermediate files or debug any particular step check the relevant folder inside work directory (check out the files starting with .command* for debugging, check the log, etc if necessary). 

`00_fastQC_YourSequenceFileName`: Quality checking results of raw file (FastQC package)

`01_a_quality_Filtering_YourSequenceFileName`: The filtered fastq file (adapterRemoval package) 

`01_b_fastQC_YourSequenceFileName`: Quality checking results of filtered file (FastQC package)

`02_assigned_dmux_YourSequenceFileName_yourBarcodeFileNames`: Demultiplexed file for each barcode file (OBITools package)

`03_Length_filtered_YourSequenceFileName`: Length filtered demultiplexed file (OBITools package)

`04_splitSamples_YourSequenceFileName`: Split files per sample (OBITools package)

`05_relabel_Cat_YourSequenceFileName`: Count of filtered demultiplexed reads in each sample (i.e. CountOfSeq.txt), each demultiplexed sample file, concatenated fastq and fasta files

`06_Uniques_ZOTUs_YourSequenceFileName`: Unique file, Final ZOTU fasta file and Final ZOTU table (this table is uncurated) (USEARCH package)

`07_blast_YourSequenceFileName`: Blast result, match file and table for generating curated result (BLAST package)  

`08_lulu_YourSequenceFileName`: LULU results including map file and curated ZOTU table (LULU package)

`09_taxonomyAssigned_lca_result_qCov#_id#_diff#`: Intermediate and final taxonomy assignment result files

`work`: Holds all the results, intermediate files, ...  

`.nextflow`: Nextflow generated folder holding history info 

`.nextflow.log`: Nextflow generated log file(s) which can be used for debugging and checking what each number in *work directory* maps to    

## Running eDNAFlow on your data
Make sure eDNAFlow scripts (including eDNAFlow.nf, nextflow.config and lulu.R), conf and LCA_taxonomyAssignment_scripts folders are in the same directory where your unzipped sequencing and Multiplex identifier (MID) tag (here defined as “barcode”) files exist. 

## Download database
One of the mandatory parameters to run eDNAFlow is to provide a path to a local GenBank nucleotide (nt) and/or your custom database. To download the NCBI nucleotide database locally, follow the steps below.

1) Download the official [BLAST+ container](https://github.com/ncbi/blast_plus_docs#show-blast-databases-available-for-download-from-ncbi) with Singularity using the below command (tested on Ubuntu 18.04):

`singularity pull --dir  directoryName docker://ncbi/blast:2.10.0`

**directoryName** is the path to the directory where you want to keep the container image

2) Make a folder where you want to keep the database and from there run the following command: 

`singularity run directoryName/blast_2.10.0.sif update_blastdb.pl --decompress nt`

\* Please be aware step 2 will take some time and will need a large space available on the disk due to the size of GenBank nucleotide database. For us it took under 2 hours on the NCBI default 1 core setting (~10MB per second), and was done a lot faster using an HPC data transfer node (hpc-data.pawsey.org.au) or copyq (with 16 cores) on Zeus, at almost 100MB per second.


## Basic command usage

Example of basic command to run the pipeline on your local machine on single-end/paired-end data with multiple barcode files using blast and/or custom database:

For single-end run:
`nextflow run eDNAFlow.nf --reads 'file.fastq' --barcode 'bc_*.txt' --blast_db 'path2/LocalGenbankDatabase/nt' [OPTIONS]` 

For paired-end run:
`nextflow run eDNAFlow.nf --barcode 'pe_bc*'  --blast_db 'Path2TestBlastDataset/file.fasta' --custom_db 'path2/customDatabase/myDb' [OPTIONS]` 

For running LCA taxonomy assignment script:
`nextflow run eDNAFlow.nf --taxonomyAssignment --zotuTable "path2/curatedOruncurated_ZotuTable_file" --blastFile "path2/blastResult_file" --lca_output "my_lca_result" [OPTIONS]`

## Description of run options
eDNAFlow allows execution of all or parts of the pipeline as long as the correct file formats are provided. For example, the user may choose to run eDNAFlow on a raw file that hasn't been demultiplexed, or opt to provide an already demultiplexed file. Similarly, a user may have performed the clustering with a different algorithm (e.g. DADA2) and is only interested in using the lca script.   

The following parameters can be adjusted on the command line to achieve different goals.

To see a list of available options run:
`nextflow run eDNAFlow.nf --help`

### Mandatory parameters if your sequences are NOT demultiplexed

`--reads 'read.fastq'`: provide the name of your raw fastq file; **You should NOT specify this option if reads are paired-end as they get identified automatically by default, BUT you need to make sure your paired-end file name ends with _R1.fastq & _R2.fastq**; reads must be unzipped

`--barcode 'bc.tab'`: your barcode file name; barcode file format must match [OBITools requirement](https://pythonhosted.org/OBITools/scripts/ngsfilter.html); if multiple barcode files exist (e.g. bc_1.txt; bc_2.txt) it can be specified like this: bc*.txt

* At least one of the below databases must be specified. 

`--blast_db 'absolutePath2/LocalGenbankDatabase/nt'`: the absolute path to where nt databse is stored 

`--custom_db 'absolutePath2/customDatabase/myDb'`: the absolute path to where custom database is stored

### Mandatory parameters if your sequences are demultiplexed

`--skipDemux`: It's a boolean 

`--demuxedInput 'demuxedFile.fasta'`: provide name of the fasta file holding all the demultiplexed sequences. Format of the sample identifier must match [USEARCH requirements](https://www.drive5.com/usearch/manual/upp_labels_sample.html). 

* At least one of the below databases must be specifieThe
`--blast_db 'absolutePath2/LocalGenbankDatabase/nt'`: the absolute path to where nt databse is stored 

`--custom_db 'absolutePath2/customDatabase/myDb'`: the absolute path to where custom database is stored

### Mandatory & optional parameters for running LCA taxonomy assignment script

For description of LCA script and required file formats see section below: LCA (Lowest Common Ancestor) script for assigning taxonomy

***Mandatory***

`--taxonomyAssignment`: It's a boolean

`--zotuTable "curatedOruncurated_ZotuTable_file"`: Provide the curated or uncurated ZOTU, OTU or ASV table file name; 

`--blastFile "blastResult_file"`: Provide the blast result file name;

***Optional***

`--lca_qcov "percent"`: percent of query coverage; Default is 100

`--lca_pid "percent`: percent of identity; Default is 97

`--lca_diff "float"`: The difference (Diff) between % identities of two hits when their qCov is equal; e.g. --lca_diff '0.5'; Default is 1

`--lca_output "string"`: Output file name; 


### Skipping and/or isolating steps

`--onlyDemux`: It's a boolean. If you only want to demultiplex your raw file.

`--skipDemux`: If set to true, then you will  need to also specify `--demuxedInput "file.fasta"` option

`--skipFastqc`: It will skip quality checking of both raw and filtered files

### Parameters to run eDNAFlow on Cloud/HPC

`-profile option`: Currently can choose between "nimbus" (can be used if user has access to more memory i.e. cloud or HPC) and "zeus" (it's specific to users who have access to ZEUS - a high-throughput HPC cluster at the Pawsey Supercomputing Centre). e.g. -profile nimbus

`--bindDir "path2/directoryToBind"`: If you run eDNAFlow on Cloud or HPC, you will need to specify this option, so singularity can bind a directory on the host system. On HPC, it usually will be /scratch or /group. On Cloud, it could be your mounted volume. e.g. --bindDir "/scratch"  

### Genearal Optional parameters

`--help`: Show help message

`--publish_dir_mode "symlink"`: Choose between symlink (Default), copy, link; see [Nextflow documentation](https://www.nextflow.io/docs/latest/process.html) on "Table of publish modes" to understand these options


`--singularityDir "path2/folderHoldingSingularityImages"`: If you are planning to run eDNAFlow regularly, we suggest you create a folder to hold singularity images, and then specify the path leading to this folder whenever you run eDNAFlow (e.g. --singularityDir "/home/user/Desktop/singularity_image_storage"). The first time you run eDNAFlow it will automatically download all the neccessary container images and will put them in that specified folder. Therefore, next time you run it, it runs faster as it doesn't need to pull those images again, provided you give it the same option --singularityDir as used before. If this option is not set, then those images can be found inside directory work/singularity.  

##### Quality filtering & demultiplexing

`--minQuality '20'`: the minimum Phred quality score to apply for quality control of raw sequences; Default is 20; must be an integer 

`--minAlignLeng '12'`: the minimum alignment length for merging read1 and read2 in case of paired-end sequences; Default is 12; must be an integer

`--minLen '50'`: the minimum length allowed for sequences; Default is 50; must be an integer

`--primer_mismatch '2'`: number of mismatches allowed for matching primers; Default is 2; Note that NO mismatches are allowed for matching tags at anytime.

##### Threshold for forming ZOTUs
`--minsize '8'`: the minimum abundance; input sequences with lower abundances are removed; Default is 8; to check how adjusting this option affects the results check out [Usearch documentation](https://drive5.com/usearch/manual/cmd_unoise3.html)

##### Setting blast parameters

`--maxTarSeq '10'`: a blast parameter; the maximum number of target sequences for hits per query to be returned by Blast; Default is 10

`--perc_identity '95'`: a blast parameter; percentage of identical matches; Default is 95

`--evalue '1e-3'`: a blast parameter; expected value for saving blast hits; Default is 1e-3

`--qcov '100'`: a blast parameter; the percent of the query that has to form an alignment against the reference to be retained; Higher values prevent alignments of only a short portion of the query to a reference; Default is 100

##### LULU

`--lulu 'lulu.R'`: an R script to run post-clustering curation with default settings of LULU; this file has been provided and must be present in the same directory as other scripts; by default eDNAFlow will be looking for this file

##### Choice of USEARCH32 vs USEARCH64

`--mode 'usearch32'`: by default eDNAFlow uses the free version of usearch (i.e. usearch 32 bit version); if you have access to 64bit version it can be set via changing mode as `--mode 'usearch64'`

`--usearch64 'Path2/Usearch64/executable'`: if mode is set to usearch64, then this option has to be specified; the full path must point to usearch64 executable 

## LCA (Lowest Common Ancestor) script for assigning taxonomy

The filtering applied in this script is based on a set of user specified thresholds, including query coverage (qCov), percentage identity (% identity) and the difference (Diff) between % identities of two hits when their qCov is equal. Setting qCov and % identity thresholds ensures that only BLAST hits >= to those thresholds will progress to the Diff comparison step. Setting Diff means that if the absolute value for the difference between % identity of hit1 and hit2 is > Diff, then a species level taxonomy will be returned, otherwise taxonomy of that ZOTU will be dropped to the lowest common ancestor. This script produces two files, a file in which the taxonomy is assigned (the final result), and an intermediate file which will give the user an idea of why some ZOTUs may have been assigned to the lowest common ancestor

**NOTE 1:**

This script is not limited to eDNAFlow created files. It can be used for assigning taxonomy of any OTU, ZOTU, and or ASV files, as long as: 

1. User provide a tab-delimited blast result file for their OTU or ASV, where blastn is performed using the following format:

-outfmt "6 qseqid sseqid staxids sscinames scomnames sskingdoms pident length qlen slen mismatch gapopen gaps qstart qend sstart send stitle evalue bitscore qcovs qcovhsp"

***If you have used eDNAFlow to generate your files, then the above has already been taken care of.***

2. The OTU or ASV table files are in tab-delimited format and the first line starts with #ID. To see examples, in folder testData2_Play check the files with extension _2test_LCAscript.tab 


**NOTE 2:**

If you want to use the curated ZOTU table, first you need to make some changes in that file: 

1) Remove all occurrence of ײ in the curated file. 
2) In the first line add #ID followed by a tab.

**NOTE 3:**

eDNAFlow allows you to specify your custom database for blast, but LCA script may not be able to parse and assign taxonomy of the custom results depending on how you built your custom database. This is because the LCA script needs taxonomy ID information (i.e. "staxids" which is the 3rd column in blast result file) to link the blast result with GenBank taxonomy. This ID will be pulled automatically when blasting against the Genbank database. However, for custom databases, if when you built it, you did not map the sequence identifiers to taxids, then it will not be available after blast and as a result LCA script will not be able to generate results for this.

We suggest you check blast manual on how to make custom database. A nice example on making custom database can be found [here](https://www.ncbi.nlm.nih.gov/books/NBK279688/), but note that this example is based on protein.

**Extra NOTE:**

Provided you have wget* installed on your system the script starts downloading the taxonomy dump file from NCBI and will put it in a folder with the date of that day. 
 
*Mac users can easily install wget following instruction [here](https://www.cyberciti.biz/faq/howto-install-wget-om-mac-os-x-mountain-lion-mavericks-snow-leopard/)
