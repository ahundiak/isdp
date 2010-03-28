/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvg;

#include "grimport.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "godef.h"
#include "grmacros.h"
#include "csmacros.h"
#include "go.h"
#include "DIdef.h"
#include "grerr.h"

extern char *cintoa();

from GRowner import GRadd_components;
from GRgencs import GRgetmatrix;
/*
Name:
    GRdisplay_object(object_id,md_env,mode)

 Abstract:

	This function will display the input object with the specified 
	display option.

 Arguments:

 struct GRid	*object_id		I	Input object id and osnum.
 struct GRmd_env *md_env		I	Module Environment 
							information
 enum GRdpmode  mode			I	Input display option. The
						options are also defined in
						this include file. eg "DRAW,
						ERASE, GRbe".

*/

int   GRdisplay_object(object_id,md_env,mode)

 struct GRid	*object_id;
 struct GRmd_env *md_env;
 enum GRdpmode  mode;

{
   int OMmsg;
   long msg;
   struct GRmd_env *env,local_env;
   enum GRdpmode local_mode;
   struct GRid module;

   GRgetmd_env(md_env,&local_env,&env);

   local_mode = mode;

   ex$get_cur_mod(id=&module.objid,
		osnum=&module.osnum);

   OMmsg = om$send(msg=message GRgraphics.GRdisplay
	(&msg,&env->md_env.matrix_type,env->md_env.matrix,
	 &local_mode,&module),
	senderid = object_id->objid,
	targetid = object_id->objid,
	targetos = object_id->osnum);

   return(OMmsg);
}

/*
 Name:

  GRchange_properties(object_id, action, property_mask)

 Abstract:
	
	This function sets or clears the  property bits of an object. 
This can be used to make an object un/displayable, un/locatable


 Arguments:

struct GRid	*object_id	I 	Input GRid of object to 
					set the properties of.

short	action		I	flag determines whether
					the list of properties is
					to be set or cleared.
					  1 = set, 0 = clear
short	property_mask	I 	is the properties word
					that contains the properties 
					to be set or cleared.
					The properties are listed in
						this include file.
 History:

*/

int  GRchange_properties(object_id, action, property_mask)

struct GRid	*object_id;
short	action;
short	property_mask;
{

    long OMmsg,msg;
    short props;
    short local_action;

    /* clear all but the valid bits */

    props = (short)property_mask & 
	(GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRFILLED_DISPLAY);

    local_action = action;

    OMmsg = om$send (
	msg = message GRgraphics.GRchgprops(&msg,&action,&props),
	senderid = object_id->objid,
	targetid = object_id->objid,
	targetos = object_id->osnum);

    return (OMmsg);
}
	
/*

 Name:

int  GRget_properties(object_id, props)

 Abstract:

	This function will get the property word from an object

 Arguments:

 struct GRid	*object_id	I 	Input GRid of object to 
					the properties from.
 short 	*prop		O       This is the properties word
					that contains a mask of the
					properties of the object.

 Notes:
	The properties that are valid to be changed are as follows:

		GRIS_PLANAR
		GRIS_LOCATABLE	  
		GRIS_DISPLAYABLE	
		GRFILLED_DISPLAY
		GRIS_VIEW_INDEP

 History:
*/

int  GRget_properties(object_id, props)

struct GRid	*object_id;
short	*props;
{

    long OMmsg,msg;

    *props = 0;

    OMmsg = om$send (
	msg = message GRgraphics.GRgetprops(&msg,props),
	senderid = object_id->objid,
	targetid = object_id->objid,
	targetos = object_id->osnum);

    *props = (unsigned short)*props & 
	(GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRFILLED_DISPLAY |
	 GRIS_PLANAR | GRIS_VIEW_INDEP);

    return (OMmsg);
}

/*

Name:

 Abstract:

	This function will get the symbology from an object.

 Arguments:

 struct GRid 	*object_id	I	input object GRid
 int		flag		I	options
					0 - get symbology
					1 - put symbology
 struct GRsymbology *symb	O	output symbology structure.

 History:

*/


int GRsymbology_options(object_id,flag,symb)

 struct GRid 	*object_id;
 int 	flag;
 struct GRsymbology *symb;

{
    long OMmsg,msg;

