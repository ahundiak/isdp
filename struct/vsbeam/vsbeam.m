/* $Id: vsbeam.m,v 1.5 2001/11/09 23:28:14 ramarao Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsbeam/vsbeam.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsbeam.m,v $
 *      Revision 1.5  2001/11/09 23:28:14  ramarao
 *      Implemented CR# 3976.
 *
 *      Revision 1.4  2001/11/04 17:35:00  jayadev
 *      fix for TR#5723
 *
 *      Revision 1.3  2001/10/13 19:18:34  ramarao
 *      Fixed TR# 5630.
 *
 *      Revision 1.2  2001/07/31 16:16:59  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.5  1998/04/20  14:28:52  pinnacle
# TR179801020
#
# Revision 1.4  1998/03/31  11:56:18  pinnacle
# Replaced: vsbeam/vsbeam.m for:  by svkadamb for struct
#
# Revision 1.3  1997/12/15  22:18:58  pinnacle
# CenterLine
#
# Revision 1.2  1997/10/06  09:34:34  pinnacle
# Replaced: vsbeam/vsbeam.m for:  by svkadamb for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *           suresh  modification
 * 12/14/97  ah      Added VSbmGetCL.I (VDSroot.VDGetCenterLine)
 * 04/20/98  ah      TR179801020 Removed VSbmGetCL.I (now in VSfeature)
 ***************************************************************************/
SOURCE
/*
	Abstract beam
*/
#if ISDP_MAKE_SP
VSbbcnstfeet.I
VSbmmakeseg.I
VSxbcnstsol.I
VSbmgivestrc.I
VSbmdeclivity.I
#else
VSbeam.S
VSbmaxisend.I
VSbmdbintrfc.I
VSbmdescfoot.I
VSbmextrprfl.I
VSbmfillattr.C
VSbmgetspprt.I
VSbmgivestrc.I
VSbmfcixtonm.I
VSbmfcnmtoix.I
VSbmfndxvec.I
VSbmfrzcpy.I
VSbmgetobjdf.I
VSbmgetxsCS.I
VSbmlstfaces.I
VSbmmakeline.I
VSbmmakeseg.I
VSbmmassprop.I
VSbmorient.I
VSbmprefix.I 
VSbmtrixtonm.I
VSbmtrnmtoix.I
VSbmxdirCS.I
VSbmxsecparm.I
VSbmfixrep.C
VSbeamlength.C
/*
	Source beam
*/
VSsrcBeam.S
VSsbcnstfeet.I
VSsbcnstline.I
VSsbcnstsol.I
VSsbgetattr.I
VSsbgetobjdf.I
VSsbgetspprt.I
VSsbgetedatt.I
VSsbmvtoroot.I
VSsborient.I
VSsbputattr.I
VSsbttentrie.I
VSgetsolbeam.I
/*
	Stiffener beam
*/
VSstfBeam.S
VSstconst.I
VSstcnstfeet.I
VSstcnsttype.I
VSstgetedatt.I
VSstgetobjdf.I
VSstgetspprt.I
VSstmvtobeam.I
VSstplatside.I
VSstplatsurf.I
VSststfndplt.I
VSstttentrie.I
/*
	Modified beam
*/
VSmodBeam.S
VSmbgetspprt.I
VSmborient.I
VSmbgetsolbm.I
/*
	Boolean beam (boolean difference)
*/
VSbooBeam.S
VSbbcnstfeet.I
VSbbgetobjdf.I
VSbbdelete.I
VSbbmvtoroot.I
VSbbgetspprt.I
VSbbfilter.I
VSbbgetrange.I
/*
	Orientation beam
*/
VSornBeam.S
VSobgetobjdf.I
VSobdelete.I
VSobcnstfeet.I
VSoborient.I
VSobretnfoot.I
VSobgivepath.I
VSobsymmfoot.I
VSobaxisend.I
/*
	Extended and trimmed beam
*/
VSxtrBeam.S
VSxbconst.I
VSxbcnstfeet.I
VSxbcnstline.I
VSxbcnstsol.I
VSxbgetobjdf.I
VSxbrevnorm.C
VSxbgetxtend.I
VSxbxtndaxis.I
VSxbgetspprt.I
VSxbcircaxxt.I
VSxbdelete.I
VSxbmvtoroot.I
/*
	Split beam with plate.
*/
VSsplBeam.S
VScbcnstfeet.I
VScbspcv2pts.I
VScbgetobjdf.I
/*
	Split beam with points.
*/
VSpntBeam.S
VSdbcnstfeet.I
VSdbgetobjdf.I
/*
	Sub-beam.
*/
VSsubBeam.S
VSubcnstfeet.I
VSubgetobjdf.I
VSubgetspprt.I
/*
	Frozen beam.
*/
VSfrzBeam.S
VSfbcptoroot.I
VSfbgetobjdf.I
VSfbgivestrc.I
VSfbgetedatt.I
VSfbformat.I
VSfbbcmfoot.I
VSfbgrxform.I
VSfbbmlength.I

VSfndbmxt2sf.I
/*
	Twisted beam
*/
VStwsBeam.S
VStwgetobjdf.I
VStwcnstfeet.I
VStwgetspprt.I

VSbmcentaxis.I
VSbmdeclivity.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vsbeam.o
#else
$(STRUCT)/lib/vsbeam.o
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
$(GRNUC)/src/assoc/include_priv
$(MODEL)/include
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
