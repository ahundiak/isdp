/* $Id: postdm2.m,v 1.1 2002/05/31 16:29:11 tlstalli Exp $  */
/* --------------------------------------------------------------------
 * Post_DM2
 *
 * File:	Post_DM2.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
Post_DM2.c
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
$EXTR4RVW/bin/pma/Post_DM2.exe

CC
acc -ansi

