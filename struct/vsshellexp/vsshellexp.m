/* $Id: vsshellexp.m,v 1.3 2002/03/21 17:51:54 ad Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsshellexp/vsshellexp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsshellexp.m,v $
 *      Revision 1.3  2002/03/21 17:51:54  ad
 *      For pload $STRUCT was defined as STRUCT.
 *
 *      Revision 1.2  2001/08/17 21:59:29  hans
 *      Fix for TR's 4388 & 4798
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:01  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/03/01  15:02:34  pinnacle
# TR179701791
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTIO
 * 03/01/98  ah      TR179701791 Added VSpsi1.I
 *
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP

VSsxcnstfeet.I
VSsxdelete.I
VSsxgetobjdf.I
VSsxgetblnpt.I
VSsxgetlmpts.I
VSsxytrans.I
VSsxgetexcv.I

VSxccnstfeet.I
VSxcevaluate.I
VSxcgetobjdf.I
VSxcgethull.I
VSxcgetshtyp.I

VSsxUtil.C
VSsxexpandsh.C
VSsxexpandcv.C
VSpsi1.I

VSmsgetobjdf.I
VSmscnstfeet.I
VSmsdelete.I
VSmsevaluate.I
VSmsytrans.I
VSmsgetlmpts.I
VSmsgetparnt.I
VSmsallshexp.I

VSmcgetobjdf.I
VSmcdelete.I
VSmcparntdel.I
VSmcevaluate.I
VSmccnstfeet.I
#else
/*
	Shell expansion.
*/
VSshellExp.S
VSsxcnstfeet.I
VSsxdelete.I
VSsxgetobjdf.I
VSsxgetblnpt.I
VSsxgetlmpts.I
VSsxytrans.I
VSsxgetexcv.I
/*
	Expanded curve.
*/
VSexpandedCv.S
VSxccnstfeet.I
VSxcevaluate.I
VSxcgetobjdf.I
VSxcgethull.I
VSxcgetshtyp.I
/*
	Misc functions.
*/
VSsxUtil.C
VSsxexpandsh.C
VSsxexpandcv.C
VSpsi1.I
/*
	Merged shell expansion.
*/
VSmergeShExp.S
VSmsgetobjdf.I
VSmscnstfeet.I
VSmsdelete.I
VSmsevaluate.I
VSmsytrans.I
VSmsgetlmpts.I
VSmsgetparnt.I
VSmsallshexp.I
/*
	Merged expanded curve.
*/
VSmergeExpCv.S
VSmcgetobjdf.I
VSmcdelete.I
VSmcparntdel.I
VSmcevaluate.I
VSmccnstfeet.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXS/lib/vsshellexp.o
#else
$STRUCT/lib/vsshellexp.o
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
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
