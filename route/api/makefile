# $Id: makefile,v 1.1 2001/01/26 17:51:50 anand Exp $

# -------------------------------------------------------------------
# I/CABLE
#
# File:	cable/api/makefile
#
# Description:
#       makefile for dynamic (c-functions) analysis package
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1  2001/01/26 17:51:50  anand
#	*** empty log message ***
#	
#	
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target:	mesg

mesg:	
	@echo "this make needs dyn or ppl as arguments"

dyn:	mkfile
	grmake -r -k -f mkfile

mkfile : vcapi.m
	grmakemake vcapi.m mkfile

ppl:	VCAN_ppl.e

VCAN_ppl.e:	VCAN_ppl.u ${CABLE}/include/vc_public.h
		${CABLE}/bin/cci.sh VCAN_ppl.u
