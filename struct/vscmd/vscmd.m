/* $Id: vscmd.m,v 1.3 2002/01/29 17:45:34 ylong Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/vscmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vscmd.m,v $
 *      Revision 1.3  2002/01/29 17:45:34  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/05/08 14:52:51  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.6  1998/03/13  23:20:50  pinnacle
# New Joints
#
# Revision 1.4  1997/11/14  13:44:16  pinnacle
# Replaced: vscmd/vscmd.m for:  by svkadamb for struct
#
# Revision 1.3  1997/10/29  08:45:50  pinnacle
# Replaced: vscmd/vscmd.m for:  by svkadamb for struct
#
# Revision 1.2  1997/10/06  11:35:28  pinnacle
# Replaced: vscmd/vscmd.m for:  by svkadamb for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *           suresh  modification
 * 03/13/98  ah      TR179800680 Modify New Joint 
 ***************************************************************************/
SOURCE
#if ISDP_MAKE_SP
VSmdstifCmdi.I
VSfmbeamCmdi.I
#else
VSplplatCmd.S
VSplplatCmdi.I
VSmdplatCmd.S
VSmdplatCmdi.I
VSfmplatCmd.S
VSfmplatCmdi.I
VSspplatCmd.S
VSspplatCmdi.I
VSpmplatCmd.S
VSpmplatCmdi.I
VSfmbeamCmd.S
VSfmbeamCmdi.I
VSfmbeamUtil.I
VSplbeamCmd.S
VSplbeamCmdi.I
VSplstifCmd.S
VSplstifCmdi.I
VSplstifUtil.I
VSmdstifCmd.S
VSmdstifCmdi.I
VSorbeamCmd.S
VSorbeamCmdi.I
VSmdbeamCmd.S
VSmdbeamCmdi.I
VStogmspCmd.S
VStogmspCmdi.I
VSophistCmd.S
VSophistCmdi.I
VSundoopCmd.S
VSundoopCmdi.I
VSntbmstCmd.S
VSntbmstCmdi.I
VSxtbeamCmd.S
VSxtbeamCmdi.I
VSspbeamCmd.S
VSspbeamCmdi.I
VScompptCmd.S
VScompptCmdi.I
VSelonspCmd.S
VSelonspCmdi.I
VSsenameCmd.S
VSsenameCmdi.I
VSevmaspCmd.S
VSevmaspCmdi.I
VScrsectCmd.S
VScrsectCmdi.I
VSbmawszCmd.S
VSbmawszCmdi.I
VSstunitCmd.S
VSstunitCmdi.I
VSdelCachdDf.I
VSpartdfCmd.S
VSpartdfCmdi.I
VSselectCmd.S
VSselectCmdi.I
VSsfofpjCmd.S
VSsfofpjCmdi.I
VSbeamcsCmd.S
VSbeamcsCmdi.I
VSsdofplCmd.S
VSsdofplCmdi.I
VSchsfsdCmd.S
VSchsfsdCmdi.I
VSstf2bmCmd.S
VSstf2bmCmdi.I
VSdllcdtCmd.S
VSdllcdtCmdi.I
VSmdstelCmd.S
VSmdstelCmdi.I
VSplcJntCmd.S
VSplcJntCmdi.I
VSmodJntCmd.S
VSmodJntCmdi.I
VSmdnjntCmd.S
VSmdnjntCmdi.I
VSnjnattCmd.S
VSnjnattCmdi.I
VSjnattrCmd.S
VSjnattrCmdi.I
VSjnattrUtil.C
VSsimprctout.I
VSctoutsCmd.S
VSctoutsCmdi.I
VSslmcftCmd.S
VSslmcftCmdi.I
VSfmcppfCmd.S
VSfmcppfCmdi.I
VScrcppfCmd.S
VScrcppfCmdi.I
VScrcppfUtil.C
VSextstfCmd.S
VSextstfCmdi.I
VSextstfUtil.I
VSreportCmd.S
VSreportCmdi.I
VSmodattCmd.S
VSmodattCmdi.I
VStracflCmd.S
VStracflCmdi.I
VSshexpCmd.S
VSshexpCmdi.I
VSexshcvCmd.S
VSexshcvCmdi.I
VSovrlngCmd.S
VSovrlngCmdi.I
VSmeshexCmd.S
VSmeshexCmdi.I
VSlogname.C
VSplEdAtCmd.S
VSpledatCmdi.I
VSmigrstCmd.S
VSmigrstCmdi.I
VSmigrstfnrs.I
VSplnjntCmd.S
VSplnjntCmdi.I
VSplnjntfrm.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vscmd.o
#else
$(STRUCT)/lib/vscmd.o
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
$(VDS)/include/vdinclude
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
CLIX SYSV BSD ENV5 LITTLE_ENDIAN

CC
acc -ansi -O3
