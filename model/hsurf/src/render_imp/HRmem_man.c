
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

#include <stdio.h>
#include <tools.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "bs.h"

#include "hslight.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "hsmemory.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "hrmem.h"

#include "HSpr_render.h"

 


/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HRmem_man.c */
static void HRprint_pool_memory_stats __((void));

static IGRchar *HRalloc_struct_from_pool __((struct HRpool_mem_data *pool_stats));

static void HRfree_pool_struct __((IGRchar *node, 
		    struct HRpool_mem_data *pool_stats));


#if defined(__cplusplus)
}
#endif


#undef __



#define HR_2K            2048
#define HR_4K            4096
#define HR_60K           61440
#define HR_TILER_RESERVE 2091752  /* 2.0 MB */

/* static globals used for limiting the number of trapezoid pools allocated */
static IGRint                 reserved_tiler_mem;
static IGRchar                *high_water_mark;
static IGRboolean             mem_limit_hit;


/* static global data for pool memory managment */
static struct HRpool_list_node  *pool_list;
static struct HRpool_mem_data   HRenv_manager;
static struct HRpool_mem_data   HRsurface_rec_manager;
static struct HRpool_mem_data   HRspan_trap_manager;
static struct HRpool_mem_data   HRspan_deltas_manager;
static struct HRpool_mem_data   HRspan_intersect_manager;
static struct HRpool_mem_data	HRtrapezoid_uv_manager;
static struct HRpool_mem_data	HRtexture_interp_parms_manager;
static struct HRpool_mem_data   HRtexture_list_manager;

#define RECORD_POOL_ALLOC( pool_data ) \
       ((pool_data)->pool_allocs)++;

#define RECORD_LIST_ALLOC( pool_data ) \
       ((pool_data)->list_allocs)++;

#define RECORD_NUM_ALLOC( pool_data )  \
       ((pool_data)->total_malloced) += ((pool_data)->structs_per_pool);

#define RECORD_FREE( pool_data )       \
       ((pool_data)->frees)++;


