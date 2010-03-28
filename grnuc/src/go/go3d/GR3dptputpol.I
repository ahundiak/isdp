/* #######################    APOGEE COMPILED   ######################## */
/*---- 
%GP% CODE CLASSIFICATION
----
%HD%

     CLASS  NAME:  GR3dpoint 
     METHOD NAME:  GRputpolyline

     Abstract:  This method posts the instance data for a 3-D 
		double precision point object.
		The input structure contains a transformation 
		matrix that may be applied to the object before 
		posting.
-----
%SC%    

     GRputpolyline(msg,md_env,post_info,polyline,newobjid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------

     *md_env	 struct GRmd_env      structure defining the environment
				       information
     *post_info  struct GRpost_info   processing control information
     *polyline   struct IGRpolyline   pointer to geometry
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION 
     ----------   ------------   ----------------------------------- 
        *msg	  IGRlong         completion code 
				     - MSSUCC if successful
				     - GRSNOINVTRAN (severe) if 
				       input matrix is not
				       invertible
				     - GRSDGNEXCEED (severe) if
				       range exceeds design limits
				     - MSFAIL (severe) if failure
     *newobjid	  GRobjid	 object id of object after posting
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:
-----
%RL%

     RELATIONS REFERENCED:  none.

-----
%NB%

     NOTES:  If a failure occurs, the object's
	     instance data will not be modified

	     If it is determined that the point
	     needs to change class, a new object
	     will be constructed, the channel
	     linkages of the original object will
	     be transferred to the new object,
	     and the original object will be deleted.
-----
%CH%

     CHANGE HISTORY:

        MAS     10/08/87 : Design date.
-----
%PD%
--------------------------------------------------------------------
M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method stores the geometry of a point object in
	the instance data.
	Before the instance data is modified, the internal format may 
	need to be transformed using the inverse of the matrix
	in the input structure.  A new range for the object is
	then calculated	and compared against the design limits.
	If all operations succeed, the instance data for the object is
	posted.  

	The object is updated in the R-tree, if the module id is
	not NULL_OBJID.
----*/
/*EH*/

class implementation GR3dpoint;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"
#include "grerr.h"

extern    IGRboolean    MAptsxform();

method GRputpolyline(IGRlong *msg; struct GRmd_env *md_env;
	struct GRpost_info *post_info; struct IGRpolyline *polyline; 
	GRobjid *newobjid) 
{
     IGRlong	  	status;		/* return status for method     */
     IGRlong		internal_msg;	/* internal message variable    */
     GRrange		range;
     GRrange		old_range;

     IGRchar		classname[80];
     IGRshort		chan_flag = 1;
     IGRshort		del_flag = 1;

/*
 *  initialize variables
 */

	status = OM_S_SUCCESS;
	*msg = MSSUCC;
	*newobjid = my_id;

/*
 *  transform the object to local coordinates
 *  and calculate the new range
 */
	status = GRposttransutil(msg,md_env,post_info,&polyline->num_points,
				 polyline->points,range);

	if (! (1 & status) )
	{
	    goto wrapup;
	}

/*
 *  check to see if object needs to change class
 *
 *  if so,
 *	- if construct flag set, alter data and continue as normal
 *	- otherwise, construct a new object and fill-in instance data
 *		- transfer all channel linkages to new object
 *		- delete original object
 */

	if (( polyline->num_points > 2 ) || ((polyline->num_points == 2) &&
	    (( polyline->points[0] != polyline->points[3] ) || 
	     ( polyline->points[1] != polyline->points[4] ) ||
	     ( polyline->points[2] != polyline->points[5] ))))
	{
	    if (! post_info->construct_flag )
	    {
		/*
		 *  if environment matrix is not identity
		 *  transform the points back to world coordinates
		 *
		 *  this restores the abstract geometry
		 */

		if ( md_env->md_env.matrix_type != MAIDMX )
	  	{
		    MAptsxform(&internal_msg,&polyline->num_points,
			       md_env->md_env.matrix,polyline->points,
			       polyline->points);
		}

		if ( polyline->num_points > 2 )
		{
		    strcpy ( classname, "GR3dlinestr" );
	 	}
		else
		{
		    strcpy ( classname, "GR3dlineseg" );
		}

		/*
		 *  construct new object
		 */

		status = GRaltchgclass(&internal_msg,md_env,&my_id,
			classname,&me->properties,polyline,&chan_flag,
			&del_flag,newobjid);
		
		if (! (1 & status) )
		{
		    *msg = MSFAIL;
		}

		goto wrapup;

	    }
	}

/*
 *  if the object is not being constructed
 *  update the range in the object and the R-tree
 */

	if (! post_info->construct_flag )
	{

	    old_range[0] = old_range[3] = me->point[0];
	    old_range[1] = old_range[4] = me->point[1];
	    old_range[2] = old_range[5] = me->point[2];

	    status = GRupdaterng(&internal_msg,md_env,post_info,&my_id,
			 	 &me->properties,old_range,range);

	    if (! (1 & status) )
	    {
		*msg = MSFAIL;
		goto wrapup;
	    }
	}
/* 
 *  update vertices in object
 */

	me->point[0] = polyline->points[0];
	me->point[1] = polyline->points[1];
	me->point[2] = polyline->points[2];

/*
 *  update properties word
 */

	if (! post_info->construct_flag)
	{
	    me->properties |= GRIS_MODIFIED;
	}

	me->properties = (me->properties | GRIS_PLANAR) 
		& (~GRFILLED_DISPLAY);

/*
 *  if environment matrix is not identity
 *  transform the points back to world coordinates
 *
 *  this restores the abstract geometry
 */

	if ( md_env->md_env.matrix_type != MAIDMX )
	{
	    MAptsxform(&internal_msg,&polyline->num_points,
		md_env->md_env.matrix,polyline->points,polyline->points);
	}

	GR_NOTIFY_LISTENERS(msg,&status,GR_GEOM_POSTED);

wrapup:

	return(status);

}

end implementation GR3dpoint;
