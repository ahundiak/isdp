#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"

#include "dp.h"
#include "dpdef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "DPdlist.h"


/* New Prototypes */
PROTO_DPdlist_delete_point_variable
PROTO_DPdlist_delete_polygon_variable
PROTO_DPdlist_delete_curve_variable
PROTO_DPdlist_delete_text_variable
PROTO_DPdlist_delete_surface_variable
PROTO_DPdlist_delete_unknown_variable
PROTO_DPdlist_delete_dimension_variable
PROTO_DPdlist_delete_skpoint_variable
PROTO_DPdlist_delete_element
PROTO_DPdlist_delete_variable_data
PROTO_DPdlist_hash_delete
PROTO_DPdlist_hash_lookup
PROTO_DPdlist_free_chunk

/*-------DPdlist_delete_point_variable-------------------------------------*/

/*ARGSUSED*/
int DPdlist_delete_point_variable(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum )

/*
NAME
   DPdlist_delete_point_variable

DESCRIPTION
   This function deletes the variable data for a point.

SYNOPSIS
   int DPdlist_delete_point_variable(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum )

PARAMETERS
   fixed (IN) - Pointer to the fixed data
   osnum (IN) - Object space number

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_I_NOVARIABLEDATA - Point has no variable data
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design
*/

{
   unsigned int *byte_size;
   int sts;

   if ( ! fixed->wf_data )
   {
      return( DLIST_I_NOVARIABLEDATA );
   }

   DLIST_PNT_BYTE_SIZE_PTR( fixed->wf_data, byte_size );
   sts = DPdlist_free_chunk( *byte_size, fixed->wf_data ); 
   if ( !(1 & sts) )
   {
      return( sts );
   }

   fixed->wf_data = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_delete_point_variable */

/*------DPdlist_delete_polygon_variable----------------------------------*/

/*ARGSUSED*/
int DPdlist_delete_polygon_variable(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum )

/*
NAME
   DPdlist_delete_polygon_variable

DESCRIPTION
   This function deletes the variable data for a polygon.

SYNOPSIS
   int DPdlist_delete_polygon_variable(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum )

PARAMETERS
   fixed (IN) - Pointer to the fixed data
   osnum (IN) - Object space number

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_I_NOVARIABLEDATA - Polygon has no variable data
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design
*/

{
   unsigned int *byte_size;
   int sts;

   if ( ! fixed->wf_data )
   {
      return( DLIST_I_NOVARIABLEDATA );
   }
 
   DLIST_PLY_BYTE_SIZE_PTR( fixed->wf_data, byte_size );
   sts = DPdlist_free_chunk( *byte_size, fixed->wf_data );       
   if ( !(1 & sts) )
   {
      return( sts );
   }

   fixed->wf_data = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_delete_polygon_variable */

/*------DPdlist_delete_curve_variable-----------------------------------*/

/*ARGSUSED*/
int DPdlist_delete_curve_variable(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum )

/*
NAME
   DPdlist_delete_curve_variable

DESCRIPTION
   This function deletes the variable data for a curve.

SYNOPSIS
   int DPdlist_delete_curve_variable(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum )

PARAMETERS
   fixed (IN) - Pointer to the fixed data
   osnum (IN) - Object space number

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_I_NOVARIABLEDATA - Curve has no variable data
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design
*/

{
   unsigned int *byte_size;
   int sts;

   if ( ! fixed->wf_data )
   {
      return( DLIST_I_NOVARIABLEDATA );
   }
 
   DLIST_CRV_BYTE_SIZE_PTR( fixed->wf_data, byte_size );
   sts = DPdlist_free_chunk( *byte_size, fixed->wf_data );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   fixed->wf_data = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_delete_curve_variable */


/*-------DPdlist_delete_text_variable----------------------------------*/

/*ARGSUSED*/
int DPdlist_delete_text_variable(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum )

/*
NAME
   DPdlist_delete_text_variable

DESCRIPTION
   This function deletes the variable data for a text element.

SYNOPSIS
   int DPdlist_delete_point_variable(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum )

PARAMETERS
   fixed (IN) - Pointer to the fixed data
   osnum (IN) - Object space number

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_I_NOVARIABLEDATA - Text has no variable data
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design
*/

{
   unsigned int *byte_size, ii;
   int sts;
   struct DPdlist_text_variable text;
   struct DPdlist_filled_text_variable ftext;

   if ( ! fixed->wf_data )
   {
      return( DLIST_I_NOVARIABLEDATA );
   }

   if ( fixed->ele_flags & DP_DLIST_ELE_FILLED )
   { 
      DLIST_FTXT_ALL_PTRS( fixed->wf_data, ftext );
      for ( ii = 0; ii < *ftext.num_polys; ii++ )
      {

         DLIST_PLY_BYTE_SIZE_PTR( ftext.polys[ii], byte_size );
         sts = DPdlist_free_chunk( *byte_size, ftext.polys[ii] ); 

         if ( !(1 & sts) )
         {
            return( sts );
         }
      }
      DLIST_FTXT_BYTE_SIZE_PTR( fixed->wf_data, byte_size );
   }
   else
   {
      DLIST_TXT_ALL_PTRS( fixed->wf_data, text );
      for ( ii = 0; ii < *text.num_lines; ii++ )
      {
         DLIST_CRV_BYTE_SIZE_PTR( text.lines[ii], byte_size );
         sts = DPdlist_free_chunk( *byte_size, text.lines[ii] );
         if ( !(1 & sts) )
         {
            return( sts );
         }
      }
      DLIST_TXT_BYTE_SIZE_PTR( fixed->wf_data, byte_size );
   } 

   sts = DPdlist_free_chunk( *byte_size, fixed->wf_data );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   fixed->wf_data = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_delete_text_variable */

/*---DPdlist_delete_surface_variable-----------------------------------*/

int DPdlist_delete_surface_variable(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum,
   IGRint delete_flag )

/*
NAME
   DPdlist_delete_surface_variable

DESCRIPTION
   This function deletes the variable data for a surface.

SYNOPSIS
   int DPdlist_delete_surface_variable(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum,
      IGRint delete_flag )

PARAMETERS
   fixed (IN) - Pointer to the fixed data
   osnum (IN) - Object space number
   delete_flag (IN) - A mask that indicates whether the wireframe or shading 
                   variable data should be deleted or both

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_I_NOVARIABLEDATA - Surface has no variable data
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   07/15/93 Shridar Subramanian
      Added delete_flag parameter
*/

{

   unsigned int *byte_size, ii;
   unsigned int *num_vi_edges, *num_vi_msc_edges, *num_sub_edges;
   int sts;
   struct DPdlist_surface_variable surface;
   struct DPdlist_sh_surface_variable sh_surface;
   int deleted_something = FALSE;

#if defined(XGL)
   if ( (fixed->sh_data) 			&& 
	(delete_flag & DP_DLIST_DELETE_SH_DATA)	&& 
   	(fixed->valid_xgl_data)
      )
   {
   	struct DPdlist_xgl_data   *xgl_data = fixed->xgl_data;

	if(xgl_data->vertex_data_size && xgl_data->vertex_data)
	{
           sts = DPdlist_free_chunk(xgl_data->vertex_data_size,
				    xgl_data->vertex_data);
            if ( !(1 & sts) )
            {
               return( sts );
            }
	}

	if(xgl_data)
	{
	    sts = DPdlist_free_chunk(sizeof(struct DPdlist_xgl_data), 
					    xgl_data);
            if ( !(1 & sts) )
            {
               return( sts );
            }
	}

        fixed->valid_xgl_data = FALSE;
	fixed->xgl_data = NULL;

   }
#endif

   if ( (fixed->sh_data) && (delete_flag & DP_DLIST_DELETE_SH_DATA) )
   {
      deleted_something = TRUE;
      DLIST_SH_SRF_ALL_PTRS( fixed->sh_data, sh_surface );

      for ( ii = 0; ii < *sh_surface.num_meshes; ii++ )
      {
         DLIST_MSH_BYTE_SIZE_PTR( sh_surface.meshes[ii], byte_size );
	 if(sh_surface.meshes[ii])
	 {  
            sts = DPdlist_free_chunk( *byte_size, sh_surface.meshes[ii] );
            if ( !(1 & sts) )
            {
               return( sts );
            }
	 }
      }
     
      sts = DPdlist_free_chunk( *sh_surface.byte_size, fixed->sh_data );
      if ( !(1 & sts) )
      {
         return( sts );
      }

      fixed->sh_data = NULL;
   }

   if ( (fixed->wf_data) && (delete_flag & DP_DLIST_DELETE_WF_DATA) )
   {
      deleted_something = TRUE;
      DLIST_SRF_NUM_VI_EDGES_PTR( fixed->wf_data, num_vi_edges );
      DLIST_SRF_NUM_VI_MSC_EDGES_PTR( fixed->wf_data, num_vi_msc_edges );
      DLIST_SRF_NUM_SUB_EDGES_PTR( fixed->wf_data, num_sub_edges );
      DLIST_SRF_ALL_PTRS( fixed->wf_data, surface, *num_vi_edges,
                                       *num_vi_msc_edges, *num_sub_edges );

      for ( ii = 0; ii < *surface.num_vi_edges; ii++ )
      {
         DLIST_CRV_BYTE_SIZE_PTR( surface.vi_edges[ii], byte_size );
         sts = DPdlist_free_chunk( *byte_size, surface.vi_edges[ii] );
         if ( !(1 & sts) )
         {
            return( sts );
         }
      }
     
      for ( ii = 0; ii < *surface.num_vi_msc_edges; ii++ )
      {
         sts = DPdlist_delete_variable_data( surface.vi_msc_edges[ii], osnum, delete_flag );
         if ( !(1 & sts) )
         {
            return( sts );
         }
      }
   
      DLIST_SRF_BYTE_SIZE_PTR( fixed->wf_data, byte_size );
      sts = DPdlist_free_chunk( *byte_size, fixed->wf_data );
      if ( !(1 & sts) )
      {
         return( sts );
      }

      fixed->wf_data = NULL;
   }

   return( (deleted_something) ? DLIST_S_SUCCESS : DLIST_I_NOVARIABLEDATA );

} /* DPdlist_delete_surface_variable */

/*---DPdlist_delete_unknown_variable--------------------------------------*/
/*ARGSUSED*/
int DPdlist_delete_unknown_variable(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum )

/*
NAME
   DPdlist_delete_unknown_variable

DESCRIPTION
   This function deletes the variable data for an unknown element.

SYNOPSIS
   int DPdlist_delete_unknown_variable(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum )

PARAMETERS
   fixed (IN) - Pointer to the fixed data
   osnum (IN) - Object space number

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_I_NOVARIABLEDATA - Unknown element has no variable data
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design
*/

{
   unsigned int *byte_size;
   int sts;

   if ( !fixed->wf_data )
   {
      return( DLIST_I_NOVARIABLEDATA );
   }

   DLIST_UNK_BYTE_SIZE_PTR ( fixed->wf_data, byte_size );
   sts = DPdlist_free_chunk( *byte_size, fixed->wf_data );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   fixed->wf_data = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_delete_unknown_variable */

/*------DPdlist_delete_dimension_variable-----------------------------------*/

/*ARGSUSED*/
int DPdlist_delete_dimension_variable(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum )

/*
NAME
   DPdlist_delete_dimension_variable

DESCRIPTION
   This function deletes the variable data for a dimension.

SYNOPSIS
   int DPdlist_delete_dimension_variable(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum )

PARAMETERS
   fixed (IN) - Pointer to the fixed data
   osnum (IN) - Object space number

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_I_NOVARIABLEDATA - dimension has no variable data
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design
*/

{
   unsigned int *byte_size;
   int sts;

   if ( ! fixed->wf_data )
   {
      return( DLIST_I_NOVARIABLEDATA );
   }
 
   DLIST_CRV_BYTE_SIZE_PTR( fixed->wf_data, byte_size );
   sts = DPdlist_free_chunk( *byte_size, fixed->wf_data );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   fixed->wf_data = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_delete_dimension_variable */

/*------DPdlist_delete_skpoint_variable-----------------------------------*/

/*ARGSUSED*/
int DPdlist_delete_skpoint_variable(
   struct DPdlist_fixed_data *fixed,
   OMuword osnum )

/*
NAME
   DPdlist_delete_skpoint_variable

DESCRIPTION
   This function deletes the variable data for a SKpoint

SYNOPSIS
   int DPdlist_delete_skpoint_variable(
      struct DPdlist_fixed_data *fixed,
      OMuword osnum )

PARAMETERS
   fixed (IN) - Pointer to the fixed data
   osnum (IN) - Object space number

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_I_NOVARIABLEDATA - SKpoint has no variable data
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design
*/

{
   unsigned int *byte_size;
   int sts;

   if ( ! fixed->wf_data )
   {
      return( DLIST_I_NOVARIABLEDATA );
   }
 
   DLIST_CRV_BYTE_SIZE_PTR( fixed->wf_data, byte_size );
   sts = DPdlist_free_chunk( *byte_size, fixed->wf_data );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   fixed->wf_data = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_delete_skpoint_variable */

/*---DPdlist_delete_element-----------------------------------------*/

int DPdlist_delete_element(
   OM_S_OBJID objid,
   OMuword osnum )

/*
NAME
   DPdlist_delete_element

DESCRIPTION
   This function deletes an element from the display list

SYNOPSIS
   int DPdlist_delete_element(
      OM_S_OBJID objid,
      OMuword osnum )

PARAMETERS
   objid (IN) - The object id of the element to be deleted
   osnum (IN) - The object spacenum of the element to be deleted

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

   sts = DPdlist_delete_variable_data( objid, osnum,
                                       DP_DLIST_DELETE_SH_DATA | DP_DLIST_DELETE_WF_DATA );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   sts = DPdlist_hash_delete( objid, osnum );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   return( DLIST_S_SUCCESS ); 

} /* DPdlist_delete_element */

/*---DPdlist_delete_variable_data-------------------------------------*/

int DPdlist_delete_variable_data(
   OM_S_OBJID objid,
   OMuword osnum,
   IGRint delete_flag )

/*
NAME
   DPdlist_delete_variable_data

DESCRIPTION
   This function deletes the variable data of an element from the display
   list.

SYNOPSIS
   int DPdlist_delete_variable_data(
      OM_S_OBJID objid,
      OMuword osnum,
      IGRint delete_flag )

PARAMETERS
   objid (IN) - The object id of the element whose variable data is to be 
                deleted
   osnum (IN) - The object spacenum of the element whose variable data is to 
                be deleted
   delete_flag (IN) - Mask indicating the wireframe or shading data is to be 
                      deleted.

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_I_NOTFOUND - Element not in hash table
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design

   07/15/93 Shridar Subramanian
      Added parameter delete_flag 
*/

{
   int sts;
   struct DPdlist_fixed_data *fixed;
   
   sts = DPdlist_hash_lookup( objid, osnum, &fixed );
   if ( ( !(1 & sts) ) || ( ! fixed ) )
   {
      return( DLIST_I_NOTFOUND );
   }

   switch ( fixed->type )
   {
      case DP_DLIST_POINT:
         sts = DPdlist_delete_point_variable( fixed, osnum );
         break;

      case DP_DLIST_POLYGON:
         sts = DPdlist_delete_polygon_variable( fixed, osnum );
         break;

      case DP_DLIST_CURVE:
         sts = DPdlist_delete_curve_variable( fixed, osnum );
         break;

      case DP_DLIST_TEXT:
         sts = DPdlist_delete_text_variable( fixed, osnum );
         break;

      case DP_DLIST_SURFACE:
         sts = DPdlist_delete_surface_variable( fixed, osnum, delete_flag );
         break;

      case DP_DLIST_UNKNOWN:
         sts = DPdlist_delete_unknown_variable( fixed, osnum );
         break;

      case DP_DLIST_DIMENSION:
         sts = DPdlist_delete_dimension_variable( fixed, osnum );
         break;

      case DP_DLIST_SKPOINT:
         sts = DPdlist_delete_skpoint_variable( fixed, osnum );
         break;

      default:
         sts = DLIST_E_ERROR;
         break;
   }

   return( sts );

} /* DPdlist_delete_variable_data */
