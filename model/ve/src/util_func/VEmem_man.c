
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $

HISTORY:
	Ramana  08/16/95        Added emsdef.h as bsvalues.h is changed.
*/

#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"

#include "igrdp.h"
#include "godef.h"
#include "go.h"

#include "dpstruct.h"

#include "bs.h"
#include "bsvalues.h"

#include "ve.h"
#include "vedef.h"
#include "vemem.h"

/* prototype files */
#include "VEpr_utilfnc.h"

#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsfreesf.h"
#include "bsallgeomcv.h"

#include "emsdef.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void       VEprint_memory_stats __(( void ));

static IGRboolean VEcan_another_saved_int_pool_be_allocated __(( void ));

static void       VEsave_pool_address __((	IGRchar *start_address ));

static IGRchar    *VEalloc_struct_from_pool __((
					struct VEpool_mem_data *pool_stats ));

static void       VEfree_element_geometry __((
					struct VEelement_header *element ));

static void       VEfree_pool_struct __((
				 	IGRchar                 *node,
					struct VEpool_mem_data 	*pool_stats ));

static void       VEfree_pool_struct_list __((
					IGRchar                 *node_list,
					struct VEpool_mem_data  *pool_stats ));

static IGRboolean VEalloc_saved_int_doubles  __((
					struct VEsaved_int_node *node,
					IGRint                  size_wanted ));

#if defined(__cplusplus)
}
#endif

#undef __


#define VE_2K  2048
#define VE_4K  4096
#define VE_60K 61440

/* External functions */
extern char *getenv();

/* External Variables */
extern struct VEsort_record      **VEbuckets;
extern struct VEenv_info         *VEenv_list;
extern struct VEexecution_status VEexec_status;

/* static global data for memory managment */
static struct VEpool_list_node           *pool_list;
static struct VEpool_mem_data            VEelem_mem_manager;
static struct VEpool_mem_data            VEedge_mem_manager;
static struct VEpool_mem_data            VEvisib_node_mem_manager;
static struct VEpool_mem_data            VEtemp_node_mem_manager;
static struct VEpool_mem_data            VEpt_proj_node_mem_manager;
static struct VEpool_mem_data            VEid_list_mem_manager;

static struct VEtemp_curve_storage       VEtemp_curve_mem;
static struct VEunweighted_pole_storage  VEunweighted_pole_mem;
static struct VEcurve_clip_storage       VEcurve_clip_mem;
static struct VEsharp_knot_storage       VEsharp_knot_mem; 


/* global data for saved intersection management */
extern struct VEint_manager VEsaved_ints;

/* static variables used for memory use debugging */
static struct VEpool_mem_data  saved_int_node_stats;
static struct VEpool_mem_data  saved_int_double_stats;

#	define RECORD_POOL_ALLOC( pool_data ) \
	       ((pool_data)->pool_allocs)++;

#	define RECORD_LIST_ALLOC( pool_data ) \
	       ((pool_data)->list_allocs)++;

#	define RECORD_NUM_ALLOC( pool_data )  \
	       ((pool_data)->total_malloced) += ((pool_data)->structs_per_pool);

#	define RECORD_FREE( pool_data )       \
	       ((pool_data)->frees)++;


/*---- VEprint_memory_stats --------------------------------------------------*/

static void VEprint_memory_stats()

/*
NAME
	VEprint_memory_stats (static)

KEYWORD
	debug

DESCRIPTION
	Print out information about VE memory allocation and use.

PARAMETERS
	none

GLOBALS USED
	static memory management structures

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	FILE    *fp;
	IGRchar *expansion;
	IGRint  elem_size, edge_size, visib_node_size, temp_node_size,
	        pt_proj_node_size, id_list_size, int_node_size;
	IGRint  temp_curve_total, curve_clip_total;
	
	/* only write logging file if LOG_VE_MEMORY_USE */
	/* environment variable is defined to be 1      */
	expansion = getenv( "VE_LOG_MEMORY_USE" );
	if ( (expansion == NULL) || (expansion[0] != '1') )
	   return;

	fp = fopen( "/usr/tmp/ve_mem_use", "w" );
	
	elem_size            = sizeof( struct VEelement_header );
	edge_size            = sizeof( struct VEedge_header );
	visib_node_size      = sizeof( struct VEvisib_node );
	temp_node_size       = sizeof( struct VEtemp_node );
	pt_proj_node_size    = sizeof( struct VEpt_proj_node );
	id_list_size         = sizeof( struct VEid_list );
	int_node_size        = sizeof( struct VEsaved_int_node );

	
	fprintf( fp, "\n\n" );
	fprintf( fp, "                   **** VE Memory Management Statistics ****\n\n" );
	
	fprintf( fp, "\nPool Memory Allocation:\n\n" );

	fprintf( fp, "   Element headers:         %5d  * %3d bytes = %6d\n",
		         VEelem_mem_manager.total_malloced, elem_size, 
		         VEelem_mem_manager.total_malloced * elem_size );

	fprintf( fp, "   Edge headers:            %5d  * %3d bytes = %6d\n",
	                 VEedge_mem_manager.total_malloced, edge_size,
	                 VEedge_mem_manager.total_malloced * edge_size );

	fprintf( fp, "   Visib nodes:             %5d  * %3d bytes = %6d\n",
	                 VEvisib_node_mem_manager.total_malloced, visib_node_size,
	                 VEvisib_node_mem_manager.total_malloced * visib_node_size );

	fprintf( fp, "   Temp nodes:              %5d  * %3d bytes = %6d\n",
	                 VEtemp_node_mem_manager.total_malloced, temp_node_size,
	                 VEtemp_node_mem_manager.total_malloced * temp_node_size );

	fprintf( fp, "   Pt Proj nodes:           %5d  * %3d bytes = %6d\n",
	                 VEpt_proj_node_mem_manager.total_malloced, pt_proj_node_size,
	                 VEpt_proj_node_mem_manager.total_malloced * pt_proj_node_size );

	fprintf( fp, "   Id List nodes:           %5d  * %3d bytes = %6d\n",
	                 VEid_list_mem_manager.total_malloced, id_list_size,
	                 VEid_list_mem_manager.total_malloced * id_list_size );

	fprintf( fp, "   Saved Int Nodes:         %5d  * %3d bytes = %6d\n",
	                 saved_int_node_stats.total_malloced, int_node_size,
	                 saved_int_node_stats.total_malloced * int_node_size );

	fprintf( fp, "   Saved Int Doubles:       %5d  * %3d bytes = %6d\n",
	                 saved_int_double_stats.total_malloced, 8,
	                 saved_int_double_stats.total_malloced * 8 );

	temp_curve_total = VEtemp_curve_mem.num_poles +
	                   VEtemp_curve_mem.num_knots +
	                   VEtemp_curve_mem.num_weights;

	fprintf( fp, "   Temp Curve Storage:      %5d  * %3d bytes = %6d\n",
	                 temp_curve_total,
	                 sizeof(IGRdouble),
		         temp_curve_total * sizeof(IGRdouble) );
	                  
	fprintf( fp, "   Unweighted Pole Storage: %5d  * %3d bytes = %6d\n",
	                 VEunweighted_pole_mem.num_poles,
	                 sizeof(IGRdouble),
	                 VEunweighted_pole_mem.num_poles * sizeof(IGRdouble) );

	if ( VEcurve_clip_mem.max_poles == 0 )
	   curve_clip_total = 0;
	else
	   curve_clip_total = (VEcurve_clip_mem.max_poles * 6) +
	                      VEcurve_clip_mem.max_poles + 2;

	fprintf( fp, "   Curve Clip Storage:      %5d  * %3d bytes = %6d\n",
	                 curve_clip_total,
	                 sizeof( IGRdouble ),
	                 curve_clip_total * sizeof(IGRdouble) );

	fprintf( fp, "   Sharp Knot Storage:      %5d  * %3d bytes = %6d\n",
	                 VEsharp_knot_mem.num_u + VEsharp_knot_mem.num_v, sizeof( IGRdouble ),
	                 (VEsharp_knot_mem.num_u + VEsharp_knot_mem.num_v) * sizeof( IGRdouble ) );
	                 

	fprintf( fp, "\nTotal Memory Allocation:  %d\n\n\n",
		         VEelem_mem_manager.total_malloced * elem_size                     +
	                 VEedge_mem_manager.total_malloced * edge_size                     +
	                 VEvisib_node_mem_manager.total_malloced * visib_node_size         +
	                 VEtemp_node_mem_manager.total_malloced * temp_node_size           +
	                 VEpt_proj_node_mem_manager.total_malloced * pt_proj_node_size     +
	                 VEid_list_mem_manager.total_malloced * id_list_size               +
	                 temp_curve_total * sizeof(IGRdouble)                              +
	                 VEunweighted_pole_mem.num_poles * sizeof(IGRdouble)               +
	                 curve_clip_total * sizeof(IGRdouble)                              +
	                 saved_int_node_stats.total_malloced * int_node_size               +
	                 saved_int_double_stats.total_malloced * 8                         +
	                 (VEsharp_knot_mem.num_u + VEsharp_knot_mem.num_v) * sizeof( IGRdouble ) );
	
	fprintf( fp, "Memory Macro Performance:\n\n" );
	fprintf( fp, "                     Pool Allocs    Free List Allocs    Frees\n" );
	fprintf( fp, "                     -----------    ----------------    -----\n" );
	fprintf( fp, "   Element Headers     %5d             %5d         %5d\n",
		         VEelem_mem_manager.pool_allocs,
		         VEelem_mem_manager.list_allocs, VEelem_mem_manager.frees );

	fprintf( fp, "   Edge Headers        %5d             %5d         %5d\n",
		         VEedge_mem_manager.pool_allocs,
		         VEedge_mem_manager.list_allocs, VEedge_mem_manager.frees );

	fprintf( fp, "   Visib Nodes         %5d             %5d         %5d\n",
		         VEvisib_node_mem_manager.pool_allocs,
		         VEvisib_node_mem_manager.list_allocs, VEvisib_node_mem_manager.frees );

	fprintf( fp, "   Temp Nodes          %5d             %5d         %5d\n",
		         VEtemp_node_mem_manager.pool_allocs,
		         VEtemp_node_mem_manager.list_allocs, VEtemp_node_mem_manager.frees );

	fprintf( fp, "   Pt Proj Nodes       %5d             %5d         %5d\n",
		         VEpt_proj_node_mem_manager.pool_allocs,
		         VEpt_proj_node_mem_manager.list_allocs, VEpt_proj_node_mem_manager.frees );

	fprintf( fp, "   Id List Nodes       %5d             %5d         %5d\n",
		         VEid_list_mem_manager.pool_allocs,
		         VEid_list_mem_manager.list_allocs, VEid_list_mem_manager.frees );

	fprintf( fp, "   Saved Int Nodes     %5d             %5d         %5d\n",
		         saved_int_node_stats.pool_allocs,
		         saved_int_node_stats.list_allocs, saved_int_node_stats.frees );

	fclose( fp );
	
	}  /* VEprint_memory_stats */


