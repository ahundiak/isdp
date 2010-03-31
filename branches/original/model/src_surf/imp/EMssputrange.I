/* ###################   APOGEE COMPILED   ################## */

class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
#include "EMSssprops.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include <stdio.h>

#include "gocmacros.h"
#include "EMSsplitdef.h"
#include "emsdef.h"
#include "EMSsubbs.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSsfparms.h"
#include "bserr.h"
#include "bsparameters.h"
#include "madef.h"
#include "emssfdef.h"
#include "EMSssprops.h"
#include "grerr.h"
#include "maidmx.h"
#include "ma2pt2di.h"
#include "bssfkttol2.h"
#include "bsfreesf.h"
#include "bsbx2.h"

/*ARGSUSED*/

/*
DESCRIPTION

This method puts the minimum possible range of the surface in the rtree.
 It is called to do so when the surface gets 1) Constructed 2) Modified -
 2a) Geometric Modification or 2b) Topological modification.
 3) The polygon is toggled.

HISTORY 

SAM	06 Jun 1988 Creation.
RC  02/02/89    If the loopset range degenerates to a line,
                increment it by knot_tol. This is done such that
                partial surface extraction does not fail.
RC  03/23/89    Replaced EFsspbtol_by_geom () by BSsfkttol2() as
                it adjusts the partol if exceeds a defined constant.
RC  12/29/89    Added some code for debugging purposes.
NP  08/26/92    Modified for ANSI compliance. Added typecasts.
Sudha7/07/93    Modified for BSprototypes ansification

*/

extern OMuword OPP_EMSelpcone_class_id, OPP_EMSelpcyl_class_id, 
			   OPP_EMSproject_class_id;

extern IGRshort draw_boxes_around_the_range;

from OMrtree import find_key;

#define NO_WINDOW_LOOPSET 	    	0
#define NO_STATUS_MESSAGES_WANTED	0
#define CUT_OFF_AREA			0.85
#define ON				1
#define OFF				0

#define GET_RANGE(range_ptr, range, gotolabel) \
        if(range_ptr) \
         OM_BLOCK_MOVE(range_ptr, range, sizeofSIXdoubles); \
        else \
   	{ \
   	 CHECK_GET_GEOM(new_geom, new_geom_ptr) \
         { \
          IGRlong num_poles; \
   num_poles = new_geom_ptr->u_num_poles * new_geom_ptr->v_num_poles; \
   masts = BSbx2(&rc, &num_poles, (IGRpoint *)new_geom_ptr->poles, \
		 new_geom_ptr->weights, (IGRdouble *)range, (IGRdouble *)&range[3]); \
   EMerr_hndlr(!masts, *EMmsg, EMS_E_BSerror, gotolabel); \
         } \
        } \

#define CHECK_GET_GEOM(ptrin, ptrout) \
         if(!ptrout) \
         { \
          if(ptrin) \
           ptrout = ptrin; \
	  else \
	  { \
	   IGRlong i; \
	   masts = GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS); \
           GRgetabsg(EMmsg, &grmd_env.md_env.matrix_type, \
		     grmd_env.md_env.matrix, (IGRchar **)&ptrout, i); \
    	   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup); \
	  } \
	 } \

#define IS_RTREE_RANGE_GOOD \
        (ME.EMSsubbs->ss_props & EMSIS_RTREE_RANGE_GOOD) \

#define SURF_RTREE_BIT_SET(on_off)\
    	if(on_off == ON) \
         ME.EMSsubbs->ss_props |=  EMSIS_RTREE_RANGE_GOOD; \
        else \
         ME.EMSsubbs->ss_props &= ~EMSIS_RTREE_RANGE_GOOD; \

#define IF_LS_AREA_BELOW_CURRENT_CUT_OFF_AREA(checked_area,current_area) \
        if(checked_area <= (IGRuchar)(CUT_OFF_AREA * current_area)) \
         
#define TRY_TOPOLOGY_EXIT \
        if( (surf_change == TOPOLOGICAL) && !IS_RTREE_RANGE_GOOD) \
         goto wrapup; \

#define BSbx2_type_surfs \
    ((type==EMfreeform_surface) || (type==EMproject) || (type==EMrevol)) \

#define POLYGON_TOGGLE_ON \
        ((surf_change == POLYGON_TOGGLE) && (polygon_on)) \

