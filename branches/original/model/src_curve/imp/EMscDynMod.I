/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRsubbc
     METHOD NAME:  GRdynmod

     Abstract: 
    
        This method is used to dynamically modify the curve. A selected
     pole for modification is input via the argument list and the cursor
     is tracked, redefining this pole dynamically. Only that portion of the
     curve is in dynamic display, that is affected by this pole. If the
     polygon display is 'on', even the affected portion of the polygon-display
     will be in dynamic display.
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

        NAME       DATA TYPE  	            DESCRIPTION
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

        NAME       DATA TYPE  	            DESCRIPTION
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
               MAptpsproj
               BSalloccv
               BSfreecv
               GRscdynmod
               OM_malloc
               OM_dealloc

-----
%RL%

     RELATIONS REFERENCED:  

          None
-----
%NB%
   

-----
%CH%

     CHANGE HISTORY:
	
    SS  10/03/86 : Design date.
    dhm 06/13/88 : Changed to maintain tangency at the endpoints 
                   if requested.
    dhm 11/14/88 : Changed to maintain z view if requested. 
    dhm 12/14/91 : fix for TR #91n3894. Problem with multiply
                   knots in a span.
    dhm 01/20/92 : fix problem with memory not getting freed.
    Sudha  06/16/93     Modified for BSprototype ansification
    dhm 01/11/94 : fix display problem by calling BSactivsplt.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

     Get the abstract geometry of the curve. Determine the index
   of the pole that is closest to the input point. Decide the poles
   and knots extents about this pole, which form the affected patch.
   Extract the relevant pole, knots, weights (ignore boundaries) and
   create a curve patch. Fill up the fields in the special structure
   that is understood by the dynamically-modifying function: GRssdynmod.
   
----*/
/*EH*/

class implementation GRsubbc;

#include "EMS.h"
#include <stdio.h>
#include "OMerrordef.h"
#include "OMminimum.h"     /* for gocmacros.h  */
#include "OMmacros.h"
#include "igrtypedef.h"     /* for gocmacros.h  */
#include "gocmacros.h"     /* GRgetabsg macro  */
#include "igrdp.h"
#include "dpstruct.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "msdef.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "maptpspro.h"
#include "maptlnpro.h"
#include "bsfreecv.h"
/*#include "bscvkttol2.h"*/
#include "bsalloccv.h"
#include "bsactivsplt.h"
#include "bsmdstwptar.h"
/*
 * Structure used to communicate
 * with the dynamic-modifying
 * function.
 */

