/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dlineseg
     METHOD NAME:  GRputpolyline

     Abstract: 
		This method posts the 3-D floating point line 
	segment graphics object into the object's instance data.  
	The input structure contains a transformation matrix that 
	may be applied to the object before posting.

-----
%SC%    
     GRputpolyline(msg,md_env,post_info,polyline,newobjid)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------

     *md_env    struct GRmd_env      structure defining the transfor-
				      mation and other info about
				      the object
     *post_info struct GRpost_info   processing control information
     *polyline	struct IGRpolyline   pointer to buffer containing
				      internal format representation
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - GRSNOINVTRAN (severe) if
				      input matrix is not invertible
			 	    - GRSDGNEXCEED (severe) if
				      range exceeds design limits
				    - MSFAIL (severe) if failure
      *newobjid   GRobjid	 used if object changes classes,
				    otherwise is same as my_id
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
    	     instance date will not be modified

	     If it is determined that the line
	     segment needs to change class, a
	     new object will be constructed, the
	     channel linkages of the original 
	     object will be transferred to the 
	     new object, and the original object
	     will be deleted.

-----
%CH%

     CHANGE HISTORY:

	MAS	10/19/87 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	The object is transformed to local coordinates using the
	inverse of the input matrix. 
	A new range for the object is then calculated and compared 
	against the design limits. If all operations succeed, the 
	instance data for the object is posted. The updated object is
	inserted into the R-tree using the new range, if the module
	id is not NULL_OBJID.
----*/
/*EH*/

class implementation GR3dlineseg;

#include "grimport.h"
#include "godef.h"
#include "gocmacros.h"
#include "madef.h"
#include "msdef.h"
#include "grerr.h"

extern    IGRboolean    MAptsxform();

method GRputpolyline(IGRlong *msg; struct GRmd_env *md_env;
	struct GRpost_info *post_info; struct IGRpolyline *polyline; 
	GRobjid *newobjid)

{
    IGRlong	  	OMmsg;		/* return status for method 	*/
    IGRlong             num_points;
    IGRint		i;		/* loop counter		     	*/
    IGRlong		internal_msg;	/* internal message variable    */

    GRrange		range;
    GRrange		old_range;


    IGRchar		classname[80];  /* name of new class		*/

    IGRshort		chan_flag = 1;  /* indicator to preserve	*/
					/* channel linkages		*/
    IGRshort		del_flag = 1;   /* indicator to delete orig obj */

/*
 *  initialize variables
 */

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;
	*newobjid = my_id;		/* object didn't change classes */

/*
 *  transform the object to local coordinates
 *  and calculate the new range
 */
	
	OMmsg = GRposttransutil(msg,md_env,post_info,
		&polyline->num_points,polyline->points,range);

	if (! (1 & OMmsg) )
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

	if (polyline->num_points != 2 ) 
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
		    MAptsxform (&internal_msg,&polyline->num_points,
				md_env->md_env.matrix,polyline->points,
				polyline->points);
		}
		if ( polyline->num_points == 0)
		{
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;
		}
		else
		{		
		    if ( polyline->num_points == 1)
		    {
		    	strcpy(classname,"GR3dpoint");
		    }
		    else if (polyline->num_points > 2)
		    {
		        strcpy(classname,"GR3dlinestr");
		    }

		    OMmsg = GRaltchgclass(msg, md_env, &my_id, 
		        classname, &me->properties, polyline, &chan_flag, 
		        &del_flag, newobjid);
		}

		goto wrapup;
	    }
	}
    
/*
 *  if the object is not being constructed,
 *  update the range in the object and the R-tree
 */

	if ( ! post_info->construct_flag )
	{
	    old_range[0] = old_range[3] = me->points[0];
	    old_range[1] = old_range[4] = me->points[1];
	    old_range[2] = old_range[5] = me->points[2];

	    OMmsg = GRupdaterng(&internal_msg,md_env,post_info,&my_id,
				 &me->properties,old_range,range);

	    if (! (1 & OMmsg) )
	    {
		*msg = MSFAIL;
		goto wrapup;
	    }
	}

/*
 *  update object
 */
/* make sure we don't overwrite memory */

        if (polyline->num_points > 2)
            num_points = 2;
        else
            num_points = polyline->num_points;

	for ( i = 0; i < num_points * 3; ++i )
	{
	     me->points[i] = polyline->points[i];
	}

	if ( polyline->num_points == 1)
	{
	    me->points[3] = polyline->points[0];
	    me->points[4] = polyline->points[1];
	    me->points[5] = polyline->points[2];
	}
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

/*
 *  update properties word
 */

	if (! post_info->construct_flag)
	{
	    me->properties |= GRIS_MODIFIED;
	}

	me->properties = (me->properties | GRIS_PLANAR) 
		& (~GRFILLED_DISPLAY);

        GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_POSTED);

wrapup:

    return(OMmsg);
}

end implementation GR3dlineseg;
