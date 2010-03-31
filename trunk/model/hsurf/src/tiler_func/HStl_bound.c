
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "exsysdep.h"
#include "hstiler.h"
#include "hslight.h"
#include "hsmath.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

#include "bstypes.h"
#include "bssfarrevmt.h"

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

/* HStl_bound.c */
static struct HSpoint *HSnew_point __((void));

static void HSdispose_point_list __((struct HSpoint *head_addr, 
				     struct HSpoint *tail_addr));
				     
static struct HSbound *HSnew_bound __((void));

static void HSdispose_bound __((struct HSbound *bound_addr));

static struct HSxsect *HSnew_xsect __((void));

static void HSdispose_xsect_list __((struct HSxsect *head_addr, 
				     struct HSxsect *tail_addr));
				     
static void HSinterpolate_point __((struct HSpoint *point));

static void HSevaluate_point __((struct HSpoint *point));

static void HSset_interp_flag __((void));

static void HSsend_out_polygon __((register struct HSpoint *pt_list, 
				       IGRboolean default_marks));
				       
static struct HSpoint *HSfind_start __((struct HSpoint *this_point, 
					struct HSpoint *stop_point));
					
static struct HSpoint *HSfind_end __((struct HSpoint *this_point, 
				      struct HSpoint *stop_point));
				      
static void HSfix_closed_bound_points __((struct HSpoint *start_point));

static void HSmove_endpt_from_corners __((struct HSbound *start_bound, 
					  struct HSbound *end_bound));
					  
static struct HSbound *HSput_bound __((struct HSpoint *start_pt, 
				       struct HSpoint *next_to_last_pt, 
				       struct HSbound *bound_list));
				       
static struct HSpoint *HSfind_bound_patch_xsect __((struct HSpoint *start_pt, 
						    struct HSpoint *stop_pt, 
							 IGRdouble ulo, 
							 IGRdouble vlo, 
							 IGRdouble uhi, 
							 IGRdouble vhi));
							 
static struct HSpoint *HSfind_start_of_bound __((struct HSpoint *this_pt, 
						 struct HSpoint *stop_pt, 
						      IGRdouble ulo, 
						      IGRdouble vlo, 
						      IGRdouble uhi, 
						      IGRdouble vhi));
						      
static struct HSpoint *HSfind_end_of_bound __((struct HSpoint *this_pt, 
						    IGRdouble ulo, 
						    IGRdouble vlo, 
						    IGRdouble uhi, 
						    IGRdouble vhi));
						    
static struct HSbound *HSsift_into_open_bounds __((struct HSpoint *start_pt, 
						   struct HSpoint *stop_pt, 
						        IGRdouble ulo, 
						        IGRdouble vlo, 
						        IGRdouble uhi, 
						        IGRdouble vhi, 
						   struct HSbound *bound_list));
						   
static struct HSpoint *HScopy_point __((struct HSpoint *pt));

static struct HSxsect *HSadd_intersection_to_list __((struct HSxsect *xsect_pt, 
						      struct HSxsect *intersection_list));
						      
static struct HSxsect *HSbuild_intersection_list __((IGRdouble ulo, 
						     IGRdouble uhi, 
						     IGRdouble vhi, 
						struct HSbound *patch_bounds, 
						    IGRboolean ll_corner_solid));
						    
static struct HSpoint *HSmake_point __((	IGRdouble u, 
						IGRdouble v));
						
static void HSreverse_boundary __((struct HSxsect *intersection));

static struct HSxsect *HSadjust_equal_xsects __((struct HSxsect *xsect_list));

static void HSlink_bound_to_horiz_side __((	struct HSpoint *point, 
						struct HSpoint *side));
						
static int HSlink_bound_to_vert_side __((	struct HSpoint *point, 
						struct HSpoint *side));
						
static int HSlink_horiz_side_to_bound __((	struct HSpoint *point, 
						struct HSpoint *side));
						
static int HSlink_vert_side_to_bound __((	struct HSpoint *point, 
						struct HSpoint *side));
						
static struct HSbound *HSremove_open_boundaries __((struct HSbound *bound_list));

static void HSsend_out_all_boundaries __((struct HSbound *closed_bound_list));

static IGRboolean HSpoint_is_within_boundary __((	IGRdouble u, 
							IGRdouble v, 
						   struct HSpoint *start_pt));
						   
static struct HSbound *HSadd_contained_loops __((	struct HSpoint *master_polygon_start, 
							struct HSbound *bound_list));
							
static void HSclean_up_remaining_boundaries __((struct HSbound *bound_list));
	
static void HSreclaim_boundary_memory __((	struct HSxsect *start_xsect, 
						struct HSxsect *end_xsect));
						
#if defined(__cplusplus)
}
#endif


#undef __




#ifdef	TRUE
#undef	TRUE
#endif
#ifdef	FALSE
#undef	FALSE
#endif
#define FALSE		0
#define TRUE		~0


#define	BOUND_TOL	0.0000005	/* parametric 'fudge' value for bndries	*/
#define	HS_60KB		61440		/* sixty kilobytes: the "magic size"	*/
#define	NUM_POINTS_IN_60KB	HS_60KB / sizeof (struct HSpoint)
					/* number of points in 60kb of memory	*/
#define	NUM_BOUNDS_IN_60KB	HS_60KB / sizeof (struct HSbound)
					/* number of bounds in 60kb of memory	*/
#define	NUM_XSECTS_IN_60KB	HS_60KB / sizeof (struct HSxsect)
					/* number of xsects in 60kb of memory	*/

/* SET_LO_BITS sets the low order 4 */
/* bits of the mantissa of a double */
#ifdef BIG_ENDIAN
#define SET_LO_BITS( d_ptr )       \
	                           \
	{                          \
	char *c_ptr;               \
	c_ptr = (char *) (d_ptr);  \
	c_ptr += 7;                \
	*c_ptr |= 0xF;             \
	}
#else
#define SET_LO_BITS( d_ptr )       \
	                           \
	{                          \
	char *c_ptr;               \
	c_ptr = (char *) (d_ptr);  \
	*c_ptr |= 0xF;             \
	}
#endif


/*******************
 * LOCAL VARIABLES *
 *******************/

/* The following contain data about a patch's corner points and are used to
   interpolate boundary points for that patch.  It's faster to use
   these global variables than pass all of them repeatedly to 'find_point'. */

static IGRdouble	global_ulo,		global_vlo,
			global_uhi,		global_vhi;
static IGRdouble	*global_ll_point,	*global_ul_point,
			*global_lr_point,	*global_ur_point;
static IGRdouble	*global_ll_norm,	*global_ul_norm,
			*global_lr_norm,	*global_ur_norm;
static IGRdouble	global_ll_w,		global_ul_w,
			global_lr_w,		global_ur_w;

static struct
   HSpoint	*free_point_pool = NIL_POINT;	/* free point list	*/
static struct
   HSbound	*free_bound_pool = NIL_BOUND;	/* free bndry cell list	*/
static struct
   HSxsect	*free_xsect_pool = NIL_XSECT;	/* free xsect cell list	*/

static struct
   HSbufptr	*point_buffer_list = NIL_BUFPTR;/* point buffer list	*/
static struct
   HSbufptr	*bound_buffer_list = NIL_BUFPTR;/* bound buffer list	*/
static struct
   HSbufptr	*xsect_buffer_list = NIL_BUFPTR;/* xsect buffer list	*/

static IGRboolean	interp_flag;		/* interpolation flag	*/


/******************************
 * MEMORY MANAGEMENT ROUTINES *
 ******************************/


/*-- HSnew_point --------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSpoint *HSnew_point()
#else
	static struct HSpoint *HSnew_point()
#endif

/*
NAME
	HSnew_point (static)

DESCRIPTION
	Allocates an HSpoint structure & returns its address.  Space is 
	allocated by 'malloc' only when the free storage pool and current
	buffer are empty.

PARAMETERS
	none

GLOBALS USED
	free_point_pool (static)
	point_buffer_list (static)

RETURN VALUES
	A pointer to an HSpoint structure is returned.  NULL is returned
	if a structure couldn't be allocated.

NOTES
	The HSpoint allocated by this routine should be free by calling
	HSdispose_point_list.  If an error occurred trying to allocate
	memory, tiling_parms.status is set to HSSTAT_ALLOC_ERROR.

HISTORY
	09/01/86    S.A. Rapa
	   Created
	11/07/89    C.M. Jablonski
	   Changed to allocate fixed-size buffers
	12/11/89    C.M. Jablonski
	   Added element counts to speed cleanup
        07/27/93    Sudha           
	   Modified for BSprototypes ansification


*/

 {
   struct
      HSpoint	*this_point;
   struct
      HSbufptr	*this_buffer;

   if (free_point_pool != NIL_POINT)
    {
      /* get the point from the free list */
      this_point = free_point_pool;
      free_point_pool = free_point_pool->next;
    }
   else if ((point_buffer_list != NIL_BUFPTR) && (point_buffer_list->num_left > 0))
    {
      /* get the point from the current buffer */
      this_point = (struct HSpoint *)point_buffer_list->ele_ptr;
      point_buffer_list->ele_ptr += point_buffer_list->ele_size;
      point_buffer_list->num_left--;
    }
  else
    {
      /* allocate the structures for a new buffer */
      if ((this_buffer = (struct HSbufptr *) malloc (sizeof(struct HSbufptr))) &&
          (this_buffer->buffer = (char *) malloc (NUM_POINTS_IN_60KB * sizeof(struct HSpoint))))
       {
         this_buffer->ele_ptr = this_buffer->buffer;
         this_buffer->num_left = NUM_POINTS_IN_60KB;
         this_buffer->ele_size = sizeof(struct HSpoint);
         this_buffer->next = point_buffer_list;
         point_buffer_list = this_buffer;

         /* allocate the first point */
         this_point = (struct HSpoint *)point_buffer_list->ele_ptr;
         point_buffer_list->ele_ptr += point_buffer_list->ele_size;
         point_buffer_list->num_left--;
       }
      else
       {
       HSset_status( HSSTAT_ALLOC_ERROR );
       this_point = NULL;
       }
    }

   return (this_point);
 }


/*-- HSdispose_point_list -----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSdispose_point_list( struct HSpoint *head_addr, 
					  struct HSpoint *tail_addr )
#else
	static void HSdispose_point_list( head_addr, tail_addr )

	struct
	   HSpoint	*head_addr,
			*tail_addr;
#endif

/*
NAME
	HSdispose_point_list (static)

DESCRIPTION
	Attaches a list of HSpoint structures to the free storage pool.

PARAMETERS
	head_addr (IN) - head of point list to free
	tail_addr (IN) - tail of point list to free

GLOBALS USED
	free_point_pool (static)

HISTORY
	09/01/86    S.A. Rapa
	   created
*/


 {
    tail_addr->next = free_point_pool;
    free_point_pool = head_addr;
 }


/*-- HSnew_bound --------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSbound *HSnew_bound(void)
#else
	static struct HSbound *HSnew_bound()
#endif

/*
NAME
	HSnew_bound (static)

DESCRIPTION
	Allocates an HSbound structure and returns its address.  Space is
	allocated by 'malloc' only when the free storage pool and current
	buffer are empty.

GLOBALS USED
	free_bound_pool (static)
	bound_buffer_list (static)

RETURN VALUES
	A pointer to an HSbound structure is returned.  NULL is returned
	if a structure couldn't be allocated.

NOTES
	The HSbound allocated by this routine should be free by calling
	HSdispose_bound or HSdispose_bound_list.  If an error occurred trying
	to allocate memory, tiling_parms.status is set to HSSTAT_ALLOC_ERROR.

HISTORY:
	09/01/86    S.A. Rapa
	   Created.
	11/07/89    C.M. Jablonski
	   Changed to allocate fixed-size buffers
	12/11/89    C.M. Jablonski
	   Added element counts to speed cleanup
*/

 {
   struct
      HSbound	*this_bound;
   struct
      HSbufptr	*this_buffer;

   if (free_bound_pool != NIL_BOUND)
    {
      /* get the bound from the free list */
      this_bound = free_bound_pool;
      free_bound_pool = free_bound_pool->next;
    }
   else if ((bound_buffer_list != NIL_BUFPTR) && (bound_buffer_list->num_left > 0))
    {
      /* get the bound from the current buffer */
      this_bound = (struct HSbound *)bound_buffer_list->ele_ptr;
      bound_buffer_list->ele_ptr += bound_buffer_list->ele_size;
      bound_buffer_list->num_left--;
    }
  else
    {
      /* allocate the structures for a new buffer */
      if ((this_buffer = (struct HSbufptr *) malloc (sizeof(struct HSbufptr))) &&
          (this_buffer->buffer = (char *) malloc (NUM_BOUNDS_IN_60KB * sizeof(struct HSbound))))
       {
         this_buffer->ele_ptr = this_buffer->buffer;
         this_buffer->num_left = NUM_BOUNDS_IN_60KB;
         this_buffer->ele_size = sizeof(struct HSbound);
         this_buffer->next = bound_buffer_list;
         bound_buffer_list = this_buffer;

         /* allocate the first bound */
         this_bound = (struct HSbound *)bound_buffer_list->ele_ptr;
         bound_buffer_list->ele_ptr += bound_buffer_list->ele_size;
         bound_buffer_list->num_left--;
       }
      else
       {
       HSset_status( HSSTAT_ALLOC_ERROR );
       this_bound = NULL;
       }
    }

   return (this_bound);
 }


/*-- HSdispose_bound ----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSdispose_bound( struct HSbound *bound_addr )
#else
	static void HSdispose_bound( bound_addr )

	struct
	   HSbound	*bound_addr;
#endif

/*
NAME
	HSdispose_bound

DESCRIPTION
	Attaches a single HSbound structure to the free storage pool.

PARAMETERS
	bound_addr (IN) - the HSbound to free

GLOBALS USED
	free_bound_pool (static)

HISTORY
	09/01/86    S.A. Rapa
	   created
*/

 {
   bound_addr->next = free_bound_pool;
   free_bound_pool = bound_addr;
 }


/*-- HSdispose_bound_list -----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSdispose_bound_list( struct HSbound *bound_addr )
#else
	void HSdispose_bound_list( bound_addr )

	struct
	   HSbound	*bound_addr;
#endif

/*
NAME
	HSdispose_bound_list

DESCRIPTION
	Attaches an HSbound structure list to the free storage pool.

PARAMETERS
	bound_addr (IN) - the head of the bound list to free

GLOBALS USED
	free_bound_pool (static)

HISTORY
	09/01/86   S.A. Rapa
	   created
*/

 {
   struct
      HSbound	*last_cell;

   last_cell = bound_addr;
   while (last_cell->next != NIL_BOUND)
      last_cell = last_cell->next;
   last_cell->next = free_bound_pool;
   free_bound_pool = bound_addr;
 }