/*---- VEcan_another_saved_int_pool_be_allocated ------------------------------------------*/

static IGRboolean VEcan_another_saved_int_pool_be_allocated()

/*
NAME
	VEcan_another_saved_int_pool_be_allocated (static)

KEYWORD
	memory_mangement

DESCRIPTION
	This function returns TRUE if it is o.k. to allocate another pool
	of saved intersection list nodes.
	
PARAMETERS
	none

RETURN VALUES
	TRUE - if another saved int pool can be allocated
	FALSE - if one cannot be allocated

GLOBALS USED
	VEsaved_ints

HISTORY
	10/18/88    S.P. Rogers
	   Creation Date
*/

	{
	if ( VEsaved_ints.pools_left > 0 )
	   {
	   VEsaved_ints.pools_left--;
	   return( TRUE );
	   }
	else
	   return( FALSE );
	}  /* VEcan_another_saved_int_pool_be_allocated */
	

/*---- VEsave_pool_address ------------------------------------------*/

static void VEsave_pool_address( start_address )

	IGRchar *start_address;
	
/*
NAME
	VEsave_pool_address (static)

KEYWORD
	memory_mangement

DESCRIPTION
	Save the starting address of an allocated memory pool so that it
	can be freed when processing is finished.

PARAMETERS
	start_address (IN) - the starting address to save

GLOBALS USED
	pool_list (static)

HISTORY
	xx/xx/xx    S.P. Rogers
	    Creation Date
	05/21/92    S.P. Rogers
	    Changed to support an array of saved addresses per node
*/

	{	
	IGRint                  ii;
	struct VEpool_list_node *temp;

	if ( (!pool_list) || (pool_list->num_addr_used == ADDR_PER_POOL_LIST_NODE) )
	   {
	   temp = (struct VEpool_list_node *) malloc( sizeof( struct VEpool_list_node ) );
	   temp->num_addr_used = 0;
	   for ( ii = 0; ii < ADDR_PER_POOL_LIST_NODE; ii++ )
	      temp->start_addr[ii] = NULL;
           temp->next = pool_list;
	   pool_list = temp;
	   }

	pool_list->start_addr[(pool_list->num_addr_used)++] = start_address;
	
	}  /* VEsave_pool_address */
	

/*---- VEinit_memory_management ------------------------------------------*/

void VEinit_memory_management()

