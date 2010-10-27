/* $Id: vdbin.m,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdbin/vdbin.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdbin.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/11/04  20:37:40  pinnacle
# moved from vdbin
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/11/04  00:13:30  pinnacle
# Replaced: vdbin/*.m for:  by jwfrosch for vds.240
#
# Revision 1.1  1995/11/03  17:15:56  pinnacle
# Created: ./vdbin/vdbin.m by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/25/95	adz		creation date
 *
 * -------------------------------------------------------------------*/

SOURCE
VDfiles.C

EXEC
$VDS/bin/Files

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

