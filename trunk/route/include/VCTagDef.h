
/* $Id: VCTagDef.h,v 1.1.1.1 2001/01/04 21:12:08 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCTagDef.h
 *
 * Description:
 *
 *      Constants defined for tag numbers manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTagDef.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:08  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/11/28  22:38:10  pinnacle
 * Created: include/VCTagDef.h by r250_int for route
 *
 * Revision 1.1  1997/11/14  22:46:34  pinnacle
 * Created: include/VCTagDef.h by onayragu for cabling
 *
 * Revision 1.3  1997/01/20  20:09:08  pinnacle
 * Replaced: vcinclude/VCTagDef.h for:  by hverstee for cabling
 *
 * Revision 1.2  1996/09/20  21:14:54  pinnacle
 * Replaced: vcinclude/VCTagDef.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/30  17:34:12  pinnacle
 * Created: vcinclude/VCTagDef.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      08/27/96    hv          Initial
 *      11/10/97	Onay	Update values to take category into account.
 *
 *************************************************************************/

#ifndef	vc_TagDef_include
#define vc_TagDef_include

/*     Tag numbers control                           */

/*    To allow duplication of tag numbers change to distinct numbers  */

#define VCTAG_CAT_GENERAL    0
#define VCTAG_CAT_ELTERM     1
#define VCTAG_CAT_FOTERM     2
#define VCTAG_CAT_ELCABLE    3
#define VCTAG_CAT_FOCABLE    4
#define VCTAG_CAT_GUIDE      5

#endif