/*---- HRprint_pool_memory_stats --------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HRprint_pool_memory_stats(void)
#else
	static void HRprint_pool_memory_stats()
#endif

/*
DESCRIPTION
	Print out information about HSURF memory allocation and use.
*/

	{
	FILE    *fp;
	IGRchar *expansion;
	IGRint  env_size, surface_rec_size, span_trap_size, span_deltas_size;
	IGRint	span_intersect_size, trapezoid_uv_size, texture_interp_parms_size;
	IGRint	texture_list_size;
		
	/* only write logging file if HR_LOG_MEMORY_USE */
	/* environment variable is defined to be 1      */
	expansion = (IGRchar *)getenv( "HR_LOG_MEMORY_USE" );
	if ( (expansion == NULL) || (expansion[0] != '1') )
	   return;

	fp = fopen( "/usr/tmp/hr_mem_use", "w" );
	
	env_size = sizeof( struct HRenv_record );
	surface_rec_size   = sizeof( struct HRsurface_record );
	span_trap_size = sizeof( struct HRspan_trapezoid );
	span_deltas_size = sizeof( struct HRspan_deltas );
	span_intersect_size = sizeof( struct HRspan_intersect );
	trapezoid_uv_size = sizeof( struct HRtrapezoid_uv );
	texture_interp_parms_size = sizeof( struct HRtexture_interp_parms );
	texture_list_size = sizeof( struct HRtexture_list );

	fprintf( fp, "\n\n" );
	fprintf( fp, "                   **** HSURF Memory Management Statistics ****\n\n" );
	
	fprintf( fp, "\nPool Memory Allocation:\n\n" );

	fprintf( fp, "   Environment structures:     %5d  * %3d bytes = %6d\n",
		         HRenv_manager.total_malloced, env_size, 
		         HRenv_manager.total_malloced * env_size );

	fprintf( fp, "   Surface headers:            %5d  * %3d bytes = %6d\n",
	                 HRsurface_rec_manager.total_malloced, surface_rec_size,
	                 HRsurface_rec_manager.total_malloced * surface_rec_size );

	fprintf( fp, "   Phong trapezoids:           %5d  * %3d bytes = %6d\n",
	                 HRspan_trap_manager.total_malloced, span_trap_size,
	                 HRspan_trap_manager.total_malloced * span_trap_size );
  
	fprintf( fp, "   Span Deltas:                %5d  * %3d bytes = %6d\n",
	                 HRspan_deltas_manager.total_malloced, span_deltas_size,
	                 HRspan_deltas_manager.total_malloced * span_deltas_size );

	fprintf( fp, "   Span Intersect:             %5d  * %3d bytes = %6d\n",
	                 HRspan_intersect_manager.total_malloced, span_intersect_size,
	                 HRspan_intersect_manager.total_malloced * span_intersect_size );
	                 
	fprintf( fp, "   Trapezoid uv:               %5d  * %3d bytes = %6d\n",
	                 HRtrapezoid_uv_manager.total_malloced, trapezoid_uv_size,
	                 HRtrapezoid_uv_manager.total_malloced * trapezoid_uv_size );

	fprintf( fp, "   Texture Interp Parms:       %5d  * %3d bytes = %6d\n",
	                 HRtexture_interp_parms_manager.total_malloced, texture_interp_parms_size,
	                 HRtexture_interp_parms_manager.total_malloced * texture_interp_parms_size );

	fprintf( fp, "   Texture List Nodes:         %5d  * %3d bytes = %6d\n",
	                 HRtexture_list_manager.total_malloced, texture_list_size,
	                 HRtexture_list_manager.total_malloced * texture_list_size );

	fprintf( fp, "\nTotal Memory Allocation:  %d\n\n\n",
		         HRenv_manager.total_malloced * env_size                  +
	                 HRsurface_rec_manager.total_malloced * surface_rec_size  +
	                 HRspan_trap_manager.total_malloced * span_trap_size    +
	                 HRspan_deltas_manager.total_malloced * span_deltas_size  +
	                 HRspan_intersect_manager.total_malloced * span_intersect_size +
	                 HRtrapezoid_uv_manager.total_malloced * trapezoid_uv_size + 
                         HRtexture_interp_parms_manager.total_malloced * texture_interp_parms_size,
	                 HRtexture_list_manager.total_malloced * texture_list_size );
	
	fprintf( fp, "Memory Macro Performance:\n\n" );
	fprintf( fp, "                     Pool Allocs    Free List Allocs    Frees\n" );
	fprintf( fp, "                     -----------    ----------------    -----\n" );
	fprintf( fp, "   Env Structures      %5d             %5d         %5d\n",
		         HRenv_manager.pool_allocs,
		         HRenv_manager.list_allocs, HRenv_manager.frees );

	fprintf( fp, "   Surface Headers     %5d             %5d         %5d\n",
		         HRsurface_rec_manager.pool_allocs,
		         HRsurface_rec_manager.list_allocs, HRsurface_rec_manager.frees );

	fprintf( fp, "   Phong Trapezoids    %5d             %5d         %5d\n",
		         HRspan_trap_manager.pool_allocs,
		         HRspan_trap_manager.list_allocs, HRspan_trap_manager.frees );

	fprintf( fp, "   Span Deltas         %5d             %5d         %5d\n",
		         HRspan_deltas_manager.pool_allocs,
		         HRspan_deltas_manager.list_allocs, HRspan_deltas_manager.frees );
	
	fprintf( fp, "   Trapezoid uv        %5d             %5d         %5d\n",
		         HRtrapezoid_uv_manager.pool_allocs,
		         HRtrapezoid_uv_manager.list_allocs, HRtrapezoid_uv_manager.frees );
	
	fprintf( fp, "   Texture Interp Par  %5d             %5d         %5d\n",
		         HRtexture_interp_parms_manager.pool_allocs,
		         HRtexture_interp_parms_manager.list_allocs, HRtexture_interp_parms_manager.frees );

	fprintf( fp, "   Texture List Nodes  %5d             %5d         %5d\n",
		         HRtexture_list_manager.pool_allocs,
		         HRtexture_list_manager.list_allocs, HRtexture_list_manager.frees );
	
	fprintf( fp, "   Span Intesect       %5d             %5d         %5d\n",
		         HRspan_intersect_manager.pool_allocs,
		         HRspan_intersect_manager.list_allocs, 
		         HRspan_intersect_manager.frees );
	
	fclose( fp );
	}  /* HRprint_pool_memory_stats */


