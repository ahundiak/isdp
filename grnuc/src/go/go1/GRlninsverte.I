/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRlinear
     METHOD NAME:  GRinsvertex

     Abstract:  This routine inserts the input vertex into
		the object at the specified location.  
		Special processing is performed if the
		input vertex should be inserted at a current
		vertex point or if the object is a polygon
		and the vertex is to be inserted at the
		start/end point.
-----
%SC%    

     GRinsvertex(msg,md_env,ref_parms,boreline,newobjid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env	   GRmd_env	  environment information 
     *ref_parms	   GRparms	  parameters identifying segment
     *boreline     IGRline	  the desired vertex to insert
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *newobjid     GRobjid	 will contain a new object id if the
				    object changes classes 
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:   MAutoparms
		MApytobc

     Methods:   GRpostabsg
		GRgeomprops
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
	
	KMO     05/09/86 : Design date.
	KMO	05/09/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This routine receives a vertex point to insert into
	the linear object at a specified location (also received
	as input).  Special processing will occur based on the
	type of object.  Following is a description of this
	special processing:

	point:
	  a line is formed, the new point becomes the start
		point and the original point becomes the
		endpoint

        line:
	  if selected location is exactly an endpoint,
		new point becomes new endpoint
	  otherwise, new point is added between 
	       	endpoints

	line string:
	  if selected location is exactly start or end
		point, start or end is replaced by new point
	  if selected location is a vertex of segment,
		new point is inserted before vertex of segment
	  if selected location is between the endpoints of a
		segment, the new point is inserted there

	polygon:
	  processed exactly like the line string except for the
	  	following case
 	  if selected location is the start/end point,
		the new point is inserted before the start point
		to become the new start point and the original
		endpoint is modified to close the polygon (becomes
		the new point also).
----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "madef.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"

extern    IGRboolean    MAutoparms();
extern    IGRboolean    MApytobc();

method GRinsvertex(IGRlong *msg; struct GRmd_env *md_env;
	    	  struct GRparms *ref_parms; struct IGRline *boreline;
		  GRobjid *newobjid)
{
    IGRlong 		status;		/* return status for method	*/
    IGRlong		nbytes;		/* size of dynamic buffer	*/
    IGRchar		*buffer;	/* pointer to dynamic buffer	*/
    struct IGRpolyline	py;
    struct IGRbsp_curve *curve;
    struct IGRbsp_curve *new_curve;
    struct GRprops	properties;
    struct GRpost_info  info;
    IGRdouble		tparm;
    IGRlong		segnum;
    IGRlong		i;
    IGRlong 		index;
    IGRlong		num_poles;
    IGRlong		internal_msg;

/*
 *  initialize variables
 */

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

/*
 *  get abstract geometry of object
 */

    GRgetabsg(&internal_msg,&md_env->md_env.matrix_type,
	      md_env->md_env.matrix,&buffer,i);
 
    if (! (1 & internal_msg))
    {
	*msg = MSFAIL;
	status = OM_E_ABORT;
	goto wrapup;
    }  

    curve = (struct IGRbsp_curve *)buffer;

/*
 *  new number of poles in object
 */

    num_poles = curve->num_poles + 1;

/*
 *  allocate and partition buffer for new representation 
 */

    GRbc_size(curve->order,num_poles,curve->rational,
	      curve->num_boundaries,nbytes);

    buffer = om$malloc(size = nbytes);

    if ( buffer == 0 )
    {
	*msg = MSFAIL;
	status = OM_E_ABORT;
	goto wrapup;
    }

    new_curve = (struct IGRbsp_curve *)buffer;

/*
 *  partition new buffer to hold curve structure
 */

    new_curve->poles = (IGRdouble *) GRalign_double(new_curve + 1);
    new_curve->knots = &new_curve->poles[num_poles * 3];

/*
 *  determine where to insert the vertex (which segment)
 */

    if (( 1 & MAutoparms(&internal_msg,curve,&ref_parms->u,
		         &segnum,&tparm)) && (segnum >= 1) ) 
    {
	/*
	 *  check for line or point object
	 */

     	if ( curve->num_poles == 2 )
	{
	    if (( curve->poles[0] == curve->poles[3]) &&
		( curve->poles[1] == curve->poles[4]) &&
		( curve->poles[2] == curve->poles[5]))
	    {
 	        /* 
		 *  object is a point
	         *  form a line using the new point as the
	         *  start point and the original point as the
	         *  end point
  	         */

	        for ( i=0; i<3; ++i )
	        {	
		    new_curve->poles[i+3] = curve->poles[i];
		    new_curve->poles[i] = boreline->point1[i];
		    num_poles = 2;
	        }
	    }
	    else
	    {
	        /*
	         *  object is a line
		 *  determine where to add the new point
		 */

	        if ( tparm == 0.0 )
	        {
		    /*
		     *  add point to beginning of line
		     */

		    for ( i=0; i<3; ++i )
		    {
		        new_curve->poles[i+6] = curve->poles[i+3];
		        new_curve->poles[i+3] = curve->poles[i];
		        new_curve->poles[i] = boreline->point1[i];
		    }
	        }

	        if ( tparm == 1.0 )
	        {
		    /*
		     *  add point to end of line
		     */

		    for ( i=0; i<3; ++i )
		    {
		        new_curve->poles[i] = curve->poles[i];
		        new_curve->poles[i+3] = curve->poles[i+3];
		        new_curve->poles[i+6] = boreline->point1[i];
		    }
	        }

	        if (( tparm != 0.0 ) && ( tparm != 1.0 ))
	        {
		    /*
		     *  add point between endpoints of line
		     */

		    for ( i=0; i<3; ++i )
		    {
		        new_curve->poles[i+6] = curve->poles[i+3];
		        new_curve->poles[i+3] = boreline->point1[i];
			new_curve->poles[i] = curve->poles[i];
		    }
	        }
	    }
	}
	else
	{
	    /*
	     *  object is a line string or polygon
	     */
	
	    if (( segnum == 1 ) &&  ( tparm == 0.0 ))
	    {
		/*
		 *  vertex is new start point
		 */

		for ( i = (num_poles * 3) - 1; i > 2; --i )
		{
		    new_curve->poles[i] = curve->poles[i-3];
		}

		index = 0;

		status = om$send(mode = OM_e_wrt_object,
                                 msg = message GRvg.GRgeomprops(msg,&md_env->md_env.matrix_type,md_env->md_env.matrix,&properties),
                                 senderid = my_id,
                                 targetid = my_id);

		if ( ! (1 & status & *msg) )
		{
		    *msg = MSFAIL;
		    status = OM_E_ABORT;
		    goto wrapup;
		}

		if ( properties.closed )
		{
		    /*
		     *  for polygon, endpoint must also change
		     */

		    new_curve->poles[num_poles * 3 - 3] = boreline->point1[0];
		    new_curve->poles[num_poles * 3 - 2] = boreline->point1[1];
		    new_curve->poles[num_poles * 3 - 1] = boreline->point1[2];
		}
	    }

       else if (( segnum == curve->num_poles - 1) && ( tparm == 1.0 ))
	    {
		/*
		 *  vertex is new endpoint
		 */

		index = curve->num_poles * 3;
	    }

       else if (( tparm == 0.0 ) || ( tparm == 1.0 ))
	    {
		/*
		 *  new point must be inserted at a vertex
		 *  point of the object
		 */

		if ( tparm == 1.0 )
		{
		    /*
		     *  adjust segment number so vertex
		     *  will be inserted in correct place
		     */

		    segnum += 1;
		}
		
		/*
		 *  make room for new point before
		 *  identified vertex
		 */

		for ( i = (num_poles * 3) - 1; i >= segnum * 3; --i )
		{
		    new_curve->poles[i] = curve->poles[i-3];
		}

		/*
		 *  set up index to insert new point
		 */

		index = (segnum - 1) * 3;
	    }
	    else 		/*  ( tparm != 0.0 ) && ( tparm != 1.0 )  */
	    {
		/*  make room for new point between
		 *  the endpoints of the identified
		 *  segment
		 */

		for ( i = (num_poles * 3) - 1; i >= (segnum + 1) * 3; --i)
		{
		    new_curve->poles[i] = curve->poles[i-3];
		}

		/*  
		 *  set up index to insert new pole
		 */

		index = segnum * 3;
	    }

 	    /*
	     *  insert new point
	     */

	    for ( i=0; i<3; ++i )
	    {
	        new_curve->poles[index + i] = boreline->point1[i];
	    }

	    /* 
	     * insert preceeding points
	     */
	    
	    for (i=0; i<index; ++i)
	    {
		new_curve->poles[i] = curve->poles[i];
	    }
	}

	/*
	 *  complete the curve and post geometry
	 */

	py.num_points = num_poles;
	py.points = new_curve->poles;

	info.construct_flag = FALSE;

	status = om$send(mode = OM_e_wrt_object,
              		msg = message GRlinear.GRputpolyline
		(msg,md_env,&info,&py,newobjid),
                         senderid = my_id,
                         targetid = my_id);
    }

/*
 *  deallocate memory
 */
    
    GRabsg_del(curve);
    om$dealloc(ptr = new_curve);

	GR_NOTIFY_LISTENERS(msg,&status,GR_GEOM_MODIFIED);
wrapup:

	return(status);

}

end implementation GRlinear;
