/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRorthogonal
     METHOD NAME:  GRdelvertex

     Abstract:  This routine deletes the selected vertex
		from the object.

-----
%SC%    

     GRdelvertex(msg,md_env,ref_parms,newobjid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env	   GRmd_env	  environment information 
     *ref_parms	   GRparms	  parameters identifying nearest
				     vertex
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
	    	MAang2vc

     Methods:   GRpostabsg
		GRgeomprops
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  Because a point has only one vertex, that
	     vertex cannot be deleted.

	     Also, if an object with 2 points has a 
	     vertex deleted, then the post routines
	     currently do not change class.
-----
%CH%

     CHANGE HISTORY:
	
	KMO	08/06/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method deletes a vertex from the object.  The
	desired vertex to delete is identified by the input
	reference parameters.

----*/
/*EH*/

class implementation GRorthogonal;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "madef.h"
#include "mapriv.h"
#include "godef.h"

extern    IGRboolean    MAutoparms();
extern    IGRboolean    MAang2vc();
extern    IGRboolean    MApytobc();

method GRdelvertex(IGRlong *msg; struct GRmd_env *md_env;
	    	  struct GRparms *ref_parms; GRobjid *newobjid)
{
    IGRlong 		status;		/* return status for method	*/
    IGRchar		*buffer;	/* pointer to dynamic buffer	*/
    struct IGRpolyline	py;
    struct IGRbsp_curve *curve;
    struct GRprops	properties;
    struct GRpost_info  info;
    IGRdouble		tparm;
    IGRlong		save_num;
    IGRlong		segnum;
    IGRlong		i;
    IGRvector		vector1,vector2;
    IGRdouble		angle[3];
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
    save_num = curve->num_poles;

/*
 *  determine which vertex to delete
 */

    if (( 1 & MAutoparms(&internal_msg,curve,&ref_parms->u,
		         &segnum,&tparm)) && (segnum >= 1) ) 
    {
	status = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgeomprops(msg,&md_env->md_env.matrix_type,md_env->md_env.matrix,&properties),
                         senderid = my_id,
                         targetid = my_id);

	if ( ! (1 & status & *msg))
	{
	    *msg = MSFAIL;
	    status = OM_E_ABORT;
	    goto wrapup;
	}

	if (( segnum == 1 ) && ( tparm <= 0.5 ))
	{
	    /*
	     *  delete start point of object if
	     *  next point is duplicate
	     */

	    if (( curve->poles[0] == curve->poles[3] )
	       && ( curve->poles[1] == curve->poles[4] )
	       && ( curve->poles[2] == curve->poles[5] ))
	    {
		curve->num_poles -= 1;
		for ( i = 0; i < curve->num_poles * 3; ++i )
		{
		    curve->poles[i] = curve->poles[i+3];
		}
	    }
	    else
	    {
		if ( properties.closed )
		{
		    /*
		     *  object is a polygon
		     *  no duplicate at beginning of object
		     *  check for duplicate at end of object 
		     */

		    if (( curve->poles[0] == 
			  curve->poles[(curve->num_poles-2) * 3] )
		       && ( curve->poles[1] ==
			  curve->poles[((curve->num_poles-2) * 3) + 1] )
		       && ( curve->poles[2] ==
			  curve->poles[((curve->num_poles-2) * 3) + 2] ))
		    {
			curve->num_poles -= 1;
		    }
		}
	    }	
	}
	else if (( segnum == curve->num_poles - 1) && ( tparm > .5 ))
	{
	    /*
	     *  delete end point of object if
	     *  previous point is a duplicate
	     */

	    if (( curve->poles[segnum * 3] == curve->poles[(segnum-1) * 3])
	       && ( curve->poles[(segnum * 3) + 1] ==
		    curve->poles[((segnum-1) * 3) + 1] )
	       && ( curve->poles[(segnum * 3) + 2] ==
		    curve->poles[((segnum-1) * 3) + 2] ))
	    {
		curve->num_poles -= 1;
	    }
	    else
	    {
		if ( properties.closed )
		{
		    /*
		     *  object is a polygon
		     *  no duplicate at end of object
		     *  check for duplicate at beginning of object 
		     */

		    if (( curve->poles[segnum * 3] == curve->poles[3] )
		      && ( curve->poles[(segnum * 3) + 1] == curve->poles[4] )
		      && ( curve->poles[(segnum * 3) + 2] == curve->poles[5] ))
		    {
			curve->num_poles -= 1;
			for ( i = 0; i < curve->num_poles * 3; ++i )
			{
			    curve->poles[i] = curve->poles[i + 3];
			}
		    }
		}
	    }
	}
	else
	{

	    /*
	     *  selected vertex in between the endpoints of
	     *  the object, so check if either adjacent vertex 
	     *  is a duplicate, or if either adjacent vector
	     *  is coplanar with the selected segment
	     */

	    if ( tparm <= .5 )
	    {
		segnum -= 1;
	    }

	    /* 
	     *  delete ending point of segment
	     */

	    if ((( curve->poles[segnum * 3] == curve->poles[(segnum-1) * 3] )
	       && ( curve->poles[(segnum * 3) + 1] ==
		    curve->poles[((segnum-1) * 3) + 1] )
	       && ( curve->poles[(segnum * 3) + 2] ==
		    curve->poles[((segnum-1) * 3) + 2] )) ||
		(( curve->poles[segnum * 3] == curve->poles[(segnum+1) * 3] )
	       && ( curve->poles[(segnum * 3) + 1] ==
		    curve->poles[((segnum+1) * 3) + 1] )
	       && ( curve->poles[(segnum * 3) + 2] ==
		    curve->poles[((segnum-1) * 3) + 2] )))
	    {
		curve->num_poles -= 1;
		for ( i = segnum * 3; i < curve->num_poles * 3; ++i )
		{
		    curve->poles[i] = curve->poles[i + 3];
		}
	    }
 	    else
	    { 
	        for ( i = 0; i < 3; ++i )
	        {
	    	    vector1[i] = curve->poles[(segnum * 3) + i] - 
			         curve->poles[((segnum-1) * 3) + i];
		    vector2[i] = curve->poles[(segnum * 3) + i] -
			         curve->poles[((segnum+1) * 3) + i];
	        }

	        MAang2vc(&internal_msg,vector1,vector2,angle);

	        if ( internal_msg == MSFAIL )
	        {
		    *msg = MSFAIL;
		    status = OM_E_ABORT;
		    goto wrapup;
	        }
	
	        if ( MAabsolute(angle[1]) <= MAETA * 10000 )
	        {
		    /*
		     *  if the sine the angle is zero then the
		     *  adjacent vectors are coplanar
	             */

		    curve->num_poles -= 1;
		    for ( i = segnum * 3; i < curve->num_poles * 3; ++i )
		    {
		        curve->poles[i] = curve->poles[i + 3];
		    }
	        }
	    }
	}

	/*
	 *  if only one vertex remains in the object,
	 *  duplicate it so that a valid B-spline can
	 *  be created
	 */

	if ( curve->num_poles == 1 )
	{
	    curve->num_poles += 1;
	    curve->poles[3] = curve->poles[0];
	    curve->poles[4] = curve->poles[1];
	    curve->poles[5] = curve->poles[2];
	}

	/*
	 *  if a vertex could not be deleted,
	 *  then skip calling the post routine
	 */

	if ( curve->num_poles != save_num )
	{
            /*
             *   post geometry
             */

            py.num_points = curve->num_poles;
            py.points = curve->poles;

	    info.construct_flag = FALSE;

            status = om$send(mode = OM_e_wrt_object,
                             msg = message GRlinear.GRputpolyline
		(msg,md_env,&info,&py,newobjid),
                             senderid = my_id,
                             targetid = my_id);
	
	    /*
	     *  remove abstract geometry representation
	     */
    
	    GRabsg_del(curve);
        }
    }

	GR_NOTIFY_LISTENERS(msg,&status,GR_GEOM_MODIFIED);
wrapup:

	return(status);

}

end implementation GRorthogonal;
