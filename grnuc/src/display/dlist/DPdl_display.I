class implementation Root;

#include <stdlib.h>
#include <stdio.h>

#include "wl.h"

#include "OMerrordef.h"
#include "OMindex.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "madef.h"

#include "gr.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"

#include "DPdlist.h"

#include "dl.h"

#include "dpmacros.h"

/* Old Prototypes */
#include "matrnmx.h"
#include "exproto.h"

extern int	IGEstop( void );

/* New Prototypes */
PROTO_DPdlist_set_shading_display_function
PROTO_DPdlist_display_point
PROTO_DPdlist_display_polygon
PROTO_DPdlist_display_curve
PROTO_DPdlist_display_text
PROTO_DPdlist_display_surface
PROTO_DPdlist_display_unknown
PROTO_DPdlist_display_element
PROTO_DPdlist_display_element_update
PROTO_DPdlist_get_transform_buffer
PROTO_DPdlist_transform_points
PROTO_DPdlist_hash_lookup

extern IGRboolean dynamics_in_progress;
extern IGRboolean DPdlist_use_display_list;
extern IGRboolean DPdynamic_update_in_progress;
extern struct GRid DPdlist_wf_fb_gragad;
extern IGRboolean DPdlist_display_tangent_edges;
extern IGRboolean DPdlist_performance_boost;

from GRgraphics import GRdisyourself;

from GRgraphics import GRadd_to_display_list;

/* Elements w/ these flags set are currently */
/* not supported in the display list         */
#define UNSUPPORTED_FLAGS (DP_DLIST_ELE_VIEW_IND | \
                           DP_DLIST_ELE_SCALE_IND)

%safe

static int (*display_element)( 
   OM_S_OBJID objid,
   OMuword osnum,
   struct DP_information *dp_info,
   IGRmatrix matrix,
   IGRshort matrix_type,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   OM_p_KEY_DESC key,
   IGRint single_display ) = NULL;

/* static pointer to shading implementation of DPdlist_display_element */
static int (*DPdlist_display_element_sh)(
   OM_S_OBJID objid,
   OMuword osnum,
   struct DP_information *dp_info,
   IGRmatrix matrix,
   IGRshort matrix_type,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   OM_p_KEY_DESC key,
   IGRint single_display ) = NULL;

static IGRlong static_msg;
static IGRshort static_four = 4;
static IGRboolean DPdlist_sending_display_back = FALSE;
%endsafe

#define SETUP_FOR_SINGLE_DISPLAY \
   if (! (dp_info->is_update) ) \
   { \
      DLget_modelling_matrix( dp_info->gragad->gpipe_id, old_mod_matrix ); \
      MAtrnmx( &static_msg, &static_four, matrix, new_mod_matrix ); \
      DLset_modelling_matrix( dp_info->gragad->gpipe_id, new_mod_matrix ); \
   }

#define RESTORE_FROM_SINGLE_DISPLAY \
   if (! (dp_info->is_update) ) \
   { \
      DLset_modelling_matrix( dp_info->gragad->gpipe_id, old_mod_matrix ); \
   }


/* set DL drawing options based on mode */
#define MAP_DISPLAY_MODE( dp_mode, blend, dl_options )                 \
                                                                       \
   (dl_options) = 0;                                                   \
   (blend) = 0xFFFF;                                                   \
   switch ( (dp_mode) )                                                \
   {                                                                   \
      case GRbd :                                                      \
         (dl_options) = DL_OPT_BASE_DRAW | DL_OPT_HILITE_NOOP;         \
         break;                                                        \
      case GRbe :                                                      \
         (dl_options) = DL_OPT_BASE_ERASE | DL_OPT_HILITE_NOOP;        \
         break;                                                        \
      case GRhd : case GRhdo :                                         \
         (dl_options) = DL_OPT_BASE_NOOP | DL_OPT_HILITE_DRAW;         \
         break;                                                        \
      case GRhhd : case GRhhdo:                                        \
         (dl_options) = DL_OPT_BASE_NOOP | DL_OPT_HILITE_DRAW;         \
         (blend) = 0xAAAA;                                             \
         break;                                                        \
      case GRhe : case GRheo :                                         \
         (dl_options) = DL_OPT_BASE_NOOP | DL_OPT_HILITE_ERASE;        \
         break;                                                        \
      case GRbdhd :                                                    \
         (dl_options) = DL_OPT_BASE_DRAW | DL_OPT_HILITE_DRAW;         \
         break;                                                        \
      case GRbehe : case GRbeheo :                                     \
         (dl_options) = DL_OPT_BASE_ERASE | DL_OPT_HILITE_ERASE;       \
         break;                                                        \
      case GRbdhe : case GRbdheo :                                     \
         (dl_options) = DL_OPT_BASE_DRAW | DL_OPT_HILITE_ERASE;        \
         break;                                                        \
      case GRbehd :                                                    \
         (dl_options) = DL_OPT_BASE_ERASE | DL_OPT_HILITE_DRAW;        \
         break;                                                        \
   }                                                                   \

#if defined( OPENGL )

