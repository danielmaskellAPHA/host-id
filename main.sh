#!/usr/bin/env bash -l

usage()
{ echo "
hostfish VERSION: 0.1
Usage: bash main.sh -1 <r1.fastq.gz> -2 <r2.fastq.gz> OR bash main.sh -b <path/to/reads>
        Single pipeline:
        	-1 <reads1.fastq.gz> Forward reads
        	-2 <reads2.fastq.gz> Reverse reads
        
        Bulk pipeline:
        	-b <directory/to/bulk/reads> Sets pipeline to bulk mode using reads in provided directory
        	
        -h Display these options
";
}

while getopts '1:2:o:b:' flag ; do
  case ${flag} in
    1) r1=$OPTARG ;;
    2) r2=$OPTARG ;;
    o) output=$OPTARG ;;
    b) bulk_dir=$OPTARG ;;

  esac
done
  
echo "$bulk_dir"
echo "$r1"
echo "$r2"
echo "$3"


if [[ "$1" = -h ]] ; then
usage

	exit
fi


if [[ "$r1" != "" ]] && [[ "$r2" != "" ]] ; then
tworeads=true
else
tworeads=false
fi

if [[ "$bulk_dir" = "" ]] && [[ "$tworeads" = false ]] ; then
echo "***** ERROR: hostfish requires forward AND reverse reads to run. *****
Please provide reads (-1 and -2 option); or run with -h to see usage"
	exit
fi

if [[ "$bulk_dir" != "" ]] && [[ "$r1" != "" || "$r2" != "" ]] ; then
echo "***** ERROR: bulk mode initiated while individual reads provided. *****
Please use either bulk mode, or individual reads."
exit
fi

#get threads and location of headtrimmer.py
threads=$(grep -c ^processor /proc/cpuinfo)
py_dir=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")

#initiate conda in the shell
source /home/$USER/miniconda3/etc/profile.d/conda.sh

#run getorganelle, clean outputs, run mitoz
main()
{
python /home/$USER/miniconda3/bin/get_organelle_from_reads.py -1 $1 -2 $2 -R 10 -k 21,45,65,85,105 -F animal_mt -o $3 -t $threads

python $py_dir"/headtrimmer.py" $3

cd $3
#turn on mitozEnv
conda activate mitozEnv

for file in *.edit.fasta
do
mitoz annotate --fastafiles $file --outprefix mitoz --thread_number $threads --clade Chordata
done

#turn off mitozEnv for repeatability
conda activate base
}

#pipeline for bulk reads
bulk() 
{
cd "$bulk_dir"
for read1 in "$bulk_dir"/*R1*.fastq.gz
do
  R1=$read1
  R2=$(echo "$R1" | sed 's/_R1_/_R2_/')
  sfile1=$(basename "$R1")
  samplename=${sfile1%%_S*}
  output=$bulk_dir"/"$samplename"_mitogenome"
  echo $R1 $R2 $output
  main "$R1" "$R2" "$output"
  cd "$bulk_dir"
done
}

#pipeline for single set of reads
single()
{
dir=$(dirname "$r1")
sfile=$(basename "$r1")
samplename=${sfile%%_S*}
R1="$r1"
R2="$r2"
output=$dir"/"$samplename"_mitogenome"
main $R1 $R2 $output
}

#execute pipeline based on selected mode
if [[ "$bulk_dir" != "" ]] ; then
bulk
else
single
fi
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
