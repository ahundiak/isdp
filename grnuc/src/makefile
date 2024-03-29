# variables

DEBUG = COPT=-g
MAKEMAKE = ${EXNUC}/bin/makemake ${MKMKOPT}

# release libraries

release: spec imp ppl
	@:

# target for fast makes

FAST: spec 

# spec files

spec: makespec
	@if [ -f makespec ]; \
	then \
		grmake -DEBUG -rkf makespec; \
	fi

# implementation files

imp: makeimp
	@if [ -f makeimp ]; \
	then \
		grmake -DEBUG -rkf makeimp; \
	fi

# ppl files

ppl:
	@if [ -f make.ppl ]; \
	then \
		make -rk -f make.ppl DOPT1="$(MKDOPT)"; \
	fi

# development platform for GRNUC testing
# Is this target still used?
debug: makeimp
	@if [ -f makeimp ]; \
	then \
		make -rk -f makeimp ${DEBUG}; \
	fi

# keep makefiles up to date with the .m files

makeimp: imp.m 
	@if [ -f imp.m ]; \
	then \
		${MAKEMAKE} imp.m makeimp~; \
		echo "\tsed -f $(GRNUC)/integ/mknodep.sed makeimp~ > makeimp"; \
		sed -f $(GRNUC)/integ/mknodep.sed makeimp~ > makeimp; \
		rm -f version.info; \
		rm -f makeimp~; \
	fi

makespec: spec.m
	@if [ -f spec.m ]; \
	then \
		${MAKEMAKE} spec.m makespec~; \
		echo "\tsed -f $(GRNUC)/integ/mknodep.sed makespec~ > makespec"; \
		sed -f $(GRNUC)/integ/mknodep.sed makespec~ > makespec; \
		rm -f version.info; \
		rm -f makespec~; \
	fi

# generate makefile for I/MDS - export MDSDIR before making
# Is this target still used?
makefiles.mds: ${MDSDIR}/makeimp ${MDSDIR}/makespec

${MDSDIR}/makeimp: imp.m
	@if [ -f imp.m ]; \
	then \
		${MAKEMAKE} -DIDRAW imp.m ${MDSDIR}/makeimp; \
		rm -f version.info; \
	fi

${MDSDIR}/makespec: spec.m
	@if [ -f spec.m ]; \
	then \
		${MAKEMAKE} -DIDRAW spec.m ${MDSDIR}/makespec; \
		rm -f version.info; \
	fi

# establish targets for .m files so that they can be listed as dependencies
# regardless of their existence

imp.m:
	@:

spec.m:
	@:

# clean up the directory
# Are these targets used?
clean:
	@rm -if `/bin/ls *.[ICM] | sed s/..$$/.c/`

strip:
	@strip -r *.o
