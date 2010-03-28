#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <math.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"

#include "DPdlist.h"

extern struct DPdlist_hash_table *DPhash_tables;

/* New Prototypes */
PROTO_DPdlist_print_point_variable
PROTO_DPdlist_print_polygon_variable
PROTO_DPdlist_print_curve_variable
PROTO_DPdlist_print_text_variable
PROTO_DPdlist_print_filled_text_variable
PROTO_DPdlist_print_surface_variable
PROTO_DPdlist_print_unknown_variable
PROTO_DPdlist_print_variable
PROTO_DPdlist_print_hash_table
PROTO_DPdlist_print_fixed_data
PROTO_DPdlist_print_element
PROTO_DPdlist_hash_lookup

/*--- DPdlist_print_curve_flags --------------------------------*/

static void DPdlist_print_curve_flags(
   unsigned int flags )

/*
NAME
   DPdlist_print_curve_flags

DESCRIPTION
   This function prints out an English description of a curve flags
   word to stderr.

SYNOPSIS
   static void DPdlist_print_curve_flags(
      unsigned int flags )

PARAMETERS
   flags (IN) - the curve flags to print out

GLOBALS USED
   none

HISTORY
   12/15/93 S.P. Rogers
      Initial Implementation
*/

{
   if ( flags & DP_DLIST_CRV_WIREFRAME )
   {
      fprintf( stderr, " WIREFRAME" );
      flags &= ~DP_DLIST_CRV_WIREFRAME;
   }

   if ( flags & DP_DLIST_CRV_TEXT )
   {
      fprintf( stderr, " TEXT" );
      flags &= ~DP_DLIST_CRV_TEXT;
   }

   if ( flags & DP_DLIST_CRV_SURFACE )
   {
      fprintf( stderr, " SURFACE" );
      flags &= ~DP_DLIST_CRV_SURFACE;
   }

   if ( flags & DP_DLIST_CRV_RULE_LINE )
   {
      fprintf( stderr, " RULE_LINE" );
      flags &= ~DP_DLIST_CRV_RULE_LINE;
   }

   if ( flags & DP_DLIST_CRV_TANGENT )
   {
      fprintf( stderr, " TANGENT" );
      flags &= ~DP_DLIST_CRV_TANGENT;
   }

   if ( flags & DP_DLIST_CRV_SEAM )
   {
      fprintf( stderr, " SEAM" );
      flags &= ~DP_DLIST_CRV_SEAM;
   }

   if ( flags & DP_DLIST_CRV_SUBORDINATE )
   {
      fprintf( stderr, " SUBORDINATE" );
      flags &= ~DP_DLIST_CRV_SUBORDINATE;
   }

   if ( flags )
   {
      fprintf( stderr, " %#X", flags );
   }

}  /* DPdlist_print_curve_flags */

/*--- DPdlist_print_point_variable --------------------------------------*/

int DPdlist_print_point_variable(
   void *variable_data )

/*
NAME
   DPdlist_print_point_variable

DESCRIPTION
   This function prints the variable data of a point to stderr.

SYNOPSIS
   int DPdlist_print_point_variable(
      void *variable_data )

PARAMETERS
   varialbe_data (IN) - the variable data of the point

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/07/93 S.P. Rogers
      Initial implementation
*/

{
   struct DPdlist_point_variable point;

   DLIST_PNT_ALL_PTRS( variable_data, point );

   fprintf( stderr, "Point Variable Data\n" );
   fprintf( stderr, "   Byte Size: %d\n", *(point.byte_size) );
   fprintf( stderr, "   %10.5f %10.5f %10.5f\n",
            point.point[0], point.point[1], point.point[2] );

   return( DLIST_S_SUCCESS );
}  /* DPdlist_print_point_variable */

/*--- DPdlist_print_polygon_variable --------------------------------------*/

int DPdlist_print_polygon_variable(
   void *variable_data )

/*
NAME
   DPdlist_print_polygon_variable

DESCRIPTION
   This function prints the variable data of a polygon to stderr.

SYNOPSIS
   int DPdlist_print_polygon_variable(
      void *variable_data )

PARAMETERS
   varialbe_data (IN) - the variable data of the polygon

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/07/93 S.P. Rogers
      Initial implementation
*/

