
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>

#include "wl.h"

#if defined( ENV5 )
#include <gpipe.h>
#include <EG.h>
#endif

#include "bs.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "HSdlist.h"
#include "hstiler.h"
#include "hslight.h"
#include "hsdef.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "hsdisplay.h"
#include "hsmacros.h"
#include "hsmacdef.h"
#include "hsmultframes.h"
#include "hsurf.h"
#include "hsmath.h"

#include "HSe2_mesher.h"

#include "HSpr_driver.h"
#include "HSpr_tiler_f.h"

/* math prototypes */
#include "bsdotp.h"
#include "bscrossp.h"
#include "bsnorvec.h"

#define HR_60K                 61440

#define HS_TILER_RESERVE       2097152  /* 2 MB */

#define SURF_ALLOC_CHECKS      0
#define NO_PREV_ACTIVE_WINDOW  -99
#define FLINK_DEBUG            0
#define SURFACE_DEBUG          0
#define EDGEII_DEBUG           0
#define DEBUG_EDGEII           0
#define GETTING_RANGE          0

#define HSALIGN_DOUBLE( ptr ) if ( ((int) (ptr)) % 8 ) \
              (ptr) = (void *)((char *)(ptr) + 8 - (unsigned long)(ptr) % 8);

/* External Variables */

extern IGRboolean  DPdlist_feedback_in_progress;

/* Local Variables */

static IGRint       save_pipe_no = NO_PREV_ACTIVE_WINDOW;

static IGRboolean   load_both = FALSE;
static IGRboolean   load_disp = FALSE;
static IGRboolean   load_fb = FALSE;

static IGRint       *hdr_word_ptr;
static IGRint       *user_hdr_word;
static IGRint       *next_word_ptr;
static IGRint       *next_user_word;
static IGRint       *last_surface;
static IGRint       *last_surf_hdr_word;

static IGRdouble    **cur_disp_ptr;
static IGRdouble    *end_disp_ptr;
static IGRdouble    **cur_app_fb_ptr;
static IGRdouble    *end_app_fb_ptr;
static IGRdouble    *local_beg_ptr;
static IGRdouble    *local_end_ptr;

static IGRint       total_bytes;
static IGRint       buffer_bytes;
static IGRint       fb_buffer_size;
static IGRchar      *CurHighWater;
static IGRchar      *MaxHighWater;

static IGRdouble   IDENTITY_4x4[4][4] = { 1.0, 0.0, 0.0, 0.0,
                                          0.0, 1.0, 0.0, 0.0,
                                          0.0, 0.0, 1.0, 0.0,
                                          0.0, 0.0, 0.0, 1.0 };

#define FEEDBACK_DEBUG   0
#define DISPLAY_DEBUG    0
#define TEMP_DEBUG       0
#define TRIMESH_DEBUG    0
#define COLORMODE_DEBUG  0
#define MESHSIZE_DEBUG   0

#if FEEDBACK_DEBUG
static IGRdouble    *UserBuffer;
#endif

#define		DEBUG	1

/*----------------------------------------------------------------------------*/

/*
 * HSdump_fb_buffer() prints out to 'stderr' the buffer pointed to by 'cur_ptr'.
 *
 * HISTORY: ??/??/??   Created.
 *                        Anon
 *       11/09/89   Formatted properly and added ability to dump chained buffers.
 *                        Trevor Mink
 */

void HSdump_fb_buffer( IGRint *fb_buffer_ptr )
   
{
   int        *cur_ptr;
   IGRint     color;
   IGRint     weight;
   IGRint     options;
   IGRint     num_polygons;
   IGRint     num_verts;
   IGRint     ii;
   IGRint     vertices_per_polygon;
   IGRdouble  *facet_normal;
   IGRdouble  *points;
   IGRdouble  *vectors=NULL;

   cur_ptr = fb_buffer_ptr;

   fprintf( stderr, "BUFFER CONTENTS ARE AS FOLLOWS: \n");
   fprintf( stderr, "start address=%x contents=%d\n", fb_buffer_ptr,
                                                      *fb_buffer_ptr);

   /* process each surface */
   while ( cur_ptr &&
           ((*cur_ptr) & NEXT_SURFACE_MASK || *cur_ptr == HSFRAMELINK ) )
   {

      if ( *cur_ptr == HSFRAMELINK )
      {
         cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);
         if ( cur_ptr )
         {
            cur_ptr += 2;
            fb_buffer_ptr = cur_ptr;
         }
         else
         {
            /* if no other buffer blocks, exit loop */
            break;
         }
      }

      options = (*(cur_ptr++)) & (~NEXT_SURFACE_MASK);
      fprintf( stderr, "1:options=%x\n", options );

      color = *(cur_ptr++);
      weight = *(cur_ptr++);
      fprintf( stderr, "2:color=%d  weight=%d\n", color, weight );

      if ( options == HS_BST_POINT )
      {
         num_verts = *(cur_ptr++);
         fprintf( stderr, "3:num_verts=%d\n", num_verts);
         HSALIGN_DOUBLE( cur_ptr );
         points = (IGRdouble *) cur_ptr;

         for ( ii = 0; ii < 3 * num_verts - 2; ii += 3 )
         {
            fprintf( stderr, "vertex:%lf %lf %lf\n", points[ii], points[ii+1],
                     points[ii+2] );
         }
         cur_ptr += 6* num_verts;
      }
      else
      {
         while ( (*cur_ptr) && ! ((*cur_ptr) & NEXT_SURFACE_MASK) )
         {
            if ( *cur_ptr == HSFRAMELINK )
            {
               cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);
               if ( cur_ptr )
               {
                  cur_ptr += 2;
                  fb_buffer_ptr = cur_ptr;
                  continue;
               }
               else
               {
                  /* if no other buffer blocks, exit loop */
                  break;
               }
            }

            num_polygons = *(cur_ptr++);
            fprintf( stderr, "num_polygons=%d\n", num_polygons);

            if ( num_polygons <= 0 || num_polygons > 10000 )
            {
               break;
            }

            num_verts = *(cur_ptr++);
            fprintf( stderr, "num_verts=%d\n", num_verts);

            vertices_per_polygon = *cur_ptr;
            fprintf( stderr, "vertices_per_polygon=%d\n", vertices_per_polygon);
            cur_ptr += num_polygons;
            HSALIGN_DOUBLE( cur_ptr );

            facet_normal = (IGRdouble *) cur_ptr;
            cur_ptr += 6;

            points = (IGRdouble *) cur_ptr;
            cur_ptr += 6 * num_verts;

            if( element_parms.facet_type == SMOOTH_SHADE )
            {
               vectors = (IGRdouble *) cur_ptr;
               cur_ptr += 6 * num_verts;
            }

            fprintf( stderr, "facet_normals:%lf %lf %lf\n",
                     facet_normal[0], facet_normal[1], facet_normal[2] );

            for ( ii = 0; ii < 3 * num_verts - 2; ii += 3 )
            {
               fprintf( stderr, "vertex:%lf %lf %lf\n",
                        points[ii], points[ii+1], points[ii+2] );
            }

            if( element_parms.facet_type == SMOOTH_SHADE )
            {
               for ( ii = 0; ii < 3 * num_verts - 2; ii += 3 )
               {
                  fprintf( stderr, "normal:%lf %lf %lf\n",
                           vectors[ii], vectors[ii+1], vectors[ii+2] );
               }
            }
         }/* end of facet while loop */
      }/* else it is a surafce */
   }/* end of surface while */
} /* HSdump_fb_buffer */


/*
 * HSdump_edgeII_fb_buffer() prints out to 'stderr' the buffer pointed to by
 * 'cur_ptr'.
 *
 * HISTORY: 03/07/90   Adapted from HSdump_fb_buffer(), dumps the buffer
 *          formatted for EDGEII machines.
 *                        Trevor Mink
 */

void HSdump_edgeII_fb_buffer( IGRint *fb_buffer_ptr )
   
{
   IGRint  *cur_ptr;
   IGRint  color;
   IGRint  weight;
   IGRint  options;
   IGRint  cull_flag;
   IGRint  num_verts;
   IGRint  NumFacetNormals;
   IGRint  i;
   IGRint  ii;
   float   *facet_normal;
   float   *vertices;
   float   *vectors;
   double  *points;

   cur_ptr = fb_buffer_ptr;

   fprintf( stderr, "BUFFER CONTENTS ARE AS FOLLOWS: \n");
   fprintf( stderr, "start address=%x contents=%d\n",
            fb_buffer_ptr, *fb_buffer_ptr);

   /* process each surface */
   while ( cur_ptr &&
           ((*cur_ptr) & NEXT_SURFACE_MASK || *cur_ptr == HSFRAMELINK ) )
   {
      if ( *cur_ptr == HSFRAMELINK )
      {
         cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);
         if ( cur_ptr )
         {
            cur_ptr += 2;
            fb_buffer_ptr = cur_ptr;
         }
         else
         {
            /* if no other buffer blocks, exit loop */
            break;
         }
      }

      options = (*(cur_ptr++)) & (~NEXT_SURFACE_MASK);
      fprintf( stderr, "1:options=%x\n", options );
      color = *(cur_ptr++);
      weight = *(cur_ptr++);
      cull_flag = *(cur_ptr++);
      fprintf( stderr, "2:color=%d  weight=%d cull=%d CUR_PTR(%x)=%d\n",
               color, weight, cull_flag, cur_ptr, *cur_ptr );

      if ( options == HS_BST_POINT )
      {
         num_verts = *(cur_ptr)++;
         fprintf( stderr, "3:num_verts=%d\n", num_verts);
         HSALIGN_DOUBLE( cur_ptr );
         points = (IGRdouble *) cur_ptr;

         for ( ii = 0; ii < 3 * num_verts - 2; ii += 3 )
         {
            fprintf( stderr, "vertex:%lf %lf %lf\n",
                     points[ii], points[ii+1], points[ii+2] );
         }
         cur_ptr += 6 * num_verts;
      }
      else
      {
         while ( (*cur_ptr) && ! ((*cur_ptr) & NEXT_SURFACE_MASK) )
         {
            if ( *cur_ptr == HSFRAMELINK )
            {
               cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);
               if ( cur_ptr )
               {
                  cur_ptr += 2;
                  fb_buffer_ptr = cur_ptr;
                  continue;
               }
               else
               {
                  /* if no other buffer blocks, exit loop */
                  break;
               }
            }

            if( options & HS_BST_POLYLINE ||
                options & HS_BST_POLYLINE_DELETE )
            {
               /* Pull out POLYLINE data as stored */
               num_verts = *(cur_ptr++);
               vertices = (float *)cur_ptr;
               fprintf( stderr, "Polyline with %d vertices\n", num_verts );
               for( i = 0; i < num_verts; i++ )
               {
                  fprintf( stderr, "point: (%lf, %lf, %lf)\n",
                           vertices[0], vertices[1], vertices[2] );
                  vertices += 3;
               }
               cur_ptr = (int *)vertices;
            }
            else
            {
               while( *cur_ptr && !( *cur_ptr & NEXT_SURFACE_MASK) &&
                      *cur_ptr != HSFRAMELINK )
               {
                  num_verts = *(cur_ptr++);
                  NumFacetNormals = *(cur_ptr++);
                  facet_normal = (float *)cur_ptr;

                  cur_ptr += 3 * NumFacetNormals;

                  for( i = 0; i < NumFacetNormals; i++ )
                  {
                     fprintf( stderr, "facet_normal # %d: (%lf, %lf, %lf)\n",
                              i, facet_normal[0], facet_normal[1],
                              facet_normal[2] );
                     facet_normal += 3;
                  }

                  if ( options & GR_BST_SMOOTH )
                  {
                     vertices = (float *) cur_ptr;
                     cur_ptr += 3 * num_verts;
                     vectors = (float *) cur_ptr;
                     cur_ptr += 3 * num_verts;
                     for ( ii = 0; ii < 3 * num_verts - 2; ii += 3 )
                     {
                        fprintf( stderr, "point: (%lf, %lf, %lf)\t\t",
                                 vertices[ii], vertices[ii+1],
                                 vertices[ii+2] );
                        fprintf( stderr, "normal:%lf %lf %lf\n",
                                 vectors[ii], vectors[ii+1],
                                 vectors[ii+2] );
                     }
                  }
                  else if( options & GR_BST_CONSTANT )
                  {
                     vertices = (float *) cur_ptr;
                     cur_ptr += 3 * num_verts;
                     for ( ii = 0; ii < 3 * num_verts - 2; ii += 3 )
                     {
                        fprintf( stderr, "point: (%lf, %lf, %lf)\n",
                                 vertices[ii], vertices[ii+1],
                                vertices[ii+2] );
                     }
                  }
               }
            }
         }/* end of facet while loop */
      }/* else it is a surafce */
   }/* end of surface while */
} /* HSdump_edgeII_fb_buffer */

