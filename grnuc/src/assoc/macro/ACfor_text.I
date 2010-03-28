/*
  ACcpxi.I
  robert patience
  21_jul_86
*/

class implementation ACcpx;

#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "go.h"
#include "lcdef.h"
#include "grio.h"
#include "lc.h"
#include "grownerdef.h"
#include "nddef.h"
#include "ndmacros.h"


#define LOCATE_FOR_TEXT 0x1000

#define AS_DEBUG 1

/*
   Method overriden to make text component eligible for edit text.
   A cleaner solution would have been to only override get_locate_properties.
   But the GRlc_cvl structure containing the information about the purpose
   of the locate is not present in this message.
*/

method GRlocate_processing (IGRlong *msg; struct GRlc_cvl *cvl;
                            struct GRlc_path *path; IGRint *path_position;
                            IGRint *owner_eligible;
                            IGRint *component_eligible)
{
  IGRlong              om_msg;
  IGRint               properties;

  *msg = MSSUCC;

  /* Is the locate for edit text */

  if( cvl->attributes.obj_attr.owner_action & LOCATE_FOR_TEXT ) 
  {
    /*| component is eligible for edit text */
    properties =  GR_LC_CMP_READ     | GR_LC_CMP_WRITE     |
    		  GR_LC_CMP_PRM_READ | GR_LC_CMP_PRM_WRITE |
		  GR_LC_FLEXIBLE ;
  }
  else
  {
    /*| regular locate */
    om_msg = om$send(msg      = message GRowner.GRget_locate_properties
                                        (msg,&properties),
                     targetid = my_id);
  }
  
  /*| Perform the locate processing. */

  om_msg = GRowner_locate_processing 
           (msg,cvl, path,path_position,owner_eligible,component_eligible,
            my_id,OM_Gw_current_OS,properties);

  return(om_msg);

}


/*
   Message send to the owner at the end of an edit text command
   We need to recompute the ACcpx and its dependency
*/

method GRxform_owner (IGRlong *msg; struct GRmd_env *md_env;
                      IGRshort *matrix_type; IGRmatrix matrix;
                      GRobjid *newobjid; IGRint *cont)
{
  struct GRid my_grid;
  IGRint cn_type;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  /*" objid = %d osnum = %d\n",my_grid.objid,my_grid.osnum */

  cn_type = ND_COMP;

  nd$wait_batch(type       = GR_GEOM_POSTED,
                l_object   = &my_grid,
                l_obj_info = &cn_type,
                nb_obj     = 1);

  return(OM_S_SUCCESS);

}


end implementation ACcpx;