/*-- HSnew_xsect --------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSxsect *HSnew_xsect(void)
#else
	static struct HSxsect *HSnew_xsect()
#endif

/*
NAME
	HSnew_xsect (static)

DESCRIPTION
	Allocates an HSxsect structure and returns its address.  Space is
	allocated by 'malloc' only when the free storage pool and current
	buffer are empty.

PARAMETERS
	none

GLOBALS USED
	free_xsect_pool (static)
	xsect_buffer_list (static)

RETURN VALUES
	A pointer to an HSbound structure is returned.  NULL is returned
	if a structure couldn't be allocated.

NOTES
	The HSxsect allocated by this routine should be free by calling
	HSdispose_xsect_list.  If an error occurred trying to allocate
	memory, tiling_parms.status is set to HSSTAT_ALLOC_ERROR.

HISTORY
	09/01/86    S.A. Rapa
	   Created
	11/07/89    C.M. Jablonski
	   Changed to allocate fixed-size buffers
	12/11/89    C.M. Jablonski
	   Added element counts to speed cleanup
*/

 {
   struct
      HSxsect	*this_xsect;
   struct
      HSbufptr	*this_buffer;

   if (free_xsect_pool != NIL_XSECT)
    {
      /* get the xsect from the free list */
      this_xsect = free_xsect_pool;
      free_xsect_pool = free_xsect_pool->next;
    }
   else if ((xsect_buffer_list != NIL_BUFPTR) && (xsect_buffer_list->num_left > 0))
    {
      /* get the xsect from the current buffer */
      this_xsect = (struct HSxsect *)xsect_buffer_list->ele_ptr;
      xsect_buffer_list->ele_ptr += xsect_buffer_list->ele_size;
      xsect_buffer_list->num_left--;
    }
  else
    {
      /* allocate the structures for a new buffer */
      if ((this_buffer = (struct HSbufptr *) malloc (sizeof(struct HSbufptr))) &&
          (this_buffer->buffer = (char *) malloc (NUM_XSECTS_IN_60KB * sizeof(struct HSxsect))))
       {
         this_buffer->ele_ptr = this_buffer->buffer;
         this_buffer->num_left = NUM_XSECTS_IN_60KB;
         this_buffer->ele_size = sizeof(struct HSxsect);
         this_buffer->next = xsect_buffer_list;
         xsect_buffer_list = this_buffer;

         /* allocate the first xsect */
         this_xsect = (struct HSxsect *)xsect_buffer_list->ele_ptr;
         xsect_buffer_list->ele_ptr += xsect_buffer_list->ele_size;
         xsect_buffer_list->num_left--;
       }
      else
       {
       HSset_status( HSSTAT_ALLOC_ERROR );
       this_xsect = NULL;
       }
    }

   return (this_xsect);
 }


/*-- HSdispose_xsect_list -----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSdispose_xsect_list( struct HSxsect *head_addr, 
					  struct HSxsect *tail_addr )
#else
	static void HSdispose_xsect_list( head_addr, tail_addr )

	struct
	   HSxsect	*head_addr,	/* input - first cell in list		*/
			*tail_addr;	/* input - last cell in list		*/
#endif

/*
NAME
	HSdispose_xsect_list (static)

DESCRIPTION
	Attaches a list of HSxsect  structures to the free storage pool.

PARAMETERS
	head_addr (IN) - head of list of xsects to free
	tail_addr (IN) - tail of list of xsects to free

GLOBALS USED
	free_xsect_pool

HISTORY
	09/01/86   S.A. Rapa
	   created
*/

 {
    tail_addr->next = free_xsect_pool;
    free_xsect_pool       = head_addr;
 }


/*-- HScleanup_boundary_structures -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HScleanup_boundary_structures(void)
#else
	void HScleanup_boundary_structures()
#endif

/*
NAME
	HScleanup_boundary_structures

DESCRIPTION
	Frees all boundary structure buffers and resets the free lists.

PARAMETERS
	none

GLOBALS USED
	point_buffer_list (static)
	free_point_pool (static)
	bound_buffer_list (static)
	free_bound_pool (static)
	xsect_buffer_list (static)
	free_xsect_pool (static)

HISTORY
	11/07/89   C.M. Jablonski
	   Created
	12/11/89   C.M. Jablonski
	   Added element counts to speed cleanup
*/

 {
   struct
      HSbufptr	*this_buffer, *next_buffer;

   /* cleanup the point structures */
   if (point_buffer_list != NIL_BUFPTR)
    {
      for (	this_buffer = point_buffer_list->next;
		this_buffer != NIL_BUFPTR;
		this_buffer = next_buffer )
       {
         next_buffer = this_buffer->next;
         free((char *)this_buffer->buffer);
         free((char *)this_buffer);
       }
      point_buffer_list->ele_ptr = point_buffer_list->buffer;
      point_buffer_list->num_left = NUM_POINTS_IN_60KB;
      point_buffer_list->next = NIL_BUFPTR;
    }
   free_point_pool = NIL_POINT;

   /* cleanup the bound structures */
   if (bound_buffer_list != NIL_BUFPTR)
    {
      for (	this_buffer = bound_buffer_list->next;
		this_buffer != NIL_BUFPTR;
		this_buffer = next_buffer )
       {
         next_buffer = this_buffer->next;
         free((char *)this_buffer->buffer);
         free((char *)this_buffer);
       }
      bound_buffer_list->ele_ptr = bound_buffer_list->buffer;
      bound_buffer_list->num_left = NUM_BOUNDS_IN_60KB;
      bound_buffer_list->next = NIL_BUFPTR;
    }
   free_bound_pool = NIL_BOUND;

   /* cleanup the xsect structures */
   if (xsect_buffer_list != NIL_BUFPTR)
    {
      for (	this_buffer = xsect_buffer_list->next;
		this_buffer != NIL_BUFPTR;
		this_buffer = next_buffer )
       {
         next_buffer = this_buffer->next;
         free((char *)this_buffer->buffer);
         free((char *)this_buffer);
       }
      xsect_buffer_list->ele_ptr = xsect_buffer_list->buffer;
      xsect_buffer_list->num_left = NUM_XSECTS_IN_60KB;
      xsect_buffer_list->next = NIL_BUFPTR;
    }
   free_xsect_pool = NIL_XSECT;
 }


/*-- HSinterpolate_point -------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSinterpolate_point( struct HSpoint *point )
#else
	static void HSinterpolate_point( point )

	struct
	   HSpoint	*point;
#endif

/*
NAME
	HSinterpolate_point (static)

DESCRIPTION
	Takes a point structure & computes its surface & normal coordinates
	from its parametric values.  Rather than evaluating the B-spline
	at the given parameters, results are computed by interpolating values
	between known points ... in this case, these known points are the
	four corners of the current tile being processed.  This routine is
	designed to be called for boundary points just before they are written
	out on the pipe.

PARAMETERS
	point (IN/OUT) - the point to interpolate

GLOBALS USED
	global_ul_point (static)
	global_ll_point (static)
	global_ur_point (static)
	global_lr_point (static)
	global_ul_norm (static)
	global_ll_norm (static)
	global_ur_norm (static)
	global_lr_norm (static)
	global_ul_w (static)
	global_ll_w (static)
	global_ur_w (static)
	global_lr_w (static)
	active_window
	element_parms.doing_vertex_normals

HISTORY
	09/01/86   S.A. Rapa
	   created
*/

 {
   register
      IGRdouble	u_weight, v_weight;
   IGRdouble	vector_length,
		x1, y1, z1, w1, x2, y2, z2, w2,
		nx, ny, nz;

   if( global_uhi == global_ulo )
      u_weight = 0.0;
   else
      u_weight = (point->u - global_ulo) / (global_uhi - global_ulo);
      
   if( global_vhi == global_vlo )
      v_weight = 0.0;
   else
      v_weight = (point->v - global_vlo) / (global_vhi - global_vlo);

   /*
    * Surface point
    */

   x1 = (global_ul_point[0]-global_ll_point[0])*v_weight+global_ll_point[0];
   y1 = (global_ul_point[1]-global_ll_point[1])*v_weight+global_ll_point[1];
   z1 = (global_ul_point[2]-global_ll_point[2])*v_weight+global_ll_point[2];

   x2 = (global_ur_point[0]-global_lr_point[0])*v_weight+global_lr_point[0];
   y2 = (global_ur_point[1]-global_lr_point[1])*v_weight+global_lr_point[1];
   z2 = (global_ur_point[2]-global_lr_point[2])*v_weight+global_lr_point[2];

   point->x = (x2 - x1) * u_weight + x1;
   point->y = (y2 - y1) * u_weight + y1;
   point->z = (z2 - z1) * u_weight + z1;

   if (active_window->perspective)
    {
      w1 = (global_ul_w - global_ll_w) * v_weight + global_ll_w;
      w2 = (global_ur_w - global_lr_w) * v_weight + global_lr_w;
      point->w = (w2 - w1) * u_weight + w1;
    }

   /*
    * Normal
    */

   if (element_parms.doing_vertex_normals)
    {
      x1 = (global_ul_norm[0]-global_ll_norm[0])*v_weight+global_ll_norm[0];
      y1 = (global_ul_norm[1]-global_ll_norm[1])*v_weight+global_ll_norm[1];
      z1 = (global_ul_norm[2]-global_ll_norm[2])*v_weight+global_ll_norm[2];

      x2 = (global_ur_norm[0]-global_lr_norm[0])*v_weight+global_lr_norm[0];
      y2 = (global_ur_norm[1]-global_lr_norm[1])*v_weight+global_lr_norm[1];
      z2 = (global_ur_norm[2]-global_lr_norm[2])*v_weight+global_lr_norm[2];

      nx = (x2 - x1) * u_weight + x1;
      ny = (y2 - y1) * u_weight + y1;
      nz = (z2 - z1) * u_weight + z1;

      vector_length = SQRT((nx * nx) + (ny * ny) + (nz * nz));
      point->nx = nx / vector_length;
      point->ny = ny / vector_length;
      point->nz = nz / vector_length;
    }
 }

/*-- HSevaluate_point -------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSevaluate_point( struct HSpoint *point )
#else
	static void HSevaluate_point( point )

	struct
	   HSpoint	*point;
#endif

/*
NAME
	HSevaluate_point (static)

DESCRIPTION
	Takes a point structure & computes its surface & normal coordinates
	from its parametric values by evaluating the B-spline directly.
	This routine is designed to be called for boundary points just before
	they are written out on the pipe.

PARAMETERS
	point (IN/OUT) - the point to evaluate

GLOBALS USED
	global_ul_norm (static)
	global_ll_norm (static)
	global_ur_norm (static)
	global_lr_norm (static)
	active_window
	element_parms.surf_geom

HISTORY
	03/09/88    C.M. Jablonski
	   created
 */

 {
   IGRlong	rc;
   IGRdouble	ptbak[4];
   IGRdouble	u_weight, v_weight, vector_length,
		x1, y1, z1, x2, y2, z2,
		nx, ny, nz;
   IGRboolean	ind[4];
   IGRint	num_deg, *deg_ind = NULL;


   /*
    * Surface point (evaluated)
    */

   ind[0] = 1;
   ind[1] = ind[2] = ind[3] = 0;

   BSsfarrevmt( element_parms.surf_geom, 1, &(point->u), 1, &(point->v),
                ind, ptbak, NULL, NULL, NULL, &num_deg, &deg_ind, &rc );

   if( !active_window->making_triangles )
	transform_points(active_window->perspective,1,ptbak,1);

   point->x = ptbak[0];
   point->y = ptbak[1];
   point->z = ptbak[2];
   if (active_window->perspective) point->w = ptbak[3];

   /*
    * Normal (interpolated and normalized)
    */

   if (element_parms.doing_vertex_normals)
    {
      if( global_uhi == global_ulo )
         u_weight = 0.0;
      else
         u_weight = (point->u - global_ulo) / (global_uhi - global_ulo);
         
      if( global_vhi == global_vlo )
         v_weight = 0.0;
      else
         v_weight = (point->v - global_vlo) / (global_vhi - global_vlo);

      x1 = (global_ul_norm[0]-global_ll_norm[0])*v_weight+global_ll_norm[0];
      y1 = (global_ul_norm[1]-global_ll_norm[1])*v_weight+global_ll_norm[1];
      z1 = (global_ul_norm[2]-global_ll_norm[2])*v_weight+global_ll_norm[2];

      x2 = (global_ur_norm[0]-global_lr_norm[0])*v_weight+global_lr_norm[0];
      y2 = (global_ur_norm[1]-global_lr_norm[1])*v_weight+global_lr_norm[1];
      z2 = (global_ur_norm[2]-global_lr_norm[2])*v_weight+global_lr_norm[2];

      nx = (x2 - x1) * u_weight + x1;
      ny = (y2 - y1) * u_weight + y1;
      nz = (z2 - z1) * u_weight + z1;

      vector_length = SQRT((nx * nx) + (ny * ny) + (nz * nz));
      point->nx = nx / vector_length;
      point->ny = ny / vector_length;
      point->nz = nz / vector_length;
    }
}

/*-- HSset_interp_flag -------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSset_interp_flag(void)
#else
	static void HSset_interp_flag()
#endif

/*
NAME
	HSset_interp_flag (static)

DESCRIPTION
	Sets the interpolation flag, which determines whether or not we can
	use bilinear interpolation from the patch corners to determine the
	viewing coordinates of boundary points.

PARAMETERS
	none

GLOBALS USED
	global_ulo (static)
	global_vlo (static)
	global_uhi (static)
	global_vhi (static)
	interp_flag (static)
	element_parms.interp_tol

HISTORY
	10/13/88   C.M. Jablonski
	   Created
*/

{
struct HSpoint	interp_test_pt, eval_test_pt;

	interp_test_pt.u = eval_test_pt.u = (global_ulo + global_uhi) / 2.0;
	interp_test_pt.v = eval_test_pt.v = (global_vlo + global_vhi) / 2.0;

	HSinterpolate_point( &interp_test_pt );
	HSevaluate_point( &eval_test_pt );

	interp_flag = ((FABS(interp_test_pt.x - eval_test_pt.x) <= element_parms.interp_tol) &&
	               (FABS(interp_test_pt.y - eval_test_pt.y) <= element_parms.interp_tol) &&
	               (FABS(interp_test_pt.z - eval_test_pt.z) <= element_parms.interp_tol));
}


/*-- HSsend_out_polygon -------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSsend_out_polygon( struct HSpoint *pt_list, 
					    IGRboolean default_marks)
#else
	static void		HSsend_out_polygon (pt_list, default_marks)

	register struct HSpoint	*pt_list;	/* input - any pt on the circular list	*/
	IGRboolean		default_marks;	/* input - if TRUE, set all marks to TRUE */
#endif

/*
 * Adds a polygon loop to the current facet being built.
 *
 * HISTORY: 09/01/86 created					S. A. Rapa
 *	    02/07/87 No longer sends out facets to the pipe;	S. A. Rapa
 *		     calls "add_vertex..." instead.
 *	    04/22/88 Checks interp_flag to int/eval bndry;	C. M. Jablonski
 *	    05/15/89 added mark flags				C. M. Jablonski
 */

 {
   register struct
      HSpoint	*stop_pt;
      double	u, v;

   stop_pt = pt_list;
   do
    {
    /*
     *  Have some cases where the list is not circular and we reach a NULL
     *  pointer...   This is an error, so lets just return and dont worry 
     *  about it.  Mike Lanier 2/10/97
     */
 
    if( pt_list == NULL ) return;

      if (interp_flag)
         HSinterpolate_point (pt_list);
      else
         HSevaluate_point (pt_list);
         
	switch( element_parms.render_parms->texture_orientation )
		{
		case 2:
		case 8:
			u = pt_list->u;
			v = 1.0 - pt_list->v;
			break;
			
		case 3:
		case 5:
			u = 1.0 - pt_list->u;
			v = pt_list->v;
			break;
			
		case 4:
		case 7:
			u = 1.0 - pt_list->u;
			v = 1.0 - pt_list->v;
			break;
			
		case 0:
		case 1:
		case 6:
		default:
			u = pt_list->u;
			v = pt_list->v;
			break;
		}


      (*active_window->add_vertex[active_window->active_zbuffer])(
         pt_list->x, pt_list->y, pt_list->z,
         pt_list->w, (pt_list->mark || default_marks),
	 pt_list->nx, pt_list->ny, pt_list->nz,
	 u, v );

#if PLOT_BOUNDS
{
   /* set the boundary color */
   PBenable_region_window();
   PBset_color(7);
   PBclip_and_draw_line(pt_list->u, pt_list->v, pt_list->next->u, pt_list->next->v);
   PBrefresh_window();
   PBenable_facet_window();
   PBset_color(7);
   PBdraw_bound_line(pt_list->u, pt_list->v, pt_list->next->u, pt_list->next->v);
   PBrefresh_window();
}
#endif

      pt_list = pt_list->next;
    }
   while (pt_list != stop_pt);
 }




