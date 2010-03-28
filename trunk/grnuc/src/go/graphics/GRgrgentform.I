/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
     GRgentform - This method is a general transformation method 
	which invokes a function to transform the object.

Synopsis

     GRgentform(msg,env,transform_function,info,new_objid)

     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *env	  GRmd_env	 environment information
     *info	  IGRchar	 information to pass to the transformation
				 function. This information is not used
				 by this method. It is just passed along 
				 to the function.
     (*tform_function)() IGRint  the function called to do the 
				 transformation
     *newobjid	  GRobjid	 objid of the transformed object

Description

	This method does a transformation of an object by calling
	a user provided function.  The arguments to the function
	are as follows:

	(*tform_function)(msg,env,geometry,geom_props,objid,
		info,new_geometry,new_objid,post_flag)

	IGRlong	   *msg		return code
	struct GRmd_env  *env	environment information
	IGRchar	   *geometry	the objects geometry
	struct GRprops	*geom_props the geometric information needed
				to identify the object's geometry
				type
	GRobjid	   *objid	object id of the object
	IGRchar	   *info	information to be passed to the function
				This can be a pointer to any sort of
				information needed by the function you
				provide.
	IGRchar    **new_geometry the new geometry after transformation.
				The function must allocate the memory
				for this geometry.  The input geometry 
				may be used if desired.  Just be certain
				the size of the geometry is sufficient.
	GRobjid	   *new_objid	object id of object after transformation
	IGRboolean *post_flag 	flag to indicate whether the new
				geometry should be posted
				0 - posting was handled by the transform
				    function
				1 - post the new geometry

	This method first generates the abstract geometry of the
	object.   Then a method is called to get the geometric 
	properties to identify what sort of geometry the object is.  
	This information along with the object id of the object is 
	included in the argument list to the function.  

	The function performs the transformation to the object.  The
	function may then handle posting the new geometry into the instance
	data of the object, if desired. The post_flag should be set 
	to indicate the	whether the GRgentform method is to do the 
	posting.  If the function did not post the geometry, the post flag
	should be set to 1 and this method will post the new geometry.

Notes
	The GRpostabsg method does a limited amount of checking to
	determine if an object should change class.  If your 
	transformation function alters the object in ways which are
	not trapped in the GRpostabsg method, you should handle the 
	deletion  of the old object and the construction of the
	new object yourself.  You may find the function GRchgclass
	helpful in doing this.

History
	MAS 	11/09/87	Design date.

\*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "gocmacros.h"
#include "godef.h"

from GRvg import GRgeomprops, GRpostabsg, GRgenabsg;

extern    IGRboolean    GRabsg_del_all();

method GRgentform(IGRlong *msg; struct GRmd_env *env;
	IGRint (*tform_function)(); IGRchar *info; GRobjid *new_objid)
{
   	IGRboolean post_flag;		/* generic function return	*/

	IGRlong  msg1,			/* working completion codes	*/
		 OMmsg;

	IGRchar  *geometry,		/* abstract geometry pointer	*/
		 *new_geometry;
	
    	struct GRpost_info post_info;	/* information for GRpostabsg	*/
	struct GRprops	geom_props;


	*msg = MSSUCC;			/* initialize to success	*/
	OMmsg = OM_S_SUCCESS;

	*new_objid = my_id;		/* default if mx_type = MAIDMX	*/

					/* get the abstract geometry	*/
	GRgetabsg(&msg1,&env->md_env.matrix_type, env->md_env.matrix,
		&geometry,i);
	
	if (! (1 & msg1))		/* an error occurred		*/
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}
					/* get the geometric properties	*/
	OMmsg = om$send(
	    msg = message GRvg.GRgeomprops
		 (&msg1,&env->md_env.matrix_type,
		  env->md_env.matrix,&geom_props),
	    targetid = my_id);

	if ( 1 & OMmsg & msg1)
	{				/* call the transform function	*/
	    (*tform_function)(msg,env,geometry,&geom_props,&my_id,
		info,&new_geometry,new_objid,&post_flag);

	    if ( 1 & *msg)
	    {
		if ( post_flag )	/* is posting requested		*/
		{
		    post_info.construct_flag = FALSE;
					/* post the transformed geometry*/
	    	    OMmsg = om$send(
                         msg = message GRvg.GRpostabsg
			    (msg,env,&post_info,new_geometry,new_objid),
                         senderid = my_id,
                         targetid = my_id);
		}
	    }
	    else
	    {
		OMmsg = OM_E_ABORT;
	    }
	}
	else
	{
	    OMmsg = OM_E_ABORT;
	    *msg = MSFAIL;
	}

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_XFORMED);

wrapup:

	return (OMmsg);

}
end implementation GRgraphics;
