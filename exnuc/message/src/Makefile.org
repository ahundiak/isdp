target: mkfile
	grmake -r -k -f mkfile

mkfile: message.m
	grmakemake message.m mkfile
