/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  EMSsubbs
     METHOD NAME:  GRdynmod

     Abstract: 
    
        This method is used to dynamically modify the surface. A selected
     pole for modification is input via the argument list and the cursor
     is tracked, redefining this pole dynamically. Only that portion of the
     surface is in dynamic display, that is affected by this pole. If the
     polygon display is 'on', even the affected portion of the polygon-mesh
     wil be in dynamic display.
        If the system state indicates that all dynamics are 'off', the method
     returns as a noop. Otherwise it returns when any non-window event
     occurs.
        
       In this implementation, other potential features of this method
     are ignored. For example: this method can be used to return
     information to the caller that would be sufficient for it to
     perform the dynamic modification itself and also have complete control
     over the process; can be used for modifying composites and complexes.

-----
%SC%    

     The following call-list is with the current implementation:

     message GRvg.GRdynmod (msg, mattyp, mat, NULL, modpole, NULL,
              NULL, NULL)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
      *mattyp      IGRshort       Type of the matrix used to convert to
                                   global coordinate system.

      mat          IGRmatrix      Matrix used for the conversion.

      *modpar      struct         Information about which pole to modify.
                    GRparms        (Currently ignored)

      modpole      IGRpoint       Input point, which could be used to
                                   obtain the pole to be modified by
                                   finding the closest pole.
                                   (Currently being used).

      *action      enum           Specifies the type of action this method
                    GRdyn_flag     should perform.
                                   return_buff - returns dynamics buffer.
                                   free_buff - frees the buffer previously
                                               allocated.
                                   call_dynam - do dynamics (default =NULL)
                                   (Currently ignored. Action performed is
                                    always - call_dynam)

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg         IGRlong        return code.
                                   - MSSUCC if all was well.
                                   - MSNOMEM if memory allocation
                                        failed.   
                                   - MSFAIL on any other error.

      *buff        IGRchar        The dynamics buffer that could be requested
                                   by the caller for performing the dynamics
                                   itself.

      (*func)()    IGRboolean     Pointer to the function that needs to be
                                   called for performing the dynamics.

-----
%MD%

     MODULES AND METHODS INVOKED:

     Methods:  GRgenabsg

     Modules:  dp$dynamics
               BSunwght_p
               MAptpsproj
               BSallocsf
               BSfreesf
               GRssdynmod

-----
%RL%

     RELATIONS REFERENCED:  

          None
-----
%NB%
   

-----
%CH%

     CHANGE HISTORY:
        
        NP      08/24/92 : Modified for ANSI compliance. Added missing typecasts.
	DLB	10/29/91 : Bug - if (rational); 
				 {	      ^^^^----- I removed the ;
				    srf->weight[ii] - crash on SUN.
				 }

        SS      01/27/88 : Modified to display surface as IGRQS.
        SS      10/03/86 : Design date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

     Get the abstract geometry of the surface. Determine the index
   of the pole that is closest to the input point. Decide the poles
   and knots extents about this pole, which form the affected patch.
   Extract the relevant pole, knots, weights (ignore boundaries) and
   create a surface patch. Fill up the fields in the special structure
   that is understood by the dynamically-modifying function: GRssdynmod.
   
----*/
/*EH*/

class implementation EMSsubbs;

#include "EMS.h"
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

# define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

/*
 * Structure used to communicate
 * with the dynamic-modifying
 * function.
 */

struct modbuff_info
   {
   IGRboolean zview_cond;
   IGRboolean is_polydisp;
   IGRboolean is_surfdisp;
   IGRshort num_buffs;
   IGRint u_inx;
   IGRint v_inx;
   IGRboolean rational;
   IGRint p_inx;
   IGRdouble weight;
   IGRpoint  pole;
   struct DPele_header buffs[3];
   };

struct cond_str
{
  IGRboolean  tangency_cond;
  IGRboolean  zview_cond;
};