/*
 * HSget_next_block() gets a new frame and takes care of linking the old
 * buffer to the new one.
 *
 * PRE: The assumption is that this will be called only for display buffers
 *      ( as the user buffer is not chained ).
 *
 * HISTORY: 11/06/89   Created.
 *                           Trevor Mink
 */

static IGRint HSget_next_block( void )

{
   IGRint      status;
   IGRboolean  EndOfProcessMem = FALSE;
   IGRint      total_mem;
   IGRint      used_mem;

#if DISPLAY_DEBUG
   fprintf( stderr, "HSget_next_block being called\n" );
#endif
   CurHighWater = (IGRchar *)sbrk(0);
   HSget_vm_stats( &total_mem, &used_mem, NULL );

   if ( ( total_mem - used_mem <= HS_TILER_RESERVE ) &&
        ( MaxHighWater != CurHighWater ) )
   {
      if ( MaxHighWater == 0 )
      {
         MaxHighWater = CurHighWater;
      }
      else
      {
         EndOfProcessMem = TRUE;
      }
   }

   if ( !EndOfProcessMem )
   {
      if ( status = DPget_frame_block( 0 ) )
      {
         DPinq_buf_ptrs( &cur_disp_ptr,
                         &end_disp_ptr,
                         &cur_app_fb_ptr,
                         &end_app_fb_ptr );

         *hdr_word_ptr = (IGRint)(*cur_disp_ptr - 1);
         hdr_word_ptr = (IGRint *)(*cur_disp_ptr - 1);
      }
      else
      {
         *hdr_word_ptr = NULL;
         *last_surf_hdr_word = NULL;
         HSset_status( HSSTAT_VIEW_DYN_LIMIT );
         HSset_feedback_full_mode( TRUE );
      }
   }
   else
   {
      *hdr_word_ptr = NULL;
      *last_surf_hdr_word = NULL;
      HSset_feedback_full_mode( TRUE );
      HSset_status( HSSTAT_VIEW_DYN_LIMIT );
      status = 0;
   }

#if DISPLAY_DEBUG
   fprintf( stderr, "HSget_next_block returns a block at address: ");
   fprintf( stderr, "%x\tstatus = %d\tChunks_left = %d\n",
            hdr_word_ptr, status, Chunks_left );
#endif

   return (status);

} /* HSget_next_block */

/*----------------------------------------------------------------------------*/

/*
 * ABSTRACT:   HSsave_surface stuffs the given data into a new surface header
 *      and links it onto the feedback list.
 *
 * HISTORY:   03/29/88   Created.                    C. M. Jablonski
 *            07/12/93   Added display list support  Shridar Subramanian
 *
 *
 */

void HSsave_surface( IGRint    color, 
                     IGRint    options, 
                     IGRint    num_points, 
                     IGRdouble *points )
   
{
   register IGRint  num_bytes;
   IGRint           *save_ptr;
   unsigned char    *buffer_dst;
   unsigned char    *buffer_src;
   IGRint           status;
   IGRint           Size=0;
   IGRint           HeaderSize;
   IGRint           rgb_value;
   float            *next_float_ptr;

   /* If in display list mode, return  */
   if ( DPdlist_feedback_in_progress )
   {
      return;
   }

   if( tiling_parms.processing_mode & HS_PMODE_FEEDBACK_FULL )
   {
      return;
   }

   last_surface = next_word_ptr;
   last_surf_hdr_word = hdr_word_ptr;

#if SURFACE_DEBUG
   fprintf( stderr, "surface being written to (last_surface = )%x\t",
            last_surface, );
   fprintf( stderr, "last_surf_hdr_word = %x\n", last_surf_hdr_word );
#endif

   if( active_window->type & (HShardware_LB_EG | HShardware_LB_OPENGL 
			| HShardware_LB_XGL) )
   {
      HeaderSize = 10;
   }
   else
   {
      HeaderSize = 4;
   }

   num_bytes = HeaderSize * sizeof( IGRint );

   if ( options == HS_BST_POINT )
   {
      save_ptr = next_word_ptr;
      next_word_ptr += HeaderSize;
      next_word_ptr++;

      HSALIGN_DOUBLE( next_word_ptr );
      num_bytes = ABS( next_word_ptr - save_ptr ) * 4;

#if TRIMESH_DEBUG
      fprintf( stderr, "Points found save_ptr = %x\tnext_word_ptr = %x\n",
               save_ptr, next_word_ptr );
#endif

      next_word_ptr = save_ptr;

      Size = ( num_points * 3 * sizeof( IGRdouble ) );
      num_bytes += Size;
   }

   if ( buffer_bytes + num_bytes + LINK_SIZE > fb_buffer_size )
   {
      *next_word_ptr = HSFRAMELINK;
      if ( load_disp || load_both )
      {
         if ( ! ( status = HSget_next_block () ) )
         {

#if DISPLAY_DEBUG
            fprintf( stderr, "Ran out of room (returning)\n");
#endif
            return;
         }
         else
         {
            fb_buffer_size = status - 16;
#if TEMP_DEBUG
            fprintf( stderr, "status = %d\tfb_buffer_size = %d\n",
               status, fb_buffer_size );
#endif
            next_word_ptr = (IGRint *) *cur_disp_ptr;
            total_bytes += buffer_bytes;
            buffer_bytes = 0;
         }
      }
      else
      {
         HSset_status( HSSTAT_VIEW_DYN_LIMIT );
         HSset_feedback_full_mode( TRUE );
         return;
      }
   }

   if ( total_bytes + num_bytes > APP_FEEDBACK_SIZE && load_both )
   {
      load_both = FALSE;
      load_disp = TRUE;
   }

#if SURFACE_DEBUG
   fprintf( stderr, "options = %x\tcolor = %d\tweight = %d\n", options, color,
           element_parms.visible_weight );
#endif

   /* write surface header, color and weight */
   *( next_word_ptr++ ) = NEXT_SURFACE_MASK|( options );
   if( active_window->type & (HShardware_LB_EG | HShardware_LB_OPENGL 
		| HShardware_LB_XGL) )
   {
      /* Store the base color */
      rgb_value = HSget_rgb_value( color );

      next_float_ptr = (float *)next_word_ptr;
      *( next_float_ptr++ ) =
                     (float)((rgb_value >> 20) & 0x3ff) / (float)(0x3ff);
      *( next_float_ptr++ ) =
                     (float)((rgb_value >> 10) & 0x3ff) / (float)(0x3ff);
      *( next_float_ptr++ ) =
                     (float)(rgb_value & 0x3ff) / (float)(0x3ff);

      next_word_ptr = (int *)next_float_ptr;

      /* render parms pointer is set for curves, points, text, etc */
      if ( element_parms.render_parms )
      {
         *( next_word_ptr++ ) = (int)(element_parms.render_parms->finish);
         next_float_ptr = (float *)next_word_ptr;
         *( next_float_ptr++ ) = element_parms.render_parms->spec_refl;
         *( next_float_ptr++ ) = element_parms.render_parms->diff_refl;
         *( next_float_ptr++ ) = element_parms.render_parms->transparency;
      }
      else
      {
         /* render parms not defined => just zero out data */
         *( next_word_ptr++ ) = 0;
         next_float_ptr = (float *)next_word_ptr;
         *( next_float_ptr++ ) = 0.0;
         *( next_float_ptr++ ) = 0.0;
         *( next_float_ptr++ ) = 0.0;
      }
      next_word_ptr = (int *)next_float_ptr;
   }
   else
   {
      *( next_word_ptr++ ) = color;
   }

   *( next_word_ptr++ ) = element_parms.visible_weight;
   *( next_word_ptr++ ) = element_parms.culling_back_planes;

#if CULLING_DEBUG
   fprintf( stderr, "culling_back_planes = %d\n", element_parms.culling_back_planes );
#endif
   if ( options == HS_BST_POINT )
   {
      *( next_word_ptr++ ) = num_points;
      HSALIGN_DOUBLE( next_word_ptr );
      memcpy( next_word_ptr, points, Size );

      /* num_points * 3 * 2 integers written */
      next_word_ptr += (num_points * 3 * 2);
   }

   if ( load_disp )
   {
      *cur_disp_ptr = (IGRdouble *) next_word_ptr;
   }
   else if ( load_fb )
   {
      *cur_app_fb_ptr = (IGRdouble *) next_word_ptr;
   }
   else if ( load_both )
   {
      buffer_src = (unsigned char *)(*cur_disp_ptr);
      buffer_dst = (unsigned char *)next_user_word;
      memcpy( buffer_dst, buffer_src, num_bytes );
      next_user_word += ( num_bytes / 4 );

#if FEEDBACK_DEBUG
      printf( "buffer_src = %x copied to buffer_dst = %x for %d bytes\n",
               buffer_src, buffer_dst, num_bytes);
#endif

      *cur_disp_ptr = (IGRdouble *) next_word_ptr;
      *cur_app_fb_ptr = (IGRdouble *) next_user_word;
   }

   buffer_bytes += num_bytes;

#if DISPLAY_DEBUG
   fprintf( stderr, "Exit HSsave_surface:num_bytes = %d\tbuffer_bytes = %d\n",
            num_bytes, buffer_bytes );
   fprintf( stderr, "last_surface = %x\tnext_word_ptr is now %x\n",
            last_surface, next_word_ptr );
#endif

   num_bytes = 0;

} /* HSsave_surface */


/*
 * GetMeshSize() calculates and returns the number of bytes necessary to store
 * the triangular mesh 'TriMesh'.
 *
 * HISTORY: 08/07/90   Created.     Trevor Mink
 */

static int GetMeshSize(
   int num_verts,
   int num_facet_normals,
   float *vnorms )

{
   int  NumNormals;
   int  MeshSize;

   /* To store numVerts and NumFacetNormals */
   MeshSize = 2 * sizeof( int );

   /* First, get number of 'facet' normals */
   NumNormals = num_facet_normals;

   /* Now, add in the number of 'vertex' normals */
   if( vnorms )
   {
      NumNormals += num_verts;
   }

   /* To store all normals and vertices */
   MeshSize += 3 * ( NumNormals + num_verts ) * sizeof( float );

   /* Will be aligned to a double word boundary */
   MeshSize = ( MeshSize + 4 ) / 8 * 8;

   return( MeshSize );

} /* GetMeshSize */


static int HSput_mesh_in_buffer(
  int num_verts,
  int num_facet_normals,
  float *verts,
  float *vnorms,
  float *fnorms )

/*
NAME
   HSput_mesh_in_buffer (static)

DESCRIPTION
   This function puts a triangular mesh in the feedback 
   buffer.

SYNOPSIS
   static int HSput_mesh_in_buffer(
     int num_verts,
     int num_facet_normals,
     float *verts,
     float *vnorms,
     float *fnorms )

PARAMETERS
   num_verts (IN) - the number of vertices in the mesh
   num_facet_normals (IN) - the number of facet normals in the mesh
   verts (IN) - the verices of the mesh
   vnorms (IN) - the vertex normals for the mesh (can be NULL)
   fnorms (IN) - the facet normals for the mesh

GLOBALS USED
   tiling_parms
   fb_buffer_size, load_disp, load_both
   next_word_ptr, next_user_word

RETURN VALUES
   0 - Failure
   1 - Success

HISTORY
   08/23/93 S.P. Rogers
      Creation Date
*/
   
{
   int             MeshSize;
   int             ArraySize;
   int             status=0;
   int             *SavePtr;
   int             num_bytes;
   unsigned char   *buffer_src;
   unsigned char   *buffer_dst;
   float           *vertices;
   float           *normals;
   float           *facet_normals;


   if( tiling_parms.processing_mode & HS_PMODE_FEEDBACK_FULL )
   {
      return(0);
   }

   MeshSize = GetMeshSize( num_verts, num_facet_normals, vnorms );

   if( MeshSize + LINK_SIZE > HSMAX_FRAME_SIZE )
   {
      return(0);
   }

   if( ( buffer_bytes + MeshSize + LINK_SIZE) > fb_buffer_size )
   {
      *next_word_ptr = HSFRAMELINK;
      if ( load_disp || load_both )
      {
         if ( ! ( status = HSget_next_block() ) )
         {
            *last_surface = HSFRAMELINK;
            return(0);
         }
         else
         {
            fb_buffer_size = status - 16;
            next_word_ptr = (IGRint *) *cur_disp_ptr;

            total_bytes += buffer_bytes;
            buffer_bytes = 0;
         }
      }
      else
      {
         HSset_status( HSSTAT_VIEW_DYN_LIMIT );
         HSset_feedback_full_mode( TRUE );
         return(0);
      }
   }

   if( total_bytes + MeshSize > APP_FEEDBACK_SIZE && load_both )
   {
      load_both = FALSE;
      load_disp = TRUE;
   }

   /* save the next_word_ptr for computing the total number of words */
   /* written later                                                  */
   SavePtr = next_word_ptr;

   *(next_word_ptr++) = num_verts;
   *(next_word_ptr++) = num_facet_normals;

   facet_normals = (float *)next_word_ptr;
   next_word_ptr += 3 * num_facet_normals;

   ArraySize = num_facet_normals * 3 * sizeof( float );
   memcpy( facet_normals, fnorms, ArraySize );

   vertices = (float *)next_word_ptr;
   next_word_ptr += 3 * num_verts;

   ArraySize = num_verts * 3 * sizeof( float );
   memcpy( vertices, verts, ArraySize );

   if( vnorms )
   {
      normals = (float *)next_word_ptr;
      memcpy( normals, vnorms, ArraySize );
      next_word_ptr += 3 * num_verts;
   }

   num_bytes = ABS( next_word_ptr - SavePtr ) * 4;

   if ( load_disp )
   {
      *cur_disp_ptr = (double *) next_word_ptr;
   }
   else if ( load_fb )
   {
      *cur_app_fb_ptr = (double *) next_word_ptr;
   }
   else if ( load_both )
   {
      buffer_src = (unsigned char *)(*cur_disp_ptr);
      buffer_dst = (unsigned char *)next_user_word;
      memcpy( buffer_dst, buffer_src, num_bytes );

      *cur_disp_ptr = (double *) next_word_ptr;
      next_user_word += ( num_bytes / 4 );
      *cur_app_fb_ptr = (double *)next_user_word;
   }

   buffer_bytes += num_bytes;
   return(status);

} /* HSput_mesh_in_buffer */

