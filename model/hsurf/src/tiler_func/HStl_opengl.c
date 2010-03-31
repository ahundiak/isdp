
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $
*/

#if defined( OPENGL )

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "wl.h"
#include "dl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"

#include "bs.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsmath.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/* prototypes */
#include "bscrossp.h"
#include "bsdotp.h"

/*---- HSsetup_OPENGL_lights -------------------------------------------------*/

void HSsetup_OPENGL_lights(
   struct HS_light_source global_lights[MAX_LIGHTS],
   struct HS_light_source *ambient_light )

/*
NAME
        HSsetup_OPENGL_lights

DESCRIPTION
        This function sets the necessary OPENGL light structures.

PARAMETERS
        global_lights (IN) - the lights to be set up
        ambient_light (IN) - the ambient light to set up, if NULL then no
                ambient light.

GLOBALS USED
        active_window

NOTES
        This function assumes that the active_window pointer is
        pointing to the window whose lights are to be set up.

HISTORY
        04/23/93   S.P. Rogers
           Created from HSsetup_EG_lights.
*/

{
   IGRint ii, num_lights;
   struct HS_light_source aligned_lights[MAX_LIGHTS];
   GLfloat lightPosition[4];
   GLfloat lightColor[4];
   
   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
   
   /* Get the window lights into world coordinates */
   HSalign_view_lights_to_world( global_lights, aligned_lights );

   num_lights = 0;
   for ( ii = 0; ii < MAX_LIGHTS; ii++ )
   {
      if ( aligned_lights[ii].flags & HS_LIGHT_ENABLED )
      {
         num_lights++;
         switch ( aligned_lights[ii].flags & HS_LIGHT_TYPE )
         {
            case HS_LIGHT_SPOT:
               /* ??? how to use light source radius ??? */
               lightPosition[0] = aligned_lights[ii].location[0];
               lightPosition[1] = aligned_lights[ii].location[1];
               lightPosition[2] = aligned_lights[ii].location[2];
               lightPosition[3] = 1.0;
               glLightfv( GL_LIGHT0 + ii, GL_POSITION, lightPosition );

               lightPosition[0] = aligned_lights[ii].direction[0];
               lightPosition[1] = aligned_lights[ii].direction[1];
               lightPosition[2] = aligned_lights[ii].direction[2];
               glLightfv( GL_LIGHT0 + ii, GL_SPOT_DIRECTION, lightPosition );

               glLightf( GL_LIGHT0 + ii, GL_SPOT_EXPONENT, 1.0 );
               glLightf( GL_LIGHT0 + ii, GL_SPOT_CUTOFF,
                ( GLfloat ) ( 180.0 * aligned_lights[ii].angle / 3.14159 ) );
               break;

            case HS_LIGHT_POINT:
               /* setting the w coponent to 1.0 makes this a point light. */
               /* ??? how to use light source radius ??? */
               lightPosition[0] = aligned_lights[ii].location[0];
               lightPosition[1] = aligned_lights[ii].location[1];
               lightPosition[2] = aligned_lights[ii].location[2];
               lightPosition[3] = 1.0;
               glLightfv( GL_LIGHT0 + ii, GL_POSITION, lightPosition );
               break;

            case HS_LIGHT_PARALLEL:
            case HS_LIGHT_PENCIL:
               /* setting the w coponent to 0.0 makes this a directional light */
               lightPosition[0] = -aligned_lights[ii].direction[0];
               lightPosition[1] = -aligned_lights[ii].direction[1];
               lightPosition[2] = -aligned_lights[ii].direction[2];
               lightPosition[3] = 0.0;

               glLightfv( GL_LIGHT0 + ii, GL_POSITION, lightPosition );
               break;

         } /* end: switch */


         lightColor[0] = aligned_lights[ii].red / 255.0;
         lightColor[1] = aligned_lights[ii].green / 255.0;
         lightColor[2] = aligned_lights[ii].blue / 255.0;
         lightColor[3] = 1.0;

         glLightfv( GL_LIGHT0 + ii, GL_DIFFUSE, lightColor );
         glLightfv( GL_LIGHT0 + ii, GL_SPECULAR, lightColor );

         glEnable( GL_LIGHT0 + ii );

      } /* light is active */
      else
      {
         glDisable( GL_LIGHT0 + ii );
      }
   }    /* end: for */

   if ( ambient_light )
   {
      lightColor[0] = ambient_light->red / 255.0;
      lightColor[1] = ambient_light->green / 255.0;
      lightColor[2] = ambient_light->blue / 255.0;
      lightColor[3] = 1.0;

      glLightModelfv( GL_LIGHT_MODEL_AMBIENT, lightColor );
      num_lights++;
   }

   if ( num_lights )
   {
      glEnable( GL_LIGHTING );
   }

} /* HSsetup_OPENGL_lights */

/*--- HSsetup_OPENGL_window --------------------------------------------*/

void HSsetup_OPENGL_window(
   IGRdouble transformation_matrix[4][4],
   IGRdouble *vw_vol,
   IGRdouble eye_pt[3],
   IGRdouble vrp[3],
   IGRdouble vpn[3],
   IGRdouble vup[3],
   IGRint x_dits,
   IGRint y_dits,
   IGRboolean init_zbuffer )

/*
NAME
   HSsetup_OPENGL_window

DESCRIPTION
   This function sets up a window for shading via OPENGL

SYNOPSIS
   void HSsetup_OPENGL_window(
      IGRdouble transformation_matrix[4][4],
      IGRdouble *vw_vol,
      IGRdouble eye_pt[3],
      IGRdouble vrp[3],
      IGRdouble vpn[3],
      IGRdouble vup[3],
      IGRint x_dits,
      IGRint y_dits,
      IGRboolean init_zbuffer )

PARAMETERS
   transformation_matrix (IN) - the transformation matrix for the window
                                (NOT USED)
   vw_vol (IN) - the view volume of the window (NOT USED)
   eye_pt (IN) - the eye point in perspective (NOT USED)
   vrp (IN) - the view reference point in perspective (NOT USED)
   vpn (IN) - the view plane normal in perspective (NOT USED)
   vup (IN) - the view up vector in perspective (NOT USED)
   x_dits (IN) - the width in dits of the window
   y_dits (IN) - the height in dits of the window
   init_zbuffer (IN) - if TRUE, initialize the Zbuffer

GLOBALS USED
   none

NOTES
   This function assumes the window that is to be setup has
   already been activated via HSactivate_window(), which sets
   up the correct OpenGL rendering context.

HISTORY
   08/16/93 S.P. Rogers
      Added header
*/

{
   GLfloat fog_color[4] = { 0.0, 0.0, 0.0, 0.0 };

   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
   
   /* Do not need to setup matrices because DL has already done it for us */

   /* Enable Z buffering, etc. */
   DLset_flag( DL_FLAG_ZBUFFER );
   glEnable( GL_DEPTH_TEST );
   glDepthFunc( GL_LEQUAL );

   glLightModeli( GL_LIGHT_MODEL_LOCAL_VIEWER, GL_TRUE );
   glLightModeli( GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE );

   /* we need this because there is scale in our modelview matrix  */
   /* if we remove the scale, we won't need this and we should run */
   /* a little bit faster                                          */
   glEnable( GL_NORMALIZE );

   if ( init_zbuffer )
   {
      glClearDepth( 1.0 );
      glClear( GL_DEPTH_BUFFER_BIT );
   }

   /* enable/disable some other things */
   glEnable( GL_DITHER );
   glDisable( GL_CULL_FACE );

   /* set up fog the way we want for depth cueing */
   glDisable( GL_FOG );
   glFogi( GL_FOG_MODE, GL_LINEAR );
   glFogf( GL_FOG_START, 0.0 );
   glFogf( GL_FOG_END, 1.0 );
   glFogfv( GL_FOG_COLOR, fog_color );
   
} /* HSsetup_OPENGL_window */

/*--- HSdelete_OPENGL_shading_window ------------------------------------------------*/

void HSdelete_OPENGL_shading_window(
   void )

