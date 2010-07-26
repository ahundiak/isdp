/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline
     METHOD NAME:	GRfragment

     Abstract: 	
		This method splits a B-spline curve representation
		of an object at knot values of multiplicity 
	 	order - 1.  New objects will be constructed from
		these split curves.

		The original object will be deleted if the method
		is successful.
-----
%SC%    

	GRfragment(msg,env,complex,new_env)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      *env	  GRmd_env	 data set environment structure for 
				   object to be fragmented
      *complex    GRid		 object id and object space number 
				   for complex object
      *new_env	  GRmd_env	 data set information for the new 
				   objects to be constructed
	

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	*msg	  long	 completion code
				    MSSUCC - successful completion
				    MSFAIL - error occured
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	MAbcusplit
	GRabsg_del

     Methods:
	GRclipto
	
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
	
	MAS     06/02/86 : Design date.
	CMD	01/30/92 : fragments into line segments for
	                   subclasses of GRlinear.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
This method fragments a B-spline geometry at knot values of 
multiplicity (order - 1).  New objects are constructed from
these fragmented segments and connected to the input channel.

If any error is encountered, the original object is left intact.
Any additional objects created in the method are deleted.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "igrdef.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAbcusplit();

method GRfragment(long *msg; struct GRmd_env *env; 
	struct GRid *complex; struct GRmd_env *new_env)

{
    IGRboolean  more;		
    IGRboolean	split;	
    IGRboolean  set_clear;

    short    flag,			/* flag for split routine	*/
		num;

    int         save_props;

    long	OMmsg;			/* OM return value		*/
    long     msg2;			/* local return code		*/
    long	i,j;			/* loop index			*/
    long	multiplicity;		/* knot multiplicity for split	*/

    char 	*ptr_cache;     	/* character pointer		*/
    char	classname[GRNAME_SIZE];	/* classname for clipto		*/

    GRclassid	classid;
    GRobjid	c1;

    OM_S_CHANSELECT my_chan, owner_chan;

    struct  IGRbsp_curve *curve,*tc1,*tc2,*tc3,*curve_array[4];
					/* temporary curve structures	*/
    struct  GRsymbology symb;		/* symbology 			*/
    struct  GRvg_construct arglist;	/* construct arguments		*/
    struct  GRid 	new_ids[1000],
			*id_ptr;
			
    extern OMuword OPP_GRlinear_class_id;

    
    *msg = MSSUCC;			/* initialize to failure	*/
    OMmsg = OM_S_SUCCESS;
    
    curve_array[0] = 0;
 					/* get abstract geometry	*/
    GRgetabsg(&msg2,&(env->md_env.matrix_type),env->md_env.matrix,
	      &ptr_cache,i);

    if (1 & msg2)			/* see if successful		*/
    {				
	curve = (struct IGRbsp_curve *)ptr_cache;
	i = 3;				/* get storage for 3 curves	*/
     	GRgetcurves(&msg2,curve,&i,curve_array);
	if ( ! (1 & msg2))
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}
	tc1 = curve_array[0];		/* assign pointers		*/
	tc2 = curve_array[1];
	tc3 = curve_array[2];
	
	/* determine new object class, if it is subclass of GRlinear */
	/* then new class = GR3dlineseg, else get it from clipto     */
	
	/* first get classname from id */
	OMmsg = om$get_classname (objid = my_id, 
				  classname = classname);
					
	/* now check whether it is a succesor of GRlinear */
	OMmsg = om$is_ancestry_valid (  subclassname = classname,
					superclassid = OPP_GRlinear_class_id );

	if (OMmsg == OM_S_SUCCESS)
            strcpy (classname,"GR3dlineseg");
          else
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
	arglist.properties = me->properties & ~GR_RIGID_RELATIONSHIP;
	arglist.name = 0;		/* new object will not be named	*/
	arglist.display = &(symb.display_attr);
	arglist.class_attr = 0;
	arglist.newflag = FALSE;
	arglist.msg = &msg2;
	arglist.env_info = new_env;

	more = TRUE;

	multiplicity = curve->order-1;	/* repeated knots for split	*/

   	OMmsg = om$make_chanselect(channame = "GRconnector.to_owners",
			   p_chanselect = &my_chan);

	if (! (1 & OMmsg ))
	{
	    *msg = MSFAIL;
	    goto wrapup;
	}

	OMmsg = om$make_chanselect(channame = "GRcmpowner.to_components",
		p_chanselect = &owner_chan);

