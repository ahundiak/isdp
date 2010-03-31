
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:43 $
$Locker:  $
*/

#if defined( XGL )

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"

#include "bs.h"
#include "bsvalues.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsmath.h"
#include "hsdisplay.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/* prototypes */
#include "bscrossp.h"
#include "bsdotp.h"

extern IGRboolean  DPdynamic_update_in_progress;
/*---- HSsetup_XGL_lights -------------------------------------------------*/

void HSsetup_XGL_lights(
   struct HS_light_source global_lights[MAX_LIGHTS],
   struct HS_light_source *ambient_light )

/*
NAME
        HSsetup_XGL_lights

DESCRIPTION
        This function sets the necessary XGL light structures.

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
        04/04/94   M. Lanier
           Copied from HStl_opengl.c and modified for XGL support
           
        04/23/93   S.P. Rogers
           Created from HSsetup_EG_lights.
*/

   {
   Xgl_light	lights[MAX_LIGHTS+1];
   Xgl_boolean	light_switchs[MAX_LIGHTS+1];
   Xgl_color    light_color;
   Xgl_pt_f3d	pt;
   Xgl_pt_d3d   dpt;
   IGRint	ii;

   struct HS_light_source aligned_lights[MAX_LIGHTS];

   light_color.rgb.r = 1.0;
   light_color.rgb.g = 1.0;
   light_color.rgb.b = 1.0;

   xgl_object_set(  active_window->xgl_context_3D,
                    XGL_CTX_SURF_FRONT_COLOR_SELECTOR, XGL_SURF_COLOR_CONTEXT,
                    XGL_3D_CTX_SURF_BACK_COLOR_SELECTOR, XGL_SURF_COLOR_CONTEXT,
                    XGL_3D_CTX_SURF_FACE_CULL, XGL_CULL_OFF,
                    XGL_CTX_SURF_FRONT_COLOR, &light_color,
                    XGL_3D_CTX_SURF_FRONT_AMBIENT, 1.0,
                    XGL_3D_CTX_SURF_FRONT_DIFFUSE, 1.0,
                    XGL_3D_CTX_SURF_FRONT_SPECULAR, 1.0,
                    XGL_3D_CTX_SURF_FRONT_SPECULAR_COLOR, &light_color,
                    XGL_3D_CTX_SURF_FRONT_SPECULAR_POWER, 32.0,
                    XGL_3D_CTX_SURF_FRONT_LIGHT_COMPONENT,
                    XGL_LIGHT_ENABLE_COMP_AMBIENT |
                    XGL_LIGHT_ENABLE_COMP_DIFFUSE |
                    XGL_LIGHT_ENABLE_COMP_SPECULAR,
                    XGL_3D_CTX_LIGHT_NUM, MAX_LIGHTS+1 , 
                    NULL);
 
   xgl_object_get( active_window->xgl_context_3D,
                   XGL_3D_CTX_LIGHTS, lights );

   xgl_object_get( active_window->xgl_context_3D,
                   XGL_3D_CTX_LIGHT_SWITCHES, light_switchs );

/*
   xgl_object_set(  lights[0],
                    XGL_LIGHT_TYPE, XGL_LIGHT_AMBIENT,
                    XGL_LIGHT_COLOR, &light_color,
                    NULL);

   pt.x = 0.0;
   pt.y = 0.0;
   pt.z = 1.0;

   xgl_object_set( lights[0],
                   XGL_LIGHT_TYPE, XGL_LIGHT_DIRECTIONAL,
                   XGL_LIGHT_COLOR, &light_color,
                   XGL_LIGHT_DIRECTION, &pt,
                   NULL );

   pt.x = 0.0;
   pt.y = 0.0;
   pt.z = -1.0;

   xgl_object_set( lights[1],
                   XGL_LIGHT_TYPE, XGL_LIGHT_DIRECTIONAL,
                   XGL_LIGHT_COLOR, &light_color,
                   XGL_LIGHT_DIRECTION, &pt,
                   NULL );

   light_switchs[0] = TRUE;
   light_switchs[1] = TRUE;

   xgl_object_set( active_window->xgl_context_3D,
                   XGL_3D_CTX_LIGHT_SWITCHES, light_switchs,
                   NULL );
*/


   /* Get the window lights into world coordinates */

   HSalign_view_lights_to_world( global_lights, aligned_lights );

   for ( ii = 0; ii < MAX_LIGHTS; ii++ )
      {
      if ( aligned_lights[ii].flags & HS_LIGHT_ENABLED )
         {
         switch ( aligned_lights[ii].flags & HS_LIGHT_TYPE )
            {
            case HS_LIGHT_SPOT:
#if FALSE
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
#endif
               break;

            case HS_LIGHT_POINT:
               dpt.x = aligned_lights[ii].location[0];
               dpt.y = aligned_lights[ii].location[1];
               dpt.z = aligned_lights[ii].location[2];

               xgl_object_set( lights[ii],
                               XGL_LIGHT_TYPE, XGL_LIGHT_POSITIONAL,
                               XGL_LIGHT_POSITION, &dpt,
                               NULL );
               break;

            case HS_LIGHT_PARALLEL:
            case HS_LIGHT_PENCIL:
               pt.x = aligned_lights[ii].direction[0];
               pt.y = aligned_lights[ii].direction[1];
               pt.z = aligned_lights[ii].direction[2];

               xgl_object_set( lights[ii],
                   XGL_LIGHT_TYPE, XGL_LIGHT_DIRECTIONAL,
                   XGL_LIGHT_DIRECTION, &pt,
                   NULL );

               break;

            } /* end: switch */

         light_color.rgb.r = (float)(aligned_lights[ii].red / 255.0);
         light_color.rgb.g = (float)(aligned_lights[ii].green / 255.0);
         light_color.rgb.b = (float)(aligned_lights[ii].blue / 255.0);

         xgl_object_set( lights[ii],
                   XGL_LIGHT_COLOR, &light_color,
                   NULL );

         light_switchs[ii] = TRUE;

         } /* light is active */
      else
         {

         /*
          *  This light is off, disable it
          */

         light_switchs[ii] = FALSE;
         }
      }    /* end: for */

   if ( ambient_light )
      {

      /*
       *  Set the last light in the list to be the ambient light.
       *  I've allocated MAX_LIGHTS+1 lights, for the MAX_LIGHTS 
       *  lights in the global light structure and one more for
       *  the ambient light.  I put the ambient light in the last
       *  slot so that the global lights will match up
       */

      light_color.rgb.r = ambient_light->red / 255.0;
      light_color.rgb.g = ambient_light->green / 255.0;
      light_color.rgb.b = ambient_light->blue / 255.0;

      xgl_object_set(  lights[MAX_LIGHTS],
                       XGL_LIGHT_TYPE, XGL_LIGHT_AMBIENT,
                       XGL_LIGHT_COLOR, &light_color,
                       NULL );

      light_switchs[MAX_LIGHTS] = TRUE;
      }
   else
      {

      /*
       *  Disable the ambient light
       */

      light_switchs[MAX_LIGHTS] = FALSE;
      }

   xgl_object_set( active_window->xgl_context_3D,
                   XGL_3D_CTX_LIGHT_SWITCHES, light_switchs,
                   NULL );

   } /* HSsetup_XGL_lights */

/*--- HSsetup_XGL_window --------------------------------------------*/

void HSsetup_XGL_window(
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
   HSsetup_XGL_window

DESCRIPTION
   This function sets up a window for shading via XGL

SYNOPSIS
   void HSsetup_XGL_window(
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
   up the correct XGL rendering context.

HISTORY
   04/04/94   M. Lanier
      Copied from HStl_opengl.c and modified for XGL support
           
   08/16/93 S.P. Rogers
      Added header
*/

{
   WLuint32 base_context_no;
   struct WLnative_info native_info;
   float scale_factors[2];
   double ref_planes[2];
   XEvent event;
   Xgl_object xgl_context_3D, hl_xgl_context;

   WLxgl_get_window_contexts( active_window->win_no, 
                              &xgl_context_3D, 
                              &hl_xgl_context );

   active_window->xgl_context_3D = xgl_context_3D;
   xgl_object_set( xgl_context_3D, 
                   XGL_3D_CTX_HLHSR_MODE, XGL_HLHSR_Z_BUFFER,
                   XGL_CTX_NEW_FRAME_ACTION, 
                      XGL_CTX_NEW_FRAME_HLHSR_ACTION |
                      XGL_CTX_NEW_FRAME_CLEAR,
                   /*XGL_3D_CTX_SURF_TRANSP_METHOD, XGL_TRANSP_SCREEN_DOOR, */
                   0 );

   scale_factors[0] = 1.0;
   scale_factors[1] = 0.0;
   ref_planes[0] = active_window->dit_clip_range[2];
   ref_planes[1] = active_window->dit_clip_range[5];

   scale_factors[0] = active_window->depth_cue_base;
   scale_factors[1] = (active_window->depth_cue_base +
                       active_window->depth_cue_delta *
                       (active_window->dit_clip_range[5] -
                       active_window->dit_clip_range[2]));
 

   if( active_window->depth_cue_on )
      {
      xgl_object_set( xgl_context_3D,
                      XGL_3D_CTX_DEPTH_CUE_SCALE_FACTORS, scale_factors,
                      XGL_3D_CTX_DEPTH_CUE_REF_PLANES, ref_planes,
                      XGL_3D_CTX_DEPTH_CUE_MODE, XGL_DEPTH_CUE_SCALED,
                      0 );
      }
   else
      {
      xgl_object_set( xgl_context_3D,
                      XGL_3D_CTX_DEPTH_CUE_MODE, XGL_DEPTH_CUE_OFF,
                      0 );
      }

   /*
    *  Here's a kludge..  On the Ultra workstation, the first time we turn on
    *  zbuffering a bogus expose event appears in the window's event queue.
    *  What this does is scan the event queue looking for the expose event
    *  and flushes it out.  
    */

   WLget_window_base_context( active_window->win_no, &base_context_no );
   WLget_native_info( active_window->win_no, base_context_no, &native_info );

   while( XCheckTypedWindowEvent( native_info.display,
                                  native_info.base_win,
                                  Expose,
                                  &event ) )
      {
      /*fprintf( stderr, "Expose event removed: %s %d\n", __FILE__, __LINE__ );*/
      }

   /* 
    *  There used to be a call to xgl_context_new_frame here, but
    *  I replaced it with a call to HSclear_window, which calls
    *  xgl_context_new_frame.  HSclear_window also allows for updates
    *  of window regions.  
    */

   HSclear_window( active_window->win_no );

} /* HSsetup_XGL_window */

/*--- HSdelete_XGL_shading_window --------------------------------------*/

void HSdelete_XGL_shading_window(
   void )

/*
NAME
   HSdelete_XGL_shading_window

DESCRIPTION
   This function deletes an XGL shading window.  That is,
   it sets it up for wireframe display.

SYNOPSIS
   void HSdelete_XGL_shading_window(
      void )

PARAMETERS
   none

GLOBALS USED
   active_window

HISTORY
   04/04/94   M. Lanier
      Copied from HStl_opengl.c and modified for XGL support
           
   04/27/93    S.P. Rogers
      Creation Date
*/

{
   Xgl_boolean	all_lights_off[MAX_LIGHTS+1];
   int		i;
   Xgl_color	light_color;
   Xgl_light	lights[MAX_LIGHTS+1];

   /*  set the ambient light to white for wireframe  */

   light_color.rgb.r = 255.0;
   light_color.rgb.g = 255.0;
   light_color.rgb.b = 255.0;

   xgl_object_get( active_window->xgl_context_3D,
                   XGL_3D_CTX_LIGHTS, lights );

   xgl_object_set( lights[MAX_LIGHTS],
                   XGL_LIGHT_TYPE, XGL_LIGHT_AMBIENT,
                   XGL_LIGHT_COLOR, &light_color,
                   NULL );

   /*  turn all lights off except for ambient  */

   for( i=0; i<MAX_LIGHTS; i++ )
	all_lights_off[i] = FALSE;

   all_lights_off[MAX_LIGHTS] = TRUE;

   /*  turn off depth cue and zbuffering and set the lights for wireframe */

   xgl_object_set( active_window->xgl_context_3D,
                   XGL_3D_CTX_DEPTH_CUE_MODE, XGL_DEPTH_CUE_OFF,
                   XGL_3D_CTX_LIGHT_SWITCHES, all_lights_off,
                   XGL_3D_CTX_HLHSR_MODE, XGL_HLHSR_NONE,
                   0 );

}  /* HSdelete_XGL_shading_window */

static int	tcount = 0;

#define XGL_LOG	0
#if XGL_LOG
extern FILE	*xgl_log;
extern int	xgl_log_color;
#endif

#define XGL_LOG_DUMP( pl ) \
fprintf( xgl_log, "%d\n", pl.num_pts ); \
for( i=0; i<pl.num_pts; i++ ) \
fprintf( xgl_log, "4 %d %f %f %f %f %f %f\n", \
        xgl_log_color, \
	pl.pts.normal_f3d[i].x, \
	pl.pts.normal_f3d[i].y, \
	pl.pts.normal_f3d[i].z, \
	pl.pts.normal_f3d[i].normal.x, \
	pl.pts.normal_f3d[i].normal.y, \
	pl.pts.normal_f3d[i].normal.z );

/*--- HSsend_trimesh_to_XGL ------------------------------------------------------*/

int HSsend_trimesh_to_XGL(
   int dummy,
   struct HStri_mesh *tri_mesh )

/*
NAME
   HSsend_mesh_to_XGL

DESCRIPTION
   This function sends a triangular mesh to XGL to be shaded.

PARAMETERS
   dummy (IN) - used only on EG version of this function
   tri_mesh (static) - the triangular mesh structure to send to GL.

GLOBALS USED
   none

RETURN VALUES
   TRUE, always

HISTORY
   04/04/94   M. Lanier
      Copied from HStl_opengl.c and modified for XGL support
           
    04/26/93    S.P. Rogers
        Creation Date
*/

{
   Xgl_facet_list	facet;
   Xgl_pt_list	pl;
   Xgl_pt_normal_f3d	*xgl_mesh;
   int			i, j;
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

   xgl_mesh = (Xgl_pt_normal_f3d *)malloc( 
                        (tri_mesh->numVerts+1) * sizeof( Xgl_pt_normal_f3d ) );
   pl.pt_type = XGL_PT_NORMAL_F3D;
   pl.bbox = NULL;
   pl.num_data_values = 0;
   pl.pts.normal_f3d = xgl_mesh;

   facet.facet_type = XGL_FACET_NONE;
   facet.num_facets = 0; 
   facet.facets.normal_facets = NULL;

   numVerts = tri_mesh->numVerts;
   verts = (float *) tri_mesh->verts;
   fnorms = (float *)tri_mesh->fNorms;

   /* calculate a normal to the triangluar mesh in */
   /* the same way that XGL will                */
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
            for ( i = 0; i < 3; i++ )
            { 
               xgl_mesh[i].x = (verts-3)[3*i];
               xgl_mesh[i].y = (verts-3)[3*i+1];
               xgl_mesh[i].z = (verts-3)[3*i+2];
               xgl_mesh[i].normal.x = (vnorms-3)[3*i];
               xgl_mesh[i].normal.y = (vnorms-3)[3*i+1];
               xgl_mesh[i].normal.z = (vnorms-3)[3*i+2];
            }
            pl.num_pts = 3;
            pl.pts.normal_f3d = xgl_mesh;

#if XGL_LOG
XGL_LOG_DUMP( pl )
#endif
            xgl_triangle_strip( active_window->xgl_context_3D, &facet, &pl );
            /* send the last triangle */
         }
            
         pl.num_pts = numVerts;
         pl.pts.normal_f3d = xgl_mesh;
         i = 0;
         while( numVerts-- )
         {
            xgl_mesh[i].x = (verts)[0];
            xgl_mesh[i].y = (verts)[1];
            xgl_mesh[i].z = (verts)[2];
            xgl_mesh[i].normal.x = (vnorms)[0];
            xgl_mesh[i].normal.y = (vnorms)[1];
            xgl_mesh[i].normal.z = (vnorms)[2];

            vnorms -= 3;
            verts -= 3;
            i++;
            }


#if XGL_LOG
XGL_LOG_DUMP( pl )
#endif
         xgl_triangle_strip( active_window->xgl_context_3D, &facet, &pl );
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
               for ( i = 0; i < 3; i++ )
                  { 
                  xgl_mesh[i].x = (verts-3)[3*i];
                  xgl_mesh[i].y = (verts-3)[3*i+1];
                  xgl_mesh[i].z = (verts-3)[3*i+2];
                  xgl_mesh[i].normal.x = (fnorms+3)[0];
                  xgl_mesh[i].normal.y = (fnorms+3)[1];
                  xgl_mesh[i].normal.z = (fnorms+3)[2];
                  }
                  
               pl.num_pts = 3;
               pl.pts.normal_f3d = xgl_mesh;

#if XGL_LOG
XGL_LOG_DUMP( pl )
#endif
               xgl_triangle_strip( active_window->xgl_context_3D, &facet, &pl );
               }

            i = 0;
            
            for ( j = 2; j >= 0; j-- )
               { 
               xgl_mesh[i].x = (verts-6)[3*j];
               xgl_mesh[i].y = (verts-6)[3*j+1];
               xgl_mesh[i].z = (verts-6)[3*j+2];
               xgl_mesh[i].normal.x = (fnorms)[0];
               xgl_mesh[i].normal.y = (fnorms)[1];
               xgl_mesh[i].normal.z = (fnorms)[2];
               i++;
               }
               
            numVerts -= 3;
            verts -= 9;
            fnorms -= 3;
            
            while ( numVerts-- )
               {
               xgl_mesh[i].x = (verts)[0];
               xgl_mesh[i].y = (verts)[1];
               xgl_mesh[i].z = (verts)[2];
               xgl_mesh[i].normal.x = (fnorms)[0];
               xgl_mesh[i].normal.y = (fnorms)[1];
               xgl_mesh[i].normal.z = (fnorms)[2];
               
               fnorms -= 3;
               verts -= 3;
               i++;
               }
               
            pl.num_pts = i;
            pl.pts.normal_f3d = xgl_mesh;

#if XGL_LOG
XGL_LOG_DUMP( pl )
#endif
            xgl_triangle_strip( active_window->xgl_context_3D, &facet, &pl );
            }
         else
            {
            /* setup pointers to point to the last vertex */
            /* in the triangular mesh                     */
            verts = &verts[ (numVerts-1) * 3 ];

            if ( send_last_separately )
               {
               for ( i = 0; i < 3; i++ )
                  { 
                  xgl_mesh[i].x = (verts-3)[3*i];
                  xgl_mesh[i].y = (verts-3)[3*i+1];
                  xgl_mesh[i].z = (verts-3)[3*i+2];
                  xgl_mesh[i].normal.x = (fnorms)[0];
                  xgl_mesh[i].normal.y = (fnorms)[1];
                  xgl_mesh[i].normal.z = (fnorms)[2];
                  }
                  
               pl.num_pts = 3;
               pl.pts.normal_f3d = xgl_mesh;

#if XGL_LOG
XGL_LOG_DUMP( pl )
#endif
               xgl_triangle_strip( active_window->xgl_context_3D, &facet, &pl );
               /* send the last triangle */
               }

            i = 0;
            
            while ( numVerts-- )
               {
               xgl_mesh[i].x = (verts)[0];
               xgl_mesh[i].y = (verts)[1];
               xgl_mesh[i].z = (verts)[2];
               xgl_mesh[i].normal.x = (fnorms)[0];
               xgl_mesh[i].normal.y = (fnorms)[1];
               xgl_mesh[i].normal.z = (fnorms)[2];
               
               verts -= 3;
               i++;
               }
            
            pl.num_pts = i;   
            pl.pts.normal_f3d = xgl_mesh;

#if XGL_LOG
XGL_LOG_DUMP( pl )
#endif
            xgl_triangle_strip( active_window->xgl_context_3D, &facet, &pl );
            }
         }
      }
   else
      {
      /* don't need to reverse the direction of the mesh */
      if ( tri_mesh->vNorms )
         {
         /* smooth shading */
         vnorms = (float *) tri_mesh->vNorms;
         pl.num_pts = numVerts;
         pl.pts.normal_f3d = xgl_mesh;
         i = 0;
         while( numVerts-- )
            {
            xgl_mesh[i].x = (verts)[0];
            xgl_mesh[i].y = (verts)[1];
            xgl_mesh[i].z = (verts)[2];
            xgl_mesh[i].normal.x = (vnorms)[0];
            xgl_mesh[i].normal.y = (vnorms)[1];
            xgl_mesh[i].normal.z = (vnorms)[2];

            vnorms += 3;
            verts += 3;
            i++;
            }

#if XGL_LOG
XGL_LOG_DUMP( pl )
#endif
         xgl_triangle_strip( active_window->xgl_context_3D, &facet, &pl );
         }
      else
         {
         /* constant shading => GL_FLAT shading mode, so the */
         /* (i+2)th vertex defines the color of the triangle */

         pl.num_pts = numVerts;
         pl.pts.normal_f3d = xgl_mesh;

         if ( tri_mesh->numFacetNormals > 1 )
            {
            for ( i = 0; i < 3; i++ )
               { 
               xgl_mesh[i].x = (verts)[3*i];
               xgl_mesh[i].y = (verts)[3*i+1];
               xgl_mesh[i].z = (verts)[3*i+2];
               xgl_mesh[i].normal.x = (fnorms)[0];
               xgl_mesh[i].normal.y = (fnorms)[1];
               xgl_mesh[i].normal.z = (fnorms)[2];
               }

            numVerts -= 3;
            verts += 9;
            fnorms += 3;

            while ( numVerts-- )
               {
               xgl_mesh[i].x = (verts)[0];
               xgl_mesh[i].y = (verts)[1];
               xgl_mesh[i].z = (verts)[2];
               xgl_mesh[i].normal.x = (fnorms)[0];
               xgl_mesh[i].normal.y = (fnorms)[1];
               xgl_mesh[i].normal.z = (fnorms)[2];

               fnorms += 3;
               verts += 3;
               i++;
               }
            }
         else
            {
            i = 0;
            while ( numVerts-- )
               {
               xgl_mesh[i].x = (verts)[0];
               xgl_mesh[i].y = (verts)[1];
               xgl_mesh[i].z = (verts)[2];
               xgl_mesh[i].normal.x = (fnorms)[0];
               xgl_mesh[i].normal.y = (fnorms)[1];
               xgl_mesh[i].normal.z = (fnorms)[2];

               verts += 3;
               i++;
               }
            }


#if XGL_LOG
XGL_LOG_DUMP( pl )
#endif
         xgl_triangle_strip( active_window->xgl_context_3D, &facet, &pl );
         }
      }

   return( TRUE );
   } /* HSsend_trimesh_to_XGL */