{
   struct DPdlist_polygon_variable polygon;
   int ii;

   DLIST_PLY_ALL_PTRS( variable_data, polygon );

   fprintf( stderr, "Polygon Variable Data\n" );
   fprintf( stderr, "   Byte Size: %d\n", *(polygon.byte_size) );
   fprintf( stderr, "   Num points: %d\n", *(polygon.num_points) );
   for ( ii = 0; ii < *(polygon.num_points); ii++ )
   {
      fprintf( stderr, "   %10.5f %10.5f %10.5f\n",
               polygon.points[ii*3],
               polygon.points[(ii*3) + 1],
               polygon.points[(ii*3) + 2] );
   }

   return( DLIST_S_SUCCESS );
}  /* DPdlist_print_polygon_variable */

/*--- DPdlist_print_curve_variable --------------------------------------*/

int DPdlist_print_curve_variable(
   void *variable_data )

/*
NAME
   DPdlist_print_curve_variable

DESCRIPTION
   This function prints the variable data of a curve to stderr.

SYNOPSIS
   int DPdlist_print_curve_variable(
      void *variable_data )

PARAMETERS
   varialbe_data (IN) - the variable data of the curve

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/07/93 S.P. Rogers
      Initial implementation
*/

{
   struct DPdlist_curve_variable curve;
   int ii;

   DLIST_CRV_ALL_PTRS( variable_data, curve );

   fprintf( stderr, "Curve Variable Data\n" );
   fprintf( stderr, "   Byte Size: %d\n", *(curve.byte_size) );
   fprintf( stderr, "   Flags:" );
   DPdlist_print_curve_flags( *(curve.flags) );
   fprintf( stderr, "\n" );

   fprintf( stderr, "   Num points: %d\n", *(curve.num_points) );
   for ( ii = 0; ii < *(curve.num_points); ii++ )
   {
      fprintf( stderr, "   %10.5f %10.5f %10.5f\n",
               curve.points[ii*3],
               curve.points[(ii*3) + 1],
               curve.points[(ii*3) + 2] );
   }

   return( DLIST_S_SUCCESS );
}  /* DPdlist_print_curve_variable */

/*--- DPdlist_print_text_variable --------------------------------------*/

int DPdlist_print_text_variable(
   void *variable_data )

/*
NAME
   DPdlist_print_text_variable

DESCRIPTION
   This function prints the variable data of a text element to stderr.

SYNOPSIS
   int DPdlist_print_text_variable(
      void *variable_data )

PARAMETERS
   varialbe_data (IN) - the variable data of the text

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/07/93 S.P. Rogers
      Initial implementation
*/

{
   struct DPdlist_text_variable text;
   struct DPdlist_curve_variable curve;
   int ii, jj;

   DLIST_TXT_ALL_PTRS( variable_data, text );

   fprintf( stderr, "Text Variable Data\n" );
   fprintf( stderr, "   Byte Size: %d\n", *(text.byte_size) );
   fprintf( stderr, "   Num lines: %d\n", *(text.num_lines) );
   for ( ii = 0; ii < *(text.num_lines); ii++ )
   {
      DLIST_CRV_ALL_PTRS( text.lines[ii], curve );

      fprintf( stderr, "      Num points: %d\n", *(curve.num_points) );
      for ( jj = 0; jj < *(curve.num_points); jj++ )
      {
         fprintf( stderr, "      %10.5f %10.5f %10.5f\n",
                  curve.points[jj*3],
                  curve.points[(jj*3) + 1],
                  curve.points[(jj*3) + 2] );
      }
   }

   return( DLIST_S_SUCCESS );
}  /* DPdlist_print_text_variable */

/*--- DPdlist_print_filled_text_variable --------------------------------------*/

int DPdlist_print_filled_text_variable(
   void *variable_data )

/*
NAME
   DPdlist_print_filled_text_variable

DESCRIPTION
   This function prints the variable data of a filled text element to stderr.

SYNOPSIS
   int DPdlist_print_filled_text_variable(
      void *variable_data )

PARAMETERS
   varialbe_data (IN) - the variable data of the filled text

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/07/93 S.P. Rogers
      Initial implementation
*/

