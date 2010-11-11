# $Id: makefile,v 1.2 2002/05/02 21:47:19 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdbin/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2002/05/02 21:47:19  ylong
#	*** empty log message ***
#	
#	Revision 1.1  2002/04/11 21:22:32  ylong
#	*** empty log message ***
#	
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	10/14/98	ah		Changed make to grmake for Sol2.6
# -------------------------------------------------------------------

# func must be made before source
target : 
	cd ${VDS}/vdxml; grmake;
	cd files; grmake;
	cd http; grmake;
	cd replaceOS; grmake;
#	cd sp_pens; grmake;
#	cd sp_std; grmake;
#	cd sp_val; grmake;
	cd stopsign; grmake;
	cd tree; grmake;
	cd zip; grmake;