/******************************************
 * ROUTINES USED IN PREPROCESS_A_BOUNDARY *
 ******************************************/


/*-- HSfind_start -------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSpoint *HSfind_start( struct HSpoint *this_point, 
					     struct HSpoint *stop_point )
#else
	static struct HSpoint *HSfind_start( this_point, stop_point )

	struct
	   HSpoint	*this_point,	/* input - current boundary point	*/
			*stop_point;	/* input - last boundary point		*/
#endif

/*
 * Returns the next point on the current boundary which is the start
 * of a piece NOT on the edge of the UV plane.  Deletes points which 
 * begin segments on the edge.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   struct
      HSpoint	*next_point;
   IGRint	start_found;
   register
      IGRdouble	ua, ub, va, vb;

   ub = this_point->u;
   vb = this_point->v;
   next_point = this_point->next;
   start_found = FALSE;

   do 
    {
      ua = ub;
      va = vb;
      ub = next_point->u;
      vb = next_point->v;
      if (((ua == 0.0) && (ub == 0.0)) ||
      	  ((ua == 1.0) && (ub == 1.0)) ||
          ((va == 0.0) && (vb == 0.0)) ||
      	  ((va == 1.0) && (vb == 1.0))   )
       {
	 HSdispose_point_list (this_point, this_point);
	 this_point = next_point;
	 next_point = this_point->next;
       }
      else
         start_found = TRUE;
    }
   while ((start_found == FALSE) &&
	  (this_point != stop_point));

   return (this_point);
 }


/*-- HSfind_end ---------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSpoint *HSfind_end( struct HSpoint *this_point, 
					   struct HSpoint *stop_point )
#else
	static struct HSpoint *HSfind_end( this_point, stop_point )

	struct
	   HSpoint	*this_point,	/* input - current boundary point	*/
			*stop_point;	/* input - last boundary point		*/
#endif

/*
 * Returns the next-to-last point on the current boundary (where
 * 'last' means either the actual last point or where the boundary begins
 * to run along the edge of the UV plane).  Also moves points in the middle of
 * the boundary (i.e. not endpoints) away from the UV plane edge if they 
 * touch it.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   struct
      HSpoint	*last_point,
		*next_point;
   IGRint	end_found;
   register
      IGRdouble	ua, ub, va, vb;

   last_point = this_point;
   this_point = this_point->next;
   next_point = this_point->next;

   ub = this_point->u;
   vb = this_point->v;
   end_found = FALSE;

   do 
    {
      ua = ub;
      va = vb;
      ub = next_point->u;
      vb = next_point->v;

      if (((ua == 0.0) && (ub == 0.0)) ||
      	  ((ua == 1.0) && (ub == 1.0)) ||
          ((va == 0.0) && (vb == 0.0)) ||
      	  ((va == 1.0) && (vb == 1.0))   )
         end_found = TRUE;

      else
       {

	 /*
	  * Check/correct tangencies to UV plane edge 
          */

         if (ua == 0.0)
	    this_point->u = BOUND_TOL;
         else 
            if (ua == 1.0)
	       this_point->u -= BOUND_TOL;

         if (va == 0.0)
	     this_point->v = BOUND_TOL;
         else 
            if (va == 1.0)
	       this_point->v -= BOUND_TOL;

         last_point = this_point;
	 this_point = next_point;
   	 next_point = this_point->next;
       }
    }
   while ((end_found == FALSE) &&
	  (this_point != stop_point));

   return (last_point);
 }


/*-- HSfix_closed_bound_points ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSfix_closed_bound_points( register struct HSpoint *start_point )
#else
	static void HSfix_closed_bound_points( start_point )

	register struct
	   HSpoint	*start_point;	/* input - current boundary point	*/
#endif

/*
 * Corrects points which are tangent to the UV plane edge by moving them
 * slightly toward the center of the plane.  The amount they are moved
 * is defined by 'BOUND_TOL'.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   register struct
      HSpoint	*stop_point;

#if PLOT_BOUNDS
   register struct
      HSpoint	check_pt;
#endif

   stop_point = start_point;
   do
    {

#if PLOT_BOUNDS
{
      check_pt = *start_point;
}
#endif

      if (start_point->u == 0.0)
	 start_point->u = BOUND_TOL;
      else 
         if (start_point->u == 1.0)
	    start_point->u -= BOUND_TOL;

      if (start_point->v == 0.0)
	 start_point->v = BOUND_TOL;
      else 
         if (start_point->v == 1.0)
	    start_point->v -= BOUND_TOL;

#if PLOT_BOUNDS
{
      if (check_pt.u!=start_point->u || check_pt.v!=start_point->v )
         {
         PBset_color(2);
         PBdraw_bound_line(check_pt.u, check_pt.v, start_point->u, start_point->v);
         PBdraw_big_point(start_point->u, start_point->v);
         PBrefresh_window();
         };
}
#endif

      start_point = start_point->next;
    }
   while (start_point != stop_point);
 }


/*-- HSmove_endpt_from_corners ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSmove_endpt_from_corners( struct HSbound *start_bound, 
					       struct HSbound *end_bound )
#else
	static void HSmove_endpt_from_corners( start_bound, end_bound )

	struct
	   HSbound	*start_bound,	/* input - first boundary to do in list	*/
			*end_bound;	/* input - last boundary to do in list	*/
#endif

/*
 * Moves an open boundary's endpoints away from a corner of the UV plane.
 * All open boundaries are processed in the list between 'start_bound'
 * and 'end_bound' inclusive (which should be those created since the 
 * last call to 'preprocess_a_boundary').  Movement is along the V axis. 
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   register struct
      HSpoint	*point;

#if PLOT_BOUNDS
   register struct
      HSpoint	check_pt;
#endif

   while (start_bound != end_bound)
    {
      point = start_bound->start_pt;
#if PLOT_BOUNDS
{
      check_pt = *point;
}
#endif
      if ((point->u == 0.0) ||
          (point->u == 1.0)   )
         if (point->v == 0.0)
            point->v = BOUND_TOL;
	 else
            if (point->v == 1.0)
               point->v -= BOUND_TOL;

#if PLOT_BOUNDS
{
      if (check_pt.u!=point->u || check_pt.v!=point->v )
         {
         PBset_color(2);
         PBdraw_bound_line(check_pt.u, check_pt.v, point->u, point->v);
         PBdraw_big_point(point->u, point->v);
         PBrefresh_window();
         };
}
#endif

      point = start_bound->end_pt;
#if PLOT_BOUNDS
{
      check_pt = *point;
}
#endif
      if ((point->u == 0.0) ||
          (point->u == 1.0)   )
         if (point->v == 0.0)
            point->v = BOUND_TOL;
	 else
            if (point->v == 1.0)
               point->v -= BOUND_TOL;

#if PLOT_BOUNDS
{
      if (check_pt.u!=point->u || check_pt.v!=point->v )
         {
         PBset_color(2);
         PBdraw_bound_line(check_pt.u, check_pt.v, point->u, point->v);
         PBdraw_big_point(point->u, point->v);
         PBrefresh_window();
         };
}
#endif

      start_bound = start_bound->next;
    }
 }


/*-- HSput_bound --------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSbound *HSput_bound( struct HSpoint *start_pt, 
					    struct HSpoint *next_to_last_pt, 
					    struct HSbound *bound_list)
#else
	static struct HSbound *HSput_bound( start_pt, next_to_last_pt, bound_list)

	struct
	   HSpoint	*start_pt,	/* input - first point of this boundary	*/
			*next_to_last_pt;/*input - second-to-last point in bound*/
	struct
	   HSbound	*bound_list;	/* input - attach cell to this bound list*/
#endif

/*
 * Creates a cell of boundary data & adds it to a list of boundaries,
 * returning the new list.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   struct
      HSbound	*bound;

   bound = HSnew_bound ();
   if (tiling_parms.status != HSSTAT_OK) return (NULL);
   bound->start_pt    = start_pt;
   bound->nxt_last_pt = next_to_last_pt;
   bound->end_pt      = next_to_last_pt->next;
   bound->next        = bound_list;
   return (bound);
 }


/*-- preprocess_a_boundary --------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HSbound *preprocess_a_boundary( struct HSbound *curr_bounds,
						       IGRint num_bound_pts,
						    IGRdouble bound_arr[],
						    IGRdouble ulo,
						    IGRdouble vlo,
						   IGRboolean *origin_is_hole )
#else
	struct HSbound	*preprocess_a_boundary (curr_bounds,
						num_bound_pts, bound_arr,
						ulo, vlo,
						origin_is_hole		 )

	struct
	   HSbound	*curr_bounds;	/* input - previous boundary list	*/
	IGRint		num_bound_pts;	/* input - # of parametric points	*/
	IGRdouble	bound_arr[];	/* input - array of parameters		*/
	IGRdouble	ulo, vlo;	/* input - origin of region of interest */
	IGRboolean	*origin_is_hole;/* i/o - solid/hole status of origin	*/
#endif

/* 
 * Accepts an array of parametric values defining a boundary and
 * translates this info into special data structures (linked lists
 * of boundaries, where each boundary is a linked list of points).
 * While building the structures I make sure that there are no boundaries
 * which run along the edge of the UV plane, are tangent to it, 
 * or have endpoints which lie exactly on a plane corner.  All of these
 * situations could cause problems later when trying to figure out
 * if tile's origin is in a hole or solid zone (which, in turn, affects
 * how facets are constructed using that tile's boundaries).
 * Tangent points are moved away from the edge; corner points
 * are moved away from the corner along the V axis; boundaries which
 * have segments running along an edge are broken up into several 'open'
 * boundaries.  This procedure also updates the solid/hole status of the
 * plane origin (U=0.0, V=0.0).  The latest boundary linked list is returned.
 *
 * HISTORY: 09/01/86 created					S. A. Rapa
 *          11/16/88 Added origin-clip check at end of bound, tossing bounds
 *                   that follow the surface edge.		C. M. Jablonski
 *          01/30/90 Added ulo, vlo and processing.		C. M. Jablonski
 */

 {
   register struct
      HSpoint	*first_point,
		*stop_point,
		*this_point,
		*next_point;
   struct
      HSbound	*last_bound;
   IGRboolean	on_edge, start_edge;
   IGRint	cnt;
   IGRboolean	move_endpts;


   move_endpts = (ulo != 0.0) || (vlo != 0.0);

   last_bound = curr_bounds;

   first_point = HSnew_point ();
   if (tiling_parms.status != HSSTAT_OK) return (NULL);
   first_point->u = bound_arr[0];
   first_point->v = bound_arr[1];
   this_point = first_point;
   next_point = this_point->next;
   stop_point = NIL_POINT;

   /*
    * Determine if the segment connecting the first & last points
    * lies on an edge of the UV plane.
    */

   num_bound_pts -= 1;
   num_bound_pts *= 2;
   if (bound_arr[0] == bound_arr[num_bound_pts - 2])
      if ((bound_arr[0] == 0.0) ||
          (bound_arr[0] == 1.0)   )
         start_edge = on_edge = TRUE;
      else
         start_edge = on_edge = FALSE;
   else
      if (bound_arr[1] == bound_arr[num_bound_pts - 1])
         if ((bound_arr[1] == 0.0) ||
             (bound_arr[1] == 1.0)   )
            start_edge = on_edge = TRUE;
         else
            start_edge = on_edge = FALSE;
      else
         start_edge = on_edge = FALSE;
   
   for (cnt = 2; cnt < num_bound_pts; cnt += 2)
    {
      /*
       * Get rid of identical adjacent points
       */
     
      if ((bound_arr[cnt]     != bound_arr[cnt - 2]) ||
          (bound_arr[cnt + 1] != bound_arr[cnt - 1])   )
       {
         next_point = HSnew_point ();
         if (tiling_parms.status != HSSTAT_OK) return (NULL);
         next_point->u = bound_arr[cnt];
         next_point->v = bound_arr[cnt + 1];
         this_point->next = next_point;

         /*
          * Find a point where the boundary leaves the UV plane edge
          */

         if (stop_point == NIL_POINT)
            if (((this_point->u == 0.0) && (next_point->u == 0.0)) ||
                ((this_point->u == 1.0) && (next_point->u == 1.0)) ||
                ((this_point->v == 0.0) && (next_point->v == 0.0)) ||
                ((this_point->v == 1.0) && (next_point->v == 1.0))   )
	       on_edge = TRUE;
	    else
	       if (on_edge == TRUE)
		  stop_point = this_point;
	       else
	   	  on_edge = FALSE;

	 /*
	  * Flip solid/hole status of origin if clipped by this boundary.
          */

         if ((this_point->v == 0.0) &&
             (next_point->v == 0.0)   )
            if ((this_point->u == 0.0) ||
                (next_point->u == 0.0)   )
               *origin_is_hole = ~(*origin_is_hole);

         this_point = next_point;
       }
    }
   this_point->next = first_point;

   /*
    * Flip solid/hole status of origin if clipped by the last segment of this boundary.
    */

   if ((this_point->v == 0.0) &&
        (this_point->next->v == 0.0)   )
      if ((this_point->u == 0.0) ||
         (this_point->next->u == 0.0)   )
         *origin_is_hole = ~(*origin_is_hole);

   /*
    * If (stop_point == NIL_POINT) then the boundary is either: 
    *    1) a closed loop that does not touch any edge of the surface, or
    *    2) a closed loop that traces along the edge of the surface, or
    *    3) a closed loop that traces along the edge of the surface, EXCEPT
    *       for the last span of the loop.
    * If this is case (1), then on_edge equals FALSE, and we need to process
    * the boundary as a closed boundary.  If this is case (2) then on_edge = 
    * start_edge = TRUE and we can toss out this boundary.  If this is case (3)
    * then on_edge = TRUE while start_edge = FALSE, and we need to process 
    * the boundary as a set of open boundaries.
    */
 
   if ((on_edge == TRUE) && (start_edge == FALSE) && (stop_point == NIL_POINT))
      stop_point = this_point;

   if (stop_point == NIL_POINT)
    {
      if (on_edge != TRUE)
       {
         HSfix_closed_bound_points (first_point);
         curr_bounds = HSput_bound (first_point->next, first_point, curr_bounds);
         if (tiling_parms.status != HSSTAT_OK) return (NULL);
       }
    }
   else
    {
      this_point = stop_point;
      do         
       {
         /*
          * Adjust the endpoint so as to keep the solid/hole status of (ulo, vlo)
          * equal to the solid/hole status of the origin.  -CMJ  01/30/90
          */
         if ((move_endpts) && (this_point->u == ulo) && (this_point->v == vlo))
            if (this_point->next->u == ulo)
               this_point->v += BOUND_TOL;
            else
               this_point->u += BOUND_TOL;

         first_point = this_point;
         this_point = HSfind_end (first_point, stop_point);

         /*
          * Adjust the endpoint so as to keep the solid/hole status of (ulo, vlo)
          * equal to the solid/hole status of the origin.  -CMJ  01/30/90
          */
         if ((move_endpts) && (this_point->u == ulo) && (this_point->v == vlo))
            if (this_point->next->u == ulo)
               this_point->v += BOUND_TOL;
            else
               this_point->u += BOUND_TOL;

         curr_bounds = HSput_bound (first_point, this_point, curr_bounds);
         if (tiling_parms.status != HSSTAT_OK) return (NULL);
         this_point = this_point->next;

         if (this_point != stop_point)
          {
            this_point = this_point->next;
            if (this_point != stop_point)
	       this_point = HSfind_start (this_point, stop_point);
          }
       }
      while (this_point != stop_point);
      HSmove_endpt_from_corners (curr_bounds, last_bound);
    }

   return (curr_bounds);
 }