#define POLYGON_TOGGLE_OFF \
        ((surf_change == POLYGON_TOGGLE) && (!polygon_on)) \

#define POLYGON_TOGGLE_OFF_EXIT_LIST \
        (POLYGON_TOGGLE_OFF && BSbx2_type_surfs) \

#define TRY_POLYGON_TOGGLE_OFF_EXIT \
        if(POLYGON_TOGGLE_OFF_EXIT_LIST) \
	 goto wrapup; \

#define TRY_POLYGON_TOGGLE_ON_EXIT \
        if(POLYGON_TOGGLE_ON && !IS_RTREE_RANGE_GOOD) \
	 goto wrapup; \

#define TRY_TOPLOGY_POLYGON_ON_EXIT \
        if( (surf_change == TOPOLOGICAL) && polygon_on) \
         goto wrapup; \

from EMSloopset import EMbounded_uv_range, EMset_props, EMget_props;


method EMput_range_in_rtree(
 IGRlong *EMmsg;
 struct IGRbsp_surface *new_geom;
 GRrange old_range;
 GRrange new_range;
 IGRuchar surf_change;
 struct GRid *md_grid)
{
  IGRlong    OM_stat, our_dumdum;
  IGRboolean better_range_found, masts;
  IGRdouble  ls_range[4], mid_uv[2], ls_uv_area, knot_tol;
  struct IGRbsp_surface *part_surf = NULL, *new_geom_ptr = NULL,
                        *surf_old = NULL;
  struct GRvg_construct construct_list;
  IGRuchar uchar_new_area = 100, *uchar_old_area;
  GRclassid iso_patch_classid, parent_classid;

  IGRshort across_seam;
  IGRint UV_SPLIT;
  struct EMsurface_params new_params;
  BSrc rc;
	
  IGRint sizeofSIXdoubles = 6*sizeof(IGRdouble);
  GRrange old_range_buff, new_range_buff;

IGRushort ls_props, type, new_params_type = EMfreeform_surface;
IGRboolean rng_calc_by_extraction = FALSE;
IGRuint count;
OM_S_CHANSELECT to_loopset;
struct GRmd_env grmd_env; /* HAS IDENTITY MATRIX IN IT, FOR THINGS TO BE
						        IN LOCAL */
struct GRpost_info post_info;
extern IGRboolean EFmodify_surface_rtree_range(), GRabsg_del(),
	          GRabsg_del_by_objid();
IGRboolean polygon_on, had_a_shot_at_rtree_modification = FALSE;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg  = EMS_S_Success;
  new_params.params.project.curve.knots = NULL;
  new_params.params.project.curve.poles = NULL;
  new_params.params.project.curve.weights = NULL;
  new_params.params.revolve.curve.knots = NULL;
  new_params.params.revolve.curve.poles = NULL;
  new_params.params.revolve.curve.weights = NULL;

  polygon_on = ((ME.EMSsubbs->ss_props & EMSIS_POLYDIS) ? TRUE : FALSE);

  TRY_POLYGON_TOGGLE_ON_EXIT

  TRY_TOPLOGY_POLYGON_ON_EXIT

  post_info.construct_flag=((surf_change==CONSTRUCTIONAL) ? TRUE : FALSE);
  

  better_range_found = FALSE;

  uchar_old_area = &ME.EMSsubbs->ls_area_for_rtree;	

  masts = MAidmx(EMmsg, grmd_env.md_env.matrix);
  EMerr_hndlr(!masts, *EMmsg, EMS_E_BSerror, wrapup);

  grmd_env.md_env.matrix_type = 2;
  grmd_env.md_id.objid = md_grid->objid;
  grmd_env.md_id.osnum = md_grid->osnum;
  
  OM_stat = om$send(msg = message EMSsurface.EMget_params
                     	(EMmsg, NULL, &grmd_env, &type, NULL),
		    targetid = my_id);
  EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_BSerror, wrapup);
  
  if(!polygon_on)
  {
  to_loopset.type = OM_e_addr;
  to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

  OM_stat = om$get_channel_count(object = me, p_chanselect = &to_loopset,
  							 count = &count);
	
  if(count)
  {
   OM_stat = om$send(msg = message EMSloopset.EMget_props(
			    EMmsg, &ls_props),
	             p_chanselect = &to_loopset);
   EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_LoopsetError, wrapup);

   if( !(ls_props & EMLS_NATURAL))
     rng_calc_by_extraction = TRUE;
   else /* if loopset is natural */
   {
    TRY_TOPOLOGY_EXIT
    TRY_POLYGON_TOGGLE_OFF_EXIT
   }
  }
  else /* if !count */
  {
   TRY_TOPOLOGY_EXIT
   TRY_POLYGON_TOGGLE_OFF_EXIT
  }

