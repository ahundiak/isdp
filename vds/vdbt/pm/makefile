#/* $Id: makefile,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdbt/piece_mark/makefile
# *
# * Description: Piece Mark Routines
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
# *      Initial import to CVS
# *
# Revision 1.1  1998/04/22  23:40:16  pinnacle
# ah
#
# Revision 1.4  1998/04/10  21:58:04  pinnacle
# ah
#
# Revision 1.3  1998/04/09  14:27:04  pinnacle
# ah
#
# Revision 1.1  1998/04/02  21:27:28  pinnacle
# ah
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 04/21/98  ah      creation
# *
# ***************************************************************************/
target: pplmkfile \
	mkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile

mkfile:	vdibtpm.m
	grmakemake vdibtpm.m mkfile

pplmkfile: pplbtpm.m
	ksh $(VDS)/etc/bin/mkmkppl pplbtpm.m pplmkfile $(VDS)