static Xgl_pt_f3d	xgl_pts[1000];

/*---HSsend_polyline_to_XGL-----------------------------------------------*/

void HSsend_polyline_to_XGL(
   IGRint num_points, 
   IGRpoint *points )

/*
NAME
   HSsend_polyline_to_XGL

DESCRIPTION
   This function sends a polyline to XGL

SYNOPSIS
   void HSsend_polyline_to_XGL(
      IGRint num_points, 
      IGRpoint *points )
   
PARAMETERS
   num_points (IN) - the number of points in the polyline
   points (IN) - the points of the polyline

GLOBALS USED
   none

HISTORY
   04/04/94   M. Lanier
      Copied from HStl_opengl.c and modified for XGL support
           
   05/03/93  S.P. Rogers
      Creation Date
*/

   {
   int		i;
   Xgl_pt_list	pt[1];
   double	*p;

   WLset_active_symbology( active_window->win_no,
                           0,
                           element_parms.visible_style,
                           0xffffffff,
                           element_parms.visible_weight,
                           WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );

   WLactivate_symbology( active_window->win_no, FALSE, TRUE );

   pt[0].pt_type = XGL_PT_F3D;
   pt[0].bbox = NULL;
   pt[0].num_pts = num_points;
   pt[0].num_data_values = 0;

   p = (double *)points;
   for( i=0; i<num_points; i++ )
      {
      xgl_pts[i].x = (float)p[i*3];
      xgl_pts[i].y = (float)p[i*3+1];
      xgl_pts[i].z = (float)p[i*3+2];
      }

   pt[0].pts.f3d = xgl_pts;

   xgl_multipolyline( active_window->xgl_context_3D,
                      NULL,
                      1,
                      pt );

   }  /* HSsend_polyline_to_XGL */

