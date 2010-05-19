/* $Id: vdiannotdim.m,v 1.2 2001/11/08 16:09:04 hans Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vdannot/dim/vdiannotdim.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiannotdim.m,v $
 *      Revision 1.2  2001/11/08 16:09:04  hans
 *      Fix for TR# MP5641
 *
 *      Revision 1.1  2001/10/17 20:40:02  hans
 *      Modifications for CR# MP5368
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *	01/10/96     HF		The new Item Balloon functionality requires extensions to the
 *				dim.h dimdef.h & dimanform.h header files of GRNUC.
 *				The source files in this directory are overrides from the
 *				following GRNUC files :
 *
 *				$GRNUC/src/dim/dim_annot: annot.I	dyn_txbln.I	txbln.I
 *				$GRNUC/src/dim/dim_co   : anplace.I
 *				$GRNUC/src/dim/dim_utils: par.I
 *
 *				Until this new functionality has been integrated in
 *				EMS, these files have to remain in vdannot/dim.
 *
 *				NOTE:
 *				ANY SOURCE FILE that uses ANY of the NEW functionality
 *				HAS TO use the new dim.h dimdef.h & dimanform.h header files
 *				in stead of the GRNUC version.
 *				This means that $VDS/vdinclude needs to preceed $GRNUC/include
 *				in the INCLUDE section of the <name>.m file
 *	5/30/96		adz	Add update.I file.
 *
 *	10/16/2001	HF	Modifications for CR# MP5368
 *                              Renamed vdannotdim.m to vdiannotdim.m
 *                              so we can use simplified makefile.
 *      11/08/2001	HF	Fix for TR 5641 - Added file compute.I
 *************************************************************************/

SOURCE
#if ISDP_MAKE_SP
dim.I
dimline_l.I
dimtext_l.I
compute.I
#else
annot.I
dyn_txbln.I
txbln.I
anplace.I
par.I
update.I
dim.I
dimline_l.I
dimtext_l.I
compute.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiannotdim.o
#else
$VDS/lib/vdiannotdim.o
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$VDS/include
$VDS/vdinclude
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp
