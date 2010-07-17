
/* $Id: VCCmdStr.h,v 1.1.1.1 2001/01/04 21:12:34 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCCmdStr.h
 *
 * Description:
 *
 *      Constants and structures defined for VC cabling system commands
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmdStr.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.5  1997/05/19  19:47:58  pinnacle
 * Replaced: vcinclude/VCCmdStr.h for:  by hverstee for cabling
 *
 * Revision 1.4  1997/05/19  12:58:36  pinnacle
 * Replaced: vcinclude/VCCmdStr.h for:  by hverstee for cabling
 *
 * Revision 1.3  1997/03/05  14:39:18  pinnacle
 * Replaced: vcinclude/VCCmdStr.h for:  by hverstee for cabling
 *
 * Revision 1.2  1997/01/20  20:09:52  pinnacle
 * Replaced: vcinclude/VCCmdStr.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:44:14  pinnacle
 * Created: vcinclude/VCCmdStr.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *
 *************************************************************************/

#ifndef	vc_cmdstr_include
#define vc_cmdstr_include

/*     structures for dynamics     */

struct VCmlcndyn_info
{
  IGRint                dynamics; /* type of dynamics in state tbl      */
  IGRboolean            bDEPTH;
  IGRboolean            bORTHO;
  IGRboolean            bGOING;
  IGRdouble             dLL[3];
  IGRint                numbuff;  /* actual number of buffers           */
  struct DPele_header   dpele_buff[100];
};

struct VCVX_detent
{
  IGRint                nDigit;
  IGRint                NumCorners;
  IGRdouble             dCorners[18];
  IGRdouble             dDist;
};

struct VCmlmoddyn_info
{
  IGRint                dynamics; /* type of dynamics in state tbl */
  IGRint                dy_index;
  IGRdouble             dy_value;
  struct VCVX_detent    Detent;
  struct DPele_header   dpele_buff;
};

/*     prototype for detent function   */

extern
IGRint VC_detent    __((IGRdouble      *dPTin,
                 struct VCVX_detent    *pDet,
                        IGRdouble      *dPTout));

#endif