/*
 * HSsave_TriMesh() saves the given 'TriMesh' into the current buffer.
 *
 * HISTORY: 02/20/90   Created.         Trevor Mink
 */


int HSsave_TriMesh( int                 w_no,
                    struct HStri_mesh   *TriMesh )
   
{
   int num_verts, num_facet_normals;
   float *verts, *vnorms, *fnorms;
#if defined ( OPENGL ) || defined( XGL )
   long rc;
   int ind, ii;
   IGRdouble v1[3], v2[3], v3[3];
   float temp[3];
   float *f_verts, *b_verts, *f_vnorms, *b_vnorms, *f_fnorms, *b_fnorms;
#endif

   num_verts = TriMesh->numVerts;
   verts = (float *)TriMesh->verts;
   vnorms = (float *)TriMesh->vNorms;
   fnorms = (float *)TriMesh->fNorms;
   num_facet_normals = TriMesh->numFacetNormals;


#if defined( OPENGL ) || defined (XGL)
   /* calculate a normal to the triangle mesh in */
   /* the same way that OpenGL will              */
   ind = -6;
   do
   {
      ind += 6;

      if ( ind >= (num_verts * 3) )
      {
         /* no unique points in triangle mesh */
         return( 0 );
      }
         
      v1[0] = (double) (verts[ind] - verts[ind+3]);
      v1[1] = (double) (verts[ind+1] - verts[ind+4]);
      v1[2] = (double) (verts[ind+2] - verts[ind+5]);

      v2[0] = (double) (verts[ind+6] - verts[ind+3]);
      v2[1] = (double) (verts[ind+7] - verts[ind+4]);
      v2[2] = (double) (verts[ind+8] - verts[ind+5]);

      BScrossp( &rc, v1, v2, v3 );
   }
   while ( (v3[0] == 0.0) && (v3[1] == 0.0) && (v3[2] == 0.0) );

   BSnorvec( &rc, v3 );

   v2[0] = fnorms[0];
   v2[1] = fnorms[1];
   v2[2] = fnorms[2];

   if ( BSdotp( &rc, v3, v2 ) > 0.0 )
   {
      /* need to reverse the direction of the triangular mesh   */
      /* beause the "calculated" mesh normal is not in the same */
      /* direction as the facet normal calculated by HSURF      */

      if ( !(num_verts % 2) )
      {
         /* even number of vertices => must put last triangle */
         /* in a separate mesh                                */
         f_vnorms = (vnorms) ? &vnorms[(num_verts - 3) * 3] : NULL;
         f_fnorms = (num_facet_normals > 1) ? &fnorms[(num_verts - 3) * 3] : fnorms;
         
         HSput_mesh_in_buffer( 3, 1,
                               &verts[(num_verts - 3) * 3], f_vnorms, f_fnorms );
         num_verts--;
         if ( num_facet_normals > 1 )
         {
            num_facet_normals--;
         }
      }

      /* reverse the remaining mesh */
      f_verts = verts;
      b_verts = &verts[(num_verts - 1) * 3];
      if ( vnorms )
      {
         f_vnorms = vnorms;
         b_vnorms = &vnorms[(num_verts - 1) * 3];
      }

      for ( ii = 0;
            ii < num_verts / 2;
            ii++, f_verts += 3, b_verts -= 3, f_vnorms += 3, b_vnorms -= 3 )
      {
         temp[0] = f_verts[0]; temp[1] = f_verts[1]; temp[2] = f_verts[2];
         f_verts[0] = b_verts[0]; f_verts[1] = b_verts[1]; f_verts[2] = b_verts[2];
         b_verts[0] = temp[0]; b_verts[1] = temp[1]; b_verts[2] = temp[2];

         if ( vnorms )
         {
            temp[0] = f_vnorms[0]; temp[1] = f_vnorms[1]; temp[2] = f_vnorms[2];
            f_vnorms[0] = b_vnorms[0]; f_vnorms[1] = b_vnorms[1]; f_vnorms[2] = b_vnorms[2];
            b_vnorms[0] = temp[0]; b_vnorms[1] = temp[1]; b_vnorms[2] = temp[2];
         }

      }

      if ( num_facet_normals > 1 )
      {
         f_fnorms = fnorms;
         b_fnorms = &fnorms[(num_verts - 3) * 3];

         for ( ii = 0;
               ii < (num_verts - 2) / 2;
               ii++, f_fnorms += 3, b_fnorms -= 3 )
         {
            temp[0] = f_fnorms[0]; temp[1] = f_fnorms[1]; temp[2] = f_fnorms[2];
            f_fnorms[0] = b_fnorms[0]; f_fnorms[1] = b_fnorms[1]; f_fnorms[2] = b_fnorms[2];
            b_fnorms[0] = temp[0]; b_fnorms[1] = temp[1]; b_fnorms[2] = temp[2];
         }
      }

      return( HSput_mesh_in_buffer( num_verts, num_facet_normals, verts, vnorms, fnorms ) );

   }
   else
#endif
   {
      /* don't need to reverse mesh */
      return( HSput_mesh_in_buffer( num_verts, num_facet_normals,
                                    verts, vnorms, fnorms ) );
   }


} /* HSsave_TriMesh */


/*
 * HSsave_trimesh_polyline() saves away a polyline into the display and/or
 * user buffer.
 * HISTORY: 04/03/91   Created.
 *                        S.P. Rogers
 */

void HSsave_trimesh_polyline( IGRint    num_points,
                              IGRpoint  *points )

   {
   IGRint         status;
   IGRint         i;
   IGRint         PolyLineSize;
   unsigned char  *buffer_src;
   unsigned char  *buffer_dst;
   float          *next_float_ptr;

   if( tiling_parms.processing_mode & HS_PMODE_FEEDBACK_FULL )
   {
      return;
   }

   /* for num_verts */
   PolyLineSize = num_points * 3 * sizeof( float ) + sizeof( int );

   if( PolyLineSize + LINK_SIZE > HSMAX_FRAME_SIZE )
   {

#if TRIMESH_DEBUG
      fprintf( stderr, "PolyLineSize = %d is too big for buffer: disposing\n",
               PolyLineSize );
#endif

      return;
   }

   /* see if polyline will fit in buffer */
   if( ( buffer_bytes + PolyLineSize + LINK_SIZE ) > fb_buffer_size )
   {

      /*
       *  Added this check, because, for some reason, on SGI workstations
       *  for the given testcase, this was coming up NULL and causing an
       *  abort.  Don't know why, but return'ing cures the abort and the
       *  the display looks good.  Mike (11/12/97)
       */

      if( next_word_ptr == NULL ) return;

      *next_word_ptr = HSFRAMELINK;
      if ( load_disp || load_both )
      {
         if ( ! ( status = HSget_next_block() ) )
         {
            *last_surface = HSFRAMELINK;

#if FACET_DEBUG
            fprintf( stderr, "Ran out of room (last_surface = %x)\n",
                     last_surface );
#endif

            return;
         }
         else
         {
            fb_buffer_size = status - 16;

#if FACET_DEBUG
            fprintf( stderr, "status = %d\tfb_buffer_size = %d\n",
                     status, fb_buffer_size );
#endif

            next_word_ptr = (IGRint *) *cur_disp_ptr;
            total_bytes += buffer_bytes;
            buffer_bytes = 0;
         }
      }
      else
      {
         HSset_status( HSSTAT_VIEW_DYN_LIMIT );
         HSset_feedback_full_mode( TRUE );
         return;
      }
   }

   *next_word_ptr++ = num_points;

   next_float_ptr = (float *) next_word_ptr;
   for ( i = 0; i < num_points; i++ )
   {
       next_float_ptr[0] = points[i][0];
       next_float_ptr[1] = points[i][1];
       next_float_ptr[2] = points[i][2];
       next_float_ptr += 3;
   }

   next_word_ptr += ( num_points * 3 * sizeof( float )) / sizeof( int );

   if ( load_disp )
   {
      *cur_disp_ptr = (double *) next_word_ptr;
   }
   else if ( load_fb )
   {
      *cur_app_fb_ptr = (double *) next_word_ptr;
   }
   else if ( load_both )
   {
      buffer_src = (unsigned char *)(*cur_disp_ptr);
      buffer_dst = (unsigned char *)next_user_word;
      memcpy( buffer_dst, buffer_src, PolyLineSize );

#if FEEDBACK_DEBUG
      printf( "buffer_src = %x copied to buffer_dst = %x for %d bytes\n",
               buffer_src, buffer_dst, PolyLineSize);
#endif
      *cur_disp_ptr = (double *) next_word_ptr;
      next_user_word += ( PolyLineSize / 4 );
      *cur_app_fb_ptr = (double *)next_user_word;
   }

   buffer_bytes += PolyLineSize;

}  /* HSsave_edgeII_polyline */


/*----------------------------------------------------------------------------*/

/*
 * ABSTRACT:   HSsave_facet stuffs the given facet data into a facet buffer
 *             and links the buffer into the feedback list.
 *
 * HISTORY:   03/29/88   Created.      C. M. Jablonski
 *
 */

void HSsave_facet( struct HSloop *facet )
   
