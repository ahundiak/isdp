class implementation Root;

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/times.h>
#include <time.h>
#include "math.h"
#include "wl.h"

#if defined( ENV5 )
#include <EG.h>
#endif

#include "OMerrordef.h"
#include "OMindex.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "madef.h"

#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"

#include "gr.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"

#include "DPdlist.h"
#include "HSdlist.h"
#include "HSdl_bbs.h"


#include "dl.h"

#include "dpmacros.h"

#include "hsmacdef.h"
#include "HStl_window.h"
#include "HStl_global.h"

/* Old Prototypes */
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "hsdisplay.h"
#include "hstiler.h"
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"
#include "matrnmx.h"


/* New Prototypes */
PROTO_HSdlist_push_matrix
PROTO_HSdlist_pop_matrix
PROTO_DPdlist_get_transform_buffer
PROTO_DPdlist_transform_points
PROTO_DPdlist_hash_lookup
PROTO_DPdlist_alloc_chunk
PROTO_HSdlist_display_element
PROTO_HSdlist_display_element_update
PROTO_HSdlist_display_point
PROTO_HSdlist_display_point_update
PROTO_HSdlist_display_polygon
PROTO_HSdlist_display_polygon_update
PROTO_HSdlist_display_curve
PROTO_HSdlist_display_curve_update
PROTO_HSdlist_display_text
PROTO_HSdlist_display_text_update
PROTO_HSdlist_display_surface
PROTO_HSdlist_display_surface_update
PROTO_DPdlist_display_unknown
PROTO_DPdlist_set_shading_display_function
PROTO_HSdlist_start_window_update
PROTO_HSdlist_finish_window_update

/* Functions required for Bucket Batching. */
PROTO_HSdlist_enter_bbs
PROTO_HSdlist_exit_bbs
PROTO_HSdlist_add_surface_to_bbs

#if defined(XGL)
PROTO_HSdlist_xgl_set_display_attributes
PROTO_HSdlist_xgl_display_surface
#endif


extern struct GRid DPdlist_sh_fb_gragad;
extern IGRboolean DPdlist_display_tangent_edges;
extern IGRboolean DPdlist_ignore_graloops;
extern IGRboolean DPdlist_ignore_SOs;
extern IGRboolean DPdynamic_update_in_progress;
extern IGRboolean DPdlist_performance_boost;

from GRgraphics import GRdisyourself;
from GRgraphics import GRadd_to_display_list;

/* Elements w/ these flags set are currently */
/* not supported in the display list         */
#define UNSUPPORTED_FLAGS (DP_DLIST_ELE_VIEW_IND|DP_DLIST_ELE_SCALE_IND)

#define GET_COLOR( lcolor )                       \
   ige$get_rgb_value( log_color = lcolor,         \
                      rgb_value = &rgb_color,     \
                      flags = STRUCTURE_COLORS ); \
                                                  \
   red = rgb_color.red * ONE_OVER_65535;          \
   green = rgb_color.green * ONE_OVER_65535;      \
   blue = rgb_color.blue * ONE_OVER_65535;        \


%safe
#if defined( ENV5 )
static EGPolyLine3Info EGpolygon = { EG_ON,              /* closed */
                                     0,                  /* numVerts */
                                     NULL,               /* verts */
                                     sizeof( EGPoint3 )  /* vertOffset */
                                   };

static EGPolyLine3Info EGline_string = { EG_OFF,             /* closed */
                                         0,                  /* numVerts */
                                         NULL,               /* verts */
                                         sizeof( EGPoint3 )  /* vertOffset */
                                       };

static EGObjectProp EGprop = { 1.0,   /* ambRefl */
                               1.0,   /* diffRefl */
                               0.0,   /* specRefl */
                               { 1.0, /* specColor.red */
                                 1.0, /* specColor.green */
                                 1.0, /* specColor.blue */
                               },
                               0.0,   /* specExp */
                               0.0,   /* transCoeff */                             
                             };

static EGTriMeshData3Info EGmesh = { 0,                  /* numVerts */
                                     NULL,               /* verts */
                                     sizeof( EGPoint3 ), /* vertOffset */
                                     NULL,               /* vColors */
                                     0,                  /* vColorOffset */
                                     NULL,               /* vNorms */
                                     sizeof( EGPoint3 ), /* VNormOffset */
                                     NULL,               /* fColors */
                                     0,                  /* fColorOffset */
                                     NULL,               /* fNorms */
                                     sizeof( EGPoint3 )  /* fNormOffset */
                                   };
#endif

static struct IGEvlt rgb_color;
static IGRlong static_msg;
static IGRshort static_four = 4;

%endsafe

#define ONE_OVER_65535 (float)(1.0 / 65535.0)

#define SETUP_FOR_SINGLE_DISPLAY \
   DLget_modelling_matrix( dp_info->gragad->gpipe_id, old_mod_matrix ); \
   MAtrnmx( &static_msg, &static_four, matrix, new_mod_matrix ); \
   DLset_modelling_matrix( dp_info->gragad->gpipe_id, new_mod_matrix ); \

#define RESTORE_FROM_SINGLE_DISPLAY \
   DLset_modelling_matrix( dp_info->gragad->gpipe_id, old_mod_matrix ); \

#if defined( OPENGL )
%safe
static float GLmaterial[4] = {1.0, 1.0, 1.0, 1.0};

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


%endsafe
#define SEND_VERTS_TO_OPENGL( numverts, verts ) \
                                                \
   switch( (numverts) % 4 )                     \
   {                                            \
      case 1:                                   \
         glVertex3fv( (verts) );                \
         (verts) += 3;                          \
         (numverts) -= 1;                       \
         break;                                 \
      case 2:                                   \
         glVertex3fv( (verts) );                \
         glVertex3fv( (verts) + 3 );            \
         (verts) += 6;                          \
         (numverts) -= 2;                       \
         break;                                 \
      case 3:                                   \
         glVertex3fv( (verts) );                \
         glVertex3fv( (verts) + 3 );            \
         glVertex3fv( (verts) + 6 );            \
         (verts) += 9;                          \
         (numverts) -= 3;                       \
         break;                                 \
   }                                            \
                                                \
   while ( (numverts) > 0 )                     \
   {                                            \
      glVertex3fv( (verts) );                   \
      glVertex3fv( (verts) + 3 );               \
      glVertex3fv( (verts) + 6 );               \
      glVertex3fv( (verts) + 9 );               \
      (verts) += 12;                            \
      (numverts) -= 4;                          \
   }

#define SEND_VERTS_AND_NORMALS_TO_OPENGL( numverts, verts, norms ) \
                                                                   \
   switch( (numverts) % 4 )                                        \
   {                                                               \
      case 1:                                                      \
         glNormal3fv( (norms) );                                   \
         glVertex3fv( (verts) );                                   \
         (norms) += 3;                                             \
         (verts) += 3;                                             \
         (numverts) -= 1;                                          \
         break;                                                    \
      case 2:                                                      \
         glNormal3fv( (norms) );                                   \
         glVertex3fv( (verts) );                                   \
         glNormal3fv( (norms) + 3 );                               \
         glVertex3fv( (verts) + 3 );                               \
         (norms) += 6;                                             \
         (verts) += 6;                                             \
         (numverts) -= 2;                                          \
         break;                                                    \
      case 3:                                                      \
         glNormal3fv( (norms) );                                   \
         glVertex3fv( (verts) );                                   \
         glNormal3fv( (norms) + 3 );                               \
         glVertex3fv( (verts) + 3 );                               \
         glNormal3fv( (norms) + 6 );                               \
         glVertex3fv( (verts) + 6 );                               \
         (norms) += 9;                                             \
         (verts) += 9;                                             \
         (numverts) -= 3;                                          \
         break;                                                    \
   }                                                               \
                                                                   \
   while ( (numverts) > 0 )                                        \
   {                                                               \
      glNormal3fv( (norms) );                                      \
      glVertex3fv( (verts) );                                      \
      glNormal3fv( (norms) + 3 );                                  \
      glVertex3fv( (verts) + 3 );                                  \
      glNormal3fv( (norms) + 6 );                                  \
      glVertex3fv( (verts) + 6 );                                  \
      glNormal3fv( (norms) + 9 );                                  \
      glVertex3fv( (verts) + 9 );                                  \
      (norms) += 12;                                               \
      (verts) += 12;                                               \
      (numverts) -= 4;                                             \
   }


#endif

static WLuint32 context_no;

static int (*color_to_index)(
   WLuint32 context_no,
   WLuint32 index,
   WLuint32 red,
   WLuint32 green,
   WLuint32 blue,
   WLuint32 flag,
   WLuint32 *phy_index );

static int (*color_to_rgb)(
   WLuint32 context_no,
   WLuint32 index,
   WLuint32 red,
   WLuint32 green,
   WLuint32 blue,
   WLuint32 flag,
   WLuint32 *out_red,
   WLuint32 *out_green,
   WLuint32 *out_blue );
					     
static int (*cmap_init)(
   WLuint32 context_no );


#define GET_LOG_COLOR( alt_symb, ele_color, log_color ) \
                                                        \
   if ( (alt_symb) )                                    \
   {                                                    \
      if ( (alt_symb)->color )                          \
      {                                                 \
         (log_color) = *(alt_symb)->color;              \
      }                                                 \
      else                                              \
      {                                                 \
         (log_color) = (ele_color);                     \
      }                                                 \
   }                                                    \
   else                                                 \
   {                                                    \
      (log_color) = (ele_color);                        \
   }                                                    \

#define GET_COLOR( lcolor )                       \
   ige$get_rgb_value( log_color = lcolor,         \
                      rgb_value = &rgb_color,     \
                      flags = STRUCTURE_COLORS ); \
                                                  \
   red = rgb_color.red * ONE_OVER_65535;          \
   green = rgb_color.green * ONE_OVER_65535;      \
   blue = rgb_color.blue * ONE_OVER_65535;        \

#define GET_COLOR_UPDATE( lcolor )                           \
   {                                                         \
   WLuint32 temp_red, temp_green, temp_blue;                 \
   (*color_to_rgb)( context_no, lcolor, 0, 0, 0,             \
                    0, &temp_red, &temp_green, &temp_blue ); \
                                                             \
   red = temp_red * ONE_OVER_65535;                          \
   green = temp_green * ONE_OVER_65535;                      \
   blue = temp_blue * ONE_OVER_65535;                        \
   }

/* 
   Define this if u need to find out user time between
   HSdlist_start_window_update() and HSdlist_finish_window_update()
*/
#define	TIMING_ON		1

%safe

#if defined(TIMING_ON)

/*
	Use global variable 'HSdlist_print_times' to toggle the
	timing mechanism between ON and OFF.
*/
unsigned long    HSdlist_print_times=0;
static unsigned long	start_time=0,finish_time=0;
static struct	tms	buf;
#endif

#if defined(XGL) || defined(OPENGL)

/* 
 *	Bucket Batching code will come into effect 
 *	only if HS_BBS is defined. 
 */
/* TURN OFF BUCKET BATCHING FOR NOW, UNTIL DISPLAY PROBLEMS IN CODE ARE WORKED
   OUT.
#define		HS_BBS			1
*/
#endif


#if defined(XGL)

/*
 *	HSdlist_first_setting bit is used to implement 
 *	'lazy symbology setting'.
 */
unsigned int	HSdlist_first_setting=1;
#endif


#if defined(HS_BBS)
/*
 * 	Use 'HSdlist_use_bbs' bit to switch ON/OFF Bucket Batching.
 */
unsigned int HSdlist_use_bbs=1;
#endif



#if defined(XGL)
struct HSdlist_xgl_surf_attributes {
        Xgl_surf_illumination   illumination;
        float                   diff_refl, spec_refl,
				finish, trans,
				red,green,blue;
};

/*
 *	The following structure holds the symbology values 
 *	required for 'lazy symbology setting' implementation.
 */
static struct HSdlist_xgl_surf_attributes 	old_attributes;

#endif

%endsafe

/*--- HSdlist_display_point -----------------------------------------------*/