struct modbuff_info
   {
   IGRboolean tangency_cond;
   IGRboolean zview_cond;
   IGRboolean is_polydisp;
   IGRboolean is_curvedisp;
   IGRshort num_buffs;
   IGRint poly_inx;
   IGRboolean rational;
   IGRint pole_inx;
   IGRdouble weight;
   IGRpoint  pole;
   struct DPele_header buffs[2];
   struct IGRline  line;
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
  IGRboolean stat_func, tst_plan = TRUE;
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRint  ind1;
  IGRint poleinx_loc, polyinx_loc, dyninx;
  IGRlong stat_OM, msg_loc, i, j;
  IGRlong ptnum, poleinx;
  IGRlong num_seg;
  IGRdouble *temp_ptr, dist;
  IGRdouble *temp_poles;
  IGRpoint ptset[3], point;
  struct IGRbsp_curve *crv, *buffcrv;
  struct modbuff_info buff_info;
  struct IGRpointset pointset;
  struct IGRespy espy;
  struct IGResbc esbc;
  struct IGRdisplay display0, display1;
  IGRint GRscdynmod();
  struct cond_str   *cond;

  *msg = MSSUCC;
  stat_OM = OM_S_SUCCESS;
  strcpy (errmsg, "GRsubbc.GRdynmod\n");
  buffcrv = NULL;
  temp_poles = NULL;
  cond = (struct cond_str *) buff;
  buff_info.tangency_cond = FALSE;
  buff_info.zview_cond = FALSE;

  /*
   * Get this curves abstract
   * geometry.
   */

  GRgetabsg (&msg_loc, mattyp, mat, (char **) &crv, i);
  EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);

  /*
   * Get the pole index of the closest
   * pole to the input pole. This is
   * the pole that is to be modified.
   */

  pointset.num_points = crv->num_poles;
  pointset.points = crv->poles;
  if (crv->rational)
  {
    temp_poles = (IGRdouble *) om$malloc(size = crv->num_poles * sizeof
                                (IGRpoint));
    EMerr_hndlr (temp_poles == NULL, *msg, MSNOMEM, ret_end);
    for (i=0; i<crv->num_poles; i++)
      for (j=0; j<3; j++)
        temp_poles[i*3+j] = crv->poles[i*3+j] / crv->weights[i];
    pointset.points = (IGRdouble *) temp_poles;
  }

  stat_func = MAptpsproj (&msg_loc, modpole, &pointset, point, &ptnum);
  EMerr_hndlr(!stat_func || EMis_error(msg_loc), *msg, msg_loc, ret_end);

  poleinx = ptnum - 1;

  /*
   * Set the buff_info zview_cond to be used in the dynamics
   * function.   dhm   11/14/88.
   */

  if (cond->zview_cond)
  {
    buff_info.zview_cond = TRUE;

    buff_info.pole[0] = point[0];
    buff_info.pole[1] = point[1];
    buff_info.pole[2] = point[2];
  }

  /*
   * Set the tangent line to be either the first two poles or the last two
   * poles depending on the endpoints given.  dhm  6/13/88.
   */

  else if (cond->tangency_cond)
  {
    buff_info.tangency_cond = TRUE;

    if ( (poleinx == 0) || (poleinx == 1) )  /* first two poles */
    {
      buff_info.line.point1 = &pointset.points[0];
      buff_info.line.point2 = &pointset.points[3];
    }
    else   /* last two poles */
    {
      IGRint  last_poleinx;

      last_poleinx = (crv->num_poles - 1) * 3;
      buff_info.line.point1 = &pointset.points[last_poleinx-3];
      buff_info.line.point2 = &pointset.points[last_poleinx];
    }

  }   /* end else if tangency_cond */


  if (temp_poles) 
  {
    om$dealloc(ptr = temp_poles);
    temp_poles = NULL;
  }

/******************* Don't do this any more ******************************

   * Get the pole and the knot
   * extents for that portion of
   * the curve that is affected
   * by the pole to be modified.


  start_pl = poleinx - (crv->order - 1);
  if (start_pl < 0) start_pl = 0;
  start_kt = start_pl;

  end_pl = poleinx + (crv->order - 1);
  if (end_pl > crv->num_poles - 1) end_pl = crv->num_poles - 1;
  end_kt = end_pl + crv->order;

  np = end_pl - start_pl + 1;
  nk = np + crv->order;
***************************************************************************/

  /*
   * Allocate space for the curve
   * that is the affected portion 
   * of this curve. Fill this curve
   * with relevant data.
   */

  BSalloccv (crv->order, crv->num_poles, crv->rational, crv->num_boundaries,
             &buffcrv, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, MSNOMEM, ret_end);

  /*
   * TR 119312743 - fix for the extracted curve not displaying correctly.
   * Call BSactivsplt to return the portion of the curve effected by this
   * pole being moved. The effected portion is that part at span knots[poleinx]
   * to knots[poleinx + crv->order].  dhm.
   */

  (void)BSactivsplt(&msg_loc, crv, &crv->knots[poleinx],
                    &crv->knots[poleinx+crv->order], buffcrv, &tst_plan);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

