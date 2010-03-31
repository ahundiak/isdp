 
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/


#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSe2_mesher.h"

#include "wl.h"

#include "hsdisplay.h"
#include "HSpr_tiler_f.h" 

/*------------------------------
 * for functions
 *     HSdisplay_memory_realloc_message
 *     HSerase_memory_realloc_message
 *     HSget_vm_stats
 */
 
#include "HSpr_co_func.h"

/*------------------------------*/



/*
 *  HSURF Big Buffer Memory Management
 *
 *     The routines in this file are designed to handle the 
 *     HSURF Big Buffer memory.  Users of this memory will be
 *
 *     o  Basic Shading
 *        o  for Zbuffer
 *        o  for Image Buffer
 *
 *     o  Create Rendering
 *        o  for trapezoids
 *        o  for MipMaps
 *
 *     o  LVHL
 *        o  for Zbuffer
 *        o  for Curve Pools
 *
 *
 *  Entry Points
 *
 *     HMinit()
 *     HMallocate()
 *     HMreallocate()
 *     HMfree()
 *     HMdispose()
 *
 *  Change History
 *
 *     Mar 14, 1991:   Initial Creation (ML)
 *
 */     
 

/* ==================== Constants ==================== */

/*
 *  modes
 */
 
#define	NUM_MODES	3
#define	SHADING		0
#define	RENDERING	1
#define	LVHL		2

/*
 * chunk manager pool node list index's
 */
 
#define	ROOT		0
#define	FREE		1
#define USED		0

/*
 *  debugging
 */
 
#define	DEBUG		0
#define DEBUG_MEMORY	0

#ifndef ENV5
#define MAX_WINDOW   40
#endif

/* =================== Structures ==================== */

/*
 *  structure is used for memory management
 *
 *     num_bytes : total bytes in the chunk
 *     offset    : byte offset from the top of the big buffer
 *     chunk     : pointer into the big buffer
 *     next      : next chunk manager structure
 *
 *  for each mode there will be two of these list..one for
 *  free chunks and one for assigned chunks
 */
 
struct	HMchunk_node
		{
		struct HMchunk_node	*next;
		struct HS_window_parms	*shading_window;
		IGRint			num_bytes;
		IGRint			offset;
		IGRchar			status;
		IGRchar			*chunk;
		};
		
struct	HMchunk_node_list
		{
		struct HMchunk_node		*node;
		struct HMchunk_node_list	*next;
		};
		
/* ================== Static Memory ================== */

/*
 *  buffer info
 */
 
static IGRchar			*big_buffer = NULL;
static IGRint			big_buffer_size = 0;
static IGRint			ideal_buffer_size = 0;
static IGRint			max_bytes[NUM_MODES];
static IGRint			bytes_allocated[NUM_MODES];
static struct HMchunk_node	*node;
static struct HMchunk_node	*chunks[NUM_MODES] = { NULL, NULL, NULL };
static struct HMchunk_node	*chunk_manager_pool[NUM_MODES];
static struct HMchunk_node_list	*chunk_manager_pool_list = NULL;

/*
 *  workstation info
 */

static IGRint		Mpx;		/*  Total screen pixels			*/
static IGRint		num_vs;		/*  total color virtual screens		*/
static IGRint		main_memory;	/*  total main memory size in bytes	*/
static IGRint		xdits, ydits;	/*  screen dimension, x/y, in pixels	*/


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

/* HSmemory.c */
static void HMfree_chunk_manager_node __((	IGRint mode, 
				   struct HMchunk_node *node));
				   
static void HMinit_chunk_manager_pool_node __((struct HMchunk_node *n));

static struct HMchunk_node *HMallocate_chunk_manager_pool_node __((void));

static void HMinit_chunk_manager_pool __((void));

static struct HMchunk_node *HMget_chunk_manager_node __((int mode));

static IGRint HMpacked_size __((IGRint mode));

static void HMcollect_free_chunks __((IGRint mode));

static IGRint HMpack_chunks __((IGRint mode));

static IGRint HMlast_chunk_size __((IGRint mode));

static int HMextend_big_buffer __((	IGRint mode, 
					IGRint extend_size));
					
static void HMfind_largest_chunk __((IGRint mode));

static IGRchar *HMassign_chunk __((	IGRint mode, 
					IGRint *bytes_returned, 
			struct HS_window_parms *shading_window));
			
static void HMsplit_chunk __((		IGRint mode, 
					IGRint bytes_requested));
					
static IGRchar HMfind_chunk __((	IGRint mode, 
					IGRint bytes_requested));
					
static char *HMget_chunk __((		int mode, 
					int bytes_requested, 
					int *bytes_returned, 
		     struct HS_window_parms *shading_window));
		     
static void HMactivate_big_buffer __((void));