    if (flag == 0)
    {
        OMmsg = om$send (
	    msg = message GRvg.GRgetsymb(&msg,symb),
	    senderid = object_id->objid,
	    targetid = object_id->objid,
	    targetos = object_id->osnum);
    }
    else
    {
        OMmsg = om$send (
	    msg = message GRvg.GRputsymb(&msg,symb),
	    senderid = object_id->objid,
	    targetid = object_id->objid,
	    targetos = object_id->osnum);
    }

    return (OMmsg);
}

/*

 Name:
      GRdelete_object(msg,md_env,object_id,display_flag)

 Abstract:

	This function will delete an object.  It will also erase the
object if the display flag is set.

 Arguments:

 long	*msg		O	completion code
					   MSSUCC - successful completion
					   MSFAIL - error occured
 struct GRmd_env *md_env	I	module envioronment structure
 struct GRid	*object_id	I	the object to be deleted
 int		display_flag	I	display options flag
					   0 - do not erase object
					   1 - erase object (default)
 Notes:

 History:

*/

int GRdelete_object(msg,md_env,object_id,display_flag)

 long	*msg;
 struct GRmd_env *md_env;
 struct GRid	*object_id;
 int		display_flag;
{

   int OMmsg;
   struct GRmd_env *env,local_env;

   GRgetmd_env(md_env,&local_env,&env);

   if (display_flag)
   {
	gr$display_object(md_env = env,
		object_id = object_id,
		mode = GRbehe);
   }

   OMmsg = om$send (msg = message GRgraphics.GRdelete(msg,env),
	senderid = object_id->objid,
	targetid = object_id->objid,
	targetos = object_id->osnum);

   return(OMmsg);
}

/*

 Name:

  GRcopyobject( msg,object_id,md_env,new_env,new_id,display_flag)

 Abstract:

	This function copyies an object.

 Arguments:
 long	*msg		O	completion code
					    MSSUCC - successful completion
					    MSFAIL - error occured
 struct GRid	*object_id	I	the object to copy
 struct GRmd_env *md_env	I 	the object's module environment 
 struct GRmd_env *new_env	I	the new object's module environment
					    if not supplied, current
					    active file is the 
					    environment the will be used
 struct GRid *new_id		O	the new object id
 int	display_flag		I	flag to indicate whether or
					not to display the new object
					   1 - display (default)
					   0 - do not display

 Notes:

 History:

-----------------------------------------------------------------------*/

int  GRcopyobject( msg,object_id,md_env,new_env,new_id,display_flag)

 long	*msg;
 struct GRid	*object_id;
 struct GRmd_env *md_env;
 struct GRmd_env *new_env;
 struct GRid *new_id;
 int	display_flag;

{
   int OMmsg;
   struct GRmd_env *env,local_env,new_local,*cp_env;
   struct GRid local_id, *id;

   GRgetmd_env(md_env,&local_env,&env);
   GRgetmd_env(new_env,&new_local,&cp_env);
   if (!new_id)
   {
	id = &local_id;
   }
   else
   {
	id = new_id;
   }

   OMmsg = om$send(msg = message GRgraphics.GRcopy
	    (msg,env,cp_env,&id->objid),
	senderid = object_id->objid,
	targetid = object_id->objid,
	targetos = object_id->osnum);

   id->osnum = cp_env->md_id.osnum;

   if (display_flag)
   {
	gr$display_object(object_id = id,
		md_env = cp_env,
		mode = GRbd);
   }

   return(OMmsg);
}

 /*

 Name:
  	GRput_name(msg,object_id,name)

 Abstract:
	This function names the input object. If the name is
	already used the function will create a unique name by
	adding a number to the name. The new name will be returned.

 Arguments:

  long	*msg		O	completion code
					    MSSUCC - successful completion
					    MSFAIL - error occured
  struct GRid	*object_id	I	object to add a name to
  char	*name		I/O	the name for the object

 History:

*/

