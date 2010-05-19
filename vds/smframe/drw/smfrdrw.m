/* $Id: smfrdrw.m,v 1.2 2001/05/24 20:34:42 jayadev Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/drw / smfrdrw.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smfrdrw.m,v $
 *	Revision 1.2  2001/05/24 20:34:42  jayadev
 *	TR# MP5230
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
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
# Revision 1.2  1996/04/19  12:57:04  pinnacle
# Replaced: smframe/drw/smfrdrw.m for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
DrwFrame.I
#else
DrwFrame.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/smiframedrw.o
#else
$VDS/lib/smiframedrw.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
#endif

$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
