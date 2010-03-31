
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef vemem_include
#define vemem_include 1

/*
DESCRIPTION
	Structure definitions used by the Vector Hidden Line memory 
	management macros

HISTORY
	S.P. Rogers    01/27/87  Creation Date
*/
	

#define ADDR_PER_POOL_LIST_NODE 10

/* linked-list structure to keep track of the starting addresses of all */
/* the memory pools that have been allocated                            */
struct VEpool_list_node
	{
	IGRint                  num_addr_used;
	IGRchar                 *start_addr[ADDR_PER_POOL_LIST_NODE];
	struct VEpool_list_node *next;
	};


/* structure used to manage pool memory allocation */
struct VEpool_mem_data
	{
	IGRint  structs_per_pool;   /* number of structures to allocate per pool       */
	IGRint  struct_size;        /* the size of the structure                       */
	IGRint  left_in_pool;       /* the number of structures left in the pool       */
	IGRchar *free_list;         /* linked-list of free structures                  */
	IGRchar *pool;              /* pointer to the first free structure in the pool */
	IGRint  total_malloced;     /* number of structures malloced for pools         */
	IGRint  pool_allocs;        /* number of structures allocated from the pool    */
	IGRint  list_allocs;        /* number of structures allocated from free list   */
	IGRint  frees;              /* number of structures that have been freed       */
	};
	


/* structure for temporary curve memory management */
struct VEtemp_curve_storage
	{
	IGRint    num_poles;        /* size of the poles array in doubles*3  */
	IGRint    num_knots;        /* size of the knots array in doubles   */
	IGRint    num_weights;      /* size of the weights array in doubles */
	IGRdouble *poles;           /* array of poles                       */
	IGRdouble *knots;           /* array of knots                       */
	IGRdouble *weights;         /* array of weights                     */
	};
	

/* structure for unweighted pole memory managment */
struct VEunweighted_pole_storage
	{
	IGRint    num_poles;        /* size of the poles array in doubles*3 */
	IGRdouble *poles;           /* array of poles                       */
	};
	

/* structure for curve clipping memory management */
struct VEcurve_clip_storage
	{
	IGRint    max_poles;       /* max. curve that can be clipped with current memory */
	IGRdouble *int_points;     /* array for intersection points                      */
	IGRdouble *int_params;     /* array for intersection parameters                  */
	IGRdouble *start_params;   /* array for clipping parameter                       */
	IGRdouble *end_params;     /* array for clipping parameters                      */
	};
	

/* structure for sharp knot memory management */
struct VEsharp_knot_storage
	{
	IGRint    num_u;       /* size of u_knots array in doubles */
	IGRdouble *u_knots;    /* array of u_knots                 */
	IGRint    num_v;       /* size of v_knots array in doubles */
	IGRdouble *v_knots;    /* array of v_knots                 */
	};


/* structure for saved intersection data management */
struct VEint_manager
	{
	struct VEsaved_int_node **buckets;          /* buckets for sorting                    */
	IGRint                  malloc_size;        /* number of structs to allocate per pool */
	struct VEsaved_int_node *pool;              /* pointer to first free node in pool     */
	IGRint                  left_in_pool;       /* number of nodes left in current pool   */
	struct VEsaved_int_node *free_list;         /* list of free nodes                     */
	IGRdouble               *double_pool;       /* pool of doubles                        */
	IGRint                  doubles_left;       /* number of nodes left in double pool    */
	IGRint                  double_malloc_size; /* number of doubles to allocate per pool */
	IGRint                  pools_left;         /* number of pools that can be allocated  */
	};
	
#endif
