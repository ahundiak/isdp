#ifndef grmacros_include
#define grmacros_include

#include "EMSdpb.h"


/*
Name:
	gr$display_object(
			object_id,
			md_env=NULL,
			mode = GRbd);

 Abstract:

	This macro will display the input object with the specified 
	display option.

 Arguments:

 struct GRid	*object_id		I	Input object id and osnum.
 struct GRmd_env *md_env		I	Module Environment 
							information
 enum GRdpmode  mode			I	Input display option. 
						The enumerated types
						are defined in dp.h.
						
 Sample Call:

	gr$display_object( object_id = &objid, mode = GRbd); 

 Notes:
	If you do not specify a md_env structure, the master file
environment will be used.  Objects in reference files will not
display correctly.

The valid display modes are defined in dp.h and are explained here:
    enum  GRdpmode   GRbd, 	background draw
		     GRbe, 	background erase
		     GRhd, 	highlight draw
		     GRhe, 	highlight erase
		     GRbdhd,    background draw, highlight draw
		     GRbehe,  	background erase, highlight erase
		     GRbdhe, 	background draw, highlight erase
		     GRbehd, 	background erase, highlight draw
		     GRhhd, 	half highlight draw
		     GRhdo, 	highlight override
		     GRhhdo, 	half highlight draw override
		     GRheo, 	highlight erase override
		     GRbdheo, 	background draw, highlight erase override
		     GRbeheo	background erase, highlight erase override

	For the override modes listed above, this means to draw the
object in the specified mode even if it is marked as non-displayable.

 History:
	MAS	01/07/91	Creation

*/

#omdef gr$display_object
			(object_id,
			 md_env=NULL,
			 mode   = GRbd )

#if (!  om$specified(object_id))
#   omerror "Must specify object_id "
#else
   GRdisplay_object((object_id),(md_env),(mode));
#endif

#endomdef

/*
    gr$put_properties
			(object_id,
			 action	 = 1,
			 properties_mask);
 Abstract:
	
	This macro sets or clears the  property bits of an object. 
This can be used to make an object displayable/undisplayable, 
locatable/unlocatable or filled/unfilled.

 Arguments:

struct GRid	*object_id	I 	Input GRid of object to 
					set the properties of.

IGRshort	action		I	flag determines whether
					the list of properties is
					to be set or cleared.
					  1 = set, 0 = clear
unsigned short	properties_mask	I 	is the properties word
					that contains the properties 
					to be set or cleared.
					The properties bit masks are
					defined in godef.h. The
					valid masks for public use are 
					listed in this include file.
 Sample Call:

	To set the properties do the following:

	mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

   	ci$locate( obj 	 = &object.objid,
	   osnum = &object.osnum,
	   md_env = &env,
	   properties = (LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY),
	   prompt= "Identify object");

 	gr$put_properties(object_id = &object,
			  set = 1,
			  properties_mask = mask);

	To clear the properties do the following:

	mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

   	ci$locate( obj 	 = &object.objid,
	   osnum = &object.osnum,
	   md_env = &env,
	   properties = (LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY),
	   prompt= "Identify object");

 	gr$put_properties(object_id = &object,
			  set = 0,
			  properties_mask = mask);


 Notes:
	The properties that are valid to be changed are as follows:
	
		GRIS_LOCATABLE	  
		GRIS_DISPLAYABLE	
		GRFILLED_DISPLAY

	The bit masks are defined in godef.h. Only the masks listed
above as valid will be honored, any other masks sent in will be ignored.
If you specify that you want the object to be filled and the object is not
closed, the bit will not be set.

       Note that since the operation is a write operation the
properties for locate  are set so that invalid objects are not located.

 History:
	MAS	01/07/91	Creation

*/

#omdef 	gr$put_properties
			(object_id,
			 action	 = 1,
			 properties_mask)

#if ( ! (om$specified(properties_mask) || om$specified(object_id)))
#   omerror "Must specify properties_mask and object_id "
#else

    GRchange_properties((object_id), (action), (properties_mask));
#endif

#endomdef

/*

 Name:

 gr$get_properties( object_id,
		    properties_mask);

 Abstract:

	This macro will get the property word from an object

 Arguments:

 struct GRid	*object_id	I 	Input GRid of object to 
					the properties from.
 unsigned short	*properties_mask O       This is the properties word
					that contains a mask of the
					properties of the object.
 Sample Call:

 	gr$get_properties( object_id = &object, 
			properties_mask = &properties);

	if (properties & GRIS_DISPLAYABLE)
	{
	    printf("the object is displayable\n");
	}
	
 Notes:
	The properties that are valid to be returned by this macro are 
as follows:

		GRIS_PLANAR
		GRIS_LOCATABLE	  
		GRIS_DISPLAYABLE	
		GRFILLED_DISPLAY
		GRIS_VIEW_INDEP

	The bit masks are defined in godef.h

 History:
	MAS	01/07/91	Creation

*/

#omdef gr$get_properties( object_id,
		    	  properties_mask)
#if (! (om$specified(properties_mask) || om$specified(object_id)))
#   omerror "Must specify properties_mask and object_id "
#else
	GRget_properties((object_id),(properties_mask));
#endif

#endomdef

/*

Name:
 	gr$get_symbology( object_id,
			  symb)

 Abstract:

	This macro will get the symbology from an object.

 Arguments:

 struct GRid 	*object_id	I	input object GRid
 struct GRsymbology *symb	O	output symbology structure.

 Sample Call:
	struct GRsymbology symbology;
	struct GRid	   object;
  
	gr$get_symbology( object_id = &object, symb = &symbology );
	
 Notes:

 History:
	MAS	01/07/91	Creation

*/

#omdef 	gr$get_symbology( object_id,
			  symb)

#if (! (om$specified(symb) || om$specified(object_id)))
#   omerror "Must specify symb and object_id "
#else
	GRsymbology_options((object_id),(0),(symb));

#endif

#endomdef

/*

Name:
 	gr$put_symbology( object_id,
			  symb)

 Abstract:

	This macro will change an objects symbology to the input
symbology.  

 Arguments:

 struct GRid 	*object_id	I	input object GRid
 struct GRsymbology *symb	I	output symbology structure.

 Sample Call:
	struct GRsymbology symbology;
	struct GRid	   object;
  
   	ci$locate( obj 	 = &object.objid,
	   osnum = &object.osnum,
	   md_env = &env,
	   properties = (LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY),
	   prompt= "Identify object to delete");

	gr$put_symbology( object_id = &object, symb = &symbology );
	
 Notes:
	This macro does not do any display operation, you will need
to first erase the object and then redraw it to see the new
symbology.

       Note that since the operation is a write operation the
properties for locate  are set so that invalid objects are not located.

 History:
	MAS	01/07/91	Creation

*/

#omdef 	gr$put_symbology( object_id,
			  symb)

#if (! (om$specified(symb) || om$specified(object_id)))
#   omerror "Must specify symb and object_id "
#else
	GRsymbology_options((object_id),(1),(symb));
#endif
#endomdef

/*

 Name:
 	gr$delete_object( 
		msg,
		md_env=NULL,
		object_id,
		display_flag = 1)

 Abstract:

	This macro will delete an object.  It will also erase the
object if the display flag is set.

 Arguments:

 IGRlong	*msg		O	completion code
					   MSSUCC - successful completion
					   MSFAIL - error occured
 struct GRmd_env *md_env	I	module envioronment structure
 struct GRid	*object_id	I	the object to be deleted
 IGRint		display_flag	I	display options flag
					   0 - do not erase object
					   1 - erase object (default)
 Sample Call:

	struct GRid	object;
	struct GRmd_env env;

   	ci$locate( obj 	 = &object.objid,
	   osnum = &object.osnum,
	   md_env = &env,
	   properties = (LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY),
	   owner_action = (LC_FLEX_COMP | LC_RIGID_OWNER | LC_FLEX_OWNER),
	   prompt= "Identify object to delete");

	gr$delete_object( 
	   msg = &msg,
	   md_env = &env,
	   object_id = &object);

 Notes:
	Note that since the operation is a write operation the
properties for locate and owner action are set so that invalid
objects are not located.

 History:
	MAS	01/07/91	Creation

*/

#omdef 	gr$delete_object( 
		msg,
		md_env=NULL,
		object_id,
		display_flag = 1)

