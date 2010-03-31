#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "OMerrordef.h"

#include "bs.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "exdef.h"
#include "msdef.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"

#include "dl.h"

#include "DPdlist.h"
#include "HSdlist.h"

#include "HSe2_mesher.h"

/* Math Prototypes */
#include "bsdotp.h"
#include "bscrossp.h"
#include "bsnorvec.h"

/* New Prototypes */
PROTO_HSdlist_save_tri_mesh
PROTO_HSdlist_enter_reference_file
PROTO_HSdlist_exit_reference_file
PROTO_HSdlist_push_matrix
PROTO_HSdlist_pop_matrix

extern int DPdlist_alloc_chunk(int size, void **ptr);
extern int DPdlist_add_mesh_to_set(void *mesh_ptr);

#if defined(XGL)
extern unsigned int  HSdlist_first_setting;
#endif

/*--- HSdlist_save_tri_mesh -----------------------------------*/

int HSdlist_save_tri_mesh(
   int vc_no,
   struct HStri_mesh *mesh )

/*
NAME
   HSdlist_save_tri_mesh

DESCRIPTION
   This function is called from the tiler to save a
   triangular mesh in the display list for a surface.

SYNOPSIS
   int HSdlist_save_tri_mesh(
      int vc_no,
      struct HStri_mesh *mesh )

PARAMETERS
   vc_no (IN) - not used; its purpose is to match the
                arguments normally used by HSURF when
                calling the mesh processing function
                via pointer
   mesh (IN) - the triangular mesh

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS
      Success
   DLIST_E_ERROR
      Failure

HISTORY
   07/16/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   int num_verts, num_facet_normals;
   float *fnorms, *verts, *vnorms;
   unsigned int byte_size;
   void *chunk;
   struct DPdlist_tri_mesh mesh_ptrs;
#if defined ( OPENGL ) || defined( XGL )
   long rc;
   int odd_triangle;
   int ind, ii, send_last_separately = FALSE;
   IGRdouble v1[3], v2[3], calc_facet_normal[3];
   int found = FALSE;
   double dotp;
   int fnorm_index;
#endif

   num_verts = mesh->numVerts;
   verts = (float *)mesh->verts;
   vnorms = (float *)mesh->vNorms;
   fnorms = (float *)mesh->fNorms;
   num_facet_normals = mesh->numFacetNormals;

#if defined( OPENGL ) || defined( XGL )
   /* calculate a normal to the triangluar mesh in */
   /* the same way that OpenGL will                */
   for ( ii = 0; (ii < 2) && (!found); ii++ )
   {
      if ( ii == 0 )
      {
         /* checking odd triangles */
         odd_triangle = TRUE;
         ind = -6;
         if ( mesh->numFacetNormals > 1 )
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
         if ( mesh->numFacetNormals > 1 )
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

         if ( ind >= ((num_verts-2) * 3) )
         {
            break;
         }
         
         if ( mesh->numFacetNormals > 1 )
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
      return( DLIST_E_ERROR );
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

      if ( !(num_verts % 2) )
      {
         verts = &verts[(num_verts - 2) * 3];
         vnorms = &vnorms[(num_verts - 2) * 3];
         if ( num_facet_normals > 1 )
         {
            fnorms = &fnorms[(num_verts - 4) * 3];
         }
      
         /* even number of vertices => must put last triangle */
         /* in a separate mesh                                */
         byte_size = DLIST_SIZEOF_MSH( 3, 1 );

         sts = DPdlist_alloc_chunk( byte_size, &chunk );

         if ( !(1 & sts) )
         {
            return( DLIST_E_ERROR );
         }
#if HS_DEBUG
	 printf("byte_size = %d, chunk_ptr = %x\n",byte_size,chunk);
#endif

         DLIST_MSH_ALL_PTRS( chunk, mesh_ptrs, 3 );

         *(mesh_ptrs.byte_size) = byte_size;
         *(mesh_ptrs.num_verts) = 3;
         *(mesh_ptrs.flags) = 0;
         *(mesh_ptrs.num_facet_normals) = 1;

         memcpy( mesh_ptrs.verts, verts - 3, 9 * sizeof( float ) );
         memcpy( mesh_ptrs.vnorms, vnorms - 3, 9 * sizeof( float ) );
         if ( num_facet_normals > 1 )
         {
            memcpy( mesh_ptrs.fnorms, fnorms + 3, 3 * sizeof( float ) );
         }
         else
         {
            memcpy( mesh_ptrs.fnorms, fnorms, 3 * sizeof( float ) );
         }

         sts = DPdlist_add_mesh_to_set( chunk );

         if ( !(1 & sts) )
         {
            return( DLIST_E_ERROR );
         }

         num_verts--;
      }
      else
      {
         verts = &verts[(num_verts - 1) * 3];
         vnorms = &vnorms[(num_verts - 1) * 3];
         if ( num_facet_normals > 1 )
         {
            fnorms = &fnorms[(num_verts - 3) * 3];
         }
      }

      /* reverse the remaining mesh */
      num_facet_normals = (mesh->numFacetNormals > 1) ?
                (mesh->numFacetNormals - 1) : 1;
      byte_size = DLIST_SIZEOF_MSH( num_verts, num_facet_normals );

      sts = DPdlist_alloc_chunk( byte_size, &chunk );

      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
#if HS_DEBUG
	 printf("byte_size = %d, chunk_ptr = %x\n",byte_size,chunk);
#endif

      DLIST_MSH_ALL_PTRS( chunk, mesh_ptrs, num_verts );

      *(mesh_ptrs.byte_size) = byte_size;
      *(mesh_ptrs.num_verts) = num_verts;
      *(mesh_ptrs.flags) = 0;
      *(mesh_ptrs.num_facet_normals) = num_facet_normals;

      for ( ii = 0; ii < num_verts; ii++, verts -= 3, vnorms -= 3 )
      {
         mesh_ptrs.verts[ii*3] = verts[0];
         mesh_ptrs.verts[ii*3+1] = verts[1];
         mesh_ptrs.verts[ii*3+2] = verts[2];

         mesh_ptrs.vnorms[ii*3] = vnorms[0];
         mesh_ptrs.vnorms[ii*3+1] = vnorms[1];
         mesh_ptrs.vnorms[ii*3+2] = vnorms[2];

      }
      
      if ( mesh->numFacetNormals > 1 )
      {
         for ( ii = 0; ii < (num_verts - 2); ii++, fnorms -= 3 )
         {
            mesh_ptrs.fnorms[ii*3] = fnorms[0];
            mesh_ptrs.fnorms[ii*3+1] = fnorms[1];
            mesh_ptrs.fnorms[ii*3+2] = fnorms[2];
         }
      }
      else
      {
         memcpy( mesh_ptrs.fnorms, fnorms, 3 * sizeof( float ) );
      }


      sts = DPdlist_add_mesh_to_set( chunk );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }

   }
   else
