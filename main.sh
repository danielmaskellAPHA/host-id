from Bio import Seq, SeqIO
import argparse
import os
import sys
from os.path import isfile, isdir, join

def main(folder):
	print(folder)
	files = file_spew(folder)
	print(files)
	for file in files:
		print(os.path.isfile(file))
	header_fix(files)
	
def file_spew(argfolder_input):
	files = [
        os.path.join(dirpath, f)
        for (dirpath, dirnames, filenames) in os.walk(argfolder_input)
        for f in filenames
        ]
	
	consensus = [file for file in files if isfile(file) and file.endswith(".fasta")]
	return consensus

def header_fix(files):
	for file in files:
		newname = file.replace(".fasta", ".edit.fasta")
		with open(file) as original, open(newname, "a+") as output:
			records = SeqIO.parse(original, "fasta")
			#sometimes there are multiple records
			count = 1
			for record in records:
				#check topology and trim header (mitoZ wont work otherwise - yet another example of why make blast db is a PITA)
				if ("circular" in record.id) or ("circular" in record.description):
					record.id = f"{count} topology=circular"
				else:
					record.id = f"{count} topology=linear"
				#clear description if there is one
				record.description = ""
				#write
				SeqIO.write(record, output, "fasta")
				#advance count
				count += 1	



if __name__ == "__main__":
        parser = argparse.ArgumentParser()
        parser.add_argument("files", help="files")
        args = parser.parse_args()
        main(args.files)