/*---- HRsave_pool_address ------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRsave_pool_address( IGRchar *start_address,
				   IGRint zbuffer_pool )
#else
	void HRsave_pool_address( start_address, zbuffer_pool )

	IGRchar *start_address;
	IGRint  zbuffer_pool;
#endif
	
/*
DESCRIPTION
	Save the starting address of an allocated memory pool so that it
	can be freed when processing is finished.
*/

	{	
	struct HRpool_list_node *temp;

	temp = (struct HRpool_list_node *) malloc( sizeof( struct HRpool_list_node ) );
	temp->start_addr = start_address;
        temp->next = pool_list;
	temp->zbuffer_pool = zbuffer_pool;
	pool_list = temp;

	}  /* HRsave_pool_address */
	

/*---- HRinit_pool_memory_management ------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRinit_pool_memory_management(void)
#else
	void HRinit_pool_memory_management()
#endif

/*
DESCRIPTION
	Initialize the global data used by the memory management macros

HISTORY
	S.P. Rogers  07/07/89  Creation Date
*/

	{
	IGRchar *expansion;

	pool_list = NULL;

	/* initialized restricted growth pool static variables */
	mem_limit_hit = FALSE;
	high_water_mark = 0;

	/* Determine the amount of memory that should be reserved for the tiler by */
	/* using what is defined in the TILER MEMORY shell variable or the default */
	expansion = (IGRchar *)getenv( "HS_RENDERING_TILER_MEM" );
	if ( expansion )
	   sscanf( expansion, "%d", &reserved_tiler_mem );
	else
	   reserved_tiler_mem = HR_TILER_RESERVE;

	/* initialize env manager */
	HRenv_manager.struct_size       = sizeof( struct HRenv_record );
	HRenv_manager.structs_per_pool  = HR_4K / HRenv_manager.struct_size;
	HRenv_manager.restrict_growth   = FALSE;
	HRenv_manager.left_in_pool      = 0;
	HRenv_manager.free_list         = NULL;
	HRenv_manager.pool              = NULL;
	HRenv_manager.total_malloced    = 0;
	HRenv_manager.pool_allocs       = 0;
	HRenv_manager.list_allocs       = 0;
	HRenv_manager.frees             = 0;

	/* initialize surface record manager */
	HRsurface_rec_manager.struct_size       = sizeof( struct HRsurface_record );
	HRsurface_rec_manager.structs_per_pool  = HR_4K / HRsurface_rec_manager.struct_size;
	HRsurface_rec_manager.restrict_growth   = FALSE;
	HRsurface_rec_manager.left_in_pool      = 0;
	HRsurface_rec_manager.free_list         = NULL;
	HRsurface_rec_manager.pool              = NULL;
	HRsurface_rec_manager.total_malloced    = 0;
	HRsurface_rec_manager.pool_allocs       = 0;
	HRsurface_rec_manager.list_allocs       = 0;
	HRsurface_rec_manager.frees             = 0;

	/* initialize phong trapezoid manager */
	HRspan_trap_manager.struct_size       = sizeof( struct HRspan_trapezoid );
	HRspan_trap_manager.structs_per_pool  = HR_60K / HRspan_trap_manager.struct_size;
	HRspan_trap_manager.restrict_growth   = TRUE;
	HRspan_trap_manager.left_in_pool      = 0;
	HRspan_trap_manager.free_list         = NULL;
	HRspan_trap_manager.pool              = NULL;
	HRspan_trap_manager.total_malloced    = 0;
	HRspan_trap_manager.pool_allocs       = 0;
	HRspan_trap_manager.list_allocs       = 0;
	HRspan_trap_manager.frees             = 0;

	/* initialize span deltas manager */
	HRspan_deltas_manager.struct_size       = sizeof( struct HRspan_deltas );
	HRspan_deltas_manager.structs_per_pool  = HR_4K / HRspan_deltas_manager.struct_size;
	HRspan_deltas_manager.restrict_growth   = FALSE;
	HRspan_deltas_manager.left_in_pool      = 0;
	HRspan_deltas_manager.free_list         = NULL;
	HRspan_deltas_manager.pool              = NULL;
	HRspan_deltas_manager.total_malloced    = 0;
	HRspan_deltas_manager.pool_allocs       = 0;
	HRspan_deltas_manager.list_allocs       = 0;
	HRspan_deltas_manager.frees             = 0;

	/* initialize trapezoid uv manager */
	HRtrapezoid_uv_manager.struct_size       = sizeof( struct HRtrapezoid_uv );
	HRtrapezoid_uv_manager.structs_per_pool  = HR_4K / HRtrapezoid_uv_manager.struct_size;
	HRtrapezoid_uv_manager.restrict_growth   = FALSE;
	HRtrapezoid_uv_manager.left_in_pool      = 0;
	HRtrapezoid_uv_manager.free_list         = NULL;
	HRtrapezoid_uv_manager.pool              = NULL;
	HRtrapezoid_uv_manager.total_malloced    = 0;
	HRtrapezoid_uv_manager.pool_allocs       = 0;
	HRtrapezoid_uv_manager.list_allocs       = 0;
	HRtrapezoid_uv_manager.frees             = 0;

	/* initialize texture interp parms manager */
	HRtexture_interp_parms_manager.struct_size       = sizeof( struct HRtexture_interp_parms );
	HRtexture_interp_parms_manager.structs_per_pool  = HR_4K / HRtexture_interp_parms_manager.struct_size;
	HRtexture_interp_parms_manager.restrict_growth   = FALSE;
	HRtexture_interp_parms_manager.left_in_pool      = 0;
	HRtexture_interp_parms_manager.free_list         = NULL;
	HRtexture_interp_parms_manager.pool              = NULL;
	HRtexture_interp_parms_manager.total_malloced    = 0;
	HRtexture_interp_parms_manager.pool_allocs       = 0;
	HRtexture_interp_parms_manager.list_allocs       = 0;
	HRtexture_interp_parms_manager.frees             = 0;

	/* initialize texture list manager */
	HRtexture_list_manager.struct_size       = sizeof( struct HRtexture_list );
	HRtexture_list_manager.structs_per_pool  = HR_4K / HRtexture_list_manager.struct_size;
	HRtexture_list_manager.restrict_growth   = FALSE;
	HRtexture_list_manager.left_in_pool      = 0;
	HRtexture_list_manager.free_list         = NULL;
	HRtexture_list_manager.pool              = NULL;
	HRtexture_list_manager.total_malloced    = 0;
	HRtexture_list_manager.pool_allocs       = 0;
	HRtexture_list_manager.list_allocs       = 0;
	HRtexture_list_manager.frees             = 0;

	/* initialize span intersection node manager */
	HRspan_intersect_manager.struct_size       = sizeof( struct HRspan_intersect );
	HRspan_intersect_manager.structs_per_pool  = HR_4K / HRspan_intersect_manager.struct_size;
	HRspan_intersect_manager.restrict_growth   = FALSE;
	HRspan_intersect_manager.left_in_pool      = 0;
	HRspan_intersect_manager.free_list         = NULL;
	HRspan_intersect_manager.pool              = NULL;
	HRspan_intersect_manager.total_malloced    = 0;
	HRspan_intersect_manager.pool_allocs       = 0;
	HRspan_intersect_manager.list_allocs       = 0;
	HRspan_intersect_manager.frees             = 0;

	}  /* HRinit_pool_memory_management */
		


