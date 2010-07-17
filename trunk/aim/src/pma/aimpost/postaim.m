/* $Id: postaim.m,v 1.1 2002/05/31 16:28:08 tlstalli Exp $  */
/* --------------------------------------------------------------------
 * postaim.m
 *
 * File:	postaim.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: postaim.m,v $
 *	Revision 1.1  2002/05/31 16:28:08  tlstalli
 *	Backup of PMA process from EXTR
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:22  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:43:50  pinnacle
# EXTR 2.5.1
#
# Revision 1.3  1997/11/24  17:52:36  pinnacle
# update the link libs.
#
# Revision 1.2  1997/11/13  17:28:44  pinnacle
# Replaced: pma/aimpost/postaim.m for:  by e250_int for extr25
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
AIMpost.c
VDpostman.c

INCLUDE

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

EXEC
$EXTR4RVW/bin/pma/AIMpost.exe

CC
acc -ansi