static void HMallocate_big_buffer __((IGRint bytes_requested));

static MIN __((int x, int y));



#if defined(__cplusplus)
}
#endif


#undef __

	
/*---HMdebug_dump_chunks-------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HMdebug_dump_chunks( IGRint mode )
#else
	void	HMdebug_dump_chunks( mode )

	IGRint	mode;
#endif

	{
	struct HMchunk_node	*n;

	fprintf( stderr, "HMdebug_dump_chunks: %1d\n\n", mode );
	fprintf( stderr, "  node     next    window  num_byte  offset  s   chunk\n" );
	fprintf( stderr, "-------- -------- -------- -------- -------- - --------\n" );

	n = chunks[mode];
	while( n != NULL )
		{
		fprintf( stderr, "%8x %8x %8x %8d %8d %1d %8x\n",
			n,
			n->next,
			n->shading_window,
			n->num_bytes,
			n->offset,
			n->status,
			n->chunk );
			
		n = n->next;
		}
			
	fprintf( stderr, "\n" );
	}
	
/* ================ Static Functions ================= */
 
/*---HMfree_chunk_manager_node-------------------------*/

/* 
 *  free a chunk manager node
 */

#if defined(__STDC__) || defined(__cplusplus)
	static void	HMfree_chunk_manager_node( IGRint mode,
				      struct HMchunk_node *node )
#else
	static void	HMfree_chunk_manager_node( mode, node )

	IGRint			mode;
	struct HMchunk_node	*node;
#endif

	{
	node->next = chunk_manager_pool[mode];
	chunk_manager_pool[mode] = node;
	}

/*---HMinit_chunk_manager_pool_node------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HMinit_chunk_manager_pool_node( struct HMchunk_node *n )
#else
	static void	HMinit_chunk_manager_pool_node( n )

	struct HMchunk_node	*n;
#endif

	{
	int	i;
		
	/*
	 *  build a link list
	 */
	for( i=1; i<MAX_WINDOW; i++ )
		{
		n->next = n+1;
 		n++;
		}
		
	n->next = NULL;
	}

/*---HMallocate_chunk_manager_pool_node----------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HMchunk_node	*HMallocate_chunk_manager_pool_node(void)
#else
	static struct HMchunk_node	*HMallocate_chunk_manager_pool_node()
#endif

	{
	struct HMchunk_node		*n;
	struct HMchunk_node_list	*l;

	l = (struct HMchunk_node_list *)malloc( sizeof( struct HMchunk_node_list ) );
	
	l->next = chunk_manager_pool_list;
	chunk_manager_pool_list = l;
		
	n = (struct HMchunk_node *)malloc( sizeof( struct HMchunk_node ) * MAX_WINDOW );
	
	if( n != NULL )
		HMinit_chunk_manager_pool_node( n );

	l->node = n;
			
	return( n );
	}
	
/*---HMinit_chunk_manager_pool-------------------*/

/*
 *  initialize the chunk manager pool structures
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static void	HMinit_chunk_manager_pool(void)
#else
	static void	HMinit_chunk_manager_pool()
#endif

	{
	
	/*
	 *  allocate memory for the chunk manager pool, one for
	 *  each mode.
	 */

	chunk_manager_pool_list = NULL;
		 
	chunk_manager_pool[SHADING]   = HMallocate_chunk_manager_pool_node();
	chunk_manager_pool[RENDERING] = HMallocate_chunk_manager_pool_node();
	chunk_manager_pool[LVHL]      = HMallocate_chunk_manager_pool_node();
	}

	
/*---HMget_chunk_manager_node--------------------*/

/*
 *  Get a chunk manager node from the chunk manager pool
 *  for the given node
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static struct HMchunk_node	*HMget_chunk_manager_node( int mode )
#else
	static struct HMchunk_node	*HMget_chunk_manager_node( mode )

	int	mode;
#endif

	{
	struct HMchunk_node	*n;
	
	n = chunk_manager_pool[mode];
	if( n == NULL )
		{
		n = HMallocate_chunk_manager_pool_node();
		chunk_manager_pool[mode] = n->next;
		
		return( n );
		}
	
	chunk_manager_pool[mode] = n->next;
	
	return( n );
	}
	
/*---HMpacked_size-------------------------------*/

/*
 *  for the given mode, search the list of chunks, 
 *  totaling the byte size of only the free chunks
 */

#if defined(__STDC__) || defined(__cplusplus)
	static IGRint	HMpacked_size( IGRint mode )
#else
	static IGRint	HMpacked_size( mode )

	IGRint	mode;
#endif

	{
	int	bytes;

	node = chunks[mode];
	bytes = 0;
	while( node != NULL )
		{
		if( node->status == FREE )
			bytes += node->num_bytes;
			
		node = node->next;
		}

	return( bytes );
	}
	
	