/*---- HRfree_pool_memory ------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRfree_pool_memory(void)
#else
	void HRfree_pool_memory()
#endif

/*
DESCRIPTION
	Deallocate all of the memory that is in all of the pools used
	by HSURF Rendering

HISTORY
	S.P. Rogers  07/07/89  Creation Date
*/
	{
	struct HRpool_list_node *cur_node;
	struct HRpool_list_node *temp;

	/* free the allocated memory pools */
	cur_node = pool_list;
	while ( cur_node )
	   {
	   temp = cur_node->next;

	   if ( cur_node->zbuffer_pool )
	      (*tiling_parms.zfree)( 1, cur_node->start_addr );
	   else
	      free( cur_node->start_addr );

	   free( (IGRchar *) cur_node );
	   cur_node = temp;
	   }

	HRprint_pool_memory_stats();

	}  /* HRfree_pool_memory */


/***********************************************************************************/

	/* GENERIC POOL MEMORY ALLOCATION/DEALLOCATION ROUTINES */
	

/*--- HRalloc_struct_from_pool ------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static IGRchar *HRalloc_struct_from_pool( struct HRpool_mem_data *pool_stats )
#else
	static IGRchar *HRalloc_struct_from_pool( pool_stats )

	struct HRpool_mem_data *pool_stats;
#endif
	
/*
DESCRIPTION
	This function controls the allocation of a structure from a
	pool of structures and a free list of structures.
	
	The pool_stats parameter contains all of the information about
	the type of structure that is being allocated.  It contains:
	
	   - the size of the structure
	   - the number of structures to allocate per pool
	   - the number of structure that are left in the current pool
	   - a pointer to the first free structure in the current pool
	   - a pointer to a free list for the type of structure
	   
	The structures that are currently supported by this routine
	are "HRenv_record" and "HRsurface_record".
	
	NOTE:  Since this routine does not know the exact type of the
	       structure it is dealing with an assumption must be made
	       when trying to get a structure from the free list. It is
	       assumed that all of the structures managed by this routine
	       have a "next" field that is a pointer used to create a
	       linked-list of the structure and that the "next" field is
	       the first field of the structure.
	       
	The algorithm used by the function to allocate a structure is:
	
	   If there are structures on the free list,
	      one of them is returned
	   Else if there are structures left in the pool,
	    one of them is returned
	   Else if the number of pools for the structure has been exceeded
	      a new pool of structures is allocated and a structure
	      from the pool is returned.

HISTORY
	S.P. Rogers  07/07/89  Creation Date	
*/

	{
	IGRchar *node;
	IGRchar *cur_water_mark;
	IGRint  total_mem, used_mem, size_wanted, buf_size;
	
	node = NULL;

	if ( pool_stats->free_list )
	   {
	   /* allocate from the free list */
	   RECORD_LIST_ALLOC( pool_stats );
	   node = pool_stats->free_list;

	   /* We can cast "node" to any one of the structures that this  */
	   /* function is supposed to work with because we know that the */
	   /* first field of all of the structures is the next field.    */
	   pool_stats->free_list = (IGRchar *) ((struct HRenv_record *) node)->next;
	   }
	else if ( pool_stats->left_in_pool )
	   {
	   /* allocate from the pool */
	   RECORD_POOL_ALLOC( pool_stats );
	   node = pool_stats->pool;
	   (pool_stats->left_in_pool)--;
	   (pool_stats->pool) += pool_stats->struct_size;
	   }
	else
	   {
	   /* another pool needs to be allocated */
	   if ( pool_stats->restrict_growth && mem_limit_hit )
	      return( NULL );  /* restricted growth pool and we have used too much memory already */

	   if ( pool_stats->restrict_growth )
	      {
	      /* see if we have used too much memory */
	      HSget_vm_stats( &total_mem, &used_mem, NULL );  /* virtual memory statistics */
	      cur_water_mark = (IGRchar *)sbrk( 0 );  /* memory used by Ems */

	      if ( ((total_mem - used_mem) < reserved_tiler_mem) &&
	           (high_water_mark != cur_water_mark) )
	         {
	         /* We have reached the point where we need to check if */
	         /* we have used too much memory.                       */
	         if ( high_water_mark == 0 )
	            {
	            /* This is the first time that the free virtual memory has gone */
	            /* below the tiler reserve => initialize the high water mark    */
	            high_water_mark = cur_water_mark;
	            }
	         else
	            {
	            /* The free virtual memory has already gone below the tiler reserve */
	            /* and the high water mark of Ems has changed => we have hit the    */
	            /* memory limit for restricted growth pools.                        */
	            mem_limit_hit = TRUE;
	            }
	         }
	      }  /* end: if ( pool_stats->restrict_growth ) */

	   if ( (! pool_stats->restrict_growth) ||
	        ((pool_stats->restrict_growth) && (! mem_limit_hit)) )
	      {
	      /* This is not a restricted growth pool or it is a restricted growth pool */
	      /* and we haven't hit the memory limint yet => allocate another pool      */
	      size_wanted = pool_stats->structs_per_pool * pool_stats->struct_size;
	      pool_stats->pool = (*tiling_parms.zmalloc)( 1, size_wanted, &buf_size, NULL );
	      if ( pool_stats->pool )
	         HRsave_pool_address( pool_stats->pool, TRUE );
	      else
	         {
	         pool_stats->pool = (IGRchar *)malloc( size_wanted );
	         while ( (!pool_stats->pool) && (pool_stats->structs_per_pool) )
	            {
	            (pool_stats->structs_per_pool) /= 2;
	            pool_stats->pool = (IGRchar *)malloc( pool_stats->structs_per_pool * pool_stats->struct_size );
	            }

	         HRsave_pool_address( pool_stats->pool, FALSE );
	         }

	      RECORD_NUM_ALLOC( pool_stats );
	      
	      RECORD_POOL_ALLOC( pool_stats );
	      node = pool_stats->pool;
	      pool_stats->left_in_pool = pool_stats->structs_per_pool - 1;
	      (pool_stats->pool) += pool_stats->struct_size;
	      }
	   
	   }  /* end: if ( allocate another pool ) */
	   
	return( node );

	}  /* HRalloc_struct_from_pool */
	

