/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline
     METHOD NAME:	GR3ptpartdel

     Abstract: 	This module performs the partial delete operation
		on a B-spline curve geometry by deleting the 
		portion of the curve between point1 and point3 
		using point2 as a direction point to determine
		which portion of the curve to delete.  After 
		deletion of the desired segment, new object(s)
		will be constructed from the remaining portions 
		of the curve if the curve is open.  If the curve
		is closed, the remaining portions will be 
		concatenated into a single curve with the 
		parameterization adjusted so that point1 is
		the beginning point of the new curve and
		point3 is the ending point.

		The original object will be deleted if the method
		is successful.
-----
%SC%    

	GR3ptpartdel(msg,env,point1,point2,point3,p1,p2,p3,c1,c2,num)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
	*env	  GRmd_env	 data set environment structure
	point1	  IGRpoint	 beginning point of deletion
	point2    IGRpoint	 direction point
	point3    IGRpoint	 ending point of deletion
	*p1	  GRparms	 structure for parameter information
	*p2	  GRparms	 structure for parameter information
	*p3	  GRparms	 structure for parameter information

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	*msg	  IGRlong	 completion code
				    MSSUCC - successful completion
				    MSINARG  - partial delete request
					is not valid, the delete
					points produced an object
					identical to the old object
				    MSFAIL - error occured
        *c1       GRobjid	 new object
	*c2 	  GRobjid	 new object 
	*num	  IGRlong	 number of objects returned may be
				  0,1 or 2
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	MAbcusplit
	MAbcconcat
	MAbcrevparm
	GRchgclass
	GRabsg_del


     Methods:
	GRclipto
	GR2ptpartdel
	GRgeomprops
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
	The original object will be left intact if any error
	occurs.
-----
%CH%

     CHANGE HISTORY:
	
	MAS     05/02/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method performs the partial delete of a B-spline geometry
between 2 input points using a third point as a direction 
indicator.   

If the curve is an open curve, the u-parameter for point2 must 
lie between the u-parameters for point1 and point3 or an error 
is returned.  The method, GR2ptpartdel is called.

If the curve is a closed curve, the input parameter information 
for point1 and point3 is sorted into ascending order. The curve 
is split at the high parameter.  The split routine returns an 
indicator of the portions returned.  From the indicator returned, 
a split is done on the portion returned to the low parameter side 
of the previous split point. The u parameter for this second split 
is calculated using the input parameters.

The construction of the new object is handled differently for
for different cases.  Assume u1=parameter for point1, u2 = 
parameter for point2, u3 = parameter for point3.

If (u1<u2<u3) or (u1>u2>u3):
  - concatenate the 2nd portion of the 1st split and the first
    portion of the second split.
  - if (u1 > u3)
    reverse the parameterization of the curve.

If second split is at beginning of the curve:
  - use the resulting curve as the new object.

If (u1 > u3)
  - reverse the parameterization of the first curve portion 
    resulting from the second split operation.

The orginal object is deleted if the operation is successful.

If any error is encountered, the original object is left intact.
Any additional objects created in the method are deleted.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAbcusplit();
extern    IGRboolean    MAbcconcat();
extern    IGRboolean    MAbcrevparm();


method GR3ptpartdel(IGRlong *msg; struct GRmd_env *env; 
		    IGRpoint pt1,pt2,pt3; struct GRparms *p1,*p2,*p3;
		    GRobjid *c1,*c2; IGRshort *num)