/*
NAME
   HSdelete_OPENGL_shading_window

DESCRIPTION
   This function deletes an OPENGL shading window.  That is,
   it sets it up for wireframe display.

SYNOPSIS
   void HSdelete_OPENGL_shading_window(
      void )

PARAMETERS
   none

GLOBALS USED
   active_window

HISTORY
   04/27/93    S.P. Rogers
      Creation Date
*/

{

   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );

   /* turn off Zbuffering */
   DLclear_flag( DL_FLAG_ZBUFFER );
   glDisable( GL_DEPTH_TEST );

   glDisable( GL_DITHER );
   glDisable( GL_FOG );
   glDisable( GL_LIGHTING );

}  /* HSdelete_OPENGL_shading_window */

/*--- HSsend_trimesh_to_OPENGL ------------------------------------------------------*/

int HSsend_trimesh_to_OPENGL(
   int dummy,
   struct HStri_mesh *tri_mesh )

/*
NAME
   HSsend_mesh_to_OPENGL

DESCRIPTION
   This function sends a triangular mesh to OPENGL to be shaded.

PARAMETERS
   dummy (IN) - used only on EG version of this function
   tri_mesh (static) - the triangular mesh structure to send to GL.

GLOBALS USED
   none

RETURN VALUES
   TRUE, always

HISTORY
    04/26/93    S.P. Rogers
        Creation Date
*/

