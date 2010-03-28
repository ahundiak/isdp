#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "wl.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

#include "ma.h"

/* old prototypes */
#include "mazrotmx.h"
#include "maptsxfor.h"
#include "mazrotmx.h"
#include "matrlmx.h"
#include "mamulmx.h"

extern int      WLIglx_last_win_type;
extern int	WLhilite_enabled;
extern int DLIreport_errors;
extern IGRboolean DPdlist_use_display_list;

static double DLIidentity_d[16] = { 1.0, 0.0, 0.0, 0.0,
                                    0.0, 1.0, 0.0, 0.0,
                                    0.0, 0.0, 1.0, 0.0,
                                    0.0, 0.0, 0.0, 1.0 };

static float DLIidentity_f[16] = { 1.0, 0.0, 0.0, 0.0,
                                   0.0, 1.0, 0.0, 0.0,
                                   0.0, 0.0, 1.0, 0.0,
                                   0.0, 0.0, 0.0, 1.0 };


/*--- DLset_z_depth ---------------------------------------------*/

int DLset_z_depth ( int pipe_id, double z_depth )

/*
NAME
   DLset_z_depth

DESCRIPTION
   This function sets the z depth for the pipe.  This value
   is used with OpenGL, EG and XGL for computing the matrices
   and viewports for reference file attachments.

SYNOPSIS
   int DLset_z_depth(
      int pipe_id,
      int z_depth )

PARAMETERS
   pipe_id (IN) - the drawing pipeline id
   z_depth (IN) - the z depth of the masterfile view volume

GLOBALS USED
   none

RETURN VALUES
   DL_SUCCESS
      Success
   DL_BAD_PIPELINE_ID
      The drawing pipeline id is invalid.

HISTORY
   01/21/95    Mike Lanier
      Initial definition
*/

   {
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe (pipe_id, &pipe);
   if( sts != DL_SUCCESS )
      {
      DL_REPORT_ERROR(sts);
      return(sts);
      }

   pipe->z_depth = z_depth;

   return( DL_SUCCESS );

   }    /* DLset_z_depth */

/*--- DLIsetup_DL_window -----------------------------------------------------------*/

int DLIsetup_DL_window(
   struct DLpipeline *pipe )

/*
NAME
   DLIsetup_DL_window

DESCRIPTION
   This function sets up the matrices required for DL to do all the
   transformations and clipping for a drawing pipeline.

SYNOPSIS
   int DLIsetup_DL_window(
      struct DLpipeline *pipe )

PARAMETERS
   pipe (IN) - the pipeline structure that is being used

GLOBALS USED
   none

RETURN VALUES
   DL_SUCCESS
      Success

HISTORY  
   09/20/93 S.P. Rogers
      Creation Date
*/

{
   int ii, jj;

   if ( pipe->clip_flag & DLI_CL_MOD_IDENTITY )
   {
      memcpy( pipe->matrix, pipe->viewing_matrix, 16 * sizeof( double ) );
   }
   else
   {
      /* multiply modelling and viewing matrices together to get */
      /* a composite transformation matrix                       */
      for ( ii = 0; ii < 4; ii++ )
      {
         for ( jj = 0; jj < 4; jj++ )
         {
            pipe->matrix[ii*4 + jj] = pipe->modelling_matrix[ii*4 + 0] * pipe->viewing_matrix[0*4 + jj] +
                                      pipe->modelling_matrix[ii*4 + 1] * pipe->viewing_matrix[1*4 + jj] +
                                      pipe->modelling_matrix[ii*4 + 2] * pipe->viewing_matrix[2*4 + jj] +
                                      pipe->modelling_matrix[ii*4 + 3] * pipe->viewing_matrix[3*4 + jj];
         }
      }
   }

   return( DL_SUCCESS );
}  /* DLIsetup_DL_window */

#if defined( ENV5 )
/*--- DLIsetup_EG_window ------------------------------------------_*/

int DLIsetup_EG_window(
   struct DLpipeline *pipe )

/*
NAME
   DLIsetup_EG_window

DESCRIPTION
   This function sets up the matrices required for EG.

SYNOPSIS
   int DLIsetup_EG_window(
      struct DLpipeline *pipe )

PARAMETERS
   pipe (IN) - the pipeline structure that is being used

GLOBALS USED
   none

RETURN VALUES
   DL_SUCCESS
      Success

HISTORY  
   09/20/93 S.P. Rogers
      Creation Date
*/