#if (! (om$specified(msg) || om$specified(object_id)))
#   omerror "Must specify msg, and object_id "
#else
	GRdelete_object((msg),(md_env),(object_id),(display_flag));
#endif

#endomdef

/*

Name:
     gr$copy_object(	msg,
			object_id,
			md_env=NULL,
			new_env=NULL,
			new_id=NULL,
			display_flag=1)
 Abstract:

	This macro copyies an object.

 Arguments:
 IGRlong	*msg		O	completion code
					    MSSUCC - successful completion
					    MSFAIL - error occured
 struct GRid	*object_id	I	the object to copy
 struct GRmd_env *md_env	I 	the object's module environment 
					    if not supplied, current
					    active file is the 
					    environment will be used
 struct GRmd_env *new_env	I	the new object's module environment
					    if not supplied, current
					    active file is the 
					    environment will be used
 struct GRid *new_id		O	the new object id
					    (optional, if you do
					     not need the new object 
					     id, you do not have to specify
					     this argument)
 IGRint	display_flag		I	flag to indicate whether or
					not to display the new object
					   1 - display (default)
					   0 - do not display

 Sample Call:

	struct GRid	CURVE, new_object;
	struct GRmd_env	ENV;
	IGRlong 	msg;

   	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   md_env = &ENV,
		   prompt= "Identify curve to copy");

 	gr$copy_object(	msg = &msg,
			object_id = &CURVE,
			md_env = &ENV,
			new_id = &new_object);
	
 Notes:

 History:
	MAS	01/07/91	Creation

-----------------------------------------------------------------------*/

#omdef gr$copy_object(	msg,
			object_id,
			md_env=NULL,
			new_env=NULL,
			new_id=NULL,
			display_flag=1)

#if (! (om$specified(msg) || om$specified(object_id)))
#   omerror "Must specify msg and object_id "
#else
    GRcopyobject((msg),(object_id),(md_env),(new_env),(new_id),(display_flag));

#endif
#endomdef

 /*

 Name:
 	gr$put_name( msg,
		     object_id,
		     name)

 Abstract:
	This macro names the input object. If the name is
	already used the macro will create a unique name by
	adding a number to the name. The new name will be returned.

 Arguments:

  IGRlong	*msg		O	completion code
					    MSSUCC - successful completion
					    MSFAIL - error occured
  struct GRid	*object_id	I	object to add a name to
  IGRchar	*name		I/O	the name for the object
					    if the name must be altered to
					    make it unique, it will be
					    returned. 
 Sample Call:

	IGRchar		ob_name[PATH_MAX];
	struct GRid	CURVE;
	IGRlong		msg;

   	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   properties = (LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY),
		   prompt= "Identify element to name");

	ci$get(string = ob_name, prompt="key in name");

 	gr$put_name( msg = &msg,
		     object_id = &CURVE, 
		     name = ob_name);

 Notes:
	Note that since the operation is a write operation the
properties for locate are set so that invalid objects are not located.

	Be certain the name array is large enough in case the name must
be altered.  The dimension should be PATH_MAX (defined in DIdef.h).

 History:
	MAS	01/07/91	Creation

*/

#omdef 	gr$put_name( msg,object_id,name)

#if (! (om$specified(msg) || om$specified(object_id) || om$specified(name)))
#   omerror "Must specify msg, name, and object_id "
#else
  	GRput_name((msg),(object_id),(name));
#endif


#endomdef


