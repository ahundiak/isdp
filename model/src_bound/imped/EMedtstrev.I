/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include <stdio.h>
#include "EMSopt.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"

from GRvg import        EMptatpr;

method EMtst_reversibility(
    IGRlong         *EMmsg; 
    IGRboolean      *rev_connect;
    GRobjid         partner_id, my_srf_id, partner_srf_id;
    IGRboolean      seam;
    struct GRmd_env *mod_info)
/*
History

    RC      03/23/87        Creation in EMconnect_edges.
    RV      02/18/88        Independence day.
    SM	    31-Aug-89	    In seam case, take 1 pt on edge1 and 2
			    points on edge2 and do comparative distance
			    checks. The points are internal at 0.25,
			    0.75. This was done because the earlier scheme
			    of checking points to be within tolerance was
			    tolerance sensitive.
    Sudha   06/04/93        modified to include BSprototype header files

*/
{
  IGRlong               OM_stat;
IGRlong   mthd_stat;
  IGRushort     partner_props;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (my_srf_id == NULL_OBJID)
  {
    OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info(
                             &mthd_stat, &my_srf_id, NULL),
                             targetid = my_id);
    EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
  }

  if (partner_srf_id == NULL_OBJID)
  {
    OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info(
                              &mthd_stat, &partner_srf_id, NULL),
                              targetid = partner_id);
    EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
  }
  OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                      &partner_props), targetid = partner_id);
  EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

   /*
    * If I am a seam edge, special processing is done as
    * in the process of going from model space to parametric
    * any one of the possible (u,v) values can be returned.
    */
   
   if (!seam)
   {
      if (ME.EMSedge->ed_props & EMED_XYZ_CLOSED)
      {

        /*
         * It is assumed that if I am a closed edge, my partner 
         * is so. The following logic is used to test for closed 
         * edge reversibility:
         *
         *  o  Pick two points on myself in my parametric space.
         *     These points should be as distant apart as possible.
         *     Evaluate these points in my surface's parametric
         *     space. Then convert these (u,v) space points to
         *     (x,y,z) space points.
         *
         *  o  Now use the above evaluated (x,y,z) points and
         *     translate them to my partner's surface (u,v) space
         *     and finally to my partner's parametric space.
         *	
         *  o  Finally, compare the direction of the points
         *     in my parametric space with that of the points
         *     in my partner's parametric space. If they
         *     have the same direction in their respective
         *     parametric space i.e., the first point in my
         *     parametric space is less than that the 2nd pt
         *     and are so the pts in my partner's parametric
         *     space, I am not a reversed edge. Other wise
         *     I am a reveresed edge.
         */

        IGRdouble           ed1_bs_param[2], valdiff1, valdiff2;
        struct EMSedgebound ed1_bnd_param[2],ed2_bnd_param[2];

        ed1_bs_param[0] = 0.25;
        ed1_bs_param[1] = 0.75;

        OM_stat = om$send (msg = message EMSedge.EMbstobnd(&mthd_stat,
                            2, ed1_bs_param, ed1_bnd_param),
                           targetid = my_id);
       EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

        OM_stat = om$send (msg = message EMSedge.EMtwin_crv_parm(
                           &mthd_stat, &ed1_bnd_param[0], 
                           &ed2_bnd_param[0], mod_info, -3, 
                           &my_srf_id, &partner_srf_id),
                          targetid = my_id);
       EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       OM_stat = om$send (msg = message EMSedge.EMtwin_crv_parm(
                           &mthd_stat, &ed1_bnd_param[1], 
                           &ed2_bnd_param[1], mod_info, -3, 
                           &my_srf_id, &partner_srf_id),
                          targetid = my_id);
       EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       valdiff1 = (ed1_bnd_param[1].span_inx + ed1_bnd_param[1].param) -
              (ed1_bnd_param[0].span_inx + ed1_bnd_param[0].param);
       if(ME.EMSedge->ed_props & EMED_REVERSED) valdiff1 = -valdiff1;

       valdiff2 = (ed2_bnd_param[1].span_inx + ed2_bnd_param[1].param) -
              (ed2_bnd_param[0].span_inx + ed2_bnd_param[0].param);
       if(partner_props & EMED_REVERSED) valdiff2 = -valdiff2;
		   
       if ((valdiff1 < 0 && valdiff2 > 0) || (valdiff1 > 0 && valdiff2 < 0))
       *rev_connect = TRUE; else *rev_connect = FALSE;

     } /* if (ME.EMSedge->ed_props & EMED_XYZ_CLOSED) */

    else			/* I am not a closed edge */
    {
        /* 
         * If I am an open edge, the reversibility can be checked
         * as:
         * 1. evaluate one of my end points ( begin pt is considered
         *    here) in the (xyz) space.
         * 2. evaluate the begin pt and the end pt of my partner
         * 3. compute distance between my begin pt and partner's begin
         *    pt with the distance between my begin pt and partner's
         *    end pt, to determine reversibility.
         */

        IGRdouble ed1_uv_bgn[2], ed2_uv_bgn[2], ed2_uv_end[2];
        IGRpoint  ed1_xyz_bgn, ed2_xyz_bgn, ed2_xyz_end;
        IGRdouble distsq1, distsq2;
        BSrc      rc;

       OM_stat = om$send (msg = message EMSedge.EMendpts( &mthd_stat, 
                            ed1_uv_bgn, NULL, NULL, NULL, NULL),
                           targetid = my_id);
       EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       OM_stat = om$send (msg = message GRvg.EMptatpr( &mthd_stat, 
                           &mod_info->md_env.matrix_type,
                            mod_info->md_env.matrix,
			    ed1_uv_bgn, 2, ed1_xyz_bgn),
                          targetid = my_srf_id);
       EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
	
       OM_stat = om$send (msg = message EMSedge.EMendpts( &mthd_stat, 
                           ed2_uv_bgn, ed2_uv_end, NULL, NULL, NULL),
                          targetid = partner_id);
       EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       OM_stat = om$send (msg = message GRvg.EMptatpr( &mthd_stat, 
                           &mod_info->md_env.matrix_type,
                            mod_info->md_env.matrix,
                            ed2_uv_bgn, 2, ed2_xyz_bgn),
                          targetid = partner_srf_id);
       EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_SurfaceError, wrapup);

       OM_stat = om$send (msg = message GRvg.EMptatpr( &mthd_stat, 
                           &mod_info->md_env.matrix_type,
                            mod_info->md_env.matrix,
                            ed2_uv_end, 2, ed2_xyz_end),
                          targetid = partner_srf_id);
       EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_SurfaceError, wrapup);

       distsq1 = BSdistptpts (&rc, ed1_xyz_bgn, ed2_xyz_bgn);
       distsq2 = BSdistptpts (&rc, ed1_xyz_bgn, ed2_xyz_end);
       if (distsq1 <= distsq2) 
       *rev_connect = FALSE; else *rev_connect = TRUE;

     } /* else for if (ME.EMSedge->ed_props & EMED_XYZ_CLOSED) */

  } /* if (!seam)) */
  else
  {
    IGRdouble ed_uv_param[2][4], ed_bs_param, ed_xyz_pts[2][6];
    IGRdouble dist1, dist2;
    BSrc      rc;
    IGRint	i;
    for(i=0; i<2; i++)
     {
      ed_bs_param = i ? 0.75 : 0.25;
      OM_stat = om$send (msg = message EMSedge.EMptatpr( &mthd_stat, 
                        1, NULL, &ed_bs_param, ed_uv_param[i]),
                       targetid = my_id);
      EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      ed_uv_param[i][2] = (ed_uv_param[i][0] == 0.) ? 1. :
                      ((ed_uv_param[i][0] == 1.) ? 0. : ed_uv_param[i][0]);
      ed_uv_param[i][3] = (ed_uv_param[i][1] == 0.) ? 1. :
                      ((ed_uv_param[i][1] == 1.) ? 0. : ed_uv_param[i][1]);

      OM_stat = om$send (msg = message GRvg.EMptatpr( &mthd_stat,       
                        &mod_info->md_env.matrix_type,
                        mod_info->md_env.matrix,
                        ed_uv_param[i], 4, ed_xyz_pts[i]),
                       targetid = my_srf_id);
      EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
     }

    dist1 = BSdistptpt (&rc, &ed_xyz_pts[0][0], &ed_xyz_pts[0][3]);
    dist2 = BSdistptpt (&rc, &ed_xyz_pts[0][0], &ed_xyz_pts[1][3]);

    if (dist1 < dist2) 
       *rev_connect = TRUE; else *rev_connect = FALSE;

  } /* else for if (!seam) */


wrapup:
  EMWRAPUP(*EMmsg,OM_stat,"In EMSedge.EMtst_reversibility")
  return(OM_stat);

}

end implementation EMSedge;