{
   int sts, ii, jj;
   double new_ylo, new_yhi, new_zlo, new_zhi;
   double z_scale;
   EGPoint3 vrp;
   EGVect3 vpn, vup;
   EGViewMap3 view_map;
   EGMatrix3 mult_mat;

   /* To enhance performance, we need not set the EG pipeline always */
   if ( !DPdlist_use_display_list && 
        ( pipe->base_context_info.base_cmap_type == WL_CMAP_INDEXED ) )
   {
      return( DL_SUCCESS );
   }

   if ( pipe->type == DL_ORTHO_PIPE )
   {
      /* transpose for EG */
      for ( ii = 0; ii < 4; ii++ )
      {
         for ( jj = 0; jj < 4; jj++ )
         {
            pipe->view_rep.oriMatrix[jj][ii] = pipe->viewing_matrix[ii*4 + jj];
         }
      }

      /* flip Y's and Z's */
      for ( ii = 0; ii < 4; ii++ )
      {
         pipe->view_rep.oriMatrix[1][ii] = -pipe->view_rep.oriMatrix[1][ii];
         pipe->view_rep.oriMatrix[2][ii] = -pipe->view_rep.oriMatrix[2][ii];
      }

      /* y's and z's have been flipped, so get new los and his */
      new_ylo = -pipe->view.yhi;
      new_yhi = -pipe->view.ylo;

      new_zlo = -pipe->view.zhi;
      new_zhi = -pipe->view.zlo;

      /* build mapping matrix that goes from VRC to NPC => remember   */
      /* that NPC goes from 0.0 - 1.0 for x, y, and z;                */

      /* | 1/(xhi-xlo)     0.0         0.0     0.0 |   | 1.0 0.0 0.0 -xlo | */
      /* |     0.0     1/(yhi-ylo)     0.0     0.0 | * | 0.0 1.0 0.0 -ylo | */
      /* |     0.0         0.0     1/(zhi-zlo) 0.0 |   | 0.0 0.0 1.0 -zlo | */
      /* |     0.0         0.0         0.0     0.0 |   | 0.0 0.0 0.0  1.0 | */

      memcpy( pipe->view_rep.mapMatrix, DLIidentity_f, 16 * sizeof( float ) );

      pipe->view_rep.mapMatrix[0][0] = 1.0 / (pipe->view.xhi - pipe->view.xlo);
      pipe->view_rep.mapMatrix[1][1] = 1.0 / (new_yhi - new_ylo);
      pipe->view_rep.mapMatrix[2][2] = 1.0 / (new_zhi - new_zlo);

      pipe->view_rep.mapMatrix[0][3] = (-pipe->view.xlo) / (pipe->view.xhi - pipe->view.xlo);
      pipe->view_rep.mapMatrix[1][3] = (-new_ylo) / (new_yhi - new_ylo);
      pipe->view_rep.mapMatrix[2][3] = (-new_zlo) / (new_zhi - new_zlo);
   
   }
   else
   {
      /* perspective pipeline */
      vrp.x = pipe->eye[0];
      vrp.y = pipe->eye[1];
      vrp.z = pipe->eye[2];

      /* negate vpn to match PHIGS */
      vpn.x = -pipe->vpn[0];
      vpn.y = -pipe->vpn[1];
      vpn.z = -pipe->vpn[2];

      vup.x = pipe->vup[0];
      vup.y = pipe->vup[1];
      vup.z = pipe->vup[2];

      /* orientation matrix to rotate from world coords to VRC */
      sts = EGEvalViewOriMatrix3( &vrp, &vpn, &vup, pipe->view_rep.oriMatrix );
      if ( sts != 0 )
      {
         DL_REPORT_ERROR( DL_ERROR );
         return( DL_ERROR );
      }

      view_map.proj = EG_PERSPECTIVE;
      view_map.projRef.x = 0.0;
      view_map.projRef.y = 0.0;
      view_map.projRef.z = 0.0;

      view_map.viewPlane = -pipe->vw_volume[5];
      view_map.frontPlane = -pipe->vw_volume[2];
      view_map.backPlane = -pipe->vw_volume[5];

      view_map.viewPlaneLimits.xMin = pipe->vw_volume[0];
      view_map.viewPlaneLimits.xMax = pipe->vw_volume[3];

      view_map.viewPlaneLimits.yMin = pipe->vw_volume[1];
      view_map.viewPlaneLimits.yMax = pipe->vw_volume[4];

      view_map.projLimits.xMin = 0.0;
      view_map.projLimits.yMin = 0.0;
      view_map.projLimits.zMin = 0.0;

      view_map.projLimits.xMax = 1.0;
      view_map.projLimits.yMax = 1.0;
      view_map.projLimits.zMax = 1.0;

      /* mapping matrix to go from VRC to NPC */
      sts = EGEvalViewMapMatrix3( &view_map, pipe->view_rep.mapMatrix );
      if ( sts != 0 )
      {
         DL_REPORT_ERROR( DL_ERROR );
         return( DL_ERROR );
      }
   }

   pipe->view_rep.clipLimits.xMin = 0.0;
   pipe->view_rep.clipLimits.yMin = 0.0;
   pipe->view_rep.clipLimits.zMin = 0.0;

   pipe->view_rep.clipLimits.xMax = 1.0;
   pipe->view_rep.clipLimits.yMax = 1.0;
   pipe->view_rep.clipLimits.zMax = 1.0;

   pipe->view_rep.clipXY = EG_ON;
   pipe->view_rep.clipFront = EG_ON;
   pipe->view_rep.clipBack = EG_ON;

   if ( !(pipe->clip_flag & DLI_CL_MOD_IDENTITY) )
   {
      /* multiply in the modelling matrix, we are calculating:  */
      /*  mult_mat = ori_matrix * transpose(modelling_matrix)   */
      /* the transpose is needed because EG's matrices have the */
      /* translation in the last column instead of the last row */
      /* like DL and GPIPE                                      */
      for ( ii = 0; ii < 4; ii++ )
      {
         for ( jj = 0; jj < 4; jj++ )
         {
            mult_mat[ii][jj] =
               pipe->view_rep.oriMatrix[ii][0] * pipe->modelling_matrix[jj*4 + 0] +
               pipe->view_rep.oriMatrix[ii][1] * pipe->modelling_matrix[jj*4 + 1] +
               pipe->view_rep.oriMatrix[ii][2] * pipe->modelling_matrix[jj*4 + 2] +
               pipe->view_rep.oriMatrix[ii][3] * pipe->modelling_matrix[jj*4 + 3];
         }
      }

      memcpy( pipe->view_rep.oriMatrix, mult_mat, sizeof( EGMatrix3 ) );
   }

   sts = EGSetViewRep( pipe->eg_vc, &pipe->view_rep );
   if ( sts != 0 )
   {
      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }

   z_scale = (EG_MAX_Z_VALUE)/pipe->z_depth;

   /* not setting NPC limits because the defaults */
   /* are the unit cube which is what we want     */
   pipe->dc_limits.xMin = pipe->view.xlo;
   pipe->dc_limits.yMin = pipe->view.ylo;
   pipe->dc_limits.zMin = (pipe->z_depth - pipe->view.zhi) * z_scale;
   pipe->dc_limits.xMax = pipe->view.xhi;
   pipe->dc_limits.yMax = pipe->view.yhi;
   pipe->dc_limits.zMax = EG_MAX_Z_VALUE;
   pipe->dc_limits.zMax = (pipe->z_depth - pipe->view.zlo) * z_scale;

   /* Would return an error if =.  This is possible for reference */
   /* planes going to the same value when zoomed out.             */
   if ((pipe->dc_limits.xMin == pipe->dc_limits.xMax) ||
       (pipe->dc_limits.yMin == pipe->dc_limits.yMax) ||
       (pipe->dc_limits.zMin == pipe->dc_limits.zMax))
   {
      if (pipe->dc_limits.xMin == pipe->dc_limits.xMax)
      {
         if (pipe->dc_limits.xMin > 0)
         {
            pipe->dc_limits.xMin--;
         }
         else
         {
            pipe->dc_limits.xMax++;
         }
      }
      if (pipe->dc_limits.yMin == pipe->dc_limits.yMax)
      {
         if (pipe->dc_limits.yMin > 0)
         {
            pipe->dc_limits.yMin--;
         }
         else
         {
            pipe->dc_limits.yMax++;
         }
      }
      if (pipe->dc_limits.zMin == pipe->dc_limits.zMax)
      {
         pipe->dc_limits.zMin--;
      }
   }

   sts = EGSetViewport( pipe->eg_vc, &pipe->dc_limits );
   if ( sts != 0 )
   {
      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }

   return( DL_SUCCESS );
} /* DLIsetup_EG_window */

/*--- DLsync_EG_window ------------------------------------------_*/

int DLsync_EG_window( )

/*
NAME
   DLsync_EG_window

DESCRIPTION
   This function syncs up EG window

SYNOPSIS
   int DLsync_EG_window( )

PARAMETERS

GLOBALS USED
   none

RETURN VALUES
   DL_SUCCESS
      Success

HISTORY  
   02/11/94 Shridar Subramanian
      Creation Date
*/

{
   int i;
   int sts;
   struct DLpipeline *pipe;
 
   for ( i = 0; i < DL_MAX_PIPES; i++ )
   {
      sts = DLIvalidate_pipe( i, &pipe );
      if (sts == DL_SUCCESS )
      {
         if ( pipe->using_eg )
         {
            DLIsetup_EG_window( pipe );
         }
      }
   }
   return( DL_SUCCESS );
}
#endif


#if defined( OPENGL )
/*--- DLIsetup_OPENGL_window --------------------------------------------*/

int DLIsetup_OPENGL_window(
  struct DLpipeline *pipe,
  short viewport_changed )