/*---HMcollect_free_chunks-----------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HMcollect_free_chunks( IGRint mode )
#else
	static void	HMcollect_free_chunks( mode )

	IGRint	mode;
#endif

	{
	struct HMchunk_node	*n, *nx;
	
	n = chunks[mode];
	while( n != NULL )
		{
		nx = n->next;
		
		if( nx != NULL )
			{
			if( n->status == FREE &&
			    nx->status == FREE )
				{
				n->next = nx->next;
				n->num_bytes += nx->num_bytes;
				
				HMfree_chunk_manager_node( mode, nx );
				}
			else
				{
				n = nx;
				}
			}
		else
			n = nx;
		}
	}

/*---HMpack_chunks-------------------------------*/

     
#if defined(__STDC__) || defined(__cplusplus)
	static IGRint	HMpack_chunks( IGRint mode )
#else
	static IGRint	HMpack_chunks( mode )

	IGRint	mode;
#endif

	{
	char			*dest;
	struct HMchunk_node	*n, *p, *nx, *sn;
	int			byte_count=0;


	/*
	 *  make sure there are no consecutive free chunks
	 */
	 
	HMcollect_free_chunks( mode );
	
	
	/*
	 *  Locate all the free nodes and dispose of them
	 *  remember the address of the first free node
	 */

	dest = NULL;
	n = chunks[mode];
	p = NULL;
	sn = NULL;
	
	while( n != NULL )
		{
		if( n->status == FREE )
			{
			if( dest == NULL )
				{
				dest = n->chunk;
				sn = n->next;
				byte_count = n->offset;
				}
			
			if( p == NULL )
				chunks[mode] = n->next;
			else
				p->next = n->next;
			
			nx = n->next;
			
			HMfree_chunk_manager_node( mode, n );
			
			n = nx;
			}
		else
			{
			p = n;
			n = n->next;
			}
		}
	
	n = sn;
	
	/*
	 *  move all the used buffers down
	 */

	while( n != NULL )
		{
		memcpy( dest, n->chunk, n->num_bytes );
		
		n->offset = byte_count;
		n->chunk = dest;

		if( mode == SHADING )
			{
			n->shading_window->zbuf = (HSzbuf *)n->chunk;
			n->shading_window->cbuf = 
				(HScbuf *)(n->shading_window->zbuf + 
					   n->shading_window->num_pixels);
			}
				
		dest += n->num_bytes;
		byte_count += n->num_bytes;
		
		if( n->next == NULL )
			{
			p = HMget_chunk_manager_node( mode );
			
			p->next = NULL;
			p->num_bytes = big_buffer_size - byte_count;
			p->offset = byte_count;
			p->status = FREE;
			p->chunk = dest;

			n->next = p;
			n = n->next;
			}
			
		n = n->next;
		}	
	return(0);
	}
	
/*---HMlast_chunk_size---------------------------*/

/*
 *  Find the last chunk and, if it is free, return its
 *  size, else return 0
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static IGRint	HMlast_chunk_size( IGRint mode )
#else
	static IGRint	HMlast_chunk_size( mode )

	IGRint	mode;
#endif

	{
	node = chunks[mode];
	while( node->next != NULL )
		node = node->next;
		
	if( node->status == FREE )	
		return( node->num_bytes );
	else
		return( 0 );
	}
	
/*---HMextend_big_buffer-------------------------*/

/*
 *  enlarge the big buffer by "extend_size" bytes
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static int	HMextend_big_buffer( IGRint mode, IGRint extend_size )
#else
	static int	HMextend_big_buffer( mode, extend_size )

	IGRint	mode;
	IGRint	extend_size;
#endif

	{
	struct HMchunk_node	*new_node;
	char			*new_buffer;
	IGRint			num_bytes, i;
	
	/*
	 *  compute the realloc size, (the current big buffer
	 *  size, plus the extend size) and attempt to
	 *  realloc. 
	 */
	 
	HSdisplay_memory_realloc_message();
	
	num_bytes = big_buffer_size + extend_size;
	new_buffer = (char *)realloc( big_buffer, num_bytes );
	
	HSerase_memory_realloc_message();
	
	if( new_buffer == NULL ) return( 0 );
	
	/*
	 *  Reset the chunk addresses in the chunk nodes, and
	 *  the z/image buffer addresses in the shading window
	 *  structures
	 */

	for( i=0; i<NUM_MODES; i++ )
		{
		node = chunks[i];
	
		while( node != NULL )
			{
			node->chunk = new_buffer + node->offset;
			
			/*
			 *  If we are doing the shading mode, and the
			 *  chunk is assigned, then reset the zbuf/cbuf
			 *  pointers in the shading window structure
			 */
			 
			if( i == SHADING && node->status != FREE )
				{
				node->shading_window->zbuf = (HSzbuf *)node->chunk;
				node->shading_window->cbuf = 
					(HScbuf *)(node->shading_window->zbuf + 
						   node->shading_window->num_pixels);
				}
				
			/*
			 *  There are special things that have to be done for
			 *  the last chunk.
			 */
			 
			if( node->next == NULL ) 
				{
				if( node->status == FREE )
					{
					node->num_bytes += extend_size;
					}
				else
					{
					new_node = HMget_chunk_manager_node( mode );

					new_node->next = NULL;
					new_node->num_bytes = extend_size;
					new_node->offset = node->offset + node->num_bytes;
					new_node->status = FREE;
					new_node->chunk = node->chunk + node->num_bytes;

					node->next = new_node;
					node = new_node;
					}
				}
			
			node = node->next;
			}
		}
		
	big_buffer = new_buffer;
	big_buffer_size = num_bytes;
		
	return( 1 );
	}
	
/*---HMfind_largest_chunk------------------------*/

/*
 *  find the largest chunk and return
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static void	HMfind_largest_chunk( IGRint mode )
#else
	static void	HMfind_largest_chunk( mode )

	IGRint	mode;
#endif

	{
	int			size;
	struct HMchunk_node	*n;
	
	node = NULL;
	size = NULL;
	n = chunks[mode];
	
	while( n != NULL )
		{
		if( n->status == FREE )
			if( n->num_bytes > size )
				node = n;
				
		n = n->next;
		}
	}
	
/*---HMassign_chunk------------------------------*/

/*
 *  assign the new chunk and return
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static IGRchar	*HMassign_chunk( IGRint mode,
					 IGRint *bytes_returned,
			 struct HS_window_parms *shading_window )
#else
	static IGRchar	*HMassign_chunk(
				mode,
				bytes_returned,
				shading_window )
			
	IGRint			mode;
	IGRint			*bytes_returned;
	struct HS_window_parms	*shading_window;
#endif

	{
	if( node != NULL )
		{
		node->status = USED;
		node->shading_window = shading_window;
		if( bytes_returned != NULL ) *bytes_returned = node->num_bytes;
		bytes_allocated[mode] += node->num_bytes;

#		if DEBUG
			HMdebug_dump_chunks( mode );
#		endif

		return( node->chunk );
		}
	else
		{
		return( NULL );
		}
	}
	
/*---HMsplit_chunk-------------------------------*/

/*
 *  Having found a chunk bigger than the requested
 *  size, split the chunk
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static void	HMsplit_chunk( IGRint mode, IGRint bytes_requested )
#else
	static void	HMsplit_chunk( mode, bytes_requested )

	IGRint	mode;
	IGRint	bytes_requested;
#endif

	{
	struct HMchunk_node	*new_node;
	
	new_node = HMget_chunk_manager_node( mode );

	new_node->next      = node->next;
	new_node->num_bytes = node->num_bytes - bytes_requested;
	new_node->offset    = node->offset + bytes_requested;
	new_node->status    = FREE;
	new_node->chunk     = node->chunk + bytes_requested;
	
	node->num_bytes = bytes_requested;

	node->next = new_node;
	}
	
/*---HMfind_chunk--------------------------------*/

/*
 *  find a chunk of bytes_requested size
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static IGRchar	HMfind_chunk( IGRint mode, IGRint bytes_requested )
#else
	static IGRchar	HMfind_chunk( mode, bytes_requested )

	IGRint	mode;
	IGRint	bytes_requested;
#endif

	{
	node = chunks[mode];
	
	while( node != NULL )
		{
		if( node->status == FREE )
			{
			if( node->num_bytes == bytes_requested )
				return( 1 );
			else
				{
				if( node->num_bytes > bytes_requested )
					{
					HMsplit_chunk( mode, bytes_requested );
					return( 1 );
					}
				}
			}
			
		node = node->next;
		}
		
	return( 0 );
	}
	
/*---HMget_chunk---------------------------------*/

/*
 *  Attempt to get a chunk of memory from the big buffer
 *  of size, bytes_requested
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static char	*HMget_chunk( int mode,
				      int bytes_requested,
				      int *bytes_returned,
		   struct HS_window_parms *shading_window )
#else
	static char	*HMget_chunk( 	mode, 
					bytes_requested, 
					bytes_returned, 
					shading_window )
			
	int			mode;
	int			bytes_requested;
	int			*bytes_returned;
	struct HS_window_parms	*shading_window;
#endif

	{
	IGRint	packed_size;
	IGRint	last_chunk_size;


	/* 
	 *  See if there is an existing chunk in the big buffer
	 *  big enough to satisfy the caller
	 */
	 
	if( HMfind_chunk( mode, bytes_requested ) )
		return( HMassign_chunk( mode, bytes_returned, shading_window ) );

	/*
	 *  Can't pack or re-size when rendering because of all of the different
	 *  pointers to the allocated chunks
	 */

	if( mode == RENDERING )
		return( NULL );

	/*
	 *  See if an chunk big enough can be generated by
	 *  packing the existing chunks
	 */
	 
	if( (packed_size = HMpacked_size( mode )) >= bytes_requested )
		{
		HMpack_chunks( mode );
		HMfind_chunk( mode, bytes_requested );
		return( HMassign_chunk( mode, bytes_returned, shading_window ) );
		}
		
	/*
	 *  See if the last chunk can be made big enough, by extending
	 *  the memory.  "max_bytes[mode] - big_buffer_size" is the bytes
	 *  the memory can be extended without exceeded the max for the
	 *  mode.
	 */
	 
	if( ((last_chunk_size = HMlast_chunk_size(mode)) + (max_bytes[mode] - big_buffer_size)) >= bytes_requested )
		{
			
		/*
		 *  Attempt to extend the memory, if ok, get the chunk assign 
		 *  it and return
		 */
		 
		if( HMextend_big_buffer( mode, bytes_requested - last_chunk_size ) )
			{
			HMfind_chunk( mode, bytes_requested );
			return( HMassign_chunk(	mode, 
						bytes_returned, 
						shading_window ) );
			}
		}
		
	/* 
	 *  See if a chunk big enough can be made by packing and extending
	 *  the memory, without extending past the upper limit
	 */
	 
	if( (packed_size + (max_bytes[mode] - big_buffer_size) ) >= bytes_requested )
		{
			
		/*
		 *  Attempt to extend the memory, if ok, get the chunk assign 
		 *  it and return
		 */
		 
		if( HMextend_big_buffer( mode, bytes_requested - packed_size ) )
			{
			HMpack_chunks( mode );
			HMfind_chunk( mode, bytes_requested );
			return( HMassign_chunk(	mode, 
						bytes_returned, 
						shading_window ) );
			}
		}
		
	/*
	 *  There's nothing left to do, error exit
	 */
	 
	return( NULL );
	}

/*---HMactivate_big_buffer--------------------------*/

/*
 *  Once a big buffer has been allocated, step up all the
 *  data structure for maintaining the memory
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static void	HMactivate_big_buffer(void)
#else
	static void	HMactivate_big_buffer()
#endif

	{
	int			mode;

	/*
	 *  For each mode, we'll have only one chunk to
	 *  start with, the big buffer.  Get a chunk manager
	 *  node for each mode, and initialize the 
	 *  variables
	 */

	for( mode=0; mode<NUM_MODES; mode++ )
		{
		node = HMget_chunk_manager_node( mode );
	
		node->next = NULL;
		node->num_bytes = big_buffer_size;
		node->offset = 0;
		node->status = FREE;
		node->chunk = big_buffer;
		
		chunks[mode] = node;
		}
	}
	
/*---HMallocate_big_buffer----------------------*/

/*
 *  attempt to allocate memory for the big buffer.
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static void	HMallocate_big_buffer( IGRint bytes_requested )
#else
	static void	HMallocate_big_buffer( bytes_requested )

	IGRint	bytes_requested;
#endif

	{
			
	/* 
	 *  If the caller is requesting more than the ideal
	 *  buffer size, allocate only the requested amount
	 */
		 
	if( bytes_requested > ideal_buffer_size )
		{
				
		/*
		 *  Call malloc to get the big buffer.  If
		 *  OK activate the buffer, else return with
		 *  error
		 */

		big_buffer = (char *)malloc( bytes_requested );
		if( big_buffer != NULL )
			{
			big_buffer_size = bytes_requested;
			HMactivate_big_buffer();
			}
		else
			{
#			if DEBUG_MEMORY
				fprintf( stderr, "HSmemory: Unable to allocate %1d bytes\n",
					bytes_requested );
#			endif
			}
		}
	else
		{
			
		/*
		 *  The caller is requesting at most, the ideal buffer
		 *  size.  Allocate that much
		 */

		big_buffer = (char *)malloc( ideal_buffer_size );
		if( big_buffer != NULL )
			{
			big_buffer_size = ideal_buffer_size;
			HMactivate_big_buffer();
			}
		else
			{
			
			/*
			 *  Failed to allocate the ideal buffer size, try
			 *  the requested size.
			 */
				 
#			if DEBUG_MEMORY
				fprintf( stderr, "HSmemory: Failed to allocate the ideal buffer size\n" );
#			endif
					
			big_buffer = (char *)malloc( bytes_requested );
			if( big_buffer != NULL )
				{
				big_buffer_size = bytes_requested;
				HMactivate_big_buffer();
				}
			else
				{
#				if DEBUG_MEMORY
					fprintf( stderr, "HSmemory: Unable to allocate %1d bytes\n",
						bytes_requested );
#				endif
				}
			}
		}
	}
	
