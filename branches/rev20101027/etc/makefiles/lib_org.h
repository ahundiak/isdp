#/* $Id: lib_org.h,v 1.1 2001/01/14 16:15:18 art Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vds/etc/makefiles/lib_org.h
# *
# * Description: The template for makefiles which generate one library
# *              From one .m file both sharing the same name
# *              Which is specified by TGT
# *
# *              This is the original version of the makefile before
# *              The attempt to handle both service packs and builds
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: lib_org.h,v $
# *      Revision 1.1  2001/01/14 16:15:18  art
# *      sp merge
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 01/14/01  ah      creation
# ***************************************************************************/

target:	mkfile
	grmake -r -k -f mkfile

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile

