/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "msdef.h"
#include "godef.h"
#include "OMerrordef.h"

extern IGRboolean MAlncbclip();

IGRlong GRlnoffset(msg,offset_env,py,projection_matrix,
	distance,distance_boreline,direction_boreline,classname,
	inf_end,apparent_flag,properties,objid,new_objid)

IGRlong 	*msg; 
IGRchar		*offset_env;
struct IGRpolyline *py;
IGRdouble	*projection_matrix;
IGRdouble 	*distance;
struct	IGRline *direction_boreline;
struct IGRline 	*distance_boreline;
IGRchar		*classname;
IGRchar		*inf_end;
IGRboolean	*apparent_flag;
IGRshort	*properties;
GRobjid		*objid,
		*new_objid;
{   

    IGRshort	chan_flag,
		del_flag;

    IGRlong	OMmsg,
		msg2;

    IGRdouble 	dist,
		dist1;

    IGRdouble	*pt1,*pt2,n[3],n1[3],n2[3],
		point1[3],point2[3],t1,t2,
		points[24];
    IGRdouble   lim_pt1[3],lim_pt2[3];

    struct IGRline org_line,ext_line;

    struct IGRline	ln,
		offset_ln1,
		offset_ln2;

    struct IGRpolyline offset_py;

    extern IGRboolean MAlnoffset();
 
    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    pt1 = &points[3];			/* adjust pointers for inf line	*/
    pt2 = &points[15];			
    offset_ln1.point1 = pt1;
    offset_ln1.point2 = &pt1[3];
    offset_ln2.point1 = pt2;
    offset_ln2.point2 = &pt2[3];

    if ( *apparent_flag)
    {
	MAptsxform(msg,&py->num_points,projection_matrix,
		py->points,py->points);
    }

    ln.point1 = &py->points[0];
    ln.point2 = &py->points[3];

    /* determine distance
     */

    if (distance)
    {
	dist = *distance;
    }
    else
    {
	 MA2lndis(msg,&ln,distance_boreline,&dist);
    }

    MA2lnproj(msg,&ln,direction_boreline,point1,point2,&t1,&t2);
    MAsubvc(msg,ln.point1,ln.point2,n1);
    MAsubvc(msg,point1,point2,n2);
    MAcrossvc(msg,n1,n2,n);
    if (MAlnoffset(msg,&ln,&dist,n,&offset_ln1,&offset_ln2))
    {
	/* determine which line to use as the offset line
	 */
		
	MA2ln2dis(msg,&offset_ln1,direction_boreline,&dist);
	MA2ln2dis(msg,&offset_ln2,direction_boreline,&dist1);

	offset_py.num_points = 2;

	offset_py.points = (dist < dist1 ? pt1 : pt2);
	    
	/* construct the new offset curve
     	 */

	if (inf_end)
	{

	    if (*inf_end != 3)
	    {

		/* the array for the org_line points and ext_line
		 * points is contiguous, the pointer for the
		 * resultant polyline points will be adjusted
		 * for the infinite ends
		 */

	        org_line.point1 = &offset_py.points[0];
	        /*
	         * the previous statement was causing the function
	         * MAlncbclip to crash, because it was assigning
	         * &offset_py.points instead of &offset_py.points[0]
	         * This fixed TR#90n2528. 5/4/92, Carlos.
	         */ 
	        org_line.point2 = &offset_py.points[3];

                lim_pt1[0] = lim_pt1[1] = lim_pt1[2] = GRDGNLIMITS_MIN_D;
	        lim_pt2[0] = lim_pt2[1] = lim_pt2[2] = GRDGNLIMITS_MAX_D;
					
	    	ext_line.point1 = offset_py.points - 3;
	    	ext_line.point2 = offset_py.points + 6;

	    	if (! (MAlncbclip(&msg2,&org_line,lim_pt1,lim_pt2,
			&ext_line)))
		{
		    OMmsg = OM_E_ABORT;
		    *msg = MSFAIL;
		    goto wrapup;
	  	}

	    	if ( *inf_end == 1 )
	    	{   			/* first point is infinite	*/
	    	    offset_py.num_points = 3;
		    offset_py.points = ext_line.point1;
		}
		else if (*inf_end == 2)
		{    			/* second point is infinite	*/
		    offset_py.num_points = 3;
		}
		else
		{			/* both are infinite		*/
		    offset_py.num_points = 4;
		    offset_py.points = ext_line.point1;
		}		
	    }
	}		

    	chan_flag = FALSE;
    	del_flag = FALSE;

    	GRaltchgclass(msg,offset_env,objid,classname, 
	    properties,&offset_py,&chan_flag,&del_flag,new_objid);

        if (! (1 & *msg))
    	{
	    *msg = MSFAIL;
  	    OMmsg = OM_E_ABORT;
	}
    }

wrapup:
    return (OMmsg);
}
