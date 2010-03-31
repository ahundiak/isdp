/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION
===========
			
 	This method caps or patches composite surface anywhere and everywhere
	 possible. It first gets the connectable edges, calls EMedfindloop()
	 function to find the closed paths and the sequence of edges in this
	 path (cappable areas), with these paths it calls EMcappl() to gen-
	 erate the cap surface, make edge connections, check for coincidency,
	 orient normals for caps, make loop connections and orientations and
	 post the cap surfac face rule line table. After this it connects the
	 cap surfaces to the composite.


NOTES
=====
		
	This method returs EMS_S_Success iff capping results in a solid, there
	 are small modifications if capping is to act as patching ( patch as
	 many holes in the surface, composite, solid as possible ).


ARGUMENTS
=========
	
    VARIABLE				MODE	DESCRIPTION
    --------                ----    -----------

	EMmsg					Output  Method return status.
									1)EMS_S_Success, If all is well.
									2)EMS_E_SurfaceError, If 'EMgetedges'
										fails.
									3)EMS_E_EdgeError, If cap edges cannot
										be determined OR cap surface can't
										be formed out of cap edges.
									4)EMS_I_Closed, If surface is closed.
									5)EMS_E_DynamicMemoryAllocated, If
										Dynamic memory allocation fails.
									6)EMS_E_OMerror, If OM errors OR 'GRri
										gidconn' fails.
									7)EMS_E_NoSolution, If surface is 
										cappable, but capping fails to 
										form a solid.

	grmd_env				Input   Pointer to module info of the surface.

    construct_list			Input	Pointer to construct_list for const-
									 ructions.

	care_coincidency		Input	Boolean to perform or skip the check
									 for coincidency (coincident caps: cap
									 areas).


RETURN VALUE
============

HISTORY
=======
	
        pp              28-May-90       Made modifications to free
                                        the memory which was erstwhile not
                                        being freed.
	SAM		20-Oct-87	Creation.
*/

class implementation EMScompsurf;

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"
#include "bs.h"
#include "emsmacros.h"
#include "EMSopt.h"
#include "EMScap.h"
#include "EMSmsgdef.h"

#define  MAXINT		2000