/*---HMget_workstation_info---------------------*/

/*
NAME
    HMget_workstation_info
    
DESCRIPTION
    Collect screen size and main memory size info
    about the workstation
    
PARAMETERS
    Mpx        : (OUT):  The number of pixels (in Megs) in the
                         default screen
    num_ls     : (OUT):  The number of valid logical screens
    main_memory: (OUT):  The number of bytes of main memory available
    xdits      : (OUT):  The default screen xaxis size in dits
    ydits      : (OUT):  The default screen yaxis size in dits
    
FUNCTIONS CALLED
    WLget_number_of_screens
    WLget_screen_size
    WLget_active_screen

NOTES
    In the near future, Shridar is going to change WLget_number_of_screens
    to return an array of lscreen numbers.  When this is done, I will need
    to add code to get the depth of each and verify that they are valid
    color windows. (ML:2/1/93)
        
HISTORY
    ??/??/??	M. Lanier
         Created
         
    2/1/93      M. Lanier
         WL Converted
         
*/
 
void	HMget_workstation_info( int *Mpx,
                                int *num_screens,
                                int *main_memory,
                                int *xdits, 
                                int *ydits )

    {
    WLuint16	lscreen_no;
    WLuint16	*screen_list;
    int		screen_type;
    
    HSget_vm_stats( NULL, NULL, (unsigned long *)main_memory );

    /*  Get the number of logical screens.  Return '0' of the function  */
    /*  fails.  Later a buffer of lscreen numbers will be added to the  */
    /*  arument list.  At that time code to verify that each logical    */
    /*  is a valid color screen will need to be added                   */
    
    if( WLget_number_of_screens( num_screens, &screen_list ) != WL_SUCCESS )
        {
        num_screens = 0;
        }
    
    /*  Get the logical screen number of the active screen.  From that  */
    /*  get the dit size of that screen hoping that all screens are the */
    /*  same size.  If either function fails, returnn '0' for the size  */
    /*  and num, Megapixels                                             */
    
    if( WLget_active_screen( &lscreen_no, &screen_type ) == WL_SUCCESS )
        {
        if( WLget_screen_size( lscreen_no, xdits, ydits ) == WL_SUCCESS )
            {
            *Mpx = ((*xdits) * (*ydits)) / 1000000;
            }
        else
            {
            *xdits = 0;
            *ydits = 0;
            *Mpx = 0;
            }
        }
    else
        {
        *xdits = 0;
        *ydits = 0;
        *Mpx = 0;
        }
        
    }  /* HMget_workstation_info */
	
/*---MIN-----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static MIN( int x, int y )
#else
	static MIN( x, y )

	int	x, y;
#endif

	{
	return( x<y ? x : y );
	}
	
	
/* ================== Entry Points =================== */

/*---HMallocate---------------------------------*/

/*
 *  This function will allocate a big buffer and divvy
 *  it out to the callers.
 *
 *  Arguments:
 *    mode:   Shading
 *            Rendering
 *            LVHL
 *
 *    bytes_requested:  Number of bytes needed.  If -1, will
 *            return the largest chunk it can find.
 *
 *    bytes_returned:  Number of bytes in the returned chunk
 *
 *    shading_window:  Address of the shading window parms
 *            structure
 *
 *  Return:
 *
 *    Pointer to a chunk of memory
 *
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	char	*HMallocate( int mode,
			     int bytes_requested,
			     int *bytes_returned,
	  struct HS_window_parms *shading_window )
#else
	char	*HMallocate(
				mode,
				bytes_requested,
				bytes_returned,
				shading_window )
			
	int			mode;
	int			bytes_requested;
	int			*bytes_returned;
	struct HS_window_parms	*shading_window;
#endif

	{
		
	/*
	 *  Make sure bytes_requested is a multiple of 8 bytes so all allocations start
	 *  on an 8 byte boundary.
	 */

	if ( bytes_requested % 8 )
		bytes_requested += (8 - (bytes_requested % 8));

	/*
	 *  If the caller has specified an invalid mode, display
	 *  and error and return with error
	 */

#	if DEBUG
		fprintf( stderr, "HMallocate\n" );
		fprintf( stderr, "   mode            : %1d\n", mode );
		fprintf( stderr, "   bytes_requested : %1d\n", bytes_requested );
		fprintf( stderr, "   shading_window  : %x\n", shading_window );
		HMdebug_dump_chunks( mode );