/************************************
 * ROUTINES USED IN SIFT_BOUNDARIES *
 ************************************/


/*-- HSfind_bound_patch_xsect -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSpoint *HSfind_bound_patch_xsect(
					struct HSpoint *start_pt,
					struct HSpoint *stop_pt,
					     IGRdouble ulo,
					     IGRdouble vlo,
					     IGRdouble uhi,
					     IGRdouble vhi )
#else
	static struct HSpoint	*HSfind_bound_patch_xsect (start_pt, stop_pt,
						 ulo, vlo, uhi, vhi)

	struct
	   HSpoint	*start_pt,	/* input - boundary start point		*/
			*stop_pt;	/* input - boundary stop point		*/
	IGRdouble	ulo, vlo,	/* input - patch range diagonal		*/
			uhi, vhi;
#endif

/*
 * Scans along a boundary until it finds the first point which intersects
 * a patch edge.  If such a point is found, it is returned; otherwise
 * NIL_POINT is returned.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   register
      IGRdouble	u, v;
   IGRboolean 	end_found;

   end_found = FALSE;
   do
    {
      u = start_pt->u;
      v = start_pt->v;

      if ((v == vlo) ||
	  (v == vhi)   )
         if ((u >= ulo) &&
	     (u <= uhi)   )
            end_found = TRUE;
         else
            start_pt = start_pt->next;

      else
         if ((u == ulo) ||
	     (u == uhi)   )
            if ((v >= vlo) &&
	        (v <= vhi)   )
               end_found = TRUE;
            else
               start_pt = start_pt->next;

         else
            start_pt = start_pt->next;
    }
   while ((end_found == FALSE) &&
  	  (start_pt != stop_pt));

   if (end_found == TRUE)
      return (start_pt);
   else
      return (NIL_POINT);
 }


/*-- HSfind_start_of_bound ----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSpoint *HSfind_start_of_bound(
					struct HSpoint *this_pt,
					struct HSpoint *stop_pt,
					     IGRdouble ulo,
					     IGRdouble vlo,
					     IGRdouble uhi,
					     IGRdouble vhi )
#else
	static struct HSpoint	*HSfind_start_of_bound (this_pt, stop_pt,
						      ulo, vlo, uhi, vhi)

	struct
	   HSpoint	*this_pt,	/* input - boundary start point		*/
			*stop_pt;	/* input - boundary stop point		*/
	IGRdouble	ulo, vlo,	/* input - patch range diagonal		*/
			uhi, vhi;
#endif

/*
 * Scans along a boundary until it finds an intersection with the
 * patch whose successor is also within the patch (i.e. this is 
 * the first point of a boundary segment which cuts through the patch).  If
 * such a point is found, it is returned; otherwise NIL_POINT is returned.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   register
      IGRdouble	ua, va, ub, vb;
   IGRboolean 	start_found;
   struct
      HSpoint	*next_pt;

   start_found = FALSE;
   ub = this_pt->u;
   vb = this_pt->v;
   next_pt = this_pt->next;

   do
    {
      ua = ub;
      va = vb;
      ub = next_pt->u;
      vb = next_pt->v;
      if ((va >= vlo) &&
          (va <= vhi) &&
          (vb >= vlo) &&
          (vb <= vhi) &&
          (ua >= ulo) &&
          (ua <= uhi) &&
          (ub >= ulo) &&
          (ub <= uhi)   )
         start_found = TRUE;
      else
       {
         this_pt = next_pt;
         next_pt = this_pt->next;
       }
    }
   while ((start_found == FALSE) &&
  	  (this_pt != stop_pt)     );

   if (start_found == TRUE)
      return (this_pt);
   else
      return (NIL_POINT);
 }


/*-- HSfind_end_of_bound ------------------------------------------------------*/


#if defined(__STDC__) || defined(__cplusplus)
	static struct HSpoint *HSfind_end_of_bound(
					struct HSpoint *this_pt,	/* input - current boundary point	*/
					     IGRdouble ulo,
					     IGRdouble vlo,
					     IGRdouble uhi,
					     IGRdouble vhi )
#else
	static struct HSpoint	*HSfind_end_of_bound (this_pt,
						    ulo, vlo, uhi, vhi)

	struct
	   HSpoint	*this_pt;	/* input - current boundary point	*/
	IGRdouble	ulo, vlo, 	/* input - range diagonal of patch	*/
			uhi, vhi;
#endif

/*
 * Skips to the next point on the boundary which intersects a patch
 * edge and returns the PREVIOUS point.  Such an intersection must exist
 * or this routine will hang.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   IGRdouble	u, v;
   IGRboolean	end_found;
   struct
      HSpoint	*next_pt;

   next_pt = this_pt->next;
   end_found = FALSE;
   while (end_found == FALSE)
    {
      u = next_pt->u;
      v = next_pt->v;
      if ((v == vlo) ||
	  (v == vhi) ||
	  (u == ulo) ||
	  (u == uhi)   )
         end_found = TRUE;
      else
       {
         this_pt = next_pt;
         next_pt = this_pt->next;
       }
    }

   return (this_pt);
 }


/*-- HSsift_into_open_bounds --------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSbound *HSsift_into_open_bounds(
					struct HSpoint *start_pt,
					struct HSpoint *stop_pt,
					     IGRdouble ulo,
					     IGRdouble vlo,
					     IGRdouble uhi,
					     IGRdouble vhi,
					struct HSbound *bound_list )
#else
	static struct HSbound	*HSsift_into_open_bounds (start_pt, stop_pt,
							ulo, vlo, uhi, vhi,
							bound_list)

	struct
	   HSpoint	*start_pt,	/* input - boundary start point		*/
			*stop_pt;	/* input - boundary end point		*/
	IGRdouble	ulo, vlo,	/* input - patch range diagonal		*/
			uhi, vhi;
	struct
	   HSbound	*bound_list;	/* input - current bound list for patch	*/
#endif

/*
 * Searches a boundary and creates a new boundary cell for each piece which
 * cuts through the given patch.  These cells are attached to an existing
 * list and the resulting list is then returned.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   register struct
      HSbound	*this_bound;
   register struct
     HSpoint	*this_pt;

   this_pt = HSfind_start_of_bound (start_pt, stop_pt, ulo, vlo, uhi, vhi);
   while (this_pt != NIL_POINT)
    {
      this_bound = HSnew_bound ();
      if (tiling_parms.status != HSSTAT_OK) return (NULL);
      this_bound->next = bound_list;
      bound_list = this_bound;
      this_bound->start_pt = this_pt;
      this_pt = HSfind_end_of_bound (this_pt, ulo, vlo, uhi, vhi);
      this_bound->nxt_last_pt = this_pt;
      this_pt = this_pt->next;
      this_bound->end_pt = this_pt;

      if (this_pt != stop_pt)
         this_pt = HSfind_start_of_bound (this_pt, stop_pt,
					ulo, vlo, uhi, vhi);
      else
	 this_pt = NIL_POINT;
    }

   return (bound_list);
 }


/*-- sift_boundaries --------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HSbound *sift_boundaries( struct HSbound *master_bound_list,
					      IGRdouble ulo,
					      IGRdouble vlo,
					      IGRdouble uhi,
					      IGRdouble vhi )
#else
	struct HSbound	*sift_boundaries (master_bound_list,
					  ulo, vlo, uhi, vhi)

	struct
	   HSbound	*master_bound_list;	/* input - original bound list	*/
	IGRdouble	ulo, vlo, uhi, vhi;	/* input - patch's range diag.	*/
#endif

/*
 * Searches a list of boundaries & returns a list of boundaries which
 * are pieces of the originals that cut a given patch or are
 * completely contained within the patch.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   struct
      HSbound	*bound_list,
		*this_bound;
   struct
      HSpoint	*new_start_pt,
		*stop_point,
		*current_point;

   bound_list = NIL_BOUND;

   while (master_bound_list != NIL_BOUND)
    {
      current_point = master_bound_list->start_pt;
      stop_point = master_bound_list->end_pt;

      /*
       * Closed boundaries don't necessarily have end points which lie
       * on a patch side.  This could cause poblems, so advance to 
       * a point on the loop which does (if one exists).
       */

      if (current_point == stop_point)
       {
         new_start_pt = HSfind_bound_patch_xsect (current_point, stop_point, 
					        ulo, vlo, uhi, vhi);
         if (new_start_pt != NIL_POINT)
          {
            bound_list = HSsift_into_open_bounds (new_start_pt, new_start_pt,
					       ulo, vlo, uhi, vhi, bound_list);
            if (tiling_parms.status != HSSTAT_OK) return (NULL);
          }
         else
   
            /*
             * Closed boundary doesn't intersect the patch ... add it to the
             * list if it is contained within the patch.
	     */

            if ((ulo < current_point->u) &&
                (uhi > current_point->u) &&
                (vlo < current_point->v) &&
                (vhi > current_point->v)   )
             {
               this_bound = HSnew_bound ();
               if (tiling_parms.status != HSSTAT_OK) return (NULL);
   	       this_bound->next = bound_list;
	       bound_list = this_bound;
	       this_bound->start_pt    = master_bound_list->start_pt;
	       this_bound->nxt_last_pt = master_bound_list->nxt_last_pt;
	       this_bound->end_pt      = master_bound_list->end_pt;
             }
       }

      else

       {
	 /*
	  * Processing an open boundary ... no need to special case.
	  */

         bound_list = HSsift_into_open_bounds (current_point, stop_point,
					     ulo, vlo, uhi, vhi, bound_list);
         if (tiling_parms.status != HSSTAT_OK) return (NULL);
       }

      master_bound_list = master_bound_list->next;
    }

   return (bound_list); 
 }


/********************************************
 * ROUTINES USED IN BUILD_INTERSECTION_LIST *
 ********************************************/


/*-- HScopy_point -------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSpoint *HScopy_point( struct HSpoint *pt )
#else
	static struct HSpoint *HScopy_point( pt )

	struct HSpoint	*pt;	/* input - original point structure	*/
#endif

/*
 * Allocates a point structure & copies another's parameteric values
 * to it.  The address of this new structure is returned.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   struct
      HSpoint	*newpt;

   newpt = HSnew_point ();
   if (tiling_parms.status != HSSTAT_OK) return (NULL);
   newpt->u = pt->u;
   newpt->v = pt->v;
   return (newpt);
 }


/*-- HSadd_intersection_to_list -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSxsect	*HSadd_intersection_to_list (
					struct HSxsect *xsect_pt,
					struct HSxsect *intersection_list )
#else
	static struct HSxsect	*HSadd_intersection_to_list (xsect_pt, intersection_list)

	struct HSxsect	*xsect_pt;		/* input - intersection cell	*/
	struct HSxsect	*intersection_list;	/* input - intersection list	*/
#endif

/*
 * Adds a boundary/patch intersection point to the current list and
 * returns the resulting list.  Note that these intersections are not
 * simply point structures, but instead are special structures which 
 * are ordered the way their corresponding intersection points would
 * be found if one traversed the patch's edges clockwise from the lower
 * left corner.
 *
 *     xsect_pt            [input] intersection cell
 *     intersection_list   [input] intersection list
 *
 * HISTORY: 09/01/86 Created.					S. A. Rapa
 *          01/05/90 Add duplicate xsects in the correct order.	C. M. Jablonski
 */

 {
   IGRdouble	sort_key;
   IGRshort	side_cut;
   IGRboolean	found;
   register struct
      HSxsect	*prev_xsect,
		*this_xsect;

   side_cut = xsect_pt->side_cut;
   sort_key = xsect_pt->sort_key;

#if PLOT_BOUNDS
{
   PBdraw_big_point( xsect_pt->bndry->u, xsect_pt->bndry->v );
   PBrefresh_window();
}
#endif

   if (intersection_list == NIL_XSECT)
    {
      xsect_pt->next    = NIL_XSECT;
      intersection_list = xsect_pt;
    }
   
   else
    {
      if ((side_cut > intersection_list->side_cut) ||
          ((side_cut == intersection_list->side_cut) &&
           (sort_key > intersection_list->sort_key)))
       {
         found = FALSE;
         this_xsect = intersection_list;
         do
          {
            prev_xsect = this_xsect;
            this_xsect = this_xsect->next;
            if (this_xsect == NIL_XSECT)
               found = TRUE;
	    else if ((side_cut < this_xsect->side_cut) ||
                     ((side_cut == this_xsect->side_cut) &&
                      (sort_key <= this_xsect->sort_key)))
               found = TRUE;
          }
         while (found == FALSE);

         /*
          * Insert duplicate intersections in the correct order.
          */
         while ((this_xsect) &&
                (this_xsect->bndry->u == xsect_pt->bndry->u) &&  
                (this_xsect->bndry->v == xsect_pt->bndry->v) &&
                ((this_xsect->other_end->side_cut > xsect_pt->other_end->side_cut) || 
                 ((this_xsect->other_end->side_cut == xsect_pt->other_end->side_cut) && 
                  (this_xsect->other_end->sort_key > xsect_pt->other_end->sort_key)))) 
          {
            prev_xsect = this_xsect;
            this_xsect = this_xsect->next;
          }  

         prev_xsect->next = xsect_pt;
         xsect_pt->next   = this_xsect;
       }

      else if ((intersection_list->bndry->u == xsect_pt->bndry->u) &&  
               (intersection_list->bndry->v == xsect_pt->bndry->v) &&
               ((intersection_list->other_end->side_cut > xsect_pt->other_end->side_cut) || 
                ((intersection_list->other_end->side_cut == xsect_pt->other_end->side_cut) && 
                 (intersection_list->other_end->sort_key > xsect_pt->other_end->sort_key)))) 
       {
         /*
          * Insert duplicate intersections in the correct order.
          */
         prev_xsect = intersection_list;
         this_xsect = intersection_list->next;
         while ((this_xsect) &&
                (this_xsect->bndry->u == xsect_pt->bndry->u) &&  
                (this_xsect->bndry->v == xsect_pt->bndry->v) &&
                ((this_xsect->other_end->side_cut > xsect_pt->other_end->side_cut) || 
                 ((this_xsect->other_end->side_cut == xsect_pt->other_end->side_cut) && 
                  (this_xsect->other_end->sort_key > xsect_pt->other_end->sort_key)))) 
          {
            prev_xsect = this_xsect;
            this_xsect = this_xsect->next;
          }  

         prev_xsect->next = xsect_pt;
         xsect_pt->next   = this_xsect;
       }

      else
       {
         /*
          * Add cell to front of list.
          */
         xsect_pt->next    = intersection_list;
         intersection_list = xsect_pt;
       }
    }

   return (intersection_list);
 }


