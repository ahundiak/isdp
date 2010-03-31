/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method 'windows' a loopset and prodces an output loopset
	which is the result of looking at the existing loopset through
	a window in parametric space. The existing loopset is left
	UNCHANGED.
		Optionally the resultant loopset can be transformed into
	a different parametric space.
		If the window falls completely in hole, then EMS_I_InHoleTrim
	is the return code. If it falls completely in area and does not
	contain any boundaries, then
	EMS_I_InAreaTrim is the return code. In both cases no loopset is
	returned and the argument loopset_out will contain NULL_OBJID.
	
	More on EMS_I_InAreaTrim : This return code means that after windowing
	there was only one loop in the output loopset which also means that
	that (P) loop describes the windowed piece completely. 
	
Arguments
	parm1		input		pointer to starting UV parameter.
	parm3		input		pointer to ending UV parameter.
	parm2		input		If the surface is closed and windowing
					is to be done across seam then this 
					parameter indicates the fact.
					If this parameter is not
					provided then, the average of
					the window limits will be used.
					If not across seam, this can be NULL.
	across_seam	output		Flag indicating whether the
					split took place across the
					seam. This information is generated
					in the method and if indicated
					by a non_NULL value, will be returned
					to the caller. If not interested, pass
					NULL.
					0x0 - Not across seam.
					0x1 - Across seam in U direction.
					0x2 - Across seam in V direction.
					0x3 - Across seam in U and V.
					(See ems/include/EMSsplitdef.h)
					
	split_ind	input		Direction of split-
					0 - split in U direction.
					1 - split in V direction.
					2 - split in both U and V directions.
	loopset_out	output		GRobjid of the windowed loopset.
	surf		input		Geometry of the surface.
	transform	input		Boolean flag indicating whether the
					caller wishes to transform the 
					windowed loopset into a new parametric
					space.
	mint, maxt	input		Limits of the new parametric
					space. If no transformation is desired
					these can be NULL.
	partolbasis	input		Parametric tolerance for the surface.
					If the is_valid flag in this structure
					is FALSE, then matrix and matrix
					type in the structure must be valid.
	env		input		Module environment of the surface.
	want_status_messages input	Boolean flag indicating whether the
					caller wishes to have status messages
					displayed as the processing continues.
History
	SM	07/26/87	Design and creation.
	SM	3-Aug-88	initialize options to NULL.
	
*/

class implementation EMSloopset;

#include "EMS.h"
#include "OMmacros.h"
#include "EMSsplitdef.h"
#include "emsimpdef.h"

