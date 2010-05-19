/* $Id: vdvesrc.m,v 1.6 2002/03/30 16:19:23 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddraw/ve/vddrawve.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdvesrc.m,v $
 *	Revision 1.6  2002/03/30 16:19:23  ad
 *	*** empty log message ***
 *	
 *	Revision 1.5  2002/03/30 16:05:07  ad
 *	*** empty log message ***
 *	
 *	Revision 1.4  2001/10/20 18:16:47  ylong
 *	fix for TR# MP5511
 *	
 *	Revision 1.3  2001/01/19 22:03:34  ramarao
 *	Merged from SP.
 *	
 *	Revision 1.2  2001/01/19 21:43:26  ramarao
 *	Merged from SP.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:41  cvs
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
# Revision 1.7  1995/09/26  15:28:00  pinnacle
# Replaced: vddraw/ve/src/vdvesrc.m for:  by sundar for vds.240
#
# Revision 1.6  1995/04/07  13:39:18  pinnacle
# Replaced: vddraw/ve/src/vdvesrc.m by azuurhou r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDveprocess.I
#else
VDveprocess.I
VEestab.I
VEtransform.C
VEmk_surf.I
VEoverlap.C
VEstatus.C
VEclassify.I
VEactivate.c
VEset_trim.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vdidrawve_sr.o
#else
$(VDS)/vddraw/ve//lib/vdidrawve_sr.o
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
$GRNUC/proto_priv
$GRNUC/src/assoc/include_priv
$MODEL/include
$MODEL/proto_include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$FORMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
