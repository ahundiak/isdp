
/*
    ASpoint implementation file

    HISTORY :   momo       06-fev-89  : Design data
*/

class implementation ASpoint;


#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "asbox.h"
#include "asdef.h"
#include "nddef.h"

#define AS_DEBUG

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                             ASpoststr method

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ASpoststr(IGRlong *msg; struct GRmd_env *md_env; 
                  struct GRpost_info *info; IGRshort nb_obj; IGRchar **str; 
		  struct GRid *newobjid)
{
  IGRint 		status;
  struct ret_struct	*pointdef;
  struct IGRpolyline	polyline;


  pointdef = (struct ret_struct *) *str;

  info->construct_flag = FALSE;

  polyline.num_points = 1;
  polyline.points = pointdef->var.point_st.pt;

  status = om$send(msg          = message GRlinear.GRputpolyline
		                  (msg,md_env,info,&polyline,&newobjid->objid),
	           p_chanselect = &AS_to_comp );
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
 
}

end implementation ASpoint;