/*
NAME
	DLIsetup_OPENGL_window

DESCRIPTION
   This function sets up the matrices required for OPENGL.

SYNOPSIS
   int DLIsetup_OPENGL_window(
      struct DLpipeline *pipe,
      short viewport_changed )

PARAMETERS
	pipe (IN) - the drawing pipeline
        viewport_changed (IN) - TRUE, if the viewport has changed

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLviewport *view;
   struct WLbounds win_bounds;
   GLfloat gl_matrix[16], modelview[16], projection[16];
   double x_trans, y_trans;
   double angle;
   int viewport[4];

   pipe->clip_flag |= DLI_CL_MATRIX_CHANGED;
   
   view = &pipe->view;

   WLglx_make_window_current( pipe->lwin_no, WL_GLX_BASE_WIN );

   WLget_window_bounds( pipe->lwin_no, NULL, &win_bounds );

   if ( viewport_changed )
   {
      /* y's are inverted because OpenGL's origin is in */
      /* the lower-left hand corner of the window       */
      glViewport( (int) view->xlo, 
                  (int) win_bounds.height - view->yhi - 1,
                  (int) (view->xhi - view->xlo) + 1, 
                  (int) (view->yhi - view->ylo) + 1 );

      glDepthRange( view->zlo/pipe->z_depth, view->zhi/pipe->z_depth );
   }
   
   if ( pipe->type != DL_PERSP_PIPE )
   {
      /* Parallel pipe */
      /* build a model view matrix that consists of the following */
      /* components:  T * S * M, where M is the viewing matrix    */
      /* passed in to DLset_matrix(), S is a scaling matrix that  */
      /* flips the Y's and Z's because M has these coordinates    */
      /* flipped with respect to OpenGL, and T is a translation   */
      /* matrix that translates the "eye coordinates" so they are */
      /* centered about the origin in the XY plane.  This is      */
      /* necessary so specular reflections are calculated         */
      /* correctly.  After S is applied to M, the coordinates end */
      /* up in the 4th quadrant of the XY plane, so T translates  */
      /* from the 4th quadrant to the origin.                     */

      /* load T */
      x_trans = -win_bounds.width / 2.0;
      y_trans = win_bounds.height / 2.0;
#if defined( TOO_SLOW )
      glLoadIdentity();

      glTranslated( x_trans, y_trans, 0.0 );

      /* multiply by S, scale matrix to flip Y's and Z's */
      glScaled( 1.0, -1.0, -1.0 );
         
      /* multiply by M */
      glMultMatrixd( pipe->viewing_matrix );
#endif
      gl_matrix[0] = pipe->viewing_matrix[0];
      gl_matrix[1] = -pipe->viewing_matrix[1];
      gl_matrix[2] = -pipe->viewing_matrix[2];
      gl_matrix[3] = pipe->viewing_matrix[3];
      gl_matrix[4] = pipe->viewing_matrix[4];
      gl_matrix[5] = -pipe->viewing_matrix[5];
      gl_matrix[6] = -pipe->viewing_matrix[6];
      gl_matrix[7] = pipe->viewing_matrix[7];
      gl_matrix[8] = pipe->viewing_matrix[8];
      gl_matrix[9] = -pipe->viewing_matrix[9];
      gl_matrix[10] = -pipe->viewing_matrix[10];
      gl_matrix[11] = pipe->viewing_matrix[11];
      gl_matrix[12] = pipe->viewing_matrix[12] + x_trans;
      gl_matrix[13] = -pipe->viewing_matrix[13] + y_trans;
      gl_matrix[14] = -pipe->viewing_matrix[14];
      gl_matrix[15] = pipe->viewing_matrix[15];
      
      glLoadMatrixf( gl_matrix );
      glMatrixMode( GL_PROJECTION );
      glLoadIdentity();
   
      /* the y's are inverted because we had to mirror */
      /* about the y axis because OpenGL's origin is   */
      /* in the lower-left hand corner of the window   */
      glOrtho( view->xlo + x_trans, view->xhi + x_trans,
               -view->yhi + y_trans, -view->ylo + y_trans,
               view->zlo, view->zhi );
               
   }
   else
   {
      /* Perspective pipe */
      glLoadIdentity();
      gluLookAt( pipe->eye[0], pipe->eye[1], pipe->eye[2],
                 pipe->eye[0] + pipe->vpn[0], pipe->eye[1] + pipe->vpn[1], pipe->eye[2] + pipe->vpn[2],
                 pipe->vup[0], pipe->vup[1], pipe->vup[2] );
                 

      glMatrixMode( GL_PROJECTION );
      glLoadIdentity();

      /* get the field of view along the Y axis */
      angle = atan( pipe->vw_volume[4] / pipe->vw_volume[5] );
      angle = 360 * angle / 3.14159;
      gluPerspective( angle, 
                      (pipe->vw_volume[3] - pipe->vw_volume[0]) /
                      (pipe->vw_volume[4] - pipe->vw_volume[1]),
                      pipe->vw_volume[2], pipe->vw_volume[5] );
   }

   /* make sure MODELVIEW matrix is active */
   glMatrixMode( GL_MODELVIEW );

   /* multiply in the DL modelling matrix */
   if ( !(pipe->clip_flag & DLI_CL_MOD_IDENTITY) )
   {
      glMultMatrixd( pipe->modelling_matrix );
   }

   if ( viewport_changed )
   {
      if ( pipe->base_context_info.flags & WL_SEPARATE_HILITE )
      {
         /* we must load the new viewport into the hilite context */
         /* because it is needed to WL drawing                    */
         glGetIntegerv( GL_VIEWPORT, viewport );
      
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_HILITE_WIN );

         glViewport( viewport[0], viewport[1], viewport[2], viewport[3] );
      }

   }

   return( DL_SUCCESS );
}  /* DLIsetup_OPENGL_window */

/*--- DLIsync_OPENGL_hilite_matrices --------------------------------------------------*/

int DLIsync_OPENGL_hilite_matrices(
   struct DLpipeline *pipe )
   
/*
NAME
   DLIsync_OPENGL_hilite_matrices

DESCRIPTION
   This function syncs the matrices in the hilite context for OpenGL
   pipelines that have separate hilite

SYNOPSIS
   int DLIsync_OPENGL_hilite_matrices(
      struct DLpipeline *pipe )

PARAMETERS
   pipe (IN) - the drawing pipeline
   
GLOBALS USED
   none

RETURN VALUES
   DL_SUCCESS
      Success

HISTORY
   10/14/93 S.P. Rogers
      Creation Date
*/

{
   float modelview[16], projection[16];
   int viewport[4];
   
   if ( ! (pipe->clip_flag & DLI_CL_MATRIX_CHANGED) )
   {
      return( DL_SUCCESS );
   }
   
   pipe->clip_flag &= ~DLI_CL_MATRIX_CHANGED;
   
   if ( pipe->base_context_info.flags & WL_SEPARATE_HILITE )
   {
      /* get matrices and viewport from the base window and copy to hilite window */
      WLglx_make_window_current( pipe->lwin_no, WL_GLX_BASE_WIN );
      
      glGetFloatv( GL_MODELVIEW_MATRIX, modelview );
      glGetFloatv( GL_PROJECTION_MATRIX, projection );
      glGetIntegerv( GL_VIEWPORT, viewport );
      
      WLglx_make_window_current( pipe->lwin_no, WL_GLX_HILITE_WIN );

      glViewport( viewport[0], viewport[1], viewport[2], viewport[3] );

      glLoadMatrixf( modelview );
      glMatrixMode( GL_PROJECTION );
      glLoadMatrixf( projection );

      /* make sure MODELVIEW matrix is active */
      glMatrixMode( GL_MODELVIEW );
   }

   return( DL_SUCCESS );
} /* DLIsync_OPENGL_hilite_matrices */
#endif

#if defined( XGL )

/*--- DLIsetup_XGL_window --------------------------------------------*/

int DLIsetup_XGL_window( struct DLpipeline *pipe,
                                     short viewport_changed )

/*
NAME
   DLIsetup_XGL_window

DESCRIPTION
   This function sets up the matrices required for XGL.

SYNOPSIS
   int DLIsetup_XGL_window( struct DLpipeline *pipe, 
                                        short viewport_changed )

PARAMETERS
   pipe (IN) - the drawing pipeline
   viewport_changed (IN) - TRUE, if the viewport has changed

GLOBALS USED
   none

RETURN VALUES
   DL_SUCCESS
      Success

HISTORY
   02/23/93    M. Lanier
      Initial definition
*/

   {
   int			sts;
   struct DLviewport	*view;
   struct WLbounds	win_bounds;
   Xgl_object		view_trans, model_trans;
   Xgl_object		modelling_trans, loc_model_trans;
   Xgl_bounds_d3d	xgl_viewport;
   Xgl_bounds_d3d	xgl_window;
   Xgl_matrix_f3d	xgl_matrix;
   int			viewport[4];
   int			i, j;
   double		xtrans, ytrans;

   pipe->clip_flag |= DLI_CL_MATRIX_CHANGED;
   
   view = &pipe->view;

   WLget_window_bounds( pipe->lwin_no, NULL, &win_bounds );

   /*  Translate by half the extent of the window, so as to get */
   /*  the eye point in the center of the viewport.  Do this */
   /*  for both parallel and perspective because it makes things */
   /*  simpler when your consistent */

   xtrans = (double)win_bounds.width * 0.5;
   ytrans = (double)win_bounds.height * 0.5;

/*xtrans = ytrans = 0.0;*/

   if ( viewport_changed )
      {
      xgl_viewport.xmin = view->xlo - xtrans;
      xgl_viewport.xmax = view->xhi - xtrans;
      xgl_viewport.ymin = view->ylo - ytrans;
      xgl_viewport.ymax = view->yhi - ytrans;
      
      xgl_viewport.zmin = view->zlo;
      xgl_viewport.zmax = view->zhi;

      /*
       *  For some reason, setting the XGL_CTX_VDC_WINDOW and 
       *  XGL_CTX_DC_VIEWPORT is the thing to do for perspective
       *  windows, but not for parallel windows.  Putting this
       *  condition in seems to give the best of both worlds
       *  ML 4/26
       */

      if( pipe->type == DL_PERSP_PIPE )
         {
         xgl_object_set( pipe->xgl_context_3D,
                         XGL_CTX_VIEW_CLIP_BOUNDS,	&xgl_viewport,
                         XGL_CTX_VDC_MAP,		XGL_VDC_MAP_ASPECT,
                         XGL_CTX_VDC_WINDOW,		&xgl_viewport,
                         /*XGL_CTX_DC_VIEWPORT,		&xgl_viewport,*/
                         XGL_CTX_CLIP_PLANES,		XGL_CLIP_XMIN | 
                      					XGL_CLIP_XMAX |
                      					XGL_CLIP_YMIN | 
                      					XGL_CLIP_YMAX |
                      					XGL_CLIP_ZMIN | 
                      					XGL_CLIP_ZMAX , 
                         NULL );

         if ( pipe->base_context_info.flags & WL_SEPARATE_HILITE )
            {
            xgl_object_set( pipe->hl_xgl_context_3D,
                            XGL_CTX_VIEW_CLIP_BOUNDS,	&xgl_viewport,
                            XGL_CTX_VDC_MAP,		XGL_VDC_MAP_ASPECT,
                            XGL_CTX_VDC_WINDOW,		&xgl_viewport,
                            /*XGL_CTX_DC_VIEWPORT,	&xgl_viewport,*/
                            XGL_CTX_CLIP_PLANES,	XGL_CLIP_XMIN | 
                         				XGL_CLIP_XMAX | 
                         				XGL_CLIP_YMIN | 
                         				XGL_CLIP_YMAX | 
                         				XGL_CLIP_ZMIN | 
                         				XGL_CLIP_ZMAX , 
                            NULL );
            }
         }
      else
         {
         xgl_object_set( pipe->xgl_context_3D,
                         XGL_CTX_VIEW_CLIP_BOUNDS,	&xgl_viewport,
                         XGL_CTX_VDC_MAP,		XGL_VDC_MAP_ASPECT,
                         /*XGL_CTX_VDC_WINDOW,		&xgl_viewport,*/
                         /*XGL_CTX_DC_VIEWPORT,		&xgl_viewport,*/
                         XGL_CTX_CLIP_PLANES,		XGL_CLIP_XMIN | 
                      					XGL_CLIP_XMAX |
                      					XGL_CLIP_YMIN | 
                      					XGL_CLIP_YMAX |
                      					XGL_CLIP_ZMIN | 
                      					XGL_CLIP_ZMAX , 
                         NULL );

         if ( pipe->base_context_info.flags & WL_SEPARATE_HILITE )
            {
            xgl_object_set( pipe->hl_xgl_context_3D,
                            XGL_CTX_VIEW_CLIP_BOUNDS,	&xgl_viewport,
                            XGL_CTX_VDC_MAP,		XGL_VDC_MAP_ASPECT,
                            /*XGL_CTX_VDC_WINDOW,	&xgl_viewport, */
                            /*XGL_CTX_DC_VIEWPORT,	&xgl_viewport, */
                            XGL_CTX_CLIP_PLANES,	XGL_CLIP_XMIN | 
                         				XGL_CLIP_XMAX | 
                         				XGL_CLIP_YMIN | 
                         				XGL_CLIP_YMAX | 
                         				XGL_CLIP_ZMIN | 
                         				XGL_CLIP_ZMAX , 
                            NULL );
            }
         }
      }

   if( pipe->type == DL_PERSP_PIPE )
      {
      double	s[16], m[16];
      long	msg;
      short	four = 4;

      /*  Use the perspective view scale and build a scaling matrix  */
      /*  Multiply that to the transformation matrix and load into  */
      /*  xgl  */

      memset( s, 0, sizeof( double ) * 16 );

      s[0] = view->scalex;
      s[5] = view->scaley;
      s[10] = view->scalez;
      s[15] = 1.0;

      MAmulmx( &msg, &four, &four, &four, pipe->matrix, s, m );

      xgl_matrix[0][0] = m[0];
      xgl_matrix[0][1] = m[1];
      xgl_matrix[0][2] = m[2];
      xgl_matrix[0][3] = m[3];
      xgl_matrix[1][0] = m[4];
      xgl_matrix[1][1] = m[5];
      xgl_matrix[1][2] = m[6];
      xgl_matrix[1][3] = m[7];
      xgl_matrix[2][0] = m[8];
      xgl_matrix[2][1] = m[9];
      xgl_matrix[2][2] = m[10];
      xgl_matrix[2][3] = m[11];
      xgl_matrix[3][0] = m[12] + view->offsetx - xtrans;
      xgl_matrix[3][1] = m[13] + view->offsety - ytrans;
      xgl_matrix[3][2] = m[14] + view->offsetz;
      xgl_matrix[3][3] = m[15];

      xgl_transform_write_specific( pipe->view_trans, 
                                    xgl_matrix,
                                    XGL_TRANS_MEMBER_LIM_PERSPECTIVE );
      
      if ( pipe->base_context_info.flags & WL_SEPARATE_HILITE &&
           WLhilite_enabled )
         {
         xgl_transform_write_specific( pipe->hl_view_trans, 
                                       xgl_matrix,
                                       XGL_TRANS_MEMBER_LIM_PERSPECTIVE );
         }
      }
   else
      {
      xgl_matrix[0][0] = pipe->matrix[0];
      xgl_matrix[0][1] = pipe->matrix[1];
      xgl_matrix[0][2] = pipe->matrix[2];
      xgl_matrix[0][3] = pipe->matrix[3];
      xgl_matrix[1][0] = pipe->matrix[4];
      xgl_matrix[1][1] = pipe->matrix[5];
      xgl_matrix[1][2] = pipe->matrix[6];
      xgl_matrix[1][3] = pipe->matrix[7];
      xgl_matrix[2][0] = pipe->matrix[8];
      xgl_matrix[2][1] = pipe->matrix[9];
      xgl_matrix[2][2] = pipe->matrix[10];
      xgl_matrix[2][3] = pipe->matrix[11];
      xgl_matrix[3][0] = pipe->matrix[12] - xtrans;
      xgl_matrix[3][1] = pipe->matrix[13] - ytrans;
      xgl_matrix[3][2] = pipe->matrix[14];
      xgl_matrix[3][3] = pipe->matrix[15];


      xgl_transform_write_specific( pipe->view_trans, 
                                    xgl_matrix,
                                    XGL_TRANS_MEMBER_AFFINE );
      
      if ( pipe->base_context_info.flags & WL_SEPARATE_HILITE &&
           WLhilite_enabled )
         {
         xgl_transform_write_specific( pipe->hl_view_trans, 
                                       xgl_matrix,
                                       XGL_TRANS_MEMBER_AFFINE );
         }
      }

/*
if ( viewport_changed )
   {
   struct WLpoint	points[2];
   struct WLrect	rect;

   rect.x = view->xlo;
   rect.y = view->ylo;
   rect.width = view->xhi - view->xlo;
   rect.height = view->yhi - view->ylo;

   WLdraw_rectangle( pipe->lwin_no, &rect, FALSE );

   points[0].x = rect.x;
   points[0].y = rect.y;
   points[1].x = rect.x + rect.width;
   points[1].y = rect.y + rect.height;

   WLdraw_2D_line_string( pipe->lwin_no, 2, points );

   points[1].x = rect.x;
   points[0].y = rect.y;
   points[0].x = rect.x + rect.width;
   points[1].y = rect.y + rect.height;

   WLdraw_2D_line_string( pipe->lwin_no, 2, points );
   }
*/

   return( DL_SUCCESS );
   }  /* DLIsetup_XGL_window */