/*
NAME
	VEinit_memory_management

KEYWORD
	memory_mangement

DESCRIPTION
	Initialize the global data used by the VE memory management
	macros.
	

PARAMETERS
	none

GLOBALS USED
	VEbuckets
	static memory management structures

HISTORY
	01/23/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRint  ii;
	IGRchar *expansion;


	pool_list = NULL;

	/* allocate element bucket sort array */
	VEbuckets = (struct VEsort_record **) 
	            malloc( sizeof(struct VEsort_record *) * NUM_SORTING_BUCKETS );

	/* initialize element header memory manager */
	VEelem_mem_manager.struct_size       = sizeof( struct VEelement_header );
	VEelem_mem_manager.structs_per_pool  = VE_4K / VEelem_mem_manager.struct_size;
	VEelem_mem_manager.left_in_pool      = 0;
	VEelem_mem_manager.free_list         = NULL;
	VEelem_mem_manager.pool              = NULL;
	VEelem_mem_manager.total_malloced    = 0;
	VEelem_mem_manager.pool_allocs       = 0;
	VEelem_mem_manager.list_allocs       = 0;
	VEelem_mem_manager.frees             = 0;
	
	/* initialize edge header memory manager */
	VEedge_mem_manager.struct_size       = sizeof( struct VEedge_header );
	VEedge_mem_manager.structs_per_pool  = VE_4K / VEedge_mem_manager.struct_size;
	VEedge_mem_manager.left_in_pool      = 0;
	VEedge_mem_manager.free_list         = NULL;
	VEedge_mem_manager.pool              = NULL;
	VEedge_mem_manager.total_malloced    = 0;
	VEedge_mem_manager.pool_allocs       = 0;
	VEedge_mem_manager.list_allocs       = 0;
	VEedge_mem_manager.frees             = 0;

	/* initialize visib node memory manager */
	VEvisib_node_mem_manager.struct_size       = sizeof( struct VEvisib_node );
	VEvisib_node_mem_manager.structs_per_pool  = VE_4K / VEvisib_node_mem_manager.struct_size;
	VEvisib_node_mem_manager.left_in_pool      = 0;
	VEvisib_node_mem_manager.free_list         = NULL;
	VEvisib_node_mem_manager.pool              = NULL;
	VEvisib_node_mem_manager.total_malloced    = 0;
	VEvisib_node_mem_manager.pool_allocs       = 0;
	VEvisib_node_mem_manager.list_allocs       = 0;
	VEvisib_node_mem_manager.frees             = 0;

	/* initialize temp node memory manager */
	VEtemp_node_mem_manager.struct_size       = sizeof( struct VEtemp_node );
	VEtemp_node_mem_manager.structs_per_pool  = VE_4K / VEtemp_node_mem_manager.struct_size;
	VEtemp_node_mem_manager.left_in_pool      = 0;
	VEtemp_node_mem_manager.free_list         = NULL;
	VEtemp_node_mem_manager.pool              = NULL;
	VEtemp_node_mem_manager.total_malloced    = 0;
	VEtemp_node_mem_manager.pool_allocs       = 0;
	VEtemp_node_mem_manager.list_allocs       = 0;
	VEtemp_node_mem_manager.frees             = 0;

	/* initialize pt proj node memory manager */
	VEpt_proj_node_mem_manager.struct_size       = sizeof( struct VEpt_proj_node );
	VEpt_proj_node_mem_manager.structs_per_pool  = VE_4K / VEpt_proj_node_mem_manager.struct_size;
	VEpt_proj_node_mem_manager.left_in_pool      = 0;
	VEpt_proj_node_mem_manager.free_list         = NULL;
	VEpt_proj_node_mem_manager.pool              = NULL;
	VEpt_proj_node_mem_manager.total_malloced    = 0;
	VEpt_proj_node_mem_manager.pool_allocs       = 0;
	VEpt_proj_node_mem_manager.list_allocs       = 0;
	VEpt_proj_node_mem_manager.frees             = 0;

	/* initialize id list memory manager */
	VEid_list_mem_manager.struct_size       = sizeof( struct VEid_list );
	VEid_list_mem_manager.structs_per_pool  = VE_2K / VEid_list_mem_manager.struct_size;
	VEid_list_mem_manager.left_in_pool      = 0;
	VEid_list_mem_manager.free_list         = NULL;
	VEid_list_mem_manager.pool              = NULL;
	VEid_list_mem_manager.total_malloced    = 0;
	VEid_list_mem_manager.pool_allocs       = 0;
	VEid_list_mem_manager.list_allocs       = 0;
	VEid_list_mem_manager.frees             = 0;

	/* initialize saved intersection storage */
	VEsaved_ints.malloc_size        = VE_60K / sizeof( struct VEsaved_int_node );
	VEsaved_ints.left_in_pool       = 0;
	VEsaved_ints.free_list          = NULL;
	VEsaved_ints.pool               = NULL;

	VEsaved_ints.double_malloc_size = VE_60K / sizeof( IGRdouble );
	VEsaved_ints.doubles_left       = 0;
	VEsaved_ints.double_pool        = NULL;
	
	expansion = getenv( "MAX_VE_INT_POOLS" );
	if ( expansion == NULL )
	   VEsaved_ints.pools_left = MAXINT;
	else
	   {
	   sscanf( expansion, "%d", &VEsaved_ints.pools_left );
	   VEsaved_ints.pools_left += 2;
	   if ( VEsaved_ints.pools_left < 2 )
	      VEsaved_ints.pools_left = 2;
	   }
	   
	/* allocate saved intersection bucket sort array*/
	VEsaved_ints.buckets = (struct VEsaved_int_node **)
	                       malloc( sizeof(struct VEsaved_int_node *) * NUM_INT_BUCKETS );
	
	for ( ii = 0; ii < NUM_INT_BUCKETS; ii++ )
	   VEsaved_ints.buckets[ii] = NULL;
	   
	/* initialize temporary curve storage */
	VEtemp_curve_mem.num_poles   = 0;
	VEtemp_curve_mem.poles       = NULL;
	VEtemp_curve_mem.num_knots   = 0;
	VEtemp_curve_mem.knots       = NULL;
	VEtemp_curve_mem.num_weights = 0;
	VEtemp_curve_mem.weights     = NULL;


	/* initialize storage for unweighted poles */
	VEunweighted_pole_mem.num_poles = 0;
	VEunweighted_pole_mem.poles     = NULL;;


	/* initialize curve clipping temporary storage */
	VEcurve_clip_mem.max_poles    = 0;
	VEcurve_clip_mem.int_points   = NULL;
	VEcurve_clip_mem.int_params   = NULL;
	VEcurve_clip_mem.start_params = NULL;
	VEcurve_clip_mem.end_params   = NULL;


	/* initialize sharp knot storage */
	VEsharp_knot_mem.num_u   = 0;
	VEsharp_knot_mem.u_knots = NULL;
	VEsharp_knot_mem.num_v   = 0;
	VEsharp_knot_mem.v_knots = NULL;

	saved_int_node_stats.structs_per_pool        = VEsaved_ints.malloc_size;
	saved_int_node_stats.total_malloced          = 0;
	saved_int_node_stats.pool_allocs             = 0;
	saved_int_node_stats.list_allocs             = 0;
	saved_int_node_stats.frees                   = 0;

	saved_int_double_stats.structs_per_pool      = VEsaved_ints.double_malloc_size;
	saved_int_double_stats.total_malloced        = 0;
	saved_int_double_stats.pool_allocs           = 0;
	saved_int_double_stats.list_allocs           = 0;
	saved_int_double_stats.frees                 = 0;

	}  /* VEinit_memory_management */
		

/*---- VEfree_memory ------------------------------------------------------*/

void VEfree_memory()

/*
NAME
	VEfree_memory

KEYWORD
	memory_mangement

DESCRIPTION
	Deallocate all of the memory that is in all of the pools used
	by Vector Hidden Line

PARAMETERS
	none

GLOBALS USED
	static memory mangement structures

HISTORY
	01/28/87    S.P. Rogers
	   Creation Date
	05/21/92    S.P. Rogers
	    Changed to support an array of saved addresses per pool node
*/

	{
	IGRint                  ii;
	struct VEpool_list_node *cur_node;
	struct VEpool_list_node *temp;
	struct VEenv_info       *temp_env;

	/* free the element bucket sort array */
	free( (IGRchar *) VEbuckets );

	/* free the entries in the environment matrix list */
	while ( VEenv_list )
	   {
	   temp_env = VEenv_list;
	   VEenv_list = VEenv_list->next;
	   free( (IGRchar *) temp_env );
	   }
	   
	/* free the saved intersection bucket array */
	free( (IGRchar *) VEsaved_ints.buckets );

	/* free the allocated memory pools */
	cur_node = pool_list;
	while ( cur_node )
	   {
	   for ( ii = 0; ii < cur_node->num_addr_used; ii++ )
	      free( cur_node->start_addr[ii] );

	   temp = cur_node->next;
	   free( (IGRchar *) cur_node );
	   cur_node = temp;
	   }


	/* free temporary curve storage memory */
	if ( VEtemp_curve_mem.poles )
	   free( (IGRchar *) VEtemp_curve_mem.poles );

	if ( VEtemp_curve_mem.knots )
	   free( (IGRchar *) VEtemp_curve_mem.knots );

	if ( VEtemp_curve_mem.weights )
	   free( (IGRchar *) VEtemp_curve_mem.weights );
	   
	/* free unweighted pole storage */
	if ( VEunweighted_pole_mem.poles )
	   free( (IGRchar *) VEunweighted_pole_mem.poles );

	/* free curve clipping temporary storage */
	if ( VEcurve_clip_mem.max_poles > 0 )
	   {
	   free( (IGRchar *) VEcurve_clip_mem.int_points );
	   free( (IGRchar *) VEcurve_clip_mem.int_params );
	   free( (IGRchar *) VEcurve_clip_mem.start_params );
	   free( (IGRchar *) VEcurve_clip_mem.end_params );
	   }
	   
	/* free sharp knot storage */
	if ( VEsharp_knot_mem.u_knots )
	   free( (IGRchar *) VEsharp_knot_mem.u_knots );

	if ( VEsharp_knot_mem.v_knots )
	   free( (IGRchar *) VEsharp_knot_mem.v_knots );

	VEprint_memory_stats();

	}  /* VEfree_memory */


/*--- VEfree_element_geometry ----------------------------------------------------*/

static void VEfree_element_geometry( element )

	struct VEelement_header *element;