/*-- HSbuild_intersection_list -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSxsect *HSbuild_intersection_list(IGRdouble ulo, 
							 IGRdouble uhi, 
							 IGRdouble vhi, 
						    struct HSbound *patch_bounds, 
							IGRboolean ll_corner_solid )
#else
	static struct HSxsect	*HSbuild_intersection_list (ulo, uhi, vhi,
							  patch_bounds, ll_corner_solid)

	struct HSbound	*patch_bounds;	/* input - list of patch's boundaries	*/
	IGRdouble	ulo, uhi, vhi;	/* input - patch's range 		*/
	IGRboolean	ll_corner_solid;/* input - solid/hole status of LL corner*/
#endif

/*
 * Takes all of the boundaries associated with this patch and returns
 * an ordered list of patch/boundary intersection points (see 
 * 'HSadd_intersection_to_list').  This list will eventually be traversed
 * in order to construct polygons from the patch's corners & boundary
 * points.
 *
 *ARGUMENT LIST
 *     patch_bounds   [INPUT] list of patch's boundaries
 *     ulo, uhi, vhi  [INPUT] patch's range
 *     corner_solid   [INPUT] solid/hole status of LL corner
 *
 * HISTORY: 09/01/86 Created.				S. A. Rapa
 *          01/05/90 Delay adding to xsect list until other_end fields
 *                   are defined.			C. M. Jablonski
 */

 {
   register struct
      HSxsect	*i_list,
		*start_xsect,
		*end_xsect;
   struct
      HSpoint	*start_pt,
		*nxt_last_pt,
		*end_pt,
		*temp_pt;

   i_list = NIL_XSECT;
   
   while (patch_bounds != NIL_BOUND)
    {

      /*
       * While building the list, make copies of the boundary/patch
       * intersection points so that adjacent patches are not affected.
       */

      start_pt      = patch_bounds->start_pt;
      nxt_last_pt   = patch_bounds->nxt_last_pt;
      end_pt        = patch_bounds->end_pt;

#if PLOT_BOUNDS
{
      /* plot this boundary */
      PBset_color(6);
      temp_pt=patch_bounds->start_pt;
      PBdraw_bound_line(temp_pt->u, temp_pt->v, temp_pt->next->u, temp_pt->next->v);
      for ( temp_pt=temp_pt->next; temp_pt!=patch_bounds->end_pt; temp_pt=temp_pt->next)
         PBdraw_bound_line(temp_pt->u, temp_pt->v, temp_pt->next->u, temp_pt->next->v);
      PBdraw_point(temp_pt->u, temp_pt->v);
      PBrefresh_window();
      PBset_color(4);
}
#endif

      if (start_pt != end_pt)
       {
         /*
          * Boundary start point
          */

         if (((start_pt->u == uhi) && (uhi != 1.0)) ||
             ((start_pt->v == vhi) && (vhi != 1.0))   )
          {
            temp_pt = HScopy_point (start_pt);
            if (tiling_parms.status != HSSTAT_OK) goto wrapup;
            temp_pt->next = start_pt->next;
            if (nxt_last_pt == start_pt)
               nxt_last_pt = temp_pt;
            patch_bounds->start_pt = start_pt = temp_pt;
          }
      
         start_xsect = HSnew_xsect ();
         if (tiling_parms.status != HSSTAT_OK) return (NULL);
         start_xsect->is_start = TRUE;
         start_xsect->bndry = start_pt;
         start_xsect->bnd_hdr = patch_bounds;

         if (start_pt->u == ulo)
          {
            start_xsect->sort_key = start_pt->v;
            start_xsect->side_cut = 0;
          }
         else
   	    if (start_pt->v == vhi)
             {
               start_xsect->sort_key = start_pt->u;
               start_xsect->side_cut = 1;
             }
            else
               if (start_pt->u == uhi)
                {
                  start_xsect->sort_key = 0.0 - start_pt->v;
                  start_xsect->side_cut = 2;
                }

               else
                {
                  start_xsect->sort_key = 0.0 - start_pt->u;
                  start_xsect->side_cut = 3;
                }


         /*
          * Boundary end point
          */

         if (((end_pt->u == uhi) && (uhi != 1.0)) ||
             ((end_pt->v == vhi) && (vhi != 1.0))   )
          {
            temp_pt = HScopy_point (end_pt);
            if (tiling_parms.status != HSSTAT_OK) goto wrapup;
            nxt_last_pt->next = temp_pt;
            patch_bounds->end_pt = end_pt = temp_pt;
	  }
      
         end_xsect = HSnew_xsect ();
         if (tiling_parms.status != HSSTAT_OK) return (NULL);
         end_xsect->is_start = FALSE;
         end_xsect->bndry = end_pt;
         end_xsect->bnd_hdr = patch_bounds;

         if (end_pt->u == ulo)
          {
            end_xsect->sort_key = end_pt->v;
            end_xsect->side_cut = 0;
          }
         else
   	    if (end_pt->v == vhi)
             {
               end_xsect->sort_key = end_pt->u;
               end_xsect->side_cut = 1;
             }
            else
               if (end_pt->u == uhi)
                {
                  end_xsect->sort_key = 0.0 - end_pt->v;
                  end_xsect->side_cut = 2;
                }
               else
                {
                  end_xsect->sort_key = 0.0 - end_pt->u;
                  end_xsect->side_cut = 3;
                }

         start_xsect->other_end = end_xsect;
         end_xsect->other_end   = start_xsect;

         /*
          * Delay adding to intersection list until now so that
          * other_end fields will be defined.  - CMJ  01/05/90
          */

#if PLOT_BOUNDS
{
      PBset_color(4);
}
#endif
         i_list = HSadd_intersection_to_list (start_xsect, i_list);
         i_list = HSadd_intersection_to_list (end_xsect, i_list);
       }

      patch_bounds = patch_bounds->next;
    }

   /*
    * Set up intersections so that we start searching from a hole
    */

   if ((ll_corner_solid != FALSE) &&
       (i_list != NIL_XSECT)        )
    {
      end_xsect = i_list;
      while (end_xsect->next != NIL_XSECT)
         end_xsect = end_xsect->next;
      end_xsect->next = i_list;
      i_list = i_list->next;
      end_xsect->next->next = NIL_XSECT;   
    }

wrapup:
   return (i_list);
 }


/***************************************
 * ROUTINES USED IN CONSTRUCT_POLYGONS *
 ***************************************/


/*-- HSmake_point -------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSpoint *HSmake_point( IGRdouble u, IGRdouble v )
#else
	static struct HSpoint *HSmake_point( u, v )

	IGRdouble	u, v;		/* input - parametric values		*/
#endif

/*
 * Allocates a point structure, loads it with parametric values, and
 * returns its address.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   struct
      HSpoint	*newpt;

   newpt = HSnew_point ();
   if (tiling_parms.status != HSSTAT_OK) return (NULL);
   newpt->u = u;
   newpt->v = v;

   return (newpt);
 }


/*-- HSreverse_boundary ------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSreverse_boundary( struct HSxsect *intersection )
#else
	static void HSreverse_boundary( intersection )

	struct
	   HSxsect	*intersection;	/* input - intersection cell of boundary
						   to be flipped around		*/
#endif

/*
 * Reverses the order of linkage for a boundary (i.e the old head becomes
 * the new tail and vice-versa).
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   register struct
      HSpoint	*this_point,
		*stop_point,
		*next_point,
		*save_next;

   stop_point = intersection->bndry;
   this_point = intersection->other_end->bndry;
   next_point = this_point->next;
   intersection->is_start = TRUE;
   intersection->other_end->is_start = FALSE;

   while (this_point != stop_point)
    {
      save_next = next_point->next;
      next_point->next = this_point;
      this_point = next_point;
      next_point = save_next;
    }

#if PLOT_BOUNDS
{
   PBset_color(4);
   this_point = intersection->bndry;
   stop_point = intersection->other_end->bndry;
   while (this_point != stop_point)
    {
    PBdraw_bound_line(this_point->u, this_point->v, this_point->next->u, this_point->next->v);
    this_point = this_point->next;
    }
  PBdraw_point(this_point->u, this_point->v);
  PBrefresh_window();
}
#endif

 }


/*-- HSadjust_equal_xsects -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSxsect	*HSadjust_equal_xsects( struct HSxsect *xsect_list )
#else
	static struct HSxsect	*HSadjust_equal_xsects (xsect_list)

	struct HSxsect	*xsect_list;	/* input - list of patch's xsects	*/
#endif

/*
 * Analyzes all intersections and adjusts those that are equal.  If
 * an open boundary has equal starting and ending xsects, then that bound
 * is linked to itself to form a closed boundary.  If a pair of bounds
 * has equal xsects at both ends, then the bounds are joined together
 * to form a single closed boundary.  If a pair of bounds has equal xsects
 * at only one end, then that end is joined to form a single open boundary.
 *
 *ARGUMENTS
 *     xsect_list     [input] list of patch's xsects
 *
 * HISTORY: 01/03/90 Created.			C. M. Jablonski
 */

 {
   struct
      HSxsect	*xsect,
		*prev,
		*next;

   struct
      HSpoint	*save_pt;


   for (prev = NIL_XSECT, xsect = xsect_list, next = xsect_list->next;
        (xsect != NIL_XSECT) && (next != NIL_XSECT);
        prev = xsect, xsect = next, next = next->next)
    {
      if ((xsect->bndry->u == next->bndry->u) &&
          (xsect->bndry->v == next->bndry->v))
       {
#if PLOT_BOUNDS
{
PBset_color(6);
PBdraw_big_point(xsect->bndry->u, xsect->bndry->v);
}
#endif
         if (xsect->other_end == next)
          {
            /*
             * Link the ends together to form a closed boundary.
             */
            xsect->bnd_hdr->end_pt->next = xsect->bnd_hdr->start_pt;

            /*
             * Adjust the boundary header.
             */
            xsect->bnd_hdr->nxt_last_pt = xsect->bnd_hdr->end_pt;
            xsect->bnd_hdr->end_pt = xsect->bnd_hdr->start_pt;
          }
         else
          {
            /*
             * Adjust the directions of the boundaries.
             */
            if (!xsect->is_start)
             {
               save_pt = xsect->bnd_hdr->start_pt;
               xsect->bnd_hdr->start_pt = xsect->bnd_hdr->end_pt;
               xsect->bnd_hdr->nxt_last_pt = save_pt->next;
               xsect->bnd_hdr->end_pt = save_pt;
               HSreverse_boundary(xsect);
             }

            if (next->is_start)
             {
               save_pt = next->bnd_hdr->start_pt;
               next->bnd_hdr->start_pt = next->bnd_hdr->end_pt;
               next->bnd_hdr->nxt_last_pt = save_pt->next;
               next->bnd_hdr->end_pt = save_pt;
               HSreverse_boundary(next->other_end);
             }

            /*
             * Link the two boundaries together at this end to
             * form a single open boundary.
             */
            next->bnd_hdr->end_pt->next = xsect->bndry;

            /*
             * Adjust the boundary headers.
             */
            next->bnd_hdr->nxt_last_pt = xsect->bnd_hdr->nxt_last_pt;
            next->bnd_hdr->end_pt = xsect->bnd_hdr->end_pt;

            /*
             * Adjust the intersections at the other end.
             */
            xsect->other_end->bnd_hdr = next->bnd_hdr;
            xsect->other_end->other_end = next->other_end;
            next->other_end->other_end = xsect->other_end;
          }

         /*
          * Delete these two intersections from the intersection list.
          */

         if (xsect == xsect_list)
          {
            xsect_list = next->next; 
          }
         else
          {
            prev->next = next->next;
          }
         HSdispose_xsect_list(xsect, xsect);
         xsect = prev;
         prev = next->next;
         HSdispose_xsect_list(next, next);
         next = prev;
       }
       
     if( next == NULL ) break;
    }

   /*
    * Compare the first and last xsects.
    */

   if ((xsect_list != NIL_XSECT) && (xsect_list->next != NIL_XSECT))
    {
      for (prev = xsect_list, xsect = prev->next;
           xsect->next != NIL_XSECT;
           prev = xsect, xsect = prev->next);
      next = xsect_list;
      if ((xsect->bndry->u == next->bndry->u) &&
          (xsect->bndry->v == next->bndry->v))
       {
#if PLOT_BOUNDS
{
PBset_color(6);
PBdraw_big_point(xsect->bndry->u, xsect->bndry->v);
}
#endif
         if (xsect->other_end == next)
          {
            /*
             * Link the ends together to form a closed boundary.
             */
            xsect->bnd_hdr->end_pt->next = xsect->bnd_hdr->start_pt;

            /*
             * Adjust the boundary header.
             */
            xsect->bnd_hdr->nxt_last_pt = xsect->bnd_hdr->end_pt;
            xsect->bnd_hdr->end_pt = xsect->bnd_hdr->start_pt;
          }
         else
          {
            /*
             * Adjust the directions of the boundaries.
             */
            if (!xsect->is_start)
             {
               save_pt = xsect->bnd_hdr->start_pt;
               xsect->bnd_hdr->start_pt = xsect->bnd_hdr->end_pt;
               xsect->bnd_hdr->nxt_last_pt = save_pt->next;
               xsect->bnd_hdr->end_pt = save_pt;
               HSreverse_boundary(xsect);
             }

            if (next->is_start)
             {
               save_pt = next->bnd_hdr->start_pt;
               next->bnd_hdr->start_pt = next->bnd_hdr->end_pt;
               next->bnd_hdr->nxt_last_pt = save_pt->next;
               next->bnd_hdr->end_pt = save_pt;
               HSreverse_boundary(next->other_end);
             }

            /*
             * Link the two boundaries together at this end to
             * form a single open boundary.
             */
            next->bnd_hdr->end_pt->next = xsect->bndry;

            /*
             * Adjust the boundary headers.
             */
            next->bnd_hdr->nxt_last_pt = xsect->bnd_hdr->nxt_last_pt;
            next->bnd_hdr->end_pt = xsect->bnd_hdr->end_pt;

            /*
             * Adjust the intersections at the other end.
             */
            xsect->other_end->bnd_hdr = next->bnd_hdr;
            xsect->other_end->other_end = next->other_end;
            next->other_end->other_end = xsect->other_end;
          }
 
         /*
          * Delete these two intersections from the intersection list.
          */

         prev->next = NIL_XSECT;
         xsect_list = xsect_list->next; 
         HSdispose_xsect_list(xsect, xsect);
         HSdispose_xsect_list(next, next);
       }
    }
   return (xsect_list);
}


/*-- HSlink_bound_to_horiz_side -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSlink_bound_to_horiz_side( register struct HSpoint *point, 
						register struct HSpoint *side )
#else
	static void HSlink_bound_to_horiz_side( point, side )

	register struct
	   HSpoint	*point,		/* input - end point of boundary	*/
			*side;		/* input - list of points along side	*/
#endif