/*--- HRfree_pool_struct ------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HRfree_pool_struct( IGRchar *node,
			 struct HRpool_mem_data *pool_stats )
#else
	static void HRfree_pool_struct( node, pool_stats )

	IGRchar                *node;
	struct HRpool_mem_data *pool_stats;
#endif

/*
DESCRIPTON
	This function returns a structure to a free list.
	
	The structures that are currently supported by this routine
	are "HRenv_record" and "HRsurface_record".
	
	NOTE:  Since this routine does not know the exact type of the
	       structure it is dealing with an assumption must be made
	       when trying to link free structures into the free list.
	       It is assumed that all of the structures managed by this
	       routine have a "next" field that is a pointer used to create
	       a linked-list of the structure and that the "next" field is
	       the first field of the structure.

HISTORY
	S.P. Rogers  07/07/89  Creation Date
*/

	{
	RECORD_FREE( pool_stats );

	/* We can cast "node" to any one of the structures that this  */
	/* function is supposed to work with because we know that the */
	/* first field of all of the structures is the next field.    */
	((struct HRenv_record *)node)->next = (struct HRenv_record *) pool_stats->free_list;
	pool_stats->free_list = node;

	}  /* HRfree_pool_struct */



/***********************************************************************************/


/*---- HRalloc_env_record ------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HRenv_record *HRalloc_env_record(void)
#else
	struct HRenv_record *HRalloc_env_record()
#endif

/*
DESCRIPTION
	Function to allocate an environment record
	
HISTORY
	S.P. Rogers  07/07/89  Creation Date	
*/
	
	{
	struct HRenv_record *env;
	
	env = (struct HRenv_record *) HRalloc_struct_from_pool( &HRenv_manager );
	
	env->next = NULL;

	return( env );
	}  /* HRalloc_env_record */



