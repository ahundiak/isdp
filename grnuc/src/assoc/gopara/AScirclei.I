
/*
    AScircle implementation file

    HISTORY :   momo       06-fev-89  : Design data
*/

class implementation AScircle;


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
  IGRint 		i,status;
  struct IGRarc		arc;
  struct ret_struct	*cirdef;


  cirdef = (struct ret_struct *) *str;

  /* update the graphic associated object */

  arc.prim_axis   = cirdef->var.circle_st.rad;
  arc.sec_axis    = cirdef->var.circle_st.rad;
  arc.start_angle = cirdef->var.circle_st.start_angle;
  arc.sweep_angle = cirdef->var.circle_st.sweep_angle;

  for(i=0;i<3;i++)  arc.origin[i]     = cirdef->var.circle_st.cent_p[i];
  for(i=0;i<16;i++) arc.rot_matrix[i] = cirdef->var.circle_st.mat[i];
  
  info->construct_flag = FALSE;

  status = om$send( msg          = message GRconic.GRputarc
                                   (msg,md_env,info,&arc,&newobjid->objid),
                    p_chanselect = &AS_to_comp);

  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
 
}

end implementation AScircle;
