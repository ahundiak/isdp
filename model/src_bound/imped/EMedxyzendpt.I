/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method returns the xyz end points of the edge. It is the model
space counterpart of the message EMendpts.

Arguments

 surf_id	input		GRid of the surface to which the edge belongs.
				If not known can be NULL, in which case the
				edge tries to get it. This argument is ignored
				if the geometry of the surface is already
				passed in.
 md_env		input		Module environment of the surface. Ignored
				if surface geometry is already passed
				in.
 begin_pt_uv	input		Begin point of the edge. If NULL the edge 
				will obtain it. This is a 2D point in UV
				space.
 end_pt_uv	input		As above.
 begin_pt_xyz	output		The corresponding point in model space. If
				not needed pass NULL.
 end_pt_xyz	output		As above.
 surf_geom	input/output	Geometry of the surface. There are to options-
				1) The double pointer points to a NULL
				value. In the case the method obtains
				the geometry and returns it back (the caller
				needs to free the memory).
				If the double pointer points to a non
				NULL value, valid geometry is assumed to
				be passed in. 
				2) The double pointer itself is NULL. In
				this case the method obtains the
				geometry and does not return it back.

History
	SM	16-May-88	Creation.
        Sudha   06/04/93        modified to include BSprototype header files
*/

class implementation EMSedge;

#include "EMS.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bssfeval.h"

method EMxyz_endpt(IGRlong *EMmsg; 
		   struct GRid *surf_id; 
		   struct GRmdenv_info *md_env;
		   IGRdouble *begin_pt_uv, *end_pt_uv, 
		   *begin_pt_xyz, *end_pt_xyz;
		   struct IGRbsp_surface **surf_geom)
{
 IGRlong		sts, rc;
 IGRdouble		begin_uv[2], end_uv[2];
 struct IGRbsp_surface  *loc_surf_geom;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 loc_surf_geom = NULL;

 /* If the surface geometry is not passed in, then go get it.
    The caller can pass the surface geometry (in which case the double pointer
    points to non NULL value) or not pass it in but wants it back (in which
    case the double pointer points to NULL value) or has not passed it
    in and does not want it back (in which case the double pointer
    itself is NULL)!
 */
 if(!surf_geom)
  {
   sts = om$send(msg = message EMSedge.EMget_sf_geom(EMmsg, surf_id, 
				&loc_surf_geom, md_env), targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
   surf_geom = &loc_surf_geom;
  }
 else if(!(*surf_geom))
  {
   sts = om$send(msg = message EMSedge.EMget_sf_geom(EMmsg, surf_id, 
				surf_geom, md_env), targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
  }

 /* Get the relevant uv endpoints of the edge if not supplied.
 */
 if( (begin_pt_xyz && !begin_pt_uv) ||
     (end_pt_xyz && !end_pt_uv))
  {
   sts = om$send(msg = message EMSedge.EMendpts(EMmsg, 
		begin_pt_xyz ? (begin_pt_uv ? NULL : begin_uv) : NULL, 
		end_pt_xyz ? (end_pt_uv ? NULL : end_uv) : NULL, 
		NULL, NULL, NULL), targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
  }

 if(!begin_pt_uv) begin_pt_uv = begin_uv;
 if(!end_pt_uv) end_pt_uv = end_uv;

  /* AMD : 02/11/92 : fix for TR 92n0426 
     Constrain the uv points to lie in the parametric space.
   */

   if (begin_pt_uv[0] > 1.0 ) 
       begin_pt_uv[0] = 1.0;
   if (begin_pt_uv[0] < 0.0 )
       begin_pt_uv[0] = 0.0;

   if (begin_pt_uv[1] > 1.0 ) 
       begin_pt_uv[1] = 1.0;
   if (begin_pt_uv[1] < 0.0 )
       begin_pt_uv[1] = 0.0;
 
 /* evaluate the relevant end points and return
 */
 if(begin_pt_xyz)
  {
   BSsfeval(*surf_geom, begin_pt_uv[0], begin_pt_uv[1], 0,
                                      (IGRpoint *) begin_pt_xyz, &rc);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
  }

   if (end_pt_uv[0] > 1.0 ) 
       end_pt_uv[0] = 1.0;
   if (end_pt_uv[0] < 0.0 )
       end_pt_uv[0] = 0.0;

   if (end_pt_uv[1] > 1.0 ) 
       end_pt_uv[1] = 1.0;
   if (end_pt_uv[1] < 0.0 )
       end_pt_uv[1] = 0.0;

 if(end_pt_xyz)
  {
   BSsfeval(*surf_geom, end_pt_uv[0], end_pt_uv[1], 0,
                                     (IGRpoint *) end_pt_xyz, &rc);
   EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
  }

wrapup:
if(loc_surf_geom) om$dealloc(ptr = loc_surf_geom);
 EMWRAPUP(*EMmsg, sts, "In EMSedge.EMxyz_endpt");
 return(sts);
}

end implementation EMSedge;
