
/* $Id: VCCmdCCN.h,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCCmdCCN.h
 *
 * Description:
 *
 *      Gadgets for VCCableCon form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmdCCN.h,v $
 *      Revision 1.2  2002/05/08 15:48:24  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.2  1997/07/31  19:44:08  pinnacle
 * Replaced: vcinclude/VCCmdCCN.h for:  by hverstee for cabling
 *
 * Revision 1.1  1997/07/25  18:10:48  pinnacle
 * Created: vcinclude/VCCmdCCN.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *
 *************************************************************************/

#ifndef	VCCmdCCN_include

#define	VCCmdCCN_include

#define VC_CCON_GDG_CABTAG                           16
#define VC_CCON_GDG_CABTYP                           29

#define VC_CCON_GDG_TMATAG                           20
#define VC_CCON_GDG_TMBTAG                           21

#define VC_CCON_GDG_TMATYP                           22
#define VC_CCON_GDG_TMBTYP                           23

#define VC_CCON_GDG_EQATAG                           15
#define VC_CCON_GDG_EQBTAG                           26

#define VC_CCON_GDG_EQATYP                           30
#define VC_CCON_GDG_EQBTYP                           35

#define VC_CCON_GDG_MCF                              19

/*     columns of MCF         */

#define VC_CCON_COL_AMOD                               0
#define VC_CCON_COL_APOS                               1
#define VC_CCON_COL_LEAD                               2
#define VC_CCON_COL_BMOD                               3
#define VC_CCON_COL_BPOS                               4
#define VC_CCON_COL_SIG                                5
#define VC_CCON_COL_MARK                               6 

#endif
