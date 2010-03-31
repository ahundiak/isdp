class implementation EMSsubbs;

#include <stdio.h>
#include <stdlib.h>

#include "wl.h"

#include "bs.h"

#include "madef.h"

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "gr.h"
#include "godef.h"

#include "dp.h"
#include "dpdef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "DPdlist.h"

#include "dl.h"

#include "emsdef.h"
#include "emseligible.h"
#include "EMSssprops.h"
#include "EMSopt.h"
#include "EMSlcdef.h"
#include "EMSprop.h"

#include "hsurf.h"
#include "hssymbmacros.h"
#include "HSdlist.h"

/* Math prototypes */
#include "bsconstprcv.h"
#include "bsalloccv.h"
#include "bsfreecv.h"

/* New prototypes */
PROTO_DPdlist_add_surface
PROTO_DPdlist_add_edge_to_surface
PROTO_DPdlist_finish_surface
PROTO_DPdlist_add_msc_edge_to_surface

from GRviewdyn import DPdisplay_for_dlist;
from EMSboundary import EMget_edges;
from EMSboundary import EMgetxyzobj;
from EMSboundary import EMgetsurface_info;
from EMSedge import EMget_props;
from EMSedge import EMget_bcxyz_geom;
from EMSedge import EMget_sf_geom;
from EMSgradata import EMgetRLT, EMupdate;

extern struct GRid DPdlist_sh_fb_gragad;
extern IGRdouble *DPdlist_fb_buffer;
extern int DPdlist_wf_fb_pipe_id;
extern IGRboolean DPdlist_feedback_in_progress;
extern IGRdouble DPdlist_stroke_tolerance;

extern OMuword OPP_EMShrzcvs_class_id;
extern OMuword OPP_EMShorizon_class_id;
extern OMuword OPP_EMSgradata_class_id;
extern OMuword OPP_EMScusp_class_id;

#define STATIC_RLT_SIZE 1024
#define NUM_STATIC_LINKAGES 25

%safe
static struct GRmdenv_info id_env_info = { MAIDMX,
                                           { 1.0, 0.0, 0.0, 0.0,
                                             0.0, 1.0, 0.0, 0.0,
                                             0.0, 0.0, 1.0, 0.0,
                                             0.0, 0.0, 0.0, 1.0 } };

static IGRboolean loopset_chandef_defined = FALSE;
static OM_S_CHANSELECT loopset_chandef;
static IGRboolean helper_chandef_defined = FALSE;
static OM_S_CHANSELECT helper_chanselect;
static IGRboolean common_edge_chandef_defined = FALSE;
static OM_S_CHANSELECT common_edge_chandef;
static IGRboolean notification_chandef_defined = FALSE;
static OM_S_CHANSELECT notification_chanselect;
%endsafe


/*--- DPdlist_stroke_surface_curve ----------------------------------------*/

static int DPdlist_stroke_surface_curve(
   struct DPdlist_fixed_data *fixed,
   struct IGRbsp_curve *curve,
   unsigned int curve_flags )

