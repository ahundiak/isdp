target : makeflag RPTequip.a RPTroute.a RPTstruct.a RPTgener.a RPTcomp.a

makeflag :
	   make -f BMmkfile
	   make -f BPmkfile
	   make -f EQmkfile
	   make -f HVmkfile
	   make -f NZmkfile
	   make -f OVmkfile
	   make -f PLmkfile
	   make -f PPmkfile
	   make -f RPmkfile
	   make -f RWmkfile
	   make -f CMmkfile
	   make -f VDmkfile

RPTequip.a : EQ*.o
	     rm RPTequip.a
	     ar -rv RPTequip.a EQ*.o

RPTcomp.a : CM*.o
	     rm RPTcomp.a
	     ar -rv RPTcomp.a CM*.o

RPTroute.a : HV*.o NZ*.o PP*.o RW*.o
	     rm RPTroute.a
	     ar -rv RPTroute.a HV*.o NZ*.o PP*.o RW*.o

RPTstruct.a : BM*.o BP*.o PL*.o
	      rm RPTstruct.a
	      ar -rv RPTstruct.a BM*.o BP*.o PL*.o

RPTgener.a : OV*.o VD*.o
	     rm RPTgener.a 
	     ar -rv RPTgener.a OV*.o VD*.o