#	endif
	 
	if( mode >= NUM_MODES )
		{
#		if DEBUG_MEMORY
			fprintf( stderr, "HSmemory: User specified invalid mode: %d\n", mode );
#		endif

		return( NULL );
		}
		
	/*
	 *  If the caller is requesting a chunk bigger than is
	 *  allowable for the given mode, then display an error
	 *  and return with error
	 */
	 
	if( bytes_requested > max_bytes[mode] )
		{
#		if DEBUG_MEMORY
			{
			fprintf( stderr, "HSmemory: A request of %1d bytes exceeded limit for mode\n", bytes_requested );
			fprintf( stderr, "          Mode limit is %1d bytes\n", max_bytes[mode] );
			}
#		endif
			
		return( NULL );
		}

	/*
	 *  If the requested amount of memory would caused the total
	 *  allocated for the specified mode to exceed the maximum 
	 *  for the more, then display error and return
	 */
	 
	if( (bytes_requested + bytes_allocated[mode]) > max_bytes[mode] )
		{
#		if DEBUG_MEMORY
			{
			fprintf( stderr, "HSmemory: The request for %1d bytes of memory will raise total memory\n", 
				bytes_requested );
			fprintf( stderr, "          allocated for this mode to %1d, which is in excess of limit\n", 
				(bytes_requested + bytes_allocated[mode]) );
			fprintf( stderr, "          of %1d bytes\n", max_bytes[mode] );
			}
#		endif

		return( NULL );
		}
			
	/*
	 *  If a big buffer has yet to be allocated, do so now
	 */
	 
	if( big_buffer == NULL ) 
		{
		HMallocate_big_buffer( bytes_requested );

		/*
		 *  If a big buffer is still not allocated, return with error
		 */
	 
		if( big_buffer == NULL ) return( NULL );
		}
		
	/*
	 *  Grab a chunk for the requested, assign it and return
	 */

	if( bytes_requested > 0 )
		{
		return( HMget_chunk( mode, bytes_requested, bytes_returned, shading_window ) );
		}
	else
		{
			
		/*
		 *  the caller is only wanting the largest chunk available, get
		 *  it, assign it and return
		 */
		 
		HMfind_largest_chunk( mode );
		return( HMassign_chunk( mode, bytes_returned, shading_window ) );
		}
	}
	
/*---HMreallocate-------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	char	*HMreallocate( int mode,
			       int bytes_requested,
			       int *bytes_returned,
	    struct HS_window_parms *shading_window,
			      char *chunk )
#else
	char	*HMreallocate(	mode,
				bytes_requested,
				bytes_returned,
				shading_window,
				chunk )
				
	int			mode;
	int			bytes_requested;
	int			*bytes_returned;
	struct HS_window_parms	*shading_window;
	char			*chunk;
#endif

	{
	static struct HMchunk_node	*n;
	char				*new_chunk;
	int				old_chunk_size;
	void				HMfree();

#	if DEBUG
		fprintf( stderr, "HMreallocate\n" );
		fprintf( stderr, "   mode            : %1d\n", mode );
		fprintf( stderr, "   bytes_requested : %1d\n", bytes_requested );
		fprintf( stderr, "   shading_window  : %x\n", shading_window );
		fprintf( stderr, "   chunk           : %x\n", chunk );
		HMdebug_dump_chunks( mode );
#	endif

	/*
	 *  Find the node that owns this chunk
	 */

	n = chunks[mode];
	while( n != NULL )
		{
		if( n->chunk == chunk )
			{
				
			/*
			 *  found the chunk node.  Mark it as free
			 *  and attempt to allocate
			 */

			old_chunk_size = n->num_bytes;
			
			HMfree( mode, n->chunk );

#			if DEBUG
				HMdebug_dump_chunks( mode );
#			endif

			new_chunk = HMallocate( mode,
						bytes_requested,
						bytes_returned, 
						shading_window );
			
			/*
			 *  if the allocate fails, reset the old
			 *  chunk back to used and return NULL
			 *  else return the new chunk
			 */

			if( new_chunk == NULL )
				{
				new_chunk = HMallocate( mode,
							old_chunk_size,
							bytes_returned, 
							shading_window );

				shading_window->zbuf = (HSzbuf *)new_chunk;
				shading_window->cbuf = 
					(HScbuf *)(shading_window->zbuf + 
						   shading_window->num_pixels);

				return( NULL );
				}
			else
				{
#				if DEBUG
					HMdebug_dump_chunks( mode );
#				endif
	
				return( new_chunk );
				}
			}
		
		n = n->next;
		}
		
	return( NULL );
	}
	
/*---HMinit-------------------------------------*/

