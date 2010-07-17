
/* $Id: vc_mtoflags.h,v 1.1.1.1 2001/01/04 21:12:10 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        include/vc_mtoflags.h
 *
 * Description:
 *
 *      Public Constants defined for consistent MTO flags...
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vc_mtoflags.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:10  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  04:56:36  pinnacle
 * Created: include/vc_mtoflags.h by impd for route
 *
 * Revision 1.1  1997/07/14  21:05:40  pinnacle
 * Created: include/vc_mtoflags.h by hverstee for cabling
 *
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *
 *************************************************************************/

#ifndef	vc_mtoflags_include
#define vc_mtoflags_include

/*     seen that there are some miscommunications about the
       character based MTO (or NO_MTO) flag the values are
       externalized here                                       */

#define     VC_MTOFLAG_INCLUDE        "y"     /*   include on BOM   */
#define     VC_MTOFLAG_EXCLUDE        "n"     /*   exclude from BOM */

#endif

