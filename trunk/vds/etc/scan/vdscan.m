/* $Id: vdscan.m,v 1.1 2002/03/11 16:16:25 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/etc/scan/vdscan.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdscan.m,v $
 *	Revision 1.1  2002/03/11 16:16:25  ad
 *	*** empty log message ***
 *	
 *	
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/11/02	adz		creation date
 *
 * -------------------------------------------------------------------*/

SOURCE
pplscan.c

EXEC
$VDS/etc/bin/pplscan

SPEC
$EXNUC/spec

LINKLIB
-lcurses
#ifdef ENV5
-lbsd
-lPW
-lgpipe_s
-linc
-lnsl_s
#else
-lsocket
-lnsl
#endif
-lUMS

INCLUDE
$(EXNUC)/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi

