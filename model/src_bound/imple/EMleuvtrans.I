/* ###################   APOGEE COMPILED   ################## */
/*
 Notes
	This method tranforms the linear edge by incoming matrix.
	This is done by transforming all of the (u,v) points in its
	instance data.

History

  RC   04/29/87   Creation date
  RC   08/31/87   Modified the arguments and the appropriate code.
  SM   09/02/87   Added code to do following -
                   If linear edge has two points see if
                   it matches any natural edge after transformation. 
                   If it does then replace.
                  Ideally any span of the linear edge matching a natural
                  edge should be replaced as such. This change will 
                  take care of a linear edge with one span only.
  SM   08-Dec-87  setting of curve_type when part edge is constructed
  RC   10/10/88   If the linear edge is replace by a natural or part of
                  a natural edge and the caller has requested the 
                  replacement info, return it in null_ptr2.
  SM   16-Feb-89  When converting the linear edge into a natural edge or
		  part of a natural edge, turn the iso property off.
  Sudha   07/06/93        modified for BSprototype includes
  WBC  12/22/93   Setting the curve type when a natural edge is constructed.
*/

class implementation EMSlinedge;

#include "EMS.h"
%safe
#include <math.h>
%endsafe
#include "EMSopt.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "mamulmx.h"

extern OMuword OPP_EMSpartedge_class_id, OPP_EMSnatedge_class_id;

from EMSnatedge import EMmake_natural_edge;
from EMSpartedge import EMpeinit;

method EMuv_transform (
	IGRlong			*EMmsg;
	IGRdouble		matrix[16];
	struct 	EMSpartolbasis	*partolbasis;
	IGRshort		option;
	IGRchar			*null_ptr1;
	IGRchar			*null_ptr2)

{
  struct EMSuvtrans_info * rpl_info;
  IGRdouble         mat_a[4],mat_c[4], parsqtol, partol;
  IGRlong           OM_stat, rc;
  IGRlong           EFget_clipped_edge_type();
  IGRint            arrsz;
  IGRshort          i, j, l = 4, m = 4, n = 1;
  IGRboolean        status, EFextract_par();
  IGRuchar  new_curve_type;
  extern void       EFmemory_allocation();

  /* *************************************************************** */

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (!partolbasis->is_valid)
  {
    OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info (
                        EMmsg, NULL, partolbasis),
                       targetid = my_id);
    EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
  }

  status = EFextract_par (BSTOLSQLENVEC, partolbasis->tol, 
                          &parsqtol, &rc);
  status = EFextract_par (BSTOLLENVEC, partolbasis->tol, &partol, &rc);

  for (i = 0; i < ME.EMSlinedge->num_points; i++)
  {
	mat_a[0] = ME.EMSlinedge->points[2*i];
	mat_a[1] = ME.EMSlinedge->points[2*i + 1];
	mat_a[2] = 0.0;
	mat_a[3] = 1.0;

	status = MAmulmx (&rc, &l, &m, &n, matrix, mat_a, mat_c);
	EMerr_hndlr ((!status || !(1&rc)),*EMmsg,EMS_E_Fail,wrapup);

	/*
	 * After transformation, if the u or v values becomes
	 * less than 0 and is very small, it is an error
	 * accumulated during matrix multiplication and
	 * thus should be reduced to 0.
	 */
	
	for(j=0; j<2; j++)
	 {
	   if ( fabs(mat_c[j] - 0.0) < partol) mat_c[j] = 0.0;
	   if ( fabs(mat_c[j] - 1.0) < partol) mat_c[j] = 1.0;
         }

	ME.EMSlinedge->points[2*i] = mat_c[0];
	ME.EMSlinedge->points[2*i + 1] = mat_c[1];
   }

   /* If the linear edge only two points and after transformation 
    * they match any natural edge then replace the linear edge 
    * with a natural edge.
    */
   
   if(ME.EMSlinedge->num_points == 2)
   {

	IGRboolean	full_natural, part_natural, natural;
	IGRshort	location;
	IGRdouble	*pt1, *pt2, nat_points[2][2];
	IGRboolean	EMis_span_on_natural_edge();

	if(ME.EMSedge->ed_props & EMED_REVERSED)
         {
          pt1 = &ME.EMSlinedge->points[2];
     	  pt2 = ME.EMSlinedge->points;
	 }
	else
	 {
	   pt1 = ME.EMSlinedge->points;
	   pt2 = &ME.EMSlinedge->points[2];
	 }
	
        full_natural = part_natural = natural = FALSE;

	natural = EMis_span_on_natural_edge(pt1, pt2, &full_natural, 
					    &part_natural, &location, 
					    partol, parsqtol);
					
	if(full_natural || part_natural)
	 {
	    GRobjid	nat_edge, replace_edge;
	
            OM_stat = om$construct(classid = OPP_EMSnatedge_class_id, 
			 	   p_objid = &nat_edge, 
			      msg = message EMSnatedge.EMmake_natural_edge
			       (EMmsg, location, &ME.EMSedge->curve_type,
                                NULL));
            EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

	    if(full_natural)
	     {
	       IGRushort	new_edprops;
	
	       EMnatpoints(EMmsg, location, nat_points);

	       new_edprops = ME.EMSedge->ed_props;
	       new_edprops &= ~EMED_ISO;
	
   	       if(EM2ddistptpts(pt1, nat_points[0]) > parsqtol)
	         new_edprops |= EMED_REVERSED;
	       else
	         new_edprops &= ~EMED_REVERSED;
		
	       OM_stat = om$send(msg = message EMSedge.EMset_props(
			   EMmsg, new_edprops, EMS_O_ON), 
		      targetid = nat_edge);
               EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
	       replace_edge = nat_edge;
	     }
	    else
	     {
		struct EMSedgebound	part_bdry[2];
		GRobjid			partedge;
		OM_S_CHANSELECT		to_owner, to_edge;
		IGRushort	pe_props ;
		IGRdouble		pts[4];
		
		IGRboolean		off_edge[2];
		
	       OM_stat = EMmake_chanselect (EMSedge_to_owner, &to_owner);
               EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

	       OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
               EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

/* Evaluate the parametric bounds of the partedge.
*/
	       OM_BLOCK_MOVE(pt1, pts, 2*sizeof(IGRdouble));
	       OM_BLOCK_MOVE(pt2, &pts[2], 2*sizeof(IGRdouble));
	
	       OM_stat = om$send (msg = message EMSedge.EMpratpt (
			 EMmsg, pts, 2, 
			 part_bdry, off_edge, NULL,partolbasis),
			 targetid = nat_edge);
	       EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_EdgeError,
								wrapup);

               pe_props =  ME.EMSedge->ed_props;
	       pe_props |= EMED_NATURAL;
	       pe_props &= ~EMED_ISO;
	 
	       if( (part_bdry[0].span_inx + part_bdry[0].param) >
		   (part_bdry[1].span_inx + part_bdry[1].param))
		pe_props |= EMED_REVERSED;
	       else
	        pe_props &= ~EMED_REVERSED;
	
	       OM_stat = EFget_clipped_edge_type(EMmsg, ME.EMSedge->curve_type,
						 &new_curve_type);
/* Construct and initialize the partedge.
*/
               OM_stat = om$construct(classid = OPP_EMSpartedge_class_id, 
			 	   p_objid = &partedge, 
			       msg = message EMSpartedge.EMpeinit
			      (EMmsg, pe_props, part_bdry, new_curve_type));
               EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
	       
	       OM_stat = om$send(msg = message Root.connect(to_owner, NULL, 
					partedge, OM_Gw_current_OS, to_edge, 
					NULL), 
				targetid = nat_edge, senderid = partedge);
               EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
               replace_edge = partedge;

	     }/* if part_natural */

	    OM_stat = om$send(msg = message EMSedge.EMreplace_edge
					(EMmsg, replace_edge, TRUE), 
				targetid = my_id);
	/**************************
		Function replaced by message. SM. Feb14, 1989.
	
	    OM_stat = EMreplace_edge(EMmsg, replace_edge, my_id, TRUE);
	****************************/
	
        EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
        
       /*
        * Return replacement info, If the caller has requested so.
        */

      if (null_ptr2)
      {
        rpl_info = (struct EMSuvtrans_info *) null_ptr2;
        if ((rpl_info->num_eds + 1) > rpl_info->eds_arrsz)
        {
          arrsz = rpl_info->eds_arrsz;
          EFmemory_allocation (&rc, (IGRchar **)&rpl_info->ed_ids,
                   rpl_info->num_eds+1, &arrsz, sizeof(GRobjid),
                   10, 5);
          EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

          EFmemory_allocation (&rc, (IGRchar **) &rpl_info->rpl_ed_ids,
                 rpl_info->num_eds+1, &rpl_info->eds_arrsz, 
                 sizeof(GRobjid), 10, 5);
          EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

        } /* if ((rpl_info->num_eds + 1) > rpl_info->eds_arrsz) */

        rpl_info->ed_ids[rpl_info->num_eds] = my_id;
        rpl_info->rpl_ed_ids[rpl_info->num_eds++] = replace_edge;

      } /* if (null_ptr2) */


	 } /* If full_natural || part_natural */
	
    } /* If num_points == 2 */

wrapup:
	
    EMWRAPUP (*EMmsg, OM_stat, "In EMSlinedge.EMuv_transform");
 
    return (OM_stat);

}

end implementation EMSlinedge;
