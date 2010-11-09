target: makespec makeimp
	grmake -r -k -f makespec
	grmake -r -k -f makeimp

makespec: spec.m
	grmakemake spec.m makespec

makeimp: imp.m
	grmakemake imp.m makeimp

clean:
	@rm -f makespec makeimp *.o
	@rm -f COcd.c     COdirmode.c  COmkdir.c COremove.c COshownm.c FIlstformi.c FIlstform.c
	@rm -f COcdpath.c COdirxlate.c COpwd.c   COrmdir.c  DIlocate.c FIdirformi.c FIdirform.c
	@rm -f super_diri.c super_dir.c GRlink.c

