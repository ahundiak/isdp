class implementation IGEgragad;

#include <stdlib.h>
#include <string.h>

#include "grimport.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "exmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "godef.h"
#include "igewindef.h"
#include "igewindow.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

/* prototype files */
#include "DPcal.h"
#include "DPgetggid.h"
#include "dpclpstack.h"
#include "dpmtxstack.h"
#include "dpaxisalign.h"
#include "dpsetrng.h"
#include "dpinqwsdep.h"
#include "dppresetvvol.h"

#include "ma.h"
#include "madotvc.h"
#include "mainvmx.h"
#include "madabs.h"
#include "maidmx.h"
#include "mapapromx.h"
#include "mapllbrel.h"
#include "maunitvc.h"
#include "matypemx.h"
#include "maptsxfor.h"
#include "mamulmx.h"

#define TRANS_LIMIT 9.99999999e+14

from IGEwindow import DPinquire;
from IGEwinsup import view_changed;

%safe
static IGRboolean winsup_chandef_defined = FALSE;
static OM_S_CHANSELECT winsup_chandef;
%endsafe

int DPcalinfo( IGRlong * msg,
                   GRspacenum osnum,
                   IGRchar * gragad_name,
                   GRobjid gragad_objid )

{

   IGRlong status;
   IGRint number_ids;
   IGRshort i;
   struct GRid gg_ids[EX_MAX_WINDOW];
   GRobjid mod_objid;
   GRspacenum mod_osnum;
   GRobjid modid;
   struct GRid mod_grid;

   *msg = MSSUCC;
   status = OM_S_SUCCESS;

   if ( osnum == 0xFFFF )
   {
      ex$get_cur_mod( id = &mod_objid, osnum = &mod_osnum );
   }
   else
   {
      mod_osnum = osnum;
   }
   if ( gragad_objid == NULL_OBJID )
   {
      ex$get_modid( mod_osnum = mod_osnum, mod_id = &modid );
      mod_grid.osnum = mod_osnum;
      mod_grid.objid = modid;
      number_ids = 0;
      dp$get_gragad_id( msg = msg, mod_GRid = &mod_grid, name = gragad_name,
                        array_size = EX_MAX_WINDOW,
                        numberofids = &number_ids, found_GRids = gg_ids );
   }
   else
   {
      gg_ids[0].objid = gragad_objid;
      gg_ids[0].osnum = mod_osnum;
      number_ids = 1;
   }
   for ( i = 0; i < number_ids; i++ )
   {
      status = om$send( mode = OM_e_wrt_object,
                        msg = message IGEgragad.DPcal( msg ),
                        senderid = NULL_OBJID,
                        targetid = gg_ids[i].objid,
                        targetos = gg_ids[i].osnum );

      if ( !( status & 1 ) )
      {
#ifdef DEBUG
         printf( "\nin DPcalinfo  DPcal send failed\n" );
         om$report_error( sts = status );
#endif
         break;
      }
   }    /* close for for */
   return ( status );
}


method DPcal( IGRlong * msg )

