target: makespec makeimp
	grmake -r -k -f makespec
	grmake -r -k -f makeimp

makespec: spec.m
	grmakemake spec.m makespec

makeimp: imp.m
	grmakemake imp.m makeimp

clean:
	@rm -f makespec makeimp *.o *.c
	@svn update
