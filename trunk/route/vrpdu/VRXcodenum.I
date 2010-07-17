
/* $Id: VRXcodenum.I,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRXcodenum.I
 *
 * Description:
 *              (replaces VRgcodenum.c)
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRXcodenum.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:42:40  pinnacle
# Created: vrpdu/VRXcodenum.I by hverstee for route
#
 *
 * History:
 *	01/17/96  tlb		Add prototypes,
 *				Change VRget_code_num to ANSII style
 *      02/28/1997 yzhu         CR179528329
 *
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "VRdef.h"
#include "VRDbStruct.h"
#include "dberror.h"
#include "VRmsg.h"
#include "VRDbTbl.h"
#include "vrpdu_pto.h"

#include "VRPDBdef.h"
#include "VRPDBmac.h"
#include "VRHDBdef.h"
#include "VRHDBmac.h"
#include "VRRDBdef.h"
#include "VRRDBmac.h"

/*
#define   MY_DEBUG
*/

/*********************************************************************/
/*                                                                   */
/* This routine extracts the code number for a given short_text of   */
/* a given code list number.                                         */
/*                                                                   */
/*********************************************************************/       
IGRint VRget_code_num ( 
      IGRlong     *msg,        /* Message                               (O) */
      IGRshort    application, /* VDS,Piping,HVAC,Cabling or Struct     (I) */
      IGRshort    list_num,    /* Codelist number                       (I) */
      IGRchar     *short_text, /* Short text for which code_num is reqd (I) */
      IGRshort    *code_num,   /* Code number                           (O) */
      IGRchar     *err_ptr     /* Error message buffer                  (O) */
	)
{

  IGRchar      *ep;

  IGRchar       XX[30];

  ep = err_ptr;       /*   get rid of warning   */

   switch ( application )
   {
	case VR_PIPING :
           if (strcmp( short_text, "<blank>") == 0 )
             strcpy (XX, " ");
           else
             strcpy (XX, short_text);

           VR$PDB_CDLNUM (p_msg = msg,
                          nlist = list_num,
                          p_txt = XX,
                          p_num = code_num);

           break;

	case VR_HVAC :
           VR$HDB_CDLNUM (p_msg = msg,
                          nlist = list_num,
                          p_txt = short_text,
                          p_num = code_num);
           break;

	case VR_CABLING :
           VR$RDB_CDLNUM (p_msg = msg,
                          nlist = list_num,
                          p_txt = short_text,
                          p_num = code_num);
           break;

	default : return OM_E_INVARG;

   }/* end set table name based on product */

   return(OM_S_SUCCESS);
}
end implementation Root;