/* Assumption: Changes in geometry not making change in UV. */
/* Optimization can be done, for changes in geometry (move, copy etc:
    pure translation transformations)
*/
 if(rng_calc_by_extraction)
  {
   OM_stat = om$send(msg = message EMSloopset.EMbounded_uv_range(
							EMmsg,
							ls_range,
							&ls_uv_area,
							&across_seam,
							&UV_SPLIT,
							&mid_uv[0],
							NULL,
						        NULL,
							NULL),
   		     p_chanselect = &to_loopset);
   EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_LoopsetError, wrapup);

   /*
    * In cases the loopset degenerates to a line parrallel to either
    * u or v axis, the ls_range points will be within knot tolerance.
    * In such cases, extraction of partial surface will fail. Since,
    * the objective is to reduce the r_tree range, increase the range
    * by knot tolerance. -- RC 02/02/89
    */

  GRgetabsg(EMmsg, &grmd_env.md_env.matrix_type,
            grmd_env.md_env.matrix, (IGRchar **)&surf_old, our_dumdum);
  EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

  /*
   * Replaced EFsspbtol_by_geom by BSsfkttol2() as EFsspbtol_by_geom
   * adjusts the partol if it exceeds a defined limit. This adjustment
   * causes problems as math still uses unadjusted partol returned
   * by BSsfkttol2.  RC  03/23/89
   */

  BSsfkttol2 (surf_old->u_order, surf_old->v_order, surf_old->u_knots,
              surf_old->v_knots, surf_old->u_num_poles, 
              surf_old->v_num_poles, surf_old->poles, surf_old->weights,
              &knot_tol, &rc);
  EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  knot_tol *= 1.1;

  if (ls_uv_area < knot_tol)
  {
    if (across_seam & ACROSS_SEAM_U)
    {
     if ( (ls_range[0] + knot_tol) <= 
           surf_old->u_knots[surf_old->u_num_poles]) 
         ls_range[0] += knot_tol;

     if ( (ls_range[2] - knot_tol) >= 
           surf_old->u_knots[surf_old->u_order - 1]) 
         ls_range[2] -= knot_tol;
    }
    else
    {
     if ( (ls_range[0] - knot_tol) >= 
           surf_old->u_knots[surf_old->u_order -1 ]) 
         ls_range[0] -= knot_tol;

     if ( (ls_range[2] + knot_tol) <= 
           surf_old->u_knots[surf_old->u_num_poles]) 
         ls_range[2] += knot_tol;
    }

    if (across_seam & ACROSS_SEAM_V)
    {
     if ( (ls_range[1] + knot_tol) <= 
           surf_old->v_knots[surf_old->v_num_poles]) 
         ls_range[1] += knot_tol;

     if ( (ls_range[3] - knot_tol) >= 
           surf_old->v_knots[surf_old->v_order - 1]) 
         ls_range[3] -= knot_tol;
    }
    else
    {
     if ( (ls_range[1] - knot_tol) >= 
           surf_old->v_knots[surf_old->v_order -1 ]) 
         ls_range[1] -= knot_tol;

     if ( (ls_range[3] + knot_tol) <= 
           surf_old->v_knots[surf_old->v_num_poles]) 
         ls_range[3] += knot_tol;
    }

    ls_uv_area = (ls_range[2] - ls_range[0]) * 
                  (ls_range[3] - ls_range[1]);
  
  } /* if (ls_uv_area < knot_tol) */

   uchar_new_area = (IGRuchar)(0.5 + (100 * ls_uv_area) ); /*typecast for ANSI*/

   if( (surf_change == GEOMETRICAL) || (surf_change == CONSTRUCTIONAL)  
      || (surf_change == POLYGON_TOGGLE) )
   {
    IF_LS_AREA_BELOW_CURRENT_CUT_OFF_AREA(uchar_new_area, 100)
     better_range_found = TRUE;
    else
     better_range_found = FALSE;
   }
   else /* surf_change == TOPOLOGICAL */
   {
    if(!*uchar_old_area) /* >= 1.2 surfs with old area=0 OR surfs < 1.2 */
    {
     if IS_RTREE_RANGE_GOOD 
     {
       goto wrapup; /* old area = 0, so quit further reduction in range */
       
     }
     else /* surfs < 1.2 */
     {
      IF_LS_AREA_BELOW_CURRENT_CUT_OFF_AREA(uchar_new_area, 100)
       better_range_found = TRUE;
      else
      {
       *uchar_old_area = 100; /* Initialize < 1.2  surfaces */
       goto wrapup;
      }
     }
    }
    else /* >= 1.2 surfs with non-zero old area */
    {
     if(uchar_new_area > *uchar_old_area)
     {
      if IS_RTREE_RANGE_GOOD
       IF_LS_AREA_BELOW_CURRENT_CUT_OFF_AREA(*uchar_old_area, 100)
       {
        IF_LS_AREA_BELOW_CURRENT_CUT_OFF_AREA(uchar_new_area, 100)
         better_range_found = TRUE;
        else
         better_range_found = FALSE;
       }
       else
        goto wrapup;
      else
       goto wrapup; /* old range is geometrical range, new range can't be
                        bigger than this... */
     }
     else /* new area <= old_area */
     IF_LS_AREA_BELOW_CURRENT_CUT_OFF_AREA(uchar_new_area,*uchar_old_area)
      better_range_found = TRUE;
     else
      goto wrapup; /* Not considerable decrease in area */
    }
   }
   
   if(better_range_found)
   {
    extern void EFget_iso_patch_classid();

/*
 * Initialised the msg field to point to EMmsg. pp (02/01/89)
 */

    construct_list.msg = EMmsg;
    construct_list.env_info = &grmd_env;

    masts = GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);

    OM_stat = om$send(msg = message EMSsubbs.EMpartsf(EMmsg, 
			&construct_list, ls_range, mid_uv, &ls_range[2],
			UV_SPLIT, NULL, &part_surf, FALSE, FALSE),
		      targetid = my_id);
    EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   (void) EFget_iso_patch_classid(my_id, OM_Gw_current_OS,
				  &ls_range[0], &ls_range[2], UV_SPLIT,
			          NULL, &iso_patch_classid, EMmsg);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   OM_stat = om$get_classid(osnum = OM_Gw_current_OS, objid = my_id,
			    p_classid = &parent_classid);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   if( ( (parent_classid == OPP_EMSelpcone_class_id) ||
         (parent_classid == OPP_EMSelpcyl_class_id)     )
                         &&
       (iso_patch_classid == OPP_EMSproject_class_id)     )
   {
    extern IGRboolean EFsam_partial_quadric_range_box();

    EMerr_hndlr(!EFsam_partial_quadric_range_box
                    (part_surf, EMfreeform_surface, &new_params),
	         *EMmsg, EMS_E_BSerror, wrapup);
   }
   else
   {
    struct GRid sh_grid;
    extern IGRlong EMgettrshobj();

    OM_stat = EMgettrshobj(EMmsg, iso_patch_classid, 1, &sh_grid);
    EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    OM_stat = om$send(msg = message EMSsurface.EMget_params(
			EMmsg, part_surf, &grmd_env, &new_params_type, 
			&new_params),
		      targetid = sh_grid.objid,
		      targetos = sh_grid.osnum);
	EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_BSerror, wrapup);

   }
   SURF_RTREE_BIT_SET(ON)
  } /* If(better_range_found) */
  else
   SURF_RTREE_BIT_SET(OFF)
 } /* If (rng_calc_by_extraction) */
		
} /* if(!polygon_on) */

 if(POLYGON_TOGGLE_OFF_EXIT_LIST && !better_range_found) goto wrapup;
 
 if(!better_range_found)
 {
  CHECK_GET_GEOM(new_geom, new_geom_ptr)
/*
  if(new_range) 
   OM_BLOCK_MOVE(new_range, new_range_buff, sizeofSIXdoubles);
*/

  if(polygon_on)
  {
   GET_RANGE(new_range, new_range_buff, wrapup)
   SURF_RTREE_BIT_SET(OFF) 
  }
  else /* polygon is off */
  {
   if( ((type!=EMfreeform_surface)&&(type!=EMproject)&&(type != EMrevol))
                                  || 
                     (surf_change == TOPOLOGICAL) )
   {
    OM_stat = om$send(msg = message EMSsurface.EMget_params
                      (EMmsg, new_geom_ptr, &grmd_env, &new_params_type, 
                       &new_params),
		      targetid = my_id);
    EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_BSerror, wrapup);
    better_range_found = TRUE;
   }
   else
    GET_RANGE(new_range, new_range_buff, wrapup)
        
   if(BSbx2_type_surfs)
      SURF_RTREE_BIT_SET(OFF)
   else
      SURF_RTREE_BIT_SET(ON)
  } /* if(!polygon_on) */
 }


 if(better_range_found)
  OM_BLOCK_MOVE(&(new_params.range[0]), new_range_buff, sizeofSIXdoubles);
 
 if(draw_boxes_around_the_range)
 {
  extern void EFdraw_range_box();

  (void) EFdraw_range_box(new_range_buff);
 }

 *uchar_old_area = uchar_new_area;

 if(surf_change != CONSTRUCTIONAL)
 {
   IGRdouble  dist_tol, dist_tol_sq, dist_sq1, dist_sq2;	

  /* This old_range is a search range ( it is actually a BSbx2() at the
      final destination, and only applicable for TOPOLOGICAL & 
      POLYGON_CHANGE modifications. For other changes old_range is input.
  */
     
   GET_RANGE(old_range, old_range_buff, wrapup)

   BSEXTRACTPAR(&rc, BSTOLLENVEC, dist_tol);
   dist_tol_sq = dist_tol * dist_tol;

   masts = MA2pt2dis(EMmsg, old_range_buff, new_range_buff, &dist_sq1);
   EMerr_hndlr(!masts, *EMmsg, EMS_E_BSerror, wrapup);

   masts=MA2pt2dis(EMmsg,&old_range_buff[3],&new_range_buff[3],&dist_sq2);
   EMerr_hndlr(!masts, *EMmsg, EMS_E_BSerror, wrapup);

   if( (dist_sq1 <= dist_tol_sq) && (dist_sq2 <= dist_tol_sq) )
   {
    SURF_RTREE_BIT_SET(OFF)
    *uchar_old_area = 100;
    EM3dbxinc(old_range_buff, 0.2)
   }
 } /* if(surf_change != CONSTRUCTIONAL) */

 if( (surf_change == TOPOLOGICAL) || POLYGON_TOGGLE_OFF)
    had_a_shot_at_rtree_modification = FALSE;
 else
    had_a_shot_at_rtree_modification = TRUE;

