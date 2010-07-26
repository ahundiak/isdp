#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"

#include "DEso.h"

#include "DPdlist.h"

static short DPdlist_building_text = FALSE;
static short DPdlist_building_surface = FALSE;

/* New Prototypes */
PROTO_DPdlist_add_point
PROTO_DPdlist_add_polygon
PROTO_DPdlist_add_curve
PROTO_DPdlist_add_text
PROTO_DPdlist_finish_text
PROTO_DPdlist_add_curve_to_text
PROTO_DPdlist_add_polygon_to_text
PROTO_DPdlist_add_surface
PROTO_DPdlist_finish_surface
PROTO_DPdlist_add_edge_to_surface
PROTO_DPdlist_add_msc_edge_to_surface
PROTO_DPdlist_add_unknown
PROTO_DPdlist_alloc_chunk
PROTO_DPdlist_hash_add
PROTO_DPdlist_init_set_arrays
PROTO_DPdlist_get_pointer_sets
PROTO_DPdlist_get_sub_pointer_sets
PROTO_DPdlist_get_objid_sets
PROTO_DPdlist_get_sub_objid_sets
PROTO_DPdlist_add_pointer_to_set
PROTO_DPdlist_add_sub_pointer_to_set
PROTO_DPdlist_add_objid_to_set
PROTO_DPdlist_add_sub_objid_to_set
PROTO_DPdlist_add_dimension
PROTO_DPdlist_add_skpoint
PROTO_DPdlist_init_mesh_array
PROTO_DPdlist_get_mesh_set


/*--- DPdlist_add_point ----------------------------------------------------*/

int DPdlist_add_point(
   OM_S_OBJID objid,
   OMuword osnum,
   unsigned short ele_flags,
   IGRshort color,
   IGRchar style,
   IGRchar weight,
   IGRshort layer,
   IGRdouble point[3] )

/*
NAME
   DPdlist_add_point

DESCRIPTION
   This function adds a point to the display list.

SYNOPSIS
   int DPdlist_add_point(
      OM_S_OBJID objid,
      OMuword osnum,
      unsigned short ele_flags,
      IGRshort color,
      IGRchar style,
      IGRchar weight,
      IGRshort layer,
      IGRdouble point[3] )

PARAMETERS
   objid (IN) - the object id of the point to add
   osnum (IN) - the object space number of the point
   ele_flags (IN) - the element flags for the point
   color (IN) - the logical color of the point
   style (IN) - the logical style of the point
   weight (IN) - the weight of the point
   layer (IN) - the layer of the point
   point (IN) - the point geometry

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;
   unsigned int byte_size;
   struct DPdlist_fixed_data *fixed_data;
   struct DPdlist_point_variable point_ptrs;

   sts = DPdlist_hash_add( objid, osnum, &fixed_data );

   if ( ! fixed_data )
   {
      return( DLIST_E_ERROR );
   }

   byte_size = DLIST_SIZEOF_PNT( ele_flags );

   sts = DPdlist_alloc_chunk( byte_size, &fixed_data->wf_data );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   DLIST_PNT_ALL_PTRS( fixed_data->wf_data, point_ptrs );

   *(point_ptrs.byte_size) = byte_size;
   point_ptrs.point[0] = point[0];
   point_ptrs.point[1] = point[1];
   point_ptrs.point[2] = point[2];
   
   fixed_data->type = DP_DLIST_POINT;
   fixed_data->ele_flags = ele_flags;
   fixed_data->color = color;
   fixed_data->style = style;
   fixed_data->weight = weight;
   fixed_data->layer = layer;
   fixed_data->sh_data = NULL;

   return( DLIST_S_SUCCESS );
}  /* DPdlist_add_point */

/*--- DPdlist_add_polygon --------------------------------------------------*/

int DPdlist_add_polygon(
   OM_S_OBJID objid,
   OMuword osnum,
   unsigned short ele_flags,
   IGRshort color,
   IGRchar style,
   IGRchar weight,
   IGRshort layer,
   IGRuint num_points,
   IGRdouble *points )