/*
NAME
	VEfree_element_geometry (static)

KEYWORD
	memory_mangement

DESCRIPTION
	Frees the memory allocated for a element.

PARAMETERS
	element (IN) - the element whose geometry is to be freed

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong rc;

	if ( element->type == SURFACE )
	   {
	   if ( element->geom.gmsurf )
	      {
	      element->geom.gmsurf->bspsf->num_boundaries = 0;
	      element->geom.gmsurf->bspsf->bdrys = NULL;

	      if ( element->geom.gmsurf->bspsf )
	         BSfreesf( &rc, element->geom.gmsurf->bspsf );

	      if ( element->geom.gmsurf->sfgen_cv )
	         BSfreecv( &rc, element->geom.gmsurf->sfgen_cv );

	      free( (IGRchar *) element->geom.gmsurf );
	      }
	   }
	else if ( (element->type == CURVE) || (element->type == POINT) )
	   {
	   if ( element->geom.curve )
	      BSfreecv( &rc, element->geom.curve );
	   }

	}  /* VEfree_element_geometry */


/*--- VEalloc_geom_curve ---------------------------------------------------*/

struct BSgeom_bsp_curve *VEalloc_geom_curve( 	IGRshort   order,
						IGRlong    num_poles,
						IGRboolean rational,
						IGRshort   num_boundaries )

/*
NAME
	VEalloc_geom_curve

DESCRIPTION
	This function allocates a geometric curve structure and its
	corresponding bspline curve structure and initialized the
	geometric curve as a general bspline curve.  If order is
	0, then no geometry is allocated.

PARAMETERS
	order (IN) - the order of the bspline curve
	num_poles (IN) - the number of poles in the bspline curve
	rational (IN) - rational flag for the bspline curve
	num_boundaries (IN) - the number of boundaries on the bspline curve

GLOBALS USED
	none

RETURN VALUES
	A pointer to the allocated geometric curve is returned.  If a
	failure occurs, NULL is returned.

HISTORY
	10/13/92    S.P. Rogers
	   Creation Date
*/

	{
	BSrc                    rc;
	struct BSgeom_bsp_curve *gmcurve;

        /* allocate and intialize geometric curve structure */
        BSallgeomcv( &gmcurve, &rc );

	if ( ! gmcurve )
	   return( NULL );

	gmcurve->type = BSGEN_BSP_CV;

	if ( order )
	   {
	   /* allocate memory for and copy curve definition */
	   BSalloccv( order, num_poles, rational, num_boundaries,
	              &gmcurve->bspcv,
	              &rc );

	   if ( ! gmcurve->bspcv )
	      {
	      free( (IGRchar *) gmcurve );
	      gmcurve = NULL;
	      }
           else
              {
	      gmcurve->bscv_flag = TRUE;
              }
	   }

	return( gmcurve );

	}  /* VEalloc_geom_curve */


/*--- VEfree_geom_curve ---------------------------------------------------*/

void VEfree_geom_curve( gmcurve )

	struct BSgeom_bsp_curve *gmcurve;

/*
NAME
	VEfree_geom_curve

DESCRIPTION
	This function frees a geometric curve structure that was
	allocated using the VEalloc_geom_curve() function.

PARAMETERS
	gmcurve (IN) - the geometric curve to free

GLOBALS USED
	none

HISTORY
	10/26/92    S.P. Rogers
	   Creation Date
*/

	{
	BSrc rc;

	if ( ! gmcurve )
	   return;

	if ( gmcurve->bspcv )
	   BSfreecv( &rc, gmcurve->bspcv );

	if ( gmcurve->array1 )
	   free( gmcurve->array1 );

	free( (IGRchar *) gmcurve );

	}  /* VEfree_geom_curve */


/*---- VEget_temp_curve_storage -------------------------------------------*/

void VEget_temp_curve_storage( struct IGRbsp_curve *curve,
                               IGRint              num_poles,
                               IGRint              num_knots,
                               IGRboolean          rational )
	
/*
NAME
	VEget_temp_curve_storage

KEYWORD
	memory_mangement

DESCRIPTION
	This function returns temporary space for the poles, knots and weights
	of a curve.
	
PARAMETERS
	curve (IN/OUT) - the curve structure to assign to the temporary
	                 space to
	num_poles (IN) - the number of poles of temporary storage needed
	num_knots (IN) - the number of knots of temporary storage needed
	rational (IN) - TRUE, if the curve is rational

GLOBALS USED
	VEtemp_curve (static)

NOTES
	The storage returned by this function is temporary and is only
	valid until the next call to this function.  The storage should
	also not be freed.

HISTORY
	09/29/87    S.P. Rogers
	   Creation Date
*/

	{
	/* check the space that is already allocated to see if it is big enough */
	if ( num_poles > VEtemp_curve_mem.num_poles )
	   {
	   if (VEtemp_curve_mem.poles) free( (IGRchar *) VEtemp_curve_mem.poles );
	   VEtemp_curve_mem.num_poles = num_poles;
	   VEtemp_curve_mem.poles = (IGRdouble *) malloc(
	                               VEtemp_curve_mem.num_poles * 3 * sizeof( IGRdouble ) );
	   }

	if ( num_knots > VEtemp_curve_mem.num_knots )
	   {
	   if (VEtemp_curve_mem.knots) free( (IGRchar *) VEtemp_curve_mem.knots );
	   VEtemp_curve_mem.num_knots = num_knots;
	   VEtemp_curve_mem.knots = (IGRdouble *) malloc(
	                               VEtemp_curve_mem.num_knots * sizeof( IGRdouble ) );
	   }
	
	if ( rational )
	   {
	   if ( num_poles > VEtemp_curve_mem.num_weights )
	      {
	      if (VEtemp_curve_mem.weights) free( (IGRchar *) VEtemp_curve_mem.weights );
	      VEtemp_curve_mem.num_weights = num_poles;
	      VEtemp_curve_mem.weights = (IGRdouble *) malloc(
	                                    VEtemp_curve_mem.num_weights * sizeof( IGRdouble ) );
	      }
	   }

	curve->poles   = VEtemp_curve_mem.poles;
	curve->knots   = VEtemp_curve_mem.knots;
	curve->weights = (rational) ? VEtemp_curve_mem.weights : NULL;

	}  /* VEget_temp_curve_storage */
	

/*---- VEget_unweighted_pole_storage -------------------------------------------*/

void VEget_unweighted_pole_storage( num_poles, poles )

	IGRint              num_poles;
	IGRdouble           **poles;

	
/*
NAME
	VEget_unweighted_pole_storage

KEYWORD
	memory_mangement

DESCRIPTION
	This function returns temporary space that is to be used for
	unweighting poles.
	
PARAMETERS
	num_poles (IN) - the number of poles of storage required
	poles (OUT) - pointer to the temporary space

NOTES
	The storage returned by this function is temporary and is only
	valid until the next call to this function.  The storage should
	also not be freed.

GLOBALS USED
	VEunweighted_pole_mem

HISTORY
	10/12/87    S.P. Rogers
	   Creation Date
*/

	{
	/* check the space that is already allocated to see if it is big enough */
	if ( num_poles > VEunweighted_pole_mem.num_poles )
	   {
	   if (VEunweighted_pole_mem.poles) free( (IGRchar *) VEunweighted_pole_mem.poles );
	   VEunweighted_pole_mem.num_poles = num_poles;
	   VEunweighted_pole_mem.poles = (IGRdouble *) malloc(
	   	                    VEunweighted_pole_mem.num_poles * 3 * sizeof( IGRdouble ) );
	   }

	*poles = VEunweighted_pole_mem.poles;

	}  /* VEget_unweighted_pole_storage */
	

/*---- VEget_curve_clip_memory ------------------------------------*/

void VEget_curve_clip_memory( max_poles, int_points, int_params, start_params, end_params )

	IGRint    max_poles;
	IGRdouble **int_points;
	IGRdouble **int_params;
	IGRdouble **start_params;
	IGRdouble **end_params;
	