/*
 * Attaches the endpoint of a boundary to a patch side to help create
 * a polygon, where this polygon is simply a list of point structures
 * linked via their 'next' fields.  Points along the side are assumed
 * to all have identical V values.
 *
 * HISTORY: 09/01/86 Created					S. A. Rapa
 *          03/01/89 Enabled points with duplicate u and v values to be
 *                   inserted before equal points in the list.	C. M. Jablonski
 */

 {
   register struct
      HSpoint	*prev, *stop;

#if PLOT_BOUNDS
{
   PBset_color(1);
   PBdraw_big_point(point->u, point->v);
   PBrefresh_window();
}
#endif

   stop = side;

   do 
    {
      prev = side;
      side = side->next_along_side;
    }
   while (((point->u < side->u) || (point->u >= prev->u)) &&
          ((point->u > side->u) || (point->u <= prev->u)) &&
          (side!=stop));

   if ((side==stop) &&
       ((point->u < side->u) || (point->u >= prev->u)) &&
       ((point->u > side->u) || (point->u <= prev->u)))
    {
      HSset_status( HSSTAT_BOUND_ERROR );
      goto wrapup;
    }

   point->next            = side;
   point->next_along_side = side;
   prev->next_along_side  = point;

#if PLOT_BOUNDS
{
   PBset_color(1);
   PBdraw_bound_line(prev->u, prev->v, point->u, point->v);
   PBset_color(3);
   PBdraw_bound_line(point->u, point->v, side->u, side->v);
   PBdraw_point(side->u, side->v);
   PBrefresh_window();
}
#endif

   if ((prev->v!=point->v) && (point->v!=side->v)) HSset_status( HSSTAT_BOUND_ERROR );

wrapup:;
 }


/*-- HSlink_bound_to_vert_side ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HSlink_bound_to_vert_side( register struct HSpoint *point, 
					      register struct HSpoint *side )
#else
	static int HSlink_bound_to_vert_side( point, side )
	
	register struct
	   HSpoint	*point,		/* input - end point of boundary	*/
			*side;		/* input - list of points along side	*/
#endif

/*
 * Attaches the endpoint of a boundary to a patch side to help create
 * a polygon, where this polygon is simply a list of point structures
 * linked via their 'next' fields.  Points along the side are assumed 
 * to all have identical U values.
 *
 * HISTORY: 09/01/86 Created					S. A. Rapa
 *          03/01/89 Enabled points with duplicate u and v values to be
 *                   inserted before equal points in the list.	C. M. Jablonski
 */

 {
   register struct
      HSpoint	*prev, *stop;

#if PLOT_BOUNDS
{
   PBset_color(1);
   PBdraw_big_point(point->u, point->v);
   PBrefresh_window();
}
#endif

   stop = side;

   do 
    {
      prev = side;
      side = side->next_along_side;
    }
   while (((point->v < side->v) || (point->v >= prev->v)) &&
          ((point->v > side->v) || (point->v <= prev->v)) &&
          (side!=stop));

   if ((side==stop) &&
       ((point->v < side->v) || (point->v >= prev->v)) &&
       ((point->v > side->v) || (point->v <= prev->v)))
    {
      HSset_status( HSSTAT_BOUND_ERROR );
      goto wrapup;
    }

   point->next            = side;
   point->next_along_side = side;
   prev->next_along_side  = point;

#if PLOT_BOUNDS
{
   PBset_color(1);
   PBdraw_bound_line(prev->u, prev->v, point->u, point->v);
   PBset_color(3);
   PBdraw_bound_line(point->u, point->v, side->u, side->v);
   PBdraw_point(side->u, side->v);
   PBrefresh_window();
}
#endif

   if ((prev->u!=point->u) && (point->u!=side->u)) HSset_status( HSSTAT_BOUND_ERROR );

wrapup:
	return(0);
 }


/*-- HSlink_horiz_side_to_bound -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HSlink_horiz_side_to_bound( register struct HSpoint *point, 
					       register struct HSpoint *side )
#else
	static int HSlink_horiz_side_to_bound( point, side )

	register struct
	   HSpoint	*point,		/* input - start point of boundary	*/
			*side;		/* input - list of points along side	*/
#endif

/*
 * Attaches the start point of a boundary to a patch side to help create
 * a polygon, where this polygon is simply a list of point structures
 * linked via their 'next' fields.  Points along the side are assumed 
 * to all have identical V values.
 *
 * HISTORY: 09/01/86 Created					S. A. Rapa
 *          03/01/89 Enabled points with duplicate u and v values to be
 *                   inserted after equal points in the list.	C. M. Jablonski
 */

 {
   register struct
      HSpoint	*prev, *stop;

#if PLOT_BOUNDS
{
   PBset_color(1);
   PBdraw_big_point(point->u, point->v);
   PBrefresh_window();
}
#endif

   stop = side;
   do 
    {
      prev = side;
      side = side->next_along_side;
    }
   while (((point->u <= side->u) || (point->u > prev->u)) &&
          ((point->u >= side->u) || (point->u < prev->u)) &&
          (side!=stop));

   if ((side==stop) &&
       ((point->u <= side->u) || (point->u > prev->u)) &&
       ((point->u >= side->u) || (point->u < prev->u)))
         {
         HSset_status( HSSTAT_BOUND_ERROR );
         goto wrapup;
         }

   point->next_along_side = side;
   prev->next_along_side  = point;
   prev->next             = point;

#if PLOT_BOUNDS
{
   PBset_color(1);
   PBdraw_bound_line(prev->u, prev->v, point->u, point->v);
   PBset_color(3);
   PBdraw_bound_line(point->u, point->v, side->u, side->v);
   PBdraw_point(side->u, side->v);
   PBrefresh_window();
}
#endif

   if ((prev->v!=point->v) && (point->v!=side->v)) HSset_status( HSSTAT_BOUND_ERROR );

wrapup:
	return(0);
 }


/*-- HSlink_vert_side_to_bound -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HSlink_vert_side_to_bound( register struct HSpoint *point, 
					      register struct HSpoint *side )
#else
	static int HSlink_vert_side_to_bound( point, side )

	register struct
	   HSpoint	*point,		/* input - start point of boundary	*/
			*side;		/* input - list of points along side	*/
#endif

/*
 * Attaches the start point of a boundary to a patch side to help create
 * a polygon, where this polygon is simply a list of point structures
 * linked via their 'next' fields.  Points along the side are assumed 
 * to all have identical U values.
 *
 * HISTORY: 09/01/86 Created					S. A. Rapa
 *          03/01/89 Enabled points with duplicate u and v values to be
 *                   inserted after equal points in the list.	C. M. Jablonski
 */

 {
   register struct
      HSpoint	*prev, *stop;

#if PLOT_BOUNDS
{
   PBset_color(1);
   PBdraw_big_point(point->u, point->v);
   PBrefresh_window();
}
#endif

   stop = side;
   do
    {
      prev = side;
      side = side->next_along_side;
    }
   while (((point->v <= side->v) || (point->v > prev->v)) &&
          ((point->v >= side->v) || (point->v < prev->v)) &&
          (side!=stop));

   if ((side==stop) &&
       ((point->v <= side->v) || (point->v > prev->v)) &&
       ((point->v >= side->v) || (point->v < prev->v)))
         {
         HSset_status( HSSTAT_BOUND_ERROR );
         goto wrapup;
         }

   point->next_along_side = side;
   prev->next_along_side  = point;
   prev->next             = point;

#if PLOT_BOUNDS
{
   PBset_color(1);
   PBdraw_bound_line(prev->u, prev->v, point->u, point->v);
   PBset_color(3);
   PBdraw_bound_line(point->u, point->v, side->u, side->v);
   PBdraw_point(side->u, side->v);
   PBrefresh_window();
}
#endif

   if ((prev->u!=point->u) && (point->u!=side->u)) HSset_status( HSSTAT_BOUND_ERROR );

wrapup:
	return(0);
 }


/*-- HSremove_open_boundaries -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSbound *HSremove_open_boundaries( register struct HSbound *bound_list )
#else
	static struct HSbound *HSremove_open_boundaries( bound_list )

	register struct
	   HSbound	*bound_list;	/* input - boundaries to process	*/
#endif
 
/*
 * Returns a list of closed boundaries extraced from the input list
 * and disposes the remaining (open) boundaries.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   register struct
      HSbound	*closed_bounds,
		*next_bound;

   closed_bounds = NIL_BOUND;
   while (bound_list != NIL_BOUND)
    {
      next_bound = bound_list->next;
      if (bound_list->start_pt != bound_list->end_pt)
         HSdispose_bound (bound_list);
      else
       {
	 bound_list->next = closed_bounds;
	 closed_bounds = bound_list;
       }
      bound_list = next_bound;
    }

   return (closed_bounds);
 }


/*-- HSsend_out_all_boundaries ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSsend_out_all_boundaries( struct HSbound *closed_bound_list )
#else
	static void HSsend_out_all_boundaries( closed_bound_list )

	struct
	   HSbound	*closed_bound_list;	/* input - patch boundaries	*/
#endif

/*
 * Adds all of this facet's boundaries to the current facet being
 * built, then clips/shades the facet & sends it to the polybuster.
 *
 * HISTORY: 09/01/86 created				S. A. Rapa
 * 	    02/07/87 No longer writes to pipe; calls	S. A. Rapa
 *		     "clip_and_shade" instead
 */

 {
   while (closed_bound_list != NIL_BOUND)
    {
      (*active_window->end_loop[active_window->active_zbuffer])();

      HSsend_out_polygon (closed_bound_list->start_pt, TRUE);
      HSdispose_point_list (closed_bound_list->end_pt->next,
			  closed_bound_list->end_pt       );
      closed_bound_list = closed_bound_list->next;
    }

    (*active_window->prepare_facet[active_window->active_zbuffer])();
 }


/*-- HSpoint_is_within_boundary -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean HSpoint_is_within_boundary( IGRdouble u,
						      IGRdouble v,
						 struct HSpoint *start_pt)
#else
	static IGRboolean	HSpoint_is_within_boundary (u, v, start_pt)

	struct
	   HSpoint	*start_pt;	/* input - any point on closed boundary	*/
	IGRdouble	u, v;		/* input - coordinates of test point	*/
#endif

/*
 * Determines if a point lies inside a closed boundary by counting the
 * number of times the boundary crosses an infinite horizontal
 * (constant V) line which passes through the point in question.  If
 * it crosses an odd number of times on each side of the point, it is
 * inside; otherwise it is outside.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 *	    04/05/91 Removed 'Fudge' factor when a boundary points v lies
 *		     on the v of the point is question.
 *					Trevor Mink
 *          12/17/93 If the vertex list only has two points, return false
 *                                      Mike Lanier
 */

 {
   struct
      HSpoint	*stop_pt,
		*this_pt;
   IGRdouble	intersect;
   register
      IGRdouble ua, ub, va, vb, uc, vc, uc_last;
   IGRint	num_left_intersects;

   num_left_intersects = 0;

   /*
    * Must start traversing boundary from a point not on test line.
    */

   if( start_pt == start_pt->next->next ) return( FALSE );
   
   while (start_pt->v == v)
      start_pt = start_pt->next;
   stop_pt = start_pt;
   this_pt = start_pt;
   ub = start_pt->u;
   vb = start_pt->v;

   do
    {
      ua = ub;
      va = vb;
      this_pt = this_pt->next;
      ub = this_pt->u;
      vb = this_pt->v;

      /*
       * 'Fudge' points which lie exactly on test line.
       * Not any more. TM
       */

/***
      if (vb == v)
        vb += BOUND_TOL;
***/

	if (((va < v) && (vb > v)) || ((va > v) && (vb < v))   )
	{
		if ((ua <= u) && (ub <= u))
			num_left_intersects++;
		else if (((ua < u) && (ub > u)) || ((ua > u) && (ub < u))   )
		{
			intersect = ((v - va) / (vb - va)) * (ub - ua) + ua;
			if (intersect < u)
				num_left_intersects++;
		}
	}
	else if( v == vb )
	/* This piece of code replaces the 'Fudge' factor implementation */
	{
		if( this_pt != stop_pt )
		{
			uc_last = ub;
			do
			{
				this_pt = this_pt->next;
				uc = this_pt->u;
				vc = this_pt->v;
				if( (va < v && v < vc) || (vc < v && v < va) )
				{
					if( uc_last <= u )
						num_left_intersects++;
					break;
				}
				if( vc == v && ub <= u && uc >= u )
				{
					num_left_intersects = 1;
					return( TRUE );
				}
				uc_last = uc;
			}
			while( vc == v && this_pt != stop_pt );
			ub = uc;
			vb = vc;
		}
	}
    }
   while (this_pt != stop_pt);

   if (num_left_intersects & 1)
      return (TRUE);
   else
      return (FALSE);
 }


/*-- HSadd_contained_loops ----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSbound	*HSadd_contained_loops(
					struct HSpoint *master_polygon_start,	/* input - a point on the parent polygon	*/
					struct HSbound *bound_list )		/* input - list of boundaries			*/
#else
	static struct HSbound	*HSadd_contained_loops (master_polygon_start, bound_list)

	struct HSpoint	*master_polygon_start;	/* input - a point on the parent polygon	*/
	struct HSbound	*bound_list;		/* input - list of boundaries			*/
#endif

/* 
 * Adds to the facet currently being build all vertices on closed
 * boundaries which are contained within a parent boundary loop.
 * Boundaries printed are removed from the input list; after
 * processing all boundaries, the remaining list is returned.
 *
 *    master_polygon_start     [input] a point on the parent polygon
 *    bound_list               [input] list of boundaries
 *
 * HISTORY: 09/01/86 created				S. A. Rapa
 *          02/07/87 No longer writes to pipe; calls	S. A. Rapa
 *		     "end_facet_loop" instead.
 */

 {
   struct
      HSbound	*bounds_left,
		*next_bound;

   bounds_left = NIL_BOUND;
   while (bound_list != NIL_BOUND)
    {
      next_bound = bound_list->next;
      if (HSpoint_is_within_boundary (bound_list->start_pt->u,
				    bound_list->start_pt->v,
				    master_polygon_start    ))
       {
         (*active_window->end_loop[active_window->active_zbuffer])();
	 HSsend_out_polygon (bound_list->start_pt, TRUE);
	 HSdispose_point_list (bound_list->end_pt->next, bound_list->end_pt);
	 HSdispose_bound (bound_list);
       }
      else
       {
	 bound_list->next = bounds_left;
	 bounds_left = bound_list;
       }

      bound_list = next_bound;
    }

   return (bounds_left);
 }


