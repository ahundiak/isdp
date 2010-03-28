/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline
     METHOD NAME:	GR2ptpartdel

     Abstract: 	This module performs the partial delete operation
		on a B-spline curve geometry by deleting the 
		portion of the curve between the two points and
		constructing new objects from the remaining 
		portions of the curve.  The original object will be
		deleted.
-----
%SC%    

	GR2ptpartdel(msg,env,point1,point2,p1,p2,c1,c2,num)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
	*env	  GRmd_env	 data set environment structure
	point1	  IGRpoint	 beginning point of deletion
	point2    IGRpoint	 ending point of deletion
	*p1	  GRparms	 structure for parameter information
				    for point1
	*p2	  GRparms	 structure for parameter information
				    for point2

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	*msg	  long	 completion code
				    MSSUCC - successful completion
				    MSINARG  - partial delete request
					is not valid, the delete
					points produced an object
					identical to the old object
				    MSFAIL - error occured
        *c1       GRobjid	 new object
	*c2 	  GRobjid	 new object 
	*num	  long	 number of objects returned may be
				  0,1 or 2
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	MAbcusplit

     Methods:
	GRclipto
	GRgetsymb
	GRdelete
	GRabsg_del
	
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
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
between 2 input points.  The input parameter information is
sorted into ascending order.  The curve is split at the low
parameter.  The split routine returns an indicator of the 
portions returned.  From the indicator returned, a new object is
constructed from from the portion to the low parameter side
of the input parameter.  The remaining portion is split at the 
adjusted parameter for the high parameter.  From the indicator 
returned, a new object is constructed from the high parameter 
portion of the curve.

The orginal object is deleted.

If any error is encountered, the original object is left intact.
Any additional objects created in the method are deleted.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAbcusplit();

method GR2ptpartdel(long *msg; struct GRmd_env *env; 
		    IGRpoint pt1,pt2; struct GRparms *p1,*p2;
		    GRobjid *c1,*c2; short *num)

