
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsvhl_include
#define hsvhl_include 1

#define CLIPPED 3

/* edge header structure */

struct HSedge_header 
	{
	struct HSedge_header	*next;		/* pointer to next edge			  */
	struct IGRbsp_curve	*curve;		/* pointer to curve definition		  */
	struct IGRbsp_curve	*stroked_curve; /* pointer to stroked curve definition	  */
	IGRdouble		*sh_spans;	/* array of self-hidden spans		  */
	struct VEvisib_node	*visib_list;	/* list of visibility changes		  */
	struct VEtemp_node	*temp_list;	/* list of possible visibility changes	  */
	struct HSedge_header	*shared_edge;	/* pointer to corresponding shared edge	  */
	IGRdouble		range[6];	/* transformed range of edge		  */
	IGRdouble		stroke_tol;	/* CHT edge was created with		  */
	IGRint			num_sh_spans;	/* number of self-hidden spans		  */
	IGRint			edge_id;	/* object id of edge			  */
	IGRint			saved_cvcv_id;	/* id used for saving cv/cv intersections */
	IGRshort		type;		/* type of the edge			  */
	IGRshort		status;		/* edge's overlap/self-hidden status	  */
	};

/**********************/
/***  from vedef.h  ***/
/**********************/

/* edge visibility classification */

#define UNKNOWN         0  /* visibility not known                         */
#define VISIBLE         1  /* visible                                      */
#define HIDDEN          2  /* hidden                                       */
#define OVERLAPPED      3  /* overlap region                               */
#define DO_NOT_PROCESS  4  /* not to be processed                          */
#define DEGENERATE_SPAN 5  /* span degenerates to a point when made planar */


/*******************/
/***  from ve.h  ***/
/*******************/

/* visibility node structure */
struct VEvisib_node
	{
	struct VEvisib_node       *next;        /* pointer to next node                   */
	IGRshort                  visib;        /* visibility for span from this node     */
	                                        /* to the next one in the list            */
	IGRdouble                 u;            /* u value of visiblity change            */
	};


/**********************/
/***  from veerr.h  ***/
/**********************/

/*
DESCRIPTION
	Macros for checking return codes.  If you want return codes to be tested,
	define CHECK_RETURN_CODES as 1.  If you do not want return codes to be tested,
	define CHECK_RETURN_CODES as 0. 
	
HISTORY
	S.P. Rogers  01/05/87  Creation Date
*/

#if CHECK_RETURN_CODES

extern IGRboolean VEreport_errors;

#   define OM_ERRCHK( status, string )			             \
	 						             \
  	   if ( (VEreport_errors) && (! (1 & status)) )              \
	      {						             \
	      fprintf( stderr, "%s, sts = %d\n", string, status );   \
	      om$report_error( sts = status );                       \
	      }


#   define MSG_ERRCHK( msg, string )			          \
							          \
  	   if ( (VEreport_errors) && (! (1 & msg)) )              \
	      {						          \
	      fprintf( stderr, "%s, msg = %d\n", string, msg );   \
	      }


#   define BS_ERRCHK( rc, string )                                 \
	                                                           \
	   if ( (VEreport_errors) && (rc != BSSUCC) )              \
	      {                                                    \
	      fprintf( stderr, "%s, rc = %d\n", string, rc );      \
	      }


#   define BS_STSCHK( sts, string )                              \
	                                                         \
	   if ( (VEreport_errors) && (! sts) )                   \
	      {                                                  \
	      fprintf( stderr, "%s, sts = %d\n", string, sts );  \
	      }

#else

#   define OM_ERRCHK( sts, string )

#   define MSG_ERRCHK( msg, string )

#   define BS_ERRCHK( rc, string  )

#   define BS_STSCHK( sts, string )

#endif

#endif
