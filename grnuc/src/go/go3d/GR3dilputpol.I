/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dinfline
     METHOD NAME:  GRputpolyline

     Abstract: 
		This method posts a 3-D floating point infinite 
	line geometry into the object's instance data.  
-----
%SC%    
     GRputpolyline(msg,md_env,post_info,absptr,newobjid)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------

     *md_env     struct GRmd_env     structure defining the transfor-
				      mation and other info about
				      the object
     *post_info  struct GRpost_info  processing control information
     *polyline	 struct IGRpolyline  pointer to buffer containing
				       the polyline
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
-----
%CH%

     CHANGE HISTORY:
	

	MAS	10/19/87 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method posts an infinite line to its 3-D floating
	point instance data.  Before the instance data is modified, 
	the input polyline is transformed to local coordinates using
	the input environment information.  A new range for the object
	is then	calculated and compared against the design limits.
	If all operations succeed, the instance data for the object is
	posted.  The object is updated in the R-tree if the module id
	is not NULL_OBJID.
----*/
/*EH*/

class implementation GR3dinfline;

#include "grimport.h"
#include "godef.h"
#include "gocmacros.h"
#include "madef.h"
#include "msdef.h"
#include "grerr.h"
#include "mapriv.h"

extern    IGRboolean    MAptsxform();
extern    IGRboolean    MAlncbclip();
extern    IGRboolean    MApyextents();
extern    IGRboolean    MAinvmx();