method EMwindow(IGRlong *EMmsg;
		IGRdouble *parm1, *parm2, *parm3;
		IGRshort *across_seam;
		IGRint split_ind;
		GRobjid *loopset_out;
		struct IGRbsp_surface *surf;
		IGRboolean transform;
		IGRdouble mint[], maxt[];
		struct EMSpartolbasis *partolbasis;
		struct GRmd_env	*env;
		IGRboolean want_status_messages)
{
   IGRint		sts;
   GRobjid		window_loop;
   IGRdouble		pt_in_area[2], window[4];
   IGRint		EMmake_window_loop(), EMwindow_in_hole();
   IGRint		EMget_window(), EMwindow_in_area();
   IGRboolean		surf_closed, inters;
   void			EMget_point_in_area();
   IGRushort	options = NULL;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
   if(across_seam) *across_seam = NOT_ACROSS_SEAM;
   if(want_status_messages) options = EMImpBnd_WantStatMsg;

   surf_closed = (surf->u_phy_closed || surf->v_phy_closed) ? TRUE : FALSE;


/* Make a copy of the host loopset.
*/
   sts = om$send(msg = message EMSboundary.EMtpcopy
			(EMmsg, NULL, OM_Gw_current_OS, OM_Gw_current_OS, 
			 FALSE, loopset_out), targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

/* If the split is taking place in both directions and if the surface
   is physically closed along the split direction then the split is handled
   first in U and then in V. If the surface is not closed then this double
   procesing is not necessary.
*/

   if(split_ind == SPLIT_BOTH)
    {
      if(surf_closed)
       {
        sts = EMget_window(EMmsg, parm1, parm3, SPLIT_U, window);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

        sts = EMmake_window_loop(EMmsg, window, &window[2], &window_loop, 
				 partolbasis);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

/* If the surface is closed and the windowing is across the seam then use
   parm2 as the point in area, else use average of the window as the point
   in area.
*/
        EMget_point_in_area(surf->u_phy_closed, parm1, parm2, parm3, window, 
			    pt_in_area, SPLIT_U, across_seam);

	if(EMwindow_in_hole(EMmsg,*loopset_out, window_loop, partolbasis, 
				&inters))
	  goto wrapup;
	
        sts = om$send(msg = message EMSloopset.EMimpose_boundaries
			(EMmsg, &window_loop, 1, pt_in_area, TRUE,  
			 NULL, NULL, NULL, NULL, NULL, NULL, partolbasis, 
			 env, NULL, options), targetid = *loopset_out);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
	
	if((!inters) && EMwindow_in_area(EMmsg,*loopset_out))
	  goto wrapup;

        sts = EMget_window(EMmsg, parm1, parm3, SPLIT_V, window);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

        sts = EMmake_window_loop(EMmsg, window, &window[2], &window_loop, 
				 partolbasis);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

	EMget_point_in_area(surf->v_phy_closed, parm1, parm2, parm3, window, 
			    pt_in_area, SPLIT_V, across_seam);
			
	if(EMwindow_in_hole(EMmsg,*loopset_out, window_loop, partolbasis, 
			    &inters))
	  goto wrapup;

	sts = om$send(msg = message EMSloopset.EMimpose_boundaries
			(EMmsg, &window_loop, 1, pt_in_area, TRUE, 
			 NULL, NULL, NULL, NULL, NULL, NULL, partolbasis, 
			 env, NULL, options), targetid = *loopset_out);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

	if((!inters) && EMwindow_in_area(EMmsg,*loopset_out))
	  goto wrapup;

      }/* if surf_closed */
     else
      {
        sts = EMget_window(EMmsg, parm1, parm3, SPLIT_BOTH, window);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

        sts = EMmake_window_loop(EMmsg, window, &window[2], &window_loop, 
				 partolbasis);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

        pt_in_area[0] = (window[0] + window[2])/2;
        pt_in_area[1] = (window[1] + window[3])/2;

	if(EMwindow_in_hole(EMmsg,*loopset_out, window_loop, partolbasis, 
			    &inters))
	  goto wrapup;

        sts = om$send(msg = message EMSloopset.EMimpose_boundaries
			(EMmsg, &window_loop, 1, pt_in_area, TRUE, 
			 NULL, NULL, NULL, NULL, NULL, NULL, partolbasis, 
			 env, NULL, options), targetid = *loopset_out);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

	if((!inters) && EMwindow_in_area(EMmsg,*loopset_out))
	  goto wrapup;

      } /* else if !surf_closed */
    }

   else if(split_ind == SPLIT_U)
    {

      sts = EMget_window(EMmsg, parm1, parm3, SPLIT_U, window);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

      sts = EMmake_window_loop(EMmsg, window, &window[2], &window_loop, 
				partolbasis);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

      EMget_point_in_area(surf->u_phy_closed, parm1, parm2, parm3, window, 
			  pt_in_area, SPLIT_U, across_seam);
			
      if(EMwindow_in_hole(EMmsg, *loopset_out, window_loop, partolbasis, 
			  &inters))
	  goto wrapup;

      sts = om$send(msg = message EMSloopset.EMimpose_boundaries
			(EMmsg, &window_loop, 1, pt_in_area, TRUE, 
			 NULL, NULL, NULL, NULL, NULL, NULL, partolbasis, 
			 env, NULL, options), targetid = *loopset_out);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

      if( (!inters) && EMwindow_in_area(EMmsg,*loopset_out))
	  goto wrapup;

    } /* If split_ind == SPLIT_U */

   else if(split_ind == SPLIT_V)
    {
      sts = EMget_window(EMmsg, parm1, parm3, SPLIT_V, window);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

      sts = EMmake_window_loop(EMmsg, window, &window[2], &window_loop, 
				partolbasis);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

      EMget_point_in_area(surf->v_phy_closed, parm1, parm2, parm3, window, 
			  pt_in_area, SPLIT_V, across_seam);
			
      if(EMwindow_in_hole(EMmsg, *loopset_out, window_loop, partolbasis, 
			  &inters))
	  goto wrapup;

      sts = om$send(msg = message EMSloopset.EMimpose_boundaries
			(EMmsg, &window_loop, 1, pt_in_area, TRUE, 
			 NULL, NULL, NULL, NULL, NULL, NULL, partolbasis, 
			 env, NULL, options), targetid = *loopset_out);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

      if( (!inters) && EMwindow_in_area(EMmsg,*loopset_out))
	  goto wrapup;
    }   

/* If the entire window was in a hole portion then delete the new loopset
   and return.
*/
   if( (*EMmsg != EMS_I_InHoleTrim) && (*EMmsg != EMS_I_InAreaTrim) )
    {
/* The copy loopset is going to exist by itself. So compress it(get rid
   of the unnecessary partedges formed due to multiple splits)
*/
      {
	  GRobjid		new_objid;
	
        sts = om$send(msg = message EMSboundary.EMcompress_top
				(EMmsg, partolbasis, &new_objid), 
			targetid = *loopset_out);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
      }

/* If the caller wishes transform the new loopset
*/
      if(transform)   
       {
	  IGRdouble		trans_matrix[16], org_range[4], new_range[4];
	  IGRshort		EFget_uv_trans_mat();
	  IGRint		size;
	
	  size = 2 * sizeof(IGRdouble);
          OM_BLOCK_MOVE(mint,new_range, size);
	  OM_BLOCK_MOVE(maxt, &new_range[2], size);
	
	  sts = om$send(msg = message EMSloopset.EMgetrange
				(EMmsg, org_range), targetid = *loopset_out);
	  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
	
	  sts = EFget_uv_trans_mat(EMmsg, org_range, new_range, 
					trans_matrix);
	  sts = om$send(msg = message EMSloopset.EMuv_transform
			(EMmsg, trans_matrix, partolbasis, NULL, NULL, NULL), 
				targetid = *loopset_out);
	  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
       }

   } /* If *EMmsg != EMS_I_InHoleTrim && *EMmsg != EMS_I_InAreaTrim */

wrapup:
        if( (*EMmsg == EMS_I_InHoleTrim) || (*EMmsg == EMS_I_InAreaTrim))
         {
           sts = om$send(msg = message Root.delete(TRUE), 
			targetid = *loopset_out);
	   *loopset_out = NULL_OBJID;
	 }
	
	EMWRAPUP(*EMmsg, sts, "In EMSloopset.EMwindow");
	return(sts);
}


end implementation EMSloopset;