/*

Name:

	gr$get_coordinate_data(
			msg,
			object_id,
			md_env=NULL,
			origin=NULL,
			x_vector=NULL,
			y_vector=NULL,
			z_vector=NULL,
			scale=NULL,
			matrix=NULL);
 Abstract:
 This macro will return the x, y, and z vectors of a coordinate system.
 It also returns the origin, scale and full matrix of the coordinate 
 system.

 Arguments:
 IGRlong	*msg		O	Completion Code
					    MSSUCC - successful completion
					    MSFAIL - error
 struct GRid	*object_id	I	the coordinate system id
					    if not specified, the active
					    coordinate system will
					    be used.
 struct GRmd_env *md_env	I	the module enviornment of
					    the coordinate system
					    (defaults to master file)
 IGRdouble *origin		O	the origin of the coordinate
					    system
 IGRdouble *x_vector		O 	the x direction vector
 IGRdouble *y_vector		O 	the y direction vector
 IGRdouble *z_vector		O 	the z direction vector
 IGRdouble *scale		O	the scale (3 doubles, x,y,z scale)
					    (local system to world system)
 IGRmatrix *matrix		O	the coordinate system matrix
					    (local system to world system)

 Sample Call:

	struct GRid	COORD;
	IGRdouble	org[3], xvec[3], yvec[3],zvec[3];
	IGRdouble	matrix[16],origin[3],scale[3];
	IGRlong		msg;

   	ci$locate( obj 	 = &COORD.objid,
		   osnum = &COORD.osnum,
		   classes = "GRgencs",
		   prompt= "Identify coordinate system");
	
 	gr$get_coordinate_data(
			msg = &msg,
			object_id = &COORD,
			x_vector = xvec,
			y_vector = yvec,
			z_vector = zvec,
			origin	 = origin,
			matrix   = matrix,
			scale    = scale);

 Notes:
   The x_vector, y_vector, z_vector, scale, origin and matrix are
all optional outputs.  You can request only the values you need.

 History:
	MAS	01/07/91	Creation

*/


#omdef  gr$get_coordinate_data(
			msg,
			object_id,
			md_env=NULL,
			origin=NULL,
			x_vector=NULL,
			y_vector=NULL,
			z_vector=NULL,
			scale=NULL,
			matrix=NULL)

#if ( !om$specified(msg))
#   omerror "Must specify msg"
#else

   GRget_coordinate_data((msg),(object_id),(md_env),(origin),(x_vector),
			(y_vector),(z_vector),(scale),(matrix));
#endif

#endomdef

/*

gr$project_pnt_on_element
                        (msg,
			md_env=NULL,
			object_id,
			point,
                        proj_pt,
                        u_parm,
                        v_parm)

 Abstract:

        This macro will project the input point onto the element.

 Arguments:

IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
struct GRmd_env		*md_env		I  module environment 
struct GRid  		*object_id	I  object id 
IGRdouble		*point		I  point to project
IGRdouble		*proj_pt	O  projected point on object
IGRdouble		*u_parm		O  u parameter of projected point
					   on object
IGRdouble               *v_parm		O  v parameter of projected point
					   (only has meaning for
					    surfaces, but the argument 
					    should be supplied)
Sample Call:

    struct GRid     object;
    struct GRmd_env env;
    IGRdouble  	    point[3],proj_point[3];
    IGRdouble	    u,v;
    IGRlong	    msg1;

    ci$locate( obj   = &object.objid,
               osnum = &object.osnum,
	       md_env = &env,
               prompt= "Identify object");

    ci$get(prompt="Enter point to project",
	   point = point);

    gr$project_pnt_on_element(
	    msg = &msg1,
	    md_env = &env,
	    object_id  = &object,
	    point = point,
	    proj_pt = proj_point,
	    u_parm  = &u,
	    v_parm  = &v);
Notes:

If the module environment is not supplied, the object will not have any
object space transformation applied. If it is in a reference file, 
the projected point will be relative to the object as it was stored in the
reference file object space, not to how it is viewed in the master
file.

History:

	12/31/90	MAS	Creation

*/

#omdef gr$project_pnt_on_element(
                        msg,
			md_env=NULL,
			object_id,
			point,
                        proj_pt,
                        u_parm,
                        v_parm)

#if (! ( om$specified(msg) || om$specified(object_id) || om$specified(proj_pt) || om$specified(v_parm) || om$specified(u_parm) || om$specified(point)))
{
#   omerror "Must specify msg, proj_pt, u_parm, v_parm, object_id, point"
}
#else

    GRproject_point_on_element((msg),(object_id),(md_env),(point), 
		(proj_pt),(u_parm),(v_parm));

#endif

#endomdef