#endif

/*--- DLcharacterize_matrix -------------------------------------------------*/

int DLcharacterize_matrix(
   int pipe_id )

/*
NAME
	DLcharacterize_matrix

DESCRIPTION
	This function characterizes the transformation matrix of a drawing
	pipeline so that transformations are performed as efficiently as
	possible.

        Each column has a type representing where 0's exist in
        the matrix:

		| 0  1  2  3 |
		| 4  5  6  7 |
		| 8  9  10 11|
		|12 13  14 15|

	There are 16 possible combinations of 0's in a column.  For
        example, if a 0 is in slot 4 then column 1 type is 11 (bit map 1011).
	If there is a 0 in slot 1 and 13, column 2 type is 6 (bit map 0110).

SYNOPSIS
	int DLcharacterize_matrix(
	   int pipe_id )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;
   double *mat;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( pipe->clip_flag & DLI_CL_IDENTITY )
      return( DL_SUCCESS );

   mat = &pipe->matrix[0];

   switch ( pipe->type )
   {
      case DL_ORTHO_PIPE:      /* characterize 3D portion */

         pipe->matmap[0] = 0;
         pipe->matmap[1] = 0;
         pipe->matmap[2] = 0;
         if ( mat[0] != 0.0 )   /* type column 1 */
         {
            pipe->matmap[0] = 0x8;
         }
         if ( mat[4] != 0.0 )
         {
            pipe->matmap[0] |= 0x4;
         }
         if ( mat[8] != 0.0 )
         {
            pipe->matmap[0] |= 0x2;
         }
         if ( mat[12] != 0.0 )
         {
            pipe->matmap[0] |= 0x1;
         }

         if ( mat[1] != 0.0 )   /* type column 2 */
         {
            pipe->matmap[1] = 0x8;
         }
         if ( mat[5] != 0.0 )
         {
            pipe->matmap[1] |= 0x4;
         }
         if ( mat[9] != 0.0 )
         {
            pipe->matmap[1] |= 0x2;
         }
         if ( mat[13] != 0.0 )
         {
            pipe->matmap[1] |= 0x1;
         }

         if ( mat[2] != 0.0 )   /* type column 3 */
         {
            pipe->matmap[2] = 0x8;
         }
         if ( mat[6] != 0.0 )
         {
            pipe->matmap[2] |= 0x4;
         }
         if ( mat[10] != 0.0 )
         {
            pipe->matmap[2] |= 0x2;
         }
         if ( mat[14] != 0.0 )
         {
            pipe->matmap[2] |= 0x1;
         }
         break;

      case DL_PERSP_PIPE:      /* characterize 3D portion */

         pipe->matmap[0] = 0;
         pipe->matmap[1] = 0;
         pipe->matmap[2] = 0;
         pipe->matmap[3] = 0;
         if ( mat[0] != 0.0 )   /* type column 1 */
         {
            pipe->matmap[0] = 0x8;
         }
         if ( mat[4] != 0.0 )
         {
            pipe->matmap[0] |= 0x4;
         }
         if ( mat[8] != 0.0 )
         {
            pipe->matmap[0] |= 0x2;
         }
         if ( mat[12] != 0.0 )
         {
            pipe->matmap[0] |= 0x1;
         }

         if ( mat[1] != 0.0 )   /* type column 2 */
         {
            pipe->matmap[1] = 0x8;
         }
         if ( mat[5] != 0.0 )
         {
            pipe->matmap[1] |= 0x4;
         }
         if ( mat[9] != 0.0 )
         {
            pipe->matmap[1] |= 0x2;
         }
         if ( mat[13] != 0.0 )
         {
            pipe->matmap[1] |= 0x1;
         }

         if ( mat[2] != 0.0 )   /* type column 3 */
         {
            pipe->matmap[2] = 0x8;
         }
         if ( mat[6] != 0.0 )
         {
            pipe->matmap[2] |= 0x4;
         }
         if ( mat[10] != 0.0 )
         {
            pipe->matmap[2] |= 0x2;
         }
         if ( mat[14] != 0.0 )
         {
            pipe->matmap[2] |= 0x1;
         }

         if ( mat[3] != 0.0 )   /* type column 4 */
         {
            pipe->matmap[3] = 0x8;
         }
         if ( mat[7] != 0.0 )
         {
            pipe->matmap[3] |= 0x4;
         }
         if ( mat[11] != 0.0 )
         {
            pipe->matmap[3] |= 0x2;
         }
         if ( mat[15] != 0.0 )
         {
            pipe->matmap[3] |= 0x1;
         }
         break;

   }

#if defined( ENV5 )
   if ( pipe->using_gpipe )
   {
      sts = GPCharMatrix( pipe->gpipe_id );
      sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;
   }
#endif

   return( sts );

}  /* DLcharacterize_matrix */

/*--- DLImat_mult ------------------------------------------------*/

int DLImat_mult(
   struct DLpipeline *pipe,
   double *matrix,
   int mult_type )

/*
NAME
	DLImat_mult

DESCRIPTION
	This function multiplies a matrix by the current
	transformation matrix of a pipeline

SYNOPSIS
	int DLImat_mult(
	   struct DLpipeline *pipe,
	   double *matrix,
	   int mult_type )

PARAMETERS
	pipe (IN) - the pipeline whose matrix is to be multiplied
	matrix (IN) - the matrix to multiply in
	mult_type (IN) - the type of multiplication

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_MULT_TYPE
		If the multiplication type is invalid

HISTORY
	11/19/92    S.P. Rogers
	   Extracted from DLmatrix_multiply to solve OpenGL
	   problems
*/