/*
NAME
	VEget_curve_clip_memory

KEYWORD
	memory_mangement

DESCRIPTION
	This function returns temporary space that is used in the process of
	clipping curves.

PARAMETERS
	max_poles (IN) - maximum number of poles in the set of curves to be
	                 clipped
	int_points (OUT) - temporary array for curve/plane intersection points
	int_params (OUT) - temporary array for curve/plane intersection params
	start_params (OUT) - temporary array for starting parameters
	start_params (OUT) - temporary array for ending parameters

NOTES
	The storage returned by this function is temporary and is only
	valid until the next call to this function.  The storage should
	also not be freed.

GLOBALS USED
	VEcurve_clip_mem (static)

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	if ( max_poles > VEcurve_clip_mem.max_poles )
	   {
	   if ( VEcurve_clip_mem.max_poles > 0 )
	      {
	      free( (IGRchar *) VEcurve_clip_mem.int_points );
	      free( (IGRchar *) VEcurve_clip_mem.int_params );
	      free( (IGRchar *) VEcurve_clip_mem.start_params );
	      free( (IGRchar *) VEcurve_clip_mem.end_params );
	      }
	      
	   VEcurve_clip_mem.max_poles    = max_poles;
	   
	   VEcurve_clip_mem.int_points   = (IGRdouble *)
	                                      malloc( max_poles * sizeof( IGRpoint ) );
	   VEcurve_clip_mem.int_params   = (IGRdouble *)
	                                      malloc( (2 + max_poles) * sizeof( IGRdouble ) );
	   VEcurve_clip_mem.start_params = (IGRdouble *)
	                                      malloc( max_poles * sizeof( IGRdouble ) );
	   VEcurve_clip_mem.end_params   = (IGRdouble *)
	                                      malloc( max_poles * sizeof( IGRdouble ) );
	   }

	*int_points   = VEcurve_clip_mem.int_points;
	*int_params   = VEcurve_clip_mem.int_params;
	*start_params = VEcurve_clip_mem.start_params;
	*end_params   = VEcurve_clip_mem.end_params;	  

	}  /* VEget_curve_clip_memory */
	

/*---- VEget_sharp_knot_storage -------------------------------------------*/

void VEget_sharp_knot_storage( num_u, num_v, u_knots, v_knots )

	IGRint              num_u;
	IGRint              num_v;
	IGRdouble           **u_knots;
	IGRdouble           **v_knots;

/*
NAME
	VEget_sharp_knot_storage

KEYWORD
	memory_management

DESCRIPTION
	This function returns temporary space that is to be used for
	finding the sharp knots of a surface.
	
PARAMETERS
	num_u (IN) - number of u knots on surface
	num_v (IN) - number of v knots on surface
	u_knots (OUT) - temporary array of u sharp knots
	v_knots (OUT) - temporary array of v sharp knots
	
NOTES
	The storage returned by this function is temporary and is only
	valid until the next call to this function.  The storage should
	also not be freed.

GLOBALS USED
	VEsharp_knot_mem

HISTORY
	09/21/88    S.P. Rogers
	   Creation Date
*/

	{
	/* check the space that is already allocated to see if it is big enough */
	if ( num_u > VEsharp_knot_mem.num_u )
	   {
	   if (VEsharp_knot_mem.u_knots) free( (IGRchar *) VEsharp_knot_mem.u_knots );
	   VEsharp_knot_mem.num_u = num_u;
	   VEsharp_knot_mem.u_knots = (IGRdouble *) malloc( num_u * sizeof( IGRdouble ) );
	   }

	if ( num_v > VEsharp_knot_mem.num_v )
	   {
	   if (VEsharp_knot_mem.v_knots) free( (IGRchar *) VEsharp_knot_mem.v_knots );
	   VEsharp_knot_mem.num_v = num_v;
	   VEsharp_knot_mem.v_knots = (IGRdouble *) malloc( num_v * sizeof( IGRdouble ) );
	   }

	*u_knots = VEsharp_knot_mem.u_knots;
	*v_knots = VEsharp_knot_mem.v_knots;

	}  /* VEget_sharp_knot_storage */


/***********************************************************************************/

	/* GENERIC POOL MEMORY ALLOCATION/DEALLOCATION ROUTINES */
	

/*--- VEalloc_struct_from_pool ------------------------------------------*/

static IGRchar *VEalloc_struct_from_pool( pool_stats )

	struct VEpool_mem_data *pool_stats;
	
/*
NAME
	VEalloc_struct_from_pool (static)

KEYWORD
	memory_management

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
	are "VEelement_header", "VEedge_header", "VEvisib_node",
	"VEtemp_node", "VEpt_proj_node", and "VEid_list".
	
PARAMETERS
	pool_stats (IN) - the pool from which the structure is to be allocated

NOTES
	Since this routine does not know the exact type of the
	structure it is dealing with an assumption must be made
	when trying to get a structure from the free list. It is
	assumed that all of the structures managed by this routine
	save a "next" field that is a pointer used to create a
	linked-list of the structure and that the "next" field is
	the first field of the structure.
	       
ALGORITHM
	If there are structures on the free list,
	   one of them is returned
	Else if there are structures left in the pool,
	 one of them is returned
	Else
	   a new pool of structures is allocated and a structure
	   from the pool is returned.

GLOBALS USED
	none

HISTORY
	11/26/88    S.P. Rogers
	   Creation Date	
*/

	{
	IGRchar *node;
	
	if ( pool_stats->free_list )
	   {
	   /* allocate from the free list */
	   RECORD_LIST_ALLOC( pool_stats );
	   node = pool_stats->free_list;

	   /* We can cast "node" to any one of the structures that this  */
	   /* function is supposed to work with because we know that the */
	   /* first field of all of the structures is the next field.    */
	   pool_stats->free_list = (IGRchar *) ((struct VEelement_header *) node)->next;
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
	   /* allocate another pool */
	   pool_stats->pool = (IGRchar *) malloc( pool_stats->structs_per_pool * pool_stats->struct_size );

	   /* if malloc failed, keep trying to allocate pools */
	   /* that are one half the size                      */
	   while ( (pool_stats->structs_per_pool) && (! pool_stats->pool) )
	      {
	      (pool_stats->structs_per_pool) /= 2;
	      pool_stats->pool = (IGRchar *) malloc( pool_stats->structs_per_pool *
	                                             pool_stats->struct_size );
	      }

	   if ( ! pool_stats->pool )
	      return( NULL );

	   RECORD_NUM_ALLOC( pool_stats );
	   VEsave_pool_address( pool_stats->pool );
	   
	   RECORD_POOL_ALLOC( pool_stats );
	   node = pool_stats->pool;
	   pool_stats->left_in_pool = pool_stats->structs_per_pool - 1;
	   (pool_stats->pool) += pool_stats->struct_size;
	   }
	   
	return( node );

	}  /* VEalloc_struct_from_pool */
	

/*--- VEfree_pool_struct ------------------------------------------*/

static void VEfree_pool_struct( node, pool_stats )

	IGRchar                *node;
	struct VEpool_mem_data *pool_stats;

/*
NAME
	VEfree_pool_struct (static)

KEYWORD
	memory_management

DESCRIPTION
	This function returns a structure to a free list.
	
	The structures that are currently supported by this routine
	are "VEelement_header", "VEedge_header", "VEvisib_node",
	"VEtemp_node", "VEpt_proj_node", and "VEid_list".
	
	NOTE:  Since this routine does not know the exact type of the
	       structure it is dealing with an assumption must be made
	       when trying to link free structures into the free list.
	       It is assumed that all of the structures managed by this
	       routine have a "next" field that is a pointer used to create
	       a linked-list of the structure and that the "next" field is
	       the first field of the structure.

PARAMETERS
	node (IN) - the structure to free
	pool_stats (IN) - the pool the structure is to be returned to

GLOBALS USED
	none

HISTORY
	11/26/88    S.P. ROgers
	   Creation Date
*/

	{
	RECORD_FREE( pool_stats );

	/* We can cast "node" to any one of the structures that this  */
	/* function is supposed to work with because we know that the */
	/* first field of all of the structures is the next field.    */
	((struct VEelement_header *)node)->next = (struct VEelement_header *) pool_stats->free_list;
	pool_stats->free_list = node;

	}  /* VEfree_pool_struct_list */


/*--- VEfree_pool_struct_list ------------------------------------------*/

static void VEfree_pool_struct_list( node_list, pool_stats )

	IGRchar                *node_list;
	struct VEpool_mem_data *pool_stats;

