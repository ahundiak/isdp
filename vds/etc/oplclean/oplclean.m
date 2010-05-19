/* $Id: oplclean.m,v 1.1 2002/03/21 17:33:36 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/etc/oplclean/vdscan.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: oplclean.m,v $
 *	Revision 1.1  2002/03/21 17:33:36  ad
 *	Add oplclean related source files.
 *	
 *	
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/21/02	adz		creation date
 *
 * -------------------------------------------------------------------*/

SOURCE
oplclean.c

EXEC
$VDS/etc/bin/oplclean

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

