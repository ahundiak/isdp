.SUFFIXES: .u .e

ppl_execs=\
	flip.e \
	FixGloop.e \
	DesignBar.e \
	DetailBar.e \
	ECintfbatch.e \
	MakeSeedEng.e \
	MakeSeedMEng.e \
	MakeSeedMMet.e \
	MakeSeedMet.e \
        MakeSeedDtl.e \
	rnd_lin.e \
	clnuphrzcvs.e \
        ReadOnlyDtl.e \
        DelSooTbls.e \
	ConvRefpln.e \
        SKdimfix.e \
        linarcfc.e \
        modxhatch.e \
		atpdebug.e \
                Convert.e

COMPILE: $(ppl_execs)
.u.e :
	@echo "\t$< -> $*.e"
	$(GRNUC)/bin/ppl -Xexternfn $<
	ln $*.e ../bin
