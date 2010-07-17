/* $Id: VRRCCinfo.I,v 1.3 2001/02/20 01:16:47 build Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRRCCinfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRRCCinfo.I,v $
 *	Revision 1.3  2001/02/20 01:16:47  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 17:53:07  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  00:02:32  pinnacle
# Created: route/vrprdcmp/VRRCCinfo.I by lawaddel for Service Pack
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
# Revision 1.3  1995/12/17  18:08:20  pinnacle
# Replaced: ./vrprdcmp/VRRCCinfo.I for:  by azuurhou for route240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/17/95	adz		VDObjDef structure error.
 *
 ***************************************************************************/
class implementation VRRCComp;

#include "VDmsg.h"
#include        "vrdbgmacros.h"

/***********************************************************************/

method VRGetDefName ( IGRlong	*msg; IGRchar *sMacroName )

{
  SetProc( VRRCComp_VRGetDefName ); Begin
  *msg = MSSUCC;

  strcpy ( sMacroName, "RWccdef" );

  End
  return ( OM_S_SUCCESS );

}/* end method VRGetDefName */

/***********************************************************************/
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
/***********************************************************************/

end implementation VRRCComp;