/*********** Don't do this any more. Call BSactivesplt *******************

  /*
   * Copy control information
   *
  buffcrv->order = crv->order;
  buffcrv->periodic = crv->periodic;
  buffcrv->non_uniform = crv->non_uniform;
  buffcrv->planar = crv->planar;
  buffcrv->phy_closed = crv->phy_closed;

  /*
   * Copy the relevant poles
   *
  from_ptr = &crv->poles[start_pl*3];
  to_ptr = buffcrv->poles;
  for (i=0; i<np*3; i++)
    *to_ptr++ = *from_ptr++;
  buffcrv->num_poles = np;

  /*
   * Copy the relevant knots
   *
  from_ptr = &crv->knots[start_kt];
  to_ptr = buffcrv->knots;
  for (i=0; i<nk; i++)
    *to_ptr++ = *from_ptr++;
  buffcrv->num_knots = nk;

  /*
   * Copy the relevant weights
   * if rational
   *
  buffcrv->rational = crv->rational;
  if (buffcrv->rational)
    {
    from_ptr = &crv->weights[start_pl];
    to_ptr = buffcrv->weights;
    for (i=0; i<np; i++)
      *to_ptr++ = *from_ptr++;
    }
  else 
    buffcrv->weights = NULL;

  /*
   * Copy that portion of the
   * boundary that falls within
   * the affected region.
   *
  total_hole = FALSE;
  spar_val = buffcrv->knots[buffcrv->order - 1];
  epar_val = buffcrv->knots[buffcrv->num_poles];
  num = 0;
  for (i=0; i<crv->num_boundaries; i++)
    {
    if (crv->bdrys[i*2] > spar_val)
      {
      if (crv->bdrys[i*2] >= epar_val)
        break;
      else
        {
        if (crv->bdrys[i*2+1] >= epar_val)
          {
          buffcrv->bdrys[num*2] = crv->bdrys[i*2];
          buffcrv->bdrys[num*2+1] = epar_val;
          num++;
          break;
          }
        else
          {
          buffcrv->bdrys[num*2] = crv->bdrys[i*2];
          buffcrv->bdrys[num*2+1] = crv->bdrys[i*2+1];
          num++;
          }
        }
      }
    else
      {
      if (crv->bdrys[i*2+1] > spar_val)
        {
        if (crv->bdrys[i*2+1] >= epar_val)
          {
          total_hole = TRUE;
          break;
          }
        else
          {
          buffcrv->bdrys[num*2] = spar_val;
          buffcrv->bdrys[num*2+1] = crv->bdrys[i*2+1];
          num++;
          }
        }
      }
    }
  if (total_hole)
    goto ret_end;
  else if (num)
    buffcrv->num_boundaries = num;
  else
    {
    buffcrv->num_boundaries = 0;
    buffcrv->bdrys = NULL;
    }

  /*
   * Fix for TR#91N3894
   * If the knots[order] meets the degenerate case, then the poles, knots, and
   * weights need to be shifted left until it is no longer degenerate.  If the
   * knots[num_poles] meets the degenerate test, then the end pole, knot, and
   * weight need to be dropped until it is no longer degenerate.  This happens
   * when the pole on either side of a merged curve's merge point is moved.
   * dhm  12/14/91
   *
   * NOTE: BSactivsplt will handle degenerate knots.

  BScvkttol2( crv->order, crv->knots, crv->num_poles, crv->poles, crv->weights,
              &knot_tol, &msg_loc );
  if ( msg_loc != BSSUCC )
  {
    *msg = MSFAIL;
    goto ret_end;
  }

  start_degenerate = TRUE;
  while ( start_degenerate )
  {
    knot_val = buffcrv->knots[buffcrv->order] -
               buffcrv->knots[(buffcrv->order-1)];

    knot_val = ( (knot_val >= 0) ? knot_val : -(knot_val) );

    if ( knot_val <= knot_tol )
    {
      buffcrv->num_poles--;
      buffcrv->num_knots--;
      start_pl++;

      /*
       * Fix memory free problem.  dhm  1/20/92
       *

      size = sizeof(IGRdouble) * buffcrv->num_poles * 3;
      temp_ptr = &buffcrv->poles[3];
      OM_BLOCK_MOVE(temp_ptr, buffcrv->poles, size);

      size = sizeof(IGRdouble) * buffcrv->num_knots;
      temp_ptr = &buffcrv->knots[1];
      OM_BLOCK_MOVE(temp_ptr, buffcrv->knots, size);

      if ( buffcrv->rational )
      {
        size = sizeof(IGRdouble) * buffcrv->num_poles;
        temp_ptr = &buffcrv->weights[1];
        OM_BLOCK_MOVE(temp_ptr, buffcrv->weights, size);
      }

/*
      buffcrv->poles = &buffcrv->poles[3];
      buffcrv->knots = &buffcrv->knots[1];
      if ( buffcrv->rational )
        buffcrv->weights = &buffcrv->weights[1];
*
    }
    else
      start_degenerate = FALSE;

  }  /* end while *

  end_degenerate = TRUE;
  while ( end_degenerate )
  {
    knot_val = buffcrv->knots[buffcrv->num_poles] -
               buffcrv->knots[(buffcrv->num_poles-1)];

    knot_val = ( (knot_val >= 0) ? knot_val : -(knot_val) );

    if ( knot_val <= knot_tol )
    {
      buffcrv->num_poles--;
      buffcrv->num_knots--;
    }
    else
      end_degenerate = FALSE;

  }  /* end while *

  if ( buffcrv->num_poles < buffcrv->order )
  {
    *msg = MSFAIL;
    goto ret_end;
  }

*****************************************************************************/


  /*
   * Check to see how many polygon
   * segments will be drawn. Also
   * obtain the modified pole index
   * relative to this extracted curve.
   * Obtain the pole index at which the
   * polygon display will begin for the
   * extracted curve (One segment on
   * either side of the modified pole).
   */

  (void)BSmdstwptar(1, &point, (crv->rational ? &crv->weights[poleinx] : NULL),
                    buffcrv->num_poles,
                    (IGRpoint *)buffcrv->poles,
                    (buffcrv->rational ? buffcrv->weights : NULL),
                    &ind1, &poleinx_loc, &dist, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

/*
  poleinx_loc = poleinx - start_pl;
*/
  polyinx_loc = poleinx_loc - 1;
  num_seg = 2;
  if (polyinx_loc < 0) 
  {
    polyinx_loc = poleinx_loc;
    num_seg = 1;
  }
  else if (polyinx_loc + 2 >= buffcrv->num_poles)
    num_seg = 1;

  dyninx = (poleinx_loc - polyinx_loc) * 3;

  /*
   * Initialize the control information
   * in the buffer to be communicated to 
   * the dynamic modify function.
   */

  stat_OM = om$send(mode = OM_e_wrt_object,
                    msg = message GRvg.GRgetattr (&msg_loc, (char *) &esbc),
                    senderid = my_id,
                    targetid = my_id);
  EMomerr_hndlr (stat_OM, ret_end, errmsg);

  buff_info.is_polydisp = esbc.is_polydis;
  buff_info.is_curvedisp = esbc.is_curvedis;
  buff_info.num_buffs = (buff_info.is_polydisp ? 1 : 0) +
                        (buff_info.is_curvedisp ? 1 : 0);
  buff_info.poly_inx = dyninx;

  if (buff_info.rational = buffcrv->rational)
  {
    buff_info.pole_inx = poleinx_loc * 3;
    buff_info.weight = buffcrv->weights[poleinx_loc];
  }

  /*
   * Fill in the element display
   * header information. There will
   * be atmost two headers (one polygon
   * and the other the curve). The
   * two headers are filled in anyway.
   */

/*display0.rgb_value = 0; */
  display0.color = ME.GRvg->display_attr.color;
  display0.weight = ME.GRvg->display_attr.weight;
  display0.style = 4; /*ME.GRvg->display_attr.style;*/

  espy.is_closed = FALSE;
  pointset.num_points = num_seg + 1;

  if (! crv->rational)
    pointset.points = &buffcrv->poles[polyinx_loc*3];
  else
  {
    pointset.points = temp_ptr = (IGRdouble *) ptset;
    for (i=0; i<num_seg+1; i++)
      for (j=0; j<3; j++)
        *temp_ptr++ = buffcrv->poles[(polyinx_loc + i) * 3 + j] /
                      buffcrv->weights[polyinx_loc + i];
  }

  dp$build_dis_buffer (buffer = &buff_info.buffs[0],
                       type = IGRPY,
                       display_att = &display0,
                       ele_spec_att = &espy,
                       geometry = &pointset);

/*display1.rgb_value = 0; */
  display1.color = ME.GRvg->display_attr.color;
  display1.weight = ME.GRvg->display_attr.weight;
  display1.style = ME.GRvg->display_attr.style;

  esbc.is_polydis = FALSE;
  esbc.is_curvedis = TRUE;
  dp$build_dis_buffer (buffer = &buff_info.buffs[1],
                       type = IGRBC,
                       display_att = &display1,
                       ele_spec_att = &esbc,
                       geometry = buffcrv);

  /*
   * Call the dynamics functions
   * that actually tracks the cursor.
   * This function returns if dynamics
   * was set to off in the system or
   * if an event (other than a window
   * event) occurred.
   */

  dp$dynamics (dyn_fun = GRscdynmod,
               information = &buff_info);


ret_end:
   if (buffcrv) BSfreecv (&msg_loc, buffcrv);
   if (temp_poles) free (temp_poles);
   return (stat_OM);
}