/*
NAME
	VEfree_pool_struct_list (static)

KEYWORD
	memory_management

DESCRIPTION
	This function returns a list of structures to a free list.
	
	The structures that are currently supported by this routine
	are "VEelement_header", "VEedge_header", "VEvisib_node",
	"VEtemp_node", "VEpt_proj_node", and "VEid_list".
	
	NOTE:  Since this routine does not know the exact type of the
	       structure it is dealing with an assumption must be made
	       when trying to link free structures into the free list.
	       It is assumed that all of the structures managed by this
	       routine have a "next" field that is a pointer used to create
	       a linked-list of the structure and that the "next" field is
	       the first field of the structure.

PARAMETERS
	node_list (IN) - the list of structures to free
	pool_stats (IN) - the pool to return the structures to

GLOBALS USED
	none

HISTORY
	11/26/88    S.P. Rogers
	   Creation Date
*/

	{
	struct VEelement_header *temp;
	
	if ( node_list == NULL ) return;
	
	temp = (struct VEelement_header *) node_list;
	while ( temp->next )
	   {
	   RECORD_FREE( pool_stats );
	   temp = temp->next;
	   }

	RECORD_FREE( pool_stats );
	temp->next = (struct VEelement_header *) pool_stats->free_list;
	pool_stats->free_list = node_list;

	}  /* VEfree_pool_struct_list */

/***********************************************************************************/


/*---- VEalloc_element_header ------------------------------------*/

struct VEelement_header *VEalloc_element_header()

/*
NAME
	VEalloc_element_header

KEYWORD
	memory_management

DESCRIPTION
	Function to allocate an element header
	
PARAMETERS
	none

RETURN VALUES
	A pointer to the allocated element header is returned

NOTES
	The element header allocated by this function should
	be freed by VEfree_element_header().

GLOBALS USED
	VEelem_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date	
*/
	
	{
	struct VEelement_header *elem;
	
	elem = (struct VEelement_header *) VEalloc_struct_from_pool( &VEelem_mem_manager );
	
	if ( ! elem )
	   return( NULL );

	elem->flags = 0;

	elem->geom.curve = NULL;
	elem->edges      = NULL;
	elem->next       = NULL;
	elem->env        = NULL;

	return( elem );
	}  /* VEalloc_element_header */


/*---- VEalloc_edge_header ------------------------------------*/

struct VEedge_header *VEalloc_edge_header()

/*
NAME
	VEalloc_edge_header

KEYWORD
	memory_management

DESCRIPTION
	Function to allocate an edge header
	
PARAMETERS
	none

RETURN VALUES
	A pointer to the allocated edge header is returned

NOTES
	The edge header allocated by this function should
	be freed by VEfree_edge_header().

GLOBALS USED
	VEedge_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date	
*/

	{
	struct VEedge_header *edge;

	edge = (struct VEedge_header *) VEalloc_struct_from_pool( &VEedge_mem_manager );

	if ( ! edge )
	   return( NULL );

	edge->gm_curve3d      = NULL;
	edge->gm_curve2d      = NULL;
	edge->stroked_gmcurve = NULL;
	edge->visib_list      = NULL;
	edge->temp_list       = NULL;
	edge->next            = NULL;
	edge->sh_spans        = NULL;
	edge->shared_edge     = NULL;
	edge->shared_elem     = NULL;

	edge->edge_id       = 0;
	edge->saved_cvcv_id = 0;
	edge->status        = 0;
	edge->num_sh_spans  = 0;

	return( edge );
	}  /* VEalloc_edge_header */


/*---- VEalloc_visib_node ------------------------------------*/

struct VEvisib_node *VEalloc_visib_node( u_val )

	IGRdouble u_val;
/*
NAME
	VEalloc_visib_node

KEYWORD
	memory_management

DESCRIPTION
	Function to allocate a visibility node
	
PARAMETERS
	u_val (IN) - parameter to initialize the node with

RETURN VALUES
	A pointer to the allocated visib node is returned

NOTES
	The visib node allocated by this function should
	be freed by VEfree_visib_node().

GLOBALS USED
	VEvisib_node_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date	
*/

	{
	struct VEvisib_node *node;

	node = (struct VEvisib_node *) VEalloc_struct_from_pool( &VEvisib_node_mem_manager );
	
	if ( ! node )
	   return( NULL );

	node->u          = u_val;
	node->next       = NULL;
	node->visib      = UNKNOWN;

	return( node );
	}  /* VEalloc_visib_node */


/*---- VEalloc_temp_node ---------------------------------------*/

struct VEtemp_node *VEalloc_temp_node( u_val )

	IGRdouble u_val;
/*
NAME
	VEalloc_temp_node

KEYWORD
	memory_management

DESCRIPTION
	Function to allocate a temp node
	
PARAMETERS
	u_val (IN) - parameter to initialize the node with

RETURN VALUES
	A pointer to the allocated temp node is returned

NOTES
	The temp node allocated by this function should
	be freed by VEfree_temp_node().

GLOBALS USED
	VEtemp_node_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date	
*/

	{
	struct VEtemp_node *node;

	node = (struct VEtemp_node *) VEalloc_struct_from_pool( &VEtemp_node_mem_manager );
	
	if ( ! node )
	   return( NULL );

	node->u          = u_val;
	node->next       = NULL;
	node->prev_visib = UNKNOWN;
	node->next_visib = UNKNOWN;
	node->status     = 0;

	return( node );
	}  /* VEalloc_temp_node */


/*---- VEalloc_pt_proj_node ---------------------------------------*/

struct VEpt_proj_node *VEalloc_pt_proj_node()

/*
NAME
	VEalloc_pt_proj_node

KEYWORD
	memory_management

DESCRIPTION
	Function to allocate a point projection node
	
PARAMETERS
	none

RETURN VALUES
	A pointer to the allocated point proj node is returned

NOTES
	The point proj node allocated by this function should
	be freed by VEfree_pt_proj_node().

GLOBALS USED
	VEpt_proj_node_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date	
*/

	{
	struct VEpt_proj_node *node;

	node = (struct VEpt_proj_node *) VEalloc_struct_from_pool( &VEpt_proj_node_mem_manager );
	
	if ( ! node )
	   return( NULL );

	node->next      = NULL;
	node->temp_node = NULL;
	return( node );
	}  /* VEalloc_pt_proj_node */


/*---- VEalloc_id_list_node ---------------------------------------*/

struct VEid_list *VEalloc_id_list_node()

/*
NAME
	VEalloc_id_list

KEYWORD
	memory_management

DESCRIPTION
	Function to allocate an id list node
	
PARAMETERS
	none

RETURN VALUES
	A pointer to the allocated id list node is returned

NOTES
	The id list node allocated by this function should
	be freed by VEfree_id_list_node().

GLOBALS USED
	VEid_list_mem_manager (static)

HISTORY
	09/23/87    S.P. Rogers
	   Creation Date	
*/

	{
	struct VEid_list *node;

	node = (struct VEid_list *) VEalloc_struct_from_pool( &VEid_list_mem_manager );

	if ( ! node )
	   return( NULL );

	node->next = NULL;

	return( node );
	}  /* VEalloc_id_list_node */


/*---- VEalloc_saved_int_doubles ---------------------------------------------*/

static IGRboolean VEalloc_saved_int_doubles ( node, size_wanted )

	struct VEsaved_int_node *node;
	IGRint                   size_wanted;
	
