/* $Id: VRHCCinfo.I,v 1.3 2001/02/20 01:16:40 build Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRHCCinfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRHCCinfo.I,v $
 *	Revision 1.3  2001/02/20 01:16:40  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 17:52:13  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  00:01:44  pinnacle
# Created: route/vrprdcmp/VRHCCinfo.I by lawaddel for Service Pack
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
# Revision 1.4  1996/01/17  19:29:54  pinnacle
# Replaced: vrprdcmp/VRHCCinfo.I for:  by r240_int for route240
#
# Revision 1.3  1995/12/17  18:05:08  pinnacle
# Replaced: ./vrprdcmp/VRHCCinfo.I for:  by azuurhou for route240
#
 *
 * History:
 *      12/17/95        adz             VDObjDef structure error.
 *	01/17/96    tlb		Add prototypes
 *
 ***************************************************************************/

class implementation VRHCComp;

#include	"vrdef.h"
#include	"VDmsg.h"
#include	"acrepdef.h"
#include	"vrtools_pto.h"
#include        "vrdbgmacros.h"

/***********************************************************************/

method VRGetDefName ( IGRlong	*msg; IGRchar *sMacroName )

{

  SetProc( VRHCComp_VRGetDefName ); Begin
  *msg = MSSUCC;

  strcpy ( sMacroName, "HVccdef" );

  End
  return ( OM_S_SUCCESS );

}/* end method VRGetDefName */

/***********************************************************************/

method	VRGetCatBehavior(
	IGRlong		*msg ;		/* I/O - return status		*/
	IGRint		*Category;	/* O   - Category of the Cmp	*/
	IGRint		*Behavior	/* O   - Behavior of the Cmp	*/
)
{
	IGRint 			status = OM_S_SUCCESS;
	IGRlong			retmsg;

        SetProc( VRHCComp_VRGetCatBehavior ); Begin
	*msg = MSSUCC;
	
	if ( !Category && !Behavior )
		return	OM_S_SUCCESS;

	if ( Category )	*Category = -1;
	if ( Behavior ) *Behavior = 0;

	/*A get the behaviour type for this entity */
	status =
	VRdbGetCompCat( &retmsg, (IGRshort)VR_PIPING,
		me->szAABBCC, Category, Behavior,NULL );
	as$status( action = RETURN_STATUS );

	/*A no tag id management in 3D : Not yet implemented*/

        End
	return	OM_S_SUCCESS;
	
}/* end VRGetCatBehavior */

/*--------------------------------------------------------------------------*/
method VDgetObjDef( long *msg; VDobjDef *myDef )
{
  long	sts;

  SetProc( VRHCComp_VDgetObjDef ); Begin
  myDef->info	= VD_I_ObjHvacComp ;
  myDef->type	= 0 ;

  sts		= OM_S_SUCCESS ;
  *msg		= MSSUCC ;

  End
  return sts ;
}
/*--------------------------------------------------------------------------*/

end implementation VRHCComp;