{
   unsigned int              num_polys;
   unsigned int              num_verts;
   unsigned int              vert_count;
   register struct HSloop    *poly;
   register struct HSvertex  *vertex;
   struct HSvertex           *last_vertex;
   IGRint                    *vertices_per_poly;
   IGRint                    facet_size;
   IGRint                    *start_ptr;
   IGRint                    num_bytes;
   IGRdouble                 *vertices = (IGRdouble *)NULL;
   IGRdouble                 *normals = (IGRdouble *)NULL;
   IGRdouble                 *facet_normal_ptr = (IGRdouble *)NULL;
   unsigned char             *buffer_src;
   unsigned char             *buffer_dst;
   IGRint                    status;

   if( tiling_parms.processing_mode & HS_PMODE_FEEDBACK_FULL )
   {
      return;
   }

   if( element_parms.facet_type == AREA_FILL )
   {
         *hdr_word_ptr &= ~DB_FLAG_MASK;
   }

#if DISPLAY_DEBUG
   fprintf(stderr,"Enter HSsave_facet:next_word_ptr=%x\n",next_word_ptr);
#endif

   /* Count the number of polygons and vertices. */
   num_polys = num_verts = 0;

   for ( poly = facet; poly != NIL_LOOP; poly = poly->next )
   {
      last_vertex = vertex = poly->loop;
      if ( last_vertex )
      {
         do
         {
            num_verts++;
            vertex = vertex->next;
         } while (vertex != last_vertex);

         num_polys++;
      }
   }

   /* See if enough space is available in the buffer before writing */
   if ( element_parms.facet_type == SMOOTH_SHADE )
   {
      facet_size = (4 + 6*num_verts + ( num_polys/2 + num_polys%2 )) *
                   sizeof (IGRdouble) + 4;
   }
   else
   {
   /* The first constant '4' represents 3 doubles for facet normal and 2 ints
    * for num_poly/num_vert. The second constant '4' is 4 bytes to account for
    * double alignment
    */
      facet_size = (4 + 3*num_verts + ( num_polys/2 + num_polys%2 )) *
                    sizeof (IGRdouble) + 4;
   }

#if DISPLAY_DEBUG
   fprintf( stderr, "facet_size = %d\tnum_polys = %d\tnum_verts = %d\n",
            facet_size, num_polys, num_verts );
#endif
   if( facet_size + LINK_SIZE > HSMAX_FRAME_SIZE )
   {
      return;
   }

   if( ( buffer_bytes + facet_size + LINK_SIZE) > fb_buffer_size )
   {
      *next_word_ptr = HSFRAMELINK;
      if ( load_disp || load_both )
      {
         if ( ! ( status = HSget_next_block() ) )
         {
            *last_surface = HSFRAMELINK;
#if DISPLAY_DEBUG
            fprintf( stderr, "Ran out of room (last_surface = %x)\n",
                     last_surface );
#endif
            return;
         }
         else
         {
            fb_buffer_size = status - 16;
#if TEMP_DEBUG
            fprintf( stderr, "status = %d\tfb_buffer_size = %d\n",
                     status, fb_buffer_size );
#endif
            next_word_ptr = (IGRint *) *cur_disp_ptr;
            total_bytes += buffer_bytes;
            buffer_bytes = 0;
         }
      }
      else
      {
         HSset_status( HSSTAT_VIEW_DYN_LIMIT );
         HSset_feedback_full_mode( TRUE );
         return;
      }
   }

   if( ( total_bytes + facet_size > APP_FEEDBACK_SIZE ) && load_both )
   {
      load_both = FALSE;
      load_disp = TRUE;
   }

   /* save the next_word_ptr for computing the total number of words */
   /* written later                                                  */
   start_ptr = next_word_ptr;

   /* write the next_facet_present flag and num_polygons */
   *( next_word_ptr++ ) = num_polys;
   *( next_word_ptr++ ) = num_verts;

   vertices_per_poly = next_word_ptr;
   next_word_ptr = vertices_per_poly + num_polys;
   HSALIGN_DOUBLE( next_word_ptr );

   facet_normal_ptr = (IGRdouble *)next_word_ptr;

   /* 3 doubles to store facet normal */
   vertices = facet_normal_ptr + 3;

   if ( element_parms.facet_type == SMOOTH_SHADE )
   {
      normals = vertices + 3 * num_verts;  /* 3 doubles per vertex */
   }

   /* write the facet normal */
   memcpy( facet_normal_ptr,
           element_parms.facet_normal,
           3 * sizeof( IGRdouble ) );

#if DISPLAY_DEBUG
   fprintf( stderr, "vertices = %x\tnormals = %x\tfacet_normal_ptr = %x\n",
            vertices, normals, facet_normal_ptr );
#endif

   if ( num_polys )
   {
      for ( poly = facet; poly != NIL_LOOP; poly = poly->next )
      {
         vert_count = 0;
         last_vertex = vertex = poly->loop;
         if ( last_vertex )
         {
            do
            {
               memcpy( vertices, vertex->coord, 3 * sizeof( IGRdouble ) );
               vertices += 3;

               if ( element_parms.facet_type == SMOOTH_SHADE )
               {
                  memcpy( normals, vertex->norm, 3*sizeof(IGRdouble) );
                  normals += 3;
               }

               vert_count++;
               vertex = vertex->next;
            } while( vertex != last_vertex );
         }

         *(vertices_per_poly++) = vert_count;
      }
   }

   /* update next_word_ptr */
   if ( element_parms.facet_type == SMOOTH_SHADE )
   {
      next_word_ptr = (IGRint *) normals;
   }
   else
   {
      next_word_ptr = (IGRint *) vertices;
   }

   num_bytes = ABS( next_word_ptr - start_ptr ) * 4;

   if ( load_disp )
   {
      *cur_disp_ptr = (IGRdouble *) next_word_ptr;
   }
   else if ( load_fb )
   {
      *cur_app_fb_ptr = (IGRdouble *) next_word_ptr;
   }
   else if ( load_both )
   {
      buffer_src = (unsigned char *)(*cur_disp_ptr);
      buffer_dst = (unsigned char *)next_user_word;
      memcpy( buffer_dst, buffer_src, num_bytes );

#if FEEDBACK_DEBUG
      printf( "buffer_src = %x copied to buffer_dst = %x for %d bytes\n",
              buffer_src, buffer_dst, num_bytes);
#endif
      *cur_disp_ptr = (IGRdouble *) next_word_ptr;
      next_user_word += ( num_bytes / 4 );
      *cur_app_fb_ptr = (IGRdouble *)next_user_word;
   }

   buffer_bytes += num_bytes;

#if DISPLAY_DEBUG
   fprintf(stderr,"After writing facet of %d bytes, next_word_ptr is now %x\n",
           num_bytes, next_word_ptr );
   fprintf(stderr,"Exit save_facet:buffer_bytes=%d\n", buffer_bytes);
#endif

} /* HSsave_facet */

#if defined( ENV5 )

void HSdisplay_fb_EDGEII( IGRint                  *fb_buffer_ptr,
                          IGRint                  pipe_no,
                          IGRdouble               wld_to_view[4][4],
                          IGRdouble               vw_vol[6],
                          IGRdouble               rotate_matrix[4][4],
                          IGRdouble               transform_matrix[4][4],
                          struct HS_light_source  global_lights[],
                          struct HS_light_source  *ambient_light,
                          IGRdouble               *eye_point,
                          IGRdouble               vrp[3],
                          IGRdouble               vpn[3],
                          IGRdouble               vup[3] )

/*
 * HSdisplay_fb_EDGEII() prepares for the display of the view dynamics with the given matrices.
 * It is called for machines with an EDGEII board or when EDGE2_EMULATION is turned on.
 *
 * NOTE: Parameters to this function are not fixed as of 03/15/90.
 *                        Trevor Mink
 *
 * HISTORY: 03/02/90   Created.
 *                        Trevor Mink
 */

{

   register int        *cur_ptr;
   int                 num_verts;
   int                 NumFacetNormals;
   int                 options;
   float               *float_ptr;
   float               *RGB;
   double              *points;
   EGTriMeshData3Info  TriMesh;
   EGPolyLine3Info     polyLine;

   IGRint              status;

   int                 finish;
   float               spec_reflectance;
   float               diff_reflectance;
   float               transparency;
   EGRGBColor          EGcolor;
   EGObjectProp        prop;

#if TRIMESH_DEBUG
   IGRint              *mesh_start;
   IGRint              count = 0;
#endif

#if CULLING_DEBUG
   int                 loopvar;
   EGVect3             *TempFacetNorms;
#endif

#if EDGEII_DEBUG
   cur_ptr = fb_buffer_ptr;
   HSdump_edgeII_fb_buffer( cur_ptr );
#endif

   tiling_parms.processing_mode &= ~HS_PMODE_FEEDBACK_FULL;

   HSactivate_window( pipe_no );   /* ignore returned status */

   WLset_drawing_mode( active_window->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );

   /* if necessary, convert to use edge2 */
   if ((active_window->type & HShardware_ZB_24) &&
       (!(active_window->type & HShardware_LB_EG) ))
   {
      HSinitialize_active_window_functions();
   }

   /* update the EG window parameters */
   HSsetup_EG_window( wld_to_view,
                      vw_vol,
                      eye_point,
                      vrp,
                      vpn,
                      vup,
                      active_window->x_dits,
                      active_window->y_dits,
                      TRUE );

   /* update the lights */
   HSsetup_window_lights( global_lights, ambient_light );

   /* erase the window */
   WLclear_window( active_window->win_no );
 
   /*
    * Read and display the feedback buffer.
    */
   cur_ptr = fb_buffer_ptr;

   while( cur_ptr && ( (*cur_ptr) & NEXT_SURFACE_MASK ||
                        *cur_ptr == HSFRAMELINK ))
   {

      if ( *cur_ptr == HSFRAMELINK )
      {
         cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);

#if FLINK_DEBUG
         fprintf( stderr, "Frame link found, new chunk at addr: %x\n",
                  cur_ptr );
#endif

         if ( cur_ptr )
         {
            cur_ptr += 2;
            fb_buffer_ptr = cur_ptr;

#if FLINK_DEBUG
            fprintf( stderr, "new chunk found, cur_ptr = %x\t", cur_ptr );
            fprintf( stderr, "next_word_ptr = %x\n", next_word_ptr );
#endif

         }
         else
         {
            /* if no other buffer blocks, exit loop */
            break;
         }
      }

      options = (*(cur_ptr++)) & (~NEXT_SURFACE_MASK);
      RGB = float_ptr = (float *)cur_ptr;
      EGcolor.red = *(float_ptr++);
      EGcolor.green = *(float_ptr++);
      EGcolor.blue = *(float_ptr++);

      /* set the base color */
      status = EGSetBaseColor( active_window->EG_vc_no, &EGcolor );

      cur_ptr = (int *)float_ptr;

      finish = *(cur_ptr++);
      float_ptr = (float *)cur_ptr;

      spec_reflectance = *(float_ptr++);
      diff_reflectance = *(float_ptr++);
      transparency = *(float_ptr++);
      cur_ptr = (int *)float_ptr;
      
      prop.ambRefl = 1.0;
      prop.diffRefl = diff_reflectance;
      prop.specRefl = spec_reflectance;
      prop.specColor.red = 1.0;
      prop.specColor.green = 1.0;
      prop.specColor.blue = 1.0;
      prop.specExp = (finish > 32.0) ? (32.0) : ((float)finish);
      prop.transCoeff = (transparency >= 0.5) ? 0.5 : 0.0;

      /* Set Finish, Reflectance, and Transparency */
      status = EGSetObjectProp( active_window->EG_vc_no, &prop );

#if DEBUG_EDGEII
      fprintf(stderr, "refl = %f, finish = %d, trans = %f\n",
              reflectance, finish, transparency);
      fprintf(stderr, "EGSetObjectProp status = %d\n", status);
      fprintf(stderr, "   ambRefl = %f, diffRefl = %f, specRefl = %f\n",
              prop.ambRefl, prop.diffRefl, prop.specRefl);
      fprintf(stderr, "   specColor = %f, %f, %f\n",
              prop.specColor.red, prop.specColor.green, prop.specColor.blue);
      fprintf(stderr, "   specExp = %f, transCoeff = %f\n",
              prop.specExp, prop.transCoeff);
#endif
      
      HSset_element_weights( *(cur_ptr++), NULL );

#if CULLING_DEBUG
      fprintf( stderr, "Cull flag is %d\n", *cur_ptr );
#endif

      switch( *(cur_ptr++) )
      {
         case HS_CULL_NONE:
            status = EGSetFaceCullingMode(active_window->EG_vc_no,
                                           EG_NO_CULL);
            break;

         case HS_CULL_POSITIVE:
            status = EGSetFaceCullingMode(active_window->EG_vc_no,
                                           EG_FRONTFACE_CULL);
            break;
         case HS_CULL_NEGATIVE:
            status = EGSetFaceCullingMode(active_window->EG_vc_no,
                                          EG_BACKFACE_CULL);
            break;
      }

#if SURFACE_DEBUG
      fprintf( stderr, "options = %x\tweight = %d\tcull_flag = %d\t",
               options, element_parms.visible_weight,
               element_parms.culling_back_planes );
      fprintf( stderr, "at address: %x\n", cur_ptr );
#endif

      /* initialize the color */
/*
      (*active_window->init_paint[active_window->active_zbuffer])( &color,
                                                                   &options );
*/

#if DEBUG_EDGEII
      status = EGInqLightingMode( active_window->EG_vc_no, &mode );
      fprintf(stderr, "LIGHTING MODE = %d  (%d)\n", mode, status);

      status = EGInqReflectEqn( active_window->EG_vc_no, &reflEqn );
      fprintf(stderr, "LIGHTING EQUATION TYPE = %d  (%d)\n", reflEqn, status);

      status = EGInqRenderMethod( active_window->EG_vc_no, &renderMethod );
      fprintf(stderr, "RENDER METHOD = %d  (%d)\n", renderMethod, status);

      status = EGInqZBufferMode( active_window->EG_vc_no, &mode );
      fprintf(stderr, "Z BUFFER MODE = %d  (%d)\n", mode, status);

      status = EGInqNormReorientMode( active_window->EG_vc_no, &mode );
      fprintf(stderr, "NORMAL REORIENT MODE = %d  (%d)\n", mode, status);

      status = EGInqFaceCullingMode( active_window->EG_vc_no, &cullMode );
      fprintf(stderr, "FACE CULLING MODE = %d  (%d)\tEG_vc_no = %d\n",
              cullMode, status, active_window->EG_vc_no );

      status = EGInqBaseColor( active_window->EG_vc_no, &EGcolor );
      fprintf(stderr, "BASE COLOR = %f, %f, %f  (%d)\n",
              EGcolor.red, EGcolor.green, EGcolor.blue, status);

      status = EGInqObjectProp( active_window->EG_vc_no, &prop );
      fprintf(stderr, "OBJECT_PROPERTIES:  ar=%f, dr=%f, sr=%f\n",
              prop.ambRefl, prop.diffRefl, prop.specRefl );
      fprintf(stderr, "                    spec_color= %f %f %f\n",
              prop.specColor.red, prop.specColor.green, prop.specColor.blue,
      fprintf(stderr, "                    se=%f tc=%f  (%d)\n",
              prop.specExp, prop.transCoeff,status);
#endif

      if ( options == HS_BST_POINT )
      {

         num_verts = *(cur_ptr++);
         HSALIGN_DOUBLE( cur_ptr );
         points = (IGRdouble *) cur_ptr;

         HSpoint_tiler( active_window->pipe_no,
                        num_verts,
                        points,
                        (int) RGB,
                        options,
                        NULL,
                        active_window->dit_clip_range,
                        TRUE );

         cur_ptr += 6 * num_verts;
      }
      else
      {
         while ( (*cur_ptr) && ! ( (*cur_ptr) & NEXT_SURFACE_MASK ) )
         {
            if ( *cur_ptr == HSFRAMELINK )
            {
               cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);
               if ( cur_ptr )
               {
                  cur_ptr += 2;
                  fb_buffer_ptr = cur_ptr;
                  continue;
               }
               else
               {
                  /* if no other buffer blocks, exit loop */
                  break;
               }
            }

            if( ( options & (HS_BST_POLYLINE | HS_BST_POLYLINE_DELETE) ) )
            {
               /* Pull out POLYLINE data as stored */
               polyLine.numVerts = *(cur_ptr++);
               polyLine.verts = (EGPoint3 *)cur_ptr;
               cur_ptr += ( 3 * polyLine.numVerts );

               polyLine.vertOffset = sizeof( EGPoint3 );
               polyLine.closed = EG_OFF;

               /* 'PolyLineVerts' points to an array of 'num_verts' vertices */
               status = EGPolyLine3( active_window->EG_vc_no, &polyLine );

#if FACET_DEBUG
               if( status )
               {
                  fprintf( stderr, "Error in EGPolyLine3; Status = %d\n",
                           status );
               }
#endif

            }
            else
            {
               TriMesh.vColors = (EGRGBColor *)NULL;
               TriMesh.fColors = (EGRGBColor *)NULL;

               while( *cur_ptr &&
                      !( *cur_ptr & NEXT_SURFACE_MASK ) &&
                      *cur_ptr != HSFRAMELINK )
               {

#if TRIMESH_DEBUG
                  mesh_start = cur_ptr;
#endif

                  TriMesh.numVerts = *(cur_ptr++);
                  NumFacetNormals = *(cur_ptr++);

                  TriMesh.fNorms = (EGVect3 *)cur_ptr;
                  TriMesh.fNormOffset = ( (NumFacetNormals == 1 ) ?
                        0 : sizeof( EGVect3 ) );

                  cur_ptr += 3 * NumFacetNormals;

                  TriMesh.verts = (EGPoint3 *)cur_ptr;
                  TriMesh.vertOffset = sizeof( EGPoint3 );
                  cur_ptr += 3 * TriMesh.numVerts;
                  if ( options & GR_BST_SMOOTH )
                  {
                     TriMesh.vNorms = (EGVect3 *) cur_ptr;
                     TriMesh.vNormOffset = sizeof( EGVect3 );
                     cur_ptr += 3 * TriMesh.numVerts;

#if TRIMESH_DEBUG
                     if( ++count > 926 && count < 929 )
                     {
                        fprintf( stderr, "Address = %x\t", mesh_start );
                        fprintf( stderr, "fb_buffer_ptr = %x\n",
                        fb_buffer_ptr );
                     }
                     status=EGTriMeshData_debug( active_window->EG_vc_no,
                                                &TriMesh );
#else    
                     status=EGTriMeshData3( active_window->EG_vc_no,
                                            &TriMesh );
#endif

                  }
                  else if( options & GR_BST_CONSTANT )
                  {
                     TriMesh.vNorms = (EGVect3 *)NULL;

#if TRIMESH_DEBUG
                     if( ++count > 926 && count < 929 )
                     {
                        fprintf( stderr, "Address = %x\t", mesh_start );
                        fprintf( stderr, "fb_buffer_ptr = %x\n",
                                 fb_buffer_ptr );
                     }

                     status=EGTriMeshData_debug( active_window->EG_vc_no,
                                                 &TriMesh );
#else
                     status=EGTriMeshData3( active_window->EG_vc_no,
                                            &TriMesh );
#endif

                  }
               }
            }
         } /* end of facet while loop */
      } /* else it is a surface */
   } /* end of surface while loop */
} /* HSdisplay_fb_EDGEII */

