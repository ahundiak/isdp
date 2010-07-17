
/* $Id: VRXgetrway.I,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRgetrway.c
 *
 * Description:
 * 	Access VDS database for rway component codes             *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRXgetrway.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:42:52  pinnacle
# Created: vrpdu/VRXgetrway.I by hverstee for route
#
 * Revision 1.1  1996/04/22  15:02:52  pinnacle
 * Created: vrpdu/VRgetrway.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:32:06  pinnacle
 * Replaced: vrpdu/getrway.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/

class implementation Root;

#include	<stdio.h>
#include        "msdef.h"
#include        "VRDbStruct.h"
#include        "VRmsg.h"
#include        "VRDbTbl.h"
#include        "VRDbCache.h"

#include "VRRDBdef.h"
#include "VRRDBmac.h"

#include 	"vrpdu_pto.h"

int get_rway_br_comp_code (

   char     *vendor_code,    /* vendor catalog code         */
   double   angle,           /* branch angle                */
   int      comp_type,       /* component type              */
                             /* 0 = horiz, 1 = vert,        */
                             /* 2 = reduc h, 3 = reduc v    */
   char     *comp_code,      /* AABBCC code of the branch   */
   char     *err_ptr)        /* Error message               */

{
/***************************************************************************/
/*                                                                         */
/* This routine extracts the AABBCC code of the branch whose vendor catalog*/
/* code,angle and component type have been specified.                      */
/*                                                                         */
/***************************************************************************/

  IGRlong   retmsg;
  IGRshort  snum;
  IGRchar   *ep;

  ep = err_ptr;    /*   get rid of warning   */

  VR$RDB_SNUM (p_nam = vendor_code,
               p_num = &snum);

  VR$RDB_BRAN (p_msg = &retmsg,
               spec  = snum,
               angle = angle,
               ctype = comp_type,
               width1 = 0.0,
               depth1 = 0.0,
               width2 = 0.0,
               depth2 = 0.0,
               p_code = comp_code);

  if (retmsg != MSSUCC) return (0);

  return(1);
}

end implementation Root;

