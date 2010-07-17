/* $Id: vsplate.m,v 1.5 2001/08/15 15:47:23 jayadev Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:       vsplate/vsplate.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsplate.m,v $
 *      Revision 1.5  2001/08/15 15:47:23  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/05/02 16:39:39  jayadev
 *      recover lost feet
 *
 *      Revision 1.3  2001/04/16 20:02:21  jayadev
 *      TR#MP5031
 *
 *      Revision 1.2  2001/04/02 22:04:04  ramarao
 *      Service Pack changes and Fixed TR# 4989 and 4985.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:53  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/03/31  11:59:08  pinnacle
# Replaced: vsplate/vsplate.m for:  by svkadamb for struct
#
# Revision 1.3  1998/02/13  14:21:18  pinnacle
# ah added vds/include/prototypes
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      02/13/98  ah      Added Header, added vds/include/prototypes
 *
 ***************************************************************************/

SOURCE
/*
	Abstract plate
*/
#if ISDP_MAKE_SP
VSpltopbotmp.I
VSbpcnstfeet.I
VScpcnstfeet.I
VSplretnfoot.I
VSipcnstfeet.I
#else
VSplate.S
VSplgetobjdf.I
VSplgivestrc.I
VSpltrixtonm.I
VSpltrnmtoix.I
VSplretnfoot.I
VSplgivepath.I
VSplmassprop.I
VSpltopbotmp.I
VSplchgcnsrp.I
VSplorient.I
VSplprefix.I
VSplfillattr.C
VSplfixrep.C
VSpllstfaces.I
VSplfrzcpy.I
VSpldescfoot.I
VSplfacecnt.I
VSpldetplane.I
VSplgetstfns.I
/*
	Parametric plate
*/
VSvarPlate.S
VSvpcnstfeet.I
VSvpgetobjdf.I
VSvpthkfrRDB.I
VSvpgetspprt.I
VSvpgetedatt.I
/*
	Source plate
*/
VSsrcPlate.S
VSspcnstfeet.I
VSspgetattr.I
VSspgetobjdf.I
VSspgetspprt.I
VSspgetedatt.I
VSspputattr.I
VSspmvtoroot.I
VSspttentrie.I
/*
	Modified plate
*/
VSmodPlate.S
VSmpforcerep.I
/*
	Impose-boundary plate
*/
VSimbPlate.S
VSipcnstfeet.I
VSipgetobjdf.I
VSipmvtoroot.I
VSipdelete.I
/*
	Holed plate
*/
VSholPlate.S
VShpimpbndry.I
VShpgetobjdf.I
/*
	Marked plate
*/
VSmrkPlate.S
VSkpimpbndry.I
VSkpgetobjdf.I
/*
	Split plate (with a curve)
*/
VSsplPlate.S
VScpcnstfeet.I
VScpgetobjdf.I
/*
	Sub-plate
*/
VSsubPlate.S
VSupcnstfeet.I
VSupgetobjdf.I
VSupgetspprt.I
/*
	Boolean plate (boolean difference)
*/
VSbooPlate.S
VSbpcnstfeet.I
VSbpcnst3Drp.I
VSbpcnst2Drp.I
VSbpdelete.I
VSbpgetobjdf.I
VSbpmvtoroot.I
VSbprepres.I
VSbpfacecnt.I
VSbpgetrange.I
/*
	Split plate with a gap
*/
VSgapPlate.S
VSgpcnstfeet.I
VSgpgetobjdf.I
VSgprmbndry.I
/*
	Frozen plate
*/
VSfrzPlate.S
VSfpcptoroot.I
VSfpformat.I
VSfpgetedatt.I
VSfpgetobjdf.I
VSfpbcmfoot.I
VSfptopbotmp.I
VSfpgrxform.I
/*
	Post placement plate (no spec file)
*/
VSpppPlPlate.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vsplate.o
#else
$(STRUCT)/lib/vsplate.o
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
$(VDS)/include/prototypes
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