	if (! (1 & OMmsg ))
	{
	    *msg = MSFAIL;
	    goto wrapup;
	}

	num = 0;
				/* estimate for pieces 			*/
	i = curve->num_poles / (curve->order -1);
	if (i > 1000)
	{
	    id_ptr = (struct GRid *)om$malloc(size = i * sizeof(struct GRid));
	}
	else
	{
	    id_ptr = new_ids;
	}

	while ( (more) && (curve->order < curve->num_poles))
	{
	    for (i = curve->order; i < curve->num_poles; ++i)
	    {
		split = TRUE;
		
		for (j = 1; j < multiplicity; ++j)
		{
		    if (curve->knots[i] != curve->knots[i+j])
		    {
			split = FALSE;
			break;
		    }
		}

		if (i + j >= curve->num_poles)
		{
		   more = FALSE;
		}
		if (split)
		{
		    if (MAbcusplit(&msg2,curve,&curve->knots[i],&flag,tc1,tc2))
		    {
			if (flag != 2)
			{
			    arglist.geometry = (char *)tc1;

	        	    OMmsg = om$construct(
				osnum = new_env->md_id.osnum,
                                classid = classid,
                                p_objid = &c1,
				msg = message GRgraphics.GRconstruct(
					  &arglist));
					/* the construct failed		*/
	       		    if ( !(1 & OMmsg))
	       		    {
	           		*msg = MSFAIL;
	           		goto wrapup;
	        	    }

			    id_ptr[num].objid = c1;
			    id_ptr[num++].osnum = new_env->md_id.osnum;

			    if (flag != 1)
			    {
					/* copy for next split		*/
			        MAbccopy(&msg2,tc2,tc3);
			        curve = tc3;
				break;
			    }
			    else 
			    {
				more = FALSE;
				curve = 0;
				break;
			    }
			}
			
		    }			
		    else		/* split failed			*/
		    {
			*msg = 	MSFAIL;
			OMmsg = OM_E_ABORT;
			goto wrapup;
		    }
		}
	    }				/* end for i			*/
	    
	}				/* end; while more		*/

	/* after all processing of the curve is done in the above loop,
	 * there is still one portion left to construct			
	 */
	
 	if (curve)
	{
	    arglist.geometry = (char *) curve;

	    OMmsg = om$construct(osnum = new_env->md_id.osnum,
                         classid = classid,
                         p_objid = &c1,
			 msg = message GRgraphics.GRconstruct(&arglist));
					
	    if ( !(1 & OMmsg))		/* the construct failed		*/
	    {
		*msg = MSFAIL;
		goto wrapup;
	    }
	    id_ptr[num].objid = c1;
	    id_ptr[num++].osnum = new_env->md_id.osnum;
	}
    }
    else				/* get abstract geometry	*/
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;        
    }
	
wrapup:

    if (! (1 & *msg & OMmsg))
    {
	/* delete any intermediate objects which were constructed
	 */

	for ( i = 0; i < num; ++i)
	{
	    om$send(
                msg = message GRgraphics.GRdelete(&msg2,new_env),
		targetid = id_ptr[i].objid,
		targetos = id_ptr[i].osnum);
	}
    }
    else
    {
					/* set hidden surf. properties	*/
	set_clear = -1;

	for (i=0; i<num; ++i)
	{
     	    om$send(msg = message GRvg.GRchghprops(&msg2,&set_clear,
		&save_props),
		senderid = my_id,
	        targetid = id_ptr[i].objid,
		targetos = id_ptr[i].osnum);
					/* connect objects to channel	*/
	    OMmsg = om$send(mode = OM_e_wrt_object,
		msg = message Root.connect
		    (owner_chan,i,id_ptr[i].objid,id_ptr[i].osnum,
		     my_chan,0),
		senderid = my_id,
		targetid = complex->objid,
		targetos = complex->osnum);
	}

	om$send(msg = message GRgraphics.GRidchanged(msg,&num,id_ptr),
		targetid = my_id);

	om$send(mode = OM_e_wrt_object,
                msg = message GRgraphics.GRdelete(&msg2,env),
                senderid = my_id,
                targetid = my_id);

        GRabsg_del(ptr_cache);		/* delete pointer to original 	*/

    }
    if ( curve_array[0])
    {
        om$dealloc(ptr = curve_array[0]);/* deallocate storage		*/
    }    
    if (id_ptr != new_ids)
    {
	om$dealloc(ptr = id_ptr);
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_CLIPPED);
    
    return( OMmsg );
}
end implementation GRbspline;