{
   double *oldmat;
   double temp[16];

   pipe->matmap[0] = 0xf;       /* Clear out matrix characterization */
   pipe->matmap[1] = 0xf;
   pipe->matmap[2] = 0xf;
   pipe->matmap[3] = 0xf;

   oldmat = &pipe->viewing_matrix[0];

   switch ( mult_type )
   {
      case DL_PRE_MULTIPLY:

         /* Multiply the matrix by the current matrix in the pipeline */
         /* matrix stack.                                             */
         switch ( pipe->type )
         {
            case DL_ORTHO_PIPE:
               temp[0] = matrix[0] * oldmat[0] + matrix[1] * oldmat[4] +
                  matrix[2] * oldmat[8];
               temp[1] = matrix[0] * oldmat[1] + matrix[1] * oldmat[5] +
                  matrix[2] * oldmat[9];
               temp[2] = matrix[0] * oldmat[2] + matrix[1] * oldmat[6] +
                  matrix[2] * oldmat[10];

               temp[4] = matrix[4] * oldmat[0] + matrix[5] * oldmat[4] +
                  matrix[6] * oldmat[8];
               temp[5] = matrix[4] * oldmat[1] + matrix[5] * oldmat[5] +
                  matrix[6] * oldmat[9];
               temp[6] = matrix[4] * oldmat[2] + matrix[5] * oldmat[6] +
                  matrix[6] * oldmat[10];

               temp[8] = matrix[8] * oldmat[0] + matrix[9] * oldmat[4] +
                  matrix[10] * oldmat[8];
               temp[9] = matrix[8] * oldmat[1] + matrix[9] * oldmat[5] +
                  matrix[10] * oldmat[9];
               temp[10] = matrix[8] * oldmat[2] + matrix[9] * oldmat[6] +
                  matrix[10] * oldmat[10];

               temp[12] = matrix[12] * oldmat[0] + matrix[13] * oldmat[4] +
                  matrix[14] * oldmat[8] + oldmat[12];
               temp[13] = matrix[12] * oldmat[1] + matrix[13] * oldmat[5] +
                  matrix[14] * oldmat[9] + oldmat[13];
               temp[14] = matrix[12] * oldmat[2] + matrix[13] * oldmat[6] +
                  matrix[14] * oldmat[10] + oldmat[14];

               oldmat[0] = temp[0];
               oldmat[1] = temp[1];
               oldmat[2] = temp[2];
               oldmat[4] = temp[4];
               oldmat[5] = temp[5];
               oldmat[6] = temp[6];
               oldmat[8] = temp[8];
               oldmat[9] = temp[9];
               oldmat[10] = temp[10];
               oldmat[12] = temp[12];
               oldmat[13] = temp[13];
               oldmat[14] = temp[14];
               oldmat[15] = 1.0;
               break;

            case DL_PERSP_PIPE:
               temp[0] = matrix[0] * oldmat[0] + matrix[1] * oldmat[4] +
                  matrix[2] * oldmat[8] + matrix[3] * oldmat[12];
               temp[1] = matrix[0] * oldmat[1] + matrix[1] * oldmat[5] +
                  matrix[2] * oldmat[9] + matrix[3] * oldmat[13];
               temp[2] = matrix[0] * oldmat[2] + matrix[1] * oldmat[6] +
                  matrix[2] * oldmat[10] + matrix[3] * oldmat[14];
               temp[3] = matrix[0] * oldmat[3] + matrix[1] * oldmat[7] +
                  matrix[2] * oldmat[11] + matrix[3] * oldmat[15];

               temp[4] = matrix[4] * oldmat[0] + matrix[5] * oldmat[4] +
                  matrix[6] * oldmat[8] + matrix[7] * oldmat[12];
               temp[5] = matrix[4] * oldmat[1] + matrix[5] * oldmat[5] +
                  matrix[6] * oldmat[9] + matrix[7] * oldmat[13];
               temp[6] = matrix[4] * oldmat[2] + matrix[5] * oldmat[6] +
                  matrix[6] * oldmat[10] + matrix[7] * oldmat[14];
               temp[7] = matrix[4] * oldmat[3] + matrix[5] * oldmat[7] +
                  matrix[6] * oldmat[11] + matrix[7] * oldmat[15];

               temp[8] = matrix[8] * oldmat[0] + matrix[9] * oldmat[4] +
                  matrix[10] * oldmat[8] + matrix[11] * oldmat[12];
               temp[9] = matrix[8] * oldmat[1] + matrix[9] * oldmat[5] +
                  matrix[10] * oldmat[9] + matrix[11] * oldmat[13];
               temp[10] = matrix[8] * oldmat[2] + matrix[9] * oldmat[6] +
                  matrix[10] * oldmat[10] + matrix[11] * oldmat[14];
               temp[11] = matrix[8] * oldmat[3] + matrix[9] * oldmat[7] +
                  matrix[10] * oldmat[11] + matrix[11] * oldmat[15];

               temp[12] = matrix[12] * oldmat[0] + matrix[13] * oldmat[4] +
                  matrix[14] * oldmat[8] + matrix[15] * oldmat[12];
               temp[13] = matrix[12] * oldmat[1] + matrix[13] * oldmat[5] +
                  matrix[14] * oldmat[9] + matrix[15] * oldmat[13];
               temp[14] = matrix[12] * oldmat[2] + matrix[13] * oldmat[6] +
                  matrix[14] * oldmat[10] + matrix[15] * oldmat[14];
               temp[15] = matrix[12] * oldmat[3] + matrix[13] * oldmat[7] +
                  matrix[14] * oldmat[11] + matrix[15] * oldmat[15];

               memcpy( oldmat, temp, 16 * sizeof( double ) );
               break;
         }
         pipe->clip_flag &= ~DLI_CL_IDENTITY;
         break;

      case DL_POST_MULTIPLY:

         /* Multiply the matrix by the current matrix in the pipeline */
         /* matrix stack.                                             */
         switch ( pipe->type )
         {
            case DL_ORTHO_PIPE:
               temp[0] = oldmat[0] * matrix[0] + oldmat[1] * matrix[4] +
                  oldmat[2] * matrix[8];
               temp[1] = oldmat[0] * matrix[1] + oldmat[1] * matrix[5] +
                  oldmat[2] * matrix[9];
               temp[2] = oldmat[0] * matrix[2] + oldmat[1] * matrix[6] +
                  oldmat[2] * matrix[10];

               temp[4] = oldmat[4] * matrix[0] + oldmat[5] * matrix[4] +
                  oldmat[6] * matrix[8];
               temp[5] = oldmat[4] * matrix[1] + oldmat[5] * matrix[5] +
                  oldmat[6] * matrix[9];
               temp[6] = oldmat[4] * matrix[2] + oldmat[5] * matrix[6] +
                  oldmat[6] * matrix[10];

               temp[8] = oldmat[8] * matrix[0] + oldmat[9] * matrix[4] +
                  oldmat[10] * matrix[8];
               temp[9] = oldmat[8] * matrix[1] + oldmat[9] * matrix[5] +
                  oldmat[10] * matrix[9];
               temp[10] = oldmat[8] * matrix[2] + oldmat[9] * matrix[6] +
                  oldmat[10] * matrix[10];

               temp[12] = oldmat[12] * matrix[0] + oldmat[13] * matrix[4] +
                  oldmat[14] * matrix[8] + matrix[12];
               temp[13] = oldmat[12] * matrix[1] + oldmat[13] * matrix[5] +
                  oldmat[14] * matrix[9] + matrix[13];
               temp[14] = oldmat[12] * matrix[2] + oldmat[13] * matrix[6] +
                  oldmat[14] * matrix[10] + matrix[14];

               oldmat[0] = temp[0];
               oldmat[1] = temp[1];
               oldmat[2] = temp[2];
               oldmat[4] = temp[4];
               oldmat[5] = temp[5];
               oldmat[6] = temp[6];
               oldmat[8] = temp[8];
               oldmat[9] = temp[9];
               oldmat[10] = temp[10];
               oldmat[12] = temp[12];
               oldmat[13] = temp[13];
               oldmat[14] = temp[14];
               oldmat[15] = 1.0;
               break;

            case DL_PERSP_PIPE:
               temp[0] = oldmat[0] * matrix[0] + oldmat[1] * matrix[4] +
                  oldmat[2] * matrix[8] + oldmat[3] * matrix[12];
               temp[1] = oldmat[0] * matrix[1] + oldmat[1] * matrix[5] +
                  oldmat[2] * matrix[9] + oldmat[3] * matrix[13];
               temp[2] = oldmat[0] * matrix[2] + oldmat[1] * matrix[6] +
                  oldmat[2] * matrix[10] + oldmat[3] * matrix[14];
               temp[3] = oldmat[0] * matrix[3] + oldmat[1] * matrix[7] +
                  oldmat[2] * matrix[11] + oldmat[3] * matrix[15];

               temp[4] = oldmat[4] * matrix[0] + oldmat[5] * matrix[4] +
                  oldmat[6] * matrix[8] + oldmat[7] * matrix[12];
               temp[5] = oldmat[4] * matrix[1] + oldmat[5] * matrix[5] +
                  oldmat[6] * matrix[9] + oldmat[7] * matrix[13];
               temp[6] = oldmat[4] * matrix[2] + oldmat[5] * matrix[6] +
                  oldmat[6] * matrix[10] + oldmat[7] * matrix[14];
               temp[7] = oldmat[4] * matrix[3] + oldmat[5] * matrix[7] +
                  oldmat[6] * matrix[11] + oldmat[7] * matrix[15];

               temp[8] = oldmat[8] * matrix[0] + oldmat[9] * matrix[4] +
                  oldmat[10] * matrix[8] + oldmat[11] * matrix[12];
               temp[9] = oldmat[8] * matrix[1] + oldmat[9] * matrix[5] +
                  oldmat[10] * matrix[9] + oldmat[11] * matrix[13];
               temp[10] = oldmat[8] * matrix[2] + oldmat[9] * matrix[6] +
                  oldmat[10] * matrix[10] + oldmat[11] * matrix[14];
               temp[11] = oldmat[8] * matrix[3] + oldmat[9] * matrix[7] +
                  oldmat[10] * matrix[11] + oldmat[11] * matrix[15];

               temp[12] = oldmat[12] * matrix[0] + oldmat[13] * matrix[4] +
                  oldmat[14] * matrix[8] + oldmat[15] * matrix[12];
               temp[13] = oldmat[12] * matrix[1] + oldmat[13] * matrix[5] +
                  oldmat[14] * matrix[9] + oldmat[15] * matrix[13];
               temp[14] = oldmat[12] * matrix[2] + oldmat[13] * matrix[6] +
                  oldmat[14] * matrix[10] + oldmat[15] * matrix[14];
               temp[15] = oldmat[12] * matrix[3] + oldmat[13] * matrix[7] +
                  oldmat[14] * matrix[11] + oldmat[15] * matrix[15];

               memcpy( oldmat, temp, 16 * sizeof( double ) );
               break;
         }
         pipe->clip_flag &= ~DLI_CL_IDENTITY;
         break;

      default:
         DL_REPORT_ERROR( DL_BAD_MULT_TYPE );
         return( DL_BAD_MULT_TYPE );

   }  /* end: switch ( mult_type ) */

   return( DL_SUCCESS );

}  /* DLImat_mult */