{
    IGRboolean  concat_flag;		/* concatenation flag		*/

    IGRshort    flag;			/* flag for MAbcusplit		*/
    IGRshort	del_flag;		/* flag to delete object	*/
	
    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong     msg2;			/* local return code		*/
    IGRlong	i;			/* loop index			*/

    IGRdouble   u0,u1,a,b,a_prime;	/* u parameters			*/

    IGRchar 	*ptr_cache;		/* character pointer		*/
    IGRchar	classname[GRNAME_SIZE];	/* classname for clipto		*/

    struct  GRid 	new_id;		/* new object id		*/
    struct  IGRbsp_curve *curve,*tc1,*tc2,*tc3,*tc4,*curve_array[4];
					/* temporary curve structures	*/
    struct  GRprops	props;		/* properties			*/

    
    *msg = MSSUCC;			/* initialize to failure	*/
    OMmsg = OM_S_SUCCESS;
    curve_array[0] = NULL;
    *num = 0;				/* initialize number of objects	*/
    					/* get abstract geometry	*/
    GRgetabsg(&msg2,&(env->md_env.matrix_type),env->md_env.matrix,
	      &ptr_cache,i);

    if (1 & msg2)			/* see if successful		*/
    {				
	curve = (struct IGRbsp_curve *)ptr_cache;

	u0 = curve->knots[curve->order - 1];
	u1 = curve->knots[curve->num_poles];

 	OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgeomprops(&msg2,
					&(env->md_env.matrix_type),
					env->md_env.matrix,&props),
                         senderid = my_id,
                         targetid = my_id);

	if (! (1 & OMmsg & msg2))	/* get properties failed	*/
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}

	if (! props.phy_closed)		/* curve is considered physically */
	{				/*   open                         */  

	    if ( ( (p1->u < p2->u) && (p2->u > p3->u) ) ||
		 ( (p1->u > p2->u) && (p2->u < p3->u) ) )
	    {
		*msg = MSINARG;		/* error condition 		*/
		OMmsg = OM_E_ABORT;
	    }
	    else			/* call 2pt partial delete	*/
	    {
		OMmsg = om$send(mode = OM_e_wrt_object,
                                msg = message GRcurve.GR2ptpartdel(msg,env,pt1,
							pt3,p1,p3,c1,c2,num),
                                senderid = my_id,
                                targetid = my_id);
	    }
	}
	else				/* the curve is closed		*/
	{

    	    if (p1->u < p3->u)		/* order the parameters		*/
	    {				
	        a = p1->u;
	        b = p3->u;
	    }
	    else
	    {
	        a = p3->u; 
	        b = p1->u;
	    }
	    if ( (a >= u1) || (b <= u0)  || (a == b)  ||
		 ((a == u0) && (b == u1) ) )
	    {
	        *msg = MSINARG;
	        OMmsg = OM_E_ABORT;
	        goto wrapup;
	    }
	    else			/* compute second split u parm. */
	    {
	        a_prime = a / (b - u0);
	    }
	    i = 4;			/* need 4 curves		*/
	    GRgetcurves(&msg2,curve,&i,curve_array);
	    if (! (1 & msg2))
	    {
		*msg = MSFAIL;
		OMmsg = OM_E_ABORT;
		goto wrapup;
	    }
					/* assign curves		*/
	    tc1 = curve_array[0];
	    tc2 = curve_array[1];
	    tc3 = curve_array[2];
	    tc4 = curve_array[3];
					/* determine new object class	*/
 	    OMmsg = om$send(mode = OM_e_wrt_object,
                             msg = message GRvg.GRclipto(&msg2,classname),
                             senderid = my_id,
                             targetid = my_id);

	    if (! (1 & OMmsg & msg2))	/* get new classname failed	*/
	    {
	        *msg = MSFAIL;
	        OMmsg = OM_E_ABORT;
	        goto wrapup;
	    }
					/* split curve at first u parm	*/
            if ( MAbcusplit(&msg2,curve,&b,&flag,tc1,tc2))
            {				
     	        /* determine if usable curve was produced, split portion
	         * to the low parameter side of the split.  First 
		 * split occurring at the beginning of the curve has
		 * been eliminated, so there is no need to allow
		 * for this case.
	         */

		concat_flag = TRUE;

	        if (flag == 1)		/* split was at end point 	*/
	        {
					/* nothing to concatenate	*/
		    concat_flag = FALSE;
	        }

					/* split curve at b_prime	*/
                if ( MAbcusplit(&msg2,tc1,&a_prime,&flag,tc4,tc3))
   	        {
	            if (flag != 1)
		    {
			if (flag == 0)	/* both parts valid		*/
			{
					/* check cases for concatenation*/

			    if( ( (p1->u < p2->u) && (p2->u < p3->u) ) ||
				( (p1->u > p2->u) && (p2->u > p3->u) ) )
			    {

				if (concat_flag)
				{
				    if (! MAbcconcat(&msg2,tc2,tc4,tc3))
				    {
				   	*msg = MSFAIL;
					OMmsg = OM_E_ABORT;
				        goto wrapup;
				    }
				}
				if (p1->u > p3->u)
				{
				    MAbcrevparm(&msg2,tc3,tc3);
				}

			    }
			    else if (p1->u > p3->u)
			    {
				MAbcrevparm(&msg2,tc3,tc3);
			    }

			}
			else		/* split is at beginning 	*/
			{
			    if (p2->u < p3->u)
			    {		/* use tc2 from first split	*/
				MAbcrevparm(&msg2,tc2,tc3);

			    }		/* else tc3 from second split
					   is the correct portion	*/
			}
		  
			del_flag = 0;	/* don't delete original	*/
			flag = 0;	/* no channels maintained	*/

			if (GRchgclass(&msg2,env,&my_id,classname,
			    	         &me->properties,tc3,
					 &flag,&del_flag,
					 c1))
			{
			    *num = 1;
			    new_id.objid = *c1;
		 	    new_id.osnum = env->md_id.osnum;

			    OMmsg = om$send(
				msg = message GRgraphics.GRidchanged
				    (msg,num,&new_id),
				targetid = my_id);

			    om$send(
				msg = message GRgraphics.GRdelete(msg,env),
				targetid = my_id);
	
			}
			else
			{
			    *msg = MSFAIL;
			    OMmsg = OM_E_ABORT;
			}
		    }
		    else
		    {
			*msg = MSINARG;
			OMmsg = OM_E_ABORT;
		    }
	        }
		else
		{
		    *msg = MSFAIL;	/* split curve failed		*/
		    OMmsg = OM_E_ABORT;
		}
	    }
	}
    }
    else				/* get abstract failed		*/
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;        
    }
	
wrapup:					/* deallocate storage		*/
    if (1 & *msg & OMmsg)
    {
        GRabsg_del(ptr_cache);		/* delete pointer to original 
					   curve if successful.		*/
    }
    if (curve_array[0])
    {					/* deallocate storage		*/
        om$dealloc(ptr = curve_array[0]);	
    }    

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_CLIPPED);
    
    return( OMmsg );

}
end implementation GRbspline;

