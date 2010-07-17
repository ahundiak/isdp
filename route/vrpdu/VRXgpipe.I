
/* $Id: VRXgpipe.I,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRXgpipe.I
 *
 * Description:
 *	Access VDS database for piping component codes    
 *        (Replaces VRgetpipe.c)
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRXgpipe.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:42:56  pinnacle
# Created: vrpdu/VRXgpipe.I by hverstee for route
#
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include "igrtypedef.h"
#include "msdef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRDbTbl.h"
#include "VRDbCache.h"

#include "vrpdu_pto.h"

#include "VRPDBdef.h"
#include "VRPDBmac.h"

/*
#define MY_DEBUG
*/

int get_piping_br_comp_code (char    *spec_name,/* spec name                 */
                             double   siz_1,    /* npd 1 - green dia         */
                             double   siz_2,    /* npd 2 - red dia           */
                             double   angle,    /* branch angle              */
                             char    *comp_code,/* AABBCC code of the branch */
                             char    *err_ptr)  /* Error Message buffer      */

{
/***************************************************************************/
/*                                                                         */
/* This routine extracts the AABBCC code of the branch whose spec name     */
/* size 1, size 2 and angle have been specified.                           */
/*                                                                         */
/***************************************************************************/

       IGRlong   retmsg;
       IGRshort  snum;
       IGRchar   *ep;

       ep = err_ptr;    /*   get rid of warning   */

       VR$PDB_SNUM (p_nam = spec_name,
                    p_num = &snum);

       VR$PDB_BRAN (p_msg = &retmsg,
                    spec  = snum,
                    angle = angle,
                    dia1  = siz_1,
                    dia2  = siz_2,
                    p_code = comp_code);

       if (retmsg != MSSUCC) return (0);

     return(1);
}


int get_adapter (char   *spec_name,  /* spec name              */
                 int     prep_1,     /* first end prep         */
                 int     prep_2,     /* second end prep        */
                 char   *comp_code,  /* AABBCC code of adapter */
                 char   *err_ptr)    /* Error message buffer   */

{
/**************************************************************************/
/*                                                                        */
/* This routine extracts default adapter AABBCC code for piping from      */
/* reference database.                                                    */
/*                                                                        */
/**************************************************************************/

  /*    this is not called anywhere ..................   */

  /*    just get rid of warnings    */

       char    *AA;
       int      II;

       AA = spec_name;
       AA = comp_code;
       AA = err_ptr;

       II = prep_1;
       II = prep_2;

       return(1);
}

end implementation Root;
