target: mkfile
	grmake -r -k -f mkfile

mkfile: igefei.m
	grmakemake igefei.m mkfile
