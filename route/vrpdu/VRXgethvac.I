
/* $Id: VRXgethvac.I,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRgethvac.c
 *
 * Description:
 *	Access VDS database for hvac component codes
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRXgethvac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:42:48  pinnacle
# Created: vrpdu/VRXgethvac.I by hverstee for route
#
 * Revision 1.1  1996/04/22  15:01:40  pinnacle
 * Created: vrpdu/VRgethvac.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:31:52  pinnacle
 * Replaced: vrpdu/gethvac.c for:  by r240_int for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include "msdef.h"
#include "igrtypedef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRHDBdef.h"
#include "VRHDBmac.h"

#include "vrpdu_pto.h"

int get_hvac_br_comp_code (

   char     *class,          /* hvac class name             */
   double   angle,           /* branch angle                */
   char     *comp_code,      /* AABBCC code of the branch   */
   char     *err_ptr)        /* Error message buffer        */

{
/***************************************************************************/
/*                                                                         */
/* This routine extracts the AABBCC code of the branch whose class name    */
/*  and angle have been specified.                                         */
/*                                                                         */
/***************************************************************************/

  IGRlong   retmsg;
  IGRshort  snum;
  IGRchar   *ep;

  ep = err_ptr;    /*   get rid of warning   */

  VR$HDB_SNUM (p_nam = class,
               p_num = &snum);

  VR$HDB_BRAN (p_msg = &retmsg,
               spec  = snum,
               angle = angle,
               ctype = 0,
               width1 = 0.0,
               depth1 = 0.0,
               width2 = 0.0,
               depth2 = 0.0,
               p_code = comp_code);

  if (retmsg != MSSUCC) return (0);

  return(1);
}


int get_transition (
    
    char    *class,        /* hvac class                */
    int     shape_code,    /* code for end shapes       */
    char    *comp_code,    /* AABBCC code of transition */
    char    *err_ptr)      /* Error message buffer      */
{
/**************************************************************************/
/*                                                                        */
/* This routine extracts the default transition component AABBCC code     */
/* from the reference database.                                           */
/*                                                                        */
/**************************************************************************/

  IGRlong   retmsg;
  IGRshort  snum;
  IGRchar   *ep;

  ep = err_ptr;    /*   get rid of warning   */

  VR$HDB_SNUM (p_nam = class,
               p_num = &snum);

  VR$HDB_TRAN (p_msg = &retmsg,
               spec  = snum,
               ttype = 0,
               scode = shape_code,
               width = 0.0,
               depth = 0.0,
               p_code = comp_code);

  if (retmsg != MSSUCC) return (0);

  return(1);
}


end implementation Root;