/*
NAME
   DPdlist_add_polygon

DESCRIPTION
   This function adds a polygon to the display list.

SYNOPSIS
   int DPdlist_add_polygon(
      OM_S_OBJID objid,
      OMuword osnum,
      unsigned short ele_flags,
      IGRshort color,
      IGRchar style,
      IGRchar weight,
      IGRshort layer,
      IGRuint num_points,
      IGRdouble *points )

PARAMETERS
   objid (IN) - the object id of the polygon to add
   osnum (IN) - the object space number
   ele_flags (IN) - the element flags of the polygon
   color (IN) - the logical color of the polygon
   style (IN) - the logical style of the polygon
   weight (IN) - the weight of the polygon
   layer (IN) - the layer of the polygon
   num_points (IN) - the number of point in the polygon
   points (IN) - the points of the polygon

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;
   unsigned int byte_size;
   float *dl_points;
   struct DPdlist_fixed_data *fixed_data;
   struct DPdlist_polygon_variable polygon_ptrs;

   /* Disable all filled display according to ERB 2/12/94*/
   if ( ele_flags & DP_DLIST_ELE_FILLED )
   {
      return( DLIST_E_ERROR );
   }

   sts = DPdlist_hash_add( objid, osnum, &fixed_data );

   if ( ! fixed_data )
   {
      return( DLIST_E_ERROR );
   }

   byte_size = DLIST_SIZEOF_PLY( num_points, ele_flags );

   sts = DPdlist_alloc_chunk( byte_size, &fixed_data->wf_data );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   DLIST_PLY_ALL_PTRS( fixed_data->wf_data, polygon_ptrs );

   *(polygon_ptrs.byte_size) = byte_size;
   *(polygon_ptrs.num_points) = num_points;

   dl_points = polygon_ptrs.points;
   while ( num_points )
   {
      *dl_points = *points;
      *(dl_points + 1) = *(points + 1);
      *(dl_points + 2)= *(points + 2);

      dl_points += 3;
      points += 3;
      num_points--;
   }
   
   fixed_data->type = DP_DLIST_POLYGON;
   fixed_data->ele_flags = ele_flags;
   fixed_data->color = color;
   fixed_data->style = style;
   fixed_data->weight = weight;
   fixed_data->layer = layer;
   fixed_data->sh_data = NULL;

   return( DLIST_S_SUCCESS );
} /* DPdlist_add_polygon */

/*--- DPdlist_add_curve ----------------------------------------------------*/

int DPdlist_add_curve(
   OM_S_OBJID objid,
   OMuword osnum,
   unsigned short ele_flags,
   IGRshort color,
   IGRchar style,
   IGRchar weight,
   IGRshort layer,
   IGRuint num_points,
   IGRdouble *points )

/*
NAME
   DPdlist_add_curve

DESCRIPTION
   This function adds a curve to the display list.

SYNOPSIS
   int DPdlist_add_curve(
      OM_S_OBJID objid,
      OMuword osnum,
      unsigned short ele_flags,
      IGRshort color,
      IGRchar style,
      IGRchar weight,
      IGRshort layer,
      IGRuint num_points,
      IGRdouble *points );

PARAMETERS
   objid (IN) - the object id of the curve to add
   osnum (IN) - the object space number
   ele_flags (IN) - the element flags of the curve
   num_points (IN) - the number of point in the curve
   points (IN) - the points of the curve

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;
   unsigned int byte_size;
   unsigned int curve_flags = 0;
   float *dl_points;
   struct DPdlist_fixed_data *fixed_data;
   struct DPdlist_curve_variable curve_ptrs;

   sts = DPdlist_hash_add( objid, osnum, &fixed_data );

   if ( ! fixed_data )
   {
      return( DLIST_E_ERROR );
   }

   byte_size = DLIST_SIZEOF_CRV( num_points, ele_flags );

   sts = DPdlist_alloc_chunk( byte_size, &fixed_data->wf_data );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   DLIST_CRV_ALL_PTRS( fixed_data->wf_data, curve_ptrs );

   if ( ele_flags & DP_DLIST_ELE_IS_MSC )
   {
      HSdlist_get_msc_flags( objid, osnum, &curve_flags );
   }

   *(curve_ptrs.byte_size) = byte_size;
   *(curve_ptrs.flags) = curve_flags | DP_DLIST_CRV_WIREFRAME;
   *(curve_ptrs.num_points) = num_points;

   dl_points = curve_ptrs.points;
   while ( num_points )
   {
      *dl_points = *points;
      *(dl_points + 1) = *(points + 1);
      *(dl_points + 2)= *(points + 2);

      dl_points += 3;
      points += 3;
      num_points--;
   }
   
   fixed_data->type = DP_DLIST_CURVE;
   fixed_data->ele_flags = ele_flags;
   fixed_data->color = color;
   fixed_data->style = style;
   fixed_data->weight = weight;
   fixed_data->layer = layer;
   fixed_data->sh_data = NULL;

   return( DLIST_S_SUCCESS );
} /* DPdlist_add_curve */

/*--- DPdlist_add_SO_data ------------------------------------------------*/

