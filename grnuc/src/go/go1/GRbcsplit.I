/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline
     METHOD NAME:	GRsplit

     Abstract: 	This module performs a split operation on a 
		B-spline curve object.

		For a closed curve, a new open curve is formed 
		with the beginning and ending point being the split 
		point.  

		For an open curve, 2 new open curves are created, 
		provided the split point is not an endpoint of
		the original curve.
		
		The original object will be deleted if the method 
		is successful.
-----
%SC%    

	GRsplit(msg,env,point,p1,c1,c2,num)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
	*env	  GRmd_env	 data set environment structure
	point	  IGRpoint	 point to split curve
	*p1	  GRparms	 structure for parameter information

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	*msg	  IGRlong	 completion code
				    MSSUCC - successful completion
				    MSINARG - invalid request for 
					this method - split point
					was an endpoint of the 
					original open curve. Original
					curve is left intact.
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

     Methods:
	GRclipto
	GRgetsymb
	GRgeomprop
	GRdelete
	GRabsg_del
	
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
	The original curve is left intact if any error occurs.
-----
%CH%

     CHANGE HISTORY:
	
	MAS     05/16/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method performs the splitting of a B-spline geometry
at an input point.  

Form a method to determine geometric properties, we determine
if the curve is to be treated as an open or closed curve.  If
the curve is closed, the split portions of the curve may have to 
be concatenated into a single curve.

The curve is split at the input parameter using a math subroutine.  
The math split routine returns an indicator of what new portions 
are returned.  From the indicator returned from the math
routine and from the open/closed indicator returned from the
properties routine, a determination is made of whether or not 
the curve portions must be concatenated. For open curves 2 curves
may be returned.

The new object(s) are then constructed and the original curve
is deleted.

If any error is encountered, the original object is left intact.
Any additional objects created in the method are deleted.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"
#include "bserr.h"

extern    IGRboolean    MAbcusplit();
extern    IGRboolean    MAbcconcat();

method GRsplit(IGRlong *msg; struct GRmd_env *env; 
		    IGRpoint point; struct GRparms *p1;
		    GRobjid *c1,*c2; IGRshort *num)

{
    IGRint 	save_props;

    IGRboolean  set_clear;
	
    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong     msg2;			/* local return code		*/
    IGRlong	i;			/* loop index			*/

    IGRchar 	*ptr_cache;		/* character pointer		*/
    IGRchar	classname[GRNAME_SIZE];	/* classname for clipto		*/

    GRclassid	classid;		/* classid for construct	*/

    struct  IGRbsp_curve *curve,*tc1,*tc2,*curve_array[3];
					/* temporary curve structures	*/
    struct  GRvg_construct arglist;	/* structure for construct	*/
    struct  GRsymbology symb;		/* symbology structure		*/
    struct  GRprops props;
    struct  GRid	new_id[2];	/* new object id's		*/


    *msg = MSSUCC;			/* initialize to failure	*/
    OMmsg = OM_S_SUCCESS;
    curve_array[0] = 0;
    *num = 0;				/* initialize number of objects	*/

 					/* get abstract geometry	*/
    GRgetabsg(&msg2,&(env->md_env.matrix_type),env->md_env.matrix,
	      &ptr_cache,i);

    if (1 & msg2)
    {				
	curve = (struct IGRbsp_curve *)ptr_cache;
	i = 2;				/* get storage for 2 curves	*/
	GRgetcurves(&msg2,curve,&i,curve_array);
	if ( !(1 & msg2))
	{				/* unable to allocate curves	*/
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}
	tc1 = curve_array[0];
	tc2 = curve_array[1];
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

 	OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgeomprops
			    (&msg2,&env->md_env.matrix_type,
			     env->md_env.matrix,&props),
                         senderid = my_id,
                         targetid = my_id);

	if (! (1 & OMmsg & msg2))	/* get props failed		*/
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}

	if (! props.closed)		/* have to trick the math routine*/
	{
	    curve->phy_closed = 0;
	}
					/*set up arguments for construct*/
	arglist.level = symb.level;
	arglist.properties = me->properties & ~GR_RIGID_RELATIONSHIP;
	arglist.name = 0;		/* new object will not be named	*/
	arglist.display = &(symb.display_attr);
	arglist.class_attr = 0;
	arglist.newflag = FALSE;
	arglist.msg = &msg2;
	arglist.env_info = env;
	
	BSsplitcv(curve,p1->u,tc1,tc2,&msg2);

	if ( msg2 == BSSUCC)
	{
	    if (tc1->num_poles)
	    {
		arglist.geometry = (IGRchar *) tc1;
		
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
	    if (tc2->num_poles)
	    {
		arglist.geometry = (IGRchar *) tc2;
		
	        OMmsg = om$construct(osnum = OM_Gw_current_OS,
                    classid = classid,
                    p_objid = &new_id[*num].objid,
		    msg = message GRgraphics.GRconstruct(&arglist));

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
    else
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
	*num = 0;			/* reset number of objects	*/
    }
    else				/* partial delete is successful */
    {
	*c1 = new_id[0].objid;

	set_clear = -1;			/* replace the properties	*/

	om$send(msg = message GRvg.GRchghprops(&msg2,&set_clear,
			&save_props),
		senderid = my_id,
	        targetid = *c1);


	if (*num > 1)			/* there are two new objects	*/
	{
	    *c2 = new_id[1].objid;
	    om$send(
		msg = message GRvg.GRchghprops(&msg2,&set_clear,
			&save_props),
		senderid = my_id,
	        targetid = *c2);

	}

	om$send (msg = message GRgraphics.GRidchanged(msg,num,new_id),
	    targetid = my_id);

        OMmsg = om$send(mode = OM_e_wrt_object,
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

