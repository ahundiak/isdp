
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

/*
 * This file contains all the routines that set per-element global values.
 */

#include <stdio.h>
#include <stdlib.h>

#include "wl.h"

#if defined( ENV5 )
#include <EG.h>
#endif

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "hstiler.h"
#include "hslight.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HSfem_spt.h"
#include "hsmacdef.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

#if defined( OPENGL )
static GLubyte gl_narrow_trans[] = {
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55 };

static GLubyte gl_wide_trans[] = {
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F };

static GLubyte gl_opaque[] = {
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
#endif

#if defined( XGL )
static unsigned char	
   xgl_narrow_trans[8] = { 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 },
   xgl_wide_trans[8]   = { 0xf0, 0xf0, 0xf0, 0xf0, 0x0f, 0x0f, 0x0f, 0x0f },
   xgl_solid_trans[8]  = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
#endif

/*---HSdump_element_parms-----------------------------------------------------*/

/*
NAME
    HSdump_element_parms
    
DESCRIPTION
    prints out the values of the element parameters
    
HISTORY
    8/29/90    M. Jablonski
        Created
*/

void    HSdump_element_parms(void)

    {
    fprintf (stderr, "GLOBAL ELEMENT PARAMETERS:\n");
    fprintf (stderr, "  color = %d\n", element_parms.color);
    fprintf (stderr, "  visible_weight = %d\n", element_parms.visible_weight);
    fprintf (stderr, "  hidden_weight = %d\n", element_parms.hidden_weight);
    fprintf (stderr, "  delete = %d\n", element_parms.delete);
    fprintf (stderr, "  facet_type = %d\n", element_parms.facet_type);
    fprintf (stderr, "  ele_clip_range = %lf %lf %lf\n",
        element_parms.ele_clip_range[0],
        element_parms.ele_clip_range[1],
        element_parms.ele_clip_range[2]);
    fprintf (stderr, "                   %lf %lf %lf\n",
        element_parms.ele_clip_range[3],
        element_parms.ele_clip_range[4],
        element_parms.ele_clip_range[5]);
    fprintf (stderr, "  facet_normal = %lf %lf %lf\n",
        element_parms.facet_normal[0],
        element_parms.facet_normal[1],
        element_parms.facet_normal[2]);
    fprintf (stderr, "  unscaled_facet_normal = %lf %lf %lf\n",
        element_parms.unscaled_facet_normal[0],
        element_parms.unscaled_facet_normal[1],
        element_parms.unscaled_facet_normal[2]);
    fprintf (stderr, "  front_facing_facet = %d\n", element_parms.front_facing_facet);
    fprintf (stderr, "  doing_vertex_normals = %d\n", element_parms.doing_vertex_normals);
    fprintf (stderr, "  culling_back_planes = %d\n", element_parms.culling_back_planes);
    fprintf (stderr, "  marking_edges = %d\n", element_parms.marking_edges);
    fprintf (stderr, "  interp_tol = %lf\n", element_parms.interp_tol);
    fprintf (stderr, "  basis_tol = %lf\n", element_parms.basis_tol);
    fprintf (stderr, "  dis_tol = %lf\n", element_parms.dis_tol);
    fprintf (stderr, "  surf_geom(ptr) = %x\n", element_parms.surf_geom);
    fprintf (stderr, "  render_parms(ptr) = %x\n", element_parms.render_parms);
    if (element_parms.render_parms)
        {
        fprintf (stderr, "    color = %d\n", element_parms.render_parms->color);
        fprintf (stderr, "    finish = %d\n", element_parms.render_parms->finish);
        fprintf (stderr, "    specular reflectance = %lf\n", element_parms.render_parms->spec_refl);
        fprintf (stderr, "    diffuse reflectance = %lf\n", element_parms.render_parms->diff_refl);
        fprintf (stderr, "    transparency = %lf\n", element_parms.render_parms->transparency);
        }
    fprintf (stderr, "  fem_parms(ABC) = %lf %lf %lf\n",
        element_parms.fem_parms.A,
        element_parms.fem_parms.B,
        element_parms.fem_parms.C);
    fprintf (stderr, "  fem_parms(triangle) = %d\n",
        element_parms.fem_parms.triangle);
    }

/*---HSset_element_color------------------------------------------------------*/

/*
NAME
    HSset_element_color
    
DESCRIPTION
    sets the element color
    
PARAMETERS
    color: (IN):  Logical color number
    
HISTORY
    2/28/90    M. Jablonski
        Create
        
    6/29/92    J. Underwood
        Added Psuedo True Color vars.   Done
        here so only has to be computed once
        per object
*/

void HSset_element_color( unsigned int color )

    {
    IGRint psuedo_color;
    IGRshort abs_color;

#   if defined (XGL)
    WLuint32 context_no;
#   endif

    if ( active_window->using_ramps )
       {
       element_parms.color = get_color_index( &color );

#      if defined( ENV5 )
          fgcolor( active_window->hwin_no, element_parms.color );
#      endif
       }
    else
       {
       element_parms.color_logical = color;      /*logical color*/
       psuedo_color = HSget_rgb_value( color );
       element_parms.red=(psuedo_color >> 22) & 0xff;
       element_parms.green=(psuedo_color >> 12) & 0xff;
       element_parms.blue=(psuedo_color >> 2) & 0xff;

#      if defined (XGL)

          /*  In XGL we want to use to forms 8bit context convert our  */
          /*  logical color index to a physical index because the active  */
          /*  context is 24bit and would return a bad value  */

          CMget_exnuc_forms_context( active_window->vs_no, &context_no );
          IGEgetabsclrindx(context_no, 
                           (IGRshort) color, 
                           &abs_color);
#      else
          IGEgetabsclrindx(active_window->context_no, 
                           (IGRshort) color, 
                           &abs_color);
#      endif

       element_parms.color = (IGRuint) abs_color;
       }
    }

/*---HSset_element_weights---------------------------------------------------*/

/*
NAME
    HSset_element_weights
    
DESCRIPTION
    Set the hsurf active hidden and visible weights
    
PARAMETERS
    visible: (IN):  The visible weight
    hidden : (IN):  The hidden weight
    
HISTORY
    2/28/90    M. Jablonski
        Created
        
*/

void HSset_element_weights( IGRint visible, IGRint hidden )

/*
 * ABSTRACT:    HSset_element_weights sets the weights for visible and hidden lines.
 *
 * HISTORY:    02/28/90  Created            C. M. Jablonski
 */

    {
    element_parms.visible_weight = visible;
    element_parms.hidden_weight = hidden;
    }


/*---HSset_element_delete_flag------------------------------------------------*/

/*
NAME
    HSset_element_delete_flag
    
DESCRIPTION
    Sets the delete flag for this element
    
PARAMETERS
    flag: (IN): the element delete flag
    
HISTORY
    02/28/90    M. Jablonski
        Created
*/

void HSset_element_delete_flag( IGRboolean flag )

    {
    element_parms.delete = flag;
    }


/*---HSset_ele_clip_range-----------------------------------------------------*/

/*
NAME
    HSset_ele_clip_range
    
DESCRIPTION
    Sets the per-element clip range for the window
    
PARAMETERS
    clip_range: (IN): array containing the clip range
    
HISTORY
    4/2/90    M. Jablonski
        Created
    07/14/93  S.P. Rogers
        Took out EG setup because DL is now taking care of it
*/

void HSset_ele_clip_range(
   IGRdouble clip_range[6] )


    {
    IGRboolean	region_update = FALSE, rhl_display = FALSE, shd_display = FALSE;
    IGRboolean	hwzbuf = FALSE, rhl_window = FALSE, shd_window = FALSE, wire_window = FALSE;
    IGRint	xlo, ylo, xhi, yhi, type, style, orig_style;

    HSget_region_update( &region_update );
    if (region_update) 
        {
        HSget_region_style( &style );
        HSget_region_original_style( &orig_style );
        
        rhl_display = (style == HS_STYLE_RASTER       || style == HS_STYLE_FILLED_RASTER);
        rhl_window  = (orig_style == HS_STYLE_RASTER  || orig_style == HS_STYLE_FILLED_RASTER);
        shd_display = (style == HS_STYLE_SMOOTH)      || (style == HS_STYLE_CONSTANT);
        shd_window  = (orig_style == HS_STYLE_SMOOTH) || (orig_style == HS_STYLE_CONSTANT);
        wire_window = (orig_style == HS_STYLE_WIREFRAME);
        
        HSget_region_hardware_type( &type );
        hwzbuf = (type & HShardware_ZB_MASK);
        }
    else
        type = active_window->type;
        
    if (region_update)
        {

        /* can't clip here if region size zbuffer */
        
        HSget_region_xy_minmax( &xlo, &ylo, &xhi, &yhi );

        if ((shd_display && shd_window)||
            (shd_display && (wire_window || rhl_window) && hwzbuf) ||
            (rhl_display && rhl_window&&hwzbuf))
            {
            clip_range[0]=(clip_range[0]>xlo-1)?clip_range[0]:xlo-1;
            clip_range[1]=(clip_range[1]>ylo-1)?clip_range[1]:ylo-1;
            clip_range[3]=(clip_range[3]<xhi+1)?clip_range[3]:xhi+1;
            clip_range[4]=(clip_range[4]<yhi+1)?clip_range[4]:yhi+1;
            }
        else
        if ((rhl_window&&!hwzbuf))
            {
            if (shd_display)
                {
                clip_range[0]=(clip_range[0]>xlo)?clip_range[0]:xlo;
                clip_range[1]=(clip_range[1]>ylo)?clip_range[1]:ylo;
                clip_range[3]=(clip_range[3]<xhi)?clip_range[3]:xhi;
                clip_range[4]=(clip_range[4]<yhi)?clip_range[4]:yhi;
                }
            else
            if (rhl_display)
                {
                clip_range[0]=(clip_range[0]-1>xlo-1)?clip_range[0]-1:xlo-1;
                clip_range[1]=(clip_range[1]>ylo)?clip_range[1]:ylo;
                clip_range[3]=(clip_range[3]<xhi-1)?clip_range[3]:xhi-1;
                clip_range[4]=(clip_range[4]<yhi)?clip_range[4]:yhi;
                }
            }
        else
        if ((rhl_display&&shd_window&&!hwzbuf))
            {
            clip_range[0]=(clip_range[0]-1>xlo-1)?clip_range[0]-1:xlo-1;
            clip_range[1]=(clip_range[1]>ylo)?clip_range[1]:ylo;
            clip_range[3]=(clip_range[3]<xhi-1)?clip_range[3]:xhi-1;
            clip_range[4]=(clip_range[4]<yhi)?clip_range[4]:yhi;
            }
        }

    if ( ! memcmp( element_parms.ele_clip_range, clip_range, sizeof( IGRdouble ) * 6 ) )
       return;  /* clip range hasn't changed */

    memcpy( element_parms.ele_clip_range, clip_range, sizeof( IGRdouble ) * 6 );

#if defined( ENV5 )
    if ((type & HShardware_LB_GPIPE ) && 
        (!region_update || (region_update && !(rhl_display && (wire_window || shd_window)))))
        {
        GPPutViewport( 
            active_window->gpipe_id,
            element_parms.ele_clip_range[0],
            element_parms.ele_clip_range[1], 
            tiling_parms.maximum_z *
            (element_parms.ele_clip_range[2] - active_window->dit_clip_range[2]) /
            (active_window->dit_clip_range[5] - active_window->dit_clip_range[2]),
            
            element_parms.ele_clip_range[3], 
            element_parms.ele_clip_range[4], 
            tiling_parms.maximum_z *
            (element_parms.ele_clip_range[5] - active_window->dit_clip_range[2]) /
            (active_window->dit_clip_range[5] - active_window->dit_clip_range[2]) );
        }
#endif

    }

/*---HSset_element_facet_type-------------------------------------------------*/

/*
NAME
    HSset_element_facet_type
    
DESCRIPTION
    sets the facet-type-dependent values
    
PARAMETERS
    type: (IN): the element facet type
    
HISTORY
    2/28/90    M. Jablonski
        Created
*/

void HSset_element_facet_type( IGRint type )

    {
#if defined( ENV5 )
    EGRenderMethod render_method;
    EGReflEqn      reflect_eqn;
#endif

    element_parms.facet_type = type;

    element_parms.doing_vertex_normals = (element_parms.facet_type == SMOOTH_SHADE) ||
                                         (element_parms.facet_type == RENDERED);

#if defined( ENV5 )
    if (active_window->type & HShardware_LB_EG)
        {
        if ( element_parms.facet_type == AREA_FILL )
            {
            reflect_eqn = EG_REFL_NONE;
            render_method = EG_RENDER_FLAT;
            }
        else
        if ( element_parms.facet_type == CONST_SHADE )
            {
            reflect_eqn = EG_REFL_AMB_DIF;  /* no specular for constant shading */
            render_method = EG_RENDER_FLAT;
            }
        else
            {
            reflect_eqn = EG_REFL_AMB_DIF_SPEC;
            render_method = EG_RENDER_GOUR;
            }

        EGSetReflectEqn( active_window->EG_vc_no, reflect_eqn );
        EGSetRenderMethod( active_window->EG_vc_no, render_method );
        }
        
#endif

#if defined( OPENGL )
    if ( active_window->type & HShardware_LB_OPENGL )
    {
       WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
       if ( element_parms.facet_type == SMOOTH_SHADE )
       {
          glShadeModel( GL_SMOOTH );
       }
       else
       {
          glShadeModel( GL_FLAT );
       }
    }
#endif

#if defined( XGL )
        if ( active_window->type & HShardware_LB_XGL )
        {
           /* always leave lighting on and reset the shading model => */
           /* it makes the display list happy because it assumes its  */
           /* always set-up properly during updates                   */ 
/*
           glEnable( GL_LIGHTING );
*/

           if ( active_window->shading_style == HS_STYLE_SMOOTH )
           {
              xgl_object_set( active_window->xgl_context_3D,
                              XGL_3D_CTX_SURF_FRONT_ILLUMINATION,
                              XGL_ILLUM_PER_VERTEX,
                              XGL_3D_CTX_SURF_BACK_ILLUMINATION,
                              XGL_ILLUM_PER_VERTEX, NULL );
           }
           else
           {   
              xgl_object_set( active_window->xgl_context_3D,
                              XGL_3D_CTX_SURF_FRONT_ILLUMINATION,
                              XGL_ILLUM_PER_FACET,
                              XGL_3D_CTX_SURF_BACK_ILLUMINATION,
                              XGL_ILLUM_PER_FACET, NULL );
           }
        }
#endif

    }  /* HSset_element_facet_type */


/*---HSset_element_cull_flag--------------------------------------------------*/

/*
NAME
    HSset_element_cull_flag
    
DESCRIPTION
    sets the back plane cull flag for this element.

PARAMETERS
    flags: (IN): the cull flag
    
HISTORY
    02/28/90     M. Jablonski
        Created
         
    03/16/90     M. Giesy
        Edge 2 culling support
 */

void HSset_element_cull_flag( IGRint flag )

    {
#if defined( ENV5 )
    EGFaceCull    cull_mode;
#endif

    element_parms.culling_back_planes = flag;

    if (! (tiling_parms.processing_mode & HS_PMODE_FEEDBACK) )
        {
#if defined( ENV5 )
        if ( active_window->type & HShardware_LB_EG )
            {
            switch(flag)
                {
                 case HS_CULL_NONE:
                    cull_mode = EG_NO_CULL;
                    break;
                case HS_CULL_POSITIVE:
                    cull_mode = EG_FRONTFACE_CULL;
                    break;
                case HS_CULL_NEGATIVE:
                    cull_mode = EG_BACKFACE_CULL;
                    break;
                default:
                    cull_mode = EG_NO_CULL;
                    break;
                }

            EGSetFaceCullingMode( active_window->EG_vc_no, cull_mode );

            /* always flip normals of back-facing facets */
            EGSetNormReorientMode( active_window->EG_vc_no, TRUE );
            }
#endif
#if defined( OPENGL )
        if ( active_window->type & HShardware_LB_OPENGL )
            {
            /* disable culling for now => fix it later */
            WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
            glDisable( GL_CULL_FACE );
            }
#endif
        }
        
    }


/*---HSset_element_edge_marking_flag------------------------------------------*/

/*
NAME
    HSset_element_edge_marking_flag
    
DESCRIPTION
    sets the edge marking flag for this element.

PARAMETERS
    flag: (IN): the edge marking flag
    
HISTORY
    02/28/90    C. M. Jablonski
        Created
*/

void HSset_element_edge_marking_flag( IGRboolean flag )

    {
    element_parms.marking_edges = flag;
    }


/*---HSset_element_tolerances-------------------------------------------------*/

/*
NAME
    HSset_element_tolerances
    
DESCRIPTION
    sets the tolerance values for this element.

PARAMETERS
    interp_tol: (IN): 
    basis_tol : (IN):
    dis_tol   : (IN):
    
HISTORY
    02/28/90    C. M. Jablonski
        Created
        
    07/09/90    C. M. Jablonski
        Added dis_tol
*/

void HSset_element_tolerances( IGRdouble interp_tol, 
                               IGRdouble basis_tol, 
                               IGRdouble dis_tol )

    {
    element_parms.interp_tol = interp_tol;
    element_parms.basis_tol = basis_tol;
    element_parms.dis_tol = dis_tol;
    }


/*---HSset_element_geometry---------------------------------------------------*/

/*
NAME
    HSset_element_geometry
    
DESCRIPTION
    sets the element geometry (surface only).

PARAMETERS
    geo_ptr: (IN): address of surface geometry
    
HISTORY
    02/28/90    C. M. Jablonski
        Created
*/

void HSset_element_geometry( struct IGRbsp_surface *geo_ptr )


    {
    element_parms.surf_geom = geo_ptr;
    }


/*---HSset_element_rendering_parms--------------------------------------------*/

/*
NAME
    HSset_element_rendering_parms
    
DESCRIPTION
    sets the element rendering parameters structure pointer.

PARAMETERS
    p: (IN): address of the element rendering parms structure
    
HISTORY
    02/28/90    C. M. Jablonski
        Created
*/

void HSset_element_rendering_parms( struct HS_element_rendering_parms *rp )

    {
#if defined( ENV5 )
    EGObjectProp    prop;
    int             status;
#endif

    element_parms.render_parms = rp;

#if defined( ENV5 )
    if ( active_window->type & HShardware_LB_EG )
        {
        prop.ambRefl = 1.0;
        prop.diffRefl = rp->diff_refl;
        prop.specRefl = rp->spec_refl;
        prop.specColor.red = 1.0;
        prop.specColor.green = 1.0;
        prop.specColor.blue = 1.0;
        prop.specExp = (rp->finish > 32.0) ? (32.0) : ((float)rp->finish);
        prop.transCoeff = (element_parms.render_parms->transparency >= 0.5) ? 0.5 : 0.0;

        status = EGSetObjectProp( active_window->EG_vc_no, &prop );

        }
#endif

#if defined( OPENGL )
    if ( active_window->type & HShardware_LB_OPENGL )
        {
        float GLdiffuse_parms[4], GLspecular_parms[4], GLshininess;
        
        WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
        
        GLdiffuse_parms[0] = (element_parms.red / 255.0) * rp->diff_refl;
        GLdiffuse_parms[1] = (element_parms.green / 255.0) * rp->diff_refl;
        GLdiffuse_parms[2] = (element_parms.blue / 255.0) * rp->diff_refl;
        GLdiffuse_parms[3] = 1.0;
        glMaterialfv( GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, GLdiffuse_parms );

        GLspecular_parms[0] = GLspecular_parms[1] = GLspecular_parms[2] = rp->spec_refl;
        GLspecular_parms[3] = 1.0;
        glMaterialfv( GL_FRONT_AND_BACK, GL_SPECULAR, GLspecular_parms );

        GLshininess = ((float)rp->finish > 128.0) ? 128.0 : ( (float)rp->finish );
        glMaterialf( GL_FRONT_AND_BACK, GL_SHININESS, GLshininess );

        if ( element_parms.render_parms->transparency >= 0.5 )
           {
           glEnable( GL_POLYGON_STIPPLE );
           if ( tiling_parms.processing_mode & HS_PMODE_TRANS_1x1 )
              {
              glPolygonStipple( gl_narrow_trans );
              }
           else
              {
              glPolygonStipple( gl_wide_trans );
              }
           }
        else
           {
           glDisable( GL_POLYGON_STIPPLE );
           glPolygonStipple( gl_opaque );
           }
        }
#endif

#if defined (XGL)
     if ( active_window->type & HShardware_LB_XGL )
        {
        float	d, s, f;

        d = (float)( rp->diff_refl );
        s = (float)( rp->spec_refl );
        f = (float)( rp->finish/2 );
 
        xgl_object_set( active_window->xgl_context_3D,
                        XGL_3D_CTX_SURF_FRONT_DIFFUSE, d,
                        XGL_3D_CTX_SURF_BACK_DIFFUSE,  d,
                        XGL_3D_CTX_SURF_FRONT_SPECULAR, s,
                        XGL_3D_CTX_SURF_BACK_SPECULAR,  s,
                        XGL_3D_CTX_SURF_FRONT_SPECULAR_POWER, f,
                        XGL_3D_CTX_SURF_BACK_SPECULAR_POWER,  f,
                        NULL );

        if( element_parms.render_parms->transparency > 0.5 )
           {
           if ( tiling_parms.processing_mode & HS_PMODE_TRANS_1x1 )
              WLset_blendarea( active_window->win_no, xgl_narrow_trans, 0 );
           else
              WLset_blendarea( active_window->win_no, xgl_wide_trans, 0 );

           WLactivate_symbology( active_window->win_no, 1, 0 );
           }
        else
           {
           WLset_blendarea( active_window->win_no, xgl_solid_trans, 0 );
           WLactivate_symbology( active_window->win_no, 0, 0 );
           }
        }
#endif
    }

/*---HSset_element_fem_parms--------------------------------------------------*/

/*
NAME
    HSset_element_fem_parms
    
DESCRIPTION
    sets the element fem data structure pointer.

PARAMETERS
    tri: (IN): 
    v1 : (IN):
    v2 : (IN):
    v3 : (IN):
    
HISTORY
    02/28/90    C. M. Jablonski
        Created
*/

void HSset_element_fem_parms(  IGRboolean tri,
                               IGRdouble v1,
                               IGRdouble v2,
                               IGRdouble v3 )

    {
    element_parms.fem_parms.triangle = tri;
    element_parms.fem_parms.A = v1;
    element_parms.fem_parms.B = v2;
    element_parms.fem_parms.C = v3;
    }

/*--- HSreset_element_parms -----------------------------------*/

void HSreset_element_parms(
   void )

/*
NAME
   HSreset_element_parms

DESCRIPTION
   This functions resets parameters in a graphics library
   that HSURF sets on a per element basis, that could affect
   drawing outside of HSURF (i.e., hiliting, clearing windows,
   etc.)  It should be called after HSURF finishes shading an
   element.

SYNOPSIS
   void HSreset_element_parms(
      void )

PARAMETERS
   none

GLOBALS USED
   active_window

HISTORY
   08/06/93 S.P. Rogers
      Initial implementation
*/

{
#if defined( OPENGL )
   if ( active_window->type & HShardware_LB_OPENGL )
   {
      WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
      glPolygonStipple( gl_opaque );
      glDisable( GL_POLYGON_STIPPLE );
      glDisable( GL_FOG );
   }
#endif

#if defined( ENV5 )
   if ( active_window->type & HShardware_LB_EG )
   {
      EGSetDepthCueMode( active_window->EG_vc_no, EG_OFF );
   }
#endif

} /* HSreset_element_parms */