/*------------------------------------------------------------------------*/

/*
 * HSdisplay_fb_FPE() prepares for the display of the view dynamics frame in
 * the appropriate orientation. It is called for machines with a Floating
 * Point Engine (FPE).
 *
 * HISTORY: ??/??/??   Created.
 *                        Anon
 *          11/07/89   Altered to not read vertex normals for constant shading.
 *                        Trevor Mink
 */

int HSdisplay_fb_FPE( IGRint     *fb_buffer_ptr,
                      IGRint     pipe_no,
                      IGRint     vs_no,
                      IGRint     transp,
                      IGRint     win_no,
                      IGRint     x_lo,
                      IGRint     y_lo,
                      IGRint     x_hi,
                      IGRint     y_hi,
                      IGRdouble  transform_matrix[4][4],
                      IGRdouble  clip_range[6],
                      IGRdouble  fit_range[6],
                      IGRint     erase )
   
{
   register IGRint  *cur_ptr;
   IGRint           num_polygons;
   IGRint           num_verts;
   IGRint           options;
   IGRint           numPoints;
   IGRint           index;
   IGRint           i;
   IGRint           *vertices_per_polygon;
   IGRint           color;
   IGRint           vlt_index;
   IGRdouble        transformation_matrix[4][4];
   IGRdouble        *points;
   IGRdouble        *vertices;
   IGRdouble        *normals=NULL;
   IGRdouble        z_min;
   IGRdouble        z_max;
   IGRdouble        near_z=0;
   IGRdouble        far_z=0;
   IGRdouble        near_z_pct=0;
   IGRdouble        far_z_pct=0;
   IGRdouble        *range=NULL;
   struct WLrect    rect;
   
   HSset_feedback_full_mode( FALSE );

#if FEEDBACK_DEBUG
   fb_buffer_ptr = (IGRint *)( UserBuffer + 2 );
   fprintf( stderr, "Displaying from UserBuffer = %x\n", UserBuffer );
#endif

   cur_ptr = fb_buffer_ptr;
   HSactivate_window( pipe_no );   /* ignore returned status */

   HSset_dit_clip_range( clip_range );
   HSset_ele_clip_range( clip_range );

   if( active_window->depth_cue_on )
   {
      near_z_pct = active_window->depth_cue_base;
      far_z_pct = active_window->depth_cue_base +
                  active_window->depth_cue_delta *
                  (active_window->dit_clip_range[5] -
                  active_window->dit_clip_range[2]);

      near_z = 0;
      far_z = tiling_parms.maximum_z;

      GPSetDepthCueing( active_window->gpipe_id,
                        1,
                        near_z,
                        near_z_pct,
                        far_z,
                        far_z_pct );
   }

   if( erase ) 
   {
      WLenter_db( active_window->win_no );
      WLhide_cursor( active_window->win_no, TRUE );
      WLclear_window( active_window->win_no );
   } 
   else
   {
      WLhide_cursor( active_window->win_no, TRUE );
   }

   while( cur_ptr && 
          ((*cur_ptr) & NEXT_SURFACE_MASK || *cur_ptr == HSFRAMELINK ))
   {

      if ( *cur_ptr == HSFRAMELINK )
      {
         cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);
         if ( cur_ptr )
         {
            cur_ptr += 2;
            fb_buffer_ptr = cur_ptr;
         }
         else
         {
            /* if no other buffer blocks, exit loop */
            break;
         }
      }

      options = (*(cur_ptr++)) & (~NEXT_SURFACE_MASK);
      color = *(cur_ptr++);

      /* convert from logical color to vlt index */
      vlt_index = get_color_index( &color );

      HSset_element_weights( *(cur_ptr++), NULL );

      /* Skip culling flag since culling isn't supported by GPIPE */
      cur_ptr++;

      if ( options == HS_BST_POINT )
      {
         num_verts = *(cur_ptr++);
         HSALIGN_DOUBLE( cur_ptr );
         points = (IGRdouble *) cur_ptr;

         clip_range[0] = active_window->dit_clip_range[0];
         clip_range[1] = active_window->dit_clip_range[1];
         clip_range[3] = active_window->dit_clip_range[3];
         clip_range[4] = active_window->dit_clip_range[4];
         HSset_dit_clip_range( clip_range );
         HSconvert_transformation_matrix( transform_matrix,
                                          transformation_matrix );

         HSset_active_transformation( transformation_matrix );
         HScalc_window_z_range( fit_range, &z_min, &z_max );
         HSset_active_z_range( z_min, z_max );

         HSpoint_tiler( active_window->pipe_no,
                        num_verts,
                        points,
                        color,
                        options,
                        range,
                        active_window->dit_clip_range,
                        FALSE );

         cur_ptr += 6 * num_verts;
      }
      else
      {
         if ( options & GR_BST_TRANSP )
         {
            GPSetTransparency( active_window->gpipe_id, transp );
         }
         else
         {
            GPSetTransparency( active_window->gpipe_id, 0 );
         }

         while ( (*cur_ptr) && ! ( (*cur_ptr) & NEXT_SURFACE_MASK ) )
         {
            if ( *cur_ptr == HSFRAMELINK )
            {
               cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);
               if ( cur_ptr )
               {
                  cur_ptr += 2;
                  fb_buffer_ptr = cur_ptr;
                  continue;
               }
               else
               {
                  /* if no other buffer blocks, exit loop */
                  break;
               }
            }

            num_polygons = *(cur_ptr++);
            if ( num_polygons <= 0 || num_polygons > 10000 )
            {

#if DISPLAY_DEBUG
               fprintf(stderr, "ERROR: num_polygons = %d\n", num_polygons);
#endif

               break;
            }

            num_verts = *(cur_ptr++);
            vertices_per_polygon = cur_ptr;
            cur_ptr += num_polygons;

            HSALIGN_DOUBLE(cur_ptr);
            if( options & GR_BST_CONSTANT )
            {
               /* Get the facet normal */
               normals = (IGRdouble *)cur_ptr;
            }
            cur_ptr += 6;

            vertices = (IGRdouble *) cur_ptr;
            cur_ptr += 6 * num_verts;

            if ( options & GR_BST_SMOOTH )
            {
               normals = (IGRdouble *) cur_ptr;
               cur_ptr += 6 * num_verts;
               GPPolySmoothShd( active_window->gpipe_id,
                                vertices,
                                normals,
                                vertices_per_polygon,
                                num_polygons,
                                vlt_index,
                                0x0 );
            }
            else if ( options & GR_BST_CONSTANT )
            {
               GPPolyConstShd( active_window->gpipe_id,
                               vertices,
                               normals,
                               vertices_per_polygon,
                               num_polygons,
                               vlt_index,
                               0x0 );
            }
            else if ( options & HS_BST_POLYLINE ||
                      options & HS_BST_POLYLINE_DELETE )
            {

               WLset_active_symbology( win_no, vlt_index, 0, 0xFFFF, 0, WL_SYMB_CHANGE_COLOR );
               index = 0;
               for ( i = 0; i < num_polygons; i++)
               {
                  numPoints = vertices_per_polygon[i];
                  points = vertices + index;
                  GPLinestr3D( active_window->gpipe_id, points, numPoints, 0x0 );
                  index += 3 * numPoints;
               }
            }  /* end: polyline */
         } /* end of facet while loop */
      } /* else it is a surface */
   } /* end of surface while loop */

   GPFlushImageBuffer(active_window->gpipe_id);
   
   WLshow_cursor(win_no);
   WLflush(win_no);

   WLexit_db( active_window->win_no );

   if ( active_window->depth_cue_on )
   {
      GPSetDepthCueing( active_window->gpipe_id,
                        0,
                        near_z,
                        near_z_pct,
                        far_z,
                        far_z_pct );
   }

   return(0);
} /* HSdisplay_fb_FPE */
#endif

/*----------------------------------------------------------------------------*/

/*
 * HSdisplay_fb_NOFPE() prepares for the display of the view dynamics frame in
 * the appropriate orientation. It is called for machines with NO Floating
 * Point Engine (NOFPE).
 *
 * HISTORY: ??/??/??   Created.
 *                        Anon
 *          11/07/89   Altered to not read vertex normals for constant shading.
 *                        Trevor Mink
 *          01/05/90   Added ability to STOP between surfaces.
 *                        Trevor Mink
 *          12/13/91   Made work in perspective view dynamics for NAVAIR
 *                        Joel Underwood
 */

