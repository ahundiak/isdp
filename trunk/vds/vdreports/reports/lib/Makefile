target: RPTconv.o RPTcrout.o RPTglobal.o RPTlib.a

RPTconv.o: ../lib/RPTconv.4gl
	   ${INFORMIXDIR}/bin/c4gl -c ../lib/RPTconv.4gl

RPTcrout.o: ../lib/RPTcrout.c
	   ${INFORMIXDIR}/bin/c4gl -c ../lib/RPTcrout.c -I../inc

RPTglobal.o: ../lib/RPTglobal.4gl
	   ${INFORMIXDIR}/bin/c4gl -c ../lib/RPTglobal.4gl

RPTlib.a: RPTconv.o RPTcrout.o RPTglobal.o
	  rm RPTlib.a
	  ar -rv RPTlib.a RPTconv.o RPTcrout.o RPTglobal.o
