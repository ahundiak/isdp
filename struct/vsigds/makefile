#/* $Id $  */

#/***************************************************************************
# * I/STRUCT
# *
# * File:        isdp/struct/vsigds/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log $
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 01/16/01  RR      File Creation
# ***************************************************************************/

target: VSEnvIgdsi.I \
	mkfile
	grmake -r -k -f mkfile

VSEnvIgdsi.I: VSEnvIgds.sl
	/bin/touch -c VSEnvIgds.sl
	slic -C VSEnvIgds.sl -p $(STRUCT)/spec

mkfile: vsigds.m
	grmakemake vsigds.m mkfile