/*
NAME
   DPdlist_stroke_surface_curve (static)

DESCRIPTION
   This function strokes a curve from a surface in order to
   add it to the display list.

SYNOPSIS
   static int DPdlist_stroke_surface_curve(
      struct DPdlist_fixed_data *fixed,
      struct IGRbsp_curve *curve,
      unsigned int curve_flags )

PARAMETERS
   fixed (IN) - the fixed data for the surface being added 
                to the display list
   curve (IN) - the Bspline geometry of the curve
   curve_flags (IN) - the flags to store in the curves
                      variable data

GLOBALS USED
   DPdlist_wf_fb_pipe_id

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/15/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   IGRdouble *points;
   IGRuint num_points;
   int qsize;
   IGRdouble *elem_ptr, *start_ptr, *dest_ptr, *next_elem_ptr;
   int current_size;
   IGRdouble os_scale;

   DPdlist_get_object_space_scale( OM_Gw_current_OS, &os_scale );

   DLset_curve_tolerance( DPdlist_wf_fb_pipe_id,
                          DPdlist_stroke_tolerance / os_scale,
                          DPdlist_stroke_tolerance / os_scale );

   sts = DLdraw_3D_curve( DPdlist_wf_fb_pipe_id,
                          curve,
                          NULL, NULL, 0,
                          0, 0, 0xFFFF, 1, DL_OPT_BASE_DRAW | DL_OPT_HILITE_NOOP );

   DLset_curve_tolerance( DPdlist_wf_fb_pipe_id,
                          DPdlist_stroke_tolerance,
                          DPdlist_stroke_tolerance );

   if ( sts != DL_SUCCESS )
   {
      return( DLIST_E_ERROR );
   }

   if ( ((WLuint16 *)DPdlist_fb_buffer)[0] == 0 )
   {
      /* nothing added to feedback buffer */
      return( DLIST_E_ERROR );
   }
   
   elem_ptr = start_ptr = &DPdlist_fb_buffer[2];
   points = &start_ptr[1]; 
   dest_ptr = points + ( ( int * )elem_ptr)[1] ;
   qsize = ( ( int * ) DPdlist_fb_buffer )[1] ;
   num_points = 0;
   while ( qsize )
   {
      /* Increment the number of points */
      num_points += ( ( ( int * )elem_ptr)[1] )/3;
      current_size =  ( ( int * )elem_ptr)[1];
      next_elem_ptr = elem_ptr + 2 + ( ( int * )elem_ptr)[1];

      if ( elem_ptr != start_ptr )
      {
         /* Move the points together */
         memcpy( dest_ptr, &elem_ptr[1], ( ( int * )elem_ptr)[1] * 8 );
         dest_ptr +=current_size;
      }

      qsize -= ( current_size + 2 );
      elem_ptr = next_elem_ptr;
      
   }
   
   DLreset_feedback( DPdlist_wf_fb_pipe_id );
   ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
   ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;

   sts = DPdlist_add_edge_to_surface( fixed, DP_DLIST_VIEW_IND, 
                                      curve_flags, num_points, points );

   if ( !(1 & sts) )
   {
      return( sts );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_stroke_surface_curve */


/*--- DPdlist_process_rlt_clip_points ---------------------------------------*/

static int DPdlist_process_rlt_clip_points(
   struct DPdlist_fixed_data *fixed,
   struct IGRbsp_curve *curve,
   IGRint num_bounds,
   IGRdouble *bounds )

/*
NAME
   DPdlist_process_rlt_clip_points (static)

DESCRIPTION
   This function processes the clip points for a rule line from a rule
   line table.  It causes the visible portions of the rule line to
   be added to the display list for the surface.

SYNOPSIS
   static int DPdlist_process_rlt_clip_points(
      struct DPdlist_fixed_data *fixed,
      struct IGRbsp_curve *curve,
      IGRint num_bounds,
      IGRdouble *bounds )

PARAMETERS
   fixed (IN) - the fixed data for the surface being added to
                the display list
   curve (IN) - the Bspline curve geometry of the rule line
   num_bounds (IN) - the number of boundaries on the rule line
   bounds (IN) - the array of rule line boundaries

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/15/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   int ii;
   int last;
   double cv_bounds[4];

   last = 2 * num_bounds - 1;

   curve->bdrys = cv_bounds;

   if ( bounds[0] != 0.0 )
   {
      /* solid region from 0.0 to bounds[0] */
      curve->num_boundaries = 1;
      cv_bounds[0] = bounds[0];
      cv_bounds[1] = 1.0;
      sts = DPdlist_stroke_surface_curve( fixed, curve,
                                          DP_DLIST_CRV_SURFACE |
                                          DP_DLIST_CRV_RULE_LINE );
      if ( !(1 & sts) )
      {
         return( sts );
      }
   }

   curve->num_boundaries = 2;
   for ( ii = 1; ii < last; ii += 2 )
   {
      /* solid region from bounds[ii] to bounds[ii+1] */
      cv_bounds[0] = 0.0;
      cv_bounds[1] = bounds[ii];
      cv_bounds[2] = bounds[ii+1];
      cv_bounds[3] = 1.0;
      sts = DPdlist_stroke_surface_curve( fixed, curve,
                                          DP_DLIST_CRV_SURFACE |
                                          DP_DLIST_CRV_RULE_LINE );
      if ( !(1 & sts) )
      {
         return( sts );
      }
   }

   if ( bounds[last] != 1.0 )
   {
      /* solid region from bounds[last] to 1.0 */
      curve->num_boundaries = 1;
      cv_bounds[0] = 0.0;
      cv_bounds[1] = bounds[last];
      sts = DPdlist_stroke_surface_curve( fixed, curve,
                                          DP_DLIST_CRV_SURFACE |
                                          DP_DLIST_CRV_RULE_LINE );
      if ( !(1 & sts) )
      {
         return( sts );
      }
   }      

   curve->num_boundaries = 0;
   curve->bdrys = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_process_rlt_clip_points */

