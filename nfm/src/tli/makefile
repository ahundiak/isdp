
target: makeimp makeexec
	grmake -r -k -f makeimp
	@cd $(NFM10)/lib; make; cd
	grmake -r -k -f makeexec

makeimp: imp.m
	grmakemake imp.m makeimp

makeexec: exec.m
	grmakemake exec.m makeexec

clean:
	@rm -f makeimp makeexec tli *.o