/*-- HSclean_up_remaining_boundaries ------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSclean_up_remaining_boundaries( struct HSbound *bound_list )
#else
	static void HSclean_up_remaining_boundaries( bound_list )

	struct HSbound	*bound_list;
#endif


/*
 * Creates facets from the closed boundaries which were not used in
 * any facets so far (that is, not used in facets which were built
 * by attaching open boundaries to patch sides).
 *
 *ARGUMENT LIST
 *     bound_list    [input] patch's reminaing closed boundaries
 *
 * HISTORY: 09/01/86 created				S. A. Rapa
 *	    02/07/87 No longer writes to pipe; calls	S. A. Rapa
 *		     "clip_and_shade" instead.
 */

 {
   IGRboolean	nested;
   IGRdouble	test_u, test_v;
   struct
      HSbound	*new_bound_list,
		*this_bound,
		*prev_bound;

   while (bound_list != NIL_BOUND)
    {
      /*
       * Clear the been_parent field for all boundaries
       */
      this_bound = bound_list;
      while ( this_bound )
       {
         this_bound->been_parent = FALSE;
         this_bound = this_bound->next;
       }

      /*
       * Find a boundary which is not nested in any others and
       * move it to the front of the list.
       */

      nested = TRUE;
      while (nested)
       {

         prev_bound = NULL;
	 this_bound = bound_list;

         /*
          * Make sure this parent hasn't been a parent, yet
          */
	 while ( (this_bound) && (this_bound->been_parent) )
          {
            prev_bound = this_bound;
            this_bound = prev_bound->next;
          }

         if ( ! this_bound )
          {
            /*
             * All boundaries have been parents => we can't
             * determine the nesting, so give up
             */
            while ( bound_list )
             {
               HSdispose_point_list (bound_list->start_pt->next,
 		                     bound_list->start_pt       );
               this_bound = bound_list->next;
               HSdispose_bound (bound_list);
               bound_list = this_bound;
             }
            return;
          }
	 else
          {
            /*
             * Make 'this_bound' the head of 'bound_list'
             */
            if ( prev_bound )
             {
               prev_bound->next = this_bound->next;
 	       this_bound->next = bound_list;
	       bound_list       = this_bound;
             }
          }

         prev_bound = bound_list;
         this_bound = prev_bound->next;
         test_u = bound_list->start_pt->u;
         test_v = bound_list->start_pt->v;
	 nested = FALSE;

         while ((nested == FALSE) &&
	        (this_bound != NIL_BOUND))
          {
            prev_bound->been_parent = TRUE;
            if (HSpoint_is_within_boundary (test_u, test_v,
					  this_bound->start_pt))
	     {
	       nested = TRUE;

	       /*
		* This boundary is the new 'potential' parent ...
		* move it to the front of the list for next time.
		*/

    	       prev_bound->next = this_bound->next;
 	       this_bound->next = bound_list;
	       bound_list       = this_bound;
	     }
	    else
	     {
	       prev_bound = this_bound;
	       this_bound = this_bound->next;
	     }
          }
       }

      /*
       * Send out the parent list, followed by any boundaries which are
       * contained in it.  This constitutes a complete facet.
       */


      HSsend_out_polygon (bound_list->start_pt, TRUE);
      new_bound_list = HSadd_contained_loops (bound_list->start_pt,
					    bound_list->next     );

      (*active_window->prepare_facet[active_window->active_zbuffer])();

      /*
       * Clean up parent boundary
       */
      
      HSdispose_point_list (bound_list->start_pt->next,
      		  	  bound_list->start_pt       );
      HSdispose_bound (bound_list);
      bound_list = new_bound_list;
    }
 }


/*-- HSreclaim_boundary_memory ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSreclaim_boundary_memory( struct HSxsect *start_xsect, 
					       struct HSxsect *end_xsect )
#else
	static void HSreclaim_boundary_memory( start_xsect, end_xsect )
	
	struct
	   HSxsect	*start_xsect,	/* input - start of list to dispose	*/
			*end_xsect;	/* input - end of list to dispose	*/
#endif

/*
 * Given a portion of the intersection list, this routine will recycle
 * the memory used by all boundary points and intersection cells
 * in this list.
 *
 * HISTORY: 09/30/86 created			S. A. Rapa
 */

 {
   struct
      HSxsect	*this_xsect,
		*stop_xsect;

   this_xsect = start_xsect;
   stop_xsect = end_xsect->next;
   do
    {
      if (this_xsect->is_start == TRUE)
         HSdispose_point_list (this_xsect->bndry,
			     this_xsect->other_end->bndry);
      this_xsect = this_xsect->next;
    }
   while (this_xsect != stop_xsect);

   HSdispose_xsect_list (start_xsect, end_xsect);
 }


/*-- construct_polygons -----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void construct_polygons( IGRdouble ulo,
				 IGRdouble vlo,
				 IGRdouble uhi,
				 IGRdouble vhi,
				  IGRpoint *sfpoints,
				    IGRint norm_offset,
				    IGRint ll_index,
				    IGRint ul_index,
				    IGRint ur_index,
				    IGRint lr_index,
			   struct HSbound *patch_bounds,
				IGRboolean patch_solid,
				IGRboolean left_mark,
				IGRboolean top_mark,
				IGRboolean right_mark,
				IGRboolean bottom_mark )

#else
	void		construct_polygons (ulo, vlo, uhi, vhi,
					    sfpoints, norm_offset,
					    ll_index, ul_index, ur_index, lr_index,
					    patch_bounds, patch_solid,
					    left_mark, top_mark, right_mark, bottom_mark)

	struct
	   HSbound	*patch_bounds;	/* i/o   - list of patch's boundaries	*/
	IGRdouble	ulo, vlo,	/* input - parametric range of patch	*/
			uhi, vhi;
	IGRboolean	patch_solid;	/* input - point (ulo, vlo) is solid	*/
	IGRpoint	*sfpoints;	/* input - surface points and normals	*/
	IGRint		norm_offset;	/* input - offset to get normals, w's	*/
	IGRint		ll_index,	/* input - normal coords of corners	*/
			ul_index, ur_index, lr_index;
	IGRboolean	left_mark,	/* input - patch edge flags		*/
			top_mark, right_mark, bottom_mark;
#endif

/*
 * Uses the four corners of a patch and all of the patch's boundaries
 * to construct polygons which represent the solid areas within the
 * patch.  These polygons are then clipped, shaded, and sent to the
 * polybuster via calls to "clip_and_shade".
 * OK is returned if everything went OK; BOUND_ERROR is returned if
 * an open boundary of this patch crosses another one.
 *
 * HISTORY: 09/01/86 created						S. A. Rapa
 *	    02/07/87 No longer writes to pipe; calls			S. A. Rapa
 *		     "clip_and_shade" instead.
 *	    08/10/87 Set 'spread' to 0 every time a set of		S. A. Rapa
 *		     boundaries is removed from the
 *		     intersection list.
 *          06/06/88 Added checks for crossing open boundaries.		C. M. Jablonski
 *          06/07/88 Only free the intersection list if all bounds	C. M. Jablonski
 *                   are valid.
 *          10/13/88 Added check to determine if interpolation can
 *                   be used to calculate boundary point coordinates.	C. M. Jablonski
 *          05/15/88 Added edge marks and processing.			C. M. Jablonski
 *
 */

 {
   struct
      HSxsect	*intersection_list,
		*prev_xsect,
		*start_xsect,
		*end_xsect,
		*next_xsect,
		*save_origin,
		*save_start;
   struct
      HSpoint	*sides[4], *tmp_pt;
   IGRshort	cut,
		spread,
		counter;
   IGRboolean	leave_side,
		polygon_generated;

   save_origin = NIL_XSECT;

#	if PLOT_BOUNDS
{
   /* dehilight the region area */
   PBset_color(6);
   PBclip_and_draw_line(ulo, vlo, ulo, vhi);
   PBclip_and_draw_line(ulo, vhi, uhi, vhi);
   PBclip_and_draw_line(uhi, vhi, uhi, vlo);
   PBclip_and_draw_line(uhi, vlo, ulo, vlo);
   PBrefresh_window();
   /* initialize the facet window */
   PBinit_facet_window(ulo, vlo, uhi, vhi);
   PBset_color(5);
   PBclip_and_draw_line(ulo, vlo, ulo, vhi);
   PBclip_and_draw_line(ulo, vhi, uhi, vhi);
   PBclip_and_draw_line(uhi, vhi, uhi, vlo);
   PBclip_and_draw_line(uhi, vlo, ulo, vlo);
   /* indicate whether (ulo, vlo) is solid */
   if (patch_solid)
      PBset_color(5);
   else
      PBset_color(3);
   PBdraw_big_point(ulo, vlo);
   PBrefresh_window();
}
#	endif
   /*
    * Set up global variables needed for interpolating boundary points
    */

   global_ulo = ulo;
   global_vlo = vlo;
   global_uhi = uhi;
   global_vhi = vhi;
   global_ll_point = sfpoints[ll_index];
   global_ul_point = sfpoints[ul_index];
   global_ur_point = sfpoints[ur_index];
   global_lr_point = sfpoints[lr_index];
   global_ll_norm  = sfpoints[ll_index + norm_offset];
   global_ul_norm  = sfpoints[ul_index + norm_offset];
   global_ur_norm  = sfpoints[ur_index + norm_offset];
   global_lr_norm  = sfpoints[lr_index + norm_offset];

   if (active_window->perspective)
    {
      IGRdouble	*w;

      w = sfpoints[norm_offset + norm_offset];
      global_ll_w = w[ll_index];
      global_ul_w = w[ul_index];
      global_ur_w = w[ur_index];
      global_lr_w = w[lr_index];
    }
	
   /*
    * Determine whether or not interpolation can be used to find 
    * boundary point coordinates.
    */

   if ((patch_bounds != NIL_BOUND) && (element_parms.interp_tol))
      {  /* there are bounds and we have a check tolerance */
      HSset_interp_flag();
      }
   else
      {
      interp_flag = TRUE;
      }


   /*
    * Build the intersection list.
    */

   intersection_list = HSbuild_intersection_list (ulo, uhi, vhi,
						patch_bounds, patch_solid);
   if (tiling_parms.status != HSSTAT_OK) goto wrapup;


   /* 
    * Adjust equal xsects.  - CMJ  01/03/89
    */

   if (intersection_list)
    {
      intersection_list = HSadjust_equal_xsects (intersection_list);
      patch_bounds = HSremove_open_boundaries (patch_bounds);
    }


   /*
    * Special case if this patch contains no open boundaries
    */

   if ((intersection_list == NIL_XSECT) &&
       (patch_solid)			  )
    {
#if PLOT_BOUNDS
{
	/* plot the facet boundary in the boundary color */
	PBset_color(7);
	PBenable_region_window();
	PBclip_and_draw_line(ulo, vlo, ulo, vhi);
	PBclip_and_draw_line(ulo, vhi, uhi, vhi);
	PBclip_and_draw_line(uhi, vhi, uhi, vlo);
	PBclip_and_draw_line(uhi, vlo, ulo, vlo);
	PBrefresh_window();
	PBenable_facet_window();
	PBdraw_bound_line(ulo, vlo, ulo, vhi);
	PBdraw_bound_line(ulo, vhi, uhi, vhi);
	PBdraw_bound_line(uhi, vhi, uhi, vlo);
	PBdraw_bound_line(uhi, vlo, ulo, vlo);
	PBrefresh_window();
}
#endif

      /*
       * Send out patch (main) loop.
       */

	switch( element_parms.render_parms->texture_orientation )
		{
		case 2:
		case 8:
			construct_facet (sfpoints, ll_index, norm_offset, left_mark,   ulo, 1.0-vlo);
			construct_facet (sfpoints, ul_index, norm_offset, top_mark,    ulo, 1.0-vhi);
			construct_facet (sfpoints, ur_index, norm_offset, right_mark,  uhi, 1.0-vhi);
			construct_facet (sfpoints, lr_index, norm_offset, bottom_mark, uhi, 1.0-vlo);
			break;

		case 3:
		case 5:
			construct_facet (sfpoints, ll_index, norm_offset, left_mark,   1.0-ulo, vlo);
			construct_facet (sfpoints, ul_index, norm_offset, top_mark,    1.0-ulo, vhi);
			construct_facet (sfpoints, ur_index, norm_offset, right_mark,  1.0-uhi, vhi);
			construct_facet (sfpoints, lr_index, norm_offset, bottom_mark, 1.0-uhi, vlo);
			break;
			
		case 4:
		case 7:
			construct_facet (sfpoints, ll_index, norm_offset, left_mark,   1.0-ulo, 1.0-vlo);
			construct_facet (sfpoints, ul_index, norm_offset, top_mark,    1.0-ulo, 1.0-vhi);
			construct_facet (sfpoints, ur_index, norm_offset, right_mark,  1.0-uhi, 1.0-vhi);
			construct_facet (sfpoints, lr_index, norm_offset, bottom_mark, 1.0-uhi, 1.0-vlo);
			break;
			
		case 0:
		case 1:
		case 6:
		default:
			construct_facet (sfpoints, ll_index, norm_offset, left_mark,   ulo, vlo);
			construct_facet (sfpoints, ul_index, norm_offset, top_mark,    ulo, vhi);
			construct_facet (sfpoints, ur_index, norm_offset, right_mark,  uhi, vhi);
			construct_facet (sfpoints, lr_index, norm_offset, bottom_mark, uhi, vlo);
			break;
		}

      /*
       * Send out a loop for each boundary.
       */

      HSsend_out_all_boundaries (patch_bounds);
      HSdispose_bound_list (patch_bounds);
      patch_bounds = NIL_BOUND;
    }

   spread = 0;

   while ((tiling_parms.status == HSSTAT_OK) &&
	  (intersection_list != NIL_XSECT))
    {
      prev_xsect  = NIL_XSECT;
      start_xsect = intersection_list;
      end_xsect   = start_xsect->next;
      next_xsect   = start_xsect->other_end;

      for (counter = 0; counter < spread; counter++)
       {
         if (end_xsect == NIL_XSECT)
          {
#if DEBUG_BOUND
fprintf (stderr, "Bad boundary definition detected by tiler: dangling end.\n");
#endif
	    HSset_status( HSSTAT_BOUND_ERROR );
	    break;
	  }
         else if ((end_xsect == next_xsect) && (counter != (spread - 1)))
          {
#if DEBUG_BOUND
fprintf (stderr, "Bad boundary definition detected by tiler: crossed open boundaries[1].\n");
#endif
            end_xsect = NIL_XSECT;
	    HSset_status( HSSTAT_BOUND_ERROR );
	    break;
	  }
         else
          {
            end_xsect = end_xsect->next;
	  }
       }

      if ( end_xsect != NIL_XSECT )
         next_xsect = end_xsect->next;
      polygon_generated = FALSE;

      /*
       * See if any polygons can be constructed using the current endpoint
       * spread. If so, the intersection list must be traversed from
       * the beginning again using the same spread until no more 
       * polygons can be made ... then bump the spread.
       */

      while ((end_xsect != NIL_XSECT) &&
     	     (polygon_generated == FALSE))
         if (start_xsect->other_end == end_xsect)
          {
	    save_start = start_xsect;
    	    polygon_generated = TRUE;

   	    leave_side = start_xsect->is_start;
            if (leave_side == FALSE)
             {
	       /*
		* Build a clockwise box
  	   	*/

               sides[0] = HSmake_point (ulo, vlo);
               sides[1] = HSmake_point (ulo, vhi);
               sides[2] = HSmake_point (uhi, vhi);
               sides[3] = HSmake_point (uhi, vlo);
               if (tiling_parms.status != HSSTAT_OK) goto wrapup;
	       sides[0]->next_along_side = sides[1];
	       sides[1]->next_along_side = sides[2];
	       sides[2]->next_along_side = sides[3];
	       sides[3]->next_along_side = sides[0];
	       sides[0]->mark = left_mark;
	       sides[1]->mark = top_mark;
	       sides[2]->mark = right_mark;
	       sides[3]->mark = bottom_mark;
             }
	    else
             {
	       /*
		* Build a counterclockwise box
  	   	*/

               sides[0] = HSmake_point (ulo, vhi);
               sides[1] = HSmake_point (uhi, vhi);
               sides[2] = HSmake_point (uhi, vlo);
               sides[3] = HSmake_point (ulo, vlo);
               if (tiling_parms.status != HSSTAT_OK) goto wrapup;
	       sides[0]->next_along_side = sides[3];
	       sides[1]->next_along_side = sides[0];
	       sides[2]->next_along_side = sides[1];
	       sides[3]->next_along_side = sides[2];
	       sides[0]->mark = bottom_mark;
	       sides[1]->mark = left_mark;
	       sides[2]->mark = top_mark;
	       sides[3]->mark = right_mark;
             }
	    sides[0]->next = sides[0]->next_along_side;
	    sides[1]->next = sides[1]->next_along_side;
	    sides[2]->next = sides[2]->next_along_side;
	    sides[3]->next = sides[3]->next_along_side;

	    /* 
	     * Attach all bounds to polygon
	     */

	    do
             {
	       if (leave_side != FALSE)
	        {
		  if (start_xsect->is_start == FALSE)
                   {
		     HSreverse_boundary (start_xsect);
                   }
#if PLOT_BOUNDS
{
      struct HSpoint *this_point, *stop_point;

      /* plot this open boundary */
      PBset_color(2);
      this_point = start_xsect->bndry;
      stop_point = start_xsect->other_end->bndry;
      while (this_point != stop_point)
       {
       PBdraw_bound_line(this_point->u, this_point->v, this_point->next->u, this_point->next->v);
       this_point = this_point->next;
       }
      PBdraw_point(this_point->u, this_point->v);
      PBrefresh_window();
}
#endif

                  /* set the edge marks */
                  if(element_parms.marking_edges )
                     for( tmp_pt = start_xsect->bndry; tmp_pt != start_xsect->other_end->bndry;
                          tmp_pt = tmp_pt->next )
                        tmp_pt->mark = TRUE;
                  
	          cut = start_xsect->side_cut;
	          if ((cut == 0) || (cut == 2))
		     HSlink_vert_side_to_bound (start_xsect->bndry, sides[cut]);
		  else
		     HSlink_horiz_side_to_bound (start_xsect->bndry, sides[cut]);
		  
		  if (tiling_parms.status == HSSTAT_OK)
		   {
		     cut = start_xsect->other_end->side_cut;
                     start_xsect->other_end->bndry->mark = sides[cut]->mark;
	             if ((cut == 0) || (cut == 2))
		        HSlink_bound_to_vert_side (start_xsect->other_end->bndry, sides[cut]);
		     else
		        HSlink_bound_to_horiz_side (start_xsect->other_end->bndry, sides[cut]);
	           }
	           
	          if (tiling_parms.status != HSSTAT_OK)
	           { /* Boundary was not linked to proper side */
#if DEBUG_BOUND
fprintf (stderr, "Bad boundary definition detected by tiler: bad link to patch side.\n");
#endif
	             end_xsect = NIL_XSECT;
		     HSset_status( HSSTAT_BOUND_ERROR );
	             break;
	           }
	             
	        }

               start_xsect = start_xsect->next;
	       leave_side = ~leave_side;
             }
            while (start_xsect != next_xsect);

            if (tiling_parms.status == HSSTAT_OK)
             {
               /*
	        * Polygon has been constructed .. send it out
	        */

	       HSsend_out_polygon (end_xsect->bndry, FALSE);
	       patch_bounds = HSadd_contained_loops( end_xsect->bndry,
                                                   patch_bounds );

	       (*active_window->prepare_facet[active_window->active_zbuffer])();

               /*
	        * Remove this polygon from further consideration.
	        */
	     
	       end_xsect->next = save_origin;
	       save_origin = save_start;

	       if (prev_xsect == NIL_XSECT)
	          intersection_list = next_xsect;
	       else
	          prev_xsect->next  = next_xsect;

	       /*
	        * Recycle the patch corner points
	        */

	       HSdispose_point_list (sides[0], sides[0]);
	       HSdispose_point_list (sides[1], sides[1]);
	       HSdispose_point_list (sides[2], sides[2]);
	       HSdispose_point_list (sides[3], sides[3]);

	       spread = 0;
	     }
          }

         else
	  {
	    prev_xsect = start_xsect->next;
	    start_xsect = prev_xsect->next;
	    if (next_xsect == NIL_XSECT)
	     {
	       spread += 2;
	       end_xsect = NIL_XSECT;
	     }
	    else
	     {
	       end_xsect = start_xsect->next;
	       for (counter = 0; counter < spread; counter++)
                  if ( (end_xsect == prev_xsect->other_end) || 
                       ( (end_xsect == start_xsect->other_end) && 
                       (counter!=(spread-1)) ) )
                     {
#if DEBUG_BOUND
fprintf (stderr, "Bad boundary definition detected by tiler: crossed open boundaries.\n");
#endif
	             end_xsect = NIL_XSECT;
	             HSset_status( HSSTAT_BOUND_ERROR );
	             break;
	             }
                  else
                     end_xsect = end_xsect->next;
               if (tiling_parms.status == HSSTAT_OK)
                  {
                  end_xsect = next_xsect->next;
	          next_xsect = end_xsect->next;
	          }
	     }
	  }
    }

   if (tiling_parms.status == HSSTAT_OK)
    {
      /*
       * Process the remaining closed loops.
       */
       
      HSclean_up_remaining_boundaries (patch_bounds);

      /*
       * Recycle the boundary memory.  NOTE: this is NOT done if any of the
       * boundaries are bad, because the intersection list could be corrupt.
       */
       
      if (save_origin!=NIL_XSECT)
         {
         end_xsect = save_origin->next;
         while (end_xsect->next != NIL_XSECT)
            end_xsect = end_xsect->next;
         HSreclaim_boundary_memory (save_origin, end_xsect);
         }
    }

#	if PLOT_BOUNDS
{
   PBrefresh_window();
   if (tiling_parms.status == HSSTAT_OK)
      PBpause();
   else
      PBbadbnd();
   PBenable_region_window();
}
#	endif
wrapup:;
 }