{
   int ii, numVerts, num_tris;
   double v1[3], v2[3], calc_facet_normal[3];
   long rc;
   float *fnorms, *verts, *vnorms;
   int ind;
   int send_last_separately = FALSE;
   int found = FALSE;
   double dotp;
   int fnorm_index;
   int odd_triangle;

   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
   
   numVerts = tri_mesh->numVerts;
   verts = (float *) tri_mesh->verts;
   fnorms = (float *)tri_mesh->fNorms;

   /* calculate a normal to the triangluar mesh in */
   /* the same way that OpenGL will                */
   for ( ii = 0; (ii < 2) && (!found); ii++ )
   {
      if ( ii == 0 )
      {
         /* checking odd triangles */
         odd_triangle = TRUE;
         ind = -6;
         if ( tri_mesh->numFacetNormals > 1 )
         {
            fnorm_index = -2;
         }
         else
         {
            fnorm_index = 0;
         }
      }
      else
      {
         /* checking even triangles */
         odd_triangle = FALSE;
         ind = -3;
         if ( tri_mesh->numFacetNormals > 1 )
         {
            fnorm_index = -1;
         }
         else
         {
            fnorm_index = 0;
         }
      }

      /* find a non-degenerate triangle */
      do
      {
         ind += 6;

         if ( ind >= ((numVerts-2) * 3) )
         {
            break;
         }
         
         if ( tri_mesh->numFacetNormals > 1 )
         {
            fnorm_index += 2;
         }

         v1[0] = (double) (verts[ind] - verts[ind+3]);
         v1[1] = (double) (verts[ind+1] - verts[ind+4]);
         v1[2] = (double) (verts[ind+2] - verts[ind+5]);
         BSnorvec( &rc, v1 );
         if ( rc != BSSUCC )
         {
            /* zero length vector */
            continue;
         }

         v2[0] = (double) (verts[ind+6] - verts[ind+3]);
         v2[1] = (double) (verts[ind+7] - verts[ind+4]);
         v2[2] = (double) (verts[ind+8] - verts[ind+5]);
         BSnorvec( &rc, v2 );
         if ( rc != BSSUCC )
         {
            /* zero length vector */
            continue;
         }

         dotp = BSdotp( &rc, v1, v2 );
         if ( fabs( dotp ) < (1.0 - 0.0000001) )
         {
            /* vectors aren't parallel */
            BScrossp( &rc, v1, v2, calc_facet_normal );
            found = TRUE;
         }
      }
      while ( ! found );
   }

   if ( ! found )
   {
      /* could not find a suitable triangle */
      return( 0 );
   }

   BSnorvec( &rc, calc_facet_normal );

   v2[0] = fnorms[fnorm_index*3];
   v2[1] = fnorms[fnorm_index*3 + 1];
   v2[2] = fnorms[fnorm_index*3 + 2];

   dotp = BSdotp( &rc, calc_facet_normal, v2 );
   if ( ! odd_triangle )
   {
      dotp *= -1.0;
   }

   if ( dotp > 0.0 )
   {
      /* need to reverse the direction of the triangular mesh   */
      /* beause the "calculated" mesh normal is not in the same */
      /* direction as the facet normal calculated by HSURF      */

      if ( !(numVerts % 2) )
      {
         /* even number of vertices => must send last triangle */
         /* in the mesh separately                             */
         numVerts--;
         send_last_separately = TRUE;
      }

      if ( tri_mesh->vNorms )
      {
         /* smooth shading */

         /* setup pointers to point to the last vertex */
         /* in the triangular mesh                     */
         verts = &verts[ (numVerts-1) * 3 ];
         vnorms = (float *) tri_mesh->vNorms;
         vnorms = &vnorms[ (numVerts-1) * 3 ];

         if ( send_last_separately )
         {
            /* send the last triangle */
            glBegin( GL_TRIANGLES );
            glNormal3fv( vnorms - 3 );
            glVertex3fv( verts - 3 );
            glNormal3fv( vnorms );
            glVertex3fv( verts );
            glNormal3fv( vnorms + 3 );
            glVertex3fv( verts + 3 );
            glEnd();
         }
            
         glBegin( GL_TRIANGLE_STRIP );
         while ( numVerts-- )
         {
            glNormal3fv( vnorms );
            glVertex3fv( verts );
            vnorms -= 3;
            verts -= 3;
         }
         glEnd();
      }
      else
      {
         /* constant shading => GL_FLAT shading mode, so the */
         /* (i+2)th vertex defines the color of the triangle */

         if ( tri_mesh->numFacetNormals > 1 )
         {
            /* setup pointers to point to the last vertex */
            /* in the triangular mesh                     */
            verts = &verts[ (numVerts-1) * 3 ];
            fnorms = &fnorms[ (numVerts-3) * 3 ];

            if ( send_last_separately )
            {
               /* send the last triangle */
               glBegin( GL_TRIANGLES );
               glNormal3fv( fnorms + 3 );
               glVertex3fv( verts - 3 );
               glVertex3fv( verts );
               glVertex3fv( verts + 3 );
               glEnd();
            }

            /* send the mesh backwards */
            glBegin( GL_TRIANGLE_STRIP );
            glNormal3fv( fnorms );
            glVertex3fv( verts );
            glVertex3fv( verts - 3 );
            glVertex3fv( verts - 6 );
            numVerts -= 3;
            verts -= 9;
            fnorms -= 3;
            while ( numVerts-- )
            {
               glNormal3fv( fnorms );
               glVertex3fv( verts );
               fnorms -= 3;
               verts -= 3;
            }
            glEnd();

         }
         else
         {
            /* setup pointers to point to the last vertex */
            /* in the triangular mesh                     */
            verts = &verts[ (numVerts-1) * 3 ];
            glNormal3fv( fnorms );

            if ( send_last_separately )
            {
               /* send the last triangle */
               glBegin( GL_TRIANGLES );
               glVertex3fv( verts - 3 );
               glVertex3fv( verts );
               glVertex3fv( verts + 3 );
               glEnd();
            }

            glBegin( GL_TRIANGLE_STRIP );
            while ( numVerts-- )
            {
               glVertex3fv( verts );
               verts -= 3;
            }
            glEnd();
         }
      }
   }
   else
   {
      /* don't need to reverse the direction of the mesh */
      if ( tri_mesh->vNorms )
      {
         /* smooth shading */
         glBegin( GL_TRIANGLE_STRIP );
         vnorms = (float *) tri_mesh->vNorms;
         while ( numVerts-- )
         {
            glNormal3fv( vnorms );
            glVertex3fv( verts );
            vnorms += 3;
            verts += 3;
         }
         glEnd();
      }
      else
      {
         /* constant shading => GL_FLAT shading mode, so the */
         /* (i+2)th vertex defines the color of the triangle */

         if ( tri_mesh->numFacetNormals > 1 )
         {
            glBegin( GL_TRIANGLE_STRIP );
            glNormal3fv( fnorms );
            glVertex3fv( verts );
            glVertex3fv( verts + 3 );
            glVertex3fv( verts + 6 );
            numVerts -= 3;
            verts += 9;
            fnorms += 3;
            while ( numVerts-- )
            {
               glNormal3fv( fnorms );
               glVertex3fv( verts );
               fnorms -= 3;
               verts -= 3;
            }
            glEnd();
         }
         else
         {
            glBegin( GL_TRIANGLE_STRIP );
            glNormal3fv( fnorms );
            while ( numVerts-- )
            {
               glVertex3fv( verts );
               verts += 3;
            }
            glEnd();
         }
      }
   }

#if defined( DRAW_VERTEX_NORMALS )
   if ( tri_mesh->vNorms )
   {
      float x,y,z;

      glDisable( GL_LIGHTING );
      glColor3f( 1.0, 0.5, 0.5 );
      numVerts = tri_mesh->numVerts;
      verts = (float *)tri_mesh->verts;
      vnorms = (float *)tri_mesh->vNorms;
      while ( numVerts-- )
      {
         glBegin( GL_LINES );
         glVertex3fv( verts );
         x = verts[0] + .1 * vnorms[0];
         y = verts[1] + .1 * vnorms[1];
         z = verts[2] + .1 * vnorms[2];
         glVertex3f( x, y, z );
         verts += 3;
         vnorms += 3;
         glEnd();
      }
      glEnable( GL_LIGHTING );
   }
#endif

   return( TRUE );
} /* HSsend_trimesh_to_OPENGL */


