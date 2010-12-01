target: mkfile
	grmake -r -k -f mkfile

mkfile: makefile app.m
	grmakemake app.m mkfile

clean:
	@rm -f mkfile *.o dload
