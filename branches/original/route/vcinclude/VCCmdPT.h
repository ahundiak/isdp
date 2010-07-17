
/* $Id: VCCmdPT.h,v 1.1.1.1 2001/01/04 21:12:34 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCCmdPT.h
 *
 * Description:
 *
 *      Constants and structures defined for VC cabling system commands
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmdPT.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.2  1997/01/20  20:10:10  pinnacle
 * Replaced: vcinclude/VCCmdPT.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/09/25  15:48:00  pinnacle
 * Created: vcinclude/VCCmdPT.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *
 *************************************************************************/

#ifndef	VCCmdPT_include

#define	VCCmdPT_include

/*C	forms indexes	*/

/* parameters form is status form */
#define VCC_PT_CONTROL_FORM             0
#define VCC_PT_USR_ATTR_FORM            1

/*    VCPtrm control form           */

#define VCPTRM_FORMNAME               "VCPtrm"

#define VCPTRM_FIBHEAD                          11
#define VCPTRM_ELHEAD                           17
#define VCPTRM_OFFSET                           16
#define VCPTRM_ORIENT                           18
#define VCPTRM_COMPCODE                         25
#define VCPTRM_TAGNO                            26

/*    add terminal event codes    */

#define VCT_EMPTY_STACK                  500
#define VCT_OFFSET                       501
#define VCT_ORIENT                       502

#endif
