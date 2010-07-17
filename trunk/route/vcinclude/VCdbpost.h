
/* $Id: VCdbpost.h,v 1.1.1.1 2001/01/04 21:12:34 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCdbpost.h
 *
 * Description:
 *
 *      Structures defined for VC cabling system (database post)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCdbpost.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/01/28  20:10:14  pinnacle
 * Replaced: vcinclude/VCdbpost.h for:  by lawaddel for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.3  1997/10/24  12:54:42  pinnacle
 * Replaced: vcinclude/VCdbpost.h for:  by apazhani for cabling
 *
 * Revision 1.2  1997/10/14  05:50:50  pinnacle
 * Replaced: vcinclude/VCdbpost.h for:  by apazhani for cabling
 *
 * Revision 1.1  1996/11/01  21:17:28  pinnacle
 * Created: vcinclude/VCdbpost.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *      10/14/97    Alwin       Increased the "VC_DYN_FTO_NUM", from 13 to 17.
 *                              B'cas of the addition of the first four fields.
 *                              "comp_seqno, assembly_cat, assembly_nam, 
 *                               assembly_ver".
 *      10/24/97    Alwin       Increased the "VC_DYN_FTO_NUM", from 17 to 19.
 *                              As Clark wanted to add two more attributes 
 *                              called "fromcino and tocino"
 *      01/05/99    law         increased VC_DYN_FTO_NUM to 33-CR179802489
 *************************************************************************/

#ifndef VCdbpost_include
#define VCdbpost_include

/*     table names      */

#define VC_DYN_EL_FTO     "vcsch_elead"
#define VC_DYN_FO_FTO     "vcsch_flead"

#define VC_DYN_FTO_NUM    33        /* CR179802489 */

#endif