/**************************
 * MISCELLANEOUS ROUTINES *
 **************************/


/*-- add_mesh_intersections -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void add_mesh_intersections( struct HSbound *boundaries,
					     IGRint u_num_mesh,
					  IGRdouble u_mesh_array[],
					     IGRint v_num_mesh,
					  IGRdouble v_mesh_array[] )
#else
	void		add_mesh_intersections (boundaries,
						u_num_mesh, u_mesh_array,
						v_num_mesh, v_mesh_array )

	struct
	   HSbound	*boundaries;	/* input - list of boundaries to process*/
	IGRint		u_num_mesh,	/* input - # of mesh points in U	*/
			v_num_mesh;	/* input - # of mesh points in V	*/
	IGRdouble	u_mesh_array[],	/* input - array of U mesh points	*/
			v_mesh_array[]; /* input - array of V mesh points	*/
#endif

/*
 * Adds the intersection points of boundary segments with mesh lines
 * to the appropriate segments for each boundary in the input list.
 * These intersection points will be needed when distributing boundary
 * pieces to all of the surface's patches.  This routine may also 
 * 'tweak' the coordinates of some points to prevent boundaries from 
 * being exactly tangent to a mesh line (patch side) or passing through
 * a mesh point (patch corner) for reasons outlined in 'preprocess_a_boundary'.
 *
 * HISTORY: 09/01/86 Created.				S. A. Rapa
 *          03/12/89 Added u-mesh check when inserting point with
 *                   a v-mesh value.			C. M. Jablonski
 */

 {
   struct
      HSpoint	*this_point,
		*save_this_point,
		*stop_point,
		*prev_point,	
		*p;
   IGRint	index, index2;
   IGRdouble	ua, ub, va, vb, delta_u, delta_v, mesh_line;


   while (boundaries != NIL_BOUND)		/* do all boundaries	 */
    {
      save_this_point = boundaries->start_pt;
      stop_point      = boundaries->end_pt;


      /*
       * Make sure that endpoints of open boundaries cannot lie on patch
       * corners.
       */

      if (save_this_point != stop_point)
       {
         if ((save_this_point->u == u_mesh_array[0]) || (save_this_point->u == u_mesh_array[u_num_mesh - 1]))
	    {
            SET_LO_BITS( &save_this_point->v );
	    }
         else
	    {
            SET_LO_BITS( &save_this_point->u );
	    }
 
         if ((stop_point->u == u_mesh_array[0]) || (stop_point->u == u_mesh_array[u_num_mesh - 1]))
	    {
            SET_LO_BITS( &stop_point->v );
	    }
         else
	    {
            SET_LO_BITS( &stop_point->u );
	    }
       }


      /* 
       * Check all boundary segments against mesh lines in U
       */
     
      do
       {
         prev_point = save_this_point;
         save_this_point = save_this_point->next;
         this_point = save_this_point;
  
         ua = prev_point->u;
         va = prev_point->v;
         ub = this_point->u;
         vb = this_point->v;
         delta_u = ua - ub;
         delta_v = va - vb;

         for (index = 0; index < u_num_mesh; index++)
          {
	    mesh_line = u_mesh_array[index];
	    if (ub == mesh_line)
	     {
	       /*
		* Correct points which are tangent to mesh line, but
		* don't do endpoints of open boundaries ... they were
		* special cased earlier.
		*/

	       if (((this_point != stop_point) && (boundaries->start_pt != stop_point)) ||
		   (boundaries->start_pt == stop_point))
		{
                  if ((ua <= mesh_line) && (this_point->next->u <= mesh_line))
                   {
	             this_point->u -= BOUND_TOL;
		     ub -= BOUND_TOL;
         	     delta_u = ua - ub;
		   }
	          else if ((ua >= mesh_line) && (this_point->next->u >= mesh_line))
                   {
	             this_point->u += BOUND_TOL;
		     ub += BOUND_TOL;
         	     delta_u = ua - ub;
                   }

		  /*
	           * Boundary is not tangent to mesh line, but crosses
	           * it instead.  Make sure that this point does not
		   * lie exactly on a box corner by setting the last 4
		   * bits of the V coordinate mantissa to not be zeroes;
		   * this will work since mesh values have their last
		   * 4 bits cleared (see 'compute_knots').
	           *
	           * Also, move the u coordinate off of the mesh line.
	           * This was causing problems with a boundary that had
                   * two separate points that were equal and on a mesh
	           * line. (TR 91n4176 - S.P. Rogers  07 Feb 1992)
                   */

	          else
		   {
		     SET_LO_BITS( &this_point->v );

		   }
	        }
             }

            else if ((ua > mesh_line) && (ub < mesh_line) ||
                     (ub > mesh_line) && (ua < mesh_line))
	     {
	       /*
	        * Boundary segment intersects with mesh line
	        */

	       p = HSnew_point ();
               if (tiling_parms.status != HSSTAT_OK) goto wrapup;
	       p->u = mesh_line;
	       p->v = (delta_v / delta_u) * (mesh_line - ub) + vb;
	       p->next = this_point;
	       prev_point->next = p;
               if (ub < mesh_line)
	          this_point = p;
	       else
		  prev_point = p;

	       /*
		* 'Un-clear' the low bits of the mantissa for all
		* new boundary points too, just to be safe.
	  	*/

	       SET_LO_BITS( &p->v );
             }
          } /* for all interior mesh lines */
       }
      while (save_this_point != stop_point);


      /* 
       * Check all boundary segments against mesh lines in V
       */

      save_this_point = boundaries->start_pt;
      ub = save_this_point->u;
      vb = save_this_point->v;

      do					/* do all boundary points */
       {
         prev_point = save_this_point;
         save_this_point = save_this_point->next;
         this_point = save_this_point;
  
         ua = ub;
         va = vb;
         ub = this_point->u;
         vb = this_point->v;
         delta_u = ua - ub;
         delta_v = va - vb;

         for (index = 0; index < v_num_mesh; index++)
          {
	    mesh_line = v_mesh_array[index];
	    if (vb == mesh_line)
	     {
	       /*
		* Correct points which are tangent to mesh line, but
		* don't do endpoints of open boundaries ... they were
		* special cased earlier.
		*/

	       if (((this_point != stop_point) && (boundaries->start_pt != stop_point)) ||
		   (boundaries->start_pt == stop_point)     )
		{
                  if ((va <= mesh_line) && (this_point->next->v <= mesh_line))
                   {
	             this_point->v -= BOUND_TOL;
		     vb -= BOUND_TOL;
         	     delta_v = va - vb;
	 	   }
	          else if ((va >= mesh_line) && (this_point->next->v >= mesh_line))
                   {
	             this_point->v += BOUND_TOL;
		     vb += BOUND_TOL;
         	     delta_v = va - vb;
                   }
		}
             }

            else
               if ((va > mesh_line) && (vb < mesh_line) ||
                   (vb > mesh_line) && (va < mesh_line)   )
		{
	          /*
	           * Boundary segment intersects with mesh line
	           */

		  p = HSnew_point ();
                  if (tiling_parms.status != HSSTAT_OK) goto wrapup;
		  p->u = (delta_u / delta_v) * (mesh_line - vb) + ub;

                  /*
                   * Check that the new point does not fall on a patch corner.
                   */

                  for (index2 = 0; index2 < u_num_mesh; index2++)
	             if (p->u == u_mesh_array[index2])
	              {
	                /*
		         * Correct new points which are tangent to but don't cross
	                 * a U mesh line.  CMJ 12/1/89
		         */

	                if ((ua <= u_mesh_array[index2]) && (ub <= u_mesh_array[index2]))
	                 {
                           p->u -= BOUND_TOL;
	                 }
	                else if ((ua >= u_mesh_array[index2]) && (ub >= u_mesh_array[index2]))
	                 {
                           p->u += BOUND_TOL;
	                 }

	                /*
		         * Correct new points which cross a U mesh line by adding another
			 * point.  CMJ 12/1/89
		         */

                        else
	                 {
                           if (va <= mesh_line)
                              p->v = mesh_line - BOUND_TOL;
		           else
                              p->v = mesh_line + BOUND_TOL;
		           prev_point->next = p;
		           p->next = HSnew_point ();
                           if (tiling_parms.status != HSSTAT_OK) goto wrapup;
	                   p = p->next;
	                   if (ub <= u_mesh_array[index2])
                              p->next->u = u_mesh_array[index2] - BOUND_TOL;
		           else
                              p->next->u = u_mesh_array[index2] + BOUND_TOL;
	                 }
	              }
		     
		  p->v = mesh_line;
		  p->next = this_point;
		  prev_point->next = p;
                  if (vb < mesh_line)
		     this_point = p;
		  else
		     prev_point = p;
                }
          } /* for all interior mesh lines */
       }
     while (save_this_point != stop_point);

     boundaries = boundaries->next;
    }
wrapup:;
 }


/*-- get_horizontal_status --------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean get_horizontal_status( IGRdouble param,
				     struct HSbound *bounds,
					 IGRboolean status )
#else
	IGRboolean		get_horizontal_status (param, bounds, status)

	IGRdouble	param;		/* input  - V of patch's lower side	*/
	struct
	   HSbound	*bounds;	/* input  - list of patch's boundaries	*/
	IGRboolean	status;		/* output - status of lr corner		*/
#endif

/*
 * Calculates the solid/hole status for a patch's lower-right corner
 * given the solid/hole status of its lower-left corner by counting
 * boundary intersections along their common side.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   while (bounds != NIL_BOUND) 
    {
      if (param == bounds->start_pt->v)
         status = ~status;
      if (param == bounds->end_pt->v)
         status = ~status;
      bounds = bounds->next;
    }

   return (status);
 }


/*-- get_vertical_status ----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean get_vertical_status( IGRdouble param,
				   struct HSbound *bounds,
				       IGRboolean status )
#else
	IGRboolean		get_vertical_status (param, bounds, status)

	IGRdouble	param;		/* input  - U of patch's left side	*/
	struct
	   HSbound	*bounds;	/* input  - list of patch's boundaries	*/
	IGRboolean	status;		/* output - status of ul corner		*/
#endif

/*
 * Calculates the solid/hole status for a patch's upper-left corner
 * given the solid/hole status of its lower-left corner by counting
 * boundary intersections along their common side.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

 {
   while (bounds != NIL_BOUND) 
    {
      if (param == bounds->start_pt->u)
         status = ~status;
      if (param == bounds->end_pt->u)
         status = ~status;
      bounds = bounds->next;
    }

   return (status);
 }