/*
NAME
	VEalloc_saved_int_doubles (static)

KEYWORD
	memory_management

DESCRIPTION
	This function allocates the array of doubles required to save a
	curve/curve intersection and associates with a saved intersection
	node.  It returns TRUE if it succeeds in allocating and FALSE otherwise.

ALGORITHM
	If the pool of doubles has enough doubles left in it,
	   the array is allocated from the pool
	Else if another pool of doubles can be allocated,
	   a new pool is allocated and the array is allocated from the pool.
	      
PARAMETERS
	node (IN/OUT) - the saved int node to receive the space
	size_wanted (IN) - the size wanted for the saved int node buffer

RETURN VALUES
	TRUE - if the allocation succeeded
	FALSE - if the allocation failed

GLOBALS USED
	VEsaved_ints

HISTORY
	01/29/89  S.P. Rogers
	   Creation Date
*/

	{
	struct VEsaved_int_node *temp_node;
	
	if ( size_wanted == 0 )
	   {
	   node->buffer_size = 0;
	   node->buffer = NULL;
	   }
	else if ( size_wanted <= VEsaved_ints.doubles_left )
	   {
	   /* allocate doubles from pool */
	   node->buffer_size = size_wanted;
	   node->buffer = VEsaved_ints.double_pool;
	   VEsaved_ints.doubles_left -= size_wanted;

	   /* adjust double pool pointer */
	   if ( VEsaved_ints.doubles_left > 0 )
	      VEsaved_ints.double_pool += size_wanted;
	   else
	      {
	      VEsaved_ints.doubles_left = 0;
	      VEsaved_ints.double_pool  = NULL;
	      }
	   }
	else if ( VEcan_another_saved_int_pool_be_allocated() )
	   {
	   if ( VEsaved_ints.doubles_left > 0 )
	      {
	      /* attach the rest of this  buffer to a node on the free list  */
	      /* that doesn't have a buffer so that this memory will be used */
	      temp_node = VEsaved_ints.free_list;
	      while ( temp_node )
	         {
	         if ( temp_node->buffer_size == 0 )
	            {
	            temp_node->buffer_size = VEsaved_ints.doubles_left;
	            temp_node->buffer = VEsaved_ints.double_pool;
	            break;
	            }
	         temp_node = temp_node->next;
	         }  /* end: while */

	      }  /* end: if ( VEsaved_ints.doubles_left > 0 ) */

	   /* allocate another pool of doubles */
	   VEsaved_ints.double_pool = (IGRdouble *) malloc( VEsaved_ints.double_malloc_size *
	                                                    sizeof( IGRdouble) );

	   if ( VEsaved_ints.double_pool == NULL )
	      {
	      /* malloc failed => return FALSE */
	      fprintf( stderr, "VEmem_man:  Allocation of saved int double pool failed\n" );
	      VEsaved_ints.doubles_left = 0;
	      VEsaved_ints.pools_left = 0;
	      return( FALSE );
	      }
	   else
	      {
	      RECORD_NUM_ALLOC( &saved_int_double_stats );
	      VEsave_pool_address( (IGRchar *) VEsaved_ints.double_pool );

	      node->buffer = VEsaved_ints.double_pool;
	      node->buffer_size = size_wanted;

	      /* adjust double pool pointer */
	      VEsaved_ints.double_pool += size_wanted;
	      VEsaved_ints.doubles_left = VEsaved_ints.double_malloc_size - size_wanted;
	      }
	   }
	else
	   {
	   /* couldn't allocate a pool of doubles because we have */
	   /* allocated too many already.                         */
	   return( FALSE );
	   }
	   	
	return( TRUE );
	
	}  /* VEalloc_saved_int_doubles */

	
/*---- VEalloc_saved_int_node ---------------------------------------------*/

struct VEsaved_int_node *VEalloc_saved_int_node( num_int, num_over, bucket_no )

	IGRint num_int;
	IGRint num_over;
	IGRint bucket_no;
	
/*
NAME
	VEalloc_saved_int_node

KEYWORD
	memory_management

DESCRIPTION
	This function allocates a node that is used to store curve/curve
	intersection data.
	
PARAMETERS
	num_int (IN) - number of intersections to be saved
	num_over (IN) - number of overlaps to be saved
	bucket_no (IN) - the bucket that the saved int node will be stored in

ALGORITHM
	If there is a node on the free list whose double buffer will be at
	least half used,
	   it is allocated

	Else if there are nodes left in the pool,
	   one of them is allocated

	Else if another pool can be allocated,
	   a pool is allocated and a node from the pool is allocated
	      
	Else
	   a node that has already been allocated will be cannibalized
	   for use if it appears in a bucket with a smaller index than
	   the current intersection and its double buffer will be at 
	   least half used
	Else
	   NULL will be returned signifying no node could be allocated

RETURN VALUES
	A pointer to the allocated saved int node is returned

NOTES
	The saved int node allocated by this function should
	be freed by VEfree_saved_int_node().

GLOBALS USED
	VEexec_status
	VEsaved_ints
	saved_int_node_stats (static)

HISTORY
	11/06/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRint                  size_wanted;
	IGRint                  bucket;
	struct VEsaved_int_node *prev;
	struct VEsaved_int_node *node;
	
	node = NULL;
	size_wanted = 2 * num_int + 4 * num_over;
	if ( size_wanted > VEsaved_ints.double_malloc_size )
	   {
	   /* trying to save more than a pool worth of doubles */
	   VEexec_status.VEint_save_denied = TRUE;
	   return( NULL );
	   }

	if ( VEsaved_ints.free_list )
	   {
	   /* find a suitable node on the free list */
	   prev = NULL;
	   node = VEsaved_ints.free_list;
	   while ( node )
	      {
	      if ( (size_wanted <= node->buffer_size) &&
	           (size_wanted >= (node->buffer_size * 0.5) ) )
	         {
	         RECORD_LIST_ALLOC( &saved_int_node_stats );

	         /* remove node from free list */
	         if ( prev == NULL )
	            VEsaved_ints.free_list = node->next;
	         else
	           prev->next = node->next;

	         break;
	         }
	         
	      prev = node;
	      node = node->next;
	      }
	      
	   }  /* end if ( VEsaved_ints.free_list ) */

	if ( node == NULL )
	   {
	   if ( VEsaved_ints.left_in_pool != 0 )
	      {
	      /* allocate a saved int node from the pool */
	      RECORD_POOL_ALLOC( &saved_int_node_stats );
	      node = VEsaved_ints.pool;
	      VEsaved_ints.pool++;
	      VEsaved_ints.left_in_pool--;
	      node->buffer_size = -1;
	      }
	   else if ( VEcan_another_saved_int_pool_be_allocated() )
	      {
	      /* allocate a new pool */
	      VEsaved_ints.pool = (struct VEsaved_int_node *) malloc(
	                                         VEsaved_ints.malloc_size *
	                                         sizeof( struct VEsaved_int_node ) );

	      if ( VEsaved_ints.pool == NULL )
	         {
	         /* malloc failed => indicate that an intersection couldn't */
	         /* be saved and set the number of saved int pools left to  */
	         /* allocate to ZERO so we wont attempt to allocate more    */
	         fprintf( stderr, "VEmem_man:  Allocation of saved int node pool failed\n" );
	         VEsaved_ints.pools_left = 0;
	         }
	      else
	         {
	         RECORD_NUM_ALLOC( &saved_int_node_stats );
	         VEsave_pool_address( (IGRchar *) VEsaved_ints.pool );

	         RECORD_POOL_ALLOC( &saved_int_node_stats );
	         node = VEsaved_ints.pool;
	         VEsaved_ints.pool++;
	         VEsaved_ints.left_in_pool = VEsaved_ints.malloc_size - 1;
	         node->buffer_size = -1;
	         }
	      }

	   }  /* end: if ( node == NULL ) */
	   
	if ( node == NULL )
	   {
	   /* For some reason we couldn't get a node => try to cannibalize one  */
	   /* from a bucket that is lower than this one.  Since we are stealing */
	   /* a node that was already in use, we must set the intersection save */
	   /* denied flag so the saved intersections will be freed properly.    */
	   VEexec_status.VEint_save_denied = TRUE;

	   for ( bucket = 0; bucket <= bucket_no; bucket++ )
	      {
	      if ( VEsaved_ints.buckets[bucket] )
	         {
	         prev = NULL;
	         node = VEsaved_ints.buckets[bucket];
	         while ( node )
	            {
	            if ( (size_wanted <= node->buffer_size) &&
	                 (size_wanted >= (node->buffer_size * 0.5)) )
	               {
	               /* suitable node => cannibalize it */
	               if ( prev == NULL )
	                  VEsaved_ints.buckets[bucket] = node->next;
	               else
	                  prev->next = node->next;

	               break;
	               }
	            else
	               {
	               prev = node;
	               node = node->next;
	               }
	            }  /* end: while */

	         if ( node )
	            break;

	         }  /* end: if ( VEsaved_ints ... ) */

	      }  /* end: for */

	   }  /* end: if ( node == NULL ) */
	   
	if ( node )
	   {
	   if ( (node->buffer_size >= 0) || (VEalloc_saved_int_doubles(node, size_wanted) ) )
	      {
	      /* node has double array assigned to it => it is o.k. to return */
	      node->next = NULL;
	      }
	   else
	      {
	      /* return node to free list because we couldn't get required doubles */
	      VEexec_status.VEint_save_denied = TRUE;
	      node->buffer_size = 0;
	      node->buffer = NULL;
	      node->next = VEsaved_ints.free_list;
	      VEsaved_ints.free_list = node;
	      node = NULL;
	      }
	   }
	
	return( node );

	}  /* VEalloc_saved_int_node */