method GRdynmod (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                 struct GRparms *modpar; IGRpoint modpole; enum GRdyn_flag
                 *action; IGRchar *buff; IGRboolean (*func)())
{
   IGRboolean stat_func;
   IGRint u_bounds[5], v_bounds[5];
   IGRlong stat_OM, msg_loc, dumdum;
   IGRlong num_poles, ptnum;
   IGRlong u_poleinx, v_poleinx, u_start_pl, v_start_pl;
   IGRlong u_end_pl, v_end_pl, u_start_kt, v_start_kt;
   IGRlong u_end_kt, v_end_kt;
   IGRlong u_poleinx_loc, v_poleinx_loc, u_polyinx_loc, v_polyinx_loc;
   IGRlong u_np, v_np, u_nk, v_nk, u_num_seg, v_num_seg;
   IGRlong u, v, i, inx;
   IGRdouble *temp_ptr, *unwpoles;
   IGRdouble u_rules[5], v_rules[5];
   IGRdouble u_ktdel, v_ktdel;
   IGRpoint u_ptset[3], v_ptset[3], point;
   struct IGRbsp_surface *mysrf, *srf;
   struct modbuff_info buff_info;
   struct IGRpointset pointset, pointset0, pointset1;
   struct IGRespy espy0, espy1;
   struct IGResbs esbs;
   struct IGResqbs esqs;
   struct IGRdisplay display0, display1, display2;
  extern    IGRboolean BSunwght_p();
  extern IGRboolean   MAptpsproj();
   IGRint GRssdynmod();
   struct cond_str   *cond;

   *msg = EMS_S_Success;
   stat_OM = OM_S_SUCCESS;

   mysrf = srf = NULL;
   cond = (struct cond_str *)buff;
   buff_info.zview_cond = FALSE;

   /*
    * Get the abstract geometry of this
    * surface.
    */

   GRgetabsg (&msg_loc, mattyp, mat, (IGRchar **)&mysrf, i);
   EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

   /*
    * Get the pole index of the pole closest
    * to the point that has been input. This
    * is the pole that will be modified.
    */

   pointset.num_points = mysrf->u_num_poles * mysrf->v_num_poles;
   unwpoles = NULL;
   if (mysrf->rational)
     {
     unwpoles = (IGRdouble *) om$malloc (size = pointset.num_points * sizeof
                               (IGRpoint));
     EMerr_hndlr (unwpoles == NULL, *msg, EMS_E_NoDynamicMemory, ret_end);

     stat_func = BSunwght_p (&msg_loc, mysrf->poles, mysrf->weights,
                             &pointset.num_points, unwpoles);
     EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

     pointset.points = unwpoles;
     }
   else
     pointset.points = mysrf->poles;

   stat_func = MAptpsproj (&msg_loc, modpole, &pointset, point, &ptnum);
   EMerr_hndlr (! stat_func || EMis_error (msg_loc), *msg, EMS_E_MAerror,
    ret_end);

   if (unwpoles) 
     {
     om$dealloc (ptr = unwpoles);
     unwpoles = NULL;
     }
   u_poleinx = (ptnum - 1) % mysrf->u_num_poles;
   v_poleinx = (ptnum - 1) / mysrf->u_num_poles;

  /*
   * Set the buff_info zview_cond to be used in the dynamics
   * function.   dhm   11/15/88.
   */

  if (cond->zview_cond)
  {
    buff_info.zview_cond = TRUE;

    buff_info.pole[0] = point[0];
    buff_info.pole[1] = point[1];
    buff_info.pole[2] = point[2];
  }

   /*
    * Get the pole and the knot
    * extents for that portion of
    * the surface that is affected
    * by the pole to be modified.
    */

   u_start_pl = u_poleinx - (mysrf->u_order - 1);
   if (u_start_pl < 0) u_start_pl = 0;
   u_start_kt = u_start_pl;
   v_start_pl = v_poleinx - (mysrf->v_order - 1);
   if (v_start_pl < 0) v_start_pl = 0;
   v_start_kt = v_start_pl;

   u_end_pl = u_poleinx + (mysrf->u_order - 1);
   if (u_end_pl > mysrf->u_num_poles - 1) u_end_pl = mysrf->u_num_poles - 1;
   u_end_kt = u_end_pl + mysrf->u_order;
   v_end_pl = v_poleinx + (mysrf->v_order - 1);
   if (v_end_pl > mysrf->v_num_poles - 1) v_end_pl = mysrf->v_num_poles - 1;
   v_end_kt = v_end_pl + mysrf->v_order;

   u_np = u_end_pl - u_start_pl + 1;
   u_nk = u_np + mysrf->u_order;
   v_np = v_end_pl - v_start_pl + 1;
   v_nk = v_np + mysrf->v_order;

   /*
    * The resulting boundaries on this patch (clipped set of
    * the original) boundaries should be computed here.
    */

   /*
    * Allocate space for the surface-patch
    * that is the affected portion 
    * of this surface. Fill this patch
    * with relevant data.
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
   * Check to see how many polygon
   * segments will be drawn. Also
   * obtain the modified pole index
   * relative to this extracted patch.
   * Obtain the pole index at which the
   * polygon display will begin for the
   * extracted patch (One segment on
   * either side of the modified pole).
   */

   u_poleinx_loc = u_poleinx - u_start_pl;
   v_poleinx_loc = v_poleinx - v_start_pl;
   u_polyinx_loc = u_poleinx_loc - 1;
   v_polyinx_loc = v_poleinx_loc - 1;
   u_num_seg = 2;
   v_num_seg = 2;
   if (u_polyinx_loc < 0) 
      {
      u_polyinx_loc =  u_poleinx_loc;
      u_num_seg = 1;
      }
   else if (u_polyinx_loc + 2 >= srf->u_num_poles)
      u_num_seg = 1;
   if (v_polyinx_loc < 0) 
      {
      v_polyinx_loc =  v_poleinx_loc;
      v_num_seg = 1;
      }
   else if (v_polyinx_loc + 2 >= srf->v_num_poles)
      v_num_seg = 1;

   /*
    * Initialize the control information
    * in the buffer to be communicated to 
    * the dynamic modify function.
    */

   stat_OM = om$send(msg = message GRvg.GRgetattr (&msg_loc, (IGRchar *)&esbs),
              targetid = my_id);
   EMomerr_exit (stat_OM, ret_end);
 
   buff_info.is_polydisp = esbs.is_polydis;
   buff_info.is_surfdisp = esbs.is_surfdis;
   buff_info.num_buffs = (buff_info.is_polydisp ? 2 : 0) +
                         (buff_info.is_surfdisp ? 1 : 0);
   buff_info.u_inx = (u_poleinx_loc - u_polyinx_loc) * 3;
   buff_info.v_inx = (v_poleinx_loc - v_polyinx_loc) * 3;
   if (buff_info.rational = srf->rational)  /*DLB 10/29/91 was if (..); */
     {
     buff_info.p_inx = (srf->u_num_poles * v_poleinx_loc +
                        u_poleinx_loc) * 3;
     buff_info.weight = srf->weights[srf->u_num_poles * v_poleinx_loc +
                                     u_poleinx_loc];
     }

   /*
    * Fill in the element display
    * header information. There will
    * be atmost three headers (two polygons
    * and the other the surface). The
    * three headers are filled anyway.
    */

/* display0.rgb_value = 0; */
   display0.color = ME.GRvg->display_attr.color;
   display0.weight = ME.GRvg->display_attr.weight;
   display0.style = 4; /*ME.GRvg->display_attr.style;*/

   espy0.is_closed = FALSE;
   pointset0.num_points = u_num_seg + 1;
   if (! srf->rational)
     pointset0.points = &srf->poles[(srf->u_num_poles * v_poleinx_loc +
                                    u_polyinx_loc) * 3];
   else
     {
     pointset0.points = temp_ptr = (IGRdouble *) u_ptset;
     for (u=0; u<u_num_seg+1; u++)
       for (i=0; i<3; i++)
         *temp_ptr++ = srf->poles[(srf->u_num_poles * v_poleinx_loc +
                                  u_polyinx_loc + u) * 3 + i] / 
                       srf->weights[srf->u_num_poles * v_poleinx_loc +
                                    u_polyinx_loc + u];
     }
   dp$build_dis_buffer (buffer = &buff_info.buffs[0], type = IGRPY,
    display_att = &display0, ele_spec_att = &espy0, geometry = &pointset0);


/* display1.rgb_value = 0; */
   display1.color = ME.GRvg->display_attr.color;
   display1.weight = ME.GRvg->display_attr.weight;
   display1.style = 4; /*ME.GRvg->display_attr.style;*/

   espy1.is_closed = FALSE;
   pointset1.num_points = v_num_seg + 1;
   pointset1.points = temp_ptr = (IGRdouble *) v_ptset;
   for (v=0; v<v_num_seg+1; v++)
     for (i=0; i<3; i++)
       *temp_ptr++ = srf->poles[(srf->u_num_poles * 
                                (v_polyinx_loc + v) +
                                u_poleinx_loc) * 3 + i] /
                     (srf->rational ? srf->weights[srf->u_num_poles *
                                       (v_polyinx_loc + v) + u_poleinx_loc]
                                    : 1.0);
   dp$build_dis_buffer (buffer = &buff_info.buffs[1], type = IGRPY,
    display_att = &display1, ele_spec_att = &espy1, geometry = &pointset1);


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

   esqs.u_rules = 5;
   esqs.v_rules = 5;
   esqs.is_polydis = FALSE;
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

   dp$build_dis_buffer (buffer = &buff_info.buffs[2], type = IGRQS,
    display_att = &display2, ele_spec_att = &esqs, geometry = srf);
         
   /*
    * Call the dynamics functions
    * that actually tracks the cursor.
    * This function returns if dynamics
    * was set to off in the system or
    * if an event (other than a window
    * event) occurred.
    */

   dp$dynamics (dyn_fun = GRssdynmod, information = &buff_info);

ret_end:
   if (srf) 
     BSfreesf (&msg_loc, srf);
   if (unwpoles) 
     om$dealloc (ptr = unwpoles);

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

IGRint GRssdynmod (buff_info, newpt, mtx, objs, num_objs, buffs, num_buffs,
                   dummy1, dummy2, dummy3, dummy4, dummy5, dummy6)
struct modbuff_info *buff_info;
struct EX_button *newpt;
IGRdouble *mtx;
struct GRid **objs;
IGRint *num_objs;
struct DPele_header **buffs;
IGRint *num_buffs;
IGRchar *dummy1, *dummy2, *dummy3;
IGRchar *dummy4, *dummy5, *dummy6;
{
   IGRdouble *temp_addr, weight;

   /*
    * Added code to map the curser point to the z coordinate of the view
    * if requested.   dhm  11/15/88.
    */

   if (buff_info->zview_cond)
   {
     IGRlong    status, msg_loc, EMmap_button_to_z_view();

     status = EMmap_button_to_z_view(&msg_loc, buff_info->pole, newpt);
     if (! (1&status) )  return(FALSE);
     if (! (1&msg_loc) )  return(FALSE);
   }

   if (! buff_info->rational || buff_info->is_polydisp)
     {
     temp_addr = &buff_info->buffs[0].geometry.point_set->
                  points[buff_info->u_inx];
     *temp_addr++ = newpt->x;
     *temp_addr++ = newpt->y;
     *temp_addr++ = newpt->z;
     }
   
   if (buff_info->is_polydisp)
     {
     temp_addr = &buff_info->buffs[1].geometry.point_set->
                  points[buff_info->v_inx];
     *temp_addr++ = newpt->x;
     *temp_addr++ = newpt->y;
     *temp_addr++ = newpt->z;
     }

   if (buff_info->rational && buff_info->is_surfdisp)
     {
     temp_addr = &buff_info->buffs[2].geometry.bspsurf->
                  poles[buff_info->p_inx];
     weight = buff_info->weight;
     *temp_addr++ = newpt->x * weight;
     *temp_addr++ = newpt->y * weight;
     *temp_addr++ = newpt->z * weight;
     }

   *buffs = (buff_info->is_polydisp) ? buff_info->buffs : &buff_info->buffs[2];
   *num_buffs = buff_info->num_buffs;
   return (TRUE);
}


end implementation EMSsubbs;
