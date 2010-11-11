#/* $Id: makefile,v 1.1 2001/02/01 21:23:50 ahundiak Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdah/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.1  2001/02/01 21:23:50  ahundiak
# *      ah
# *
# *      Revision 1.3  2001/01/11 16:34:30  art
# *      sp merge
# *
# *      Revision 1.1  2001/01/11 16:20:58  art
# *      s merge
# *
# Revision 1.1  2000/12/06  14:51:48  pinnacle
# ah
#
# Revision 1.2  2000/12/01  14:12:30  pinnacle
# ah
#
# Revision 1.1  2000/04/28  19:11:36  pinnacle
# ah
#
# Revision 1.1  1997/11/25  01:19:14  pinnacle
# AssyTree
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 12/05/00  ah      Creation
# ***************************************************************************/

TGT = vdiahd

target:	mkfile
	grmake -r -k -f mkfile

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile

clean:
	@rm -f mkfile *.o

