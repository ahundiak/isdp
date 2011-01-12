target: mkfile
	grmake -r -k -f mkfile

mkfile: stubs.m
	grmakemake stubs.m mkfile