/*---- HRalloc_surface_record ------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HRsurface_record *HRalloc_surface_record(void)
#else
	struct HRsurface_record *HRalloc_surface_record()
#endif

/*
DESCRIPTION
	Function to allocate a surface record

HISTORY
	S.P. Rogers  07/07/89  Creation Date	
*/

	{
	struct HRsurface_record *surf;

	surf = (struct HRsurface_record *) HRalloc_struct_from_pool( &HRsurface_rec_manager );

	surf->next = NULL;
	
	return( surf );

	}  /* HRalloc_surface_record */


/*---- HRalloc_span_trap ------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HRspan_trapezoid *HRalloc_span_trap(void)
#else
	struct HRspan_trapezoid *HRalloc_span_trap()
#endif

/*
DESCRIPTION
	Function to allocate a phong trapezoid

HISTORY
	S.P. Rogers  07/07/89  Creation Date	
*/

	{
	struct HRspan_trapezoid *trap;

	trap = (struct HRspan_trapezoid *) HRalloc_struct_from_pool( &HRspan_trap_manager );

	if ( ! trap )
	   {
	   HRreclaim_trapezoids();
	   if ( HRspan_trap_manager.free_list )
	      {
	      /* allocate from the free list */
	      RECORD_LIST_ALLOC( &HRspan_trap_manager );
	      trap = (struct HRspan_trapezoid *) HRspan_trap_manager.free_list;

	      HRspan_trap_manager.free_list = (IGRchar *) ((struct HRenv_record *)trap)->next;
	      }
	   }

	if ( trap )
	   {
	   trap->nexty = NULL;
	   trap->nextz = NULL;
	   trap->attr = NULL;
	   }

	return( trap );

	}  /* HRalloc_span_trap */


