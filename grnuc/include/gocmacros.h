#ifndef gocmacros_include
#define gocmacros_include

/* This include file is dependant on the following files:
 *
 * igrtypdef.h
 * OMminimum.h
 *
 */


/************************************************************************
 *
 * The following macros align pointers (if necessary).
 *
 ************************************************************************/

#define GRalign_bdry(bdry,ptr) (((IGRulong) (ptr) % (bdry)) ? 	\
				(bdry) - (IGRulong) (ptr) % 	\
				(bdry) + (IGRchar *) (ptr) : (IGRchar *)(ptr))

#define GRalign_double(ptr) GRalign_bdry(8,ptr)
#define GRalign_quad(ptr)   GRalign_bdry(8,ptr)
#define GRalign_long(ptr)   GRalign_bdry(4,ptr)
#define GRalign_short(ptr)  GRalign_bdry(2,ptr)
#define GRalign_char(ptr)   (ptr)

/*************************************************************************
 *
 *  This macro determines the number of bytes necessary to hold a B-spline
 *  curve data structure immediately followed by its poles, knots, weights,
 *  and boundary points (with proper alignment).
 *
 *  IGRshort   order		- order of curve
 *  IGRlong    num_poles	- number of poles
 *  IGRboolean rational		- rational curve indicator
 *  IGRshort   num_boundaries	- number of curve boundaries
 *  IGRlong    size		- number of bytes required
 *
 *************************************************************************/

#define GRbc_size(order,num_poles,rational,num_boundaries,size)		\
	size = sizeof(struct IGRbsp_curve) +				\
 	       (4 * (num_poles) + (order) + 2 * (num_boundaries)) *	\
	       sizeof (IGRdouble) + 20;					\
	if (rational)							\
	{								\
	  size += (num_poles) * sizeof (IGRdouble);			\
	}


/*************************************************************************
 *  
 *  This macro partitions a contiguous array of memory (starting at a 
 *  B-spline curve structure) so that the structure is immediately 
 *  followed by the curve's poles, knots, weights, and boundary points.
 *  It is assumed that the curve is properly aligned.  The internal 
 *  pointers in the curve will be properly aligned.
 *
 *  struct IGRbsp_curve *curve   - curve data structure
 *  IGRshort   order		- order of curve
 *  IGRlong    num_poles	- number of poles
 *  IGRboolean rational		- rational curve indicator
 *  IGRshort   num_boundaries	- number of curve boundaries
 *
 *************************************************************************/

#define GRbc_partition(curve,order,num_poles,rational,num_boundaries)	\
	(curve)->poles = (IGRdouble *) (GRalign_double((curve) + 1));	\
	(curve)->knots = &(curve)->poles[3 * (num_poles)];		\
	if ((rational))							\
	{								\
	  (curve)->weights = &(curve)->knots[(num_poles) + (order)];	\
	  if ((num_boundaries))						\
	  {								\
	    (curve)->bdrys = &(curve)->weights[(num_poles)];		\
	  }								\
	  else								\
	  {								\
	    (curve)->bdrys = 0;						\
	  }								\
	}								\
	else 								\
	{								\
	    (curve)->weights = 0;					\
	    if ((num_boundaries))					\
	    {								\
	      (curve)->bdrys = &(curve)->knots[(num_poles) + (order)];	\
	    }								\
	    else							\
	    {								\
	      (curve)->bdrys = 0;					\
	    }								\
	}

/************************************************************************
 * MACRO NAME : GRgetabsg
 *
 * ABSTRACT:
 * This macro determines if an object is in the abstract 
 * cache buffer.
 *
 * NOTE: this macro may only be called within a graphics object's
 * method.
 *
 *	IGRlong *msgcode		-completion code
 *					 -MSSUCC if succesful
 *	 		 		 -MSFAIL if not enough memory 
 *						could be allocated
 *
 *	short	*mx_type		-matrix type
 *
 *	IGRmatrix mx			-environment matrix
 *
 *	IGRchar	**absgptr (note: a pointer to any type of pointer can 
 *				 be used.)
 *					-returned pointer to the abstract
 *					 geometry
 *
 *	int	 i			-just a counter variable
 *
 *************************************************************************/

#define GRgetabsg(msgcod, mx_type, mx, absgptr, i)			\
if (! GRabsg_test(msgcod,mx_type,mx,&OM_Gw_current_OS,&my_id,absgptr))	\
{  \
	*msgcod = MSFAIL; \
	om$send( mode = OM_e_wrt_object, \
		 msg  = message GRvg.GRgenabsg(msgcod,mx_type,mx,absgptr),\
		 senderid = my_id, \
		 targetid = my_id); \
        if (!(*msgcod & 1)) \
          GRabsg_del_all(); \
}

/*
 * This macro is to be used by methods to notify the listeners of the 
 * operation that occurred on the graphics object.
 * For efficiency, the properties word of the graphic object will be 
 * checked to see if the object has a notification listener.
 *
 * IGRlong *msg;	the methods return status		
 * IGRlong *OMmsg;      the OM return value from the method
 * IGRint  action_mask; the mask indicating what operation was performed
 * 			the masks are defined in godef.h
 *
 */

#ifndef  BASE_EMS
#define GR_NOTIFY_LISTENERS(msg,OMmsg,action_mask) \
{ \
\
    IGRlong	___mask; \
    IGRlong     ___local_msg; \
    extern int GRnotifylisteners(); \
	\
    ___mask = action_mask; \
    ___local_msg = *(OMmsg); \
    GRnotifylisteners(msg,&___local_msg,&___mask,OPPmargs,&my_id);\
}					
#else
#define GR_NOTIFY_LISTENERS(msg,OMmsg,action_mask)  
#endif /* NT*/
#endif
