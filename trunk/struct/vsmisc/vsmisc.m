/* $Id: vsmisc.m,v 1.11 2002/02/06 22:32:27 jayadev Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:       struct/vsmisc/vsmisc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsmisc.m,v $
 *      Revision 1.11  2002/02/06 22:32:27  jayadev
 *      added VSconsume.I to SP
 *
 *      Revision 1.10  2001/10/22 17:03:22  ramarao
 *      Moved struct/vsmisc/VSvalidate.I file to vds/vdmisc/VDvalidate.I.
 *
 *      Revision 1.9  2001/10/21 19:06:21  ramarao
 *      Fixed a small bug while working on CR# 4081.
 *
 *      Revision 1.8  2001/08/30 22:03:03  ylong
 *      functions for TR#5412
 *
 *      Revision 1.7  2001/05/01 16:23:38  ramarao
 *      Fixed a crv_roll problem related to Profile Cards.
 *
 *      Revision 1.6  2001/04/11 22:34:04  ramarao
 *      Fixed TR# 5010. Replace overlap function with BScvcv_int().
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/11/01	Rama Rao	Added Header.
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VSrempenhol.I
VSgetrollmc.I
VSgetchildrn.I
VSconsume.I
#else
VSbeambox.I
VSbldrootcpx.I
VSbuildname.C
VScmpbmgdbst.I
VScmpixpath.C
VScnstdeflts.C
VScrtGadgets.C
VSdebug.C
VSdrwcvonfm.C
VSelmsonsupp.I
VSexpvalue.I
VSgetbmplcst.C
VSgetconsumr.I
VSgetmacinfo.I
VSfillcnstls.C
VSfitGadgets.C
VSfndendinfo.I
VSfndendtrts.I
VSfndslsinmc.I
VSfreeOpHist.C
VSgencmpname.C
VSgetchanobj.C
VSgetinpbynm.I
VSgetgscntnt.C
VSgetOpType.I
VSisancestry.C
VSisobjofcls.C
VSisosninlst.C
VSmemdup.C
VSmkgrobjtmp.I
VSmulspprtmx.C
VSmxalgebra.C
VSocgrleaves.C
VSpocketUtil.C
VSprcssfence.C
VSrangebxint.C
VSregexp.C
VSseterrmsg.C
VSstringUtil.C
VSvcalgebra.C
VSbmutil.I
VSbulkdel.I
VSbulkdsp.I
VSconsume.I
VSchgsymb.I
VSdrwxsonfm.I
VSfmtObjInfo.I
VSgetchildrn.I
VSgetmodattr.I
VSnameUtil.I
VSobjgarbage.I
VSobjsppassm.I
VSprtinasbly.I
VStoltests.C
VSupdreffdep.I
VSvirtinfo.I
VStxtexpval.I
VSgetrollmc.I
VSgetsibling.I
VSvalidate.I
VSrempenhol.I
VSexecfnhist.I
VSplateUtil.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vsmisc.o
#else
$(STRUCT)/lib/vsmisc.o
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
$(SPXV)/vdinclude
$(SPXS)/include
$(SPXS)/include/prototypes
#endif
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/proto_priv
$(MODEL)/include
$(FORMS)/include
$(VDS)/include
$(STRUCT)/include
$(STRUCT)/include/prototypes

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

/*
 * "CLIX" : -D switch for operating system
 * "ENV5" : -D switch for windowing system
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN _INGR_EXTENSIONS

CC
acc -ansi -O3
