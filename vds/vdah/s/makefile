#/* $Id: makefile,v 1.3 2001/01/11 16:34:32 art Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdahc/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.3  2001/01/11 16:34:32  art
# *      sp merge
# *
# *      Revision 1.1  2001/01/11 16:20:59  art
# *      s merge
# *
# Revision 1.1  2000/12/06  14:54:16  pinnacle
# ah
#
# Revision 1.1  2000/12/01  14:03:18  pinnacle
# ah
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 11/30/00  ah      creation
# ***************************************************************************/

TGT = vdiahs

target:	mkfile
	grmake -r -k -f mkfile

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile

clean:
	@rm -f mkfile *.o