{
   struct DPdlist_filled_text_variable ftext;
   struct DPdlist_polygon_variable polygon;
   int ii, jj;

   DLIST_FTXT_ALL_PTRS( variable_data, ftext );

   fprintf( stderr, "Filled Text Variable Data\n" );
   fprintf( stderr, "   Byte Size: %d\n", *(ftext.byte_size) );
   fprintf( stderr, "   Num polys: %d\n", *(ftext.num_polys) );
   for ( ii = 0; ii < *(ftext.num_polys); ii++ )
   {
      DLIST_PLY_ALL_PTRS( ftext.polys[ii], polygon );

      fprintf( stderr, "      Num points: %d\n", *(polygon.num_points) );
      for ( jj = 0; jj < *(polygon.num_points); jj++ )
      {
         fprintf( stderr, "      %10.5f %10.5f %10.5f\n",
                  polygon.points[jj*3],
                  polygon.points[(jj*3) + 1],
                  polygon.points[(jj*3) + 2] );
      }
   }

   return( DLIST_S_SUCCESS );
}  /* DPdlist_print_filled_text_variable */

/*--- DPdlist_print_surface_variable --------------------------------------*/

int DPdlist_print_surface_variable(
   void *wf_variable_data,
   void *sh_variable_data )

/*
NAME
   DPdlist_print_surface_variable

DESCRIPTION
   This function prints the variable data of a surface element to stderr.

SYNOPSIS
   int DPdlist_print_surface_variable(
      void *wf_variable_data,
      void *sh_variable_data )

PARAMETERS
   wf_variable_data (IN) - the wireframe variable data of the surface
   sh_variable_data (IN) - the shading variable data of the surface

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/07/93 S.P. Rogers
      Initial implementation
*/

{
   struct DPdlist_surface_variable surface;
   struct DPdlist_sh_surface_variable sh_surface;
   struct DPdlist_curve_variable curve;
   struct DPdlist_tri_mesh mesh;
   unsigned int *num_vi_edges, *num_verts, *num_vi_msc_edges, *num_sub_edges;
   int ii, jj;

   if ( wf_variable_data )
   {
      DLIST_SRF_NUM_VI_EDGES_PTR( wf_variable_data, num_vi_edges );
      DLIST_SRF_NUM_VI_MSC_EDGES_PTR( wf_variable_data, num_vi_msc_edges );
      DLIST_SRF_NUM_SUB_EDGES_PTR( wf_variable_data, num_sub_edges );
      DLIST_SRF_ALL_PTRS( wf_variable_data, surface, *num_vi_edges,
                                        *num_vi_msc_edges, *num_sub_edges  );

      fprintf( stderr, "Surface Wireframe Variable Data\n" );
      fprintf( stderr, "   Byte Size: %d\n", *(surface.byte_size) );
      fprintf( stderr, "   Num VI Edges: %d\n", *(surface.num_vi_edges) );
      for ( ii = 0; ii < *(surface.num_vi_edges); ii++ )
      {
         DLIST_CRV_ALL_PTRS( surface.vi_edges[ii], curve );

         fprintf( stderr, "      Flags:" );
         DPdlist_print_curve_flags( *(curve.flags) );
         fprintf( stderr, "\n" );
         fprintf( stderr, "      Num points: %d\n", *(curve.num_points) );

         for ( jj = 0; jj < *(curve.num_points); jj++ )
         {
            fprintf( stderr, "      %10.5f %10.5f %10.5f\n",
                     curve.points[jj*3],
                     curve.points[(jj*3) + 1],
                     curve.points[(jj*3) + 2] );
         }
      }

      fprintf( stderr, "   Num Sub Edges: %d\n", *(surface.num_sub_edges) );
      for ( ii = 0; ii < *(surface.num_sub_edges); ii++ )
      {
         DLIST_CRV_ALL_PTRS( surface.sub_edges[ii], curve );

         fprintf( stderr, "      Flags:" );
         DPdlist_print_curve_flags( *(curve.flags) );
         fprintf( stderr, "\n" );
         fprintf( stderr, "      Num points: %d\n", *(curve.num_points) );

         for ( jj = 0; jj < *(curve.num_points); jj++ )
         {
            fprintf( stderr, "      %10.5f %10.5f %10.5f\n",
                     curve.points[jj*3],
                     curve.points[(jj*3) + 1],
                     curve.points[(jj*3) + 2] );
         }
      }

      fprintf( stderr, "   Num VI MSC Edges: %d\n", *(surface.num_vi_msc_edges) );
      for ( ii = 0; ii < *(surface.num_vi_msc_edges); ii++ )
      {
         fprintf( stderr, "   MSC Edge: %u\n", surface.vi_msc_edges[ii] );
      }

      fprintf( stderr, "   Num Sub MSC Edges: %d\n", *(surface.num_sub_msc_ids) );
      for ( ii = 0; ii < *(surface.num_sub_msc_ids); ii++ )
      {
         fprintf( stderr, "   MSC Edge: %u\n", surface.sub_msc_ids[ii] );
      }


   }

   if ( sh_variable_data )
   {
      DLIST_SH_SRF_ALL_PTRS( sh_variable_data, sh_surface );

      fprintf( stderr, "Surface Shading Variable Data\n" );
      fprintf( stderr, "   Byte Size: %d\n", *(sh_surface.byte_size) );
      fprintf( stderr, "   Num Meshes: %d\n", *(sh_surface.num_meshes) );
      fprintf( stderr, "   Diff,Spec,Trans,Finish: %f %f %f %f\n",
               *(sh_surface.diff_refl), *(sh_surface.spec_refl),
               *(sh_surface.trans), *(sh_surface.finish) );

      for ( ii = 0; ii < *(sh_surface.num_meshes); ii++ )
      {
         DLIST_MSH_NUM_VERTS_PTR( sh_surface.meshes[ii], num_verts );
         DLIST_MSH_ALL_PTRS( sh_surface.meshes[ii], mesh, *num_verts );

         fprintf( stderr, "      Num verts: %d   Flags: %#X\n",
                 *(mesh.num_verts), *(mesh.flags) );
         for ( jj = 0; jj < *(mesh.num_verts); jj++ )
         {
            fprintf( stderr, "      %lf %lf %lf - %lf %lf %lf\n",
                     mesh.verts[jj*3], mesh.verts[jj*3+1], mesh.verts[jj*3+2],
                     mesh.vnorms[jj*3], mesh.vnorms[jj*3+1], mesh.vnorms[jj*3+2] );
         }

         fprintf( stderr, "      Num Facet Normals: %d\n", *(mesh.num_facet_normals) );
         for ( jj = 0; jj < *(mesh.num_facet_normals); jj++ )
         {
            fprintf( stderr, "      %lf %lf %lf\n",
                     mesh.fnorms[jj*3], mesh.fnorms[jj*3+1], mesh.fnorms[jj*3+2] );
         }
      }
   }

   return( DLIST_S_SUCCESS );
}  /* DPdlist_print_surface_variable */