void HSdisplay_fb_NOFPE( IGRint                  *fb_buffer_ptr, 
                         IGRint                  pipe_no, 
                         IGRdouble               transform_matrix[4][4],
                         IGRdouble               rotate_matrix[4][4], 
                         IGRdouble               clip_range[6],
                         IGRint                  x_lo,
                         IGRint                  y_lo,
                         IGRint                  x_hi,
                         IGRint                  y_hi,
                         struct HS_light_source  global_lights[],
                         struct HS_light_source  *ambient_light, 
                         IGRdouble               *eye_point,
                         IGRdouble               fit_range[6], 
                         IGRdouble               sx, 
                         IGRdouble               sy, 
                         IGRdouble               sz, 
                         IGRboolean              *perspective, 
                         IGRint                  erase )

{
   register IGRint  *cur_ptr;
   IGRint           i;
   IGRint           j;
   IGRint           *vertices_per_polygon;
   IGRint           color;
   IGRint           options;
   IGRint           num_polygons;
   IGRint           num_verts;
   IGRdouble        transformation_matrix[4][4];
   IGRdouble        rotation_matrix[4][4];
   IGRdouble        px;
   IGRdouble        py;
   IGRdouble        pz;
   IGRdouble        nx;
   IGRdouble        ny;
   IGRdouble        nz;
   IGRdouble        w;
   IGRdouble        *points;
   IGRdouble        *vectors=NULL;
   IGRdouble        *facet_normal;
   IGRdouble        z_min;
   IGRdouble        z_max;
   IGRboolean       edge_mark;
   IGRdouble        *range=NULL;
   IGRboolean       GridValue;

#if DISPLAY_DEBUG
   int              xx;

   fprintf( stderr, "within HSdisplay_fb_NOFPE\n" );
#endif

   /* Save whether grid is on or off */
   GridValue = active_window->grid_on;

   /* Turn off grid for displaying view dynamics */
   active_window->grid_on = 0;

   HSactivate_window( pipe_no );   /* ignore returned status */

   if (*perspective)
   {
      HSset_active_perspective_scales(sx,sy,sz);
   }

   HSset_feedback_full_mode( FALSE );   

   active_window->process_facet = process_facet;

   w = 1.0;
   edge_mark = FALSE;

   /*
    * Set the dit_clip_range
    */
   HSset_ele_clip_range( clip_range );

   clip_range[0] = active_window->dit_clip_range[0];
   clip_range[1] = active_window->dit_clip_range[1];
   clip_range[3] = active_window->dit_clip_range[3];
   clip_range[4] = active_window->dit_clip_range[4];

   HSset_dit_clip_range( clip_range );

   /*
    * find the fit range and set zmax & zmin
    */

   HSconvert_transformation_matrix( transform_matrix, transformation_matrix );
   HSset_active_transformation( transformation_matrix );

   HScalc_window_z_range( fit_range, &z_min, &z_max );
   HSset_active_z_range( z_min, z_max );

   HSsetup_window_lights( global_lights, ambient_light );

   /* reset the perspective flag for the active pipe */
   active_window->perspective = *perspective;

   /* Initialize the z and color buffers. */
   WLhide_cursor( active_window->win_no, TRUE );

   if ( erase )
   {
      if ( !(active_window->type & HShardware_ZB_MASK) )
      {
         HSinitialize_buffers();
         HSrepaint();
      }
      else 
      {
         WLclear_window( active_window->win_no );
      }
   } 

   /* adjust the rotation matrix */
   HSconvert_rotation_matrix( rotate_matrix, rotation_matrix );

#if FEEDBACK_DEBUG
   HSdump_fb_buffer( fb_buffer_ptr );
   fb_buffer_ptr = (IGRint *) ( UserBuffer + 2 );
   fprintf( stderr, "Displaying from UserBuffer = %x\n", UserBuffer );
   HSdump_fb_buffer( fb_buffer_ptr );
#endif

   cur_ptr = fb_buffer_ptr;

   /* process each surface */
   while( cur_ptr && ( (*cur_ptr) & NEXT_SURFACE_MASK ||
                        *cur_ptr == HSFRAMELINK ))
   {
      if ( *cur_ptr == HSFRAMELINK )
      {

#if DISPLAY_DEBUG
         fprintf( stderr, "A framelink was found at addr %x ", cur_ptr );
#endif

         cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);

#if DISPLAY_DEBUG
         fprintf( stderr, "that points to addr %x\n", cur_ptr );
#endif

         if ( cur_ptr )
         {
            cur_ptr += 2;
            fb_buffer_ptr = cur_ptr;
         }
         else
         {
            /* if there are no other buffer blocks, exit loop */
            break;
         }
      }

#if DISPLAY_DEBUG
      fprintf( stderr, "Surface being read from address %x\n", cur_ptr );
#endif

      options = (*(cur_ptr++)) & (~NEXT_SURFACE_MASK);
      color = *(cur_ptr++);
      HSset_element_weights( *(cur_ptr++), NULL );
      HSset_element_cull_flag( *(cur_ptr++) );

#if CULLING_DEBUG
      fprintf( stderr, "options = %x\tcolor = %d\tweight = %d\t",
               options, color, element_parms.visible_weight );
      fprintf( stderr. "culling_back_planes = %d\n",
               element_parms.culling_back_planes);
#endif

      if ( options == HS_BST_POINT )
      {
         num_verts = *(cur_ptr++);
         HSALIGN_DOUBLE( cur_ptr );
         points = (IGRdouble *) cur_ptr;
         HSpoint_tiler( pipe_no,
                        num_verts,
                        points,
                        color,
                        options,
                        range,
                        active_window->dit_clip_range,
                        FALSE );
         cur_ptr += 6 * num_verts;
      }
      else
      {
         /* Set the tiler parameters for this surface. */
         if ( (options == HS_BST_POLYLINE) ||
              (options == HS_BST_POLYLINE_DELETE) )
         {
            HSset_element_facet_type( POLYLINE );
            (*active_window->init_paint[active_window->active_zbuffer])
                       ( &color, &options );
         }
         else
         {
            HSset_surf_parms ( color, options );
         }

         /* Process each facet on this surface. */
         while ( (*cur_ptr) && ! ( (*cur_ptr) & NEXT_SURFACE_MASK) )
         {
            if ( *cur_ptr == HSFRAMELINK )
            {
               cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);
               if ( cur_ptr )
               {
                  cur_ptr += 2;
                  fb_buffer_ptr = cur_ptr;
                  continue;
               }
               else
               {
                  /* if no other buffer blocks, exit loop */
                  break;
               }
            }

#if DISPLAY_DEBUG
            fprintf( stderr, "Facet is being printed from %x\n", cur_ptr );
#endif

            num_polygons = *(cur_ptr++);
            if ( num_polygons <= 0 || num_polygons > 10000 )
            {

#if DISPLAY_DEBUG
               fprintf(stderr, "ERROR: num_polygons = %d\n", num_polygons);
#endif

               break;
            }

            num_verts = *(cur_ptr++);
            vertices_per_polygon = cur_ptr;
            cur_ptr += num_polygons;
            HSALIGN_DOUBLE(cur_ptr);

#if DISPLAY_DEBUG
            fprintf( stderr, "num_verts = %d\tvertices_per_polygon:\n",
                     num_verts );
            for ( xx = 0; xx < num_polygons; xx++ )
            {
               fprintf( stderr, "poly # %d has %d vertices\n",
                        xx, (IGRint)( vertices_per_polygon[xx] ) );
            }
            fprintf( stderr, "\n" );
#endif

            facet_normal = (IGRdouble *) cur_ptr;
            cur_ptr += 6;

#if DISPLAY_DEBUG
            fprintf( stderr, "facet_normal is at: %x\n", facet_normal );
#endif

            points = (IGRdouble *) cur_ptr;
            cur_ptr += 6 * num_verts;

#if DISPLAY_DEBUG
            fprintf( stderr, "points is at = %x\n", points );
#endif

            if ( element_parms.facet_type == SMOOTH_SHADE )
            {
               vectors = (IGRdouble *) cur_ptr;
               cur_ptr += 6 * num_verts;

#if DISPLAY_DEBUG
               fprintf( stderr, "vectors = %x\tfb_buffer_ptr = %x\n",
                  vectors, fb_buffer_ptr );
#endif

            }

            if ( active_window->perspective )
            {
            /* You divide the facet normal by the perspective scale because  */
            /* you divide a vector to scale (skew) and multiply a point.     */
            /* This will go into unscaled facet normal.  For view dynamics   */
            /* the point is in world coordinates instead of transformed in a */
            /*  normal update                                                */

               HSset_facet_normal(((rotation_matrix[0][0] * facet_normal[0]) +
                                (rotation_matrix[0][1] * facet_normal[1]) +
                                (rotation_matrix[0][2] * facet_normal[2]))/sx,
                                ((rotation_matrix[1][0] * facet_normal[0]) +
                                (rotation_matrix[1][1] * facet_normal[1]) +
                                (rotation_matrix[1][2] * facet_normal[2]))/sy,
                                ((rotation_matrix[2][0] * facet_normal[0]) +
                                (rotation_matrix[2][1] * facet_normal[1]) +
                                (rotation_matrix[2][2] * facet_normal[2]))/sz );
            }
            else
            {
               HSset_facet_normal(((rotation_matrix[0][0] * facet_normal[0]) +
                                (rotation_matrix[0][1] * facet_normal[1]) +
                                (rotation_matrix[0][2] * facet_normal[2])),
                                ((rotation_matrix[1][0] * facet_normal[0]) +
                                (rotation_matrix[1][1] * facet_normal[1]) +
                                (rotation_matrix[1][2] * facet_normal[2])),
                                ((rotation_matrix[2][0] * facet_normal[0]) +
                                (rotation_matrix[2][1] * facet_normal[1]) +
                                (rotation_matrix[2][2] * facet_normal[2])) );
            }

#if DISPLAY_DEBUG
            fprintf( stderr, "\nfacet_normal = %lf\t%lf\t%lf\n",
                     facet_normal[0], facet_normal[1], facet_normal[2] );
#endif

            if ( active_window->perspective )
            {
               HSsave_and_scale_facet_normal();
            }

            /* Construct the facet. */
            for ( i=0; i<num_polygons; i++ )
            {
               for ( j=0; j<vertices_per_polygon[i]; j++)
               {
                   /* Transform point into viewing coordinates.*/
                   px = (transformation_matrix[0][0] * points[0]) +
                        (transformation_matrix[0][1] * points[1]) +
                        (transformation_matrix[0][2] * points[2]) +
                        (transformation_matrix[0][3]);
                   py = (transformation_matrix[1][0] * points[0]) +
                        (transformation_matrix[1][1] * points[1]) +
                        (transformation_matrix[1][2] * points[2]) +
                        (transformation_matrix[1][3]);
                   pz = (transformation_matrix[2][0] * points[0]) +
                        (transformation_matrix[2][1] * points[1]) +
                        (transformation_matrix[2][2] * points[2]) +
                        (transformation_matrix[2][3]);

                  if ( active_window->perspective )
                  {
                     w = (transformation_matrix[3][0] * points[0]) +
                         (transformation_matrix[3][1] * points[1]) +
                         (transformation_matrix[3][2] * points[2]) +
                         (transformation_matrix[3][3]);
                  }
                  /* Rotate normal and add this point to the current loop. */
                  if( options & GR_BST_SMOOTH )
                  {
                     nx = (rotation_matrix[0][0] * vectors[0]) +
                          (rotation_matrix[0][1] * vectors[1]) +
                          (rotation_matrix[0][2] * vectors[2]);
                     ny = (rotation_matrix[1][0] * vectors[0]) +
                          (rotation_matrix[1][1] * vectors[1]) +
                          (rotation_matrix[1][2] * vectors[2]);
                     nz = (rotation_matrix[2][0] * vectors[0]) +
                          (rotation_matrix[2][1] * vectors[1]) +
                          (rotation_matrix[2][2] * vectors[2]);

                     add_vertex_to_loop( px, py, pz, w, edge_mark, nx, ny,
                                         nz, 0.0, 0.0 );
                     if ( tiling_parms.status == HSSTAT_ALLOC_ERROR )
                     {
                         break;
                     }
                     vectors += 3;
                  }
                  else
                  {
                     add_vertex_to_loop ( px, py, pz, w, edge_mark, 0.0,
                                          0.0, 0.0, 0.0, 0.0 );
                     if ( tiling_parms.status == HSSTAT_ALLOC_ERROR )
                     {
                        break;
                     }
                  }
                  points += 3;

               }  /* end: for j */
#if SURF_ALLOC_CHECKS
               if ( tiling_parms.status != HSSTAT_ALLOC_ERROR )
#endif
                  end_facet_loop();

               /* Don't make this the else clause of the previous statement */
               /* because the 'status' could get set from the call to       */
               /* end_facet_loop()                                          */

#if SURF_ALLOC_CHECKS
               if ( tiling_parms.status == HSSTAT_ALLOC_ERROR )
               {
                  toss_current_facet();
                  break; /* toss the entire facet */
               }
#endif
            }  /* end: for i */
#if SURF_ALLOC_CHECKS
            if ( tiling_parms.status != HSSTAT_ALLOC_ERROR )
#endif

                     /* Process the facet. */
               clip_and_shade();
         }  /* end: while */

         /* Display the surface. */
         HSpaint( 0 );

      }/* else it is a surface */
   } /* end: while each surface */

   /* reset the cull flag */
   HSset_element_cull_flag( HS_CULL_NONE );

   /* Flush the buffer. */
   HSpaint( TRUE );

   /* Replace the appropriate value of the grid */
   active_window->grid_on = GridValue;

   WLshow_cursor( active_window->win_no );
   WLflush( active_window->win_no );

