/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRlinear
     METHOD NAME:  GRdelvertex

     Abstract:  This routine deletes the selected vertex
		from the object.  If the object is a
		polygon	and the vertex to be deleted is
		the start/end point, special processing
		must occur.
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
	
	KMO     05/13/86 : Design date.
	KMO	05/13/86 : Creation date.
	MAS	07/04/88 : Modified to check for point objects

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method deletes a vertex from the object.  The
	desired vertex to delete is identified by the input
	reference parameters.  Special processing must occur
	for certain objects.  Following is a description of
	this special processing:

	point or zero length line:
	   it is illegal to delete a vertex from a point or
	   a zero length line segment. An error is returned

	line segment:
	   when the vertex is deleted, a point object must
	   be constructed

	polygon:
	   if the deleted vertex is the start/end point,
	   the second point in the polygon becomes the
	   new start/end point
----*/
/*EH*/

class implementation GRlinear;


#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"
#include "mapriv.h"

method GRdelvertex(IGRlong *msg; struct GRmd_env *md_env;
	    	  struct GRparms *ref_parms; GRobjid *newobjid)
{
    IGRlong 		status;		/* return status for method	*/
    IGRchar		*buffer;	/* pointer to dynamic buffer	*/
    struct IGRpolyline	py;
    struct IGRbsp_curve *curve;
    struct GRprops	properties;
    struct GRpost_info  info;
    IGRdouble		tparm,
			dis;
    IGRlong		segnum;
    IGRlong		i, j;
    IGRlong		internal_msg;

    extern IGRboolean		MAutoparms();
    extern IGRboolean		MApytobc();

/*
 *  initialize variables
 */

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

/*
 *  get abstract geometry of object
 */
    curve = NULL;
    GRgetabsg(&internal_msg,&md_env->md_env.matrix_type,
	      md_env->md_env.matrix,&buffer,i);
 
    if (! (1 & internal_msg))
    {
	*msg = MSFAIL;
	status = OM_E_ABORT;
	goto wrapup;
    }  
    curve = (struct IGRbsp_curve *)buffer;

    if ( curve->num_poles == 2)
    {  
        MA2pt2dis(&internal_msg,curve->poles,&curve->poles[3],&dis);

        if (dis <= MAETA)	/* object is a point already		*/
        {
	    *msg = MSFAIL;	
	    status = OM_E_ABORT;
	    goto wrapup;
	}
    }  
	
/*
 *  initialize polyline
 */

    py.num_points = curve->num_poles - 1;
    py.points = curve->poles;

/*
 *  determine which vertex to delete
 */

    if (1 & MAutoparms(&internal_msg,curve,&ref_parms->u,&segnum,&tparm)) 
    {
	status = om$send(
           msg = message GRvg.GRgeomprops
		(msg,&md_env->md_env.matrix_type,md_env->md_env.matrix,
		 &properties),
           senderid = my_id,
           targetid = my_id);

	if ( ! (1 & status & *msg))
	{
	    *msg = MSFAIL;
	    status = OM_E_ABORT;
	    goto wrapup;
	}

	if ((segnum == 1) && ( tparm <= 0.5 ))
	{
	    /*
	     *  delete beginning point of element 
	     */

	    py.points = &curve->poles[3];

	    if ( properties.closed && (segnum == 1 ))
	    {
		/*
		 *  object is a polygon
		 *  endpoint must be modified because
		 *  startpoint was deleted
		 */

		i = (py.num_points - 1) * 3;

		py.points[i++] = py.points[0];
		py.points[i++] = py.points[1];
		py.points[i++] = py.points[2];
	    }
	}
	else if ((segnum == py.num_points) && (tparm >= 0.5))
	{
	    /* 
	     *  Delete end point of element. For non-closed case
	     *  the value has already been decremented so there is
	     *  nothing to do.
	     */

	    if ( properties.closed)
	    {
		/*  
		 *  object is a polygon
		 *  endpoint was deleted, startpoint must be modified
		 */

	        i = (py.num_points - 1) * 3;
		py.points[0] = py.points[i++];
		py.points[1] = py.points[i++];
		py.points[2] = py.points[i++];

	    }
	}
	else
	{
	    if (tparm <= 0.5)
	    {
		i = (segnum - 1) * 3;
	    }
	    else
	    {
		i = segnum * 3;
	    }

	    /* Delete a pole in the interior portion of the curve
	     */

	    for ( j = i; j < py.num_points * 3; ++j )
	    {
		py.points[j] = py.points[j+3];
	    }
	}

        /*
         *   post geometry
         */

	info.construct_flag = FALSE;

        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRlinear.GRputpolyline
		(msg,md_env,&info,&py,newobjid),
                         senderid = my_id,
                         targetid = my_id);
    }

wrapup:

/*
 *  remove abstract geometry representation
 */
    
    GRabsg_del(curve);

    GR_NOTIFY_LISTENERS(msg,&status,GR_GEOM_MODIFIED);

    return(status);

}
end implementation GRlinear;