/*--- DLmatrix_multiply --------------------------------------------------*/

int DLmatrix_multiply(
   int pipe_id,
   double *matrix,
   int mult_type )

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( ! matrix )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   sts = DLImat_mult( pipe, matrix, mult_type );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   sts = DLIsetup_DL_window( pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

#if defined( OPENGL )
   if ( pipe->using_opengl )
   {
      sts = DLIsetup_OPENGL_window( pipe, FALSE );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }
   }
#endif

#if defined( XGL )
   if ( pipe->using_xgl )
   {
      sts = DLIsetup_XGL_window( pipe, FALSE );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }
   }
#endif

#if defined( ENV5 )
   if ( pipe->using_gpipe )
   {
      if ( mult_type == DL_PRE_MULTIPLY )
      {
         sts = GPMultMatrix( pipe->gpipe_id, matrix, GP_PREMULT );
      }
      else
      {
         sts = GPMultMatrix( pipe->gpipe_id, matrix, GP_POSTMULT );
      }

      sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;
   }

   if ( pipe->using_eg )
   {

      sts = DLIsetup_EG_window( pipe );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }
   }

#endif

   return( sts );

}  /* DLmatrix_multiply */


/*--- DLget_matrix ----------------------------------------------------------*/

int DLget_matrix(
   int pipe_id,
   double *matrix )

/*
NAME
	DLget_matrix

DESCRIPTION
	This function gets the current transformation matrix for a drawing
	pipeline.

SYNOPSIS
	int DLget_matrix(
	   int pipe_id,
	   double *matrix )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	matrix (OUT) - the transformation matrix

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The matrix parameter is NULL.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( ! matrix )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   memcpy( matrix, pipe->viewing_matrix, 16 * sizeof( double ) );
   return( DL_SUCCESS );

} /* DLget_matrix */

/*--- DLset_matrix ----------------------------------------------------------*/

int DLset_matrix(
   int pipe_id,
   double *matrix,
   double *eye_in,
   double *vpn_in,
   double *vup_in )

/*
NAME
	DLset_matrix

DESCRIPTION
	This function sets the current transformation matrix for a drawing
	pipeline.

        For 3D orthogonal mode, the matrix is in 4 x 3 format
        where the fourth column is always 0 0 0 1.

                |  r1  r2  r3 0 |
                |  r4  r5  r6 0 |
                |  r7  r8  r9 0 |
                |  tx  ty  tz 1 |

        For 3D perspective mode, the matrix is in 4 x 4 format.

                |  a1  a2  a3  a4  |
                |  a5  a6  a7  a8  |
                |  a9  a10 a11 a12 |
                |  a13 a14 a15 a16 |

SYNOPSIS
	int DLset_matrix(
	   int pipe_id,
	   double *matrix,
           double *eye_in,
           double *vpn_in,
           double *vup_in )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	matrix (IN) - the transformation matrix
        eye_in (IN) - the perspective eye point, only needed 
                      in perspective
        vpn_in (IN) - the perspective view plane normal, only
                      needed in perspective
        vup_in (IN) - the perspective view up vector, only needed
                      in perspective

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The matrix parameter is NULL.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( (! matrix) ||
        ( (pipe->type == DL_PERSP_PIPE) &&
          ((! eye_in) || (! vpn_in) || (! vup_in) ) ) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

#if defined (DLTEST)
DLTlog_matrix( pipe_id, matrix, eye_in, vpn_in, vup_in );
#endif

#if defined( OPENGL )
   /* Performance benefits are mainly noted on the SGI, and not elsewhere */
   /* and hence the ifdef                                                 */
    
   if ( pipe->type != DL_PERSP_PIPE )
   {
      if ( ! memcmp( matrix, pipe->viewing_matrix, 16 * sizeof( double ) ) )
      {
         return( DL_SUCCESS );
      }
   }