/*--- DPdlist_print_unknown_variable --------------------------------------*/

int DPdlist_print_unknown_variable(
   void *variable_data )

/*
NAME
   DPdlist_print_unknown_variable

DESCRIPTION
   This function prints the variable data of an unknown element to stderr.

SYNOPSIS
   int DPdlist_print_unknown_variable(
      void *variable_data )

PARAMETERS
   varialbe_data (IN) - the variable data of the unknown

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/07/93 S.P. Rogers
      Initial implementation
*/

{
   struct DPdlist_unknown_variable unknown;

   DLIST_UNK_ALL_PTRS( variable_data, unknown );

   fprintf( stderr, "Unknown Variable Data\n" );
   fprintf( stderr, "   Byte Size: %d\n", *(unknown.byte_size) );
   fprintf( stderr, "   Disp Func: %#X\n", *(unknown.disp_func) );
   fprintf( stderr, "   Data Size: %u\n", *(unknown.data_size) );
   fprintf( stderr, "   Data: %#X\n", *(unknown.data) );

   return( DLIST_S_SUCCESS );
}  /* DPdlist_print_unknown_variable */

/*--- DPdlist_print_variable_data ---------------------------------------*/

int DPdlist_print_variable_data(
   struct DPdlist_fixed_data *fixed_data )

/*
NAME
   DPdlist_print_varaible_data

DESCRIPTION
   This function prints the variable data referenced by a fixed data
   structure to stderr

SYNOPSIS
   int DPdlist_print_variable_data(
      struct DPdlist_fixed_data *fixed_data )

PARAMETERS
   fixed_data (IN) - the fixed data pointer whose variable data is to
                     be printed

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/07/93 S.P. Rogers
      Initial implementation
*/