/*ARGSUSED*/
int DPdlist_add_SO_data(
   OM_S_OBJID objid,
   OMuword osnum,
   int num_SOs,
   DEsoe *SOs )

/*
NAME
   DPdlist_add_SO_data

DESCRIPTION
   This function adds SO data to a wireframe element in the display list

SYNOPSIS
   int DPdlist_add_SO_data(
      OM_S_OBJID objid,
      OMuword osnum,
      int num_SOs,
      DEsoe *SOs )

PARAMETERS
   objid (IN) - the object id of the element with the SOs
   osnum (IN) - the object space number of the element
   num_SOs (IN) - the number of SOs to be added
   SOs (IN) - the SOs

GLOBALS USED
  none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   /* not implemented in 2.4 */
   return( DLIST_E_ERROR );
} /* DPdlist_add_SO_data */

/*--- DPdlist_add_text ---------------------------------------------------*/

int DPdlist_add_text(
   OM_S_OBJID objid,
   OMuword osnum,
   unsigned short ele_flags,
   IGRshort color,
   IGRchar style,
   IGRchar weight,
   IGRshort layer,
   struct DPdlist_fixed_data **fixed_data )

/*
NAME
  DPdlist_add_text()

DESCRIPTION
   This function adds a text element to the display list.  After this function
   is called, the functions to add curves or polygons to the text element
   must be called.  Finally, DPdlist_finish_text() must be called.

SYNOPSIS
   int DPdlist_add_text(
      OM_S_OBJID objid,
      OMuword osnum,
      unsigned short ele_flags,
      IGRshort color,
      IGRchar style,
      IGRchar weight,
      IGRshort layer,
      struct DPdlist_fixed_data **fixed_data )

PARAMETERS
   objid (IN) - the object id of the text element to add
   osnum (IN) - the object space number of the text
   ele_flags (IN) - the element flags for the text
   color (IN) - the logical color of the text
   style (IN) - the logical style of the text
   weight (IN) - the weight of the text
   layer (IN) - the layer of the text
   fixed_data (OUT) - the fixed data pointer for the text

GLOBALS USED
   DPdlist_building_text

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;


   /* Disable all filled display according to ERB 2/12/94*/
   if ( ele_flags & DP_DLIST_ELE_FILLED )
   {
      return( DLIST_E_ERROR );
   }

   sts = DPdlist_hash_add( objid, osnum, fixed_data );

   if ( ! (*fixed_data) )
   {
      return( DLIST_E_ERROR );
   }

   (*fixed_data)->type = DP_DLIST_TEXT;
   (*fixed_data)->ele_flags = ele_flags;
   (*fixed_data)->color = color;
   (*fixed_data)->style = style;
   (*fixed_data)->weight = weight;
   (*fixed_data)->layer = layer;
   (*fixed_data)->sh_data = NULL;

   sts = DPdlist_init_set_arrays();
   if ( !(1 & sts) )
   {
      return( DLIST_E_ERROR );
   }

   DPdlist_building_text = TRUE;
   return( DLIST_S_SUCCESS );

} /* DPdlist_add_text */

/*--- DPdlist_finish_text --------------------------------------------------*/

int DPdlist_finish_text(
   struct DPdlist_fixed_data *fixed_data )

/*
NAME
   DPdlist_finish_text()

DESCRIPTION
   This function competes the addition of a text element to the display list.

SYNOPSIS
   int DPdlist_finish_text(
      struct DPdlist_fixed_data *fixed_data )

PARAMETERS
   fixed_data (IN) - the fixed data header for the text element

GLOBALS USED
   DPdlist_building_text

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;
   unsigned int num_vi, num_vd;
   void **vi_ptrs, **vd_ptrs;
   unsigned int byte_size;
   struct DPdlist_filled_text_variable ftext_ptrs;
   struct DPdlist_text_variable text_ptrs;

   if ( ! DPdlist_building_text )
   {
      return( DLIST_E_ERROR );
   }

   sts = DPdlist_get_pointer_sets( &num_vi, &vi_ptrs, &num_vd, &vd_ptrs );
   if ( !(1 & sts) )
   {
      return( DLIST_E_ERROR );
   }

   if ( fixed_data->ele_flags & DP_DLIST_ELE_FILLED )
   {
      byte_size = DLIST_SIZEOF_FTXT( num_vi, fixed_data->ele_flags );

      sts = DPdlist_alloc_chunk( byte_size, &fixed_data->wf_data );
      if ( !(1 & sts) )
      {
         return( sts );
      }

      DLIST_FTXT_ALL_PTRS( fixed_data->wf_data, ftext_ptrs );

      *(ftext_ptrs.byte_size) = byte_size;
      *(ftext_ptrs.num_polys) = num_vi;

      memcpy( ftext_ptrs.polys, vi_ptrs, num_vi * sizeof( void * ) );
   }
   else
   {
      byte_size = DLIST_SIZEOF_TXT( num_vi, fixed_data->ele_flags );

      sts = DPdlist_alloc_chunk( byte_size, &fixed_data->wf_data );
      if ( !(1 & sts) )
      {
         return( sts );
      }

      DLIST_TXT_ALL_PTRS( fixed_data->wf_data, text_ptrs );

      *(text_ptrs.byte_size) = byte_size;
      *(text_ptrs.num_lines) = num_vi;

      memcpy( text_ptrs.lines, vi_ptrs, num_vi * sizeof( void * ) );
   }

   DPdlist_building_text = FALSE;

   return( DLIST_S_SUCCESS );
} /* DPdlist_finish_text */

