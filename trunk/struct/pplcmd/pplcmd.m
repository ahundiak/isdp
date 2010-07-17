/* $Id: pplcmd.m,v 1.18 2002/05/01 19:45:33 ahundiak Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	pplcmd/pplcmd.m
 *
 * Description:
 *	COmpilation support file.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: pplcmd.m,v $
 *	Revision 1.18  2002/05/01 19:45:33  ahundiak
 *	ah
 *	
 *	Revision 1.17  2002/03/11 19:14:37  ramarao
 *	Implemented CR# 6121.
 *	
 *	Revision 1.16  2001/11/08 14:13:47  ramarao
 *	Removed COz_cpPl.u ppl.
 *	
 *	Revision 1.15  2001/10/22 22:59:06  ramarao
 *	Fixed TR# 5663.
 *	
 *	Revision 1.14  2001/08/18 18:30:08  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.13  2001/07/31 22:32:19  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.12  2001/07/30 20:49:38  ramarao
 *	Implemented CR# 5411.
 *	
 *	Revision 1.11  2001/07/28 19:37:11  ramarao
 *	Implemented CR# 5411.
 *	
 *	Revision 1.10  2001/07/05 21:48:04  ramarao
 *	Created COz_cpPl.u ppl.
 *	
 *	Revision 1.9  2001/06/08 21:24:03  ad
 *	fix for TR# MP5292
 *	
 *	Revision 1.8  2001/05/08 14:55:37  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.7  2001/05/08 14:49:14  ramarao
 *	Added COz_valPen.u file.
 *	
 *	Revision 1.6  2001/05/03 13:03:16  ramarao
 *	Added a ppl ( COz_cmpPen.u ) to control the recompute of the penetration macros.
 *	
 *	Revision 1.5  2001/02/28 23:28:53  ramarao
 *	Profile Card Validation Routines.
 *	
 *	Revision 1.4  2001/02/27 15:32:17  ramarao
 *	Fixed TR# 3056.
 *	
 *	Revision 1.3  2001/02/25 19:18:12  ramarao
 *	Created "Review Structural Objects" command.
 *	
 *	Revision 1.2  2001/01/17 15:06:49  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:10:02  cvs
 *	Initial import to CVS
 *	
# Revision 1.7  2000/03/01  21:07:42  pinnacle
# track point for VSsplPlate
#
# Revision 1.6  2000/02/17  16:52:08  pinnacle
# (No comment)
#
# Revision 1.5  2000/02/05  13:57:50  pinnacle
# Replaced: pplcmd/pplcmd.m for:  by impd252 for struct
#
# Revision 1.4  1999/04/26  21:01:52  pinnacle
# ah
#
# Revision 1.3  1999/04/10  15:12:24  pinnacle
# Remove Plate Operators
#
# Revision 1.2  1999/04/09  20:40:16  pinnacle
# CR_179900195
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.10  1998/03/26  21:19:40  pinnacle
# Replaced: pplcmd/pplcmd.m for:  by azuurhou for struct
#
# Revision 1.9  1998/03/22  13:53:18  pinnacle
# CR179800676
#
# Revision 1.8  1998/03/06  19:56:52  pinnacle
# CR179800790
#
# Revision 1.7  1998/01/05  20:25:14  pinnacle
# Replaced: pplcmd/pplcmd.m for:  by s250_int for struct
#
# Revision 1.6  1997/09/26  19:38:16  pinnacle
# CR179700200
#
# Revision 1.4  1997/09/26  18:27:06  pinnacle
# CR179700200
#
# Revision 1.3  1997/09/22  17:28:34  pinnacle
# Add File.
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 01/01/97  i-struct  creation date
 * 09/22/97  adz       Add COz_selector Command Object.
 * 09/26/97  ah	       Add Var Bevel PPL
 * 01/05/97  adz       Add Checking options.
 * 03/06/98  ah        CR179800790 Unprotect struct directories
 * 03/22/98  ah        CR179800676 Modify Beam Axis
 *    ""               CR179800677 Set axis orientation
 * 03/26/98  adz	Add VSstfEndInfo.u for Stiffener End Treatments.
 * 04/09/99  ejm       CR_179900195: added COmodBevel.u
 * 04/10/99  ah        Added COrem_ops.u
 * 04/26/99  ah        Added VSmopPlate.u
 * 03/01/00  mf        Added VSmodSpPl.u (TR 179900881)
 ***************************************************************************/

CCIOPT  -Xnoptrchk -Xnoargchk -m -q 
#if ISDP_MAKE_SP
pla_cs2el.u
COz_cmpPen.u
COz_valPen.u
COz_coaming.u
COz_chkCut.u
COz_mulCut.u
COz_bbeam.u
CObaModify.u
COz_neatCon.u
COz_chkNtPl.u
#else
CObaModify.u
COmodBevel.u
COmodSpPl.u
COpla_cs2el.u
COrem_ops.u
COz_InvStrEl.u
COz_UnPro.u
COz_macroS.u
COz_selector.u
CS_by2elem.u
VSbaonoffCmd.u
VScpsfdep.u
VSdebug.u
VSgenlib.u
VSimonoffCmd.u
VSmdsfplCmd.u
VSmopPlate.u
VSopinmcCmd.u
VSpppPlPlate.u
VSps_plt.u
VSrevlib.u
VSstfEndInfo.u
VStrmigrCmd.u
VStrmigrFea.u
VSvar_bevel.u
pla_cs2el.u
COdelEdges.u
COornBeam.u
COz_pcmk.u
VSedgToBvl.u
VSmopBeam.u
COrevStrObj.u
COz_rtAxis.u
COz_fixAxis.u
COz_valPC.u
COz_cmpPen.u
COz_valPen.u
COz_coaming.u
COz_chkCut.u
COz_cpPl.u
COz_mulCut.u
COz_bbeam.u
COz_neatCon.u
COz_chkNtPl.u
VSppstock.u
#endif
