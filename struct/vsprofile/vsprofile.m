/* $Id: vsprofile.m,v 1.2 2002/02/13 22:29:58 jayadev Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:       $STRUCT/vsprofile/vsprofile.m 
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsprofile.m,v $
 *      Revision 1.2  2002/02/13 22:29:58  jayadev
 *      fix for TR# MP6011
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:56  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1995/10/27  15:22:24  pinnacle
# Replaced: vsprofile/*.m for:  by tdumbach for struct
#
 *
 * History:
 *      MM/DD/YY   	AUTHOR	DESCRIPTION
 *	27-Oct-95	TRD	Adding $VDS/include to include list
 *************************************************************************/

SOURCE
/*
	Composite curve with indexed components
*/
#if ISDP_MAKE_SP
VSpxcnstfeet.I
#else
VScompcurve.S
VSccinitmap.I
VSccgetmap.I
VScccmptousr.I
VSccusrtocmp.I
VSccrevparm.I
VSccdebug.I
/*
	Cross-section composite curve with named components
*/
VSxscurve.S
VSxsunmtocmp.I
VSxscmptounm.I
VSxsdebug.I
VSgrcctovsxs.I
VSagcctovsxs.I
VSxsfacemap.C
VSxscurveAG.S
VSxsAGcptort.I
VSxsAGmvtort.I
/*
	Projected profile (cross-section) onto a surface.
*/
VSprjCrsSctn.S
VSpxcnstfeet.I
VSpxgetobjdf.I
VSpxgivepath.I
VSpxretnfoot.I
/*
	Profile resulting of intersection of a beam and a surface.
*/
VSintCrsSctn.S
VSixcnstfeet.I
VSixgetobjdf.I
/*
	Composite profile definition, constructed from definitions of plates
	stuck together so as to make a beam.
*/
VSproffrplts.S
VSppcnstfeet.I
VSppretnfoot.I
VSppputattr.I
VSppgetattr.I
VSppgetobjdf.I
VSpptempstrc.I
VSmkprfrpls.I
VScalccntour.C
VSjnptswlsgs.C
VSnmcntfaces.C
#endif

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vsprofile.o
#else
$(STRUCT)/lib/vsprofile.o
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXS)/include
$(SPXS)/include/prototypes
#endif
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(VDS)/include
$(VDS)/include/prototypes
$(VDS)/vdinclude
$(STRUCT)/include
$(STRUCT)/include/prototypes

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN

CC
acc -ansi -O3
