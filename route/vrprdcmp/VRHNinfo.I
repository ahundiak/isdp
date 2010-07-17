/* $Id: VRHNinfo.I,v 1.2 2001/02/21 15:14:09 ramarao Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRHNinfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRHNinfo.I,v $
 *	Revision 1.2  2001/02/21 15:14:09  ramarao
 *	Fixed a crash.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:05  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1995/12/17  18:06:22  pinnacle
# Replaced: ./vrprdcmp/VRHNinfo.I for:  by azuurhou for route240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/17/95	adz		VDObjDef structure error.
 *	02/21/01	Rama Rao	Fix for a crash.
 ***************************************************************************/

class implementation VRHNozz;

#include "VRmsg.h"

/***********************************************************************/

method VRGetDefName ( IGRlong	*msg; IGRchar *sMacroName )

{

  *msg = MSSUCC;

  strcpy ( sMacroName, "HVcndef" );

  return ( OM_S_SUCCESS );

}/* end method VRGetDefName */

/***********************************************************************/
method VRGetModel ( IGRlong *msg; struct GRid *ModelId;
		    struct GRmd_env *md_env )
{

  *msg = MSSUCC;

  /* --- We have no cache and the macro name should be in the --- */
  /* --- System collection --- */


  ModelId->objid = NULL_OBJID;

  // Previously, it was ModelId->osnum = md_env->md_id.osnum.
  // Modified by Rama Rao

  if( md_env ) 	ModelId->osnum = md_env->md_id.osnum;
  else		ModelId->osnum = OM_Gw_current_OS;

  return ( OM_S_SUCCESS );

}/* end method VRGetModel */
/***********************************************************************/

/*--------------------------------------------------------------------------*/
method VDgetObjDef( long *msg; VDobjDef *myDef )
{
  long	sts;


  myDef->info	= VR_I_ObjHvacNozz ;
  myDef->type	= 0 ;

  sts		= OM_S_SUCCESS ;
  *msg		= MSSUCC ;

  return sts ;
}
/*--------------------------------------------------------------------------*/
end implementation VRHNozz;
