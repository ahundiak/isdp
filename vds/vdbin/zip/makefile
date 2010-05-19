# $Id: makefile,v 1.3 2002/05/02 19:27:07 ahundiak Exp $
#!/bin/ksh

#**********************************************************************
# I/VDS
#
# File:		vdbin/zip/makefile
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.3  2002/05/02 19:27:07  ahundiak
#	ah
#	
#	Revision 1.2  2002/04/25 15:10:54  ylong
#	*** empty log message ***
#	
#	Revision 1.1  2002/04/23 21:01:48  ylong
#	deliver gzip and gunzip
#	
#
# History:
# MM/DD/YY	AUTHOR		DESCRIPTION
# 04/20/02	ylong		creation
#
#**********************************************************************


target:
	@if [ -f gzip ]; \
	then \
		cp gzip ${VDS}/bin; \
		echo "--- copy gzip to vds/bin/gzip"; \
	else \
		if [ -f /bin/gzip ]; \
		then \
			cp /bin/gzip ${VDS}/bin; \
			echo "--- copy /bin/gzip to vds/bin/gzip"; \
		else \
			echo "*** Error, missing gzip"; \
		fi; \
	fi;

	@if [ -f gunzip ]; \
	then \
		cp gunzip ${VDS}/bin; \
		echo "--- copy gunzip to vds/bin/gunzip"; \
	else \
		if [ -f /bin/gunzip ]; \
		then \
			cp /bin/gunzip ${VDS}/bin; \
			echo "--- copy /bin/gunzip to vds/bin/gunzip"; \
		else \
			echo "*** Error, missing gunzip"; \
		fi; \
	fi;

	@if [ -f dtpad ]; \
	then \
		cp dtpad ${VDS}/bin; \
		echo "--- copy dtpad to vds/bin/dtpad"; \
	else \
		if [ -f /usr/dt/bin/dtpad ]; \
		then \
			cp /usr/dt/bin/dtpad ${VDS}/bin; \
			echo "--- copy /usr/dt/bin/dtpad to vds/bin/dtpad"; \
		else \
			echo "*** Error, missing dtpad"; \
		fi; \
	fi;
