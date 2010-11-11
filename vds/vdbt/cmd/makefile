#/* $Id: makefile,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdbt/cmd/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
# *      Initial import to CVS
# *
# Revision 1.1  1998/04/05  13:34:26  pinnacle
# ah
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 04/04/98  ah      creation
# *
# ***************************************************************************/

target:	mkfile
	grmake -r -k -f mkfile

mkfile:	vdibtcmd.m
	grmakemake vdibtcmd.m mkfile

clean:
	@rm -f mkfile *.o *.c