/*---- HRalloc_span_deltas ------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HRspan_deltas *HRalloc_span_deltas(void)
#else
	struct HRspan_deltas *HRalloc_span_deltas()
#endif

/*
DESCRIPTION
	Function to allocate a span deltas structure

HISTORY
	S.P. Rogers  07/07/89  Creation Date	
*/

	{
	struct HRspan_deltas *deltas;

	deltas = (struct HRspan_deltas *) HRalloc_struct_from_pool( &HRspan_deltas_manager );

	return( deltas );

	}  /* HRalloc_span_deltas */


/*---- HRalloc_trapezoid_uv ------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HRtrapezoid_uv *HRalloc_trapezoid_uv(void)
#else
	struct HRtrapezoid_uv *HRalloc_trapezoid_uv()
#endif

/*
DESCRIPTION
	Function to allocate a span deltas structure

HISTORY
	S.P. Rogers  07/07/89  Creation Date	
*/

	{
	struct HRtrapezoid_uv *deltas;

	deltas = (struct HRtrapezoid_uv *) HRalloc_struct_from_pool( &HRtrapezoid_uv_manager );

	return( deltas );

	}  /* HRalloc_trapezoid_uv */


/*---- HRalloc_texture_interp_parms ------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HRtexture_interp_parms *HRalloc_texture_interp_parms(void)
#else
	struct HRtexture_interp_parms *HRalloc_texture_interp_parms()
#endif

/*
DESCRIPTION
	Function to allocate a span deltas structure

HISTORY
	S.P. Rogers  07/07/89  Creation Date	
*/

	{
	struct HRtexture_interp_parms *deltas;

	deltas = (struct HRtexture_interp_parms *) HRalloc_struct_from_pool( &HRtexture_interp_parms_manager );

	return( deltas );

	}  /* HRalloc_texture_interp_parms */


/*---- HRalloc_texture_list ------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HRtexture_list *HRalloc_texture_list(void)
#else
	struct HRtexture_list *HRalloc_texture_list()
#endif

/*
DESCRIPTION
	Function to allocate a texture list structure

HISTORY
	S.P. Rogers  07/07/89  Creation Date	
*/

	{
	struct HRtexture_list *texture;

	texture = (struct HRtexture_list *) HRalloc_struct_from_pool( &HRtexture_list_manager );

	texture->Fname[0] = '\0';
	texture->mipmap = NULL;

	return( texture );

	}  /* HRalloc_texture_interp_parms */


/*---- HRalloc_span_intersect ------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HRspan_intersect *HRalloc_span_intersect(void)
#else
	struct HRspan_intersect *HRalloc_span_intersect()
#endif

/*
DESCRIPTION
	Function to allocate a span intersection node structure

HISTORY
	S.P. Rogers  07/07/89  Creation Date	
*/

	{
	struct HRspan_intersect *span_intersect;

	span_intersect = (struct HRspan_intersect *) HRalloc_struct_from_pool( &HRspan_intersect_manager );

	return( span_intersect );

	}  /* HRalloc_span_intersect */


