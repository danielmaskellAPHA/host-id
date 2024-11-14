# host-id
a tool to attempt host prediction (analogous to barcoding) using NGS data

# NOTE: AS OF 2024 THIS IS INCREDIBLY DIFFICULT TO SETUP DUE TO REQUIRING A SPECIFIC VERSION OF CONDA TO INSTALL CERTAIN DEPENDENCIES, I RECOMMEND NOT TRYING. SORRY :-(


> created 10/07/23 by Dan Maskell (daniel.maskell@APHA.gov.uk) as part of the GAP-DC-II Project. This tool uses getorganelle (https://github.com/Kinggerm/GetOrganelle) to quickly extract any host mitogenomes located in WGS reads. MitoZ (https://github.com/linzhi2013/MitoZ) is then used to annotate and visualise the produced mitogenome. getOrganelle is faster, easier to use, and more memory efficient than mitoZ - but lacks annotation/visualisation tools. Should getOrganelle incorporate such features, this tool would become defunct.

If this tool is used to produce data that would be published, please cite **BOTH** getOrganelle, MitoZ, and their dependencies.

# INSTALLATION # 

## getOrganelle
`conda install -c bioconda getorganelle`
`get_organelle_config.py --add animal_mt`

this installs getorganelle through conda and then creates the animal mitogenome seed required for use

## mitoZ
mamba works much faster for installation than conda and is recommended for installing mitoZ (regular conda can be used upon install)

`conda install mamba -n base -c conda-forge` 
`mamba create -n mitozEnv -c bioconda -c conda-forge mitoz=3.6`

this has created a conda env called mitozEnv, please test it out before running the script

`conda activate mitozEnv`

## Python
you need both the latest version of python, and biopython to run this script.


# USAGE #
This tool should be run in the **base** conda environment. It *will not work* if you run it through mitozEnv (it will activate that itself when it needs to).
This tool is run using the main.sh script. It can be run for single read sets (-1 <r1.fastq.gz> -2 <r2.fastq.gz>) or for an entire directory of reads (-b <dir/containing/reads>).

1. The script calls getOrganelle with some default settings - I may allow one to change these settings in future. Generally, this only needs to be done if the default settings do not produce a satisfiable result.
2. The script calls a custom python script to format headers (mitoZ has some very rigid restrictions, resulting from makeblastdb's bizarre header restrictions)
3. The script calls mitoZ to finalise the output.

The information you want will usually be found in samplename_mitogenome/mitoz.animal.....etc.....etc.../ of note are summary.txt, [.....].cds.fasta (contains CDS for getting COX1 or other genes), circos.png (cool visual output).

As with all bioinformatics tools, the success of this tool is highly dependent on the quality of the data used. If the tool is taking an abnormally long time to run (>1 hour), it is typically predictive of a poor output and indicative of insufficient read depth.

