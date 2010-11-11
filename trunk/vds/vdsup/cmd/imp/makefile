#  $Id: makefile,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $

#***************************************************************************
#* I/VDS
#*
#* File:        vdsup/cmd/imp/makefile
#*
#* Description:
#*
#* Dependencies:
#*
#* Revision History:
#*      $Log: makefile,v $
#*      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
#*      Initial import to CVS
#*
# Revision 1.1  1997/12/17  21:59:52  pinnacle
# VDsupEtc
#
#*
#* History:
#*      MM/DD/YY  AUTHOR  DESCRIPTION
#*      12/17/97  ah      Created
#***************************************************************************/

target: mkfile 
	grmake -r -k -f mkfile

mkfile : vdisupcmd.m
	grmakemake vdisupcmd.m mkfile

clean:
	@rm -f mkfile *.o *.c