{
   int sts;

   if ( ! fixed_data->wf_data )
   {
      fprintf( stderr, "NO WIREFRAME VARIABLE DATA\n" );

      if ( fixed_data->type != DP_DLIST_SURFACE )
      {
         return( DLIST_E_ERROR );
      }
      else
      {
         if ( ! fixed_data->sh_data )
         {
            fprintf( stderr, "NO WIREFRAME/SHADING VARIABLE DATA\n" );
            return( DLIST_E_ERROR );
         }
      }
   }

   switch ( fixed_data->type )
   {
      case DP_DLIST_POINT :
         sts = DPdlist_print_point_variable( fixed_data->wf_data );
         break;

      case DP_DLIST_POLYGON :
         sts = DPdlist_print_polygon_variable( fixed_data->wf_data );
         break;

      case DP_DLIST_CURVE :
         sts = DPdlist_print_curve_variable( fixed_data->wf_data );
         break;

      case DP_DLIST_TEXT :
         if ( fixed_data->ele_flags & DP_DLIST_ELE_FILLED )
         {
            sts = DPdlist_print_filled_text_variable( fixed_data->wf_data );
         }
         else
         {
            sts = DPdlist_print_text_variable( fixed_data->wf_data );
         }
         break;

      case DP_DLIST_SURFACE :
         sts = DPdlist_print_surface_variable( fixed_data->wf_data, fixed_data->sh_data );
         break;

      case DP_DLIST_UNKNOWN :
         sts = DPdlist_print_unknown_variable( fixed_data->wf_data );
         break;

      case DP_DLIST_DIMENSION :
         fprintf( stderr, "   DIMENSIONS HAVE NO VARIABLE DATA\n" );
         sts = DLIST_S_SUCCESS;
         break;

      default:
         fprintf( stderr, "INVALID ELEMENT TYPE\n" );
         sts = DLIST_E_ERROR;
         break;
   }

   return( sts );
}  /* DPdlist_print_variable_data */

/*--- DPdlist_print_fixed_data ------------------------------------------*/

int DPdlist_print_fixed_data(
   struct DPdlist_fixed_data *fixed_data )

/*
NAME
   DPdlist_print_fixed_data

DESCRIPTION
   This function prints a fixed data structure to stderr

SYNOPSIS
   int DPdlist_print_fixed_data(
      struct DPdlist_fixed_data *fixed_data )

PARAMETERS
   fixed_data (IN) - the fixed data to print

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/13/93 S.P. Rogers
      Initial design, specification, and implementation
*/

