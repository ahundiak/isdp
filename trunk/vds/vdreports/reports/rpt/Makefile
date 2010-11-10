target: RPTexec.4ge VDSexec.4ge

RPTexec.4ge: ../cmp/RPTmai.o  \
	     ../cmp/RPTequip.a ../cmp/RPTroute.a ../cmp/RPTstruct.a \
	     ../cmp/RPTcomp.a \
	     ../cmp/RPTgener.a ../lib/RPTlib.a
	     ${INFORMIXDIR}/bin/c4gl -ga -o RPTexec.4ge \
		    ../cmp/RPTmai.o \
		    ../cmp/RPTequip.a ../cmp/RPTroute.a ../cmp/RPTstruct.a \
	            ../cmp/RPTcomp.a \
		    ../cmp/RPTgener.a ../lib/RPTlib.a

	     mcs -d RPTexec.4ge
	     strip RPTexec.4ge
	     mv RPTexec.4ge ../reports

VDSexec.4ge: ../cmp/VDSrpt.o ../cmp/VDSfun.o ../lib/RPTlib.a
	     ${INFORMIXDIR}/bin/c4gl -ga -o VDSexec.4ge \
		    ../cmp/VDSrpt.o ../cmp/VDSfun.o ../lib/RPTlib.a
	     mcs -d VDSexec.4ge
	     strip VDSexec.4ge
	     mv VDSexec.4ge ../reports