/*

Name:
 	gr$create_graphic_group(
			msg,
			object_ids,
			num_objects,
			gg_id);

 Abstract:

	This macro will create a graphic group of the array of object_ids
	The graphic group id is the gg_id.

 Arguments:
 IGRlong 	*msg		O	completion code
					    MSSUCC - successful completion
					    MSFAIL - error occured
 struct GRid	*object_ids	I	Input array of objects.
 IGRint		num_objects	I	Number of object_ids in the array
 struct GRid	*gg_id		O	Output graphic group id.

 Sample Call:

	struct GRid	CURVES[100], GRA_GROUP;
	int		i,locating_objects;

	i=0;
	locating_objects=1;
	while( locating_objects && (i < 100) )
	{
	    if(ci$locate( 
		obj   = &CURVES[i].objid,
		osnum = &CURVES[i].osnum,
		properties = (LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY),
	        owner_action = (LC_FLEX_COMP | LC_RIGID_OWNER | LC_FLEX_OWNER),
		prompt= "Identify obj to add to graphic group"))
	    {
		i=i+1;
	    }
	    else
	    {
		locating_objects = 0;
	    }
	}

	gr$create_graphic_group(
			msg = &msg,
			object_ids = CURVES,
			num_objects = i,
			gg_id = &GRA_GROUP);

 Notes:
       Note that since the operation is a write operation the
properties for locate and owner action are set so that invalid
objects are not located.

 History:
	MAS	01/07/91	Creation

-----------------------------------------------------------------------*/

 #omdef	gr$create_graphic_group(
			msg,
			object_ids,
			num_objects,
			gg_id)

#if (! (om$specified(msg) || om$specified(object_ids) || om$specified(num_objects) || om$specified(gg_id)))
{
#   omerror "Must specify msg, object_ids, num_objects, gg_id"
}
#else
	GRcreate_graphic_group( (msg),(0),(object_ids),(num_objects),(gg_id));

#endif

#endomdef

/*

Name:
	gr$add_to_graphic_group(
			msg,
			object_ids,
			num_objects,
			gg_id)

 Abstract:

	This macro will add a list of objects to an existing
graphic group.

 Arguments:
 IGRlong 	*msg		O	completion code
					    MSSUCC - successful completion
					    MSFAIL - error occured
 struct GRid	*object_ids	I	Input array of objects.
 IGRint		num_objects	I	Number of object_ids in the array
 struct GRid	*gg_id		I	graphic group id.

 Sample Call:

	struct GRid	CURVES[100], GRA_GROUP;
	IGRlong		i,locating_objects,msg;

	i=0;
	locating_objects=1;
	while( locating_objects && (i < 100))
	{
	    if(ci$locate( 
		obj   = &CURVES[i].objid,
		osnum = &CURVES[i].osnum,
		properties = (LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY),
		prompt= "Identify obj to add to graphic group"))
	    {
		i=i+1;
	    }
	    else
	    {
		locating_objects=0;
	    }
        }
	ci$locate( 
		obj   = &GRA_GROUP.objid,
		osnum = &GRA_GROUP.osnum,
		properties = (LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY),
		prompt= "Identify graphic group");

	gr$add_to_graphic_group(
			msg = &msg,
			object_ids = CURVES,
			num_objects = i,
			gg_id = &GRA_GROUP);

 Notes:

 History:
	MAS	01/07/91	Creation

-----------------------------------------------------------------------*/

#omdef 	gr$add_to_graphic_group(
			msg,
			object_ids,
			num_objects,
			gg_id)

#if (! ( om$specified(msg) || om$specified(object_ids) || om$specified(num_objects) || om$specified(gg_id)))
{
#   omerror "Must specify msg, object_ids, num_objects, gg_id"
}
#else
 GRcreate_graphic_group( (msg),(1),(object_ids),(num_objects),(gg_id));

#endif

#endomdef


/*
 Name:
	gr$get_active_u_order( msg,
				order)

 Abstract:

	This macro will get the active system u order.

 Arguments:
 IGRlong	*msg		O	Completion Code
					    MSSUCC - successful completion
					    MSFAIL - error
 IGRint		*order		O	Output u order

 Sample Call:
	
	IGRint	u_order;
	IGRlong	msg;
       
	gr$get_active_u_order( msg = &msg, order = &u_order);

 History:
	MAS	01/07/91	Creation
        SCW     03/10/92        Changed function called from
                                EMdpb_get to EMdpb_get_trans

*/