#define SPLIT_AND_MAP_DISPLAY_MODE( dp_mode, split_modes, num_modes, blend, dl_options ) \
                                                                                         \
   (dl_options)[0] = (dl_options)[1] = 0;                                                \
   (blend)[0] = (blend)[1] = 0xFFFF;                                                     \
   switch ( (dp_mode) )                                                                  \
   {                                                                                     \
      case GRbd :                                                                        \
         (split_modes)[0] = GRbd; num_modes = 1;                                         \
         (dl_options)[0] = DL_OPT_BASE_DRAW | DL_OPT_HILITE_NOOP;                        \
         break;                                                                          \
      case GRbe :                                                                        \
         (split_modes)[0] = GRbe; num_modes = 1;                                         \
         (dl_options)[0] = DL_OPT_BASE_ERASE | DL_OPT_HILITE_NOOP;                       \
         break;                                                                          \
      case GRhd : case GRhdo :                                                           \
         (split_modes)[0] = dp_mode; num_modes = 1;                                      \
         (dl_options)[0] = DL_OPT_BASE_NOOP | DL_OPT_HILITE_DRAW;                        \
         break;                                                                          \
      case GRhhd : case GRhhdo:                                                          \
         (split_modes)[0] = dp_mode; num_modes = 1;                                      \
         (dl_options)[0] = DL_OPT_BASE_NOOP | DL_OPT_HILITE_DRAW;                        \
         (blend)[0] = 0xAAAA;                                                            \
         break;                                                                          \
      case GRhe : case GRheo :                                                           \
         (split_modes)[0] = dp_mode; num_modes = 1;                                      \
         (dl_options)[0] = DL_OPT_BASE_NOOP | DL_OPT_HILITE_ERASE;                       \
         break;                                                                          \
      case GRbdhd :                                                                      \
         (split_modes)[0] = GRhd; (split_modes)[1] = GRbd; num_modes = 2;                \
         (dl_options)[0] = DL_OPT_BASE_NOOP | DL_OPT_HILITE_DRAW;                        \
         (dl_options)[1] = DL_OPT_BASE_DRAW | DL_OPT_HILITE_NOOP;                        \
         break;                                                                          \
      case GRbehe :                                                                      \
         (split_modes)[0] = GRhe; (split_modes)[1] = GRbe; num_modes = 2;                \
         (dl_options)[0] = DL_OPT_BASE_NOOP | DL_OPT_HILITE_ERASE;                       \
         (dl_options)[1] = DL_OPT_BASE_ERASE | DL_OPT_HILITE_NOOP;                       \
         break;                                                                          \
      case GRbeheo :                                                                     \
         (split_modes)[0] = GRheo; (split_modes)[1] = GRbe; num_modes = 2;               \
         (dl_options)[0] = DL_OPT_BASE_NOOP | DL_OPT_HILITE_ERASE;                       \
         (dl_options)[1] = DL_OPT_BASE_ERASE | DL_OPT_HILITE_NOOP;                       \
         break;                                                                          \
      case GRbdhe :                                                                      \
         (split_modes)[0] = GRhe; (split_modes)[1] = GRbd; num_modes = 2;                \
         (dl_options)[0] = DL_OPT_BASE_NOOP | DL_OPT_HILITE_ERASE;                       \
         (dl_options)[1] = DL_OPT_BASE_DRAW | DL_OPT_HILITE_NOOP;                        \
         break;                                                                          \
      case GRbdheo :                                                                     \
         (split_modes)[0] = GRheo; (split_modes)[1] = GRbd; num_modes = 2;               \
         (dl_options)[0] = DL_OPT_BASE_NOOP | DL_OPT_HILITE_ERASE;                       \
         (dl_options)[1] = DL_OPT_BASE_DRAW | DL_OPT_HILITE_NOOP;                        \
         break;                                                                          \
      case GRbehd :                                                                      \
         (split_modes)[0] = GRhd; (split_modes)[1] = GRbe; num_modes = 2;                \
         (dl_options)[0] = DL_OPT_BASE_NOOP | DL_OPT_HILITE_DRAW;                        \
         (dl_options)[1] = DL_OPT_BASE_ERASE | DL_OPT_HILITE_NOOP;                       \
         break;                                                                          \
   }                                                                                     \

#else

#define SPLIT_AND_MAP_DISPLAY_MODE( dp_mode, split_modes, num_modes, blend, dl_options ) \
   (num_modes) = 1; \
   (split_modes)[0] = dp_mode; \
   MAP_DISPLAY_MODE( (dp_mode), (blend)[0], (dl_options)[0] ); \

#endif


/*--- DPdlist_set_shading_display_function -------------------------------*/

int DPdlist_set_shading_display_function(
   int (shading_display_function)(
      OM_S_OBJID objid,
      OMuword osnum,
      struct DP_information *dp_info,
      IGRmatrix matrix,
      IGRshort matrix_type,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      OM_p_KEY_DESC key,
      IGRint single_display ) )

/*
NAME
   DPdlist_set_shading_display_function

DESCRIPTION
   This function sets the function that will be called when an 
   element is to be displayed in a shaded window from the 
   display list.

SYNOPSIS
   int DPdlist_set_shading_display_function(
      int (shading_display_function)(
         OM_S_OBJID objid,
         OMuword osnum,
         struct DP_information *dp_info,
         IGRmatrix matrix,
         IGRshort matrix_type,
         enum GRdpmode dp_mode,
         struct IGRaltdisplay *alt_symb,
         OM_p_KEY_DESC key,
         IGRint single_display ) )

PARAMETERS
   shading_display_function (IN) - the shading display function

GLOBALS USED
   DPdlist_display_element_sh (static)

RETURN VALUES
   DLIST_S_SUCCESS

HISTORY
   07/14/93 S.P. Rogers
      Intitial specification, design, and implementation
*/

{
   /*
    *  Call this functions here, because, I pretty sure this
    *  is the first display list function called after dload
    *  has occured.
    */

   DPdlist_set_on_off_mode();

   DPdlist_display_element_sh = shading_display_function;
   return( DLIST_S_SUCCESS );
} /* DPdlist_set_shading_display_function */



/*--- DPdlist_display_point -----------------------------------------------*/