/*--- DPdlist_add_curve_to_text --------------------------------------------*/

int DPdlist_add_curve_to_text(
   struct DPdlist_fixed_data *fixed_data,
   IGRuint num_points,
   IGRdouble *points )

/*
NAME
   DPdlist_add_curve_to_text()

DESCRIPTION
   This function adds a curve to a text element

SYNOPSIS
   int DPdlist_add_curve_to_text(
      struct DPdlist_fixed_data *fixed_data )
      IGRuint num_points,
      IGRdouble *points )

PARAMETERS
   fixed_data (IN) - the fixed data for the text element
   num_points (IN) - the number of points in the curve
   points (IN) - the points of the curve

GLOBALS USED
   DPdlist_building_text

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;
   unsigned int byte_size;
   float *dl_points;
   void *chunk;
   struct DPdlist_curve_variable curve_ptrs;

   if ( ! DPdlist_building_text )
   {
     return( DLIST_E_ERROR );
   }

   if ( fixed_data->ele_flags & DP_DLIST_ELE_FILLED )
   {
      return( DLIST_E_ERROR );
   }

   byte_size = DLIST_SIZEOF_CRV( num_points, 0 );

   sts = DPdlist_alloc_chunk( byte_size, &chunk );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   DLIST_CRV_ALL_PTRS( chunk, curve_ptrs );

   *(curve_ptrs.byte_size) = byte_size;
   *(curve_ptrs.flags) = DP_DLIST_CRV_TEXT;
   *(curve_ptrs.num_points) = num_points;

   dl_points = curve_ptrs.points;
   while ( num_points )
   {
      *dl_points = *points;
      *(dl_points + 1) = *(points + 1);
      *(dl_points + 2) = *(points + 2);

      dl_points += 3;
      points += 3;
      num_points--;
   }
   
   sts = DPdlist_add_pointer_to_set( DP_DLIST_VIEW_IND, chunk );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_add_curve_to_text */
   

/*--- DPdlist_add_polygon_to_text ------------------------------------------*/

int DPdlist_add_polygon_to_text(
   struct DPdlist_fixed_data *fixed_data,
   IGRuint num_points,
   IGRdouble *points )

/*
NAME
   DPdlist_add_polylgon_to_text()

DESCRIPTION
   This function adds a polygon to a text element.

SYNOPSIS
   int DPdlist_add_polygon_to_text(
      struct DPdlist_fixed_data *fixed_data )
      IGRuint num_points,
      IGRdouble *points )

PARAMETERS
   fixed_data (IN) - the fixed data of the text element
   num_points (IN) - the number of points in the polygon
   points (IN) - the points of the polygon

GLOBALS USED
   DPdlist_building_text

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;
   unsigned int byte_size;
   float *dl_points;
   void *chunk;
   struct DPdlist_curve_variable polygon_ptrs;

   if ( ! DPdlist_building_text )
   {
     return( DLIST_E_ERROR );
   }

   if ( !(fixed_data->ele_flags & DP_DLIST_ELE_FILLED) )
   {
      return( DLIST_E_ERROR );
   }

   byte_size = DLIST_SIZEOF_PLY( num_points, 0 );

   sts = DPdlist_alloc_chunk( byte_size, &chunk );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   DLIST_PLY_ALL_PTRS( chunk, polygon_ptrs );

   *(polygon_ptrs.byte_size) = byte_size;
   *(polygon_ptrs.num_points) = num_points;

   dl_points = polygon_ptrs.points;
   while ( num_points )
   {
      *dl_points = *points;
      *(dl_points + 1) = *(points + 1);
      *(dl_points + 2) = *(points + 2);

      dl_points += 3;
      points += 3;
      num_points--;
   }
   
   sts = DPdlist_add_pointer_to_set( DP_DLIST_VIEW_IND, chunk );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_add_polygon_to_text */