#if DISPLAY_DEBUG
   fprintf( stderr, "Exiting HSdisplay_fb_NOFPE\n" );
#endif

} /* HSdisplay_fb_NOFPE */

#if defined( OPENGL )
void HSdisplay_fb_OPENGL( IGRint                  *fb_buffer_ptr,
                          IGRint                  pipe_no,
                          IGRdouble               wld_to_view[4][4],
                          IGRdouble               vw_vol[6],
                          IGRdouble               rotate_matrix[4][4],
                          IGRdouble               transform_matrix[4][4],
                          struct HS_light_source  global_lights[],
                          struct HS_light_source  *ambient_light,
                          IGRdouble               *eye_point,
                          IGRdouble               vrp[3],
                          IGRdouble               vpn[3],
                          IGRdouble               vup[3] )

/*
NAME
   HSdisplay_fb_OPENGL

DESCRIPTION
   This function displays a feedback buffer using OpenGL.

HISTORY
   08/23/93 S.P. Rogers
      Creation Date
*/

{

   register int        *cur_ptr;
   int                 num_verts;
   int                 NumFacetNormals;
   int                 options;
   float               *float_ptr;
   float               *RGB;
   double              *points;
   float               *verts, *vnorms, *fnorms;
   GLfloat             gl_material[4];
   IGRint              status;
   int                 finish;
   int                 cull_flag;
   float               spec_reflectance;
   float               diff_reflectance;
   float               transparency;

   tiling_parms.processing_mode &= ~HS_PMODE_FEEDBACK_FULL;

   HSactivate_window( pipe_no );   /* ignore returned status */

   WLset_drawing_mode( active_window->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );

   /* update the EG window parameters */
   HSsetup_OPENGL_window( wld_to_view, vw_vol, eye_point, vrp, vpn, vup,
                      active_window->x_dits, active_window->y_dits, TRUE );

   /* update the lights */
   HSsetup_window_lights( global_lights, ambient_light );

   /* erase the window */
   WLclear_window( active_window->win_no );
 
   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );

   cur_ptr = fb_buffer_ptr;
   while( cur_ptr && ( (*cur_ptr) & NEXT_SURFACE_MASK ||
                        *cur_ptr == HSFRAMELINK ))
   {

      if ( *cur_ptr == HSFRAMELINK )
      {
         cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);

         if ( cur_ptr )
         {
            cur_ptr += 2;
            fb_buffer_ptr = cur_ptr;

         }
         else
         {
            /* if no other buffer blocks, exit loop */
            break;
         }
      }

      options = (*(cur_ptr++)) & (~NEXT_SURFACE_MASK);
      RGB = float_ptr = (float *)cur_ptr;

      glColor3fv( RGB );
      float_ptr += 3;

      cur_ptr = (int *)float_ptr;

      /* finish */
      glMateriali( GL_FRONT_AND_BACK, GL_SHININESS, *(cur_ptr++) );

      float_ptr = (float *)cur_ptr;

      spec_reflectance = *(float_ptr++);
      diff_reflectance = *(float_ptr++);
      transparency = *(float_ptr++);

      gl_material[0] = RGB[0] * diff_reflectance;
      gl_material[1] = RGB[1] * diff_reflectance;
      gl_material[2] = RGB[2] * diff_reflectance;
      gl_material[3] = 1.0;
      glMaterialfv( GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, gl_material );

      gl_material[0] = gl_material[1] = gl_material[2] = spec_reflectance;
      glMaterialfv( GL_FRONT_AND_BACK, GL_SPECULAR, gl_material );

      cur_ptr = (int *)float_ptr;
      
      /* skip weights field */
      cur_ptr++;

      /* skip culling for now */
      cull_flag = *(cur_ptr++);
      if ( options == HS_BST_POINT )
      {

         num_verts = *(cur_ptr++);
         HSALIGN_DOUBLE( cur_ptr );
         points = (IGRdouble *) cur_ptr;
         cur_ptr += 6 * num_verts;
         glBegin( GL_POINTS );
         while ( num_verts-- );
         {
            glVertex3dv( points );
            points += 3;
         }
         glEnd();
      }
      else
      {
         while ( (*cur_ptr) && ! ( (*cur_ptr) & NEXT_SURFACE_MASK ) )
         {
            if ( *cur_ptr == HSFRAMELINK )
            {
               cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);
               if ( cur_ptr )
               {
                  cur_ptr += 2;
                  fb_buffer_ptr = cur_ptr;
                  continue;
               }
               else
               {
                  /* if no other buffer blocks, exit loop */
                  break;
               }
            }

            if( ( options & (HS_BST_POLYLINE | HS_BST_POLYLINE_DELETE) ) )
            {
               /* Pull out POLYLINE data as stored */
               num_verts = *(cur_ptr++);
               verts = (float *) cur_ptr;
               cur_ptr += ( 3 * num_verts );

               glDisable( GL_LIGHTING );
               glBegin( GL_LINE_STRIP );
               while ( num_verts-- )
               {
                  glVertex3fv( verts );
                  verts += 3;
               }
               glEnd();
               glEnable( GL_LIGHTING );
            }
            else
            {
               while( *cur_ptr &&
                      !( *cur_ptr & NEXT_SURFACE_MASK ) &&
                      *cur_ptr != HSFRAMELINK )
               {

                  num_verts = *(cur_ptr++);
                  NumFacetNormals = *(cur_ptr++);

                  fnorms = (float *)cur_ptr;
                  cur_ptr += 3 * NumFacetNormals;

                  verts = (float *)cur_ptr;
                  cur_ptr += 3 * num_verts;

                  if ( options & GR_BST_SMOOTH )
                  {
                     vnorms = (float *) cur_ptr;
                     cur_ptr += 3 * num_verts;

                     glShadeModel( GL_SMOOTH );
                     glBegin( GL_TRIANGLE_STRIP );
                     while ( num_verts-- )
                     {
                        glNormal3fv( vnorms );
                        glVertex3fv( verts );
                        verts += 3;
                        vnorms += 3;
                     }
                     glEnd();

                  }
                  else if( options & GR_BST_CONSTANT )
                  {
                     glShadeModel( GL_FLAT );
                     if ( NumFacetNormals > 1 )
                     {
                        /* facet normal per triangle */
                        glBegin( GL_TRIANGLE_STRIP );

                        glNormal3fv( fnorms );
                        glVertex3fv( verts );
                        glVertex3fv( verts + 3 );
                        glVertex3fv( verts + 6 );
                        verts += 9;
                        fnorms += 3;
                        num_verts -= 3;

                        while ( num_verts-- )
                        {
                           glNormal3fv( fnorms );
                           fnorms += 3;

                           glVertex3fv( verts );
                           verts += 3;
                        }
                        glEnd();
                     }
                     else
                     {
                        /* only one facet normal */
                        glBegin( GL_TRIANGLE_STRIP );
                        glNormal3fv( fnorms );
                        while ( num_verts-- )
                        {
                           glVertex3fv( verts );
                           verts += 3;
                        }
                        glEnd();
                     }
                  }
               }
            }
         } /* end of facet while loop */
      } /* else it is a surface */
   } /* end of surface while loop */
} /* HSdisplay_fb_OPENGL */
#endif

#if defined( XGL )
void HSdisplay_fb_XGL(    IGRint                  *fb_buffer_ptr,
                          IGRint                  pipe_no,
                          IGRdouble               wld_to_view[4][4],
                          IGRdouble               vw_vol[6],
                          IGRdouble               rotate_matrix[4][4],
                          IGRdouble               transform_matrix[4][4],
                          struct HS_light_source  global_lights[],
                          struct HS_light_source  *ambient_light,
                          IGRdouble               *eye_point,
                          IGRdouble               vrp[3],
                          IGRdouble               vpn[3],
                          IGRdouble               vup[3] )

/*
NAME
   HSdisplay_fb_XGL

DESCRIPTION
   This function displays a feedback buffer using XGL.

HISTORY
	21-Apr-1994	sash.		Creation.
*/