{
   unsigned short hash_flags, ele_flags;

   fprintf( stderr, "   OBJID: %u  TYPE: ", fixed_data->objid );

   switch ( fixed_data->type )
   {
      case DP_DLIST_POINT :
         fprintf( stderr, "POINT" );
         break;

      case DP_DLIST_POLYGON :
         fprintf( stderr, "POLYGON" );
         break;

      case DP_DLIST_CURVE :
         fprintf( stderr, "CURVE" );
         break;

      case DP_DLIST_TEXT :
         fprintf( stderr, "TEXT" );
         break;

      case DP_DLIST_SURFACE :
         fprintf( stderr, "SURFACE" );
         break;

      case DP_DLIST_DIMENSION :
         fprintf( stderr, "DIMENSION" );
         break;

      case DP_DLIST_UNKNOWN :
         fprintf( stderr, "UNKNOWN" );
         break;

      default :
         fprintf( stderr, "???" );
         break;
   }

   fprintf( stderr, "  DATA: %#X  SHADING DATA: %#X\n", 
            fixed_data->wf_data, fixed_data->sh_data );

   fprintf( stderr, "   HASH FLAGS:" );
   hash_flags = fixed_data->hash_flags;
   if ( hash_flags & DP_DLIST_HASH_EMPTY )
   {
      fprintf( stderr, " EMPTY" );
      hash_flags &= ~DP_DLIST_HASH_EMPTY;
   }

   if ( hash_flags & DP_DLIST_HASH_USED )
   {
      fprintf( stderr, " USED" );
      hash_flags &= ~DP_DLIST_HASH_USED;
   }

   if ( hash_flags & DP_DLIST_HASH_DELETED )
   {
      fprintf( stderr, " DELETED" );
      hash_flags &= ~DP_DLIST_HASH_DELETED;
   }

   if ( hash_flags )
   {
      fprintf( stderr, " %#X", hash_flags );
   }

   fprintf( stderr, "\n" );

   fprintf( stderr, "   ELE FLAGS:" );
   ele_flags = fixed_data->ele_flags;

   if ( ele_flags & DP_DLIST_ELE_DISPLAYABLE )
   {
      fprintf( stderr, " DISPLAYABLE" );
      ele_flags &= ~DP_DLIST_ELE_DISPLAYABLE;
   }

   if ( ele_flags & DP_DLIST_ELE_INACTIVE )
   {
      fprintf( stderr, " INACTIVE" );
      ele_flags &= ~DP_DLIST_ELE_INACTIVE;
   }

   if ( ele_flags & DP_DLIST_ELE_FILLED )
   {
      fprintf( stderr, " FILLED" );
      hash_flags &= ~DP_DLIST_ELE_FILLED;
   }

   if ( ele_flags & DP_DLIST_ELE_HAS_SOS )
   {
      fprintf( stderr, " HAS_SOS" );
      ele_flags &= ~DP_DLIST_ELE_HAS_SOS;
   }

   if ( ele_flags & DP_DLIST_ELE_IS_MSC )
   {
      fprintf( stderr, " IS_MSC" );
      ele_flags &= ~DP_DLIST_ELE_IS_MSC;
   }

   if ( ele_flags & DP_DLIST_ELE_VIEW_IND )
   {
      fprintf( stderr, " VIEW_IND" );
      ele_flags &= ~DP_DLIST_ELE_VIEW_IND;
   }

   if ( ele_flags & DP_DLIST_ELE_SCALE_IND )
   {
      fprintf( stderr, " SCALE_IND" );
      ele_flags &= ~DP_DLIST_ELE_SCALE_IND;
   }

   if ( ele_flags & DP_DLIST_ELE_HAS_GRALOOPS )
   {
      fprintf( stderr, " HAS_GRALOOPS" );
      ele_flags &= ~DP_DLIST_ELE_HAS_GRALOOPS;
   }

   if ( ele_flags & DP_DLIST_ELE_HAS_GRADATA )
   {
      fprintf( stderr, " HAS_GRADATA" );
      ele_flags &= ~DP_DLIST_ELE_HAS_GRADATA;
   }

   if ( ele_flags & DP_DLIST_ELE_HAS_HORIZON_CURVES )
   {
      fprintf( stderr, " HAS_HORIZ_CURVES" );
      ele_flags &= ~DP_DLIST_ELE_HAS_HORIZON_CURVES;
   }

   if ( ele_flags & DP_DLIST_ELE_DISPLAY_POLYGON )
   {
      fprintf( stderr, " DISP_POLY" );
      ele_flags &= ~DP_DLIST_ELE_DISPLAY_POLYGON;
   }

   if ( ele_flags )
   {
      fprintf( stderr, " %#X", ele_flags );
   }

   fprintf( stderr, "\n" );

   fprintf( stderr, "   CSWL: %-.6u %-.6u %-.6u %-.6u\n",
            fixed_data->color, fixed_data->style, fixed_data->weight,
            fixed_data->layer );

   return( DLIST_S_SUCCESS );
} /* DPdlist_print_fixed_data */


/*--- DPdlist_print_hash_table -------------------------------------*/

int DPdlist_print_hash_table(
   OMuword osnum,
   short print_entries )

/*
NAME
   DPdlist_print_hash_table

DESCRIPTION
   This function prints the contents of a hash table to stderr

SYNOPSIS
   int DPdlist_print_hash_table(
      OMuword osnum,
      short print_entries )

PARAMETERS
   osnum (IN) - the object space number of the hash table
   print_entries (IN) - if TRUE, print the entries in the table

GLOBALS USED
   DPhash_tables

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/13/93 S.P. Rogers
      Initial specification, design, and coding

   05/12/93 S.P. Rogers
      Initial implementation
*/