/*--- DPdlist_add_surface -------------------------------------------------*/

int DPdlist_add_surface(
   OM_S_OBJID objid,
   OMuword osnum,
   unsigned short ele_flags,
   IGRshort is_hidden_line,
   IGRshort color,
   IGRchar style,
   IGRchar weight,
   IGRshort layer,
   struct DPdlist_fixed_data **fixed_data )

/*
NAME
   DPdlist_add_surface

DESCRIPTION
   This function adds a surface to the display list.  After this function
   is called the functions to add the surfaces edges must be called.  Finally,
   DPdlist_finish_surface() must be called.

SYNOPSIS
   int DPdlist_add_surface(
      OM_S_OBJID objid,
      OMuword osnum,
      unsigned short ele_flags,
      IGRshort is_hidden_line,
      IGRshort color,
      IGRchar style,
      IGRchar weight,
      IGRshort layer,
      struct DPdlist_fixed_data **fixed_data )

PARAMETERS
   objid (IN) - the object id of the surface element to add
   osnum (IN) - the object space number of the surface
   ele_flags (IN) - the element flags for the surface
   is_hidden_line (IN) - TRUE, if adding for shading
   color (IN) - the logical color of the surface
   style (IN) - the logical style of the surface
   weight (IN) - the weight of the surface
   layer (IN) - the layer of the surface
   fixed_data (OUT) - the fixed data pointer for the surface

GLOBALS USED
   DPdlist_building_surface

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;

   sts = DPdlist_hash_add( objid, osnum, fixed_data );

   if ( ! (*fixed_data) )
   {
      return( DLIST_E_ERROR );
   }

   /*  OR the ele_flags, because if we're adding display list for  */
   /*  shading, we don't want to clear the flags already set for   */
   /*  wireframe.  (Mike Lanier: 4/28/96)  */

   (*fixed_data)->type = DP_DLIST_SURFACE;
   (*fixed_data)->ele_flags |= ele_flags;
   (*fixed_data)->color = color;
   (*fixed_data)->style = style;
   (*fixed_data)->weight = weight;
   (*fixed_data)->layer = layer;
   (*fixed_data)->sh_data = NULL;

#if defined(XGL)
   (*fixed_data)->xgl_data = NULL;
   (*fixed_data)->valid_xgl_data = 0;
#endif


   if ( is_hidden_line )
   {
      sts = DPdlist_init_mesh_array();
   }
   else
   {
      sts = DPdlist_init_set_arrays();
   }
   if ( !(1 & sts) )
   {
      return( DLIST_E_ERROR );
   }

   DPdlist_building_surface = TRUE;
   return( DLIST_S_SUCCESS );

} /* DPdlist_add_surface */

/*--- DPdlist_finish_surface -----------------------------------------------*/

int DPdlist_finish_surface(
   struct DPdlist_fixed_data *fixed_data,
   IGRshort is_hidden_line,
   unsigned short num_u_rules,
   unsigned short num_v_rules )