/*---- HRfree_env_record ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRfree_env_record( struct HRenv_record *env )
#else
	void HRfree_env_record( env )

	struct HRenv_record *env;
#endif
	
/*
DESCRIPTION
	This function returns an environment record to the free list.
	
HISTORY
	S.P. Rogers  07/07/89
*/

	{
	HRfree_pool_struct((IGRchar *)env, &HRenv_manager );
	}  /* HRfree_env_record */



/*---- HRfree_surface_record ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRfree_surface_record( struct HRsurface_record *surf )
#else
	void HRfree_surface_record( surf )

	struct HRsurface_record *surf;
#endif

/*
DESCRIPTION
	This function returns a surface record to the free list
	
HISTORY
	S.P. Rogers  07/07/89
*/

	{
	HRfree_pool_struct( (IGRchar *)surf, &HRsurface_rec_manager );
	}  /* HRfree_surface_record */


/*---- HRfree_span_trap ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRfree_span_trap( struct HRspan_trapezoid *trap )
#else
	void HRfree_span_trap( trap )

	struct HRspan_trapezoid *trap;
#endif

/*
DESCRIPTION
	This function returns a phong trapezoid to the free list
	
HISTORY
	S.P. Rogers  07/07/89
*/

	{
	HRfree_pool_struct( (IGRchar *)trap, &HRspan_trap_manager );
	}  /* HRfree_span_trap */


/*---- HRfree_span_deltas ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRfree_span_deltas( struct HRspan_deltas *deltas )
#else
	void HRfree_span_deltas( deltas )

	struct HRspan_deltas *deltas;
#endif

/*
DESCRIPTION
	This function returns a span deltas structure to the free list
	
HISTORY
	S.P. Rogers  07/07/89
*/

	{
	HRfree_pool_struct( (IGRchar *)deltas, &HRspan_deltas_manager );
	}  /* HRfree_span_deltas */


/*---- HRfree_trapezoid_uv ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRfree_trapezoid_uv( struct HRtrapezoid_uv *deltas )
#else
	void HRfree_trapezoid_uv( deltas )

	struct HRtrapezoid_uv *deltas;
#endif

/*
DESCRIPTION
	This function returns a span deltas structure to the free list
	
HISTORY
	S.P. Rogers  07/07/89
*/

	{
	HRfree_pool_struct( (IGRchar *)deltas, &HRtrapezoid_uv_manager );
	}  /* HRfree_trapezoid_uv */


/*---- HRfree_texture_interp_parms ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRfree_texture_interp_parms( struct HRtexture_interp_parms *deltas )
#else
	void HRfree_texture_interp_parms( deltas )

	struct HRtexture_interp_parms *deltas;
#endif

/*
DESCRIPTION
	This function returns a span deltas structure to the free list
	
HISTORY
	S.P. Rogers  07/07/89
*/

	{
	HRfree_pool_struct( (IGRchar *)deltas, &HRtexture_interp_parms_manager );
	}  /* HRfree_texture_interp_parms */


/*---- HRfree_texture_list ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRfree_texture_list( struct HRtexture_list *texture )
#else
	void HRfree_texture_list( texture )

	struct HRtexture_list *texture;
#endif

/*
DESCRIPTION
	This function returns a texture list structure to the free list
	
HISTORY
	S.P. Rogers  07/07/89
*/

	{
	HRfree_pool_struct( (IGRchar *)texture, &HRtexture_list_manager );
	}  /* HRfree_texture_list */


/*---- HRfree_span_intersect ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRfree_span_intersect( struct HRspan_intersect *span_intersect )
#else
	void HRfree_span_intersect( span_intersect )
	
	struct HRspan_intersect *span_intersect;
#endif

/*
DESCRIPTION
	This function returns a span intersection_node structure to the free list
	
HISTORY
	S.P. Rogers  07/07/89
*/

	{
	HRfree_pool_struct( (IGRchar *)span_intersect, &HRspan_intersect_manager );
	}  /* HRfree_span_intersect */