{
   IGRlong status;
   IGRlong vw_vol_msg;
   IGRshort n = 4;      /* the # of rows & columns in a square matrix, which
                         * is passed to a routine to find its inverse        */

/* The following 3 variables are used as parameters for the MAmulmx
   where 2 matrices are multiplied together.                          */
   IGRshort rows1 = 4;  /* the # of rows in the first matrix.        */
   IGRshort col1_rows2 = 4;     /* the # of columns in the first matrix which
                                 * equals the # of rows in the second matrix. */
   IGRshort col2 = 4;   /* the # of columns in the second matrix.     */
   IGRshort axis_aligned;       /* indicates if the view and wld axes are
                                 * aligned.                                 */
   IGRshort cpl_in_vwvol;       /* flag to indicate if the construction plane
                                 * is within the view volume      */
   IGRshort vvol_flag;  /* indicates if the clip flags are on   */

   IGRdouble temp;
   IGRdouble wn_matrix[4][4];   /* window and screen dependencies    */
   IGRdouble transVOR[4][4];    /* Translates the view origin to the world
                                 * origin */
   IGRdouble trans_vvol[4][4];  /* translates the view volume to the origin */
   IGRdouble scale[4][4];       /* scale matrix for moving from view to
                                 * viewport */
   IGRdouble vw_to_vwport[4][4];        /* view to viewport             */
   IGRdouble temp_1mx[4][4];    /* these are temporary matrices */
   IGRdouble project_mtx[4][4]; /* matrix to project a point to the
                                 * construction plane                     */
   IGRdouble view_to_wld[4][4]; /* matrix to take points from the viewing
                                 * coordinate system to world coordinates */
   IGRdouble z_ext_mtx[4][4];
   IGRdouble z_scrn_ext;
   IGRdouble y_ratio;   /* the ratio between the viewport & view volume's */
   IGRdouble x_ratio;   /* y distances. x_ratio is for the x distances. */
   IGRdouble y_vwvol;   /* the view volume's y distance  */
   IGRdouble x_vwvol;   /* the view volume's x distance  */
   IGRdouble new_ext;   /* new view volume extents       */
   IGRdouble ext_diff;  /* difference between the old view volume extents and
                         * the new extents divided by 2 */
   IGRdouble new_scale; /* the new view volume to viewport scale */
   IGRdouble x_trans;
   IGRdouble y_trans;
   IGRdouble y_vwport;  /* the viewport's y distance     */
   IGRdouble x_vwport;  /* the viewport's x distance     */
   IGRdouble temp_pts[6];       /* temporary points */
   IGRdouble tmp_pt[3]; /* temporary point */
   IGRdouble dot_prod;  /* the dot product (to see if the construction plane
                         * is perpendicular to the screen */
   IGRlong num_points;  /* the num_points being sent to be mult. by a matrix */
   IGRint display_ext[2];       /* display extents for the screen  */
   OMuint count;

   struct DPws_flags ws_flag;   /* workstation flags */
   struct IGRplane construct_plane;     /* construction plane */
   struct IGRlbsys loc_b_sys;   /* local bounded system (view volume) */
   IGRvector vw_direct_vec;     /* the view's direction vector (view_to_wld) */
   IGRvector vw_unit_vec;       /* the  "        "        "  after being made
                                 * a unit vector           */
   IGRvector construct_normal;  /* a vector normal to the construction plane */
   IGRpoint construct_origin;   /* construction plane's origin         */
   IGRchar const_plane_valid;   /* flag indicating if the construction plane
                                 * is currently valid for transformations  */
   struct DPgra_gad *gragad_ptr;

   IGRshort rect;
   IGRshort front;
   IGRshort back;


/*****************************************************************************/

   *msg = MSSUCC;
   status = OM_E_ABORT;

   gragad_ptr = &ME.IGEgragad->gragad;

   construct_plane.point = construct_origin;
   construct_plane.normal = construct_normal;

   /* initalizing matrices */

   if ( !MAidmx( msg, ( IGRdouble * ) transVOR ) )
   {
      goto fini;
   }

   memcpy( (void *)trans_vvol, (void *)transVOR, ( sizeof( IGRdouble ) * 16 ) );
   memcpy( (void *)scale, (void *)transVOR, ( sizeof( IGRdouble ) * 16 ) );
   memcpy( (void *)wn_matrix, (void *)transVOR, ( sizeof( IGRdouble ) * 16 ) );

   if ( gragad_ptr->flags & IS_PERSP )
   {
      status = OM_S_SUCCESS;
      status = om$send( mode = OM_e_wrt_object,
                        msg = message IGEgragad.DPcal_persp( msg ),
                        senderid = my_id,
                        targetid = my_id,
                        targetos = OM_Gw_current_OS );
      if ( !( status & 1 ) )
      {
#ifdef DEBUG
         printf( "\nin DPcal:  DPphigs send failed\n" );
         om$report_error( sts = status );
#endif
      }

   }
   else
   {

      /* The order of matrix multiplication for the world to viewport matrix is
         wn_matrix , (vvol_vwport) scale , trans_vvol , view_rotation, transVOR */

      /* First the world to view matrix is gotten by multipling the
         view_rotation,and transVOR matrices */

      if ( gragad_ptr->origin[0] < GRDGNLIMITS_MIN_D )
      {
         gragad_ptr->origin[0] = GRDGNLIMITS_MIN_D;
      }
      else if ( gragad_ptr->origin[0] > GRDGNLIMITS_MAX_D )
      {
         gragad_ptr->origin[0] = GRDGNLIMITS_MAX_D;
      }

      transVOR[0][3] = -gragad_ptr->origin[0];

      if ( gragad_ptr->origin[1] < GRDGNLIMITS_MIN_D )
      {
         gragad_ptr->origin[1] = GRDGNLIMITS_MIN_D;
      }
      else if ( gragad_ptr->origin[1] > GRDGNLIMITS_MAX_D )
      {
         gragad_ptr->origin[1] = GRDGNLIMITS_MAX_D;
      }

      transVOR[1][3] = -gragad_ptr->origin[1];

      if ( gragad_ptr->origin[2] < GRDGNLIMITS_MIN_D )
      {
         gragad_ptr->origin[2] = GRDGNLIMITS_MIN_D;
      }
      else if ( gragad_ptr->origin[2] > GRDGNLIMITS_MAX_D )
      {
         gragad_ptr->origin[2] = GRDGNLIMITS_MAX_D;
      }

      transVOR[2][3] = -gragad_ptr->origin[2];

      if ( !MAmulmx( msg, &rows1, &col1_rows2, &col2, ( IGRdouble * ) gragad_ptr->rotation,
                     ( IGRdouble * ) transVOR, ( IGRdouble * ) gragad_ptr->wld_to_view ) )
      {
         goto fini;
      }

      /* checking the vw_volume to be sure it is proportional with the window
       * size and within design limits */

      if ( !DPpresetvvol( &vw_vol_msg, gragad_ptr->vw_volume,
                          ME.IGEgadget->min_x_dep, ME.IGEgadget->max_x_dep,
                          ME.IGEgadget->min_y_dep, ME.IGEgadget->max_y_dep,
                        ( IGRdouble * ) gragad_ptr->wld_to_view ) )
      {
         *msg = vw_vol_msg;
         status = OM_S_SUCCESS;
         goto fini;
      }

      x_vwport = ME.IGEgadget->max_x_dep - ME.IGEgadget->min_x_dep;
      x_vwvol = gragad_ptr->vw_volume[3] - gragad_ptr->vw_volume[0];
      y_vwport = ME.IGEgadget->max_y_dep - ME.IGEgadget->min_y_dep;
      y_vwvol = gragad_ptr->vw_volume[4] - gragad_ptr->vw_volume[1];

      y_ratio = y_vwport / y_vwvol;
      x_ratio = x_vwport / x_vwvol;
      if ( y_ratio < x_ratio )
      {
         gragad_ptr->vvol_viewport_scale = y_ratio;
      }
      else
      {
         gragad_ptr->vvol_viewport_scale = x_ratio;
      }

      trans_vvol[0][3] = -gragad_ptr->vw_volume[0];
      trans_vvol[1][3] = -gragad_ptr->vw_volume[1];
      trans_vvol[2][3] = -gragad_ptr->vw_volume[2];

      /* Next the view to viewport matrix is found by multipling the wn_matrix,
         (vvol_vwport) scale,and trans_vvol matrices       */

      scale[0][0] = gragad_ptr->vvol_viewport_scale;
      scale[1][1] = gragad_ptr->vvol_viewport_scale;
      scale[2][2] = gragad_ptr->vvol_viewport_scale;

      if ( !MAmulmx( msg, &rows1, &col1_rows2, &col2, ( IGRdouble * ) scale,
                   ( IGRdouble * ) trans_vvol, ( IGRdouble * ) z_ext_mtx ) )
      {
         goto fini;
      }

      num_points = 2;
      if ( !MAptsxform( msg, &num_points, ( IGRdouble * ) z_ext_mtx,
                        gragad_ptr->vw_volume, temp_pts ) )
      {
         goto fini;
      }

      z_scrn_ext = temp_pts[5] - temp_pts[2];

      /* to keep from having the following duplication make function later or at
         least wait to "add" the wn_matrix to complete the matrices */

      /* Inquiring workstation dependency data */

      if ( !DPinqwsdep( msg, &ws_flag, display_ext, &gragad_ptr->dit_tol ) )
      {
         goto fini;
      }

      if ( ws_flag.x_origin )
      {
         wn_matrix[0][0] = -1.0;
         wn_matrix[0][3] = ME.IGEgadget->max_x_dep;
      }
      else
      {
         wn_matrix[0][3] = ME.IGEgadget->min_x_dep;
      }

      if ( ws_flag.y_origin )
      {
         wn_matrix[1][1] = -1.0;
         wn_matrix[1][3] = ME.IGEgadget->max_y_dep;
      }
      else
      {
         wn_matrix[1][3] = ME.IGEgadget->min_y_dep;
      }

      if ( ws_flag.y_origin && !ws_flag.x_origin || !ws_flag.y_origin && ws_flag.x_origin )
      {
         wn_matrix[2][2] = -1.0;
         wn_matrix[2][3] = z_scrn_ext;
      }

      if ( !MAmulmx( msg, &rows1, &col1_rows2, &col2, ( IGRdouble * ) wn_matrix,
                     ( IGRdouble * ) scale, ( IGRdouble * ) temp_1mx ) )
      {
         goto fini;
      }

      if ( !MAmulmx( msg, &rows1, &col1_rows2, &col2, ( IGRdouble * ) temp_1mx,
                ( IGRdouble * ) trans_vvol, ( IGRdouble * ) vw_to_vwport ) )
      {
         goto fini;
      }

      if ( !MAmulmx( msg, &rows1, &col1_rows2, &col2, ( IGRdouble * ) vw_to_vwport,
                     ( IGRdouble * ) gragad_ptr->wld_to_view,
                     ( IGRdouble * ) gragad_ptr->wld_to_viewport ) )
      {
         goto fini;
      }

      x_trans = MAdabs( msg, &gragad_ptr->wld_to_viewport[0][3] );
      y_trans = MAdabs( msg, &gragad_ptr->wld_to_viewport[1][3] );

      if ( ( x_trans > TRANS_LIMIT ) || ( y_trans > TRANS_LIMIT ) && ( vw_vol_msg != DPVWPTOOSM ) )
      {
         vw_vol_msg = DPDGNSLIMIT;
         if ( x_trans > y_trans )
         {
            temp = gragad_ptr->wld_to_view[0][3] - gragad_ptr->vw_volume[0];
            new_scale = TRANS_LIMIT / MAdabs( msg, &temp );
         }
         else
         {
            temp = gragad_ptr->wld_to_view[1][3] - gragad_ptr->vw_volume[1];
            new_scale = ( TRANS_LIMIT - ME.IGEgadget->max_y_dep ) / MAdabs( msg, &temp );
         }
         new_ext = x_vwvol * ( gragad_ptr->vvol_viewport_scale / new_scale );
         ext_diff = new_ext - x_vwvol;
         gragad_ptr->vw_volume[3] += ext_diff;

         new_ext = y_vwvol * ( gragad_ptr->vvol_viewport_scale / new_scale );
         ext_diff = new_ext - y_vwvol;
         gragad_ptr->vw_volume[4] += ext_diff;

         /* should I call DPpresetvvol to be sure that it is still within
          * design file limits (no since it is only a minute change)		 */

         trans_vvol[0][3] = -gragad_ptr->vw_volume[0];
         trans_vvol[1][3] = -gragad_ptr->vw_volume[1];
         trans_vvol[2][3] = -gragad_ptr->vw_volume[2];

         gragad_ptr->vvol_viewport_scale = new_scale;

         scale[0][0] = gragad_ptr->vvol_viewport_scale;
         scale[1][1] = gragad_ptr->vvol_viewport_scale;
         scale[2][2] = gragad_ptr->vvol_viewport_scale;

         if ( !MAmulmx( msg, &rows1, &col1_rows2, &col2, ( IGRdouble * ) scale,
                   ( IGRdouble * ) trans_vvol, ( IGRdouble * ) z_ext_mtx ) )
         {
            goto fini;
         }

         num_points = 2;
         if ( !MAptsxform( msg, &num_points, ( IGRdouble * ) z_ext_mtx,
                           gragad_ptr->vw_volume, temp_pts ) )
         {
            goto fini;
         }

         z_scrn_ext = temp_pts[5] - temp_pts[2];

         wn_matrix[2][3] = z_scrn_ext;

         if ( !MAmulmx( msg, &rows1, &col1_rows2, &col2, ( IGRdouble * ) wn_matrix,
                        ( IGRdouble * ) scale, ( IGRdouble * ) temp_1mx ) )
         {
            goto fini;
         }

         if ( !MAmulmx( msg, &rows1, &col1_rows2, &col2, ( IGRdouble * ) temp_1mx,
                ( IGRdouble * ) trans_vvol, ( IGRdouble * ) vw_to_vwport ) )
         {
            goto fini;
         }

         if ( !MAmulmx( msg, &rows1, &col1_rows2, &col2, ( IGRdouble * ) vw_to_vwport,
                        ( IGRdouble * ) gragad_ptr->wld_to_view,
                    ( IGRdouble * ) gragad_ptr->wld_to_viewport ) )
         {
            goto fini;
         }

      }

      if ( !MAtypemx( msg, ( IGRdouble * ) gragad_ptr->wld_to_viewport,
                      &gragad_ptr->wld_viewport_type ) )
      {
         goto fini;
      }

      /* inverses */
      if ( !MAinvmx( msg, &n, ( IGRdouble * ) gragad_ptr->wld_to_viewport,
                     ( IGRdouble * ) gragad_ptr->viewport_to_wld ) )
      {
         goto fini;
      }

      /**********************************************/
      /* construction plane calculations and checks */
      /**********************************************/

      /* If the user wants the construction plane to be on */

      if ( gragad_ptr->flags & CONST_PLANE_ON )
      {
         vw_direct_vec[0] = gragad_ptr->rotation[2][0];
         vw_direct_vec[1] = gragad_ptr->rotation[2][1];
         vw_direct_vec[2] = gragad_ptr->rotation[2][2];

         construct_plane.normal[0] = gragad_ptr->construct_plane[2][0];
         construct_plane.normal[1] = gragad_ptr->construct_plane[2][1];
         construct_plane.normal[2] = gragad_ptr->construct_plane[2][2];

         construct_plane.point[0] = gragad_ptr->construct_plane[0][3];
         construct_plane.point[1] = gragad_ptr->construct_plane[1][3];
         construct_plane.point[2] = gragad_ptr->construct_plane[2][3];

         if ( !MAunitvc( msg, vw_direct_vec, vw_unit_vec ) )
         {
            goto fini;
         }
         /* checking to see if the construction plane is still within the
          * view volume if the z clip flags are on.  If the plane is outside
          * the view volume, it is cut off.              */

         if ( (gragad_ptr->flags & FRONT_CLIP) || (gragad_ptr->flags & BACK_CLIP) )
         {
            if ( !MAinvmx( msg, &n, ( IGRdouble * ) gragad_ptr->wld_to_view,
                           ( IGRdouble * ) view_to_wld ) )
            {
               goto fini;
            }

            loc_b_sys.diag_pt1[0] = gragad_ptr->vw_volume[0];
            loc_b_sys.diag_pt1[1] = gragad_ptr->vw_volume[1];
            loc_b_sys.diag_pt1[2] = gragad_ptr->vw_volume[2];
            loc_b_sys.diag_pt2[0] = gragad_ptr->vw_volume[3];
            loc_b_sys.diag_pt2[1] = gragad_ptr->vw_volume[4];
            loc_b_sys.diag_pt2[2] = gragad_ptr->vw_volume[5];

            memcpy( (void *)loc_b_sys.matrix, (void *) view_to_wld, ( sizeof( IGRdouble ) * 16 ) );

            if ( (gragad_ptr->flags & FRONT_CLIP) && (gragad_ptr->flags & BACK_CLIP) )
            {
               vvol_flag = 0;
            }
            else if ( gragad_ptr->flags & BACK_CLIP )
            {
               vvol_flag = 1;
            }
            else
            {
               vvol_flag = 2;
            }

            if ( !MApllbrel( msg, &construct_plane, &loc_b_sys, &vvol_flag,
                             &cpl_in_vwvol ) )
            {
               goto fini;
            }
         }      /* close for if clip is on */
         else
         {
            cpl_in_vwvol = 1;
         }
         /* checking to see if the construction plane is almost perpendicular
          * to the direction of the view.  If this is true, then most input
          * points cannot be projected onto the construction plane, and the
          * construction plane is temporarily disabled.                     */

         if ( !MAdotvc( msg, vw_unit_vec, construct_plane.normal, &dot_prod ) )
         {
            goto fini;
         }
         if ( dot_prod > -0.1 && dot_prod < 0.1 )
         {
            const_plane_valid = 0;
         }
         else
         {
            const_plane_valid = 1;
         }
         /* if the construction plane is NOT VALID */

         if ( !const_plane_valid || !cpl_in_vwvol )
         {
            if ( gragad_ptr->flags & VALID_ALT_INV )
            {
               if ( !const_plane_valid )
               {
/*
                ex$message ( msgnumb = GR_E_CnsPlOffRot);
*/
               }
               else
               {
/*
                ex$message ( msgnumb = GR_E_CnsPlOutVwVol);
*/
               }
               gragad_ptr->flags &= ~VALID_ALT_INV;
/*
            EX_bell();
            sleep (3);
*/
            }
         }

         /* If the construction plane is VALID */

         if ( const_plane_valid && cpl_in_vwvol )
         {
            gragad_ptr->flags |= VALID_ALT_INV;

            /* finding the matrix necessary to project a point in WCS onto
             * the construction plane                                       */

            if ( !MApapromx( msg, vw_unit_vec, &construct_plane,
                             ( IGRdouble * ) project_mtx ) )
            {
               goto fini;
            }
            /* calculating the matrix that will take a point on the screen
             * and project it onto the construction plane in WCS            */

            if ( !MAmulmx( msg, &rows1, &col1_rows2, &col2, ( IGRdouble * ) project_mtx,
                       ( IGRdouble * ) gragad_ptr->viewport_to_wld,
                  ( IGRdouble * ) gragad_ptr->alt_vwport_to_wld ) )
            {
               goto fini;
            }
         }      /* close for if c.p. is valid */
      } /* close for if c.p. wanted on */

      if ( gragad_ptr->act_z > gragad_ptr->vw_volume[5] ||
           gragad_ptr->act_z < gragad_ptr->vw_volume[2] )
      {
         gragad_ptr->act_z = ( gragad_ptr->vw_volume[2] +
                                  gragad_ptr->vw_volume[5] ) / 2.0;
         if ( *msg == MSSUCC && vw_vol_msg == MSSUCC )
         {
            vw_vol_msg = DPDDOUTDGN;
         }
      }

      num_points = 1;
      tmp_pt[0] = 0.0;
      tmp_pt[1] = 0.0;
      tmp_pt[2] = gragad_ptr->act_z;
      if ( !MAptsxform( msg, &num_points, ( IGRdouble * ) vw_to_vwport, tmp_pt,
                        tmp_pt ) )
      {
         goto fini;
      }
      gragad_ptr->act_z_screen = tmp_pt[2];

      num_points = 2;

      if ( !MAptsxform( msg, &num_points, ( IGRdouble * ) vw_to_vwport,
                        gragad_ptr->vw_volume, temp_pts ) )
      {
         goto fini;
      }

      if ( temp_pts[0] < temp_pts[3] )
      {
         gragad_ptr->dit_clip_range[0] = temp_pts[0];
         gragad_ptr->dit_clip_range[3] = temp_pts[3];
      }
      else
      {
         gragad_ptr->dit_clip_range[0] = temp_pts[3];
         gragad_ptr->dit_clip_range[3] = temp_pts[0];
      }

      if ( temp_pts[1] < temp_pts[4] )
      {
         gragad_ptr->dit_clip_range[1] = temp_pts[1];
         gragad_ptr->dit_clip_range[4] = temp_pts[4];
      }
      else
      {
         gragad_ptr->dit_clip_range[1] = temp_pts[4];
         gragad_ptr->dit_clip_range[4] = temp_pts[1];
      }

      if ( temp_pts[2] < temp_pts[5] )
      {
         gragad_ptr->dit_clip_range[2] = temp_pts[2];
         gragad_ptr->dit_clip_range[5] = temp_pts[5];
      }
      else
      {
         gragad_ptr->dit_clip_range[2] = temp_pts[5];
         gragad_ptr->dit_clip_range[5] = temp_pts[2];
      }

      /* the vv_range is now being set for perspective in DPcalpersp */
      DPsetrng( msg, ( IGRdouble * ) gragad_ptr->wld_to_view,
                &gragad_ptr->vv_range_chk );

      status = OM_S_SUCCESS;

   }    /* close for else (meaning no perspective) */

        DLset_z_depth( ME.IGEgragad->gragad.gpipe_id,
                ME.IGEgragad->gragad.dit_clip_range[5] -
                ME.IGEgragad->gragad.dit_clip_range[2] );

   /* The axis_wld_align bit indicates if the view's coordinate system
      is aligned to the world's coordinate system.  The bit is set to a
      1 if the axes are aligned and set to a 0 otherwise.               */

   if ( !( DPaxisalign( msg, ( IGRdouble * ) gragad_ptr->rotation,
                        &axis_aligned ) ) )
   {
      goto fini;
   }

   if ( axis_aligned == 1 )
   {
      gragad_ptr->flags |= AXIS_WLD_ALIGN;
   }
   else
   {
      gragad_ptr->flags &= ~AXIS_WLD_ALIGN;
   }

   rect = gragad_ptr->flags & CLIP;
   front = gragad_ptr->flags & FRONT_CLIP;
   back = gragad_ptr->flags & BACK_CLIP;

   if ( ( gragad_ptr->flags & IS_WIN_ON ) && ( !( ex$is_batch(  ) ) ) )
   {
      if ( gragad_ptr->flags & IS_PERSP )
      {
         DPpush_vwmtx( msg, ( IGRdouble * ) gragad_ptr->wld_to_view,
                       gragad_ptr->vvol_viewport_scale,
                       gragad_ptr->gpipe_id,
                       gragad_ptr->eye_pt,
                       gragad_ptr->vup,
                       gragad_ptr->vpn );
      }
      else
      {



         DPpush_vwmtx( msg, ( IGRdouble * ) gragad_ptr->wld_to_viewport,
                       gragad_ptr->vvol_viewport_scale,
                       gragad_ptr->gpipe_id,
                       NULL, NULL, NULL );
      }
      /* added vw_volume parameter for OPENGL setup for perspective */
      DPpush_clip( msg, rect, front, back, gragad_ptr->dit_clip_range,
            gragad_ptr->gpipe_id, gragad_ptr->vw_volume );
   }

   DPsetrng( msg, ( IGRdouble * ) gragad_ptr->wld_to_viewport,
             &gragad_ptr->range_chk );

   if ( !( gragad_ptr->flags & IS_PERSP ) )
   {
      *msg = vw_vol_msg;
   }

   if ( ! winsup_chandef_defined )
   {
      status = om$make_chanselect( channame = "IGEgragad.winsup",
                                   p_chanselect = &winsup_chandef );

      if ( !( status & 1 ) )
      {
#ifdef DEBUG
         om$report_error( sts = status );
#endif
         goto fini;
      }
      winsup_chandef_defined = TRUE;
   }

   status = om$get_channel_count( objid = my_id,
                                  p_chanselect = &winsup_chandef,
                                  count = &count );

   if ( !( status & 1 ) )
   {
#ifdef DEBUG
      om$report_error( sts = status );
#endif
      goto fini;
   }

   if ( count )
   {

      status = om$send( msg = message IGEwinsup.view_changed( msg ),
                        senderid = my_id,
                        p_chanselect = &winsup_chandef );

      /* protect against unknown objects */
      if ( status == OM_E_NOSUCHCLASS )
      {
         status = OM_S_SUCCESS;
      }

      if ( !( status & 1 ) )
      {
#ifdef DEBUG
         om$report_error( sts = status );
#endif
      }
   }

fini:
   return ( status );
}

end implementation IGEgragad;