method GRputpolyline(IGRlong *msg; struct GRmd_env *md_env;
	struct GRpost_info *post_info;struct IGRpolyline *polyline;
	GRobjid *newobjid)
{
    IGRshort		mxsize,
			chan_flag,
 			del_flag;

    IGRlong	  	OMmsg,		/* return status for method 	*/
			msg1;		/* internal message variable    */

    IGRint		i,		/* loop counter		     	*/
		        index,
			index2;

    IGRdouble		ext_point[6],
			points[6],
			x_formed_pts[30],
			*ptr,
			tparm,
			dis,dis1,
			end_num,beg_num,cmp_num,
 			max;

    IGRpoint		pt1,pt2;

    struct IGRline	org_line,
    			ext_line;

    IGRmatrix		invmx;

    GRrange		range;
    GRrange		old_range;

    IGRboolean		beg,		/* infinite at first end	*/
			ending,		/* infinite at second end	*/
 			value; 		/* return value for MA functions*/


/*
 * initialize variables 
 */

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;
	chan_flag = 1;
 	del_flag = 1;
	mxsize = 4;


	*newobjid = my_id;		/* object didn't change classes */

					/* transform to local coord.	*/
	if ( md_env->md_env.matrix_type != MAIDMX )
	{
	    if (! MAinvmx(&msg1,&mxsize,md_env->md_env.matrix,invmx) )
	    {
		*msg = GRSNOINVTRAN;
		OMmsg = OM_E_ABORT;
		goto wrapup;
	    }

	    if (! MAptsxform(&msg1,&polyline->num_points,invmx,
			polyline->points,x_formed_pts))
	    {
		*msg = MSFAIL;
	        OMmsg = OM_E_ABORT;
		goto wrapup;
	    }
	    ptr = x_formed_pts;
	}
	else
	{
	    ptr = polyline->points;
	}


	if (! post_info->construct_flag)
	{
	    if ((polyline->num_points > 4) || (me->inf_end == 3))
	    {
	   	/*
 	    	 *  object needs to change class
 	    	 *
 	    	 *	- construct a new object and fill-in instance data
	    	 *	- transfer all channel linkages to new object
	    	 *	- delete original object
		 */

	   	OMmsg = GRaltchgclass(msg,md_env,&my_id,"GR3dlinestr",
		    &me->properties,polyline,&chan_flag,&del_flag,
		    newobjid);

		goto wrapup;
	    }
	}
/*
 * find out if object is still infinite
 */
	beg = 0;
	ending = 0;

	max = GRDGNLIMITS_MAX_D - (1 + (MAETA*10));
	
	beg_num = MAabsolute(ptr[0]);
	end_num = MAabsolute(ptr[(polyline->num_points - 1)*3]);

	for ( i=1; i<3; ++i)
	{
	   cmp_num = MAabsolute(ptr[i]);

	   if (cmp_num > beg_num)
	   {
		beg_num = cmp_num;
	   }

	   cmp_num = MAabsolute(ptr[(polyline->num_points - 1)*3+i]);

	   if (cmp_num > end_num)
	   {
		end_num = cmp_num;
	   }
	}

        if (beg_num >= max)
	{
	    beg = 1;
 	}

        if ( end_num >= max)
	{
	    ending = 1;
	}

        if (! post_info->construct_flag)
	{
	    /* if the infinite line has been scaled, moved or rotated, 
	     * the indicators may not be correct, adjust them.
	     */

	    if (! (beg || ending))
	    {
		IGRdouble vc1[3],vc2[3],angle[3];

		if ( (polyline->num_points == 4) && (me->inf_end == 0))
		{
		    MA2pt2dis(&msg1,me->points,&me->points[3],&dis);
		    MA2pt2dis(&msg1,&ptr[3],&ptr[6],&dis1);
		    
		    if (dis > dis1)
		    {
			/* a scale of the infinite line may have
			 * occurred. Do not mark as clipped.
			 */

			beg = 1;
			ending = 1;
	      	    }
		    else
		    {
			/* check to see if the line is rotated so that
			 * points aren't at design cube edge.
			 */

			MAsubvc(&msg1,me->points,&me->points[3],vc1);
		    	MAsubvc(&msg1,&ptr[3],&ptr[6],vc2);
			MAang2vc(&msg1,vc1,vc2,angle);
					
			if (angle[0] > MAETA)
			{
			    /* line was rotated */

			    beg = 1;
	  		    ending = 1;
			}

	      	    }
		}
	    }
	    else if ((polyline->num_points == 4) && (!(beg && ending)))
	    {
		/* check to be sure the line has not been moved, if it
	  	 * has been moved, one of the endpoints may be no
		 * longer at the design cube limits. 
		 */

		if (beg)
		{
        	   if (beg_num  > max )
		   {
			/* beginning of line is no longer at the
			 * design cube limits, it is outside the
			 * limits, this means the ending indicator is
			 * incorrect, reset it.
			 */

	    		ending = 1;
 		   }
		}
		else
		{
        	    if (end_num  > max)
		    {
			/* ending of line is no longer at the
			 * design cube limits, it is outside the
			 * limits, this means the ending indicator is
			 * incorrect, reset it.
			 */

			beg = 1;
		    }
		}		
	    }
	}
		
	index = 0;
       	index2 = 3;

        if ( beg && ending)
	{
	    me->inf_end = 0;
	    if ( polyline->num_points > 2)
	    {
	 	index = 3;
		index2 = (polyline->num_points - 2) * 3;
	    }
	}
	else if ( beg )
	{
	    me->inf_end = 1;
 	    if (polyline->num_points > 2)
	    {
	        index = 3;
		index2 = (polyline->num_points - 1) * 3;
	    }
	}
	else if (ending)
	{
	    me->inf_end = 2;

	    if ( polyline->num_points > 2)
	    {
		index2 = (polyline->num_points - 2) * 3;
	    }
	}
	else
	{
	    me->inf_end = 3;
	    index2 = (polyline->num_points - 1) * 3;
	}


	points[0] = ptr[index++];
	points[1] = ptr[index++];
	points[2] = ptr[index++];

	points[3] = ptr[index2++];
	points[4] = ptr[index2++];
	points[5] = ptr[index2++];

	if (polyline->num_points == 2)
	{
	    /* if the infinite line has been clipped or split to
	     * two points we do not want the infinite points posted.
	     * If they are you can no longer manipulate the infinite
	     * line.
	     */

	    ext_line.point1 = points;
	    ext_line.point2 = &points[3];
	    tparm = 0.5;  

	    if (beg)	
	    {
		MAptattparm(&msg1,&tparm,&ext_line,points);
	    }
	    if (ending)
	    {
		MAptattparm(&msg1,&tparm,&ext_line,&points[3]);
	    }		
	}

	if ( me->inf_end == 3)
	{
	   ext_line.point1 = points;
	   ext_line.point2 = &points[3];
	}
	else
	{
	    org_line.point1 = points;
	    org_line.point2 = &points[3];

	    pt1[0] = pt1[1] = pt1[2] = GRDGNLIMITS_MIN_D+1;
	    pt2[0] = pt2[1] = pt2[2] = GRDGNLIMITS_MAX_D-1;

	    ext_line.point1 = ext_point;
	    ext_line.point2 = &ext_point[3];     

	    value = MAlncbclip(&msg1,&org_line,pt1,pt2,&ext_line);

	    if ( ! value )
	    {
#ifdef DEBUG
printf("design cube limits exceeded\n");
#endif
	        *msg = GRSDGNEXCEED;
	        OMmsg = OM_E_ABORT;
	        goto wrapup;
	    }

	    if ( me->inf_end == 1)
	    {
		ext_line.point2 = &points[3];
	    }
	    else if ( me->inf_end == 2)
	    {
		ext_line.point1 = &points[0];
	    }	    
	}

	if ( ! post_info->construct_flag)
	{
	    if (ext_line.point1[0] < ext_line.point2[0] )
	    {
	       	range[0] =  ext_line.point1[0];
	    	range[3] =  ext_line.point2[0];
	    }
	    else
	    {
	    	range[0] = ext_line.point2[0];
	    	range[3] = ext_line.point1[0];
	    }

	    if (ext_line.point1[1] < ext_line.point2[1] )
	    {
	    	range[1] =  ext_line.point1[1];
	    	range[4] =  ext_line.point2[1];
	    }
	    else
	    {
/****** FIX TR90N1453 *************************************/
/**
	        range[4] = ext_line.point2[1];
	    	range[1] = ext_line.point1[1];
**/
	        range[1] = ext_line.point2[1];
	    	range[4] = ext_line.point1[1];
	    }
	    if (ext_line.point1[2] < ext_line.point2[2] )
	    {
	    	range[2] =  ext_line.point1[2];
	    	range[5] =  ext_line.point2[2];
	    }
	    else
	    {
	    	range[2] = ext_line.point2[2];
	    	range[5] = ext_line.point1[2];
	    }

	    /*
 	     *  update the range in the  R-tree
 	     */

	    old_range[0] = old_range[3] = me->points[0];
	    old_range[1] = old_range[4] = me->points[1];
	    old_range[2] = old_range[5] = me->points[2];

	    OMmsg = GRupdaterng(&msg1,md_env,post_info,&my_id,
			&me->properties,old_range,range);
	
	    if (! (1 & OMmsg) )
	    {
#ifdef DEBUG
printf("GRupdaterng failed\n");
#endif
	      	*msg = MSFAIL;
	      	goto wrapup;
	    }
	}
/*
 *  update object
 */
	for ( i = 0; i < 3; ++i )
	{
	    me->points[i] = points[i];
	    me->points[i+3] = points[i+3];
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

end implementation GR3dinfline;
