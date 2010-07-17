/*
     CLASS  NAME: VRHanger
     METHOD NAMES: 

	* 09-DEC-91	1.4.3.14	
		Bruno
		- VRInitInstances method has been removed.
		- VRSetInstances now does the ACset_db_info.

***********************************************************************/

class implementation VRHanger;


#define AS_DEBUG

#include "nddef.h"
#include "ndmacros.h"
#include "ACcheckin.h"
#include "ACdb_info.h"

/**********************************************************************/

method NDmove_to_root (IGRlong *msg; struct GRid *src_grid;
			struct GRmd_env *md_env)
{

IGRint		cn_type;
struct GRid	MyId;

*msg = MSSUCC;

/* -- Delete via batch -- */
MyId.objid = my_id;
MyId.osnum = OM_Gw_current_OS;
cn_type    = ND_COMP;

nd$wait_batch( type       = GR_DELETED, 
		l_object   = &MyId,
		l_obj_info = &cn_type,
		nb_obj     = 1 );

return OM_S_SUCCESS;

} /* end method NDmove_to_root */

/***********************************************************************/

method VRSetInstance ( IGRlong	*msg; struct VRGenInfo *Instance )

{
	register IGRint  i;
	IGRint status;

*msg = MSSUCC;

/*| -- Init super class instance -- */
status =om$send (
	msg 	= message VRGeneric.VRSetInstance
			(msg, Instance),
	mode    = OM_e_wrt_message,
	targetid= my_id );
as$status ();

	/* -- Set status for checkin -- */

	{
		IGRlong			retmsg;
		struct ACdb_info	DbInfo;

		DbInfo.quantity = PIPE_SUPP_OBJ;
		status = om$send(msg = message ACdb_info.ACset_db_info
						( &retmsg, &DbInfo),
			targetid = my_id);
		as$status();


	}

/*| -- Set status to BUILT_IN -- */
status =
om$send ( msg = message VRGeneric.VRSetStatus 
		(msg, 	(IGRshort)VR_BUILT_IN,
			(IGRshort)VR_BUILT_IN),
	targetid = my_id );
as$status ();

/*| Store support datapoint orientation */
for (i=0;i<3;i++)
    me->dOrientation [i] = Instance->Attr.Supp.dOrientation[i];

/*| Store Support relative factor */
me->dFactor = Instance->Attr.Supp.dFactor;

/*| Store Hanger tagVRSupAttr structure instances */
me->VRSupAttr	= Instance->VRSupAttr;

/*^
printf ("Values put in Support instance\n");
printf ("dOrientation = (%lf,%lf,%lf)\ndFactor = %lf\n",
	me->dOrientation [0], me->dOrientation [1], me->dOrientation [2],
			me->dFactor);
*/

return ( OM_S_SUCCESS );

}/* end method VRSetInstance */

end implementation VRHanger;