/*---- VEfree_saved_int_node ----------------------------------------------*/

void VEfree_saved_int_node( node )

	struct VEsaved_int_node *node;
	
/*
NAME
	VEfree_saved_int_node

KEYWORD
	memory_management

DESCRIPTION
	This function returns a saved intersection node to the free list
	
PARAMETERS
	node (IN) - the saved int node to free

GLOBALS USED
	VEsaved_ints
	saved_int_node_stats (static)

NOTES
	The saved int node freed by this function should have
	been allocated by VEalloc_saved_int_node().

HISTORY
	11/06/87    S.P. Rogers
	   Creation Date
*/

	{
	RECORD_FREE( &saved_int_node_stats );
	node->next = VEsaved_ints.free_list;
	VEsaved_ints.free_list = node;
	}  /* VEfree_saved_int_node */


/*---- VEfree_element_header ----------------------------------------------*/

void VEfree_element_header( elem )

	struct VEelement_header *elem;
	
/*
NAME
	VEfree_element_header

KEYWORD
	memory_management

DESCRIPTION
	This function returns an element header to the free list.
	It also frees the geometry that is associated with the element.
	
PARAMETERS
	elem (IN) - the element header to free

NOTES
	The element header freed by this function should have
	been allocated by VEalloc_element_header().

GLOBALS USED
	VEelem_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date
*/

	{
	/* free the geometry associated with this element */
	VEfree_element_geometry( elem );
	   
	VEfree_pool_struct( (IGRchar *)elem, &VEelem_mem_manager );
	}  /* VEfree_element_header */


/*---- VEfree_edge_header ----------------------------------------------*/

void VEfree_edge_header( edge )

	struct VEedge_header *edge;

/*
NAME
	VEfree_edge_header

KEYWORD
	memory_management

DESCRIPTION
	This function returns an edge header to the free list
	It also frees the curve definition(s) associated with the edge and
	the self-hidden start/end point array.
	
PARAMETERS
	edge (IN) - the edge header to free

NOTES
	The edge header freed by this function should have
	been allocated by VEalloc_edge_header().

GLOBALS USED
	VEedge_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date
*/

	{
	VEfree_geom_curve( edge->gm_curve3d );
	VEfree_geom_curve( edge->gm_curve2d );
	VEfree_geom_curve( edge->stroked_gmcurve );

	if ( edge->sh_spans )
	   free( (IGRchar *) edge->sh_spans );

	VEfree_pool_struct( (IGRchar *)edge, &VEedge_mem_manager );
	}  /* VEfree_edge_header */


/*---- VEfree_visib_node ----------------------------------------------*/

void VEfree_visib_node( node )

	struct VEvisib_node *node;

/*
NAME
	VEfree_visib_node

KEYWORD
	memory_management

DESCRIPTION
	This function returns a visibility node to the free list
	
PARAMETERS
	node (IN) - the visib node to free

NOTES
	The visib node freed by this function should have
	been allocated by VEalloc_visib_node().

GLOBALS USED
	VEvisib_node_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date
*/

	{
	VEfree_pool_struct( (IGRchar *)node, &VEvisib_node_mem_manager );
	}  /* VEfree_visib_node */
	

/*---- VEfree_visib_node_list ----------------------------------------*/

void VEfree_visib_node_list( node_list )

	struct VEvisib_node *node_list;
	
/*
NAME
	VEfree_visib_node_list

KEYWORD
	memory_management

DESCRIPTION
	This function returns a list of visibility nodes to the free list
	
PARAMETERS
	node_list (IN) - the visib node list to free

NOTES
	The nodes in the visib list freed by this function should have
	been allocated by VEalloc_visib_node().

GLOBALS USED
	VEvisib_node_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date
*/

	{
	VEfree_pool_struct_list( (IGRchar *)node_list, &VEvisib_node_mem_manager );
	}  /* VEfree_visib_node_list */


/*---- VEfree_temp_node ----------------------------------------------*/

void VEfree_temp_node( node )

	struct VEtemp_node *node;

/*
NAME
	VEfree_temp_node

KEYWORD
	memory_management

DESCRIPTION
	This function returns a temp node to the free list
	
PARAMETERS
	node (IN) - the temp node to free

NOTES
	The temp node freed by this function should have
	been allocated by VEalloc_temp_node().

GLOBALS USED
	VEtemp_node_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	    Creation Date
*/

	{
	VEfree_pool_struct( (IGRchar *)node, &VEtemp_node_mem_manager );
	}  /* VEfree_temp_node */


/*---- VEfree_temp_node_list ----------------------------------------*/

void VEfree_temp_node_list( node_list )

	struct VEtemp_node *node_list;
	
/*
NAME
	VEfree_temp_node_list

KEYWORD
	memory_management

DESCRIPTION
	This function returns a list of temp nodes to the free list
	
PARAMETERS
	node_list (IN) - the temp node list to free

NOTES
	The nodes in the temp list freed by this function should have
	been allocated by VEalloc_temp_node().

GLOBALS USED
	VEtemp_node_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date
*/

	{
	VEfree_pool_struct_list( (IGRchar *)node_list, &VEtemp_node_mem_manager );
	}  /* VEfree_temp_node_list */


/*---- VEfree_pt_proj_node ----------------------------------------------*/

void VEfree_pt_proj_node( node )

	struct VEpt_proj_node *node;

/*
NAME
	VEfree_pt_proj_node

KEYWORD
	memory_management

DESCRIPTION
	This function returns a point proj node to the free list
	
PARAMETERS
	node (IN) - the point proj node to free

NOTES
	The point proj node freed by this function should have
	been allocated by VEalloc_pt_proj_node().

GLOBALS USED
	VEpt_proj_node_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date
*/

	{
	VEfree_pool_struct( (IGRchar *)node, &VEpt_proj_node_mem_manager );
	}  /* VEfree_pt_proj_node */


/*---- VEfree_pt_proj_node_list ----------------------------------------*/

void VEfree_pt_proj_node_list( node_list )

	struct VEpt_proj_node *node_list;
	
/*
NAME
	VEfree_pt_proj_node_list

KEYWORD
	memory_management

DESCRIPTION
	This function returns a list of temp nodes to the free list
	
PARAMETERS
	node_list (IN) - the point proj node list to free

NOTES
	The nodes in the point proj list freed by this function
	should have been allocated by VEalloc_pt_proj_node().

GLOBALS USED
	VEpt_proj_node_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	   Creation Date
*/

	{
	VEfree_pool_struct_list( (IGRchar *)node_list, &VEpt_proj_node_mem_manager );
	}  /* VEfree_pt_proj_node_list */


/*---- VEfree_id_list_node ----------------------------------------------*/

void VEfree_id_list_node( node )

	struct VEid_list *node;

/*
NAME
	VEfree_id_list_node

KEYWORD
	memory_management

DESCRIPTION
	This function returns an id list node to the free list
	
PARAMETERS
	node (IN) - the id list node to free

NOTES
	The is list node freed by this function should have
	been allocated by VEalloc_id_list_node().

GLOBALS USED
	VEid_list_mem_manager (static)

HISTORY
	08/17/87    S.P. Rogers
	    Creation Date
*/

	{
	VEfree_pool_struct( (IGRchar *)node, &VEid_list_mem_manager );
	}  /* VEfree_id_list_node */
