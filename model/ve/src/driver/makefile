target: makespec
	grmake -r -k -f makespec

makespec: spec.m
	grmakemake spec.m makespec

makeimp: imp.m
	grmakemake imp.m makeimp

clean:
	@rm -f makespec makeimp *.o 