/*
 *  This function is to be called once, at the begining.
 *  It's purpose is to set up any global information that
 *  will be needed by the other functions
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	char	*HMinit( int mode,
			 int bytes_requested,
			 int *bytes_returned,
			struct HS_window_parms *shading_window )
#else
	char	*HMinit(
				mode,
				bytes_requested,
				bytes_returned,
				shading_window )
				
	int			mode;
	int			bytes_requested;
	int			*bytes_returned;
	struct HS_window_parms	*shading_window;
#endif

	{
	char	*getenv(), *envr;
        int	user_memory;
	
	HMget_workstation_info(
		&Mpx,
		&num_vs,
		&main_memory,
		&xdits, &ydits );
			

        user_memory = 0;
        envr = getenv( "HS_MAX_ZBUFFER_MEMORY" );
        if( envr )
           sscanf( envr, "%d", &user_memory );

        if( user_memory > 0 )
           {
           max_bytes[SHADING] = user_memory * 1024 * 1024;
           printf( "Zbuffer memory max: %d\n", max_bytes[SHADING] );
           }
        else
	   max_bytes[SHADING] = 5 * xdits * ydits * num_vs;

	max_bytes[RENDERING] = 16777216;
	max_bytes[LVHL] = 16777216;
		
	bytes_allocated[SHADING] = 0;
	bytes_allocated[RENDERING] = 0;
	bytes_allocated[LVHL] = 0;
		
	ideal_buffer_size = MIN( (max_bytes[SHADING]/num_vs), (main_memory/2) );
		
	big_buffer = NULL;
	big_buffer_size = 0;
		
	HMinit_chunk_manager_pool();
		
#	if DEBUG_MEMORY
		{
		fprintf( stderr, "HMinit:\n" );
		fprintf( stderr, "   Mpx                  : %1d\n", Mpx );
		fprintf( stderr, "   num_vs               : %1d\n", num_vs );
		fprintf( stderr, "   main_memory          : %1d\n", main_memory );
		fprintf( stderr, "   xdits                : %1d\n", xdits );
		fprintf( stderr, "   ydits                : %1d\n", ydits );
		fprintf( stderr, "   max_bytes[SHADING]   : %1d\n", max_bytes[SHADING] );
		fprintf( stderr, "   max_bytes[RENDERING] : %1d\n", max_bytes[RENDERING] );
		fprintf( stderr, "   max_bytes[LVHL}      : %1d\n", max_bytes[LVHL] );
		fprintf( stderr, "   ideal_buffer_size    : %1d\n", ideal_buffer_size );
		}
#	endif

	/*
	 *  reset the malloc and realloc functions
	 */
	 
	tiling_parms.zmalloc = HMallocate;
	tiling_parms.zrealloc = HMreallocate;
			
	return( HMallocate(	mode,
				bytes_requested,
				bytes_returned,
				shading_window ) );
	}

/*---HMfree--------------------------------------------------*/

/*
 *  search through the list of chunks for the mode, looking
 *  for the one that has chunk, and mark it free
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	void	HMfree( int mode, char *chunk )
#else
	void	HMfree( mode, chunk )

	int	mode;
	char	*chunk;
#endif

	{
	struct HMchunk_node	*n;

#	if DEBUG
		fprintf( stderr, "HMfree:\n" );
		fprintf( stderr, "   mode  : %1d\n", mode );
		fprintf( stderr, "   chunk : %x\n", chunk );
#	endif
	
	n = chunks[mode];
	while( n != NULL )
		{
		if( n->chunk == chunk )
			{
			bytes_allocated[mode] -= n->num_bytes;
			n->status = FREE;
			break;
			}
			
		n = n->next;
		}
		
	HMcollect_free_chunks( mode );
	
#	if DEBUG
		HMdebug_dump_chunks( mode );
#	endif
	}
	
/*---HMdispose--------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HMdispose(void)
#else
	IGRint	HMdispose()
#endif

/*
DESCRIPTION
	This function disposes of the big buffer that was allocated for
	shading, rendering, and LVHL.  Before this function can be called,
	all shading windows with Zbuffers must be converted to wireframe.
*/

	{
	IGRint size_freed = 0;
	struct HMchunk_node_list	*l, *ln;

	if ( big_buffer )
	   {
	   size_freed = big_buffer_size;

	   /* free what has been malloced */
	   free( big_buffer );
	   
	   l = chunk_manager_pool_list;
	   chunk_manager_pool_list = NULL;
	   while( l != NULL )
	      {
	      ln = l->next;
	      free( (char *)l->node );
	      free( (char *)l );
	      l = ln;
	      }

	   /* reset static variables back to their initial states */
	   big_buffer = NULL;
	   big_buffer_size = 0;
	   ideal_buffer_size = 0;
           chunks[SHADING] = NULL;
           chunks[RENDERING] = NULL;
           chunks[LVHL] = NULL;

	   tiling_parms.zmalloc = HMinit;
	   tiling_parms.zrealloc = HMinit;
	   }

	return( size_freed );
	}  /* HMdispose */

