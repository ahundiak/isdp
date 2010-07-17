class implementation VRcopy;


#include "VRdimdef.h"
#include "VRcompdef.h"
#include "BGerrordef.h"

#define AS_DEBUG

from	NDnode		import	ASreturn_go;
from 	VRGeneric	import	VRGetStatus, VRGetPlanes;
from	VRNozzle	import	VRGetRefId;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function VRadd_momo                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRadd_plane(p_object, p_info)
  
  struct GRid     *p_object;  /* IN     Object to inquire                    */
  struct VRgrinfo *p_info;    /* IN     Pointer to the information            */

  /*.VRadd_plane*/
  {
  /*
  Description : add the planes of the components to the list p_info->padd
  Constraint  : none.
  */ 
  short        cmp_type;       /* Component type                              */
  long         msg;            /* Status returned by a message                */
  int          status;         /* Status returned by the om                   */
  int          index ;         /* Index for a loop                            */
  int          nb_plane;       /* Number of planes to recompute               */
  GRclassid    obj_classid;
  struct GRid  l_plane [3*VR_MAX_CPTS];
			       /* Plane list to add in the batch              */

  extern GRclassid OPP_VRNozzle_class_id;

  status = om$send
             (msg = message VRGeneric.VRGetStatus(&msg,&cmp_type),
              senderid = NULL_OBJID,
              targetid = p_object->objid,
              targetos = p_object->osnum);
  gm$status(test = !((status&1)&&(msg&1)) );

  /*" status(%d.%d) = %d\n",p_object->objid,p_object->osnum,cmp_type*/

  if(!(cmp_type & VR_CORRECTION))
  {
    status = om$send
             (msg = message VRGeneric.VRGetPlanes
             (&msg,3*VR_MAX_CPTS,l_plane,&nb_plane,(struct GRmd_env *)p_info->p_md_env),
              senderid = NULL_OBJID,
              targetid = p_object->objid,
              targetos = p_object->osnum);
    gm$status(test = !((status&1)&&(msg&1)));

    for(index=0; index<nb_plane; index++)
    {
      if( l_plane[index].objid != NULL_OBJID )
      {
      	/*"Add the plane %d.%d in the list\n",l_plane[index].objid,l_plane[index].osnum */

      	GMl_add(&l_plane[index],p_info->p_add);
      }
    }/* end for */

    om$get_classid( objid     = p_object->objid,
		    osnum     = p_object->osnum,
                    p_classid = &obj_classid );

    if(om$is_ancestry_valid( subclassid   = obj_classid,
                             superclassid = OPP_VRNozzle_class_id) == OM_S_SUCCESS)
    {
        /*| given component is a nozzle ==> add the ref. in the list */
	status = om$send( msg      = message VRNozzle.VRGetRefId
						( &msg, &l_plane[0] ),
			  senderid = NULL_OBJID,
			  targetid = p_object->objid,
			  targetos = p_object->osnum );
	gm$status();

	/*"refid = %d\n", l_plane[0].objid */

        if( l_plane[0].objid != NULL_OBJID )
      	{
      		/*"Add nozzle ref %d.%d in the list\n", l_plane[0].objid,l_plane[0].osnum */

      		GMl_add( &l_plane[0], p_info->p_add );
      	}
    }
  }

exception:
  return(status);

}

end implementation VRcopy;