int HSdlist_display_point(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   HSdlist_display_point

DESCRIPTION
   This function displays a point from the display list.

SYNOPSIS
   int HSdlist_display_point(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type )

PARAMETERS
   fixed (IN) - the fixed data for the point
   osnum (IN) - the object space number of the point
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_symb (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 S.P. Rogers
      Initial implementation
  
   21-Mar-94	sash	Added ENV5 code.

   15-Apr-94	sash	Added XGL  code.
*/


{
   IGRshort log_color;
   float *point;
   float red, green, blue;
   IGRdouble old_mod_matrix[16], new_mod_matrix[16];

#if defined( ENV5 )

   short		ii;

   float		points[12];

   EGPolyLine3Info eg_poly_line = { EG_ON,              /* closed */
                                  4,                  /* numVerts */
                                  NULL,    	   /* verts */
                                  sizeof(EGPoint3)    /* vertOffset */
                                };
   EGRGBColor EGcolor;

#endif

#if defined(XGL)
	Xgl_color      	xgl_color;
	Xgl_pt_list	point_list[1];
#endif


   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   DLIST_PNT_POINT_PTR( fixed->wf_data, point );

   GET_LOG_COLOR( alt_symb, fixed->color, log_color );

   if ( dp_mode == GRbd )
   {
      GET_COLOR( log_color );
      WLset_drawing_mode( active_window->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );
   }
   else
   {
      GET_COLOR( IGE_LOGICAL_BACKGROUND );
      WLset_drawing_mode( active_window->win_no, WL_BASE_ERASE | WL_HILITE_NOOP );
   }

   SETUP_FOR_SINGLE_DISPLAY;


#if defined( ENV5 )

   for(ii=0;ii<3;ii++)
	points[ii] 	= 
	points[ii+3] 	= 
	points[ii+6] 	= 
	points[ii+9] 	= point[ii];
	
   eg_poly_line.verts	= (EGPoint3 *)points;

   EGcolor.red 		= red;
   EGcolor.green 	= green;
   EGcolor.blue 	= blue;

   EGSetBaseColor( active_window->EG_vc_no, &EGcolor );
   EGPolyLine3( active_window->EG_vc_no, &eg_poly_line );

#endif

#if defined( OPENGL )
   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
   glColor3f( red, green, blue );
   glDisable( GL_LIGHTING );
   glBegin( GL_POINTS );
   glVertex3fv( point );
   glEnd();
   glEnable( GL_LIGHTING );
#endif

#if defined(XGL)

	HS_XGL_SET_RGB_COLOR (xgl_color, red, green, blue);

	xgl_object_set (active_window->xgl_context_3D,
			XGL_CTX_MARKER_COLOR, 		&xgl_color, 
			XGL_CTX_MARKER, 		xgl_marker_square, 
			XGL_CTX_MARKER_COLOR_SELECTOR,XGL_MARKER_COLOR_CONTEXT,
			NULL);

	HS_XGL_SET_PT_LIST_F3D(point_list[0], 1, point);

	/* Draw a marker at given point. */
	xgl_multimarker(active_window->xgl_context_3D, point_list);

#endif

   RESTORE_FROM_SINGLE_DISPLAY;

   return( DLIST_S_SUCCESS );

} /* HSdlist_display_point */

/*--- HSdlist_display_point_update -----------------------------------------------*/

int HSdlist_display_point_update(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   HSdlist_display_point_update

DESCRIPTION
   This function displays a point from the display list assuming that
   a window update is progress.

SYNOPSIS
   int HSdlist_display_point_update(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type )

PARAMETERS
   fixed (IN) - the fixed data for the point
   osnum (IN) - the object space number of the point
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_symb (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 S.P. Rogers
      Initial implementation

   21-Mar-94	sash	Added ENV5 code.
   15-Apr-94	sash	Added XGL  code.
*/


{
   IGRshort log_color;
   float *point;
   float red, green, blue;

#if defined( ENV5 )
   short		ii;
   float		points[12];
   EGPolyLine3Info eg_poly_line = { EG_ON,              /* closed */
                                  4,                  /* numVerts */
                                  NULL,    	   /* verts */
                                  sizeof(EGPoint3)    /* vertOffset */
                                };
   EGRGBColor EGcolor;
#endif

#if defined(XGL)
	Xgl_color      	xgl_color;
	Xgl_pt_list	point_list[1];
#endif

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   DLIST_PNT_POINT_PTR( fixed->wf_data, point );

   GET_LOG_COLOR( alt_symb, fixed->color, log_color );

   GET_COLOR_UPDATE( log_color );

#if defined( ENV5 )

   for(ii=0;ii<3;ii++)
	points[ii] 	= 
	points[ii+3] 	= 
	points[ii+6] 	= 
	points[ii+9] 	= point[ii];
	
   eg_poly_line.verts	= (EGPoint3 *)points;	

   EGcolor.red 		= red;
   EGcolor.green 	= green;
   EGcolor.blue 	= blue;

   EGSetBaseColor( active_window->EG_vc_no, &EGcolor );
   EGPolyLine3( active_window->EG_vc_no, &eg_poly_line );

#endif

#if defined( OPENGL )
   glColor3f( red, green, blue );
   glDisable( GL_LIGHTING );
   glBegin( GL_POINTS );
   glVertex3fv( point );
   glEnd();
   glEnable( GL_LIGHTING );
#endif

#if defined(XGL)

	HS_XGL_SET_RGB_COLOR (xgl_color, red, green, blue);

	xgl_object_set (active_window->xgl_context_3D, 
			XGL_CTX_MARKER_COLOR, 		&xgl_color, 
			XGL_CTX_MARKER, 		xgl_marker_square, 
			XGL_CTX_MARKER_COLOR_SELECTOR,XGL_MARKER_COLOR_CONTEXT,
			NULL);

	HS_XGL_SET_PT_LIST_F3D(point_list[0], 1, point);

	/* Draw a marker at given point. */
	xgl_multimarker(active_window->xgl_context_3D, point_list);
#endif

   return( DLIST_S_SUCCESS );

} /* HSdlist_display_point_update */

/*--- HSdlist_display_polygon -----------------------------------------------*/

int HSdlist_display_polygon(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   HSdlist_display_polygon

DESCRIPTION
   This function displays a polygon from the display list.

SYNOPSIS
   int HSdlist_display_polygon(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type )

PARAMETERS
   fixed (IN) - the fixed data for the polygon
   osnum (IN) - the object space number of the polygon
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_symb (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 S.P. Rogers
      Initial implementation

   15-Apr-94	sash	Added XGL  code.
*/


{
   unsigned int *num_points;
   float *points;
   float red, green, blue;
   IGRshort log_color;

#  if defined (XGL)
   int		weight, style;
#  endif

#if defined( ENV5 )
   EGRGBColor EGcolor;
#endif

#if defined( OPENGL )
   int gl_num_points;
#endif

#if defined(XGL)
	Xgl_color      	xgl_color;
	Xgl_pt_list	pt_list[1];
#endif


   IGRdouble old_mod_matrix[16], new_mod_matrix[16];

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   DLIST_PLY_NUM_POINTS_PTR( fixed->wf_data, num_points );
   DLIST_PLY_POINTS_PTR( fixed->wf_data, points );

   GET_LOG_COLOR( alt_symb, fixed->color, log_color );

   if ( dp_mode == GRbd )
   {
      GET_COLOR( log_color );
      WLset_drawing_mode( active_window->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );
   }
   else
   {
      GET_COLOR( IGE_LOGICAL_BACKGROUND );
      WLset_drawing_mode( active_window->win_no, WL_BASE_ERASE | WL_HILITE_NOOP );
   }

#  if defined (XGL)
   if( alt_symb )
      {
      weight = (alt_symb->weight) ? *alt_symb->weight : fixed->weight;
      style = (alt_symb->style) ? *alt_symb->style : fixed->style;
      }
   else
      {
      weight = fixed->weight;
      style = fixed->style;
      }

   WLset_active_symbology( active_window->win_no,
                           0,
                           style,
                           0xffffffff,
                           weight,
                           WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );

   WLactivate_symbology( active_window->win_no, FALSE, TRUE );
#  endif /* XGL */


   SETUP_FOR_SINGLE_DISPLAY;

#if defined( ENV5 )
   EGcolor.red = red;
   EGcolor.green = green;
   EGcolor.blue = blue;
   EGSetBaseColor( active_window->EG_vc_no, &EGcolor );
   EGpolygon.numVerts = *num_points;
   EGpolygon.verts = (EGPoint3 *) points;
   EGPolyLine3( active_window->EG_vc_no, &EGpolygon );
#endif

#if defined( OPENGL )
   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
   glColor3f( red, green, blue );
   glDisable( GL_LIGHTING );
   gl_num_points = *num_points;
   glBegin( GL_LINE_LOOP );
   SEND_VERTS_TO_OPENGL( gl_num_points, points );
   glEnd();
   glEnable( GL_LIGHTING );
#endif

#if defined ( XGL )

	HS_XGL_SET_RGB_COLOR (xgl_color, red, green, blue);

        xgl_object_set(	active_window->xgl_context_3D,
		    	XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
		    	NULL);

	HS_XGL_SET_PT_LIST_F3D(pt_list[0], *num_points, points);

	xgl_multi_simple_polygon(active_window->xgl_context_3D, 
			  XGL_FACET_FLAG_SIDES_UNSPECIFIED,
			  NULL,		/* Facet info. */
			  NULL,		/* BBOX info. */
			  1, 		/* Num. of point lists */
			  pt_list);

#endif

   RESTORE_FROM_SINGLE_DISPLAY;

   return( DLIST_S_SUCCESS );
} /* HSdlist_display_polygon */


/*--- HSdlist_display_polygon_update -----------------------------------------------*/

int HSdlist_display_polygon_update(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   HSdlist_display_polygon_update

DESCRIPTION
   This function displays a polygon from the display list assuming that
   a window update is in progress.

SYNOPSIS
   int HSdlist_display_polygon_update(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type )

PARAMETERS
   fixed (IN) - the fixed data for the polygon
   osnum (IN) - the object space number of the polygon
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_symb (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 S.P. Rogers
      Initial implementation
 
   15-Apr-94	sash	Added XGL  code.
*/


{
   unsigned int *num_points;
   float *points;
   IGRshort log_color;
   float red, green, blue;

#  if defined (XGL)
   int		style, weight;
#  endif

#if defined( ENV5 )
   EGRGBColor EGcolor;
#endif

#if defined( OPENGL )
   int gl_num_points;
#endif

#if defined(XGL)
	Xgl_color      	xgl_color;
	Xgl_pt_list	pt_list[1];
#endif

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   DLIST_PLY_NUM_POINTS_PTR( fixed->wf_data, num_points );
   DLIST_PLY_POINTS_PTR( fixed->wf_data, points );

   GET_LOG_COLOR( alt_symb, fixed->color, log_color );

   GET_COLOR_UPDATE( log_color );

#  if defined (XGL)
   if( alt_symb )
      {
      weight = (alt_symb->weight) ? *alt_symb->weight : fixed->weight;
      style = (alt_symb->style) ? *alt_symb->style : fixed->style;
      }
   else
      {
      weight = fixed->weight;
      style = fixed->style;
      }

   WLset_active_symbology( active_window->win_no,
                           0,
                           style,
                           0xffffffff,
                           weight,
                           WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );

   WLactivate_symbology( active_window->win_no, FALSE, TRUE );
#  endif /* XGL */


#if defined( ENV5 )
   EGcolor.red = red;
   EGcolor.green = green;
   EGcolor.blue = blue;
   EGSetBaseColor( active_window->EG_vc_no, &EGcolor );
   EGpolygon.numVerts = *num_points;
   EGpolygon.verts = (EGPoint3 *) points;
   EGPolyLine3( active_window->EG_vc_no, &EGpolygon );
#endif

#if defined( OPENGL )
   glColor3f( red, green, blue );
   glDisable( GL_LIGHTING );
   gl_num_points = *num_points;
   glBegin( GL_LINE_LOOP );
   SEND_VERTS_TO_OPENGL( gl_num_points, points );
   glEnd();
   glEnable( GL_LIGHTING );
#endif

#if defined ( XGL )

	HS_XGL_SET_RGB_COLOR (xgl_color, red, green, blue);

        xgl_object_set(	active_window->xgl_context_3D,
		    	XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
		    	NULL);

	HS_XGL_SET_PT_LIST_F3D(pt_list[0], *num_points, points);

	xgl_multi_simple_polygon(active_window->xgl_context_3D, 
			  XGL_FACET_FLAG_SIDES_UNSPECIFIED,
			  NULL,		/* Facet info. */
			  NULL,		/* BBOX info. */
			  1, 		/* Num. of point lists */
			  pt_list);
#endif

   return( DLIST_S_SUCCESS );
} /* HSdlist_display_polygon_update */


/*--- HSdlist_display_curve -----------------------------------------------*/

int HSdlist_display_curve(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   HSdlist_display_curve

DESCRIPTION
   This function displays a curve from the display list.

SYNOPSIS
   int HSdlist_display_curve(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type )

PARAMETERS
   fixed (IN) - the fixed data for the curve
   osnum (IN) - the object space number of the curve
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_symb (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 S.P. Rogers
      Initial implementation

   15-Apr-94	sash	Added XGL  code.
*/


{
   unsigned int *num_points;
   float *points;
   IGRshort log_color;
   float red, green, blue;

#  if defined (XGL)
   int		weight, style;
#  endif

#if defined( ENV5 )
   EGRGBColor EGcolor;
#endif

#if defined( OPENGL )
   int gl_num_points;
#endif

#if defined(XGL)
	Xgl_color		xgl_color;
	Xgl_pt_list		pt_list[1];
#endif


   IGRdouble old_mod_matrix[16], new_mod_matrix[16];

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   DLIST_CRV_NUM_POINTS_PTR( fixed->wf_data, num_points );
   DLIST_CRV_POINTS_PTR( fixed->wf_data, points );

   GET_LOG_COLOR( alt_symb, fixed->color, log_color );

   if ( dp_mode == GRbd )
   {
      GET_COLOR( log_color );
      WLset_drawing_mode( active_window->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );
   }
   else
   {
      GET_COLOR( IGE_LOGICAL_BACKGROUND );
      WLset_drawing_mode( active_window->win_no, WL_BASE_ERASE | WL_HILITE_NOOP );
   }

#  if defined (XGL)
   if( alt_symb )
      {
      weight = (alt_symb->weight) ? *alt_symb->weight : fixed->weight;
      style = (alt_symb->style) ? *alt_symb->style : fixed->style;
      }
   else
      {
      weight = fixed->weight;
      style = fixed->style;
      }

   WLset_active_symbology( active_window->win_no,
                           0,
                           style,
                           0xffffffff,
                           weight,
                           WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );

   WLactivate_symbology( active_window->win_no, FALSE, TRUE );
#  endif /* XGL */


   SETUP_FOR_SINGLE_DISPLAY;

#if defined( ENV5 )
   EGcolor.red = red;
   EGcolor.green = green;
   EGcolor.blue = blue;
   EGSetBaseColor( active_window->EG_vc_no, &EGcolor );
   if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
   {
      EGpolygon.numVerts = *num_points;
      EGpolygon.verts = (EGPoint3 *) points;
      EGPolyLine3( active_window->EG_vc_no, &EGpolygon );
   }
   else
   {
      EGline_string.numVerts = *num_points;
      EGline_string.verts = (EGPoint3 *) points;
      EGPolyLine3( active_window->EG_vc_no, &EGline_string );
   }
#endif

#if defined( OPENGL )
   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
   glColor3f( red, green, blue );
   glDisable( GL_LIGHTING );
   gl_num_points = *num_points;
   if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
   {
      glBegin( GL_LINE_LOOP );
   }
   else
   {
      glBegin( GL_LINE_STRIP );
   }

   SEND_VERTS_TO_OPENGL( gl_num_points, points );
   glEnd();

   glEnable( GL_LIGHTING );
#endif

#if defined (XGL)

        xgl_color.rgb.r = red;
        xgl_color.rgb.g = green;
        xgl_color.rgb.b = blue;

        xgl_object_set(	active_window->xgl_context_3D,
		    	XGL_CTX_LINE_COLOR, &xgl_color,
		    	NULL);

	HS_XGL_SET_PT_LIST_F3D(pt_list[0], *num_points, points);


			
	if ( fixed->ele_flags & DP_DLIST_ELE_FILLED ){
     		xgl_multi_simple_polygon(active_window->xgl_context_3D,
					 XGL_FACET_FLAG_SIDES_UNSPECIFIED,
					 NULL,	/* Facet info. */
					 NULL,  /* bbox info.  */
					 1,
					 pt_list);
   	} else {
		xgl_multipolyline(active_window->xgl_context_3D,
				  NULL,		/* bbox	*/
				  1,		/* num pt lists */
				  pt_list);
   	}

#endif

   RESTORE_FROM_SINGLE_DISPLAY;

   return( DLIST_S_SUCCESS );
} /* HSdlist_display_curve */

/*--- HSdlist_display_curve_update -----------------------------------------------*/

int HSdlist_display_curve_update(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   HSdlist_display_curve_update

DESCRIPTION
   This function displays a curve from the display list assuming that
   a window update is in progress.

SYNOPSIS
   int HSdlist_display_curve_update(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type )

PARAMETERS
   fixed (IN) - the fixed data for the curve
   osnum (IN) - the object space number of the curve
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_symb (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 S.P. Rogers
      Initial implementation

   15-Apr-94	sash	Added XGL  code.
*/


{
   unsigned int *num_points;
   float *points;
   IGRshort log_color;
   float red, green, blue;

#  if defined (XGL)
   int		style, weight;
#  endif

#if defined( ENV5 )
   EGRGBColor EGcolor;
#endif
#if defined( OPENGL )
   int gl_num_points;
#endif

#if defined(XGL)
	Xgl_color		xgl_color;
	Xgl_pt_list		pt_list[1];
#endif

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   DLIST_CRV_NUM_POINTS_PTR( fixed->wf_data, num_points );
   DLIST_CRV_POINTS_PTR( fixed->wf_data, points );

   GET_LOG_COLOR( alt_symb, fixed->color, log_color );

   GET_COLOR_UPDATE( log_color );

#  if defined (XGL)
   if( alt_symb )
      {
      weight = (alt_symb->weight) ? *alt_symb->weight : fixed->weight;
      style = (alt_symb->style) ? *alt_symb->style : fixed->style;
      }
   else
      {
      weight = fixed->weight;
      style = fixed->style;
      }

   WLset_active_symbology( active_window->win_no,
                           0,
                           style,
                           0xffffffff,
                           weight,
                           WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );

   WLactivate_symbology( active_window->win_no, FALSE, TRUE );
#  endif /* XGL */

#if defined( ENV5 )
   EGcolor.red = red;
   EGcolor.green = green;
   EGcolor.blue = blue;
   EGSetBaseColor( active_window->EG_vc_no, &EGcolor );
   if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
   {
      EGpolygon.numVerts = *num_points;
      EGpolygon.verts = (EGPoint3 *) points;
      EGPolyLine3( active_window->EG_vc_no, &EGpolygon );
   }
   else
   {
      EGline_string.numVerts = *num_points;
      EGline_string.verts = (EGPoint3 *) points;
      EGPolyLine3( active_window->EG_vc_no, &EGline_string );
   }
#endif

#if defined( OPENGL )
   glColor3f( red, green, blue );
   glDisable( GL_LIGHTING );
   gl_num_points = *num_points;
   if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
   {
      glBegin( GL_LINE_LOOP );
   }
   else
   {
      glBegin( GL_LINE_STRIP );
   }

   SEND_VERTS_TO_OPENGL( gl_num_points, points );
   glEnd();
   glEnable( GL_LIGHTING );
#endif

#if defined (XGL)

        xgl_color.rgb.r = red;
        xgl_color.rgb.g = green;
        xgl_color.rgb.b = blue;

        xgl_object_set(	active_window->xgl_context_3D,
		    	XGL_CTX_LINE_COLOR, &xgl_color,
		    	NULL);

	HS_XGL_SET_PT_LIST_F3D(pt_list[0], *num_points, points);

	if ( fixed->ele_flags & DP_DLIST_ELE_FILLED ){
     		xgl_multi_simple_polygon(active_window->xgl_context_3D,
					 XGL_FACET_FLAG_SIDES_UNSPECIFIED,
					 NULL,	/* facets, */
					 NULL,	/* bbox,   */
					 1,
					 pt_list);
   	} else {
		xgl_multipolyline(active_window->xgl_context_3D,
				  NULL,		/* bbox	*/
				  1,		/* num pt lists */
				  pt_list);
   	}

#endif

   return( DLIST_S_SUCCESS );
} /* HSdlist_display_curve_update */

/*--- HSdlist_display_text -------------------------------------------------*/

int HSdlist_display_text(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   HSdlist_display_text

DESCRIPTION
   This function displays a text element from the display list.

SYNOPSIS
   int HSdlist_display_text(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type )

PARAMETERS
   fixed (IN) - the fixed data for the text
   osnum (IN) - the object space number of the text
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_symb (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 S.P. Rogers
      Initial implementation

   15-Apr-94	sash	Added XGL  code.
*/


{
   int ii;
   unsigned int *num_polys;
   unsigned int *num_lines;
   void **polys;
   void **lines;
   unsigned int *num_points;
   float *points;
   IGRshort log_color;
   float red, green, blue;

#  if defined (XGL)
   int		weight, style;
#  endif

#if defined( ENV5 )
   EGRGBColor EGcolor;
#endif
#if defined( OPENGL )
   int gl_num_points;
#endif

#if defined (XGL)
	int			sts;
	void			*chunk=NULL;
	unsigned long		byte_size=0;
	Xgl_pt_list		*pt_lists=NULL;
	Xgl_color		xgl_color;
#endif

   IGRdouble old_mod_matrix[16], new_mod_matrix[16];

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   GET_LOG_COLOR( alt_symb, fixed->color, log_color );

   if ( dp_mode == GRbd )
   {
      GET_COLOR( log_color );
      WLset_drawing_mode( active_window->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );
   }
   else
   {
      GET_COLOR( IGE_LOGICAL_BACKGROUND );
      WLset_drawing_mode( active_window->win_no, WL_BASE_ERASE | WL_HILITE_NOOP );
   }

#  if defined (XGL)
   if( alt_symb )
      {
      weight = (alt_symb->weight) ? *alt_symb->weight : fixed->weight;
      style = (alt_symb->style) ? *alt_symb->style : fixed->style;
      }
   else
      {
      weight = fixed->weight;
      style = fixed->style;
      }

   WLset_active_symbology( active_window->win_no,
                           0,
                           style,
                           0xffffffff,
                           weight,
                           WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );

   WLactivate_symbology( active_window->win_no, FALSE, TRUE );
#  endif /* XGL */

   SETUP_FOR_SINGLE_DISPLAY;

#if defined( ENV5 )
   EGcolor.red = red;
   EGcolor.green = green;
   EGcolor.blue = blue;
   EGSetBaseColor( active_window->EG_vc_no, &EGcolor );
#endif

#if defined( OPENGL )
   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
   glColor3f( red, green, blue );
   glDisable( GL_LIGHTING );
#endif

#if defined (XGL)
	HS_XGL_SET_RGB_COLOR (xgl_color, red, green, blue);
        xgl_object_set(	active_window->xgl_context_3D,
		    	XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
		    	NULL);
#endif

   if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
   {
      DLIST_FTXT_NUM_POLYS_PTR( fixed->wf_data, num_polys );
      DLIST_FTXT_POLYS_PTR( fixed->wf_data, polys );

#if defined (XGL)

      byte_size = *num_polys*sizeof(Xgl_pt_list);
      sts = DPdlist_alloc_chunk( byte_size, &chunk );
      if ( !(1 & sts) )
      {
          return( DLIST_E_ERROR );
      }
      pt_lists = (Xgl_pt_list *) chunk;

#endif
      /* display each polygon individuallly */
      for ( ii = 0; ii < *num_polys; ii++ )
      {
         DLIST_PLY_NUM_POINTS_PTR( polys[ii], num_points );
         DLIST_PLY_POINTS_PTR( polys[ii], points );

#if defined( ENV5 )
         EGpolygon.numVerts = *num_points;
         EGpolygon.verts = (EGPoint3 *) points;
         EGPolyLine3( active_window->EG_vc_no, &EGpolygon );
#endif

#if defined( OPENGL )
         gl_num_points = *num_points;
         glBegin( GL_LINE_LOOP );
         SEND_VERTS_TO_OPENGL( gl_num_points, points );
         glEnd();
#endif

#if defined (XGL)
	HS_XGL_SET_PT_LIST_F3D(pt_lists[ii], *num_points, points);
#endif
      } /* end: for */

   }
   else
   {
      DLIST_TXT_NUM_LINES_PTR( fixed->wf_data, num_lines );
      DLIST_TXT_LINES_PTR( fixed->wf_data, lines );

#if defined (XGL)
      byte_size = *num_lines*sizeof(Xgl_pt_list);
      sts = DPdlist_alloc_chunk( byte_size, &chunk );
      if ( !(1 & sts) )
      {
          return( DLIST_E_ERROR );
      }
      pt_lists = (Xgl_pt_list *) chunk;

#endif

      /* display each line string individuallly */
      for ( ii = 0; ii < *num_lines; ii++ )
      {
         DLIST_CRV_NUM_POINTS_PTR( lines[ii], num_points );
         DLIST_CRV_POINTS_PTR( lines[ii], points );

#if defined( ENV5 )
         EGline_string.numVerts = *num_points;
         EGline_string.verts = (EGPoint3 *) points;
         EGPolyLine3( active_window->EG_vc_no, &EGline_string );
#endif

#if defined( OPENGL )
         gl_num_points = *num_points;
         glBegin( GL_LINE_STRIP );
         SEND_VERTS_TO_OPENGL( gl_num_points, points );
         glEnd();
#endif

#if defined (XGL)
	HS_XGL_SET_PT_LIST_F3D(pt_lists[ii], *num_points, points);
#endif

      } /* end: for */

   }

#if defined( OPENGL )
   glEnable( GL_LIGHTING );
#endif

#if defined (XGL)

	if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
	{
		/* Closed curve */
     		xgl_multi_simple_polygon(active_window->xgl_context_3D,
					 XGL_FACET_FLAG_SIDES_UNSPECIFIED,
					 NULL,		/* facets */
					 NULL,		/* bbox   */
					 *num_polys,
					 pt_lists);
   	} else {
		/* Open curve */
		xgl_multipolyline(active_window->xgl_context_3D,
				  NULL,	       /* bbox   */
				  *num_lines,
				  pt_lists);

   	}

      DPdlist_free_chunk( byte_size, chunk );

#endif

   RESTORE_FROM_SINGLE_DISPLAY;

   return( DLIST_S_SUCCESS );

} /* HSdlist_display_text */

/*--- HSdlist_display_text_update -------------------------------------------------*/

int HSdlist_display_text_update(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   HSdlist_display_text_update

DESCRIPTION
   This function displays a text element from the display list assuming that
   a window update is in progress.

SYNOPSIS
   int HSdlist_display_text_update(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type )

PARAMETERS
   fixed (IN) - the fixed data for the text
   osnum (IN) - the object space number of the text
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_symb (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 S.P. Rogers
      Initial implementation

   15-Apr-94	sash	Added XGL  code.
*/


{
   int ii;
   unsigned int *num_polys;
   unsigned int *num_lines;
   void **polys;
   void **lines;
   unsigned int *num_points;
   float *points;
   IGRshort log_color;
   float red, green, blue;

#  if defined (XGL)
   int		weight, style;
#  endif

#if defined( ENV5 )
   EGRGBColor EGcolor;
#endif
#if defined( OPENGL )
   int gl_num_points;
#endif

#if defined (XGL)
	int			sts;
	void			*chunk=NULL;
	unsigned long		byte_size=0;
        Xgl_pt_list		*pt_lists=NULL;
	Xgl_color		xgl_color;
#endif


   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   GET_LOG_COLOR( alt_symb, fixed->color, log_color );

   GET_COLOR_UPDATE( log_color );

#  if defined (XGL)
   if( alt_symb )
      {
      weight = (alt_symb->weight) ? *alt_symb->weight : fixed->weight;
      style = (alt_symb->style) ? *alt_symb->style : fixed->style;
      }
   else
      {
      weight = fixed->weight;
      style = fixed->style;
      }

   WLset_active_symbology( active_window->win_no,
                           0,
                           style,
                           0xffffffff,
                           weight,
                           WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );

   WLactivate_symbology( active_window->win_no, FALSE, TRUE );
#  endif /* XGL */

#if defined( ENV5 )
   EGcolor.red = red;
   EGcolor.green = green;
   EGcolor.blue = blue;
   EGSetBaseColor( active_window->EG_vc_no, &EGcolor );
#endif

#if defined( OPENGL )
   glColor3f( red, green, blue );
   glDisable( GL_LIGHTING );
#endif

#if defined (XGL)
	HS_XGL_SET_RGB_COLOR (xgl_color, red, green, blue);
        xgl_object_set(	active_window->xgl_context_3D,
		    	XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
		    	NULL);
#endif

   if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
   {
      DLIST_FTXT_NUM_POLYS_PTR( fixed->wf_data, num_polys );
      DLIST_FTXT_POLYS_PTR( fixed->wf_data, polys );

#if defined (XGL)
      byte_size = *num_polys*sizeof(Xgl_pt_list);
      sts = DPdlist_alloc_chunk( byte_size, &chunk );
      if ( !(1 & sts) )
      {
          return( DLIST_E_ERROR );
      }
      pt_lists = (Xgl_pt_list *) chunk;
#endif

      /* display each polygon individuallly */
      for ( ii = 0; ii < *num_polys; ii++ )
      {
         DLIST_PLY_NUM_POINTS_PTR( polys[ii], num_points );
         DLIST_PLY_POINTS_PTR( polys[ii], points );

#if defined( ENV5 )
         EGpolygon.numVerts = *num_points;
         EGpolygon.verts = (EGPoint3 *) points;
         EGPolyLine3( active_window->EG_vc_no, &EGpolygon );
#endif

#if defined( OPENGL )
         gl_num_points = *num_points;
         glBegin( GL_LINE_LOOP );
         SEND_VERTS_TO_OPENGL( gl_num_points, points );
         glEnd();
#endif

#if defined (XGL)
	HS_XGL_SET_PT_LIST_F3D(pt_lists[ii], *num_points, points);
#endif

      } /* end: for */

   }
   else
   {
      DLIST_TXT_NUM_LINES_PTR( fixed->wf_data, num_lines );
      DLIST_TXT_LINES_PTR( fixed->wf_data, lines );

#if defined (XGL)
      byte_size = *num_lines*sizeof(Xgl_pt_list);
      sts = DPdlist_alloc_chunk( byte_size, &chunk );
      if ( !(1 & sts) )
      {
          return( DLIST_E_ERROR );
      }
      pt_lists = (Xgl_pt_list *) chunk;
#endif

      /* display each line string individuallly */
      for ( ii = 0; ii < *num_lines; ii++ )
      {
         DLIST_CRV_NUM_POINTS_PTR( lines[ii], num_points );
         DLIST_CRV_POINTS_PTR( lines[ii], points );

#if defined( ENV5 )
         EGline_string.numVerts = *num_points;
         EGline_string.verts = (EGPoint3 *) points;
         EGPolyLine3( active_window->EG_vc_no, &EGline_string );
#endif

#if defined( OPENGL )
         gl_num_points = *num_points;
         glBegin( GL_LINE_STRIP );
         SEND_VERTS_TO_OPENGL( gl_num_points, points );
         glEnd();
#endif

#if defined (XGL)
	HS_XGL_SET_PT_LIST_F3D(pt_lists[ii], *num_points, points);
#endif

      } /* end: for */

   }

#if defined( OPENGL )
   glEnable( GL_LIGHTING );
#endif

#if defined (XGL)

	if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
	{
    		xgl_multi_simple_polygon(active_window->xgl_context_3D,
					 XGL_FACET_FLAG_SIDES_UNSPECIFIED,
					 NULL,		/* facets */
					 NULL,		/* bbox   */
					 *num_polys,
					 pt_lists);
   	} 
	else 
	{
		xgl_multipolyline(active_window->xgl_context_3D,
				  NULL,	       /* bbox   */
				  *num_lines,
				  pt_lists);
   	}

        DPdlist_free_chunk( byte_size, chunk );

#endif

   return( DLIST_S_SUCCESS );

} /* HSdlist_display_text_update */

/*--- HSdlist_display_surface -------------------------------------------------*/

int HSdlist_display_surface(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   HSdlist_display_surface

DESCRIPTION
   This function displays a surface from the display list.

SYNOPSIS
   int HSdlist_display_surface(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type )

PARAMETERS
   fixed (IN) - the fixed data for the surface
   osnum (IN) - the object space number of the surface
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_symb (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 S.P. Rogers
      Initial implementation

   15-Apr-94	sash	Added XGL  code.
*/


{
   register int ii;
   register struct DPdlist_sh_surf *temp_ptr;
   register unsigned int *num_verts_ptr, num_verts, num_meshes;
   register float *verts, *fnorms, *vnorms;
   register char **mesh_ptr;
   register float diff_refl, spec_refl, finish, trans;
   unsigned int *num_facet_normals;
   IGRshort log_color;
   IGRdouble old_mod_matrix[16], new_mod_matrix[16];
   float red, green, blue;
#if defined( ENV5 )
   EGRGBColor EGcolor;
#endif

   if ( !fixed->sh_data )
   {
      return( DLIST_E_ERROR );
   }

   GET_LOG_COLOR( alt_symb, fixed->color, log_color );

#if defined( OPENGL )
   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
#endif

   if ( dp_mode == GRbd )
   {
      GET_COLOR( log_color );
      WLset_drawing_mode( active_window->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );
#if defined( ENV5 )
      EGSetReflectEqn( active_window->EG_vc_no, EG_REFL_AMB_DIF_SPEC );
      if ( active_window->shading_style == HS_STYLE_SMOOTH )
      {
         EGSetRenderMethod( active_window->EG_vc_no, EG_RENDER_GOUR );
      }
      else
      {
         EGSetRenderMethod( active_window->EG_vc_no, EG_RENDER_FLAT );
      }
#endif

#if defined( OPENGL )
      if ( active_window->shading_style == HS_STYLE_SMOOTH )
      {
         glShadeModel( GL_SMOOTH );
      }
      else
      {
         glShadeModel( GL_FLAT );
      }
#endif

   } /*  if ( dp_mode == GRbd ) */
   else
   {
      GET_COLOR( IGE_LOGICAL_BACKGROUND );
      WLset_drawing_mode( active_window->win_no, WL_BASE_ERASE | WL_HILITE_NOOP );

#if defined( ENV5 )
      EGSetReflectEqn( active_window->EG_vc_no, EG_REFL_NONE );
      EGSetRenderMethod( active_window->EG_vc_no, EG_RENDER_FLAT );
      EGSetLightingMode( active_window->EG_vc_no, EG_OFF );
#endif

#if defined( OPENGL )
      glDisable( GL_LIGHTING );
#endif
   }


   SETUP_FOR_SINGLE_DISPLAY;

   temp_ptr = (struct DPdlist_sh_surf *) fixed->sh_data;

   num_meshes = temp_ptr->num_meshes;
   diff_refl = temp_ptr->diff_refl;
   spec_refl = temp_ptr->spec_refl;
   finish = temp_ptr->finish;
   trans = temp_ptr->trans;
   mesh_ptr = (char **) (temp_ptr + 1);

   /* set rendering parms */
#if defined( ENV5 )
   EGcolor.red = red;
   EGcolor.green = green;
   EGcolor.blue = blue;
   EGSetBaseColor( active_window->EG_vc_no, &EGcolor );

   EGprop.diffRefl = diff_refl;
   EGprop.specRefl = spec_refl;
   EGprop.specExp = (finish > 32.0) ? 32.0 : finish;
   EGprop.transCoeff = (trans >= 0.5) ? 0.5 : 0.0;
   EGSetObjectProp( active_window->EG_vc_no, &EGprop );

   EGSetNormReorientMode( active_window->EG_vc_no, EG_ON );
   EGSetFaceCullingMode( active_window->EG_vc_no, EG_NO_CULL );
#endif

#if defined( OPENGL )
   glColor3f( red, green, blue );
   GLmaterial[0] = red * diff_refl;
   GLmaterial[1] = green * diff_refl;
   GLmaterial[2] = blue * diff_refl;

   glMaterialfv( GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, GLmaterial );

   GLmaterial[0] = GLmaterial[1] = GLmaterial[2] = spec_refl;
   glMaterialfv( GL_FRONT_AND_BACK, GL_SPECULAR, GLmaterial );

   if ( finish > 128.0 )
   {
      finish = 128.0;
   }
   glMaterialf( GL_FRONT_AND_BACK, GL_SHININESS, finish );

   if ( trans >= 0.5 )
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
#endif

#if defined (XGL)
{
   int	sts;

   (void)HSdlist_xgl_set_display_attributes(red,green,blue,fixed);
   sts = HSdlist_xgl_display_surface(fixed);
   if(!(1&sts))
   {
      return sts;
   }
}
#else

   /* display each mesh */
#if defined( OPENGL )
   switch ( active_window->shading_style )
#else
   switch ( HS_STYLE_SMOOTH )
#endif
   {
      case HS_STYLE_SMOOTH :

         for ( ii = 0; ii < num_meshes; ii++, mesh_ptr++ )
         {
            DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
            num_verts = *num_verts_ptr;
            DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
            DLIST_MSH_VNORMS_PTR( *mesh_ptr, vnorms, num_verts );

	     
#if defined( ENV5 )
            DLIST_MSH_FNORMS_PTR( *mesh_ptr, fnorms, num_verts );
            DLIST_MSH_NUM_FACET_NORMALS_PTR( *mesh_ptr, num_facet_normals );

            EGmesh.numVerts = num_verts;
            EGmesh.verts = (EGPoint3 *) verts;
            EGmesh.vNorms = (EGVect3 *) vnorms;
            EGmesh.fNorms = (EGVect3 *) fnorms;
            EGmesh.fNormOffset = (*num_facet_normals > 1) ? sizeof( EGPoint3 ) : 0;
            EGTriMeshData3( active_window->EG_vc_no, &EGmesh );
#endif

#if defined( OPENGL )
            glBegin( GL_TRIANGLE_STRIP );
            SEND_VERTS_AND_NORMALS_TO_OPENGL( num_verts, verts, vnorms );
            glEnd();
#endif
         }/* end of for loop */
         break;

      default:

         for ( ii = 0; ii < num_meshes; ii++, mesh_ptr++ )
         {
            DLIST_MSH_NUM_FACET_NORMALS_PTR( *mesh_ptr, num_facet_normals );
            if ( *num_facet_normals > 1 )
            {
               DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
               num_verts = *num_verts_ptr;
 
               DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
               DLIST_MSH_FNORMS_PTR( *mesh_ptr, fnorms, num_verts );

#if defined( OPENGL )
               /* facet normal per triangle */
               glBegin( GL_TRIANGLE_STRIP );
               glNormal3fv( fnorms );
               glVertex3fv( verts );
               glVertex3fv( verts + 3 );
               glVertex3fv( verts + 6 );
               verts += 9;
               fnorms += 3;
               num_verts -= 3;

               SEND_VERTS_AND_NORMALS_TO_OPENGL( num_verts, verts, fnorms );
               glEnd();
#endif
            }
            else
            {
               DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
               num_verts = *num_verts_ptr;
               DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
               DLIST_MSH_FNORMS_PTR( *mesh_ptr, fnorms, num_verts );

#if defined( OPENGL )
               /* only one facet normal */
               glBegin( GL_TRIANGLE_STRIP );
               glNormal3fv( fnorms );
               SEND_VERTS_TO_OPENGL( num_verts, verts );
               glEnd();
#endif
            }

         }/* end of for(ii) loop */
         break;

   }/* end of switch */

/****** if(XGL){...} else {...} ends here. ******/
#endif
	
   RESTORE_FROM_SINGLE_DISPLAY;

#if defined( OPENGL )
   if ( dp_mode != GRbd )
   {
      glEnable( GL_LIGHTING );
   }

   if ( trans >= 0.5 )
   {
      glDisable( GL_POLYGON_STIPPLE );
   }
#endif

   return( DLIST_S_SUCCESS );

} /* HSdlist_display_surface */

/*--- HSdlist_display_surface_update -------------------------------------------------*/

int HSdlist_display_surface_update(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   HSdlist_display_surface_update

DESCRIPTION
   This function displays a surface from the display list assuming that
   a window update is in progress.

SYNOPSIS
   int HSdlist_display_surface_update(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type )

PARAMETERS
   fixed (IN) - the fixed data for the surface
   osnum (IN) - the object space number of the surface
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_symb (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 S.P. Rogers
      Initial implementation

   15-Apr-94	sash	Added XGL  code.
*/


{
   register int ii;
   register struct DPdlist_sh_surf *temp_ptr;
   register unsigned int *num_verts_ptr, num_verts, num_meshes;
   register float *verts, *fnorms, *vnorms;
   register char **mesh_ptr;
   register float diff_refl, spec_refl, finish, trans;
   unsigned int *num_facet_normals;
   IGRshort log_color;
   float red, green, blue;

#if defined( ENV5 )
   EGRGBColor EGcolor;
#endif

   if ( !fixed->sh_data )
   {
      return( DLIST_E_ERROR );
   }

   GET_LOG_COLOR( alt_symb, fixed->color, log_color );

   GET_COLOR_UPDATE( log_color );

   temp_ptr = (struct DPdlist_sh_surf *) fixed->sh_data;

   num_meshes = temp_ptr->num_meshes;
   diff_refl = temp_ptr->diff_refl;
   spec_refl = temp_ptr->spec_refl;
   finish = temp_ptr->finish;
   trans = temp_ptr->trans;
   mesh_ptr = (char **) (temp_ptr + 1);

#if HS_DEBUG
   printf("red = %lf, green = %lf, blue = %lf\n", red,green,blue);
   printf("diff_refl = %lf, spec_refl = %lf, finish = %lf, trans = %lf\n",
	   diff_refl,spec_refl,finish,trans);
#endif

   /* set rendering parms */
#if defined( ENV5 )
   EGcolor.red = red;
   EGcolor.green = green;
   EGcolor.blue = blue;
   EGSetBaseColor( active_window->EG_vc_no, &EGcolor );

   EGprop.diffRefl = diff_refl;
   EGprop.specRefl = spec_refl;
   EGprop.specExp = (finish > 32.0) ? 32.0 : finish;
   EGprop.transCoeff = (trans >= 0.5) ? 0.5 : 0.0;
   EGSetObjectProp( active_window->EG_vc_no, &EGprop );
#endif

#if defined( OPENGL )
   glColor3f( red, green, blue );
   GLmaterial[0] = red * diff_refl;
   GLmaterial[1] = green * diff_refl;
   GLmaterial[2] = blue * diff_refl;

   glMaterialfv( GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, GLmaterial );
   GLmaterial[0] = GLmaterial[1] = GLmaterial[2] = spec_refl;
   glMaterialfv( GL_FRONT_AND_BACK, GL_SPECULAR, GLmaterial );

   if ( finish > 128.0 )
   {
      finish = 128.0;
   }
   glMaterialf( GL_FRONT_AND_BACK, GL_SHININESS, finish );

   if ( trans >= 0.5 )
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
#endif

#if defined( XGL )
{
	int	sts;
	 /*  Set display attributes here.  */
	(void)HSdlist_xgl_set_display_attributes(red,green,blue,fixed);
	sts = HSdlist_xgl_display_surface(fixed);
	return sts;
}
#else

   /* display each mesh */
#if defined( OPENGL )
   switch ( active_window->shading_style )
#else
   switch ( HS_STYLE_SMOOTH )
#endif
   {
      case HS_STYLE_SMOOTH :


         for ( ii = 0; ii < num_meshes; ii++, mesh_ptr++ )
         {
            DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
            num_verts = *num_verts_ptr;
            DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
            DLIST_MSH_VNORMS_PTR( *mesh_ptr, vnorms, num_verts );
 
#if defined( ENV5 )
            DLIST_MSH_FNORMS_PTR( *mesh_ptr, fnorms, num_verts );
            DLIST_MSH_NUM_FACET_NORMALS_PTR( *mesh_ptr, num_facet_normals );

            EGmesh.numVerts = num_verts;
            EGmesh.verts = (EGPoint3 *) verts;
            EGmesh.vNorms = (EGVect3 *) vnorms;
            EGmesh.fNorms = (EGVect3 *) fnorms;
            EGmesh.fNormOffset = (*num_facet_normals > 1) ? sizeof( EGPoint3 ) : 0;
            EGTriMeshData3( active_window->EG_vc_no, &EGmesh );
#endif

#if defined( OPENGL )
            glBegin( GL_TRIANGLE_STRIP );
            SEND_VERTS_AND_NORMALS_TO_OPENGL( num_verts, verts, vnorms );
            glEnd();
#endif

         }/* end of for loop */
         break;

      default:

         for ( ii = 0; ii < num_meshes; ii++, mesh_ptr++ )
         {
            DLIST_MSH_NUM_FACET_NORMALS_PTR( *mesh_ptr, num_facet_normals );
            if ( *num_facet_normals > 1 )
            {
               DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
               num_verts = *num_verts_ptr;
 
               DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
               DLIST_MSH_FNORMS_PTR( *mesh_ptr, fnorms, num_verts );

#if defined( OPENGL )
               /* facet normal per triangle */
               glBegin( GL_TRIANGLE_STRIP );
               glNormal3fv( fnorms );
               glVertex3fv( verts );
               glVertex3fv( verts + 3 );
               glVertex3fv( verts + 6 );
               verts += 9;
               fnorms += 3;
               num_verts -= 3;

               SEND_VERTS_AND_NORMALS_TO_OPENGL( num_verts, verts, fnorms );
               glEnd();
#endif
            }
            else
            {
               DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
               num_verts = *num_verts_ptr;
               DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
               DLIST_MSH_FNORMS_PTR( *mesh_ptr, fnorms, num_verts );

#if defined( OPENGL )
               /* only one facet normal */
               glBegin( GL_TRIANGLE_STRIP );
               glNormal3fv( fnorms );
               SEND_VERTS_TO_OPENGL( num_verts, verts );
               glEnd();
#endif

            }/*  if ( *num_facet_normals > 1 ) */

         }/* end of for loop */
         break;
 
   }/* end of switch */

#if defined( OPENGL )
   if ( trans >= 0.5 )
   {
      glDisable( GL_POLYGON_STIPPLE );
   }
#endif

   return( DLIST_S_SUCCESS );
  /*********** end of #if defined(XGL) ... #else ***************/
#endif

} /* HSdlist_display_surface_update */

%safe
static int (*display_point)(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type ) = HSdlist_display_point;

static int (*display_polygon)(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type ) = HSdlist_display_polygon;

static int (*display_text)(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type ) = HSdlist_display_text;

static int (*display_curve)(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type ) = HSdlist_display_curve;

static int (*display_surface)(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type ) = HSdlist_display_surface;
%endsafe

/*--- HSdlist_display_element ----------------------------------------------*/

int HSdlist_display_element( 
   OM_S_OBJID objid,
   OMuword osnum,
   struct DP_information *dp_info,
   IGRmatrix matrix,
   IGRshort matrix_type,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   OM_p_KEY_DESC key,
   IGRint single_display )

/*
NAME
   HSdlist_display_element

DESCRIPTION
   This function will display an element from the display
   list in a shading window.

SYNOPSIS
   int HSdlist_display_element( 
      OM_S_OBJID objid,
      OMuword osnum,
      struct DP_information *dp_info,
      IGRmatrix matrix,
      IGRshort matrix_type,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRint single_display )

PARAMETERS
   objid (IN) - the objid of the element to display
   osnum (IN) - the object space number of the element
   dp_info (IN) - the display information
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix
   dp_mode (IN) - the display mode
   alt_sym (IN) - the alternate symbology for the element
   single_display (IN) - if TRUE, then this is a single
                         display request (not an update)

GLOBALS USED
   DPdlist_wf_fb_gragad

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
   09/08/93  Ravi Parthasarthy
      Added to check if the active_window type is HShardware_LB_HSURF_ROP also
*/

{
   int sts;
   IGRlong msg;
   struct DPdlist_fixed_data *fixed = NULL;
   IGRboolean need_disyourself = TRUE;

   HSactivate_window( dp_info->gragad->gpipe_id );
   if ( (active_window->type & (HShardware_LB_HSURF | HShardware_LB_HSURF_ROP | HShardware_LB_GPIPE)) ||
        ( (active_window->shading_style != HS_STYLE_SMOOTH) &&
          (active_window->shading_style != HS_STYLE_CONSTANT) ) )
   {
      /* smooth/constant shading is supported now; only */
      /* when using EG or OPENGL                        */
      return( DLIST_E_ERROR );
   }

   DPdlist_hash_lookup( objid, osnum, &fixed );
   if ( ! fixed )
   {
      if ( single_display & DP_DLIST_DISPLAY_SINGLE_ELEMENT )
      {
         /* don't create data on a single display => return an error */
         /* and let the GRdisyourself method who called us handle    */
         /* the display of this element                              */
         return( DLIST_E_ERROR );
      }

      if ( DPdlist_sh_fb_gragad.objid != NULL_OBJID )
      {
         sts = om$send( msg = message GRgraphics.GRadd_to_display_list( &msg,
                                                      dp_info->is_hidden_line ),
                        senderid = NULL_OBJID,
                        targetid = objid,
                        targetos = osnum );

         if ( 1 & sts & msg )
         {
            /* successful add => get new fixed data */
            DPdlist_hash_lookup( objid, osnum, &fixed );
         }

      }
   }
   else if ( ( ((fixed->type == DP_DLIST_SURFACE) && (!fixed->sh_data)) ||
               ((fixed->type != DP_DLIST_SURFACE) && (!fixed->wf_data)) ) &&
                   (fixed->ele_flags & DP_DLIST_ELE_DISPLAYABLE) &&
                   (!(fixed->ele_flags & DP_DLIST_ELE_INACTIVE)) &&
                   (!(fixed->ele_flags & UNSUPPORTED_FLAGS)) )
   {
      /* need to do something about unknown elements => so we don't */
      /* keep trying to add their strokes if they don't have any    */

      if ( single_display )
      {
         /* don't create data on a single display => return an error */
         /* and let the GRdisyourself method who called us handle    */
         /* the display of this element                              */
         return( DLIST_E_ERROR );
      }

      if ( DPdlist_sh_fb_gragad.objid != NULL_OBJID )
      {
         sts = om$send( msg = message GRgraphics.GRadd_to_display_list( &msg,
                                                      dp_info->is_hidden_line ),
                        senderid = NULL_OBJID,
                        targetid = objid,
                        targetos = osnum );

         if ( 1 & sts & msg )
         {
            /* successful add => get new fixed data */
            DPdlist_hash_lookup( objid, osnum, &fixed );
         }
      }
   }

   if ( fixed )
   {
      if ( (! ((fixed->type == DP_DLIST_DIMENSION) || 
               DPlevel_check( fixed->layer, dp_info->gragad->levels ))) ||
           (fixed->ele_flags & DP_DLIST_ELE_INACTIVE) ||
           ( (!(fixed->ele_flags & DP_DLIST_ELE_DISPLAYABLE)) &&
             ( (dp_mode != GRhdo) && (dp_mode != GRhhdo) &&
               (dp_mode != GRheo) && (dp_mode != GRbdheo) &&
               (dp_mode != GRbeheo) ) ) )
      {
         /* element is not on a displayed layer or is not */
         /* displayable or is not an active surface       */
         return( DLIST_S_SUCCESS );
      }

     if ( ( ((fixed->type == DP_DLIST_SURFACE) && (fixed->sh_data)) ||
            ((fixed->type != DP_DLIST_SURFACE) && (fixed->wf_data)) ) &&
           !(fixed->ele_flags & UNSUPPORTED_FLAGS) )
      {

         /* call HSactivate_window() again because adding to  */
         /* display list above could have caused it to change */
         HSactivate_window( dp_info->gragad->gpipe_id );
         switch( fixed->type )
         {
            case DP_DLIST_POINT :
               sts = (*display_point)( fixed, osnum, dp_info,
                                       dp_mode, alt_symb,
                                       matrix, matrix_type );
               break;
  
            case DP_DLIST_POLYGON :
               sts = (*display_polygon)( fixed, osnum, dp_info,
                                         dp_mode, alt_symb,
                                         matrix, matrix_type );
               break;

            case DP_DLIST_CURVE :
               sts = (*display_curve)( fixed, osnum, dp_info,
                                       dp_mode, alt_symb,
                                       matrix, matrix_type );
               break;

            case DP_DLIST_TEXT :
               sts = (*display_text)( fixed, osnum, dp_info,
                                      dp_mode, alt_symb,
                                      matrix, matrix_type );
               break;

            case DP_DLIST_SURFACE :
               sts = (*display_surface)( fixed, osnum, dp_info,
                                         dp_mode, alt_symb,
                                         matrix, matrix_type );
               break;

            case DP_DLIST_UNKNOWN :
               sts = DPdlist_display_unknown( fixed, osnum, dp_info,
                                              dp_mode, alt_symb,
                                              matrix, matrix_type );
               break;

            case DP_DLIST_DIMENSION :
               /* dimension owner => if performance boost is on don't display it */
               /* otherwise defer the display to the dimension owner             */
               sts = (DPdynamic_update_in_progress && DPdlist_performance_boost) ?
                     DLIST_S_SUCCESS  : DLIST_E_ERROR;
               break;

            default:
               sts = DLIST_E_ERROR;
               break;
         } /* end: switch */
         
         if ( 1 & sts )
         {
            need_disyourself = FALSE;
         }
      }
   }

   if ( need_disyourself )
   {
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );

} /* HSdlist_display_element */

/*--- HSdlist_display_element_update ----------------------------------------*/

int HSdlist_display_element_update( 
   OM_S_OBJID objid,
   OMuword osnum,
   struct DP_information *dp_info,
   IGRmatrix matrix,
   IGRshort matrix_type,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   OM_p_KEY_DESC key,
   IGRint single_display )

/*
NAME
   HSdlist_display_element_update

DESCRIPTION
   This function will display an element from the display
   list in a shading window.  It is tuned for display occuring because
   of an update window request.

SYNOPSIS
   int HSdlist_display_element_update( 
      OM_S_OBJID objid,
      OMuword osnum,
      struct DP_information *dp_info,
      IGRmatrix matrix,
      IGRshort matrix_type,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRint single_display )

PARAMETERS
   objid (IN) - the objid of the element to display
   osnum (IN) - the object space number of the element
   dp_info (IN) - the display information
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix
   dp_mode (IN) - the display mode
   alt_sym (IN) - the alternate symbology for the element
   single_display (IN) - if TRUE, then this is a single
                         display request (not an update)

GLOBALS USED
   DPdlist_wf_fb_gragad

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
   09/08/93  Ravi Parthasarthy
      Added to check if the active_window type is HShardware_LB_HSURF_ROP also
   11/24/93  S.P. Rogers
      Copied from HSdlist_display_element
*/

{
   int sts;
   IGRlong msg;
   struct DPdlist_fixed_data *fixed;
   IGRboolean need_disyourself = TRUE;

   HSactivate_window( dp_info->gragad->gpipe_id );

   DPdlist_hash_lookup( objid, osnum, &fixed );
   if ( ! fixed )
   {
      if ( DPdynamic_update_in_progress )
      {
         /* don't try to add on a dynamic update */
         return( DLIST_E_ERROR );
      }

      if ( DPdlist_sh_fb_gragad.objid != NULL_OBJID )
      {
         sts = om$send( msg = message GRgraphics.GRadd_to_display_list( &msg,
                                                      dp_info->is_hidden_line ),
                        senderid = NULL_OBJID,
                        targetid = objid,
                        targetos = osnum );

         if ( 1 & sts & msg )
         {
            /* successful add => get new fixed data */
            DPdlist_hash_lookup( objid, osnum, &fixed );

            /* call HSactivate_window() again because adding to  */
            /* display list above could have caused it to change */
            HSactivate_window( dp_info->gragad->gpipe_id );
         }

      }
   }
#if defined( TESTING )
   else if ( ( ((fixed->type == DP_DLIST_SURFACE) && (!fixed->sh_data)) ||
               ((fixed->type != DP_DLIST_SURFACE) && (!fixed->wf_data)) ) &&
                   (fixed->ele_flags & DP_DLIST_ELE_DISPLAYABLE) &&
                   (!(fixed->ele_flags & DP_DLIST_ELE_INACTIVE)) &&
                   (!(fixed->ele_flags & UNSUPPORTED_FLAGS)) )
#endif
   else if ( ( ((fixed->type == DP_DLIST_SURFACE) && (!fixed->sh_data)) ||
               ((fixed->type != DP_DLIST_SURFACE) && (!fixed->wf_data)) ) )

   {
      /* need to do something about unknown elements => so we don't */
      /* keep trying to add their strokes if they don't have any    */

      if ( DPdlist_sh_fb_gragad.objid != NULL_OBJID )
      {
         sts = om$send( msg = message GRgraphics.GRadd_to_display_list( &msg,
                                                      dp_info->is_hidden_line ),
                        senderid = NULL_OBJID,
                        targetid = objid,
                        targetos = osnum );

         if ( 1 & sts & msg )
         {
            /* successful add => get new fixed data */
            DPdlist_hash_lookup( objid, osnum, &fixed );

            /* call HSactivate_window() again because adding to  */
            /* display list above could have caused it to change */
            HSactivate_window( dp_info->gragad->gpipe_id );
         }
      }
   }

   if ( fixed )
   {
      if ( (! ((fixed->type == DP_DLIST_DIMENSION) || 
               DPlevel_check( fixed->layer, dp_info->gragad->levels ))) ||
           (fixed->ele_flags & DP_DLIST_ELE_INACTIVE) ||
           (!(fixed->ele_flags & DP_DLIST_ELE_DISPLAYABLE)) )
      {
         /* element is not on a displayed layer or is not */
         /* displayable or is not an active surface       */
         return( DLIST_S_SUCCESS );
      }

     if ( ( ((fixed->type == DP_DLIST_SURFACE) && (fixed->sh_data)) ||
            ((fixed->type != DP_DLIST_SURFACE) && (fixed->wf_data)) ) &&
           !(fixed->ele_flags & UNSUPPORTED_FLAGS) )
      {
         switch( fixed->type )
         {
            case DP_DLIST_POINT :
#if defined(XGL)
     	       HSdlist_first_setting    = TRUE;
#endif
               sts = (*display_point)( fixed, osnum, dp_info,
                                       dp_mode, alt_symb,
                                       matrix, matrix_type );
               break;
  
            case DP_DLIST_POLYGON :
#if defined(XGL)
     	       HSdlist_first_setting    = TRUE;
#endif
               sts = (*display_polygon)( fixed, osnum, dp_info,
                                         dp_mode, alt_symb,
                                         matrix, matrix_type );
               break;

            case DP_DLIST_CURVE :
#if defined(XGL)
     	       HSdlist_first_setting    = TRUE;
#endif
               sts = (*display_curve)( fixed, osnum, dp_info,
                                       dp_mode, alt_symb,
                                       matrix, matrix_type );
               break;

            case DP_DLIST_TEXT :
#if defined(XGL)
     	       HSdlist_first_setting    = TRUE;
#endif
               sts = (*display_text)( fixed, osnum, dp_info,
                                      dp_mode, alt_symb,
                                      matrix, matrix_type );
               break;

            case DP_DLIST_SURFACE :
#if defined(HS_BBS)
{
        int bool=1;

#if defined(XGL)
	if( fixed->valid_xgl_data &&
	   (fixed->xgl_data->shading_style == active_window->shading_style))
		bool = 1;
	else
		bool = 0;
#endif

	/* 
	 * Use "HSdlist_use_bbs" boolean to divert control to old system.
	 * If there is no memory, HSdlist_use_bbs is set to FALSE in 
	 * HSdlist_enter_bbs()
         */

	if(!HSdlist_use_bbs) bool = 0;

        if(bool)
        {
                sts = HSdlist_add_surface_to_bbs(fixed, osnum, dp_info,
                                                 dp_mode, alt_symb,
                                                 matrix, matrix_type ,
                                                 context_no,
						 color_to_rgb);
                if(!(1&sts))
                {	
#if defined(XGL)
		   HSdlist_first_setting = TRUE;
#endif
                   /* some thing went wrong. */
                   sts = (*display_surface)( fixed, osnum, dp_info,
                                                  dp_mode, alt_symb,
                                                  matrix, matrix_type );
                }
        }
        else
        {
               sts = (*display_surface)( fixed, osnum, dp_info,
                                         dp_mode, alt_symb,
                                         matrix, matrix_type );
        }
}
 
#else
               sts = (*display_surface)( fixed, osnum, dp_info,
                                         dp_mode, alt_symb,
                                         matrix, matrix_type );
#endif
               break;

            case DP_DLIST_UNKNOWN :
#if defined(XGL)
     	       HSdlist_first_setting    = TRUE;
#endif
               sts = DPdlist_display_unknown( fixed, osnum, dp_info,
                                              dp_mode, alt_symb,
                                              matrix, matrix_type );
               break;

            case DP_DLIST_DIMENSION :
#if defined(XGL)
     	       HSdlist_first_setting    = TRUE;
#endif
               /* dimension owner => if performance boost is on don't display it */
               /* otherwise defer the display to the dimension owner             */
               sts = (DPdynamic_update_in_progress && DPdlist_performance_boost) ?
                     DLIST_S_SUCCESS  : DLIST_E_ERROR;
               break;

            default:
#if defined(XGL)
     	       HSdlist_first_setting    = TRUE;
#endif
               sts = DLIST_E_ERROR;
               break;
         } /* end: switch */
         
         if ( 1 & sts )
         {
#if defined(XGL)
     	    HSdlist_first_setting    = TRUE;
#endif
            need_disyourself = FALSE;
         }
      }
   }

   if ( need_disyourself )
   {
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );

} /* HSdlist_display_element_update */


/*--- HSdlist_start_window_update -----------------------------------*/

int HSdlist_start_window_update(
   WLuint32 lwin_no,
   int pipe_id )

/*
NAME
   HSdlist_start_window_update

DESCRIPTION
   This function notifies the display list that a window
   update is starting.  It is used so the display for updates
   can be optimized.

SYNOPSIS
   int HSdlist_start_window_update(
      WLuint32 lwin_no,
      int pipe_id )

PARAMETERS
   lwin_no (IN) - the logical window that is being updated
   pipe_id (IN) - the DL pipe id of the window

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS

HISTORY
   12/03/93 S.P. Rogers
      Creation Date

   15-Apr-94	sash	Added Memory Mgmt. code.(XGL)
*/

{
   OM_S_OBJID objid;
   struct WLcontext_info context_info;

   fflush(stdout); fflush(stderr); 
	
#if defined(TIMING_ON)
   if(HSdlist_print_times)
	   start_time = times(&buf);
#endif

   HSactivate_window( pipe_id );

   if ( (active_window->type & (HShardware_LB_HSURF | HShardware_LB_HSURF_ROP | HShardware_LB_GPIPE)) ||
        ( (active_window->shading_style != HS_STYLE_SMOOTH) &&
          (active_window->shading_style != HS_STYLE_CONSTANT) ) )
   {
      /* smooth/constant shading is supported now; only */
      /* when using EG or OPENGL                        */
      DPdlist_set_shading_display_function( NULL );
   }
   else
   {
      /* use update-tuned display element function */
      DPdlist_set_shading_display_function( HSdlist_display_element_update );
   }

   WLset_drawing_mode( active_window->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );

   /* get the context color mapping functions for fast color translation */
   WLget_window_base_context( lwin_no, &context_no );
   CMget_context_info( context_no, &objid, &color_to_index, &color_to_rgb, &cmap_init, &context_info );

   /* set the update based routines */
   display_point = HSdlist_display_point_update;
   display_polygon = HSdlist_display_polygon_update;
   display_curve = HSdlist_display_curve_update;
   display_text = HSdlist_display_text_update;
   display_surface = HSdlist_display_surface_update;

#if defined( ENV5 )
   if ( active_window->shading_style == HS_STYLE_SMOOTH )
   {
      EGSetRenderMethod( active_window->EG_vc_no, EG_RENDER_GOUR );
   }
   else
   {
      EGSetRenderMethod( active_window->EG_vc_no, EG_RENDER_FLAT );
   }
   EGSetLightingMode( active_window->EG_vc_no, EG_ON );
   EGSetReflectEqn( active_window->EG_vc_no, EG_REFL_AMB_DIF_SPEC );
   EGSetNormReorientMode( active_window->EG_vc_no, EG_ON );
   EGSetFaceCullingMode( active_window->EG_vc_no, EG_NO_CULL );
#endif

#if defined( OPENGL )
   WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
   if ( active_window->shading_style == HS_STYLE_SMOOTH )
   {
      glShadeModel( GL_SMOOTH );
   }
   else
   {
      glShadeModel( GL_FLAT );
   }
   glEnable( GL_LIGHTING );
#endif

#if defined(XGL)
    HSdlist_first_setting = TRUE;
#endif

 
#if defined(HS_BBS)
   HSdlist_enter_bbs();
#endif
 
   return( DLIST_S_SUCCESS );

}  /* HSdlist_start_window_update */

/*--- HSdlist_finish_window_update --------------------------------------*/

int HSdlist_finish_window_update(
   WLuint32 lwin_no,
   int pipe_id )

/*
NAME
   HSdlist_finish_window_update

DESCRIPTION
   This function notifies the display list that a window
   update is finished.  It is used so the display for updates
   can be optimized.

SYNOPSIS
   int HSdlist_finish_window_update(
      WLuint32 lwin_no,
      int pipe_id )

PARAMETERS
   lwin_no (IN) - the logical window that is being updated
   pipe_id (IN) - the DL pipe id of the window

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS

HISTORY
   12/03/93 S.P. Rogers
      Creation Date
*/

{
   /* set back to the generic shading display element function */
   DPdlist_set_shading_display_function( HSdlist_display_element );

   /* set the non-update based routines */
   display_point = HSdlist_display_point;
   display_polygon = HSdlist_display_polygon;
   display_curve = HSdlist_display_curve;
   display_text = HSdlist_display_text;
   display_surface = HSdlist_display_surface;

#if defined(HS_BBS)
   HSdlist_exit_bbs();
#endif
 
  
#if defined(TIMING_ON)
   if(HSdlist_print_times)
     finish_time = times(&buf);

   if(HSdlist_print_times)
   {
     int junk_time=0;
     float f_junk_time=0.0;

     junk_time = finish_time-start_time;

     f_junk_time = (float)junk_time / 100.0;

     printf("Time = %f sec. Frames # = %f\n",f_junk_time,1.0/f_junk_time);
	
   }
#endif


   return( DLIST_S_SUCCESS );

} /* HSdlist_finish_window_update */


#if defined(XGL)

#if DEBUG

/---DumpXGLContextShadingAttributes---------------------------------------*/

/*
 * A Debug function that will display the shading attribute data currently
 * active in XGL for the named context
 */

void	DumpXGLContextShadingAttributes( Xgl_object context , char *title )
   {
   Xgl_color	xgl_color, fc, bc;
   int		selector, component;
   float	finish, fd, bd, fs, bs;
   int	        xgl_surf_illumination; 

   xgl_object_get(context, XGL_CTX_SURF_FRONT_COLOR_SELECTOR,    &selector );
   xgl_object_get(context, XGL_CTX_SURF_FRONT_COLOR,             &xgl_color );
   xgl_object_get(context, XGL_3D_CTX_SURF_FRONT_ILLUMINATION,   &xgl_surf_illumination );
   xgl_object_get(context, XGL_3D_CTX_SURF_FRONT_LIGHT_COMPONENT,&component );
   xgl_object_get(context, XGL_3D_CTX_SURF_FRONT_DIFFUSE,        &fd );
   xgl_object_get(context, XGL_3D_CTX_SURF_BACK_DIFFUSE,         &bd );
   xgl_object_get(context, XGL_3D_CTX_SURF_FRONT_SPECULAR,       &fs );
   xgl_object_get(context, XGL_3D_CTX_SURF_BACK_SPECULAR,        &bs );
   xgl_object_get(context, XGL_3D_CTX_SURF_FRONT_SPECULAR_COLOR, &fc );
   xgl_object_get(context, XGL_3D_CTX_SURF_BACK_SPECULAR_COLOR,  &bc );
   xgl_object_get(context, XGL_3D_CTX_SURF_FRONT_SPECULAR_POWER, &finish );

   fprintf( stderr, "\n\n   %s\n", title );
   fprintf( stderr, "COLOR_SELECTOR: %x\n", selector );
   fprintf( stderr, "COLOR         : %f %f %f\n", xgl_color.rgb.r, xgl_color.rgb.g, xgl_color.rgb.b );
   fprintf( stderr, "ILLUMINATION  : %x\n", xgl_surf_illumination );
   fprintf( stderr, "COMPONENT     : %x\n", component );
   fprintf( stderr, "FRONT_DIFFUSE : %f\n", fd );
   fprintf( stderr, "BACK_DIFFUSE  : %f\n", bd );
   fprintf( stderr, "FRONT_SPECULAR: %f\n", fs );
   fprintf( stderr, "BACK_SPECULAR : %f\n", bs );
   fprintf( stderr, "FRONT_SPEC_CLR: %f %f %f\n", fc.rgb.r, fc.rgb.g, fc.rgb.b );
   fprintf( stderr, "BACK_SPEC_CLR : %f %f %f\n", bc.rgb.r, bc.rgb.g, bc.rgb.b );
   fprintf( stderr, "FINISH        : %f\n", finish );
   }
#endif

/*---HSdlist_xgl_set_display_attributes---------------------------------*/

void	HSdlist_xgl_set_display_attributes(
		float	red,				/* i */
		float	green,				/* i */
		float	blue,				/* i */
	     	struct DPdlist_fixed_data 	*fixed	/* i */
	)
/*
NAME
	HSdlist_xgl_set_display_attributes

DESCRIPTION
   This function does symbology settings for XGL display.
   HSdlist_first_setting is used to implement lazy symbology setting.

SYNOPSIS
void	HSdlist_xgl_set_display_attributes(
		float	red,
		float	green,
		float	blue,
	     	struct DPdlist_fixed_data 	*fixed
	)

PARAMETERS
	red	(IN)	color of surface
	green	(IN)	color of surface
	blue	(IN)	color of surface
	fixed   (IN)    the fixed data for the surface

GLOBALS USED
	active_window->shading_style
	HSdlist_first_setting

RETURN VALUES
	None.

HISTORY
   10-June-94	sash	Creation
*/

{
   float		diff_refl,spec_refl,trans,finish;
   unsigned int			setting_required = TRUE;
   Xgl_surf_illumination	xgl_surf_illumination; 
   struct DPdlist_sh_surf 	*temp_ptr;
   struct HSdlist_xgl_surf_attributes 	new_attributes;

   /*----------------------------------------------------------*/

   if ( active_window->shading_style == HS_STYLE_SMOOTH )
   {
	xgl_surf_illumination = XGL_ILLUM_PER_VERTEX;
   }
   else 
   {
	xgl_surf_illumination = XGL_ILLUM_PER_FACET;
   }
 
   temp_ptr = (struct DPdlist_sh_surf *) fixed->sh_data;
   new_attributes.red	       = red;
   new_attributes.green	       = green;
   new_attributes.blue	       = blue;
   new_attributes.illumination = xgl_surf_illumination;
   new_attributes.diff_refl    = diff_refl = temp_ptr->diff_refl;
   new_attributes.spec_refl    = spec_refl = temp_ptr->spec_refl;
   new_attributes.trans        = trans     = temp_ptr->trans;
   new_attributes.finish       = finish    = (float)(temp_ptr->finish > 32.0)?32.0:temp_ptr->finish;


   /* Trying to avoid multiple xgl_object_set() calls.... */
   if(HSdlist_first_setting)
   {
     setting_required = TRUE;
     HSdlist_first_setting    = FALSE;
   }
   else
   {
   	HSDLIST_COMPARE_ATTRIBUTES(setting_required,
				   old_attributes,
				   new_attributes);
   }
     
   /* Save current settings for future use. */
   old_attributes = new_attributes;

   if(setting_required)
   {   
        Xgl_color	xgl_color;

        HS_XGL_SET_RGB_COLOR (xgl_color, red, green, blue);

        xgl_object_set(active_window->xgl_context_3D,
                XGL_CTX_SURF_FRONT_COLOR_SELECTOR,    XGL_SURF_COLOR_CONTEXT,
                XGL_CTX_SURF_FRONT_COLOR,             &xgl_color,
                XGL_3D_CTX_SURF_FRONT_ILLUMINATION,   xgl_surf_illumination,
                XGL_3D_CTX_SURF_FRONT_LIGHT_COMPONENT,
                   XGL_LIGHT_ENABLE_COMP_AMBIENT |
                   XGL_LIGHT_ENABLE_COMP_DIFFUSE |
                   XGL_LIGHT_ENABLE_COMP_SPECULAR,
                XGL_3D_CTX_SURF_FRONT_DIFFUSE,        diff_refl,
                XGL_3D_CTX_SURF_BACK_DIFFUSE,         diff_refl,
                XGL_3D_CTX_SURF_FRONT_SPECULAR,       spec_refl,
                XGL_3D_CTX_SURF_BACK_SPECULAR,        spec_refl,
                /*XGL_3D_CTX_SURF_FRONT_SPECULAR_COLOR, &xgl_color,
                XGL_3D_CTX_SURF_BACK_SPECULAR_COLOR,  &xgl_color,*/
                XGL_3D_CTX_SURF_FRONT_SPECULAR_POWER, (finish/2),
		NULL);

        /*DumpXGLContextShadingAttributes(active_window->xgl_context_3D, "HSdlist_xgl_set_display_attributes" );*/
   }

}/* HSdlist_xgl_set_display_attributes() */


int	HSdlist_xgl_display_surface (
	     struct DPdlist_fixed_data 	*fixed
	)
/*
NAME
	HSdlist_xgl_display_surface

DESCRIPTION
	This function displays given surface using XGL
	library.

	Eventhough I have code witch works for constant shading
	I am not using this because:

		- I will not be able to delete mesh data.
		- I will not be able to do smooth and constant shading
		  at the same time
		- It is not possible to hadnle multiple shading windows
		  with multiple shading styles.

SYNOPSIS
int	HSdlist_xgl_display_surface (
	     struct DPdlist_fixed_data 	*fixed
	)

PARAMETERS
	fixed   (IN)    the fixed data for the surface

GLOBALS USED
	active_window->shading_style


RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   10-June-94	sash	Creation
*/

{
   register char 		**mesh_ptr;

   register float 		*verts, *fnorms, *vnorms;

   register unsigned int 	*num_verts_ptr, num_verts=0, num_facets=0,
				num_meshes,*num_facet_normals;

   void				*chunk=NULL;

   int				use_xgl_data = FALSE,ii,
				sts = DLIST_S_SUCCESS;

   Xgl_usgn32			byte_size=0,jj, total_num_verts=0;

   Xgl_pt_list			pt_list[1];

   Xgl_pt_normal_flag_f3d	*dup_pt_normal_flag_f3d = NULL,
				*pt_normal_flag_f3d_arr = NULL;

   struct DPdlist_xgl_data	*xgl_data=NULL;

   struct DPdlist_sh_surf 	*temp_ptr;

   /*-----------------------------------------------------------*/

   if(active_window->shading_style == HS_STYLE_CONSTANT)
   {
        return( DLIST_E_ERROR );
   }

   if(!fixed)
   {
	return( DLIST_E_ERROR );
   }

   if((fixed->valid_xgl_data) && (fixed->xgl_data))
   {
	/* Job is simple. */
	use_xgl_data = TRUE;
   }
   else
   {
	/* Fill in xgl data... */
	fixed->xgl_data = NULL;
	use_xgl_data = FALSE;
   }

   if(use_xgl_data)
   {
	if((fixed->xgl_data->shading_style == active_window->shading_style) &&
	   (fixed->xgl_data->total_num_verts) && (fixed->xgl_data->vertex_data))
        {
           HS_XGL_SET_PT_LIST_NORMAL_FLAG_F3D(pt_list[0], 
	  			              fixed->xgl_data->total_num_verts, 
					      fixed->xgl_data->vertex_data);

	   xgl_triangle_list(active_window->xgl_context_3D,
				NULL,
				pt_list,
				XGL_TLIST_FLAG_USE_VTX_FLAGS);

        }
        else 
	{
		/* 
		 *	Free existing xgl_data. 
		 */

		if((fixed->xgl_data->vertex_data_size)&&
				   (fixed->xgl_data->vertex_data))
		{
      		  sts = DPdlist_free_chunk(fixed->xgl_data->vertex_data_size,
					   fixed->xgl_data->vertex_data);
		  if(!(1&sts))
		  {
			return DLIST_E_ERROR;
		  }
		}

		sts = DPdlist_free_chunk(sizeof(struct DPdlist_xgl_data),
					 fixed->xgl_data);
		if(!(1&sts))
		{
                   return DLIST_E_ERROR;
		}

   		fixed->valid_xgl_data = use_xgl_data = FALSE;
		fixed->xgl_data	      = NULL;

		return( DLIST_E_ERROR );
	}

        /* I am throu'. */
        goto wrapup;

    } /* use_xgl_data .... */


    /*
     *		Find total number of verts.
     */
    temp_ptr = (struct DPdlist_sh_surf *) fixed->sh_data;
    num_meshes = temp_ptr->num_meshes;
    mesh_ptr = (char **) (temp_ptr + 1);
    if(!mesh_ptr)
    {
        return( DLIST_E_ERROR );
    }

    for ( ii = 0; ii < num_meshes; ii++, mesh_ptr++ )
    {
            DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
	    total_num_verts += *num_verts_ptr;
    }
    /* Restore mesh_ptr back. */
    mesh_ptr = (char **) (temp_ptr + 1);

    /*
     *	   Allocate & Initialize for xgl_data.
     */
    sts = DPdlist_alloc_chunk(sizeof(struct DPdlist_xgl_data),&chunk);
    if(!(1&sts))
    {
        return( DLIST_E_ERROR );
    }
    xgl_data = (struct DPdlist_xgl_data *)chunk;
    xgl_data->vertex_data      = NULL;
    xgl_data->vertex_data_size = xgl_data->total_num_verts  = 0;
    xgl_data->shading_style    = active_window->shading_style;

    /*
     *	Allocate for xgl_data->vertex_data.
     */
    byte_size = total_num_verts*sizeof(Xgl_pt_normal_flag_f3d);
    sts = DPdlist_alloc_chunk( byte_size, &chunk );
    if ( !(1 & sts) )
    {
        return( DLIST_E_ERROR );
    }

    dup_pt_normal_flag_f3d     = 
    pt_normal_flag_f3d_arr     = (Xgl_pt_normal_flag_f3d *)chunk;
    xgl_data->vertex_data_size = byte_size;

    /* Pack verts and facets. */
    switch ( active_window->shading_style )
    {
      case HS_STYLE_SMOOTH :

         for ( ii = 0; ii < num_meshes; ii++, mesh_ptr++ )
         {
            DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
            num_verts = *num_verts_ptr;
            DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
            DLIST_MSH_VNORMS_PTR( *mesh_ptr, vnorms, num_verts );
 
 	    HS_XGL_SET_PT_NORMAL_FLAG_F3D(num_verts,
					  verts,
					  vnorms,
					  dup_pt_normal_flag_f3d,
					  1);
         }

	 HS_XGL_SET_PT_LIST_NORMAL_FLAG_F3D(pt_list[0], 
					    total_num_verts, 
					    pt_normal_flag_f3d_arr);

	 /* Fill xgl_data structure. */
	 if(xgl_data && !use_xgl_data)
         {
		/* Store xgl_data for future use. */
		fixed->valid_xgl_data	  = 1;
		fixed->xgl_data 	  = xgl_data;
		xgl_data->total_num_verts = total_num_verts;
		xgl_data->shading_style   = active_window->shading_style;
		xgl_data->vertex_data	  = pt_normal_flag_f3d_arr;
	 }

	 xgl_triangle_list(active_window->xgl_context_3D,
			   NULL,
			   pt_list,
			   XGL_TLIST_FLAG_USE_VTX_FLAGS);

         break;


      default:

	 /*
	  *		CONSTANT (FLAT) SHADING
	  */

         for ( ii = 0; ii < num_meshes; ii++, mesh_ptr++ )
         {
            DLIST_MSH_NUM_FACET_NORMALS_PTR( *mesh_ptr, num_facet_normals );
	    num_facets = *num_facet_normals;

            DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
            num_verts = *num_verts_ptr;

            DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
            DLIST_MSH_FNORMS_PTR( *mesh_ptr, fnorms, num_verts );

	    if(num_facets > 1)
	    {
		dup_pt_normal_flag_f3d[0].x = verts[0];
                dup_pt_normal_flag_f3d[0].y = verts[1];
                dup_pt_normal_flag_f3d[0].z = verts[2];

		dup_pt_normal_flag_f3d[1].x = verts[3];
                dup_pt_normal_flag_f3d[1].y = verts[4];
                dup_pt_normal_flag_f3d[1].z = verts[5];
		
		dup_pt_normal_flag_f3d[2].x = verts[6];
                dup_pt_normal_flag_f3d[2].y = verts[7];
                dup_pt_normal_flag_f3d[2].z = verts[8];

                dup_pt_normal_flag_f3d[0].normal.x = 
                dup_pt_normal_flag_f3d[1].normal.x = 
                dup_pt_normal_flag_f3d[2].normal.x = fnorms[0];

                dup_pt_normal_flag_f3d[0].normal.y =
                dup_pt_normal_flag_f3d[1].normal.y =
                dup_pt_normal_flag_f3d[2].normal.y = fnorms[1];

                dup_pt_normal_flag_f3d[0].normal.z =
                dup_pt_normal_flag_f3d[1].normal.z = 
                dup_pt_normal_flag_f3d[2].normal.z = fnorms[2];

		dup_pt_normal_flag_f3d[0].flag = XGL_TRIANGLE_RESTART;
		dup_pt_normal_flag_f3d[1].flag = XGL_TRIANGLE_STRIP;
		dup_pt_normal_flag_f3d[2].flag = XGL_TRIANGLE_STRIP;

		for(jj=3;jj<num_verts;jj++)
		{
		   dup_pt_normal_flag_f3d[jj].x        = verts[(3*jj)];
		   dup_pt_normal_flag_f3d[jj].y        = verts[(3*jj)+1];
		   dup_pt_normal_flag_f3d[jj].z        = verts[(3*jj)+2];
                   dup_pt_normal_flag_f3d[jj].normal.x = fnorms[(3*(jj-2))];
                   dup_pt_normal_flag_f3d[jj].normal.y = fnorms[(3*(jj-2))+1];
                   dup_pt_normal_flag_f3d[jj].normal.z = fnorms[(3*(jj-2))+2];
		   dup_pt_normal_flag_f3d[jj].flag     = XGL_TRIANGLE_STRIP;
		}

	    }
	    else
	    {
		for(jj=0;jj<num_verts;jj++)
		{
		   dup_pt_normal_flag_f3d[jj].x        = verts[(3*jj)];
		   dup_pt_normal_flag_f3d[jj].y        = verts[(3*jj)+1];
		   dup_pt_normal_flag_f3d[jj].z        = verts[(3*jj)+2];
                   dup_pt_normal_flag_f3d[jj].normal.x = fnorms[(3*jj)];
                   dup_pt_normal_flag_f3d[jj].normal.y = fnorms[(3*jj)+1];
                   dup_pt_normal_flag_f3d[jj].normal.z = fnorms[(3*jj)+2];
		   dup_pt_normal_flag_f3d[jj].flag     = XGL_TRIANGLE_STRIP;
		}

		dup_pt_normal_flag_f3d[0].flag = XGL_TRIANGLE_RESTART;

	    }/* if(num_facets>1) */

	    dup_pt_normal_flag_f3d = &dup_pt_normal_flag_f3d[num_verts];

         }/* end of for loop */

         HS_XGL_SET_PT_LIST_NORMAL_FLAG_F3D(pt_list[0],
                                            total_num_verts,
                                            pt_normal_flag_f3d_arr);

	 /* Fill xgl_data structure. */
         if(xgl_data && !use_xgl_data)
         {
                /* Store xgl_data for future use. */
                fixed->valid_xgl_data     = 1;
                fixed->xgl_data           = xgl_data;
                xgl_data->total_num_verts = total_num_verts;
                xgl_data->shading_style   = active_window->shading_style;
                xgl_data->vertex_data     = pt_normal_flag_f3d_arr;
         }

         xgl_triangle_list(active_window->xgl_context_3D,
			   NULL,
			   pt_list,
			   XGL_TLIST_FLAG_USE_VTX_FLAGS); 

         break;
 
   }/* end of switch */

   /*
    *		Free mesh data.
    */
   if(sts == DLIST_S_SUCCESS)
   {
	HSDLIST_FREE_SH_MESH_DATA(fixed);
   }

wrapup:
	return sts;

} /* HSdlist_xgl_display_surface () */

#endif

end implementation Root;