{
   int sts;
   unsigned int index, first;
   short last_slot_empty, last_slot_deleted;
   struct DPdlist_hash_table *table;
   unsigned int search_length, max_search, sum, sum_of_squares;
   double avg_search, variance;
   OM_S_OBJID objid;

   table = &DPhash_tables[osnum];

   fprintf( stderr, "\n\nHash Table For Object Space: %d\n", osnum );
   fprintf( stderr, "   Size: %u  Bytes: %u Used: %u  Fixed Data: %#X\n",
            table->size, table->size * sizeof( struct DPdlist_fixed_data ), table->used, table->fixed_data );
   fprintf( stderr, "   Percent Used: %.2f\n", ((double) table->used / (double) table->size) * 100.0 );

   /* lookup every object once to get some searching statistics */
   sum = 0;
   sum_of_squares = 0;
   max_search = 0;
   for ( index = 0; index < table->size; index++ )
   {
      if ( table->fixed_data[index].hash_flags & DP_DLIST_HASH_USED )
      {
         objid = table->fixed_data[index].objid;
         first = DLIST_HASH_FUNCTION( objid, table->size );

         if ( first == index )
         {
            /* first place to search this slot => search length is 1 */
            search_length = 1;
         }
         else if ( first > index )
         {
            /* first place to search is after this slot => must search */
            /* to the end of the table and then back to this slot      */
            search_length = (table->size - first) + (index + 1);
         }
         else
         {
            /* first place to search is before this slot => must search */
            /* to this slot                                             */
            search_length = index - first + 1;
         }
 
         if ( search_length > max_search )
         {
            max_search = search_length;
         }

         sum += search_length;
         sum_of_squares += (search_length * search_length);
      }
   }

   avg_search = (double) sum / (double) table->used;
   variance = (double) ((table->used * sum_of_squares) - (sum * sum)) /
              (double) (table->used * (table->used - 1) );

   fprintf( stderr, "   Longest Search: %u\n", max_search );
   fprintf( stderr, "   Average Search: %.2f  Standard Deviation: %.2f\n", avg_search, sqrt( variance ) );

   if ( print_entries )
   {
      last_slot_empty = last_slot_deleted = FALSE;
      for ( index = 0; index < table->size; index++ )
      {
         if ( table->fixed_data[index].hash_flags & DP_DLIST_HASH_USED )
         {
            fprintf( stderr, "Slot %d - USED\n", index );
            sts = DPdlist_print_fixed_data( &(table->fixed_data[index]) );
            if ( !(1 & sts) )
            {
               return( sts );
            }
            last_slot_empty = last_slot_deleted = FALSE;
         }
         else if ( table->fixed_data[index].hash_flags & DP_DLIST_HASH_EMPTY )
         {
            if ( ! last_slot_empty )
            {
               fprintf( stderr, "Slot %d - EMPTY\n", index );
            }
            last_slot_empty = TRUE;
            last_slot_deleted = FALSE;
         }
         else if ( table->fixed_data[index].hash_flags & DP_DLIST_HASH_DELETED )
         {
            if ( ! last_slot_deleted )
            {
               fprintf( stderr, "Slot %d - DELETED\n", index );
            }
            last_slot_empty = FALSE;
            last_slot_deleted = TRUE;
         }
      }

   }

   return( DLIST_S_SUCCESS );

}  /* DPdlist_print_hash_table */

/*--- DPdlist_print_element -----------------------------------*/

int DPdlist_print_element(
   OM_S_OBJID objid,
   OMuword osnum )

/*
NAME
   DPdlist_print_element

DESCRIPTION
   This function prints the display list data for an element

SYNOPSIS
   int DPdlist_print_element(
      OM_S_OBJID objid,
      OMuword osnum )

PARAMETERS
   objid (IN) - the object id of the element
   osnum (IN) - the object space number of the element

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_I_NOTFOUND - Element not in display list
   DLIST_E_ERROR - Failure

HISTORY
   06/07/93 S.P. Rogers
      Initial implementation
*/

{
   int sts;
   struct DPdlist_fixed_data *fixed;

   fprintf( stderr, "Element (%d,%d)\n", objid, osnum );

   sts = DPdlist_hash_lookup( objid, osnum, &fixed );

   if ( ! fixed )
   {
      fprintf( stderr, "   NOT IN HASH TABLE\n" );
      return( DLIST_I_NOTFOUND );
   }

   sts = DPdlist_print_fixed_data( fixed );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   sts = DPdlist_print_variable_data( fixed );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   return( DLIST_S_SUCCESS );

}  /* DPdlist_print_element */

/*--- DPdlist_print_hash_statistics ----------------------------------*/

int DPdlist_print_hash_statistics(
   int osnum )

{
   struct DPdlist_hash_table *table;

   table = &DPhash_tables[osnum];

   fprintf( stderr, "\n\nHash Table Statistics For Object Space: %d\n", osnum );
   fprintf( stderr, "   Size: %u  Used: %u  Fixed Data: %#X\n",
            table->size, table->used, table->fixed_data );
   fprintf( stderr, "   Percent Used: %.2f\n", ((double) table->used / (double) table->size) * 100.0 );

   return( DLIST_S_SUCCESS );

} /* DPdlist_print_hash_statistics */