/*---HSdraw_point_XGL--------------------------------------------------------------*/

void HSdraw_point_XGL(
   IGRpoint point )

/*
NAME
   HSdraw_point_XGL

DESCRIPTION
   This function shades a point using XGL

SYNOPSIS
   void HSdraw_point_XGL(
      IGRpoint point )

PARAMETERS
   point (IN) - the point to shade

GLOBALS USED
   none

HISTORY
   04/04/94   M. Lanier
      Copied from HStl_opengl.c and modified for XGL support
           
   08/16/93 S.P. Rogers
      Added header
*/

{
#if COMMENT_OUT
   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );

   glBegin( GL_POINTS );
   glVertex3dv( point );
   glEnd();
#endif
}  /* HSdraw_point_XGL */

/*--- HSpaint_screen_XGL ------------------------------------------------------*/

void HSpaint_screen_XGL(
   void )

/*
NAME
   HSpaint_screen_XGL

DESCRIPTION
   This function flushes all shading output to the screen in
   XGL

SYNOPSIS
   void HSpaint_screen_XGL(
      void )

PARAMETERS
   none

GLOBALS USED
   none

HISTORY
   04/04/94   M. Lanier
      Copied from HStl_opengl.c and modified for XGL support
           
   08/16/93 S.P. Rogers
      Added header
*/

{
   xgl_context_flush (active_window->xgl_context_3D, XGL_FLUSH_BUFFERS);

}  /* HSpaint_screen_XGL */

#endif