/*
 * This function is the one that gets called repeatedly
 * by DPdynamics whenever any change occurs in the cursor
 * position. The argument list for this fuction is standard.
 * Some of the arguments are not made use of in this function.
 * The most significant arguments here are the 'buff_info' and 
 * 'newpt'; the latter is used to modify the former along with
 * the constrol information in 'buff_info'.
 */

#argsused
IGRint GRscdynmod (buff_info, newpt, mtx, objs, num_objs, buffs, num_buffs,
                     dummy1, dummy2, dummy3, dummy4, dummy5, dummy6)
struct modbuff_info *buff_info;
struct EX_button *newpt;
IGRdouble *mtx;
struct GRid **objs;
IGRint *num_objs;
struct DPele_header **buffs;
IGRint *num_buffs;
IGRchar *dummy1, *dummy2, *dummy3;
IGRchar **dummy4, **dummy5, **dummy6;
{
   IGRdouble *temp_addr, weight;
   IGRlong   msg_loc;

  /*
   * Added code to map the curser point to the z coordinate of the view
   * if requested.   dhm  11/14/88.
   */

  if (buff_info->zview_cond)
  {
    IGRlong    status, EMmap_button_to_z_view();

    status = EMmap_button_to_z_view(&msg_loc, buff_info->pole, newpt);
    if (! (1&status) )  return(FALSE);
    if (! (1&msg_loc) )  return(FALSE);
  }

  /*
   * Added code to project the newpt onto the tangency line
   * if maintaining tangency was requested.  dhm  6/13/88.
   */

  else if (buff_info->tangency_cond)
  {
    IGRboolean    sts;
    IGRpoint      point, proj_pt;
    IGRdouble     t;

    point[0] = newpt->x;
    point[1] = newpt->y;
    point[2] = newpt->z;

    sts = MAptlnproj(&msg_loc, point, &buff_info->line, proj_pt, &t);
    if (!sts)  return(FALSE);

    newpt->x = proj_pt[0];
    newpt->y = proj_pt[1];
    newpt->z = proj_pt[2];

  }  /* end if tangency_cond */


   if (! buff_info->rational || buff_info->is_polydisp)
     { 
     temp_addr = &buff_info->buffs[0].geometry.point_set->
                  points[buff_info->poly_inx];
     *temp_addr++ = newpt->x;
     *temp_addr++ = newpt->y;
     *temp_addr++ = newpt->z;
     }

   if (buff_info->rational && buff_info->is_curvedisp)
     {
     temp_addr = &buff_info->buffs[1].geometry.bspcurve->
                  poles[buff_info->pole_inx];
     weight = buff_info->weight;
     *temp_addr++ = newpt->x * weight;
     *temp_addr++ = newpt->y * weight;
     *temp_addr++ = newpt->z * weight;
     }

   *buffs = (buff_info->is_polydisp) ? buff_info->buffs : &buff_info->buffs[1];
   *num_buffs = buff_info->num_buffs;
   return (TRUE);
}

end implementation GRsubbc;