int  	GRput_name(msg,object_id,name)
  long	*msg;
  struct GRid	*object_id;
  char	*name;
{
   long OMmsg;
   long j;
   char tmpname[DI_PATH_MAX];
   char max_char[40];

   if (!name)
   {
	*msg = MSSUCC;
	OMmsg = 1;
	goto wrapup;
   }
   
	
   *msg = GR_E_INV_REQUEST;
   OMmsg = 0;

   strcpy(tmpname,name);
   strcpy(max_char,"0");

   while (*msg == GR_E_INV_REQUEST)
   {
       OMmsg = om$send(msg = message GRvg.GRputname(msg,tmpname),
	senderid = object_id->objid,
	targetid = object_id->objid,
	targetos = object_id->osnum);

	if ( *msg == GR_E_INV_REQUEST)
	{
    	    for (j = strlen(max_char)-1; j >= 0; --j)
	    {
		if (max_char[j] < '9')
		{	
		    ++max_char[j];
		    j = -10;		/* exit loop	*/
		}
		else
		{
		    if (max_char[j] == '9')
		    {
			max_char[j] = '0';
		    }
		}
	    }
	    if ( j > -2 )
	    {
			       	/* string was all 9's 		*/
	       	strcpy(tmpname,"1");
		strcat(tmpname,max_char);
		strcpy(max_char,tmpname);
	    }					

	    strcpy(tmpname,name);
	    strcat(tmpname,max_char);
	}
   }

   strcpy(name,tmpname);

  wrapup:
   return (OMmsg);
}

/*

Name:

 Abstract:
 This function will return the x, y, and z vectors of a coordinate system.
 It also returns the origin, scale and full matrix of the coordinate 
 system.

 Arguments:
 long	*msg		O	Completion Code
					    MSSUCC - successful completion
					    MSFAIL - error
 struct GRid	*object_id	I	the coordinate system id
					    if not specified, the active
					    coordinate system will
					    be used.
 struct GRmd_env *md_env	I	the module enviornment of
					    the coordinate system
					    (defaults to master file)
 double *origin		O	the origin of the coordinate
					    system
 double *x_vector		O 	the x direction vector
 double *y_vector		O 	the y direction vector
 double *z_vector		O 	the z direction vector
 double *scale		O	the scale (3 doubles, x,y,z scale)
 IGRmatrix *matrix		O	the coordinate system matrix

 History:

*/

int   GRget_coordinate_data(msg,object_id,md_env,origin,x_vector,
			y_vector,z_vector,scale,matrix)

 long	*msg;
 struct GRid	*object_id;
 struct GRmd_env *md_env;
 double *origin;
 double *x_vector;
 double *y_vector;
 double *z_vector;
 double *scale;
 IGRmatrix *matrix;
{
   int OMmsg;
   struct GRmd_env *env,local_env;
   struct GRid *id,act_cs;
   double *m,local_matrix[16];

   GRgetmd_env(md_env,&local_env,&env);

   if (object_id)
   { 
	id = object_id;
   }
   else
   {
	id = &act_cs;

	cs$get_active_info(msg = msg,
		osnum = env->md_id.osnum,
		module = env->md_id.objid,
		objid = &id->objid);

	id->osnum = env->md_id.osnum;
   }

   if (matrix)
   {
	m = (double *)matrix;
   }
   else
   {
	m = local_matrix;
   }
	
   OMmsg = om$send(msg = message GRgencs.GRgetmatrix(msg,m),
	senderid = id->objid,
	targetid = id->objid,
	targetos = id->osnum);

   if ( 1 & OMmsg & *msg)
   {
       	if (origin)
       	{
	    origin[0] = m[3];
	    origin[1] = m[7];
	    origin[2] = m[11];
       	}
       	if (x_vector)
       	{
	    x_vector[0] = m[0];
	    x_vector[1] = m[4];
	    x_vector[2] = m[8];
   	} 
   	if (y_vector)
   	{
	    y_vector[0] = m[1];
	    y_vector[1] = m[5];
	    y_vector[2] = m[9];
   	} 
   	if (z_vector)
   	{
	    z_vector[0] = m[2];
	    z_vector[1] = m[6];
	    z_vector[2] = m[10];
   	} 
   	if (scale)
   	{
	    OMmsg = cs$get_scale(msg = msg,
		     cs_id = id->objid,
		     cs_os = id->osnum,
		     scale = scale);
	}
    }
    
    return(OMmsg);
}

/*

 Name:

 Abstract:

        This function will project the input point onto the element.

 Arguments:

long			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
struct GRmd_env		*md_env		I  module environment 
struct GRid  		*object_id	I  object id 
double		*point		I  point to project
double		*proj_pt	O  projected point on object
double		*u_parm		O  u parameter of projected point
					   on object
double               *v_parm		O  v parameter of projected point
					   (only applies to surfaces)

History:

	12/31/90	MAS	Creation

*/