{

   register int        *cur_ptr;
   int                 num_verts,jj;
   int                 NumFacetNormals;
   int                 options;
   float               *float_ptr;
   float               *RGB;
   double              *points;
   float               *verts, *vnorms, *fnorms;
   int                 finish;
   int                 cull_flag;
   float               spec_refl;
   float               diff_refl;
   float               transp;

   char			*address_space=NULL;
   unsigned long	bytes_allocated=0,
			bytes_required=HS_PAGE_SIZE;

   Xgl_color      		xgl_color;
   Xgl_pt_list	        	pt_list[1];
   Xgl_facet_list		facet_list[1];
   Xgl_surf_illumination 	xgl_surf_illumination; 
   Xgl_pt_normal_f3d		*pt_normal_f3d_arr = NULL;

   /*------------------------------------------------------------*/

#if 0
   HSdump_fb_buffer( fb_buffer_ptr );
#endif

   tiling_parms.processing_mode &= ~HS_PMODE_FEEDBACK_FULL;

   HSactivate_window( pipe_no );   

   WLset_drawing_mode( active_window->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );

   /* update the XGL window parameters */
   HSsetup_XGL_window( 	wld_to_view, 
			vw_vol, 
			eye_point, 
			vrp, vpn, vup,
                      	active_window->x_dits, 
			active_window->y_dits, 
			TRUE );

   /* update the lights */
   HSsetup_window_lights( global_lights, ambient_light );

   /* erase the window */
   WLclear_window( active_window->win_no );

   cur_ptr = fb_buffer_ptr;
   while( cur_ptr && ( (*cur_ptr) & NEXT_SURFACE_MASK ||
                        *cur_ptr == HSFRAMELINK ))
   {

      if ( *cur_ptr == HSFRAMELINK )
      {
         cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);

         if ( cur_ptr )
         {
            cur_ptr += 2;
            fb_buffer_ptr = cur_ptr;

         }
         else
         {
            /* if no other buffer blocks, exit loop */
            break;
         }
      }

      options = (*(cur_ptr++)) & (~NEXT_SURFACE_MASK);

      RGB = float_ptr = (float *)cur_ptr;

      float_ptr += 3;

      cur_ptr = (int *)float_ptr;
      finish = *(cur_ptr++);

      float_ptr = (float *)cur_ptr;
      spec_refl = *(float_ptr++);
      diff_refl = *(float_ptr++);
      transp    = *(float_ptr++);

      if ( options & GR_BST_SMOOTH )
      {
	xgl_surf_illumination = XGL_ILLUM_PER_VERTEX;
      }
      else 
      {
	xgl_surf_illumination = XGL_ILLUM_PER_FACET;
      }

      cur_ptr = (int *)float_ptr;

      HS_XGL_SET_RGB_COLOR (xgl_color, RGB[0], RGB[1], RGB[2]);
	
      /*
	 Enable ligting at appropriate places. If not required here.
	 TBD TBD TBD TBD
      */
      xgl_object_set (active_window->xgl_context_3D,
  		      HS_XGL_SURFACE_ATTRIBUTES,
		      NULL);
      
      /* skip weights field */
      cur_ptr++;

      /* skip culling for now */
      cull_flag = *(cur_ptr++);

      if ( options == HS_BST_POINT )
      {

         num_verts = *(cur_ptr++);
         HSALIGN_DOUBLE( cur_ptr );
         points = (IGRdouble *) cur_ptr;
         cur_ptr += 6 * num_verts;
	 
	 if(num_verts)
         {
            xgl_object_set(active_window->xgl_context_3D,
			XGL_CTX_MARKER_COLOR, 		&xgl_color, 
			XGL_CTX_MARKER, 		xgl_marker_square, 
			XGL_CTX_MARKER_COLOR_SELECTOR,XGL_MARKER_COLOR_CONTEXT,
			NULL);

 	    HS_XGL_SET_PT_LIST_F3D(pt_list[0], num_verts, points);

	    /* Draw a marker at given point. */
	    xgl_multimarker(active_window->xgl_context_3D, pt_list);

	 }/* if(num_verts) */
	 else
	 {
#if DEBUG
	   printf("[HS_BST_POINT] FB empty. num_verts = %d\n",num_verts);
#endif		
	 }

      }
      else
      {
         while ( (*cur_ptr) && ! ( (*cur_ptr) & NEXT_SURFACE_MASK ) )
         {
            if ( *cur_ptr == HSFRAMELINK )
            {
               cur_ptr = (IGRint *)*(fb_buffer_ptr - 2);
               if ( cur_ptr )
               {
                  cur_ptr += 2;
                  fb_buffer_ptr = cur_ptr;
                  continue;
               }
               else
               {
                  /* if no other buffer blocks, exit loop */
                  break;
               }
            }

            if( ( options & (HS_BST_POLYLINE | HS_BST_POLYLINE_DELETE) ) )
            {
               /* Pull out POLYLINE data as stored */
               num_verts = *(cur_ptr++);
               verts = (float *) cur_ptr;
               cur_ptr += ( 3 * num_verts );
		
	       if(num_verts)
	       {
	       	  HS_XGL_SET_PT_LIST_F3D(pt_list[0], num_verts, verts);

		  /* Opngl: Disable lighting. ???? */

	          /* Draw a strip. */	
	          xgl_multipolyline(active_window->xgl_context_3D,
				    NULL,		/* bbox	*/
				    1 ,		/* num pt lists */
				    pt_list);

		  /* Opngl: Enable lighting.?????? */
		}
		else
		{
#if DEBUG
	   	   printf("[HS_BST_POLYLINE] FB empty. num_verts = %d\n",num_verts);
#endif		
	 	}
            }
            else
            {
               while( *cur_ptr &&
                      !( *cur_ptr & NEXT_SURFACE_MASK ) &&
                      *cur_ptr != HSFRAMELINK )
               {

                  num_verts = *(cur_ptr++);
                  NumFacetNormals = *(cur_ptr++);

                  fnorms = (float *)cur_ptr;
                  cur_ptr += 3 * NumFacetNormals;

                  verts = (float *)cur_ptr;
                  cur_ptr += 3 * num_verts;

		  if(!num_verts)
		  {
#if DEBUG
		   printf("[HS_BST_SURF] FB empty. num_verts = %d\n",num_verts);
		   printf("[HS_BST_SURF] FB empty. num_facet_normals = %d\n",
				NumFacetNormals);
#endif		
		  }

                  if ( options & GR_BST_SMOOTH )
                  {
                     vnorms = (float *) cur_ptr;
                     cur_ptr += 3 * num_verts;

		     bytes_required = num_verts*sizeof(Xgl_pt_normal_f3d);

		     HStl_allocate_memory(address_space,
					  bytes_allocated, 
					  bytes_required);

		     pt_normal_f3d_arr = (Xgl_pt_normal_f3d *)address_space;

  	             HS_XGL_SET_PT_NORMAL_F3D(num_verts,
				              verts,
				              vnorms,
				              pt_normal_f3d_arr);

	  	     HS_XGL_SET_PT_LIST_NORMAL_F3D(pt_list[0], 
					           num_verts, 
					           pt_normal_f3d_arr);

	             xgl_triangle_strip(active_window->xgl_context_3D, 
				        NULL,
				        pt_list);

			/* End of smooth shading */
				      
                  }
                  else if( options & GR_BST_CONSTANT )
                  {
		     bytes_required = num_verts*sizeof(Xgl_pt_normal_f3d);

		     HStl_allocate_memory(address_space,
					  bytes_allocated, 
					  bytes_required);

	             pt_normal_f3d_arr	= (Xgl_pt_normal_f3d *)address_space;

 		     if(NumFacetNormals > 1 )
		     {
			pt_normal_f3d_arr[0].x = verts[0];
        	        pt_normal_f3d_arr[0].y = verts[1];
                	pt_normal_f3d_arr[0].z = verts[2];

			pt_normal_f3d_arr[1].x = verts[3];
	                pt_normal_f3d_arr[1].y = verts[4];
	                pt_normal_f3d_arr[1].z = verts[5];
		
			pt_normal_f3d_arr[2].x = verts[6];
                	pt_normal_f3d_arr[2].y = verts[7];
	                pt_normal_f3d_arr[2].z = verts[8];

        	        pt_normal_f3d_arr[0].normal.x = 
	                pt_normal_f3d_arr[1].normal.x = 
	                pt_normal_f3d_arr[2].normal.x = fnorms[0];

        	        pt_normal_f3d_arr[0].normal.y =
	                pt_normal_f3d_arr[1].normal.y =
	                pt_normal_f3d_arr[2].normal.y = fnorms[1];

        	        pt_normal_f3d_arr[0].normal.z =
	                pt_normal_f3d_arr[1].normal.z = 
        	        pt_normal_f3d_arr[2].normal.z = fnorms[2];

			for(jj=3;jj<num_verts;jj++)
			{
			   pt_normal_f3d_arr[jj].x        = verts[(3*jj)];
			   pt_normal_f3d_arr[jj].y        = verts[(3*jj)+1];
			   pt_normal_f3d_arr[jj].z        = verts[(3*jj)+2];
	                   pt_normal_f3d_arr[jj].normal.x = fnorms[(3*(jj-2))];
	                   pt_normal_f3d_arr[jj].normal.y = fnorms[(3*(jj-2))+1];
	                   pt_normal_f3d_arr[jj].normal.z = fnorms[(3*(jj-2))+2];
		        }

		     }
		     else
		     {
		             for(jj=0;jj<num_verts;jj++)
		             {
				pt_normal_f3d_arr[jj].x		= verts[(3*jj)];
				pt_normal_f3d_arr[jj].y		= verts[(3*jj)+1];
				pt_normal_f3d_arr[jj].z		= verts[(3*jj)+2];
		       		pt_normal_f3d_arr[jj].normal.x = fnorms[0];
		       		pt_normal_f3d_arr[jj].normal.y = fnorms[1];
		       		pt_normal_f3d_arr[jj].normal.z = fnorms[2];
		    	     }
		     }

	  	     HS_XGL_SET_PT_LIST_NORMAL_F3D(pt_list[0], 
					           num_verts, 
					           pt_normal_f3d_arr);

	             xgl_triangle_strip(active_window->xgl_context_3D, 
				        NULL,
				        pt_list);
				      
			/* End of constant shading */
                  }
               }
            }
         } /* end of facet while loop */
      } /* else it is a surface */
   } /* end of surface while loop */

   if(address_space) free(address_space);

} /* HSdisplay_fb_XGL */

#endif



/*----------------------------------------------------------------------------*/

/*
 * ABSTRACT:   HSenable_feedback kicks the tiler into feedback mode by setting
 *      the tiling_parms feedback flag to TRUE, modifying the pipe's
 *      tiling parameters,  and allocating the surface header which will
 *      become the head of the feedback buffer list.
 *
 * RETURN:   - the surface header that will start the feedback list.
 *
 * HISTORY:   03/29/88 Created.            C. M. Jablonski
 *       03/21/90 Rewritten.            C. M. Jablonski
 *
 */

void HSenable_feedback( IGRint     vs_no,
                        IGRint     win_no,
                        IGRint     pipe_no,
                        IGRdouble  wv_scale,
                        IGRint     shading_style )
   
{

#if defined(XGL)
Xgl_object   xgl_context_3D,hl_xgl_context;
#endif

   /*
    * Activate a dummy window for use when filling the feedback buffer.
    */

   save_pipe_no = (active_window) ?
                  (active_window->pipe_no) : (NO_PREV_ACTIVE_WINDOW);

   HSinit_shading_window( vs_no, 
                          win_no,
                          pipe_no,
                          NULL,
                          NULL,
                          shading_style,
                          NULL_OBJID,
                          0 );   /* ignore returned status */

#if defined(XGL)
    WLxgl_get_window_contexts(active_window->win_no,
                              &xgl_context_3D,
                              &hl_xgl_context );
 
    active_window->xgl_context_3D = xgl_context_3D;
#endif


   /*
    * Set the world-to-viewport scale.  This allows us to tile to the
    * original window tolerance.
    */
   active_window->wv_scale = wv_scale;

   /*
    * Set the transform matrix so that the buffered facets will be in
    * world coordinates.
    */
   HSset_active_transformation( IDENTITY_4x4 );

   /*
    * Set the rotate matrix so that the buffered facet normals will be in
    * world coordinates.
    */

   HSset_active_rotation( IDENTITY_4x4 );
   if (active_window->perspective == FALSE)
   {
      /* set the perspective scales */
      active_window->perspective = FALSE;   
      HSset_active_perspective_scales( 1.0, 1.0, 1.0 );
   }
   
   HSset_feedback_mode( TRUE );

   active_window->process_facet = HSsave_facet;
   active_window->process_mesh = HSsave_TriMesh;

   DPinq_buf_ptrs( &cur_disp_ptr,
                   &end_disp_ptr,
                   &cur_app_fb_ptr,
                   &end_app_fb_ptr );
#if FEEDBACK_DEBUG
   UserBuffer = (IGRdouble *) malloc( APP_FEEDBACK_SIZE );
   *cur_app_fb_ptr = UserBuffer;
   end_app_fb_ptr = *cur_app_fb_ptr + APP_FEEDBACK_SIZE;
   *cur_app_fb_ptr += 2 /* doubles */;
#endif

   if(*cur_disp_ptr)
   {
      next_word_ptr = (IGRint *) *cur_disp_ptr;

      if ( *cur_app_fb_ptr )
      {
         next_user_word = (IGRint *) *cur_app_fb_ptr;
         load_both = TRUE;
         load_disp = FALSE;
      }
      else
      {
         load_both = FALSE;
         load_disp = TRUE;
      }
      load_fb = FALSE;
      local_beg_ptr = *cur_disp_ptr;
      local_end_ptr = end_disp_ptr;
      total_bytes = 0;
      buffer_bytes = 0;
   }
   else if ( *cur_app_fb_ptr )
   {
      next_user_word = next_word_ptr = (IGRint *) *cur_app_fb_ptr;

      load_fb = TRUE;
      load_disp = FALSE;
      load_both = FALSE;
      local_beg_ptr = *cur_app_fb_ptr;
      local_end_ptr = end_app_fb_ptr;
      total_bytes = 0;
      buffer_bytes = -LINK_SIZE;
   }
   else
   {
#if DISPLAY_DEBUG
      fprintf( stderr, "Error in buffer pointers. Both display and \n");
      fprintf( stderr, "feedback are null\n" );
#endif
      return;
   }

   /* Step back a double word to write the frame header for HLINE frame
    * and the frame size on the first word of the frame. This word also
    * contains a flag bit to indicate if double buffering can be allowed
    * or not. In case of RHL surfaces db should be disabled during display
    * on machines with double buffering capability.
    */

   if ( load_both || load_disp )
   {
      hdr_word_ptr = ( next_word_ptr - 4 );
      *hdr_word_ptr = HSMAX_FRAME_SIZE << 2;
      *hdr_word_ptr |= HLINE_MASK;
      *hdr_word_ptr |= DB_FLAG_MASK;
      hdr_word_ptr += 1;
      if( active_window->type & (HShardware_LB_EG | HShardware_LB_OPENGL
			| HShardware_LB_XGL) )
      {
         *hdr_word_ptr |= EDGEII_BUFFER_MASK;
      }
      else
      {
         *hdr_word_ptr &= ~EDGEII_BUFFER_MASK;
      }

      hdr_word_ptr += 1;
      *hdr_word_ptr = NULL; /* In case this is the only block */
   }

   if ( load_both || load_fb )
   {
      user_hdr_word = (IGRint *)( next_user_word - 4 );
      *user_hdr_word = APP_FEEDBACK_SIZE << 2;
      *user_hdr_word |= HSHLINE_FRAME;
      *user_hdr_word |= DB_FLAG_MASK;
      user_hdr_word += 1;
      if( active_window->type & (HShardware_LB_EG | HShardware_LB_OPENGL
			| HShardware_LB_XGL) )
      {
         *user_hdr_word |= EDGEII_BUFFER_MASK;
      }
      else
      {
         *user_hdr_word &= ~EDGEII_BUFFER_MASK;
      }
      user_hdr_word += 1;
      *user_hdr_word = NULL;
   }

   fb_buffer_size = sizeof(IGRdouble) * (local_end_ptr - local_beg_ptr);

#if DISPLAY_DEBUG
   fprintf(stderr,"save_surface: fb_buffer_size=%d\n",fb_buffer_size );
#endif

   HSset_feedback_full_mode( FALSE );

   MaxHighWater = 0;

} /* HSenable_feedback */


/*----------------------------------------------------------------------------*/

/*
 * ABSTRACT:   HSdisable_feedback kicks the tiler out of feedback mode by
 *      resetting the tiler flags and restoring the active window.
 *
 * HISTORY:   03/29/88   Created.         C. M. Jablonski
 *
 */

void HSdisable_feedback( void)

{
   HSdelete_active_window();  

   if (save_pipe_no != NO_PREV_ACTIVE_WINDOW)
   {
      HSactivate_window( save_pipe_no );
   }

   HSset_feedback_mode( FALSE );
   HSset_feedback_full_mode( FALSE );

} /* HSdisable_feedback */
