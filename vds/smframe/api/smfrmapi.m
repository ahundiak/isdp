/* $Id: smfrmapi.m,v 1.2 2001/05/09 15:46:42 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	smframe/api/smfrmapi.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smfrmapi.m,v $
 *	Revision 1.2  2001/05/09 15:46:42  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/18  18:56:48  pinnacle
# SurfaceFrame
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/09/27  15:04:32  pinnacle
# Replaced: smframe/api/smfrmapi.m for:  by ksundar for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/02/20  20:34:00  pinnacle
# Created: ./smframe/api/smfrmapi.m by azuurhou for vds.240
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  12/17/97  ah      Added SMint.I
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
SMint.I

#else
FrameSystem.I
SinglePlane.I
SMfunc.I
SMint.I
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
/usr/ip32/forms/include
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

LIB
#if ISDP_MAKE_SP
$SPXV/lib/smiframeapi.o
#else
$VDS/lib/smiframeapi.o
#endif

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