int GRproject_point_on_element(msg,object_id,md_env,point, 
		proj_pt,u_parm,v_parm)

long			*msg;
struct GRmd_env		*md_env;
struct GRid  		*object_id;
double		*point;
double		*proj_pt;
double		*u_parm;
double               *v_parm;
{

   int OMmsg;
   struct GRmd_env *env,local_env;
   struct GRparms  parms;

   GRgetmd_env(md_env,&local_env,&env);

   parms.u = 0;
   parms.v = 0;

   OMmsg = om$send (
	msg = message GRgraphics.GRptproject
		(msg,&env->md_env.matrix_type,
		 env->md_env.matrix,point,proj_pt,&parms),
	senderid = object_id->objid,
	targetid = object_id->objid,
	targetos = object_id->osnum);

   if ( 1 & OMmsg & *msg)
   {
	*u_parm = parms.u;
	*v_parm = parms.v;
   }

   return(OMmsg);
}


/*

Name:
 	gr$create_graphic_group(
			msg,
			object_ids,
			num_objects,
			gg_id);

 Abstract:

	This function will create a graphic group of the array of object_ids
	The graphic group id is the gg_id.

 Arguments:
 long 	*msg		O	completion code
					    MSSUCC - successful completion
					    MSFAIL - error occured
 int		flag		I	option flag
					    0 - create new graphic group
					        and add the objects
				    	    1 - add the objects to
						input graphic group
 struct GRid	*object_ids	I	Input array of objects.
 int		num_objects	I	Number of object_ids in the array
 struct GRid	*gg_id		O	Output graphic group id.

 Notes:

 History:
*/

int GRcreate_graphic_group (msg,flag,object_ids,num_objects,gg_id)

 long 	*msg;
 int		flag;
 struct GRid	*object_ids;
 int		num_objects;
 struct GRid	*gg_id;
{
    int OMmsg,num_bytes,num_bytes_ret,num,i;
    struct GRmd_env *env,local_env;
    struct GRvg_construct cst;
    struct IGRdisplay local_symbology;
    struct GRobj_env obj_env[100],*ptr;

    GRgetmd_env(NULL,&local_env,&env);
    num = num_objects;
    OMmsg = 1;
    *msg = MSSUCC;

    if ( flag == 0)   /* construct new graphic group */
    {
    	cst.msg = msg;
    	cst.env_info = env;
    	cst.newflag = FALSE;

	num_bytes = sizeof(short);

    	gr$get_active_level(
		msg = msg,
		sizbuf = &num_bytes,
		buffer = &cst.level,
		nret = &num_bytes_ret);

    	num_bytes = sizeof( local_symbology );
    	gr$get_active_display(msg = msg,
                           sizbuf = &num_bytes,
                           buffer = &local_symbology,
                           nret = &num_bytes_ret );

    	cst.display = &local_symbology;
    
    	num_bytes = sizeof(short);
    	gr$get_active_prop(msg = msg,
                      sizbuf = &num_bytes,
                      buffer = &cst.properties,
                      nret = &num_bytes_ret );
    	cst.name = NULL;
    	cst.geometry = NULL;
    	cst.class_attr = NULL;

	gg_id->osnum = env->md_id.osnum;
        OMmsg = om$construct(classname = "GRgrgrp",
		p_objid = &gg_id->objid,
		osnum = env->md_id.osnum,
		msg = message GRgraphics.GRconstruct(&cst));
    }
    if ( 1 & OMmsg & *msg)
    {
	if (num_objects > 100)
        {
	    ptr = (struct GRobj_env *)
		malloc((sizeof(struct GRobj_env) * num_objects));
	}
	else
	{
	    ptr = obj_env;
	}
  	for ( i=0; i< num_objects; ++i)
	{
	    ptr[i].obj_id = object_ids[i];
	    ptr[i].mod_env = *env;
	}

	OMmsg = om$send(msg = message GRowner.GRadd_components
		(msg,env,&num,ptr,NULL,NULL),
	    senderid = gg_id->objid,
	    targetid = gg_id->objid,
	    targetos = gg_id->osnum);

	if (num_objects > 100)
        {
	    free(ptr);
	}
    }

    return (OMmsg);

}



end implementation GRvg;
