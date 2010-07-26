/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRlinear
     METHOD NAME: GRaddpts

     Abstract: 	

		This method adds a set of points to the end of a 
	linear graphics object.  For a closed geometry (e.g., a
	polygon), the repeated last point is removed, the new 
	points are added, and a new repeated last point is 
	generated.

-----
%SC%    

	GRaddpts(msg,env,num,points,option,new_objid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *env	  GRmd_env	 structure defining the transformation
				 and other info about the object
     *num	  IGRshort	 number of points to add
     *points	  IGRdouble	 array of 3-D points to add
     *option	  IGRshort	 option to be used for closed linear
				 objects
				   - if = 0, then replace current
				     repeated last point with new 
				     list of points and close again
				     (primarily used for polygons)
				   - if = 1, then add current list
				     of points without deleting 
				     the current repeated point 
				     (primarily used for linestrings)
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				   - MSSUCC if successful     
				   - GRSNOINVTRAN (severe) if input
				     matrix is not invertible
				   - GRSDGNEXCEED (severe) if range
				     exceeds design limits
				   - MSFAIL (severe) if other error
     *new_objid	  GRobjid	 used if object changes classes, 
				 otherwise is same as my_id

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:

		MApytobc
		MA2pt2dis

     Methods:

		GRgenabsg
		GRpostabsg
-----
%RL%

     RELATIONS REFERENCED:	None.

-----
%NB%

     NOTES:			None.

-----
%CH%

     CHANGE HISTORY:
	
	MAS     03/27/86 : Design date.
	REJ	04/01/86 : Creation date.
	MEF	11/14/89 : Added support to prevent the creation of zero
  			   length segments.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	The new points are added at the end of the old points in the
	linear object.  If the object is physically closed and the 
	option requests that it remain closed, the endpoints of the
	object will remain the same and the new points will be 
	added before the endpoint.

	The new curve is then posted back into the object.

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"
#include "grerr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "mapriv.h"

method  GRaddpts(IGRlong *msg; struct GRmd_env *env; 
		 IGRshort *num; IGRdouble *points;
		 IGRshort *option; GRobjid *new_objid)
{
	IGRlong OMmsg;		  	/* OM return value		*/
	IGRlong i,j,k;		/* loop index			*/
	IGRlong msg2;			/* local return message		*/

    	IGRint  maintain_closure = 0,
		action;

        IGRdouble buffer[3003],
		dist;
	IGRdouble dist_sqtol;		/* tolerance */

	struct  IGRpolyline   polyline;	/* polyline structure		*/
	struct  GRpost_info  info;	/* information for GRpostabsg	*/

	IGRboolean status;		

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

/* 
 * Get the polyline using a default buffer.  Allow room in the
 * buffer to add the new points.
 */
	polyline.num_points = 1001 - *num;
        polyline.points = buffer;
        action = 2;		/* indicate default buffer sent in	*/

        OMmsg = om$send(msg= message GRlinear.GRgetpolyline
		(&msg2,&env->md_env.matrix_type,env->md_env.matrix,
		&action,&polyline),
	    targetid = my_id);

	if (! (1 & OMmsg & msg2))
  	{
	    if ( msg2 == MSINARG)
	    {
		/* the default buffer was not large enough. Malloc the
	 	 * necessary buffer.
		 */
		polyline.points =
		    (IGRdouble *)om$malloc(size=((polyline.num_points + *num) * sizeof(IGRpoint)));

		action = 1;

        	OMmsg = om$send(msg= message GRlinear.GRgetpolyline
			(&msg2,&env->md_env.matrix_type,env->md_env.matrix,
			&action,&polyline),
	    	    targetid = my_id);
	    }
	}

	if  (1 & msg2 & OMmsg)
	{
	                                  /* Get the tolerance */
 	    status = BSEXTRACTPAR(&msg2,BSTOLSQLENVEC,dist_sqtol);
            if (!status)
            {
          	*msg = MSFAIL;
          	OMmsg = OM_E_ABORT;
          	goto wrapup;
            }

	    if (*option == 0)
	    {
	  	MA2pt2dis(msg,polyline.points,
		    &polyline.points[(polyline.num_points - 1) *3],&dist);

		if (dist <= MAETA)
		{
		    maintain_closure = 1;
		    polyline.num_points -= 1; /* remove repeated point	*/
		}
	    }

	    /* add the new points to the buffer, check each new point to
	     * be sure we are not creating a 0 length segment.
	     */
	  	 
	    for (i = 0, j=polyline.num_points*3, k=0; i<*num;  i++)
	    {
		MA2pt2dis(&msg2,&polyline.points[j-3],&points[k],&dist);

		if (dist >= dist_sqtol)
		{   			/* point is okay,add to buffer	*/
	  	   polyline.points[j++] = points[k++];
	  	   polyline.points[j++] = points[k++];
	  	   polyline.points[j++] = points[k++];
		   polyline.num_points ++;
		}
		else			/* skip the point		*/
		{
		   k+=3;
		}
	    }

	    if (maintain_closure)
	    {
		/* j is positioned at the correct location from the loop;
		 * load the repeated point now.
		 */
	  	polyline.points[j++] = polyline.points[0];
	  	polyline.points[j++] = polyline.points[1];
	  	polyline.points[j++] = polyline.points[2];
	  	++polyline.num_points;
	    }

	    info.construct_flag = FALSE;

	    OMmsg = om$send(
	    	msg = message GRlinear.GRputpolyline
		   (msg,env,&info,&polyline,new_objid),
                senderid = my_id,
                targetid = my_id);

					/* clear the cache		*/
	    GRabsg_del_by_objid(new_objid,&OM_Gw_current_OS);

	    if (action == 1)
	    {
	        om$dealloc(ptr = polyline.points);
	    }
	
 	    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);        
	}
	else
	{
	    OMmsg = OM_E_ABORT;
	    *msg = MSFAIL;
	}		

wrapup:

	return (OMmsg);
}


end implementation GRlinear;



