/* $Id: vsfeature.m,v 1.4 2001/04/14 17:10:32 jayadev Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsfeature/vsfeature.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsfeature.m,v $
 *      Revision 1.4  2001/04/14 17:10:32  jayadev
 *      remove operator problem
 *
 *      Revision 1.3  2001/01/17 23:18:06  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/17 23:06:50  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/04/20  14:23:02  pinnacle
# TR179801020
#
# Revision 1.3  1998/01/07  08:28:58  pinnacle
# Replaced: vsfeature/vsfeature.m for:  by svkadamb for struct
#
# Revision 1.2  1997/12/15  22:25:00  pinnacle
# VDprocAttr
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/14/97  ah      Added VSfeProcAttr.I (VDSroot.VDprocAttr)
 * 04/20/98  ah      TR179801020 Added VDSroot.VDGetCenterLine     
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VSdfremoveop.I
#else
VSfeature.S
VSfeProcAttr.I
VSfeGetCL.I

VSfebcmmacro.I
VSfechgname.I
VSfechilddel.I
VSfechldcnsr.I
VSfecnsmerep.I
VSfeconst.I
VSfecopy.I
VSfecptoroot.I
VSfedbintrfc.I
VSfedelete.I
VSfedidump.I
VSfedrop.I
VSfedrwcpgeo.I
VSfefindcoll.I
VSfefrzcpy.I
VSfefwdtoorg.I
VSfefwd2src.I
VSfefwdtosrc.I
VSfegetcnsmd.I
VSfegetjnts.I
VSfegetname.I
VSfegetopmgr.I
VSfegivepath.I
VSfegiveoutp.I
VSfegivestrc.I
VSfegrcopy.I
VSfehdrclsid.I
VSfeisorigin.I
VSfelocate.I
VSfelocprops.I
VSfemvtoroot.I
VSfenrmofcmp.I
VSfeobjinfo.I
VSfeoperatn.I
VSfeoperator.I
VSfeophist.I
VSfeputdvjns.I
VSfeputjoint.I
VSfeputmdjns.I
VSfeputname.I
VSferegen.I
VSferestype.I
VSferetnfoot.I
VSfeusrattr.I
VSfettentrie.I
VSfevisdvres.I
VSfevisobjct.I
VSfexfcinftr.I
VSfegetsib.I

/*
	Modified features
*/
VSmodFeature.S
VSmfalwstrue.I
VSmfchgsymb.I
VSmfcopy.I
VSmfcptoroot.I
VSmfevaluate.I
VSmfgetattr.I
VSmfgetedatt.I
VSmfgetspprt.I
VSmfifsrcsnd.I
VSmfisorigin.I
VSmfnamehold.I
VSmfputattr.I
VSmfremoveop.I
VSmfrepres.I
VSmftransrep.I
VSmfundoop.I
VSmfvirtobj.I
/*
	Divided features
*/
VSdivFeature.S
VSdfchilddel.I
VSdfconst.I
VSdfcptoroot.I
VSdfdelete.I
VSdfmvtoroot.I
VSdfremoveop.I
VSdfsubfeat.I
VSdfsubmask.I
/*
	Sub-features
*/
VSsubFeature.S
VSufdelete.I
VSufgetedatt.I
VSufgetopmgr.I
VSufindex.I
VSufisorigin.I
VSufnamehold.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vsfeature.o
#else
$(STRUCT)/lib/vsfeature.o
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXS)/include
$(SPXS)/include/prototypes
#endif

$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/proto_priv
$(GRNUC)/src/assoc/include_priv
$(MODEL)/include
$(FORMS)/include
$(VDS)/include
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