/*--- DPdlist_process_surface_rlt -------------------------------*/

static int DPdlist_process_surface_rlt(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct IGRbsp_surface *surf,
   struct IGRbsp_curve *curve, 
   struct IGResqbs *rlt )

/*
NAME
   DPdlist_process_surface_rlt (static)

DESCRIPTION
   This function processes the rule line table for a surface by
   adding the visible portions of the rule lines to the display
   list.

SYNOPSIS
   static int DPdlist_process_surface_rlt(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct IGRbsp_surface *surf,
      struct IGRbsp_curve *curve,
      struct IGResqbs *rlt )

PARAMETERS
   fixed (IN) - the fixed data for the surface being added
                to the display list
   osnum (IN) - the object space number of the surface
   surf (IN)  - the surface whose rule line table is to be processed
   curve (IN) - a preallocated curve structure that is big enough to
                hold any isocurve of 'surf'
   rlt (IN)   - the rule line table

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/15/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int ii;
   BSrc rc;
   IGRshort par_option;
   IGRboolean tst_planar = FALSE;


   /* process the u rule lines */
   par_option = 1;
   for ( ii = 0; ii < rlt->u_rules; ii++ )
   {
      /* extract the iso-curve for this rule line */
      BSconstprcv( &rc, surf, &par_option, &rlt->u_rule_values[ii], 
                   &tst_planar, curve );

      if ( rlt->u_num_bound[ii] != 0 )
      {
         /* this rule line is clipped */
         DPdlist_process_rlt_clip_points( fixed,
                                          curve,
                                          rlt->u_num_bound[ii],
                                          rlt->u_bdrys[ii] );
      }
      else
      {
         /* this rule line is not clipped */
         DPdlist_stroke_surface_curve( fixed, curve,
                                       DP_DLIST_CRV_SURFACE |
                                       DP_DLIST_CRV_RULE_LINE );
      }
   }

   /* process the v rule lines */
   par_option = 2;
   for ( ii = 0; ii < rlt->v_rules; ii++ )
   {
      BSconstprcv( &rc, surf, &par_option, &rlt->v_rule_values[ii], 
                   &tst_planar, curve );

      if ( rlt->v_num_bound[ii] != 0 )
      {
         /* this rule line is clipped */
         DPdlist_process_rlt_clip_points( fixed,
                                          curve,
                                          rlt->v_num_bound[ii],
                                          rlt->v_bdrys[ii] );
      }
      else
      {
         /* this rule line is not clipped */
         DPdlist_stroke_surface_curve( fixed, curve,
                                       DP_DLIST_CRV_SURFACE |
                                       DP_DLIST_CRV_RULE_LINE );
      }

   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_process_surface_rlt */

/*--- GRadd_to_display_list-------------------------------------*/

method GRadd_to_display_list(
   IGRlong *msg;
   IGRboolean is_hidden_line )

/*
NAME
   EMSsubbs.GRadd_to_display_list
 
DESCRIPTION
   This function adds a surface to the display list
 
SYNOPSIS
method GRadd_to_display_list(
   IGRlong *msg;
   IGRboolean is_hidden_line )
 
PARAMETERS
   msg (OUT) - return status
   is_hidden_line (IN) - TRUE, if adding for shading
 
GLOBALS USED
   none
 
RETURN VALUES
   OM_S_SUCCESS - Success
   OM_E_ERROR - Failure
 
HISTORY
   05/18/93  Shridar Subramanian
      Initial specification and design and implementation
*/


{
   unsigned short ele_flags;
   int sts;
   struct DPdlist_fixed_data *fixed;
   struct GRid *edge_ids;
   IGRint edge_id_size;
   IGRint num_edges;
   IGRint ii, jj;
   OM_S_OBJECT_LINKAGE list[1];
   OMuint count;
   GRobjid msc_id;
   OMuint num_on_channel;
   OM_S_OBJECT_LINKAGE *linkage, static_linkage[NUM_STATIC_LINKAGES];
   OMuword object_classid;
   IGRushort edge_prop_word, common_edge_prop_word;
   OM_S_OBJECT_LINKAGE common_edge_linkage[1];
   struct IGRbsp_curve curve, *iso_curve = NULL;
   struct IGRbsp_surface *surf = NULL;
   unsigned int curve_flags;
   IGRdouble static_rlt[STATIC_RLT_SIZE / 8];
   struct IGResqbs *rlt = NULL;
   unsigned short num_u_rules = 0, num_v_rules = 0;
   int max_poles, max_order;
   BSrc rc;
   struct HSrender_bundle render_bundle;
   struct GRid obj;
   struct IGResbs surf_attr;
   GRobjid surf_id;
   IGRboolean world;
   struct EMSpartolbasis partol;  

   sts = OM_S_SUCCESS;
   DPdlist_feedback_in_progress = TRUE;
   sts = DPdlist_set_element_flags( my_id, OM_Gw_current_OS, &ele_flags );
   if ( !(1 & sts) )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }

   if ( me->ss_props & EMSIS_INACTIVE )
   {
      ele_flags |= DP_DLIST_ELE_INACTIVE;
   }

   sts = om$send( msg = message GRvg.GRgetattr( msg, (IGRchar *)&surf_attr ),
                  targetid = my_id );
   if ( !(1 & sts & *msg) )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }

   if ( surf_attr.is_polydis )
   {
      ele_flags |= DP_DLIST_ELE_DISPLAY_POLYGON;
   }

   sts = DPdlist_add_surface( my_id, OM_Gw_current_OS, ele_flags, is_hidden_line,
                           me->display_attr.color,
                           me->display_attr.style,
                           me->display_attr.weight,
                           me->level, &fixed );
   if ( !(1 & sts) )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }

   if ( is_hidden_line )
   {
      /* display surface to get its meshes */
      sts = om$send( msg = message GRviewdyn.DPdisplay_for_dlist( msg, my_id, OM_Gw_current_OS ),
                     targetid = DPdlist_sh_fb_gragad.objid,
                     targetos = DPdlist_sh_fb_gragad.osnum );

      if ( !(1 & sts & *msg) )
      {
         *msg = MSFAIL;
         sts = OM_E_ERROR;
         goto wrapup;
      }

   }
   else
   {
      /* get the geometry of the surface, it is allocated as a single */
      /* contiguous chunk so it should be freed that way too          */
      obj.objid = my_id;
      obj.osnum = OM_Gw_current_OS;
      sts = EMgetvggeom( msg, &id_env_info.matrix_type, id_env_info.matrix, 
                          &obj, (IGRchar **) &surf, NULL );
                  
      if ( ! (1 & sts) )
      {
         *msg = MSFAIL;
         sts = OM_E_ERROR;
         goto wrapup;
      }

      /* allocate space to extract isocurves in rule line processing */
      if ( surf->u_order > surf->v_order )
      {
         max_order = surf->u_order;
      }
      else
      {
         max_order = surf->v_order;
      }

      if ( surf->u_num_poles > surf->v_num_poles )
      {
         max_poles = surf->u_num_poles;
      }
      else
      {
         max_poles = surf->v_num_poles;
      }

      BSalloccv( max_order, max_poles, surf->rational, 0, &iso_curve, &rc );
      if ( ! iso_curve )
      {
         *msg = MSFAIL;
         sts = OM_E_ERROR;
         goto wrapup;
      }

      /* see if surface has horizon edges */
      if ( ! helper_chandef_defined )
      {
         helper_chandef_defined = TRUE;
         om$make_chanselect( channame = "EMSrequester.to_helpers",
                             p_chanselect = &helper_chanselect );
      }

      sts = om$get_channel_count( osnum = OM_Gw_current_OS, objid = my_id,
                                  p_chanselect = &helper_chanselect,
                                  count = &num_on_channel );

      if ( num_on_channel > NUM_STATIC_LINKAGES )
      {
         linkage = (OM_S_OBJECT_LINKAGE *) malloc( num_on_channel * sizeof( OM_S_OBJECT_LINKAGE ) );
         if ( ! linkage )
         {
            *msg = MSFAIL;
            sts = OM_E_ERROR;
            goto wrapup;
         }
      }
      else
      {
         linkage = static_linkage;
      }

      sts = om$get_channel_objects( osnum = OM_Gw_current_OS, objid = my_id,
                                    p_chanselect = &helper_chanselect,
                                    list = linkage,
                                    size = num_on_channel,
                                    count = &num_on_channel );

      for ( ii = 0; ii < num_on_channel; ii++ )
      {
         sts = om$get_classid( osnum = linkage[ii].osnum,
                               objid = linkage[ii].S_objid,
                               p_classid = &object_classid );

         if ( ( om$is_ancestry_valid( superclassid = OPP_EMShorizon_class_id,
                                      subclassid = object_classid ) == OM_S_SUCCESS ) ||
              ( om$is_ancestry_valid( superclassid = OPP_EMScusp_class_id,
                                      subclassid = object_classid ) == OM_S_SUCCESS ) )
         {
            /* surface has a horizon/cusp loop */
            fixed->ele_flags |= DP_DLIST_ELE_HAS_GRALOOPS;
         }
         else if ( object_classid == OPP_EMSgradata_class_id )
         {
            /* update the EMSgradata if it is already not
               - Fix for TR#119418766. - Vadi */

            sts = om$send(msg = message EMSsubbs.EMpartolbasis(msg,
                                &id_env_info.matrix_type,
                                id_env_info.matrix,
                                &world, FALSE, &partol.tol),
                                targetid = my_id);
            if(!(1 & sts & *msg))
            {
               goto wrapup;
            }
            partol.in_world = TRUE;
            partol.is_valid = TRUE;
            partol.mattyp = &id_env_info.matrix_type;
            partol.mat = id_env_info.matrix;

            sts = om$send(msg = message EMSgradata.EMupdate(msg,
                                &id_env_info.matrix_type, id_env_info.matrix,
                                NULL, &surf_attr, surf, NULL, NULL, &partol),
                                targetid = linkage[ii].S_objid,
                                targetos = linkage[ii].osnum);
            if(!(1 & sts & *msg))
            {
               goto wrapup;
            }

            fixed->ele_flags |= DP_DLIST_ELE_HAS_GRADATA;
            sts = om$send( msg = message EMSgradata.EMgetRLT( msg,
                                                              (IGRchar *) static_rlt,
                                                              STATIC_RLT_SIZE,
                                                              &rlt ),
                        targetid =  linkage[ii].S_objid,
                        targetos =  linkage[ii].osnum );

            if ( ! (1 & sts & *msg) )
            {
               goto wrapup;
            }

            sts = DPdlist_process_surface_rlt( fixed, OM_Gw_current_OS, surf, iso_curve, rlt );
            if ( !(1 & sts) )
            {
               *msg = MSFAIL;
               sts = OM_E_ERROR;
               goto wrapup;
            }

            if ( (rlt) && (rlt != (struct IGResqbs *) static_rlt) )
            {
               free( rlt );
            }
            rlt = NULL;

         }

      }

      if ( linkage != static_linkage )
      {
         free( linkage );
      }

      /* see if surface has horizon curves */
      if ( ! notification_chandef_defined )
      {
         notification_chandef_defined = TRUE;
         om$make_chanselect( channame = "GRnotify.notification",
                             p_chanselect = &notification_chanselect );
      }

      sts = om$get_channel_count( osnum = OM_Gw_current_OS, objid = my_id,
                                  p_chanselect = &notification_chanselect,
                                  count = &num_on_channel );

      if ( num_on_channel > NUM_STATIC_LINKAGES )
      {
         linkage = (OM_S_OBJECT_LINKAGE *) malloc( num_on_channel * sizeof( OM_S_OBJECT_LINKAGE ) );
         if ( ! linkage )
         {
            *msg = MSFAIL;
            sts = OM_E_ERROR;
            goto wrapup;
         }
      }
      else
      {
         linkage = static_linkage;
      }

      sts = om$get_channel_objects( osnum = OM_Gw_current_OS, objid = my_id,
                                    p_chanselect = &notification_chanselect,
                                    list = linkage,
                                    size = num_on_channel,
                                    count = &num_on_channel );

      for ( ii = 0; ii < num_on_channel; ii++ )
      {
         sts = om$get_classid( osnum = linkage[ii].osnum,
                               objid = linkage[ii].S_objid,
                               p_classid = &object_classid );

         if ( ( om$is_ancestry_valid( superclassid = OPP_EMShrzcvs_class_id,
                                      subclassid = object_classid ) == OM_S_SUCCESS ) )
         {
            /* surface has a horizon curves */
            fixed->ele_flags |= DP_DLIST_ELE_HAS_HORIZON_CURVES;
            break;
         }

      }

      if ( linkage != static_linkage )
      {
         free( linkage );
      }


      if ( ! loopset_chandef_defined )
      {
         loopset_chandef_defined = TRUE;
         om$make_chanselect( channame = "EMSsubbs.to_loopset",
                             p_chanselect = &loopset_chandef );
      }

      om$get_channel_objects( osnum = OM_Gw_current_OS,
                              objid = my_id,
                              p_chanselect = &loopset_chandef,
                              list = list,
                              size = 1,
                              count = &count );

      if ( fixed->ele_flags & DP_DLIST_ELE_HAS_GRADATA )
      {
         num_u_rules = num_v_rules = 0;
      }
      else
      {
         /* no graphics data objects => get rules lines from surface */
         sts = om$send( msg = message EMSsubbs.EMgetRuleLineTable( msg,
                                                                   count ? FALSE:TRUE,
                                                                   NULL, NULL,
                                                                   surf,
                                                                   NULL, NULL,
                                                                   (IGRchar *) static_rlt,
                                                                   STATIC_RLT_SIZE,
                                                                   &rlt ),
                     targetid = my_id,
                     targetos = OM_Gw_current_OS );

         if ( ! (1 & sts & *msg) )
         {
            goto wrapup;
         }

         num_u_rules = rlt->u_rules;
         num_v_rules = rlt->v_rules;

         sts = DPdlist_process_surface_rlt( fixed, OM_Gw_current_OS, surf, iso_curve, rlt );
         if ( !(1 & sts) )
         {
            *msg = MSFAIL;
            sts = OM_E_ERROR;
            goto wrapup;
         }

         if ( (rlt) && (rlt != (struct IGResqbs *) static_rlt) )
         {
            free( rlt );
         }
         rlt = NULL;
      }

      BSfreecv( &rc, iso_curve );
      iso_curve = NULL;
      /* process the edges for this surface */
      edge_id_size = 0;
      num_edges = 0;
      edge_ids = NULL;

      if ( ! common_edge_chandef_defined )
      {
         common_edge_chandef_defined = TRUE;
         om$make_chanselect( channame = "EMSedge.to_common_edge",
                             p_chanselect = &common_edge_chandef );
      }


      if ( count != 0 )
      {
         /* surface has a loopset => get all the edges for the surface */
         sts = om$send( msg = message EMSboundary.EMget_edges( msg,
                                                               MAXINT,
                                                               EMS_OPT_ALL,
                                                               &edge_ids,
                                                               &edge_id_size,
                                                               &num_edges ),
                        targetid = list[0].S_objid,
                        targetos = OM_Gw_current_OS );

         if ( ! (1 & sts & *msg) )
         {
            goto wrapup;
         }

         for ( ii = 0; ii < num_edges; ii++ )
         {
            sts = om$send( msg = message EMSedge.EMget_props( msg, &edge_prop_word ),
                           targetid = edge_ids[ii].objid,
                           targetos = OM_Gw_current_OS );
   
            if ( ! (1 & sts & *msg) )
            {
               goto wrapup;
            }

            if ( (! (edge_prop_word & EMED_SUBORDINATE)) &&
                 (! (edge_prop_word & EMED_DEGENERATE) ) )
            {
               /* this is a non-degenerate, dominant edge */

               if ( edge_prop_word & EMED_MSCEXISTS )
               {
                  /* edge has a msc */
                  sts = om$send( msg = message EMSboundary.EMgetxyzobj( msg,
                                                                        EMSlcopt_existingmsc,
                                                                        NULL, NULL, NULL, NULL, NULL,
                                                                        OM_Gw_current_OS, &msc_id ),
                                 targetid = edge_ids[ii].objid,
                                 targetos = OM_Gw_current_OS );

                  if ( ! (1 & sts & *msg) )
                  {
                     goto wrapup;
                  }
   
                  sts = DPdlist_add_msc_edge_to_surface( fixed, 
                                                         DP_DLIST_VIEW_IND, 0, 
                                                         msc_id );
                  if ( ! (1 & sts) )
                  {
                     *msg = MSFAIL;
                     sts = OM_E_ERROR;
                     goto wrapup;
                  }
               }
               else
               {
                  /* no msc for this edge */

                  /* get the common edge and its properties word */
                  sts = om$get_channel_objects( osnum = edge_ids[ii].osnum,
                                                objid = edge_ids[ii].objid,
                                                p_chanselect = &common_edge_chandef,
                                                list = common_edge_linkage,
                                                size = 1,
                                                count = &count );

                  if ( ! (1 & sts) )
                  {
                     *msg = MSFAIL;
                     sts = OM_E_ERROR;
                     goto wrapup;
                  }
   
                  if ( count )
                  {
                     /* common edge exists */
                     sts = om$send( msg = message EMSedge.EMget_props( msg, &common_edge_prop_word ),
                                    targetid = common_edge_linkage[0].S_objid,
                                    targetos = OM_Gw_current_OS );

                     if ( ! (1 & sts & *msg) )
                     {
                        goto wrapup;
                     }

                  }
                  else
                  {
                     /* no common edge */
                     common_edge_prop_word = 0;
                  }

                  /* get the geomtetry of the edge */
                  curve.poles = curve.knots = curve.weights = NULL;
                  sts = om$send( msg = message EMSedge.EMget_bcxyz_geom( msg, NULL, NULL,
                                                                         surf, 0, 0x7fffffff,
                                                                         FALSE, NULL, &curve ),
                                 targetid = edge_ids[ii].objid,
                                 targetos = edge_ids[ii].osnum );

                  if ( ! (1 & sts & *msg) )
                  {
                     goto wrapup;
                  }

                  /* setup the flags for this edge */
                  curve_flags = DP_DLIST_CRV_SURFACE;
                  if ( edge_prop_word & EMED_SEAM )
                  {
                     curve_flags |= DP_DLIST_CRV_SEAM;
                  }
                  if ( (edge_prop_word | common_edge_prop_word) & EMED_TANGENT )
                  {
                     curve_flags |= DP_DLIST_CRV_TANGENT;
                  }

                  /* stroke curve and add to surface variable data */
                  sts = DPdlist_stroke_surface_curve( fixed, &curve, curve_flags );
                  if ( ! (1 & sts) )
                  {
                     *msg = MSFAIL;
                     sts = OM_E_ERROR;
                     goto wrapup;
                  }
                  curve_flags = 0;
                  if ( curve.poles )
                  {
                     free( curve.poles );
                     curve.poles = NULL;
                  }

                  if ( curve.knots )
                  {
                     free( curve.knots );
                     curve.knots = NULL;
                  }

                  if ( curve.weights )
                  {
                     free( curve.weights );
                     curve.weights = NULL;
                  }
               }
            }
            else 
            if ( (edge_prop_word & EMED_SUBORDINATE) &&
                 (! (edge_prop_word & EMED_DEGENERATE) ) )
            {
               /* Get the dominant edge and store its geometry */
               sts = om$get_channel_objects( osnum = edge_ids[ii].osnum,
                                             objid = edge_ids[ii].objid,
                                             p_chanselect = &common_edge_chandef,
                                             list = common_edge_linkage,
                                             size = 1,
                                             count = &count );

               if ( ! (1 & sts) )
               {
                  *msg = MSFAIL;
                  sts = OM_E_ERROR;
                  goto wrapup;
               }
   
               if ( count )
               {
                  /* common edge exists */
                  for ( jj = 0; jj < count;jj++ )
                  {
                    
                     sts = om$send( msg = message EMSedge.EMget_props( msg, &common_edge_prop_word ),
                                    targetid = common_edge_linkage[jj].S_objid,
                                    targetos = OM_Gw_current_OS );

                     if ( ! (1 & sts & *msg) )
                     {
                        goto wrapup;
                     }
                     if ( (! (common_edge_prop_word & EMED_SUBORDINATE)) &&
                          (! (common_edge_prop_word & EMED_DEGENERATE) ) )
                     {
                        break;
                     }
                  }
               }
               if ( ( !count ) || ( jj == count ) )
               {
                  *msg = MSFAIL;
                  sts = OM_E_ERROR;
                  goto wrapup;
               }

               if ( common_edge_prop_word & EMED_MSCEXISTS )
               {
                  /* edge has a msc */
                  sts = om$send( msg = message EMSboundary.EMgetxyzobj( msg,
                                                                        EMSlcopt_existingmsc,
                                                                        NULL, NULL, NULL, NULL, NULL,
                                                                        OM_Gw_current_OS, &msc_id ),
                                 targetid = common_edge_linkage[jj].S_objid,
                                 targetos = common_edge_linkage[jj].osnum );

                  if ( ! (1 & sts & *msg) )
                  {
                     goto wrapup;
                  }
                  curve_flags = DP_DLIST_CRV_SUBORDINATE;   
                  sts = DPdlist_add_msc_edge_to_surface( fixed, 
                                                         DP_DLIST_VIEW_IND, 
                                                         curve_flags, 
                                                         msc_id );
                  if ( ! (1 & sts) )
                  {
                     *msg = MSFAIL;
                     sts = OM_E_ERROR;
                     goto wrapup;
                  }
               }
               else
               {
                 
                  /* get the geomtetry of the edge */
                  curve.poles = curve.knots = curve.weights = NULL;

                  sts = om$send( msg = message EMSboundary.EMgetsurface_info( msg, &surf_id, NULL ),
                                 targetid = common_edge_linkage[jj].S_objid,
                                 targetos = common_edge_linkage[jj].osnum );
  
                  if ( surf_id != NULL_OBJID )
                  {
                     /* common edge is conntected to a surface => get its geometry */
                     sts = om$send( msg = message EMSedge.EMget_bcxyz_geom ( msg, &id_env_info, NULL,
                                                                            NULL, 0, 0x7fffffff,
                                                                            FALSE, NULL, &curve ),
                                    targetid = common_edge_linkage[jj].S_objid,
                                    targetos = common_edge_linkage[jj].osnum );
                  }
                  else
                  {
                     /* common edge is not conntected to a surface => get geometry of edge */
                     sts = om$send( msg = message EMSedge.EMget_bcxyz_geom( msg, NULL, NULL,
                                                                            surf, 0, 0x7fffffff,
                                                                            FALSE, NULL, &curve ),
                                    targetid = edge_ids[ii].objid,
                                    targetos = edge_ids[ii].osnum );
                  }

                  if ( ! (1 & sts & *msg) )
                  {
                     goto wrapup;
                  }

                  /* setup the flags for this edge */
                  curve_flags = DP_DLIST_CRV_SURFACE;
                  if ( common_edge_prop_word & EMED_SEAM )
                  {
                     curve_flags |= DP_DLIST_CRV_SEAM;
                  }
                  if ( (edge_prop_word | common_edge_prop_word) & EMED_TANGENT )
                  {
                     curve_flags |= DP_DLIST_CRV_TANGENT;
                  }
                  curve_flags |= DP_DLIST_CRV_SUBORDINATE;
  
                  /* !!! Add the geometry of the dominant curve as a subordinate entry !!! */
                  sts = DPdlist_stroke_surface_curve( fixed, &curve, curve_flags );

                  if ( ! (1 & sts) )
                  {
                     *msg = MSFAIL;
                     sts = OM_E_ERROR;
                     goto wrapup;
                  }
                  curve_flags = 0;
                  if ( curve.poles )
                  {
                     free( curve.poles );
                  }

                  if ( curve.knots )
                  {
                     free( curve.knots );
                  }

                  if ( curve.weights )
                  {
                     free( curve.weights );
                  }
               }
            }   
         }

         if ( edge_ids )
         {
            om$dealloc( ptr = edge_ids );
         }

      }

      if ( surf )
      {
         om$dealloc( ptr = surf );
         surf = NULL;
      }
   }

   sts = DPdlist_finish_surface( fixed, is_hidden_line, num_u_rules, num_v_rules );

   if ( !(1 & sts) )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }
  
   /* get the shading parameters set properly */
   hs$retrieve_symb_entry( msg = msg,
                           index = me->hidden_line,
                           entry = &render_bundle,
                           app_entry = NULL );

   sts = HSdlist_shading_parameter_notify( my_id, OM_Gw_current_OS,
                                           render_bundle.diff_refl, render_bundle.spec_refl,
                                           render_bundle.finish, render_bundle.trans );
   if ( !(1 & sts) )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }
   
wrapup:
   DLreset_feedback( DPdlist_wf_fb_pipe_id );
   ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
   ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;

/* fix for mlk */
   if(iso_curve) BSfreecv(&rc,iso_curve);
   if ( surf ) om$dealloc( ptr = surf );
   DPdlist_feedback_in_progress = FALSE;

   return( sts );

} /* GRadd_to_display_list */

end implementation EMSsubbs;