/*
NAME
   DPdlist_finish_surface

DESCRIPTION
   This function completes the addition of a surface to the display list.

SYNOPSIS
   int DPdlist_finish_surface(
      struct DPdlist_fixed_data *fixed_data,
      IGRshort is_hidden_line,
      unsigned short num_u_rules,
      unsigned short num_v_rules )

PARAMETERS
   fixed_data (IN) - the fixed data pointer of the surface
   is_hidden_line (IN) - TRUE, if adding for shading
   num_u_rules (IN) - the number of u rule lines for the surface
   num_v_rules (IN) - the number of v rule lines for the surface

GLOBALS USED
   DPdlist_building_surface

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

NOTES
   We are only doing view independent edges for 2.4

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;
   unsigned int num_vi_ptrs, num_vd_ptrs, num_vi_ids, num_vd_ids, num_mesh_ptrs;
   unsigned int num_sub_ptrs, num_sub_msc_ids;
   void **vi_ptrs, **vd_ptrs, **mesh_ptrs, **sub_ptrs;
   OM_S_OBJID *vi_ids, *vd_ids, *sub_msc_ids;
   unsigned int byte_size;
   struct DPdlist_surface_variable surface_ptrs;
   struct DPdlist_sh_surface_variable sh_surface_ptrs;

   if ( ! DPdlist_building_surface )
   {
      return( DLIST_E_ERROR );
   }

   if ( is_hidden_line )
   {
      sts = DPdlist_get_mesh_set( &num_mesh_ptrs, &mesh_ptrs );

      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
      byte_size = DLIST_SIZEOF_SH_SRF( num_mesh_ptrs );

      sts = DPdlist_alloc_chunk( byte_size, &fixed_data->sh_data );
      if ( !(1 & sts) )
      {
         return( sts );
      }

      DLIST_SH_SRF_ALL_PTRS( fixed_data->sh_data, sh_surface_ptrs );

      *(sh_surface_ptrs.byte_size) = byte_size;
      *(sh_surface_ptrs.num_meshes) = num_mesh_ptrs;

      /* fill these for real in EMSsubbs method */
      *(sh_surface_ptrs.diff_refl) = 1.0;
      *(sh_surface_ptrs.spec_refl) = 0.5;
      *(sh_surface_ptrs.finish) = 10.0;
      *(sh_surface_ptrs.trans) = 0.0;

      memcpy( sh_surface_ptrs.meshes, mesh_ptrs, num_mesh_ptrs * sizeof( void * ) );
   }
   else
   {
      sts = DPdlist_get_pointer_sets( &num_vi_ptrs, &vi_ptrs,
                                      &num_vd_ptrs, &vd_ptrs );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }

      sts = DPdlist_get_sub_pointer_sets( &num_sub_ptrs, &sub_ptrs );
      
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }

      sts = DPdlist_get_objid_sets( &num_vi_ids, &vi_ids,
                                    &num_vd_ids, &vd_ids );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
      sts = DPdlist_get_sub_objid_sets( &num_sub_msc_ids, &sub_msc_ids );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }

      byte_size = DLIST_SIZEOF_SRF( num_vi_ptrs, num_vi_ids, num_sub_ptrs, 
                                    num_sub_msc_ids );

      sts = DPdlist_alloc_chunk( byte_size, &fixed_data->wf_data );
      if ( !(1 & sts) )
      {
         return( sts );
      }

      DLIST_SRF_ALL_PTRS( fixed_data->wf_data, surface_ptrs, num_vi_ptrs,
                                                num_vi_ids, num_sub_ptrs );

      *(surface_ptrs.byte_size) = byte_size;
      *(surface_ptrs.num_vi_edges) = num_vi_ptrs;
      *(surface_ptrs.num_vi_msc_edges) = num_vi_ids;
      *(surface_ptrs.num_u_rules) = num_u_rules;
      *(surface_ptrs.num_v_rules) = num_v_rules;
      *(surface_ptrs.num_sub_edges) = num_sub_ptrs;
      *(surface_ptrs.num_sub_msc_ids) = num_sub_msc_ids;

      memcpy( surface_ptrs.vi_edges, vi_ptrs, num_vi_ptrs * sizeof( void * ) );

      memcpy( surface_ptrs.vi_msc_edges, vi_ids, num_vi_ids * sizeof( OM_S_OBJID ) );

      memcpy( surface_ptrs.sub_edges, sub_ptrs, num_sub_ptrs * sizeof( void * ) );

      memcpy( surface_ptrs.sub_msc_ids, sub_msc_ids, num_sub_msc_ids * sizeof( OM_S_OBJID ) );

   }

   DPdlist_building_surface = FALSE;

   return( DLIST_S_SUCCESS );

} /* DPdlist_finish_surface */

/*--- DPdlist_add_edge_to_surface -------------------------------------------*/

/*ARGSUSED*/
int DPdlist_add_edge_to_surface(
   struct DPdlist_fixed_data *fixed_data,
   IGRuchar edge_type,
   IGRuint flags,
   IGRuint num_points,
   IGRdouble *points )

/*
NAME
   DPdlist_add_edge_to_surface

DESCRIPTION
   This function adds an edge to a surface.

SYNOPSIS
   int DPdlist_add_edge_to_surface(
      struct DPdlist_fixed_data *fixed_data )
      IGRuchar edge_type,
      IGRuint flags,
      IGRuint num_points,
      IGRdouble *points )

PARAMETERS
   fixed_data (IN) - the fixed data pointer of the surface
   edge_type (IN) - the type of edge being added (view dep. or view ind)
   flags (IN) - the flags for the variable
   num_points (IN) - the number of points in the edge to be added
   points (IN) - the points of the edge

GLOBALS USED
   DPdlist_building_surface

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;
   unsigned int byte_size;
   float *dl_points;
   void *chunk;
   struct DPdlist_curve_variable curve_ptrs;

   if ( ! DPdlist_building_surface )
   {
     return( DLIST_E_ERROR );
   }

   byte_size = DLIST_SIZEOF_CRV( num_points, 0 );

   sts = DPdlist_alloc_chunk( byte_size, &chunk );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   DLIST_CRV_ALL_PTRS( chunk, curve_ptrs );

   *(curve_ptrs.byte_size) = byte_size;
   *(curve_ptrs.flags) = DP_DLIST_CRV_SURFACE | flags;
   *(curve_ptrs.num_points) = num_points;

   dl_points = curve_ptrs.points;
   while ( num_points )
   {
      *dl_points = *points;
      *(dl_points + 1) = *(points + 1);
      *(dl_points + 2) = *(points + 2);

      dl_points += 3;
      points += 3;
      num_points--;
   }

   if ( flags & DP_DLIST_CRV_SUBORDINATE )
   {
      sts = DPdlist_add_sub_pointer_to_set( edge_type, chunk );
   }
   else
   {
      sts = DPdlist_add_pointer_to_set( edge_type, chunk );
   }   
   if ( !(1 & sts) )
   {
      return( sts );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_add_edge_to_surface */

