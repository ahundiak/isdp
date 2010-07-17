/* $Id: VRRCinfo.I,v 1.3 2001/02/20 01:16:49 build Exp $  */

/******************************************************************
 * Product:   	I/ROUTE
 *
 * File:        vrprdcmp/VRRCinfo.I
 *
 * Description:
 *      This file contains the implemention for all overriden 
 *      messages
 *
 * Revision History:
 *	$Log: VRRCinfo.I,v $
 *	Revision 1.3  2001/02/20 01:16:49  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 17:53:09  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  00:02:46  pinnacle
# Created: route/vrprdcmp/VRRCinfo.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/03/27  20:03:08  pinnacle
# Replaced: vrprdcmp/VRRCinfo.I for:  by hverstee for route240
#
# Revision 1.5  1996/01/17  19:30:58  pinnacle
# Replaced: vrprdcmp/VRRCinfo.I for:  by r240_int for route240
#
 *
 * History:
 *        ???         ????            Creation
 *      09/29/94      Manyam            Override ACgive_structure
 *	01/17/96      tlb		Add prototypes
 **********************************************************************/
class implementation VRRComp;

#include "vrparameters.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "bstypes.h"
#include "bserr.h"
#include "VRdef.h"
#include "VDmsg.h"
#include "acrepdef.h"
#include "bslenvec.h"
#include "bsmkvec.h"
#include        "vrdbgmacros.h"

method      VRGetDefName ( IGRlong      *msg;
                           IGRchar      *sMacroName )
{

  SetProc( VRRCComp_VRGetDefName ); Begin
  *msg = MSSUCC;

  strcpy ( sMacroName, "RWccdef" );

  End
  return ( OM_S_SUCCESS );

}/* end method VRGetDefName */


/*--------------------------------------------------------------------------*/
method VDgetObjDef( long *msg; VDobjDef *myDef )
{
  long	sts;
  SetProc( VRRCComp_VDgetObjDef ); Begin

  myDef->info	= VD_I_ObjRwayComp ;
  myDef->type	= 0 ;

  sts		= OM_S_SUCCESS ;
  *msg		= MSSUCC ;

  End
  return sts ;
}
/*--------------------------------------------------------------------------*/

end implementation VRRComp;
