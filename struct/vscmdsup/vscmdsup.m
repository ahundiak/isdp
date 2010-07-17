/* $Id: vscmdsup.m,v 1.7 2001/08/30 22:06:10 ylong Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmdsup/vscmdsup.m
 *
 * Description: Modify Operator Functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vscmdsup.m,v $
 *      Revision 1.7  2001/08/30 22:06:10  ylong
 *      fix for TR#MP5412
 *
 *      Revision 1.6  2001/05/09 16:33:56  ramarao
 *      Fixed TR# 5184.
 *
 *      Revision 1.5  2001/04/18 22:18:30  jayadev
 *      TR# MP 5030
 *
 *      Revision 1.4  2001/03/06 23:51:11  ramarao
 *      Added Modify Beam Operator entries.
 *
 *      Revision 1.3  2001/02/25 19:41:46  ramarao
 *      Created "Review Structural Objects" command.
 *
 *      Revision 1.2  2001/02/25 19:21:06  ramarao
 *      Created "Review Structural Objects" command.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:30  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/04/26  20:57:12  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/26/99  ah      Added header, mop routines
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VSmopPlate.I
VSmopCmd.I
VSCmdRevObjFi.I
VSclsdplcvAH.I
VSlocateCmdi.I
#else
VSlocateCmd.S
VSlocateCmdi.I

VSmacpalCmd.S
VSmacpalCmdi.I

VSpartopCmd.S
VSpartopCmdi.I

VSqryRdbCmd.S
VSqryRdbCmdi.I

VSstrtupCmd.S
VSstrtupCmdi.I

VSclsdplcvAH.I
VSextorisfAH.I
VSfltfeatrAH.I
VSisanedftAH.I
VSissuppbmAH.I
VSissuppplAH.I
VSrjtsubclAH.I

VSdefltvalue.C
VSprcunitfld.C
VSrdbCache.C

VSrtUpdCmd.S
VSrtUpdCmdi.I

VSmopVLA.I
VSmopPlate.I
VSmopCmd.I
VSmopBeam.I
VSmopBeamCmd.I

VSCmdRevObjF.S
VSCmdRevObjFi.I
VSCmdRevImp.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vscmdsup.o
#else
$(STRUCT)/lib/vscmdsup.o
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
$(VDS)/vdinclude
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
CLIX SYSV BSD ENV5 LITTLE_ENDIAN __APGE__

CC
acc -ansi -O3