/*--- DPdlist_add_msc_edge_to_surface -------------------------------------*/
/*ARGSUSED*/
int DPdlist_add_msc_edge_to_surface(
   struct DPdlist_fixed_data *fixed_data,
   IGRuchar edge_type,
   IGRuint flags,
   OM_S_OBJID msc_id )

/*
NAME
   DPdlist_add_msc_edge_to_surface

DESCRIPTION
   This function adds an edge with a model space counterpart to a surface.

SYNOPSIS
   int DPdlist_add_msc_edge_to_surface(
      struct DPdlist_fixed_data *fixed_data )
      IGRuchar edge_type,
      IGRuint flags,
      OM_S_OBJID msc_id )

PARAMETERS
   fixed_data (IN) - the fixed data of the surface
   edge_type (IN) - the type of edge being added (view dep. or view ind)
   flags (IN) - flags word
   msc_id (IN) - the objid of the model space counterpart

GLOBALS USED
   DPdlist_building_surface

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;

   if ( ! DPdlist_building_surface )
   {
     return( DLIST_E_ERROR );
   }

   if ( flags & DP_DLIST_CRV_SUBORDINATE )
   {
      sts = DPdlist_add_sub_objid_to_set( edge_type, msc_id );
   }
   else
   {
      sts = DPdlist_add_objid_to_set( edge_type, msc_id );
   }

   if ( !(1 & sts) )
   {
      return( sts );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_add_msc_edge_to_surface */

/*--- DPdlist_add_unknown --------------------------------------------------*/

int DPdlist_add_unknown(
   OM_S_OBJID objid,
   OMuword osnum,
   unsigned short ele_flags,
   IGRshort color,
   IGRchar style,
   IGRchar weight,
   IGRshort layer,
   int (*disp_func)(
      OM_S_OBJID objid,
      OMuword osnum,
      void *data,
      struct DP_information *dp_info,
      IGRmatrix matrix,
      IGRshort mat_type,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb ),
   IGRuint data_size,
   void *data )

/*
NAME
   DPdlist_add_unknown

DESCRIPTION
   This function adds an unknown element to the display list.

SYNOPSIS
   int DPdlist_add_unknown(
      OM_S_OBJID objid,
      OMuword osnum,
      unsigned short ele_flags,
      IGRshort color,
      IGRchar style,
      IGRchar weight,
      IGRshort layer,
      int (*disp_func)(
         OM_S_OBJID objid,
         OMuword osnum,
         void *data,
         struct DP_information dp_info,
         IGRmatrix matrix,
         IGRshort mat_type,
         GRdpmode dp_mode,
         struct IGRaltdisplay *alt_symb ),
      IGRuint data_size,
      void *data )

PARAMETERS
   objid (IN) - the object id of the surface element to add
   osnum (IN) - the object space number of the surface
   ele_flags (IN) - the element flags for the surface
   color (IN) - the logical color of the unknown element
   style (IN) - the logical style of the unknown element
   weight (IN) - the weight of the unknown element
   layer (IN) - the layer of the unknown element
   disp_func (IN) - the display function of the unknown element
   data_size (IN) - the size, in bytes, of the unknown element's data
   data (IN) - a pointer to the unknown element's data

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;
   unsigned int byte_size;
   struct DPdlist_fixed_data *fixed_data;
   struct DPdlist_unknown_variable unknown_ptrs;

   sts = DPdlist_hash_add( objid, osnum, &fixed_data );

   if ( ! fixed_data )
   {
      return( DLIST_E_ERROR );
   }

   byte_size = DLIST_SIZEOF_UNK( data_size );

   sts = DPdlist_alloc_chunk( byte_size, &fixed_data->wf_data );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   DLIST_UNK_ALL_PTRS( fixed_data->wf_data, unknown_ptrs );

   *(unknown_ptrs.byte_size) = byte_size;
   *(unknown_ptrs.data_size) = data_size;
   *(unknown_ptrs.disp_func) = disp_func;
   *(unknown_ptrs.data) = data;

   fixed_data->type = DP_DLIST_UNKNOWN;
   fixed_data->ele_flags = ele_flags;
   fixed_data->color = color;
   fixed_data->style = style;
   fixed_data->weight = weight;
   fixed_data->layer = layer;
   fixed_data->sh_data = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_add_unknown */