method EMcap_comp(
  IGRlong *EMmsg; 					/* Error return code */
  struct GRmd_env *grmd_env;	/* My module info */
  struct GRvg_construct *construct_list;
  IGRboolean care_coincidency)
{
 struct		GRid			*comp_edges = NULL, my_grid;
 			GRobjid			*comp_surf_list = NULL;
			GRspacenum		our_os;
 struct		EMcap_ed_sf		*cap_eds =  NULL;

 IGRint						i, *comp_numed_list = NULL, comp_buf_size = 0,
							num_in_comp_list = 0, num_comp_edges = 0,
							num_caps = 0, *num_edges_in_cap = NULL,
							comp_list_size = 0, num_invalid_caps = 0,
							add_at_end = 5000;
IGRlong 					OM_stat;
IGRlong   mthd_stat;
IGRlong   EMedfindloop(),
							EMedcapplane();
 IGRboolean					*is_planar_cap = NULL, no_solid = FALSE;
 struct 	EMcap_plane		*cap_sf = NULL;
 IGRint ii;


 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 our_os = OM_Gw_current_OS;

 OM_stat = om$send (msg = message EMSsurface.EMgetedges(
						&mthd_stat, 
						EMS_OPT_CONNECTABLE,
						&comp_edges,
						&comp_buf_size,	
						&num_comp_edges,
						&comp_surf_list,
						&comp_numed_list,
						&comp_list_size,
						&num_in_comp_list),
			        targetid = my_id);
 EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

 EMerr_hndlr(!num_comp_edges, *EMmsg, EMS_I_Closed, wrapup);

 cap_eds = (struct EMcap_ed_sf *) om$malloc ( 
		 size = (unsigned) (num_comp_edges) * sizeof(struct EMcap_ed_sf));
 EMerr_hndlr(!cap_eds, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 for (ii=0;ii<num_comp_edges;ii++)
 {
  cap_eds[ii].ed_geoms.poles = NULL;
  cap_eds[ii].ed_geoms.knots = NULL;
  cap_eds[ii].ed_geoms.weights = NULL;
  cap_eds[ii].ed_geoms.bdrys = NULL;
 }

 OM_stat = EMedfindloop(&mthd_stat,
						&comp_edges,
						&num_comp_edges,
						comp_surf_list,
						comp_numed_list,
						num_in_comp_list,
						cap_eds,
						&num_caps,
						&num_edges_in_cap,
						&our_os);
 EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup);
	
 
 is_planar_cap = (IGRboolean *) om$malloc ( 
		 	size = (unsigned) (num_caps) * sizeof(IGRboolean));
 cap_sf        = (struct EMcap_plane *) om$malloc ( 
		 	size = (unsigned) (num_caps) * sizeof(struct EMcap_plane));
 EMerr_hndlr(! is_planar_cap || !cap_sf, 
			 *EMmsg,EMS_E_DynamicMemoryAllocated, wrapup);
 for (ii=0;ii<num_caps;ii++)
 {
  cap_sf[ii].plane.poles = NULL;
  cap_sf[ii].plane.u_knots = NULL;
  cap_sf[ii].plane.v_knots = NULL;
  cap_sf[ii].plane.weights = NULL;
 }

 OM_stat = EMedcapplane(&mthd_stat,
						cap_eds,
						num_caps,
						num_edges_in_cap,
						is_planar_cap,
						cap_sf,
						grmd_env,
						construct_list, 
						care_coincidency,
						&our_os);
 EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup);

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 for(i = 0; i <= num_caps -1; i++)
 {
  if(is_planar_cap[i])
  {
   OM_stat = om$send( msg = message GRconnector.GRrigidconn(
							&mthd_stat,
							&my_grid,
					    (IGRlong *) &add_at_end),
					  targetid = cap_sf[i].plane_id,
					  targetos = OM_Gw_current_OS);
   EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_OMerror, del_sf);
  }
  else
  {
	no_solid = TRUE;
	break;
  }
 }

del_sf:
 if( (*EMmsg == EMS_E_OMerror) || (no_solid == TRUE))
  {
	for(i = 0; i < num_caps; i++)
	{
	 OM_stat = om$send(msg = message GRgraphics.GRdelete(
							&mthd_stat,
							grmd_env),
					   targetid = cap_sf[i].plane_id,
					   targetos = OM_Gw_current_OS);
    }											
	*EMmsg = EMS_E_NoSolution;
  }

wrapup:
 if (comp_edges)       om$dealloc (ptr = comp_edges);
 if (comp_surf_list)   om$dealloc (ptr = comp_surf_list);
 if (comp_numed_list)  om$dealloc (ptr = comp_numed_list);
 if (cap_eds)
 {
  struct IGRbsp_curve *crv;

   for (ii=0;ii<num_comp_edges;ii++)
   {
    crv = &(cap_eds[ii].ed_geoms);
    if (crv->poles) om$dealloc(ptr = crv->poles);
    if (crv->knots) om$dealloc(ptr = crv->knots);
    if (crv->weights) om$dealloc(ptr = crv->weights);
  }
 }

 if (cap_eds) 		   om$dealloc (ptr = cap_eds);
 if (cap_sf)
 {
  for (ii=0;ii<num_caps;ii++)
  {
    if (cap_sf[ii].plane.poles) om$dealloc (ptr = cap_sf[ii].plane.poles);
    if (cap_sf[ii].plane.u_knots) om$dealloc (ptr = cap_sf[ii].plane.u_knots);
    if (cap_sf[ii].plane.v_knots) om$dealloc (ptr = cap_sf[ii].plane.v_knots);
  }
 }
 if (cap_sf)	 	   om$dealloc (ptr = cap_sf);
 if (is_planar_cap)    om$dealloc (ptr = is_planar_cap);
 if (num_edges_in_cap) om$dealloc (ptr = num_edges_in_cap);

 EMWRAPUP(*EMmsg, OM_stat, "In EMcscap.I for composite surface");
 return(OM_stat);
}

end implementation EMScompsurf;
