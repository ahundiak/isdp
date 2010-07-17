#/* $Id: lib_org.h,v 1.1 2001/01/16 22:46:29 ramarao Exp $  */

#/***************************************************************************
# * I/STRUCT
# *
# * File:        struct/etc/makefiles/lib_org.h
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
# *      Revision 1.1  2001/01/16 22:46:29  ramarao
# *      *** empty log message ***
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 01/16/01  RR      File Creation.
# ***************************************************************************/

target:	mkfile
	grmake -r -k -f mkfile

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile

