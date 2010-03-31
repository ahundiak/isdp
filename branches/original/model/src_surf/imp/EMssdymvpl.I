/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
HISTORY:

Long Ago:  ??  Creation.
08/26/92:  NP  Modified for ANSI compliance. Added missing typecast in GRgetabsg.
*/

# include "OMerrordef.h"
# include "gocmacros.h"     /* GRgetabsg macro  */
# include "igrdp.h"
# include "dpstruct.h"
# include "dpmacros.h"
# include "msdef.h"
# include "bserr.h"
# include "emsdef.h"
# include "OMstackalloc.h"
# include "EMSmsgdef.h"
# include "EMSfrtdef.h"
# include "OMmacros.h" /* For OM_BLOCK_MOVE */
# include <stdio.h>
# include "EMSmvpl.h" /* For EMMOVE_POLE... */
# define DEBUG 0

# define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

/*
 * Structure used to communicate
 * with the dynamic-modifying
 * function.
 */

struct movepole_info
  {
   IGRshort num_buffs;
   IGRint pole_inx;
   IGRint num_indices;
   IGRint *indices;
   IGRboolean rational;
   IGRpoint from_point;
   IGRint u_num_poles;
   IGRint v_num_poles;
   IGRint u_start_pl;
   IGRint v_start_pl;
   IGRdouble *vectors;
   IGRdouble *dists;
   IGRdouble *ref_vector;
   struct DPele_header buffs[2];
  };

method EMdynmod (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                 IGRushort options;IGRlong num_poles;
                 IGRint *indices; IGRdouble *poles; IGRpoint from_point;
                 IGRchar *buff)
{
   IGRboolean stat_func;
   IGRint u_bounds[5], v_bounds[5];
   IGRlong stat_OM, msg_loc, dumdum;
   IGRlong  u_start_pl, v_start_pl,temp_u,temp_v;
   IGRlong u_end_pl, v_end_pl, u_start_kt, v_start_kt;
   IGRlong u_end_kt, v_end_kt;
   IGRlong from_u_pole_inx, to_u_pole_inx, from_v_pole_inx, to_v_pole_inx;
   IGRlong u_np, v_np, u_nk, v_nk, u_num_seg, v_num_seg;
   IGRlong u, v, i, inx;
   IGRdouble *temp_ptr;
   IGRdouble u_rules[5], v_rules[5];
   IGRdouble u_ktdel, v_ktdel;
   IGRdouble *vectors;
   IGRdouble vecpts[6];
   IGRpoint u_ptset[3], v_ptset[3], point;
   struct IGRpointset pointset0;
   struct IGRespy espy0;
   struct IGRbsp_surface *mysrf, *srf;
   struct movepole_info buff_info;
   struct IGResqbs esqs;
   struct IGRdisplay display2,display0;
   struct EMmove_pole_addtnl_info *info = NULL;
   extern    IGRboolean BSunwght_p();
   IGRint EMssdynmod1();

   *msg = EMS_S_Success;
   stat_OM = OM_S_SUCCESS;

   mysrf = srf = NULL;

   /*
    * Get the abstract geometry of this
    * surface.
    */

    buff_info.vectors = NULL;
    buff_info.dists = NULL;
    buff_info.ref_vector = NULL;

   if (options & EMMOVE_POLE_ALONG_SPECIFIED_VECTORS)
   {
    info = (struct EMmove_pole_addtnl_info *) buff;
    buff_info.vectors = info->vectors;
    buff_info.ref_vector = info->ref_vector;
   }

   if (options & EMMOVE_POLE_ALONG_SPECIFIED_DISTS)
   {
    buff_info.dists = info->dists;
   }

   GRgetabsg (&msg_loc, mattyp, mat, (IGRchar **)&mysrf, i);
   EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

/*
 * Determine the extents of the surface that is getting modified.
 */

   temp_u = temp_v = from_u_pole_inx = from_v_pole_inx = to_u_pole_inx =
   to_v_pole_inx = 0;


   for (i=0;i<num_poles;i++)
   {
    temp_u = indices[i] % mysrf->u_num_poles;
    temp_v = indices[i] / mysrf->u_num_poles;

    if (i == 0)
    {
     from_u_pole_inx = to_u_pole_inx = temp_u;
     from_v_pole_inx = to_v_pole_inx = temp_v;
    }
    else
    {
    if (temp_u < from_u_pole_inx)
     from_u_pole_inx = temp_u;
    else if (temp_u > to_u_pole_inx)
     to_u_pole_inx = temp_u;


    if (temp_v < from_v_pole_inx)
     from_v_pole_inx = temp_v;
    else if (temp_v > to_v_pole_inx)
     to_v_pole_inx = temp_v;
   }
   }

#if DEBUG
 fprintf (stderr,"%d %d %d %d \n", from_u_pole_inx, from_v_pole_inx,
                                   to_u_pole_inx, to_v_pole_inx);
#endif

   /*
    * Get the pole and the knot extents for that portion of the surface
    * that is affected by the pole to be modified.
    */

    u_start_pl = from_u_pole_inx - (mysrf->u_order - 1);
    if (u_start_pl < 0) u_start_pl = 0;
    u_start_kt = u_start_pl;
    v_start_pl = from_v_pole_inx - (mysrf->v_order - 1);
    if (v_start_pl < 0) v_start_pl = 0;
    v_start_kt = v_start_pl;

    u_end_pl = to_u_pole_inx + (mysrf->u_order - 1);
    if (u_end_pl > mysrf->u_num_poles - 1) u_end_pl = mysrf->u_num_poles - 1;
    u_end_kt = u_end_pl + mysrf->u_order;
    v_end_pl = to_v_pole_inx + (mysrf->v_order - 1);
    if (v_end_pl > mysrf->v_num_poles - 1) v_end_pl = mysrf->v_num_poles - 1;
    v_end_kt = v_end_pl + mysrf->v_order;

   u_np = u_end_pl - u_start_pl + 1;
   u_nk = u_np + mysrf->u_order;
   v_np = v_end_pl - v_start_pl + 1;
   v_nk = v_np + mysrf->v_order;

   /*
    * Allocate space for the surface-patch that is the affected portion
    * of this surface. Fill this patch with relevant data.
    */
   
   BSallocsf (mysrf->u_order, mysrf->v_order, u_np, v_np, mysrf->rational,
              mysrf->num_boundaries, &srf, &msg_loc);
   EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoDynamicMemory, ret_end);

  /*
   * Copy control information
   */
   srf->u_order = mysrf->u_order;
   srf->v_order = mysrf->v_order;
   srf->u_periodic = mysrf->u_periodic;
   srf->v_periodic = mysrf->v_periodic;
   srf->u_non_uniform = mysrf->u_non_uniform;
   srf->v_non_uniform = mysrf->v_non_uniform;
   srf->planar = mysrf->planar;
   srf->u_phy_closed = mysrf->u_phy_closed;
   srf->v_phy_closed = mysrf->v_phy_closed;

  /*
   * Copy the relevant poles
   */
   inx = 0;
   for (v=0; v<v_np; v++)
     for (u=0; u<u_np; u++)
       for (i=0; i<3; i++)
         srf->poles[inx++] = mysrf->poles[(mysrf->u_num_poles * 
                                           (v_start_pl + v) +
                                           (u_start_pl + u)) * 3 + i];
   srf->u_num_poles = u_np;
   srf->v_num_poles = v_np;

  /*
   * Copy the relevant knots
   */
   for (u=u_start_kt, i=0; i<u_nk; u++, i++)
     srf->u_knots[i] = mysrf->u_knots[u];
   for (v=v_start_kt, i=0; i<v_nk; v++, i++)
     srf->v_knots[i] = mysrf->v_knots[v];

   srf->u_num_knots = u_nk;
   srf->v_num_knots = v_nk;
  
  /*
   * Copy the relevant weights
   * if rational
   */
   srf->rational = mysrf->rational;
   if (srf->rational)
      {
      inx = 0;
      for (v=0; v<v_np; v++)
        for (u=0; u<u_np; u++)
          srf->weights[inx++] = mysrf->weights[(mysrf->u_num_poles * 
                                             (v_start_pl + v) +
                                             (u_start_pl + u))];
      }
   else 
      srf->weights = NULL;

   /*
    * The boundaries computed earlier for this patch should
    * be entered here. But for now, no boundaries are supported.
    * Therefore,
    */

   srf->num_boundaries = 0;
   srf->bdrys = NULL;

  /*
   * Check to see how many polygon segments will be drawn. Also obtain
   * pole index to this extracted patch. Obtain the pole index at which
   * the polygon display will begin for the extracted patch. (One
   * segment on either side of the modified pole.
   */



    buff_info.pole_inx = v_start_pl * (srf->u_num_poles) + u_start_pl; 
                         
    OM_BLOCK_MOVE(from_point, buff_info.from_point,
                  sizeof (IGRpoint));

   /*
    * Initialize the control information
    * in the buffer to be communicated to 
    * the dynamic modify function.
    */

   buff_info.num_buffs = 2;
   buff_info.num_indices = num_poles;

/* display2.rgb_value = 0; */
   display2.color = ME.GRvg->display_attr.color;
   display2.weight = ME.GRvg->display_attr.weight;
   display2.style = ME.GRvg->display_attr.style;

   u_ktdel = (srf->u_knots[u_np] - srf->u_knots[srf->u_order-1]) / 4.0;
   v_ktdel = (srf->v_knots[v_np] - srf->v_knots[srf->v_order-1]) / 4.0;
   u_rules[0] = srf->u_knots[srf->u_order-1];
   v_rules[0] = srf->v_knots[srf->v_order-1];
   for (i=1; i<4; i++)
     {
     u_rules[i] = u_rules[i-1] + u_ktdel;
     v_rules[i] = v_rules[i-1] + v_ktdel;
     }
   u_rules[4] = srf->u_knots[u_np];
   v_rules[4] = srf->v_knots[v_np];

   for (i=0; i<5; i++)
     {
     u_bounds[i] = 0;
     v_bounds[i] = 0;
     }

   buff_info.indices = indices;
   buff_info.u_num_poles = mysrf->u_num_poles;
   buff_info.v_num_poles = mysrf->v_num_poles;
   buff_info.u_start_pl = u_start_pl;
   buff_info.v_start_pl = v_start_pl;

   esqs.u_rules = 5;
   esqs.v_rules = 5;
   esqs.is_polydis = TRUE;
   esqs.is_surfdis = TRUE;
   esqs.is_slowdis = FALSE;
   esqs.type = NULL;
   esqs.rules_specified = TRUE;
   esqs.u_rule_values = u_rules;
   esqs.v_rule_values = v_rules;
   esqs.u_num_bound = u_bounds;
   esqs.v_num_bound = v_bounds;
   esqs.u_bdrys = NULL;
   esqs.v_bdrys = NULL;

   dp$build_dis_buffer (buffer = &buff_info.buffs[0], type = IGRQS,
    display_att = &display2, ele_spec_att = &esqs, geometry = srf);
         
   espy0.is_closed = FALSE;
/* display0.rgb_value = 0; */
   display0.color = ME.GRvg->display_attr.color;
   display0.weight = ME.GRvg->display_attr.weight;
   display0.style = ME.GRvg->display_attr.style;

   pointset0.num_points = 2;
   pointset0.points = vecpts;
   OM_BLOCK_MOVE(from_point,&vecpts[0],sizeof(IGRpoint));
   OM_BLOCK_MOVE(from_point,&vecpts[3],sizeof(IGRpoint));

   dp$build_dis_buffer (buffer = &buff_info.buffs[1], type = IGRPY,
    display_att = &display0, ele_spec_att = &espy0, geometry = &pointset0);
   /*
    * Call the dynamics functions
    * that actually tracks the cursor.
    * This function returns if dynamics
    * was set to off in the system or
    * if an event (other than a window
    * event) occurred.
    */

   dp$dynamics (dyn_fun = EMssdynmod1, information = &buff_info);

ret_end:
   if (srf) 
     BSfreesf (&msg_loc, srf);

   EMWRAPUP (*msg, stat_OM, "EMsubbs.EMdynmod");
   return (stat_OM);
}


/*
 * This function is the one that gets called repeatedly
 * by DPdynamics whenever any change occurs in the cursor
 * position. The argument list for this fuction is standard.
 * Some of the arguments are not made use of in this function.
 * The most significant arguments here are the 'buff_info' and 
 * 'newpt'; the latter is used to modify the former along with
 * the control information in 'buff_info'.
 */

IGRint EMssdynmod1 (buff_info, newpt, mtx, objs, num_objs, buffs, num_buffs,
                   dummy1, dummy2, dummy3, dummy4, dummy5, dummy6)
struct movepole_info *buff_info;
struct EX_button *newpt;
IGRdouble *mtx;
struct GRid **objs;
IGRint *num_objs;
struct DPele_header **buffs;
IGRint *num_buffs;
IGRchar *dummy1, *dummy2, *dummy3;
IGRchar *dummy4, *dummy5, *dummy6;
{
   IGRdouble weight;
   IGRint msg;
   IGRint u_inx;
   IGRint v_inx;
   IGRint i,j,k;
   IGRvector vec;
   IGRint ret;
   IGRint u_pole_inx, v_pole_inx;
   IGRdouble dist,temp_dist;
   extern IGRboolean MAptlnproj();
   extern IGRdouble sqrt();
   struct IGRbsp_surface *surf;
   struct IGRpointset *ptset;
     
     EMconstrain(newpt);

     surf = buff_info->buffs[0].geometry.bspsurf;


     if (buff_info->ref_vector)
     {
      struct IGRline line;
      IGRdouble t;
      IGRpoint todir,topt;
      IGRpoint proj_pt;
      IGRboolean sts;
       
      topt[0] = newpt->x;
      topt[1] = newpt->y;
      topt[2] = newpt->z;

      line.point1 = buff_info->from_point;
      line.point2 = todir;

      for (k=0;k<3;k++)
       todir[k] = buff_info->from_point[k] + 
               buff_info->ref_vector[k];

      sts = MAptlnproj(&ret,topt,&line,proj_pt,&t);
      if (!(1&sts)) return (0);

      for (k=0;k<3;k++)
       vec[k] = proj_pt[k] - buff_info->from_point[k];

      dist = sqrt(vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2]);

      if (t < 0) dist = -dist;

      OM_BLOCK_MOVE(proj_pt,buff_info->from_point,sizeof(IGRpoint));

     }
     else
     {
      vec[0] = newpt->x - buff_info->from_point[0];
      vec[1] = newpt->y - buff_info->from_point[1];
      vec[2] = newpt->z - buff_info->from_point[2];

      buff_info->from_point[0] = newpt->x;
      buff_info->from_point[1] = newpt->y;
      buff_info->from_point[2] = newpt->z;
     }

     for (i=0;i<buff_info->num_indices;i++)
     {
          j = buff_info->indices[i];

          u_pole_inx = j % buff_info->u_num_poles;
          v_pole_inx = j / buff_info->u_num_poles;

          j = (v_pole_inx - buff_info->v_start_pl) * surf->u_num_poles +
              (u_pole_inx - buff_info->u_start_pl);
          
          if (surf->rational)
           weight = surf->weights[j];
          else
           weight = 1;

/*
 * If each pole is moving by a different vector then calculate the new
 * vector.
 */
          if (buff_info->vectors)
          {
           for (k=0;k<3;k++)
            vec[k] = dist*buff_info->vectors[3*i+k];
          }

           if (buff_info->dists)
            temp_dist = buff_info->dists[i];
           else
            temp_dist = 1;

            for (k=0;k<3;k++)
             surf->poles[3*j+k] += vec[k]* weight*temp_dist;
     }

   ptset = (struct IGRpointset *) 
      buff_info->buffs[1].geometry.point_set;
  OM_BLOCK_MOVE(buff_info->from_point,&ptset->points[3],sizeof(IGRpoint));
      
   *buffs = buff_info->buffs;
   *num_buffs = buff_info->num_buffs;
   return (TRUE);
}

end implementation EMSsubbs;