/*---HSsend_polyline_to_OPENGL-----------------------------------------------*/

void HSsend_polyline_to_OPENGL(
   IGRint num_points, 
   IGRpoint *points )

/*
NAME
   HSsend_polyline_to_OPENGL

DESCRIPTION
   This function sends a polyline to OPENGL

SYNOPSIS
   void HSsend_polyline_to_OPENGL(
      IGRint num_points, 
      IGRpoint *points )
   
PARAMETERS
   num_points (IN) - the number of points in the polyline
   points (IN) - the points of the polyline

GLOBALS USED
   none

HISTORY
   05/03/93  S.P. Rogers
      Creation Date
*/

{
   IGRint    ii;
   IGRdouble *dbl_ptr;
   
   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );

   if ( tiling_parms.processing_mode & HS_PMODE_FEEDBACK )
   {
      HSsave_trimesh_polyline( num_points, points );
   }
   else
   {
      dbl_ptr = (IGRdouble *) points;
      glBegin( GL_LINE_STRIP );
      while ( num_points-- )
      {
         glVertex3dv( dbl_ptr );
         dbl_ptr += 3;
      }

      glEnd();
   }

}  /* HSsend_polyline_to_OPENGL */

/*---HSdraw_point_OPENGL--------------------------------------------------------------*/

void HSdraw_point_OPENGL(
   IGRpoint point )

/*
NAME
   HSdraw_point_OPENGL

DESCRIPTION
   This function shades a point using OpenGL

SYNOPSIS
   void HSdraw_point_OPENGL(
      IGRpoint point )

PARAMETERS
   point (IN) - the point to shade

GLOBALS USED
   none

HISTORY
   08/16/93 S.P. Rogers
      Added header
*/

{
   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );

   glBegin( GL_POINTS );
   glVertex3dv( point );
   glEnd();

}  /* HSdraw_point_OPENGL */

/*--- HSpaint_screen_OPENGL ------------------------------------------------------*/

void HSpaint_screen_OPENGL(
   void )

/*
NAME
   HSpaint_screen_OPENGL

DESCRIPTION
   This function flushes all shading output to the screen in
   OpenGL

SYNOPSIS
   void HSpaint_screen_OPENGL(
      void )

PARAMETERS
   none

GLOBALS USED
   none

HISTORY
   08/16/93 S.P. Rogers
      Added header
*/

{
   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );

   glFlush();

}  /* HSpaint_screen_OPENGL */

#endif
