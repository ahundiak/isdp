/* $Id: VRPCCinfo.I,v 1.1.1.1 2001/01/04 21:13:05 cvs Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRPCCinfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPCCinfo.I,v $
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
# Revision 1.4  1996/01/17  19:30:26  pinnacle
# Replaced: vrprdcmp/VRPCCinfo.I for:  by r240_int for route240
#
# Revision 1.3  1995/12/17  18:06:50  pinnacle
# Replaced: ./vrprdcmp/VRPCCinfo.I for:  by azuurhou for route240
#
 *
 * History:
 *	12/17/95    adz		VDObjDef structure error.
 *	01/17/96    tlb		Add prototypes
 *
 ***************************************************************************/

class implementation VRPCComp;
#include	"vrdef.h"
#include	"VDmsg.h"
#include	"acrepdef.h"
#include	"vrtools_pto.h"

/***********************************************************************/

method VRGetDefName ( IGRlong	*msg; IGRchar *sMacroName )

{

  *msg = MSSUCC;

  strcpy ( sMacroName, "PPccdef" );

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

	return	OM_S_SUCCESS;
	
}/* end VRGetCatBehavior */

/*--------------------------------------------------------------------------*/
method VDgetObjDef( long *msg; VDobjDef *myDef )
{
  long	sts;


  myDef->info	= VD_I_ObjPipeComp ;
  myDef->type	= 0 ;

  sts		= OM_S_SUCCESS ;
  *msg		= MSSUCC ;

  return sts ;
}
/*--------------------------------------------------------------------------*/

end implementation VRPCComp;
