.SUFFIXES: .sl .S

SLICPATH = -p ../../src_co/slic -p ${GRNUC}/spec -p ${MODEL}/spec
SLIC = ${EXNUC}/bin/slic -IS  
model_etc = ${MODEL}/etc

.sl.S :
	@if [ -f ../spec/${*}.S ] ; then rm ../spec/${*}.S; fi
	@if [ -f ../spec/${*}.c ] ; then rm ../spec/${*}.c; fi
	@if [ -f ../spec/${*}.o ] ; then rm ../spec/${*}.o; fi
	@if [ -f ../imp/${*}i.I ] ; then rm ../imp/${*}i.I; fi
	@if [ -f ../imp/${*}i.c ] ; then rm ../imp/${*}i.c; fi
	@if [ -f ../imp/${*}i.o ] ; then rm ../imp/${*}i.o; fi
	@if [ -f ${*}.S ] ; then rm ${*}.S; fi
	@if [ -f ${*}i.I ] ; then rm ${*}i.I; fi
	@echo slicing ${*}
	@${SLIC} ${SLICPATH} ${*}.sl
	@ln -f ${*}.S ../spec
	@ln -f ${*}.S ${MODEL}/spec
	@ln -f ${*}i.I ../imp

tees :
	@slictees.sh