{
    short    flag;			/* flag for MAbcusplit		*/
    int      save_props;

    short    set_clear;
	
    long	OMmsg;			/* OM return value		*/
    long     msg2;			/* local return code		*/
    long	i;			/* loop index			*/

    double   u0,u1,a,b,b_prime;	/* u parameters			*/

    char 	*ptr_cache;		/* character pointer		*/
    char	classname[GRNAME_SIZE];	/* classname for clipto		*/

    GRclassid	classid;		/* classid for construct	*/
					/* temporary curve pointers	*/
    struct  IGRbsp_curve *curve,*tc1,*tc2,*tc3,*curve_array[3];
    struct  GRvg_construct arglist;	/* structure for construct	*/
    struct  GRsymbology symb;		/* symbology structure		*/

    struct GRid new_id[2];		/* new object id's		*/


    *msg = MSSUCC;			/* initialize to failure	*/
    OMmsg = OM_S_SUCCESS;
    curve_array[0] = 0;
    *num = 0;				/* initialize number of objects	*/

 					/* get abstract geometry	*/
    GRgetabsg(&msg2,&(env->md_env.matrix_type),env->md_env.matrix,&ptr_cache,i);
    if (1 & msg2)
    {				
	curve = (struct IGRbsp_curve *)ptr_cache;

	u0 = curve->knots[curve->order - 1];
	u1 = curve->knots[curve->num_poles];

	if (p1->u < p2->u)		/* order the parameters		*/
	{				
	    a = p1->u;
	    b = p2->u;
	}
	else
	{
	    a = p2->u; 
	    b = p1->u;
	}
	if ( (a >= u1) || (b <= u0) || (a < u0) || (b > u1) ||
	     ((a == u0) && (b == u1)) )
	{
	    *msg = MSINARG;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}
	else				/* compute second split u parm. */

	{
	    b_prime = (b - a) / (u1 - a);
	}
	i = 3;				/* need storage for 3 curves	*/
	GRgetcurves(&msg2,curve,&i,curve_array);

	if (!(1 & msg2))
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	}

	tc1 = curve_array[0];		/* assign curves		*/
	tc2 = curve_array[1];
	tc3 = curve_array[2];
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
					/* get classid from OM		*/
        OMmsg = om$get_classid(classname = classname,
                               p_classid = &classid);

	if (! (1 & OMmsg))		/* get classid failed		*/
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}
					/* get symbology for construct	*/
 	OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgetsymb(&msg2,&symb),
                         senderid = my_id,
                         targetid = my_id);

	if (! (1 & OMmsg & msg2))	/* get symbology failed		*/
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}
					/*set up arguments for construct*/
	arglist.level = symb.level;
	arglist.properties = me->properties & (~GR_RIGID_RELATIONSHIP);
	arglist.name = 0;		/* new object will not be named	*/
	arglist.display = &(symb.display_attr);
	arglist.class_attr = 0;
	arglist.newflag = FALSE;
	arglist.msg = &msg2;
	arglist.env_info = env;
					/* split curve at first u parm	*/
        if ( MAbcusplit(&msg2,curve,&a,&flag,tc1,tc2))
	{				
     	    /* determine if usable curve was produced, keep only portion
	     * to the low parameter side of the split.  Split point
	     * at the end of the curve has already been eliminated as
	     * an error, so there is no need to check for flag == 1.
	     */

	    if (flag == 0)
	    {				
					/* construct 1st new object	*/
	        arglist.geometry = (char *) tc1;

					/* construct object		*/
	        OMmsg = om$construct(osnum = OM_Gw_current_OS,
                                     classid = classid,
                                     p_objid = &new_id[0].objid,
				     msg = message GRgraphics.GRconstruct(
								&arglist),
                                     neighbor = OM_GS_NULL_NEIGHBOR);

	       if ( !(1 & OMmsg))	/* the construct failed		*/
	       {
	           *msg = MSFAIL;
	           goto wrapup;
	       }
	       new_id[0].osnum = env->md_id.osnum;

	       ++(*num);		/* increment number of objects	*/

	    }
					/* nothing left after split	*/
	    if (b_prime != curve->knots[curve->num_poles] )
	    {
					/* previous split curve is final*/
		if (b_prime != curve->knots[curve->order-1])
		{
					/* split curve at b_prime	*/
            	    if ( MAbcusplit(&msg2,tc2,&b_prime,&flag,tc1,tc3))
   	            {
	                if (flag == 0)	/* both parts valid, use 2nd	*/
		        {	
		            arglist.geometry = (char *)tc3;
			}
			else
			{
			    *msg = MSFAIL;
			    OMmsg = OM_E_ABORT;
			    goto wrapup;
			}
		
		    }		
		    else		/* split curve failed		*/
		    {
		        *msg = MSFAIL;
		        OMmsg = OM_E_ABORT;
			goto wrapup;
		    }
		}		  
		else			/* split point was beginning pt */
	        {			/* use curve from 1st split	*/
		    arglist.geometry = (char *) tc2;
		}
					/* construct new object		*/
	        OMmsg = om$construct(osnum = OM_Gw_current_OS,
                                     classid = classid,
                                     p_objid = &new_id[*num].objid,
				     msg = message GRgraphics.GRconstruct(
								&arglist),
                                     neighbor = OM_GS_NULL_NEIGHBOR);

	        if ( !(1 & OMmsg))	/* the construct failed		*/
	        {
	            *msg = MSFAIL;
	            goto wrapup;
		}    
	        new_id[*num].osnum = env->md_id.osnum;
		++(*num);		/* increment number of objects	*/
	    }
	}
	else
	{
	    *msg = MSFAIL;		/* split curve failed		*/
	    OMmsg = OM_E_ABORT;		
	}
    }
    else				/* get abstract geometry failed	*/
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;        
    }

	
wrapup:
    
    if (! (1 & *msg))			/* a failure occured		*/
    {
	if (*num > 0)			/* delete any new objects	*/
	{
	    OMmsg = om$send(mode = OM_e_wrt_object,
                msg = message GRgraphics.GRdelete(&msg2,env),
                senderid = my_id,
                targetid = new_id[0].objid);

	    if (*num > 1)		/* delete new objects		*/
	    {
	        OMmsg = om$send(mode = OM_e_wrt_object,
                     msg = message GRgraphics.GRdelete(&msg2,env),
                     senderid = my_id,
                     targetid = new_id[1].objid);
	    }
	}
	*num = 0;
    }
    else				/* partial delete is successful */
    {
	*c1 = new_id[0].objid;
	set_clear = -1;

	om$send(msg = message GRvg.GRchghprops(&msg2,&set_clear,
				&save_props),
		senderid = my_id,
	        targetid = *c1);

	if (*num > 1)			/* there are two new objects	*/
	{
	    *c2 = new_id[1].objid;

	    om$send(msg = message 
			GRvg.GRchghprops(&msg2,&set_clear,&save_props),
		senderid = my_id,
	        targetid = *c2);
	}
	om$send(msg = message GRgraphics.GRidchanged(msg,num,new_id),
	    targetid = my_id);

					/* delete original curve	*/
        OMmsg = om$send(
            msg = message GRgraphics.GRdelete(&msg2,env),
            senderid = my_id,
            targetid = my_id);

	GRabsg_del(ptr_cache);		/* delete pointer		*/

    }
    if (curve_array[0])
    {
        om$dealloc(ptr = curve_array[0]);/* deallocate storage		*/
    }    

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_CLIPPED);
    
    return( OMmsg );

}
end implementation GRbspline;

