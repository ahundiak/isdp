# $Id: makefile,v 1.1 2002/05/30 15:19:01 ylong Exp $
#!/bin/ksh

#**********************************************************************
# Aimsir
#
# File:		aim/src/shell/makefile
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1  2002/05/30 15:19:01  ylong
#	*** empty log message ***
#	
#
# History:
# MM/DD/YY	AUTHOR		DESCRIPTION
# 05/28/02	ylong		creation
#
#**********************************************************************

# For any file needed to be copied to somewhere from this dir, just add
# the code for the file copying

target:
	@if [ -f BatchDad ]; \
	then \
		cp BatchDad ${AIM_PATH}/bin; \
		echo "--- copy BatchDad to ${AIM_PATH}/bin"; \
	else \
		echo "*** Error, missing BatchDad"; \
	fi;
