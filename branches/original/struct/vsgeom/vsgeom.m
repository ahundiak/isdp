/***************************************************************************
 * I/STRUCT
 *
 * File:       vsgeom/vsgeom.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: $
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      04/19/01  Jayadev creation 
 *
 ***************************************************************************/
SOURCE
#if ISDP_MAKE_SP
VSmkbooldiff.I
VSbmvertices.I
#else
VSiscvclkwis.C
VSplclppngcv.C
VSmkinfnline.C
VSspxtcvtosf.C
VSxformcurve.C
VSxtcvthrusf.C

VS2dbmmsprop.I
VSarwhd.I
VScapsurface.I
VSbmvertices.I
VScnstarrows.I
VScrvarealen.I
VSdelcvby2sf.I
VSgetCS.I
VSgetcomp.I
VSgetgeom.I
VSgetsrfdims.I
VSgetsfedges.I
VSgetsfrange.I
VSimposbndry.I
VSinfplsfint.I
VSintcvsf.I
VSintgrprops.I
VSisptonsrf.I
VSmakecvcomp.I
VSmkccfrprof.I
VSminrctplcv.I
VSmkbooldiff.I
VSmkinfplane.I
VSmknatbdry.I
VSmkoffsetsf.I
VSmkpentrcyl.I
VSoffcvalvec.I
‚‚VSoffsetcurv.I
VSoffsrf2sol.I
VSpjcv2infpl.I
VSpjcompcvsf.I
VSplcmoment.I
VSplcontcurv.I
VSplcxsect.I
VSplsfint.I
VSrecompsf.I
VSrevsforn.I
VSrmcusponcv.I
VSsetcvorien.I
VSsfnorm.I
VSsortsubsrf.I
VSsplsfwthcv.I
VStestgeom.I
VSxtsl2sftrm.I
VSgmGetGeom.I
VSmkcontedges.I
VSgmmiscfunk.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vsgeom.o
#else
$(STRUCT)/lib/vsgeom.o
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
$(GRNUC)/proto_priv
$(MODEL)/include
$(VDS)/include
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
CLIX SYSV BSD ENV5 LITTLE_ENDIAN _INGR_EXTENSIONS

CC
acc -ansi -O3
