
/* $Id: VCMacLib.h,v 1.1.1.1 2001/01/04 21:12:34 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCMacLib.h
 *
 * Description:
 *
 *      Constants defining the VC system basic macro library
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCMacLib.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.3  1997/04/28  21:41:50  pinnacle
 * Replaced: vcinclude/VCMacLib.h for:  by hverstee for cabling
 *
 * Revision 1.2  1997/03/28  20:39:46  pinnacle
 * Replaced: vcinclude/VCMacLib.h for:  by hverstee for cabling
 *
 * Revision 1.1  1997/03/25  16:20:38  pinnacle
 * Created: vcinclude/VCMacLib.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *
 *************************************************************************/

#ifndef	VCMacLib_include
#define VCMacLib_include

/************************************************************************/
/***                 MACRO DEFINITION NAMES                           ***/
/************************************************************************/

#define  VC_MACDEF_TERM          "VCTermDef"
#define  VC_MACDEF_CABLE         "VCCableDef"
#define  VC_MACDEF_GUIDE         "VCGuideDef"

/************************************************************************/
/***                 DEFAULT MACRO LIBRARY                            ***/
/************************************************************************/

#define  VC_MACLIB_BASE          "VCBaseLib"

/*      old values, from route libs     */
/*
#define  VC_MACDEF_TERM          "ConnectDef"
#define  VC_MACDEF_CABLE         "ComCabDef"
#define  VC_MACDEF_GUIDE         "CableDef"
*/

/************************************************************************/
/***                 MACRO TEMPLATE/FEET DEFINITION NAMES             ***/
/************************************************************************/

#define VC_TFNAME_SYS       "syspara"
#define VC_TFNAME_USR       "usrpara"

#define VC_PID_SYM_TAB      "PID_SYM_CODE"

#endif