int DPdlist_display_point(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   DPdlist_display_point

DESCRIPTION
   This function displays a point from the display list.

SYNOPSIS
   int DPdlist_display_point(
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
   alt_sym (IN) - the alternate symbology for the element
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
*/


{
   int sts;
   int dl_options;
   WLuint16 blend;
   WLcolorref color_ref;
   int weight;
   float *point;
   IGRdouble old_mod_matrix[16], new_mod_matrix[16];

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   DLIST_PNT_POINT_PTR( fixed->wf_data, point );

   MAP_DISPLAY_MODE( dp_mode, blend, dl_options );

   if ( alt_symb )
   {
      if ( alt_symb->color )
      {
         WLpack_index_colorref( *alt_symb->color, &color_ref, FALSE );
      }
      else
      {
         WLpack_index_colorref( fixed->color, &color_ref, FALSE );
      }
      weight = (alt_symb->weight) ? *alt_symb->weight : fixed->weight;
   }
   else
   {
      WLpack_index_colorref( fixed->color, &color_ref, FALSE );
      weight = fixed->weight;
   }

   SETUP_FOR_SINGLE_DISPLAY;

   sts = DLdraw_3D_point_string_f( dp_info->gragad->gpipe_id,
                                   point, 1,
                                   color_ref, weight, dl_options );

   RESTORE_FROM_SINGLE_DISPLAY;

   if ( sts != DL_SUCCESS )
   {
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_display_point */


/*--- DPdlist_display_polygon -----------------------------------------------*/

int DPdlist_display_polygon(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   DPdlist_display_polygon

DESCRIPTION
   This function displays a polygon from the display list.

SYNOPSIS
   int DPdlist_display_polygon(
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
   alt_sym (IN) - the alternate symbology for the element
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
*/


{
   int sts;
   int dl_options;
   WLuint16 blend;
   unsigned int *num_points;
   WLcolorref color_ref;
   int weight;
   int style;
   float *points;
   IGRdouble old_mod_matrix[16], new_mod_matrix[16];

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   DLIST_PLY_NUM_POINTS_PTR( fixed->wf_data, num_points );
   DLIST_PLY_POINTS_PTR( fixed->wf_data, points );

   MAP_DISPLAY_MODE( dp_mode, blend, dl_options );

   if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
   {
      dl_options |= DL_OPT_FILL;
   }

   if ( alt_symb )
   {
      if ( alt_symb->color )
      {
         WLpack_index_colorref( *alt_symb->color, &color_ref, FALSE );
      }
      else
      {
         WLpack_index_colorref( fixed->color, &color_ref, FALSE );
      }
      weight = (alt_symb->weight) ? *alt_symb->weight : fixed->weight;
      style = (alt_symb->style) ? *alt_symb->style : fixed->style;
   }
   else
   {
      WLpack_index_colorref( fixed->color, &color_ref, FALSE );
      weight = fixed->weight;
      style = fixed->style;
   }

   if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
   {
      dl_options |= DL_OPT_FILL;
   }

   SETUP_FOR_SINGLE_DISPLAY;

   sts = DLdraw_3D_polygons_f( dp_info->gragad->gpipe_id,
                               points, (int *)num_points, 1,
                               color_ref, style, blend, 
                               weight, dl_options );

   RESTORE_FROM_SINGLE_DISPLAY;

   if ( sts != DL_SUCCESS )
   {
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_display_polygon */


/*--- DPdlist_display_curve -----------------------------------------------*/

int DPdlist_display_curve(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   DPdlist_display_curve

DESCRIPTION
   This function displays a curve from the display list.

SYNOPSIS
   int DPdlist_display_curve(
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
   alt_sym (IN) - the alternate symbology for the element
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
*/


{
   int sts;
   int dl_options;
   WLuint16 blend;
   WLcolorref color_ref;
   int weight;
   int style;
   struct DPdlist_curve_variable curve_ptrs;
   IGRdouble old_mod_matrix[16], new_mod_matrix[16];

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   DLIST_CRV_ALL_PTRS( fixed->wf_data, curve_ptrs );

   if ( fixed->ele_flags & DP_DLIST_ELE_IS_MSC )
   {
      /* must check for tangent edge and rule line display */
      /* for model space counterparts                      */
      if ( (! DPdlist_display_tangent_edges) &&
           (*curve_ptrs.flags & DP_DLIST_CRV_TANGENT) )
      {
         /* not displaying tangent edges */
         return( DLIST_S_SUCCESS );
      }

      if ( (dp_info->gragad->flags & DP_NO_RULE_LINES) &&
           ( (*curve_ptrs.flags & DP_DLIST_CRV_RULE_LINE) ||
             ( (*curve_ptrs.flags & DP_DLIST_CRV_SEAM) &&
               (*curve_ptrs.flags & DP_DLIST_CRV_TANGENT) ) ) )
      {
         /* not displaying rule lines */
         return( DLIST_S_SUCCESS );
      }      
   }

   MAP_DISPLAY_MODE( dp_mode, blend, dl_options );

   if ( alt_symb )
   {
      if ( alt_symb->color )
      {
         WLpack_index_colorref( *alt_symb->color, &color_ref, FALSE );
      }
      else
      {
         WLpack_index_colorref( fixed->color, &color_ref, FALSE );
      }
      weight = (alt_symb->weight) ? *alt_symb->weight : fixed->weight;
      style = (alt_symb->style) ? *alt_symb->style : fixed->style;
   }
   else
   {
      WLpack_index_colorref( fixed->color, &color_ref, FALSE );
      weight = fixed->weight;
      style = fixed->style;
   }

   SETUP_FOR_SINGLE_DISPLAY;

   if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
   {
      dl_options |= DL_OPT_FILL;
      sts = DLdraw_3D_polygons_f( dp_info->gragad->gpipe_id,
                                  curve_ptrs.points, 
                                  ( int *) curve_ptrs.num_points, 1,
                                  color_ref, style, blend, 
                                  weight, dl_options );
   }
   else
   {
      sts = DLdraw_3D_line_string_f( dp_info->gragad->gpipe_id,
                                     curve_ptrs.points, *curve_ptrs.num_points,
                                     color_ref, style, blend, 
                                     weight, dl_options );
   }

   RESTORE_FROM_SINGLE_DISPLAY;

   if ( sts != DL_SUCCESS )
   {
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_display_curve */

/*--- DPdlist_display_text -------------------------------------------------*/

int DPdlist_display_text(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   DPdlist_display_text

DESCRIPTION
   This function displays a text element from the display list.

SYNOPSIS
   int DPdlist_display_text(
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
   alt_sym (IN) - the alternate symbology for the element
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
*/


{
   register cur_num_elems;
   register void **cur_elem;
   register int cur_dl_options;
   register WLuint16 cur_blend;
   int sts;
   unsigned int *num_polys;
   unsigned int *num_lines;
   void **polys;
   void **lines;
   unsigned int *num_points;
   WLcolorref color_ref;
   int weight;
   int style;
   float *points;
   IGRdouble old_mod_matrix[16], new_mod_matrix[16];
   int num_modes;
   int dl_options[2];
   WLuint16 blend[2];
   enum GRdpmode split_modes[2];

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   if ( alt_symb )
   {
      if ( alt_symb->color )
      {
         WLpack_index_colorref( *alt_symb->color, &color_ref, FALSE );
      }
      else
      {
         WLpack_index_colorref( fixed->color, &color_ref, FALSE );
      }
      weight = (alt_symb->weight) ? *alt_symb->weight : fixed->weight;
      /* Styles in text is always 0 */
      style = 0;
   }
   else
   {
      WLpack_index_colorref( fixed->color, &color_ref, FALSE );
      weight = fixed->weight;

      /* Styles in text is always 0 */
      style = 0;
   }

   SPLIT_AND_MAP_DISPLAY_MODE( dp_mode, split_modes, num_modes, blend, dl_options );

   SETUP_FOR_SINGLE_DISPLAY;

   cur_dl_options = dl_options[0];
   cur_blend = blend[0];
   if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
   {
      cur_dl_options |= DL_OPT_FILL;

      DLIST_FTXT_NUM_POLYS_PTR( fixed->wf_data, num_polys );
      DLIST_FTXT_POLYS_PTR( fixed->wf_data, polys );

      while ( num_modes > 0 )
      {
         /* display each polygon individuallly */
         cur_num_elems = *num_polys;
         cur_elem = polys;
         while ( cur_num_elems > 0 )
         {
            DLIST_PLY_NUM_POINTS_PTR( *cur_elem, num_points );
            DLIST_PLY_POINTS_PTR( *cur_elem, points );

            sts = DLdraw_3D_polygons_f( dp_info->gragad->gpipe_id,
                                        points, (int *)num_points, 1,
                                        color_ref, style, cur_blend,
                                        weight, cur_dl_options );

            if ( sts != DL_SUCCESS )
            {
               return( DLIST_E_ERROR );
            }

            cur_dl_options |= DL_OPT_USE_LAST_SYMB;
 
            cur_elem++;
            cur_num_elems--;
         } /* end: while */

         cur_dl_options = dl_options[1];
         cur_blend = blend[1];
         num_modes--;
      }  /* end: while */
   }
   else
   {
      DLIST_TXT_NUM_LINES_PTR( fixed->wf_data, num_lines );
      DLIST_TXT_LINES_PTR( fixed->wf_data, lines );

      while ( num_modes > 0 )
      {
         /* display each line string individuallly */
         cur_num_elems = *num_lines;
         cur_elem = lines;
         while ( cur_num_elems > 0 )
         {
            DLIST_CRV_NUM_POINTS_PTR( *cur_elem, num_points );
            DLIST_CRV_POINTS_PTR( *cur_elem, points );

            sts = DLdraw_3D_line_string_f( dp_info->gragad->gpipe_id,
                                           points, *num_points,
                                           color_ref, style, cur_blend, 
                                           weight, cur_dl_options );

            if ( sts != DL_SUCCESS )
            {
               return( DLIST_E_ERROR );
            }

            cur_dl_options |= DL_OPT_USE_LAST_SYMB;

            cur_elem++;
            cur_num_elems--;
         } /* end: while */

         cur_dl_options = dl_options[1];
         cur_blend = blend[1];
         num_modes--;
      }  /* end: while */

   }  /* end: else */

   RESTORE_FROM_SINGLE_DISPLAY;

   return( DLIST_S_SUCCESS );

} /* DPdlist_display_text */

/*--- DPdlist_display_msc -----------------------------------------------*/

static int DPdlist_display_msc(
   OM_S_OBJID objid,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type,
   WLcolorref color_ref,
   int style,
   WLuint16 blend,
   int weight,
   int dl_options )

/*
NAME
   DPdlist_display_msc (static)

DESCRIPTION
   This function displays a msc curve from the display list.

SYNOPSIS
   static int DPdlist_display_msc(
      OM_S_OBJID objid,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type,
      WLcolorref color_ref,
      int style,
      WLuint16 blend,
      int weight,
      int dl_options )

PARAMETERS
   objid (IN) - the object id of the msc
   osnum (IN) - the object space number of the msc
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_sym (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix
   color_ref (IN) - the color ref for the msc
   style (IN) - the style of the msc
   blend (IN) - the blend pattern for the msc
   weight (IN) - the weight of the msc

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
*/


{
   int sts;
   IGRlong msg;
   struct DPdlist_fixed_data *fixed;
   register float *points;
   register unsigned int *flags, *num_points;
   IGRdouble mod_matrix[16];
   IGRboolean need_disyourself = TRUE;

   DPdlist_hash_lookup( objid, osnum, &fixed );

   if ( ! fixed )
   {
      /* add msc */
      if ( DPdlist_wf_fb_gragad.objid != NULL_OBJID )
      {
         sts = om$send( msg = message GRgraphics.GRadd_to_display_list
                                                 (&msg, dp_info->is_hidden_line ),
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
   else if ( (! fixed->wf_data) &&
             (fixed->ele_flags & DP_DLIST_ELE_DISPLAYABLE) &&
             (!(fixed->ele_flags & DP_DLIST_ELE_INACTIVE)) )
   {
      /* need to do something about unknown elements => so we don't */
      /* keep trying to add their strokes if they don't have any    */
      if ( DPdlist_wf_fb_gragad.objid != NULL_OBJID )
      {
         sts = om$send( msg = message GRgraphics.GRadd_to_display_list
                                                 (&msg, dp_info->is_hidden_line ),
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

   if ( (fixed) &&
        (fixed->wf_data) &&
        ( ( DPdynamic_update_in_progress && DPdlist_performance_boost ) ||
          (!(fixed->ele_flags & DP_DLIST_ELE_HAS_SOS)) ) )
   {
      DLIST_CRV_NUM_POINTS_PTR( fixed->wf_data, num_points );
      DLIST_CRV_POINTS_PTR( fixed->wf_data, points );
      DLIST_CRV_FLAGS_PTR( fixed->wf_data, flags );

      /* must check for tangent edge and rule line display */
      /* for model space counterparts                      */
      if ( (! DPdlist_display_tangent_edges) &&
           (*flags & DP_DLIST_CRV_TANGENT) )
      {
         /* not displaying tangent edges */
         return( DLIST_S_SUCCESS );
      }

      if ( (dp_info->gragad->flags & DP_NO_RULE_LINES) &&
           ( (*flags & DP_DLIST_CRV_RULE_LINE) ||
            ( (*flags & DP_DLIST_CRV_SEAM) &&
               (*flags & DP_DLIST_CRV_TANGENT) ) ) )
      {
         /* not displaying rule lines */
         return( DLIST_S_SUCCESS );
      }      

      sts = DLdraw_3D_line_string_f( dp_info->gragad->gpipe_id,
                                     points, *num_points,
                                     color_ref, style, blend, weight,
                                     dl_options );

      if ( sts == DL_SUCCESS )
      {
         need_disyourself = FALSE;
      }

   }

   /* Make sure that the MSC is not display if tangent edge display is off */
   /* and if the MSC is a tangent edge */
   if ( (fixed) &&
        (fixed->wf_data) )
   {
      DLIST_CRV_NUM_POINTS_PTR( fixed->wf_data, num_points );
      DLIST_CRV_POINTS_PTR( fixed->wf_data, points );
      DLIST_CRV_FLAGS_PTR( fixed->wf_data, flags );

      /* must check for tangent edge and rule line display */
      /* for model space counterparts                      */
      if ( (! DPdlist_display_tangent_edges) &&
           (*flags & DP_DLIST_CRV_TANGENT) )
      {
         /* not displaying tangent edges */
         need_disyourself = FALSE;
      }
   }
   
   if ( need_disyourself )
   {
      /* didn't display from display list => must send message to display */
      DLget_modelling_matrix( dp_info->gragad->gpipe_id, mod_matrix );
      DLreset_modelling_matrix( dp_info->gragad->gpipe_id );
      sts = om$send( msg = message GRgraphics.GRdisyourself( &msg,
                                                             &matrix_type,
                                                             matrix,
                                                             &dp_mode,
                                                             alt_symb,
                                                             dp_info,
                                                             /*key*/ NULL ),
                     targetid = objid,
                     targetos = osnum,
                     senderid = NULL_OBJID );

      DLset_modelling_matrix( dp_info->gragad->gpipe_id, mod_matrix );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_display_msc */

/*--- DPdlist_display_surface ----------------------------------------------*/

int DPdlist_display_surface(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type,
   IGRint single_display )

/*
NAME
   DPdlist_display_surface

DESCRIPTION
   This function displays a surface from the display list.

SYNOPSIS
   int DPdlist_display_surface(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type,
      IGRint single_display )

PARAMETERS
   fixed (IN) - the fixed data for the surface
   osnum (IN) - the object space number of the surface
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_sym (IN) - the alternate symbology for the element
   matrix (IN) - the environment matrix for the display
   matrix_type (IN) - the type of the environment matrix
   single_display (IN) - if TRUE, then this is a single
                         display request (not an update)

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

NOTES
   For the first pass, we are not display any view dependent edges

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 S.P. Rogers
      Initial implementation
*/


{
   register unsigned int cur_num;
   register OM_S_OBJID *cur_ids;
   register void **cur_edges;
   register int cur_dl_options;
   register WLuint16 cur_blend;
   register enum GRdpmode cur_mode;
   int sts;
   int dl_options[2];
   WLuint16 blend[2];
   unsigned int *num_points;
   WLcolorref color_ref;
   int weight;
   int style;
   float *points;
   unsigned int *num_vi_edges, *num_vi_msc_edges, *num_sub_edges, *num_sub_msc_ids;
   unsigned int *flags;
   void **vi_edges, **sub_edges;
   OM_S_OBJID *vi_msc_edges, *sub_msc_ids;
   IGRdouble old_mod_matrix[16], new_mod_matrix[16];
   int num_modes;
   enum GRdpmode split_modes[2];

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   if ( alt_symb )
   {
      if ( alt_symb->color )
      {
         WLpack_index_colorref( *alt_symb->color, &color_ref, FALSE );
      }
      else
      {
         WLpack_index_colorref( fixed->color, &color_ref, FALSE );
      }
      weight = (alt_symb->weight) ? *alt_symb->weight : fixed->weight;
      style = (alt_symb->style) ? *alt_symb->style : fixed->style;
   }
   else
   {
      WLpack_index_colorref( fixed->color, &color_ref, FALSE );
      weight = fixed->weight;
      style = fixed->style;
   }

   DLIST_SRF_NUM_VI_EDGES_PTR( fixed->wf_data, num_vi_edges );
   if ( *num_vi_edges )
   {
      DLIST_SRF_VI_EDGES_PTR( fixed->wf_data, vi_edges );
   }

   DLIST_SRF_NUM_VI_MSC_EDGES_PTR( fixed->wf_data, num_vi_msc_edges );
   if ( *num_vi_msc_edges )
   {
      DLIST_SRF_VI_MSC_EDGES_PTR( fixed->wf_data, vi_msc_edges, *num_vi_edges );
   }

   SPLIT_AND_MAP_DISPLAY_MODE( dp_mode, split_modes, num_modes, blend, dl_options );

   SETUP_FOR_SINGLE_DISPLAY;

   cur_mode = split_modes[0];
   cur_dl_options = dl_options[0];
   cur_blend = blend[0];
   while ( num_modes > 0 )
   {
      /* display each vi edge */
      cur_num = *num_vi_edges;
      cur_edges = vi_edges;
      while ( cur_num > 0 )
      {
         DLIST_CRV_NUM_POINTS_PTR( *cur_edges, num_points );
         DLIST_CRV_POINTS_PTR( *cur_edges, points );
         DLIST_CRV_FLAGS_PTR( *cur_edges, flags );

         if ( (! DPdlist_display_tangent_edges) &&
              (*flags & DP_DLIST_CRV_TANGENT) )
         {
            /* not displaying tangent edges */
            goto next_vi_edge;
         }

         if ( (dp_info->gragad->flags & DP_NO_RULE_LINES) &&
              ( (*flags & DP_DLIST_CRV_RULE_LINE) ||
                ( (*flags & DP_DLIST_CRV_SEAM) &&
               (*flags & DP_DLIST_CRV_TANGENT) ) ) )
         {
            /* not displaying rule lines */
            goto next_vi_edge;
         }      

         DLdraw_3D_line_string_f( dp_info->gragad->gpipe_id,
                                  points, *num_points,
                                  color_ref, style, cur_blend,
                                  weight, cur_dl_options );
   
         cur_dl_options |= DL_OPT_USE_LAST_SYMB;

next_vi_edge:
         cur_edges++;
         cur_num--;
      } /* end: while */

      /* Display all the subordinate edges if required */
      if ( single_display & DP_DLIST_DISPLAY_ALL_EDGES )
      {
         DLIST_SRF_NUM_SUB_EDGES_PTR( fixed->wf_data, num_sub_edges );
         if ( *num_sub_edges )
         {
            DLIST_SRF_SUB_EDGES_PTR( fixed->wf_data, sub_edges, *num_vi_edges, *num_vi_msc_edges );
         }

         DLIST_SRF_NUM_SUB_MSC_PTR( fixed->wf_data, num_sub_msc_ids );
         if ( *num_sub_msc_ids )
         {
            DLIST_SRF_SUB_MSC_PTR( fixed->wf_data, sub_msc_ids, *num_vi_edges, *num_vi_msc_edges, *num_sub_edges );
         }

         /* display each subordinate edge */
         cur_num = *num_sub_edges;
         cur_edges = sub_edges;
         while ( cur_num > 0 )
         {
            DLIST_CRV_NUM_POINTS_PTR( *cur_edges, num_points );
            DLIST_CRV_POINTS_PTR( *cur_edges, points );
            DLIST_CRV_FLAGS_PTR( *cur_edges, flags );

            if ( (! DPdlist_display_tangent_edges) &&
                 (*flags & DP_DLIST_CRV_TANGENT) )
            {
               /* not displaying tangent edges */
               goto next_sub_edge;
            }

            if ( (dp_info->gragad->flags & DP_NO_RULE_LINES) &&
                 ( (*flags & DP_DLIST_CRV_RULE_LINE) ||
                   ( (*flags & DP_DLIST_CRV_SEAM) &&
                     (*flags & DP_DLIST_CRV_TANGENT) ) ) )
            {
               /* not displaying rule lines */
               goto next_sub_edge;
            }      

            DLdraw_3D_line_string_f( dp_info->gragad->gpipe_id,
                                     points, *num_points,
                                     color_ref, style, cur_blend,
                                     weight, cur_dl_options );

            cur_dl_options |= DL_OPT_USE_LAST_SYMB;

next_sub_edge:
            cur_edges++;
            cur_num--;
         }

         /* display each subordinate msc edge */
         cur_num = *num_sub_msc_ids;
         cur_ids = sub_msc_ids;
         while ( cur_num > 0 )
         {
            /* always returns success */
            DPdlist_display_msc( *cur_ids, osnum,
                                 dp_info, cur_mode, alt_symb,
                                 matrix, matrix_type, 
                                 color_ref, style, cur_blend, weight,
                                 cur_dl_options );

            /* The Symbology may have changed due to Sos */
            cur_dl_options &= ~DL_OPT_USE_LAST_SYMB;

            cur_ids++;
            cur_num--;
         } /* end: for */

      }

      /* display each msc vi edge */
      cur_num = *num_vi_msc_edges;
      cur_ids = vi_msc_edges;
      while ( cur_num > 0 )
      {
         /* always returns success */
         DPdlist_display_msc( *cur_ids, osnum,
                              dp_info, cur_mode, alt_symb,
                              matrix, matrix_type, 
                              color_ref, style, cur_blend, weight,
                              cur_dl_options );

         /* The Symbology may have changed due to Sos */
         cur_dl_options &= ~DL_OPT_USE_LAST_SYMB;

         cur_ids++;
         cur_num--;
      }

      cur_dl_options = dl_options[1];
      cur_blend = blend[1];
      cur_mode = split_modes[1];
      num_modes--;
   }  /* end: while */

   RESTORE_FROM_SINGLE_DISPLAY;

   return( DLIST_S_SUCCESS );

} /* DPdlist_display_surface */

/*--- DPdlist_display_unknown ----------------------------------------------*/

int DPdlist_display_unknown(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   struct DP_information *dp_info,
   enum GRdpmode dp_mode,
   struct IGRaltdisplay *alt_symb,
   IGRmatrix matrix,
   IGRshort matrix_type )

/*
NAME
   DPdlist_display_unknown

DESCRIPTION
   This function displays an unknown element from the display list.

SYNOPSIS
   int DPdlist_display_unknown(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      struct DP_information *dp_info,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb,
      IGRmatrix matrix,
      IGRshort matrix_type )

PARAMETERS
   fixed (IN) - the fixed data for the unknown element
   osnum (IN) - the object space number of the unknown element
   dp_info (IN) - the display information
   dp_mode (IN) - the display mode
   alt_sym (IN) - the alternate symbology for the element
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
*/


{
   int sts;
   struct DPdlist_unknown_variable unknown_ptrs;
   IGRdouble old_mod_matrix[16], new_mod_matrix[16];

   if ( !fixed->wf_data )
   {
      return( DLIST_E_ERROR );
   }

   DLIST_UNK_ALL_PTRS( fixed->wf_data, unknown_ptrs );

   if ( *unknown_ptrs.disp_func )
   {
      SETUP_FOR_SINGLE_DISPLAY;

      /* display function exists, call it */
      sts = (*(*unknown_ptrs.disp_func))( fixed->objid, osnum,
                                   *unknown_ptrs.data,
                                   dp_info, matrix, matrix_type,
                                   dp_mode, alt_symb );

      RESTORE_FROM_SINGLE_DISPLAY;

      if ( !(1 & sts) )
      {
         return( sts );
      }
      else
      {
         return( DLIST_S_SUCCESS );
      }
   }

   /* no display function */
   return( DLIST_E_ERROR );     

} /* DPdlist_display_unknown */

/*--- DPdlist_display_element ----------------------------------------------*/

int DPdlist_display_element( 
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
   DPdlist_display_element

DESCRIPTION
   This function will display an element from the display
   list.

SYNOPSIS
   int DPdlist_display_element( 
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
*/

{
   int sts;
   IGRlong msg;
   struct DPdlist_fixed_data *fixed = NULL;
   IGRboolean need_disyourself = TRUE;
   IGRdouble mod_matrix[16];
#if defined( ENV5 )
   IGRint events;
   IGRint button_win, x, y, button, trans, timetag;
#elif defined( X11 )
   XEvent ev;
   extern Display *EXdisplay;
#endif
  
   if ( ! DPdlist_use_display_list )
   {
      /* display lists are turned off => return an error and let    */
      /* the GRdisyourself method that called us handle the display */
      return( DLIST_E_ERROR );
   }

   if ( (DPdlist_sending_display_back) && (dp_info->is_update) && (matrix_type != MAIDMX) )
   {
      /* we are sending a display back to an element during an update and the    */
      /* module env. is not an identity => defer the display back to this object */
      /* so the matrices are correct                                             */
      return( DLIST_E_ERROR );
   }

   /* Honor the stop sign if update is in progress */
   if ( dp_info->is_update || ( dp_mode == GRhd ) || ( dp_mode == GRhdo ) ||
        ( dp_mode == GRhhd ) || ( dp_mode == GRhhdo ) )
   {
      if ( IGEstop() )
      {
         return( DLIST_E_ERROR );
      }
   }

   if ( ( !dynamics_in_progress ) &&
        ( ( dp_mode == GRhd ) || ( dp_mode == GRhdo ) ||
          ( dp_mode == GRhhd ) || ( dp_mode == GRhhdo ) ) )
   {
#if defined( ENV5 )
      EX_inq_events( &events );
      if ( events & BUTTON_EVENT )
      {
         EX_inq_button_data( &button_win, &x, &y, &button, &trans, &timetag );
         if ( EX_is_button_defined( button, trans ) )
         {
            return( DLIST_E_ERROR );
         }
         EX_get_button_data( &button_win, &x, &y, &button, &trans, &timetag );
      }
#elif defined( X11 )
      if ( JNL_XCheckMaskEvent( EXdisplay, ButtonPressMask, &ev ) )

      {
         JNL_XPutBackEvent( EXdisplay, &ev );
         return( DLIST_E_ERROR );
      }
#endif
   }

   display_element = DPdlist_display_element;

   if ( (!(dp_info->gragad->flags & DPVIEW_DYNAMICS)) &&
        (!dp_info->is_fit) )
   {
      if ( dp_info->is_hidden_line )
      {
         if ( DPdlist_display_element_sh )
         {
            /* shading display request => call shading function */
            sts = (*DPdlist_display_element_sh)( objid, osnum, dp_info, matrix,
                                                 matrix_type, dp_mode, alt_symb,
                                                 key, single_display );

            if ( (1 & sts) )
            {
               need_disyourself = FALSE;
            }
         }
      }
      else
      {
         /* we aren't loading a feedback buffer and we aren't doing */
         /* a FIT request and we aren't doing shading, try and      */
         /* display from the display list                           */
         sts = DPdlist_hash_lookup( objid, osnum, &fixed );
   
         if ( ! fixed )
         {
            if ( single_display & DP_DLIST_DISPLAY_SINGLE_ELEMENT )
            {
               /* don't create data on a single display => return an error */
               /* and let the GRdisyourself method who called us handle    */
               /* the display of this element                              */
               return( DLIST_E_ERROR );
            }

            if ( DPdlist_wf_fb_gragad.objid != NULL_OBJID )
            {
               sts = om$send( msg = message GRgraphics.GRadd_to_display_list
                                                       (&msg, dp_info->is_hidden_line ),
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
         else if ( (! fixed->wf_data) &&
                   (fixed->ele_flags & DP_DLIST_ELE_DISPLAYABLE) &&
                   (!(fixed->ele_flags & DP_DLIST_ELE_INACTIVE)) &&
                   (!(fixed->ele_flags & UNSUPPORTED_FLAGS)) )
         {
            /* need to do something about unknown elements => so we don't */
            /* keep trying to add their strokes if they don't have any    */

            if ( single_display & DP_DLIST_DISPLAY_SINGLE_ELEMENT )
            {
               /* don't create data on a single display => return an error */
               /* and let the GRdisyourself method who called us handle    */
               /* the display of this element                              */
               return( DLIST_E_ERROR );
            }

            if ( DPdlist_wf_fb_gragad.objid != NULL_OBJID )
            {
               sts = om$send( msg = message GRgraphics.GRadd_to_display_list
                                                       (&msg, dp_info->is_hidden_line ),
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

            if ( (fixed->wf_data) &&
                 !(fixed->ele_flags & UNSUPPORTED_FLAGS) &&
                 ( ( DPdynamic_update_in_progress && DPdlist_performance_boost ) ||
                   (!(fixed->ele_flags & DP_DLIST_ELE_HAS_SOS)) ) )
            {
               switch( fixed->type )
               {
                  case DP_DLIST_POINT :
                     sts = DPdlist_display_point( fixed, osnum, dp_info,
                                                  dp_mode, alt_symb,
                                                  matrix, matrix_type );
                     break;
  
                  case DP_DLIST_POLYGON :
                     sts = DPdlist_display_polygon( fixed, osnum, dp_info,
                                                    dp_mode, alt_symb,
                                                    matrix, matrix_type );
                     break;

                  case DP_DLIST_CURVE :
                     if ( (DPdynamic_update_in_progress && DPdlist_performance_boost) ||
                          (!(fixed->ele_flags & DP_DLIST_ELE_DISPLAY_POLYGON)) )
                     {
                        sts = DPdlist_display_curve( fixed, osnum, dp_info,
                                                     dp_mode, alt_symb,
                                                     matrix, matrix_type );
                     }
                     else
                     {
                        sts = DLIST_E_ERROR;
                     }
                     break;
   
                  case DP_DLIST_TEXT :
                     sts = DPdlist_display_text( fixed, osnum, dp_info,
                                                 dp_mode, alt_symb,
                                                 matrix, matrix_type );
                     break;

                  case DP_DLIST_SURFACE :
                     if ( (DPdynamic_update_in_progress && DPdlist_performance_boost) ||
                           (! (fixed->ele_flags & 
                               (DP_DLIST_ELE_HAS_GRALOOPS |
                                DP_DLIST_ELE_HAS_HORIZON_CURVES |
                                DP_DLIST_ELE_DISPLAY_POLYGON) ) ) )
                     {
                        sts = DPdlist_display_surface( fixed, osnum, dp_info,
                                                       dp_mode, alt_symb,
                                                       matrix, matrix_type, single_display );
                     }
                     else
                     {
                        sts = DLIST_E_ERROR;
                     }
                     break;

                  case DP_DLIST_DIMENSION :
                     /* dimension owner => if performance boost is on don't display it */
                     /* otherwise defer the display to the dimension owner             */
                     sts = (DPdynamic_update_in_progress && DPdlist_performance_boost) ?
                        DLIST_S_SUCCESS  : DLIST_E_ERROR;
                     break;

                  case DP_DLIST_UNKNOWN :
                     sts = DPdlist_display_unknown( fixed, osnum, dp_info,
                                                    dp_mode, alt_symb,
                                                    matrix, matrix_type );
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
      }
   }

   if ( need_disyourself )
   {
      if ( (single_display & DP_DLIST_DISPLAY_SINGLE_ELEMENT) ||
           (!(single_display & DP_DLIST_DISPLAY_FROM_RTREE)) )
      {
         /* let the GRdisyourself method who called us handle */
         /* the display of this element                       */
         return( DLIST_E_ERROR );
      }

      /* didn't display from display list => must send message to display */
      DLget_modelling_matrix( dp_info->gragad->gpipe_id, mod_matrix );
      DLreset_modelling_matrix( dp_info->gragad->gpipe_id );
      sts = om$send( msg = message GRgraphics.GRdisyourself( &msg,
                                                             &matrix_type,
                                                             matrix,
                                                             &dp_mode,
                                                             alt_symb,
                                                             dp_info,
                                                             key ),
                     targetid = objid,
                     targetos = osnum,
                     senderid = NULL_OBJID );

      DLset_modelling_matrix( dp_info->gragad->gpipe_id, mod_matrix );
      return( sts );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_display_element */

/*--- DPdlist_display_element_update ----------------------------------------------*/

int DPdlist_display_element_update( 
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
   DPdlist_display_element_update

DESCRIPTION
   This function will display an element from the display
   list.

SYNOPSIS
   int DPdlist_display_element_update( 
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
*/

{
   int sts;
   IGRlong msg;
   struct DPdlist_fixed_data *fixed = NULL;
   IGRboolean need_disyourself = TRUE;
   IGRboolean skipping_surf_or_skpoint = FALSE;
   IGRdouble mod_matrix[16];
  
   /* Honor the stop sign if update is in progress */
   if ( IGEstop() )
   {
      return( DLIST_E_ERROR );
   }

   if ( (DPdlist_sending_display_back) && (matrix_type != MAIDMX) )
   {
      /* we are sending a display back to an element during an update and the    */
      /* module env. is not an identity => defer the display back to this object */
      /* so the matrices are correct                                             */
      return( DLIST_E_ERROR );
   }

   display_element = DPdlist_display_element_update;

   if ( dp_info->is_hidden_line )
   {
      if ( DPdlist_display_element_sh )
      {
         /* shading display request => call shading function */
         sts = (*DPdlist_display_element_sh)( objid, osnum, dp_info, matrix,
                                              matrix_type, dp_mode, alt_symb,
                                              key, single_display );
         if ( (1 & sts) )
         {
            need_disyourself = FALSE;
         }
      }
   }
   else
   {
      sts = DPdlist_hash_lookup( objid, osnum, &fixed );
 
      if ( ! fixed )
      {
         if ( DPdlist_wf_fb_gragad.objid != NULL_OBJID )
         {
            sts = om$send( msg = message GRgraphics.GRadd_to_display_list
                                                    (&msg, dp_info->is_hidden_line ),
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
      else if ( (! fixed->wf_data) &&
                (fixed->ele_flags & DP_DLIST_ELE_DISPLAYABLE) &&
                (!(fixed->ele_flags & DP_DLIST_ELE_INACTIVE)) &&
                (!(fixed->ele_flags & UNSUPPORTED_FLAGS)) )
      {
         /* need to do something about unknown elements => so we don't */
         /* keep trying to add their strokes if they don't have any    */

         if ( DPdlist_wf_fb_gragad.objid != NULL_OBJID )
         {
            sts = om$send( msg = message GRgraphics.GRadd_to_display_list
                                                    (&msg, dp_info->is_hidden_line ),
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
              ( (!(fixed->ele_flags & DP_DLIST_ELE_DISPLAYABLE)) ) )
         {
            /* element is not on a displayed layer or is not */
            /* displayable or is not an active surface       */
            return( DLIST_S_SUCCESS );
         }

         if ( (fixed->wf_data) &&
              !(fixed->ele_flags & UNSUPPORTED_FLAGS) &&
              ( ( DPdynamic_update_in_progress && DPdlist_performance_boost ) ||
                (!(fixed->ele_flags & DP_DLIST_ELE_HAS_SOS)) ) )
         {
            switch( fixed->type )
            {
               case DP_DLIST_POINT :
                  sts = DPdlist_display_point( fixed, osnum, dp_info,
                                               dp_mode, alt_symb,
                                               matrix, matrix_type );
                  break;
  
               case DP_DLIST_POLYGON :
                  sts = DPdlist_display_polygon( fixed, osnum, dp_info,
                                                 dp_mode, alt_symb,
                                                 matrix, matrix_type );
                  break;

               case DP_DLIST_CURVE :
                  if ( (DPdynamic_update_in_progress && DPdlist_performance_boost) ||
                       (!(fixed->ele_flags & DP_DLIST_ELE_DISPLAY_POLYGON)) )
                  {
                     sts = DPdlist_display_curve( fixed, osnum, dp_info,
                                                  dp_mode, alt_symb,
                                                  matrix, matrix_type );
                  }
                  else
                  {
                     sts = DLIST_E_ERROR;
                  }
                  break;
   
               case DP_DLIST_TEXT :
                  sts = DPdlist_display_text( fixed, osnum, dp_info,
                                              dp_mode, alt_symb,
                                              matrix, matrix_type );
                  break;

               case DP_DLIST_SURFACE :
                  if ( (DPdynamic_update_in_progress && DPdlist_performance_boost) ||
                        (! (fixed->ele_flags & 
                            (DP_DLIST_ELE_HAS_GRALOOPS |
                             DP_DLIST_ELE_HAS_HORIZON_CURVES |
                             DP_DLIST_ELE_DISPLAY_POLYGON) ) ) )
                  {
                     sts = DPdlist_display_surface( fixed, osnum, dp_info,
                                                    dp_mode, alt_symb,
                                                    matrix, matrix_type, single_display );
                  }
                  else
                  {
                     skipping_surf_or_skpoint = TRUE;
                     sts = DLIST_E_ERROR;
                  }
                  break;

               case DP_DLIST_DIMENSION :
                  /* dimension owner => if performance boost is on don't display it */
                  /* otherwise defer the display to the dimension owner             */
                  sts = (DPdynamic_update_in_progress && DPdlist_performance_boost) ?
                     DLIST_S_SUCCESS  : DLIST_E_ERROR;
                  break;

               case DP_DLIST_UNKNOWN :
                  sts = DPdlist_display_unknown( fixed, osnum, dp_info,
                                                 dp_mode, alt_symb,
                                                 matrix, matrix_type );
                  break;

               case DP_DLIST_SKPOINT :
                  sts = DLIST_E_ERROR;
                  skipping_surf_or_skpoint = TRUE;
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
   }

   if ( need_disyourself )
   {
      /* didn't display from display list => must send message to display */
      DLget_modelling_matrix( dp_info->gragad->gpipe_id, mod_matrix );
      DLreset_modelling_matrix( dp_info->gragad->gpipe_id );
      DPdlist_sending_display_back = skipping_surf_or_skpoint;
      sts = om$send( msg = message GRgraphics.GRdisyourself( &msg,
                                                             &matrix_type,
                                                             matrix,
                                                             &dp_mode,
                                                             alt_symb,
                                                             dp_info,
                                                             key ),
                     targetid = objid,
                     targetos = osnum,
                     senderid = NULL_OBJID );

      DPdlist_sending_display_back = FALSE;
      DLset_modelling_matrix( dp_info->gragad->gpipe_id, mod_matrix );
      return( sts );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_display_element_update */

end implementation Root;