#endif
   
   memcpy( pipe->viewing_matrix, matrix, 16 * sizeof( double ) );
   DLIsetup_DL_window( pipe );

   if ( pipe->type == DL_PERSP_PIPE )
   {
      pipe->eye[0] = eye_in[0];
      pipe->eye[1] = eye_in[1];
      pipe->eye[2] = eye_in[2];

      pipe->vpn[0] = vpn_in[0];
      pipe->vpn[1] = vpn_in[1];
      pipe->vpn[2] = vpn_in[2];

      pipe->vup[0] = vup_in[0];
      pipe->vup[1] = vup_in[1];
      pipe->vup[2] = vup_in[2];
   }

   /* Reset the matrix map so no optimization is performed */
   /* This will be fixed at the next call to               */
   /* DLcharacterize_matrix()                              */
   pipe->matmap[0] = 0xF;
   pipe->matmap[1] = 0xF;
   pipe->matmap[2] = 0xF;
   pipe->matmap[3] = 0xF;
   pipe->clip_flag &= ~DLI_CL_IDENTITY;

#if defined( XGL )
   if ( pipe->using_xgl )
   {
      sts = DLIsetup_XGL_window( pipe, FALSE );
   }
#endif

#if defined( OPENGL )
   if ( pipe->using_opengl )
   {
      sts = DLIsetup_OPENGL_window( pipe, FALSE );
   }
#endif

#if defined( ENV5 )
   if ( pipe->using_eg )
   {
      sts = DLIsetup_EG_window( pipe );
   }

   if ( pipe->using_gpipe )
   {
      sts = GPPutMatrix( pipe->gpipe_id, pipe->viewing_matrix );
      if ( sts != 0 )
      {
         DL_REPORT_ERROR( DL_ERROR );
         return( DL_ERROR );
      }

      if ( !(pipe->clip_flag & DLI_CL_MOD_IDENTITY) )
      {
         sts = GPMultMatrix( pipe->gpipe_id, pipe->modelling_matrix, GP_PREMULT );
         sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;
      }
   }
#endif

   return( sts );

}  /* DLset_matrix */

/*--- DLset_modelling_matrix ----------------------------------------------------------*/

int DLset_modelling_matrix(
   int pipe_id,
   double *mod_matrix )

/*
NAME
	DLset_modelling_matrix

DESCRIPTION
	This function sets the current modelling matrix for a drawing
	pipeline.  This matrix is applied to geometry before the viewing
        matrix set by DLset_matrix.

        For 3D orthogonal mode, the matrix is in 4 x 3 format
        where the fourth column is always 0 0 0 1.

                |  r1  r2  r3 0 |
                |  r4  r5  r6 0 |
                |  r7  r8  r9 0 |
                |  tx  ty  tz 1 |

SYNOPSIS
	int DLset_modelling_matrix(
	   int pipe_id,
	   double *mod_matrix )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	mod_matrix (IN) - the modelling matrix

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The mod_matrix parameter is NULL.

RELATED INFORMATION

HISTORY
	09/17/93    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   short is_identity;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( ! mod_matrix )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   if ( ! memcmp( pipe->modelling_matrix, mod_matrix, 16 * sizeof( double ) ) )
   {
      /* no change in matrix */
      return( DL_SUCCESS );
   }

   is_identity = ! memcmp( DLIidentity_d, mod_matrix, 16 * sizeof( double ) );
   memcpy( pipe->modelling_matrix, mod_matrix, 16 * sizeof( double ) );
   if ( is_identity )
   {
      pipe->clip_flag |= DLI_CL_MOD_IDENTITY;
   }
   else
   {
      pipe->clip_flag &= ~DLI_CL_MOD_IDENTITY;
   }

   sts = DLIsetup_DL_window( pipe );
   sts = DLcharacterize_matrix( pipe_id );

#if defined( OPENGL )
   if ( pipe->using_opengl )
   {
      sts = DLIsetup_OPENGL_window( pipe, FALSE );
   }
#endif

#if defined( XGL )
   if( pipe->using_xgl )
   {
      DLIsetup_XGL_window( pipe, FALSE );
   }
#endif
 
#if defined( ENV5 )
   if ( pipe->using_eg )
   {
      sts = DLIsetup_EG_window( pipe );
   }

   if ( pipe->using_gpipe )
   {
      sts = GPPutMatrix( pipe->gpipe_id, pipe->viewing_matrix );
      if ( sts != 0 )
      {
         DL_REPORT_ERROR( DL_ERROR );
         return( DL_ERROR );
      }

      if ( !(pipe->clip_flag & DLI_CL_MOD_IDENTITY) )
      {
         sts = GPMultMatrix( pipe->gpipe_id, pipe->modelling_matrix, GP_PREMULT );
         sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;
      }
   }
#endif

   return( sts );

}  /* DLset_modelling_matrix */

/*--- DLreset_modelling_matrix ----------------------------------------------------------*/

int DLreset_modelling_matrix(
   int pipe_id )

/*
NAME
	DLreset_modelling_matrix

DESCRIPTION
	This function resets the current modelling matrix for a drawing
	pipeline to an identity.  This matrix is applied to geometry before
        the viewing matrix set by DLset_matrix.

SYNOPSIS
	int DLreset_modelling_matrix(
	   int pipe_id )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.

RELATED INFORMATION

HISTORY
	09/17/93    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( pipe->clip_flag & DLI_CL_MOD_IDENTITY )
   {
      /* modelling matrix is already an identity */
      return( DL_SUCCESS );
   }
   
   memcpy( pipe->modelling_matrix, DLIidentity_d, 16 * sizeof( double ) );

   pipe->clip_flag |= DLI_CL_MOD_IDENTITY;

   sts = DLIsetup_DL_window( pipe );
   sts = DLcharacterize_matrix( pipe_id );

#if defined( OPENGL )
   if ( pipe->using_opengl )
   {
      sts = DLIsetup_OPENGL_window( pipe, FALSE );
   }
#endif

#if defined( XGL )
   if ( pipe->using_xgl )
   {
      sts = DLIsetup_XGL_window( pipe, FALSE );
      if ( sts != DL_SUCCESS )
      {
         DL_REPORT_ERROR( sts );
         return( sts );
      }
   }
#endif

#if defined( ENV5 )
   if ( pipe->using_eg )
   {
      sts = DLIsetup_EG_window( pipe );
   }

   if ( pipe->using_gpipe )
   {
      sts = GPPutMatrix( pipe->gpipe_id, pipe->viewing_matrix );
      sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;
   }
#endif

   return( sts );

}  /* DLreset_modelling_matrix */

/*--- DLget_modelling_matrix ----------------------------------------------------------*/

int DLget_modelling_matrix(
   int pipe_id,
   double *mod_matrix )

/*
NAME
	DLget_modelling_matrix

DESCRIPTION
	This function gets the current modelling matrix for a drawing
	pipeline.  This matrix is applied to geometry before the viewing
        matrix set by DLset_matrix.

        For 3D orthogonal mode, the matrix is in 4 x 3 format
        where the fourth column is always 0 0 0 1.

                |  r1  r2  r3 0 |
                |  r4  r5  r6 0 |
                |  r7  r8  r9 0 |
                |  tx  ty  tz 1 |

SYNOPSIS
	int DLget_modelling_matrix(
	   int pipe_id,
	   double *mod_matrix )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	mod_matrix (OUT) - the modelling matrix

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_BAD_PARAMETER
		The mod_matrix parameter is NULL.

RELATED INFORMATION

HISTORY
	09/17/93    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( ! mod_matrix )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   memcpy( mod_matrix, pipe->modelling_matrix, 16 * sizeof( double ) );

   return( DL_SUCCESS );

}  /* DLget_modelling_matrix */