#omdef 	gr$get_active_u_order( msg, order)

#if (! (om$specified(msg) || om$specified(order)))
#   omerror "Must specify msg, and order"
#else
  	EMdpb_get_trans((msg),0,(order));

#endif

#endomdef

/*

 Name:
    gr$get_active_v_order( msg, order)

 Abstract:

	This macro will get the active system v order.

 Arguments:
 IGRlong	*msg		O	Completion Code
					    MSSUCC - successful completion
					    MSFAIL - error
 IGRint		*order		O	Output v order

 Sample Call:
	
	IGRint	v_order;
 	IGRlong	msg;

	gr$get_active_v_order( msg = &msg, order = &v_order);

 History:
	MAS	01/07/91	Creation
        SCW     03/10/92        Changed function called from
                                EMdpb_get to EMdpb_get_trans

*/

#omdef 	gr$get_active_v_order( msg, order)	

#if (! (om$specified(msg) || om$specified(order)))
#   omerror "Must specify msg and order"
#else
  	EMdpb_get_trans((msg),1,(order));
#endif

#endomdef

/*
 * Name
 *    gr$point_along_curve
 *
 * Description
 *    This function returns the point and u parameter at a given distance from
 *    one end of a curve.
 *
 * Arguments
 *    struct GRid   GRid_in     object id and osnum of the input curve.
 *    IGRint        endflag     flag telling which end to calculate the
 *                              distance from. 0 - start point.  1 - end point.
 *    IGRpoint      dirpoint    direction point used in closed curves case.
 *    IGRint        num         number of distance's given.
 *    IGRdouble     *dist       array of input distances.
 *    IGRdouble     *uparm      output -- array of u values.
 *                              NULL if not needed, else memory pointer.
 *    IGRdouble     *out_point  output -- array of points. NULL if not needed,
 *                              else memory pointer.
 *    struct GRid   *cmp_id     output -- array of component id's. Useful if 
 *                              input object was a composite curve. NULL if not
 *                              needed, else a memory pointer.
 *
 * Notes
 *    If used, memory needs to be allocated for the following like so:
 *      uparm = (IGRdouble *) om$malloc(size = sizeof(IGRdouble) * num);
 *      out_point = (IGRdouble *) om$malloc(size = sizeof(IGRdouble)*num*3);
 *      cmp_id = (struct GRid *) om$malloc(size = sizeof(struct GRid) * num);
 *
 * History
 *    dhm    11/01/91    creation date
 */

#omdef  gr$point_along_curve( GRid_in,
                              endflag = 0,
                              dirpoint,
                              num,
                              dist,
                              uparm = NULL,
                              outpoint = NULL,
                              cmp_id = NULL )

#if (! ( om$specified(GRid_in) || om$specified(dirpoint) || \
         om$specified(num) || om$specified(dist) ) )
#   omerror "Must specify GRid_in, dirpoint, num, and dist"
#else
    GRpoint_along_curve( GRid_in, endflag, dirpoint, num, dist, uparm,
                         outpoint, cmp_id );
#endif

#endomdef

/*
 * Name
 *    gr$get_curve_tan_radcrv
 *
 * Description
 *    This function returns the model space point, tangent vector and radius
 *    of curvature of a curve at a given u parameter.
 *
 * Arguments
 *    struct GRid   GRid_in     objid and osnum of the input curve.
 *    IGRdouble     uparm       input u parameter on the curve.
 *    IGRpoint      outpoint    output model space point. NULL if not needed.
 *    IGRvector     tan         output tangent vector at uparm. NULL if
 *                              not needed.
 *    IGRdouble     *radcrv     output radius of curvature value at uparm.
 *                              NULL if not needed.
 *
 * History
 *    dhm    11/05/91    creation date.
 */

#omdef   gr$get_curve_tan_radcrv( GRid_in,
                                  uparm,
                                  outpoint = NULL,
                                  tan = NULL,
                                  radcrv = NULL )

#if (! (om$specified(GRid_in) || om$specified(uparm)))
#   omerror "Must specify GRid_in and uparm"
#else
    GRget_curve_tan_radcrv( GRid_in, uparm, outpoint, tan, radcrv );
#endif

#endomdef

#endif
