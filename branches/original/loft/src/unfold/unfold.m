/* $Id: unfold.m,v 1.2 2001/06/25 17:43:22 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	src/unfold/unfold.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: unfold.m,v $
 *	Revision 1.2  2001/06/25 17:43:22  ramarao
 *	Fixed an unwrap algorithm problem.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:11:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.4  1999/12/08  16:29:34  pinnacle
# Moved bs to vds
#
# Revision 1.3  1999/06/30  20:32:18  pinnacle
# bspmath
#
# Revision 1.2  1999/06/30  19:12:16  pinnacle
# New bspmath
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.2  1998/04/23  21:10:32  pinnacle
# Replaced: src/unfold/unfold.m for:  by azuurhou for loft
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/23/98	adz		Add bssidecntrs.c & bssplitncvs.c
 *      06/30/99        ah              Deleted above 2 following new bs build
 *      06/30/99        ah              Put em back in, need to check bspmath
 *      12/08/99        ah              Moved bs functions to emsfixes/bs
 ***************************************************************************/
SOURCE
#if ISDP_MAKE_SP
VLdTessFunk.I
#else
VLdFemFunk.I
VLdTessFunk.I
VLunwrap.S
VLunwrapi.I
VLstretchV.S
VLstretchVi.I
VLmodUnwCmd.S
VLmodUnwCmdi.I
VLdFeaFunk.I
VLdBoundFunk.I
VLunwrapCmd.S
VLunwrapCmdi.I
VLstrecVCmd.S
VLstrecVCmdi.I
VLstrRpCmd.S
VLstrRpCmdi.I
VLunwMethod.I
VLdToolsFunk.I
VLdTool1Funk.I
VLunwrapFk1.I
VLunwrapFk2.I
VLunwrapFk3.I
VLunwrapFk4.I
VLunwRpCmdi.I
VLunwRpCmd.S
#endif

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXV)/vdinclude
$(SPXS)/include
$(SPXS)/include/prototypes
$(SPXL)/include
$(SPXL)/include/prototypes
#endif
$BS/include
$BS/include/prototypes
$BS/include/igr_include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$GRNUC/ingrsys
$MODEL/include
$VDS/include
$VDS/vdinclude
$STRUCT/include
$LOFT/include
$LOFT/include/private
$LOFT/include/prototypes

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec
$LOFT/spec

LIB
#if ISDP_MAKE_SP
$SPXL/lib/VLunfold.o
#else
$LOFT/lib/VLunfold.o
#endif

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc
