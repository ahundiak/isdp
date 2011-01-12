target: mkfile
	grmake -r -k -f mkfile

mkfile: version.m
	grmakemake version.m mkfile