#if DEBUG
if (surf_change != CONSTRUCTIONAL)
{
  GRrange search_range, rtree_range;
  OM_S_CHANSELECT prim_chan;
  OM_S_KEY_DESC select_key_search_range, select_key_rtree_range;


  search_range[0] = -MAXDOUBLE;
  search_range[1] = -MAXDOUBLE; 
  search_range[2] = -MAXDOUBLE;

  search_range[3] = MAXDOUBLE;
  search_range[4] = MAXDOUBLE; 
  search_range[5] = MAXDOUBLE;
 
  OM_stat = EMmake_chanselect (module_primary, &prim_chan);
  if(!(1&OM_stat)) goto wrapup;
 
  select_key_search_range.type = KEY_3D_DBL;
  select_key_search_range.key.p_3ddbl = search_range;

  select_key_rtree_range.type = KEY_3D_DBL;
  select_key_rtree_range.key.p_3ddbl = rtree_range;
 
  OM_stat = om$send(msg = message OMrtree.find_key(
                          &select_key_search_range,
                          &my_id, 
                          &select_key_rtree_range,
                          0, EMmsg),
                    senderid = md_grid->objid,
                    p_chanselect = &prim_chan);
  EMerr_hndlr (!(1&OM_stat) || (*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  *EMmsg = EMS_S_Success;

  fprintf (stderr, "objid = %d, osnum = %d \n", my_id, OM_Gw_current_OS);

  fprintf (stderr, " ***** Rtree Range ***** \n");
  fprintf (stderr, "Rtree_Min[] = %lf, %lf, %lf \n\n", rtree_range[0], 
                    rtree_range[1], rtree_range[2]);
  fprintf (stderr, "Rtree_Max[] = %lf, %lf, %lf \n\n", rtree_range[3], 
                    rtree_range[4], rtree_range[5]);

  fprintf (stderr, " ***** Old_range Buff ***** \n");
  fprintf (stderr, "Old_buff_Min[] = %lf, %lf, %lf \n\n", 
           old_range_buff[0], old_range_buff[1], old_range_buff[2]);
  fprintf (stderr, "Old_buff_Max[] = %lf, %lf, %lf \n\n", 
           old_range_buff[3], old_range_buff[4], old_range_buff[5]);

  fprintf (stderr, " ***** New_range Buff ***** \n");
  fprintf (stderr, "New_buff_Min[] = %lf, %lf, %lf \n\n", 
           new_range_buff[0], new_range_buff[1], new_range_buff[2]);
  fprintf (stderr, "Old_buff_Max[] = %lf, %lf, %lf \n\n", 
           new_range_buff[3], new_range_buff[4], new_range_buff[5]);

} /* if (surf_change != CONSTRUCTIONAL) */
#endif

 EMerr_hndlr(!EFmodify_surface_rtree_range
              (old_range_buff, new_range_buff, &my_id,
               &me^^GRgraphics.properties, &grmd_env, &post_info), 
              *EMmsg, EMS_E_Fail, wrapup);

wrapup:
  ME.EMSsubbs->ss_props &= ~EMSIS_RANGE_MODIFIED;

/*
  if(!(1&OM_stat&*EMmsg) && had_a_shot_at_rtree_modification)
*/
  if(!(1&OM_stat&*EMmsg))
  {
   extern OMuint OM_Gf_verbose_warning;


   if (OM_Gf_verbose_warning)
    fprintf(stderr, "rtree modification failed, recovering surface\n");
   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

   GET_RANGE(NULL, new_range_buff, free_geom)

   masts = EFmodify_surface_rtree_range
            (old_range_buff, new_range_buff, &my_id,
             &me^^GRgraphics.properties, &grmd_env, &post_info);
 
   if(masts)
   {
    SURF_RTREE_BIT_SET(OFF)   
    *uchar_old_area = 100;
   }
   else /* Updation failed */
   {
    if(!post_info.construct_flag) /* Failed for modified surf */
    {
      IGRint i;
      for(i = 0; i < 3; i++)
      {
       old_range_buff[i]   = GRDGNLIMITS_MIN_D;
       old_range_buff[i+3] = GRDGNLIMITS_MAX_D;
      }
      masts = TRUE;     /* Update with design space limits as old range */

      masts = EFmodify_surface_rtree_range
              (old_range_buff, new_range_buff, &my_id,
               &me^^GRgraphics.properties, &grmd_env, &post_info);

      if(!masts) *EMmsg = GRSDGNEXCEED;
    }
    else /* Updation failed for a newly constructed surface */
     *EMmsg = EMS_E_Fail;
   } /* if(!masts) */
 } /* if(!(1&OM_stat&*EMmsg) && had_a_shot_at_rtree_modification) */
   
free_geom:
  if(!new_geom && new_geom_ptr)
  {
   masts = GRabsg_del(new_geom_ptr);
   if(!masts) *EMmsg = EMS_E_Fail;
  }

  if(part_surf)
   {
    masts =  BSfreesf(&rc, part_surf);
    if(!masts) *EMmsg =  EMS_E_BSerror;
   }
  
  if(new_params_type == EMproject)
   {
    if(new_params.params.project.curve.knots)
     om$dealloc(ptr = new_params.params.project.curve.knots);
    if(new_params.params.project.curve.poles)
     om$dealloc(ptr = new_params.params.project.curve.poles);
    if(new_params.params.project.curve.weights)
     om$dealloc(ptr = new_params.params.project.curve.weights);
   }
  else if(new_params_type == EMrevol)
   {
    if(new_params.params.revolve.curve.knots)
     om$dealloc(ptr = new_params.params.revolve.curve.knots);
    if(new_params.params.revolve.curve.poles)
     om$dealloc(ptr = new_params.params.revolve.curve.poles);
    if(new_params.params.revolve.curve.weights)
     om$dealloc(ptr = new_params.params.revolve.curve.weights);
   }
  
  if (surf_old) GRabsg_del(surf_old);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMput_range_in_rtree")
  return (OM_stat);
}

end implementation EMSsubbs;
