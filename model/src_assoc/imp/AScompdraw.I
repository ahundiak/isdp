class implementation ASplancompcv;

#include "AS_status.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "godef.h"
#include "asbox.h"
#define AS_DEBUG

extern IGRboolean ASbroadcast_in_progress;

method NDdrawing_copy_geom
		(struct GRid *selected_elements;
		 int 	nb_elements;
		 struct GRid **drawing_elements;
		 int    *nb_drawing_elem;
		 double *vector,*point;
		 int *level;  struct IGRlbsys *lbsys;
		 struct GRmd_env *from_env,*to_env)
{
 long status,msg;
 IGRboolean save_br;
 double cs,fabs();
 double pt_info[6];
 struct IGRplane my_plane;
IGRlong		sts;
IGRint		disp_state;
 struct GRsymbology my_symb;

 status = OM_S_SUCCESS;
 *nb_drawing_elem = 0;

 /* check my level */

 status = om$send(msg = message GRvg.GRgetsymb(&msg,&my_symb),
		  targetid = my_id);
 as$status(action = RET_STATUS);
 if(!(DPlevel_check(my_symb.level,level))) return OM_S_SUCCESS;
 



	sts = om$send(	msg	 = message ASplancompcv.ASis_visible(
					&msg,
					&from_env->md_env.matrix_type,
					from_env->md_env.matrix,
					vector,
					&disp_state ),
			targetid = my_id );
	as$status( sts = sts );
					
	if( ! (disp_state&1))	return	OM_S_SUCCESS;

/* now copy */

 *drawing_elements = (struct GRid *) om$malloc (size = sizeof(struct GRid));
 *nb_drawing_elem = 1;
 save_br = ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;
 status = om$send(msg = message NDnode.NDcopy_to_root(&msg,0,from_env,to_env,
						      *drawing_elements),
		  targetid = my_id);
 if(status&msg&1)
  {
   *nb_drawing_elem = 1;
   om$change_class(objid = (*drawing_elements)[0].objid,
		   osnum = (*drawing_elements)[0].osnum,
		   classname = "AScompcurve");
  }
 ASbroadcast_in_progress = save_br;

 return status;
}

end implementation ASplancompcv;
