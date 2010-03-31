/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"

method EMrefine_points( IGRlong *EMmsg;
			struct EMSdataselect *surf_data[3];
			struct GRmdenv_info  *env[3];
			struct EMSpartolbasis *tol[3];
			IGRdouble	      *uv_approx[3], 
					      *xyz_int_approx, 
					      *uv_exact[3], 
					      *xyz_int_exact;
			struct EMSsfintedpar  *my_edpar, *comm_edpar;
			IGRboolean	      *me_refined, *comm_refined, 
					      *me_hole, *comm_hole;
			struct EMSpartedinfo  *part)
{
  OM_S_CHANSELECT		to_edge;
  IGRlong			sts;

  to_edge.type = OM_e_addr;
  to_edge.u_sel.addr = &ME.EMSbd_owner->to_comps;

  if(part)
    sts = om$send(msg = OPPmargs, p_chanselect = &to_edge);
  else
   {
     struct EMSpartedinfo my_info;
     EMput_partinfo (my_info);
     sts = om$send(msg = message EMSedge.EMrefine_points
			(EMmsg, surf_data, env, tol, uv_approx, xyz_int_approx,
			 uv_exact, xyz_int_exact, my_edpar, comm_edpar, 
			 me_refined, comm_refined, me_hole, comm_hole, 
			 &my_info), 
			p_chanselect = &to_edge);
   }
  return(sts);
}

end implementation EMSpartedge;
