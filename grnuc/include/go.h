/*
 * Include file for Graphics Objects (typedefs and structs only).
 */

#ifndef go_include

#define go_include

/* This file is dependant on the following include files:
 *
 * 	godef.h
 * 	gr.h
 * 	igr.h
 * 	igrdp.h
 *
 */

#if sun
#include "sunlimits.h"
#endif

#ifndef DI_PATH_MAX
#include "DIdef.h"
#endif

#include "msdef.h"

typedef double GRrange [6];
typedef char   GRname [DI_PATH_MAX];

enum GRdyn_flag {return_buf, free_buff, call_dynam};

struct GRsymbology
{
    struct IGRdisplay display_attr;	/* display attributes		*/
    short             level;		/* level index			*/
};

struct GRvg_construct
{
 	long		  *msg;		/* completion code msg		*/
	struct GRmd_env   *env_info;	/* env_info structure		*/
 	IGRboolean 	  newflag;	/* if TRUE then allocate object */
					/* only; if FALSE then allocate */
					/* and format			*/
	short 	          level;	/* level index			*/
	unsigned short    properties;	/* reserved properties		*/
 	char		  *geometry;	/* ptr to geometry		*/
	struct IGRdisplay *display;	/* ptr to display attributes	*/
	char		  *class_attr;	/* ptr to class specific attr.	*/
	char		  *name;	/* ptr to optional object name	*/
};

struct GRprops				/* geometry properties		*/
{
	short		type;		/* object type		        */
	short    	subtype;	/* subtype of object		*/

	IGRboolean	closed;		/* closed by definition		*/
					/* closed (TRUE) /open (FALSE)  */
	IGRboolean	phy_closed;	/* physically closed (TRUE) or  */
					/* open (FALSE)	element flag	*/
	IGRboolean	is_segmented;	/* segmented geometry flag     */
	IGRboolean	planar;		/* planar (TRUE) / nonplanar	*/
					/* (FALSE) element flag		*/
};

struct GRabsg_hdr			/* structure for absg cache	*/
{
	long		whole_size;	/* uninitialize for alloc routine*/
	long 		geometry_size;  /* geometry size in bytes  	*/
	struct GRid	id;		/* object id for geometry 	*/
	short		matrix_type;	/* type of matrix		*/
	IGRmatrix	matrix;		/* environment matrix		*/
};

struct GRparms				/*geometric parameters		*/
{
	double 	   u;			/* B-spline u parameter		*/
	double     v;			/* B-spline v parameter		*/
	IGRboolean polygon_inx;		/* polygon / curve (surf) flag	*
					 * 0 - parameter on smooth curve
					       or surface
					   1 - parameter on polygon
					   2 - parameter not on curve
						or polygon i.e.,
					       center of circle
					   3 - invalid, not set
					   4 - special parameter on
						extension of curve. 
					       parameter is stored in v */
	struct GRid leaf_id;		/* leaf node id if nested geom	*/
};


struct GRpost_info			/* information for GRpostabsg	*/
{
 	IGRboolean construct_flag;	/* object is being constructed	*/
};


struct GRobj_info			/* locate info of object	*/
{
	char type [MS_MAX_MSG_LENGTH]; 		/* type of object- line,point...*/
};


/* This structure is to be used by the GRfunction method. A macro is 
 * provided in gomacros.h to load this data structure.  Any entry not
 * needed by your user function can be set to be a null pointer.
 */

struct GRfunction_info
{
    struct GRmd_env   *md_env;		/* your module information	*/
    IGRboolean	      pass_to_other_spaces; 
					/* 0 = do not pass to other spaces.
					   1 = pass to other spaces	*/
    char	      *info;		/* information you want to pass to
					   your function		*/
};

#endif
