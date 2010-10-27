/* $Id: vdregex.m,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdregex/vdregex.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdregex.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:06  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/03/14  19:10:50  pinnacle
# Created: vdregex/vdregex.m by jwfrosch for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/14/96	HF		creation date
 *
 * -------------------------------------------------------------------*/

SOURCE
VD_isl_regex.c

EXEC
$VDS/bin/VD_isl_regex

SPEC
$EXNUC/spec

LINKLIB
#ifdef ENV5
-lPW
#else
-lgen
#endif

INCLUDE
$(EXNUC)/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