#endif
   {
      /* don't need to reverse mesh */
      byte_size = DLIST_SIZEOF_MSH( num_verts, num_facet_normals );

      sts = DPdlist_alloc_chunk( byte_size, &chunk );

      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
#if HS_DEBUG
	 printf("byte_size = %d, chunk_ptr = %x\n",byte_size,chunk);
#endif

      DLIST_MSH_ALL_PTRS( chunk, mesh_ptrs, num_verts );

      *(mesh_ptrs.byte_size) = byte_size;
      *(mesh_ptrs.num_verts) = num_verts;
      *(mesh_ptrs.flags) = 0;
      *(mesh_ptrs.num_facet_normals) = num_facet_normals;

      memcpy( mesh_ptrs.verts, mesh->verts, num_verts * sizeof( struct HStri_point ) );
      memcpy( mesh_ptrs.vnorms, mesh->vNorms, num_verts * sizeof( struct HStri_point ) );
      memcpy( mesh_ptrs.fnorms, mesh->fNorms, num_facet_normals * sizeof( struct HStri_point ) );
   
      sts = DPdlist_add_mesh_to_set( chunk );

      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }

   }

   return( DLIST_S_SUCCESS );
} /* HSdlist_save_tri_mesh */

/*--- HSdlist_enter_reference_file ----------------------------------*/

int HSdlist_enter_reference_file(
   struct DP_information *dp_info,
   IGRshort matrix_type,
   IGRmatrix matrix )

/*
NAME
   HSdlist_enter_reference_file

DESCRIPTION
   This function is used to tell the display list that a refernce
   file has been entered.  It is used to speed up the display
   by concatenating the ref-file-to-world matrix with the
   viewing matrix

SYNOPSIS
   int HSdlist_enter_reference_file(
      struct DP_information *dp_info,
      IGRshort matrix_type,
      IGRmatrix matrix )

PARAMETERS
   dp_info (IN) - display information for window
   matrix_type (IN) - the type of the ref. file matrix
   matrix (IN) - the reference file matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS
      Success

HISTORY
   07/19/93 S.P. Rogers
      Initial spefication, design, and implementation
*/

{

   /* put processing here when using a library */
   /* besides EG or OPENGL                     */

#if defined(XGL)
	HSdlist_first_setting = TRUE;
#endif
   return( DLIST_S_SUCCESS );
} /* HSdlist_enter_reference_file */

/*--- HSdlist_exit_reference_file ----------------------------------*/

int HSdlist_exit_reference_file(
   struct DP_information *dp_info,
   IGRshort matrix_type,
   IGRmatrix matrix )

/*
 NAME
   HSdlist_exit_reference_file

DESCRIPTION
   This function is used to tell the display list that a refernce
   file has been exited.  It is used to speed up the display
   by concatenating the ref-file-to-world matrix with the
   viewing matrix

SYNOPSIS
   int HSdlist_exit_reference_file(
      struct DP_information *dp_info,
      IGRshort matrix_type,
      IGRmatrix matrix )

PARAMETERS
   dp_info (IN) - display information for window
   matrix_type (IN) - the type of the ref. file matrix
   matrix (IN) - the reference file matrix

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS
      Success

HISTORY
   07/19/93 S.P. Rogers
      Initial spefication, design, and implementation
*/

{

   /* put processing here when using a library */
   /* besides EG or OPENGL                     */

   return( DLIST_S_SUCCESS );
} /* HSdlist_exit_reference_file */