/*--- DPdlist_add_dimension ----------------------------------------------------*/

int DPdlist_add_dimension(
   OM_S_OBJID objid,
   OMuword osnum,
   unsigned short ele_flags,
   IGRshort color,
   IGRchar style,
   IGRchar weight,
   IGRshort layer )

/*
NAME
   DPdlist_add_dimension

DESCRIPTION
   This function adds a dimension to the display list.  The
   dimension header is added w/out geometry so they can
   be ignored when "performance boost" is on.

SYNOPSIS
   int DPdlist_add_dimension(
      OM_S_OBJID objid,
      OMuword osnum,
      unsigned short ele_flags,
      IGRshort color,
      IGRchar style,
      IGRchar weight,
      IGRshort layer )

PARAMETERS
   objid (IN) - the object id of the dimension to add
   osnum (IN) - the object space number
   ele_flags (IN) - the element flags of the dimension
   color (IN) - the color of the dimension
   style (IN) - the style of the dimension
   weight (IN) - the weight of the dimension
   layer (IN) - the layer of the dimension

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   09/13/93  S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   unsigned int *byte_size;
   struct DPdlist_fixed_data *fixed_data;

   sts = DPdlist_hash_add( objid, osnum, &fixed_data );

   if ( ! fixed_data )
   {
      return( DLIST_E_ERROR );
   }

   /* add 4 bytes of wireframe variable data for dimensions */
   /* so we don't keep trying to re-add them because the    */
   /* wf_data pointer it NULL                               */
   sts = DPdlist_alloc_chunk( 4, &fixed_data->wf_data );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   DLIST_CRV_BYTE_SIZE_PTR( fixed_data->wf_data, byte_size );
   *byte_size = 4;
   fixed_data->type = DP_DLIST_DIMENSION;
   fixed_data->ele_flags = ele_flags;
   fixed_data->color = color;
   fixed_data->style = style;
   fixed_data->weight = weight;
   fixed_data->layer = layer;
   fixed_data->sh_data = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_add_dimension */

/*--- DPdlist_add_skpoint ----------------------------------------------------*/

int DPdlist_add_skpoint(
   OM_S_OBJID objid,
   OMuword osnum,
   unsigned short ele_flags,
   IGRshort color,
   IGRchar style,
   IGRchar weight,
   IGRshort layer )

/*
NAME
   DPdlist_add_skpoint

DESCRIPTION
   This function adds a SKpoint to the display list.  The
   SKpoint is added w/out geometry so the hiliting behavior
   of their parent circle/arc is correct.

SYNOPSIS
   int DPdlist_add_skpoint(
      OM_S_OBJID objid,
      OMuword osnum,
      unsigned short ele_flags,
      IGRshort color,
      IGRchar style,
      IGRchar weight,
      IGRshort layer )

PARAMETERS
   objid (IN) - the object id of the SKpoint to add
   osnum (IN) - the object space number
   ele_flags (IN) - the element flags of the SKpoint
   color (IN) - the color of the SKpoint
   style (IN) - the style of the SKpoint
   weight (IN) - the weight of the SKpoint
   layer (IN) - the layer of the SKpoint

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   01/10/94  S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   unsigned int *byte_size;
   struct DPdlist_fixed_data *fixed_data;

   sts = DPdlist_hash_add( objid, osnum, &fixed_data );

   if ( ! fixed_data )
   {
      return( DLIST_E_ERROR );
   }

   /* add 4 bytes of wireframe variable data for SKpoints */
   /* so we don't keep trying to re-add them because the  */
   /* wf_data pointer it NULL                             */
   sts = DPdlist_alloc_chunk( 4, &fixed_data->wf_data );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   DLIST_CRV_BYTE_SIZE_PTR( fixed_data->wf_data, byte_size );
   *byte_size = 4;
   fixed_data->type = DP_DLIST_SKPOINT;
   fixed_data->ele_flags = ele_flags;
   fixed_data->color = color;
   fixed_data->style = style;
   fixed_data->weight = weight;
   fixed_data->layer = layer;
   fixed_data->sh_data = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_add_skpoint */

