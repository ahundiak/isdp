/* #######################    APOGEE COMPILED   ######################## */
class implementation GRgraphics;

#include "grimport.h"
#include <stdio.h>
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "bserr.h"
#include "madef.h"
#include "comiscmac.h"
#include "go.h"
#include "grwireframe.h"
#include "grmacros.h"
#include "griodef.h"
#include "grio.h"
#include "grerr.h"

#define ARC 1
#define CIRCLE 0

from GRlinear import GRgetpolyline;
from GRconic import GRgetarc;
from GRcurve import GRendpts,GRrevparm;
from GRvg import GRgetsize,GRgetgeom, GRpostabsg;
/* MODEL
from GRsubbc import EMcurve_by_poles, EMleast_squares_fit_curvee;
*/

int GRgetmd_env(md_env,local_env,env)
struct GRmd_env *md_env;
struct GRmd_env *local_env;
struct GRmd_env **env;
{
    IGRlong	msg;
    if (! md_env)
    {
    	IGRint size;
      	size = sizeof (struct GRmd_env);

	gr$get_module_env(msg=&msg,
			sizbuf = &size,
			buffer = local_env,
			nret = &size);
        *env=local_env;
   }
   else
   {
	*env = md_env;
   }

   return(1);

}

/*
Name:
    GRgetpolyline_struct(msg,object_id,md_env,polyline);

Abstract:

	This function will return an IGRpolyline structure for a linear
object.  This includes  Points, Lines, and Linestrings and polygons.

Arguments:
IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
						MSINARG - not a
						    linear object
struct GRmd_env		*md_env		I  module environment 
struct GRid  		*object_id	I  object id of linear object
struct IGRpolyline 	*polyline  	O  polyline structure
					     the points array will be 
					     allocated in the function. The 
					     caller must free the array
				  	     i.e.,free(polyline.points)

*/

int GRgetpolyline_struct(msg,object_id,md_env,polyline)

IGRlong		*msg;
struct GRid	*object_id;
struct GRmd_env *md_env;
struct IGRpolyline *polyline;

{
   IGRint action=0;
   IGRint OMmsg;
   struct GRmd_env *env,local_env;

   GRgetmd_env(md_env,&local_env,&env);

   OMmsg = om$send(msg = message GRlinear.GRgetpolyline(
	msg,
	&env->md_env.matrix_type, 
	env->md_env.matrix,
	&action,
	polyline),
	senderid = NULL_OBJID,
	targetid = object_id->objid, 
	targetos = object_id->osnum);

    if ( 1 & OMmsg & *msg)
    {
   	polyline->points = (IGRdouble *) 
		malloc( polyline->num_points * 3 * sizeof(IGRdouble));

   	action = 1;
   	om$send(msg = message GRlinear.GRgetpolyline(
			msg,&env->md_env.matrix_type, 
			env->md_env.matrix,&action,polyline),
		senderid = NULL_OBJID,
		targetid = object_id->objid, 
		targetos = object_id->osnum);
    }
    else
    {
	*msg = MSINARG;
    }

    return (OMmsg);
}
 
/*
Name:

	 GRgetconic_struct(msg,object_id,md_env,conic)

Abstract:

	This function will return an IGRarc structure for a conic
object.  This includes  circular arcs, elliptical arcs, circles and
ellipses.

Arguments:
IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
						MSINARG - not a
						    conic object
struct GRmd_env		*md_env		I  module environment 
struct GRid  		*object_id	I  object id of conic object
struct IGRarc 		*arc  		O  arc structure

*/

int GRgetconic_struct(msg,object_id,md_env,arc)

IGRlong			*msg;
struct GRmd_env		*md_env;
struct GRid  		*object_id;
struct IGRarc 		*arc;
{
   IGRint OMmsg;
   struct GRmd_env *env,local_env;

   GRgetmd_env(md_env,&local_env,&env);

   OMmsg = om$send(msg = message GRconic.GRgetarc(
		msg,&env->md_env.matrix_type, env->md_env.matrix,arc),
	senderid = NULL_OBJID,
	targetid = object_id->objid, 
	targetos = object_id->osnum);

   if (! (OMmsg & 1 & *msg))
   {
       *msg = MSINARG;
   }

   return(OMmsg);

}


/*
Name:	
    GRreverse_curve(msg,object_id,md_env)

Abstract:
    This function will reverse the parametric direction of the input
curve.

Arguments:
IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
						MSINARG - object is in
						   a read only
						   object space
struct GRmd_env		*md_env		I  module environment 
struct GRid  		*object_id	I  object id 

History:

	12/21/90	MAS	Creation

*/

int GRreverse_curve(msg,object_id,md_env)

IGRlong			*msg;
struct GRmd_env		*md_env;
struct GRid  		*object_id;

{
   IGRint OMmsg;
   struct GRmd_env *env,local_env;

   GRgetmd_env(md_env,&local_env,&env);

   OMmsg = om$send( msg = message GRcurve.GRrevparm(msg,env),
	senderid = NULL_OBJID,
	targetid = object_id->objid,
	targetos = object_id->osnum); 

   return(OMmsg);
}

/*
Name:	

    GRget_endpoints(msg,object_id,md_env,point1,point2)

Abstract:
    This function will return the endpoints of a curve

Arguments:

IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
struct GRmd_env		*md_env		I  module environment 
struct GRid  		*object_id	I  object id 
IGRdouble		*point1		O  beginning point (x,y,z)
IGRdouble		*point2		O  end point (x,y,z)

History:

	12/21/90	MAS	Creation

*/

int  GRget_endpoints(msg,object_id,md_env,point1,point2)

IGRlong			*msg;
struct GRmd_env		*md_env;
struct GRid  		*object_id;
IGRdouble		*point1;
IGRdouble		*point2;

{
   IGRint OMmsg;
   struct GRmd_env *env,local_env;

   GRgetmd_env(md_env,&local_env,&env);

   OMmsg = om$send(msg= message GRcurve.GRendpts
	(msg,&env->md_env.matrix_type,env->md_env.matrix,point1,point2),
	senderid = NULL_OBJID,
	targetid= object_id->objid,
	targetos= object_id->osnum);

    return(OMmsg);
}


/*
 Name:	

    GRproject_point(msg,object_id,md_env,vec_start,vec_end,
	point, proj_point,u_parm,v_parm)

 Abstract:

    This function will project the input point onto the input object
    along a vector.


 Arguments:

IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
struct GRmd_env		*md_env		I  module environment 
struct GRid  		*object_id	I  object id 
IGRdouble               *vec_start	I  start point to compute
					 	projection vector
IGRdouble               *vec_end	I  end point to compute vector
					 	projection vector
IGRdouble		*point		I  point to project
IGRdouble		*proj_pt	O  projected point on object
IGRdouble		*u_parm		O  u parameter of projected point
					   on object
IGRdouble               *v_parm		O  v parameter of projected point
					   (only applies to surfaces)
History:

	12/31/90	MAS	Creation
	05/07/92  	Carlos  Modified to not return MSSUCC if
				the projection is not an actual
				intersection. (TR91n3591)
*/

int GRproject_point(msg,object_id,md_env,vec_start,vec_end,
	point, proj_pt,u_parm,v_parm)

IGRlong			*msg;
struct GRmd_env		*md_env;
struct GRid  		*object_id;
IGRdouble               *vec_start;
IGRdouble               *vec_end;
IGRdouble		*point;
IGRdouble		*proj_pt;
IGRdouble		*u_parm;
IGRdouble               *v_parm;
{
   IGRint OMmsg;
   struct GRmd_env *env,local_env;
   struct IGRline line;
   IGRdouble v1[3],v2[3],t;
   struct GRparms parms;

   GRgetmd_env(md_env,&local_env,&env);
   
   line.point1 = point;
   line.point2 = v2;

   parms.u = 0.0;
   parms.v=0.0;
   
   if (vec_end)
   {
	MAsubvc(msg,vec_end,vec_start,v1);
	MAaddvc(msg,point,v1,v2);
   }
   else
   {
	MAaddvc(msg,point,vec_start,v2);
   }

   OMmsg = om$send( msg = message GRgraphics.GRlnproject
	       (msg,&env->md_env.matrix_type,env->md_env.matrix,
		&line,v1,proj_pt,&t,&parms),
            senderid = NULL_OBJID,
	    targetid = object_id->objid,
	    targetos = object_id->osnum); 

   *u_parm = parms.u;
   *v_parm= parms.v;

   /*
    * Now check if the resulting point is collinear with the
    * input point and the direction of projection, which will
    * indicate if the line of projection actually intersects
    * the object. Carlos (TR91n3591).
    */   
   if (*msg == MSSUCC) {
      int     rc;
      if (BScollin (&rc, point, proj_pt, v1)) 
          *msg = MSSUCC;
        else
          *msg = GR_NO_INT_POINT;
      }
   return(OMmsg);
}

/*
Name:

int GRgetcurve_struct(msg,object_id,md_env,curve_struct)

 Abstract:

        This function will return the bspline geometry for use. 

Arguments:

IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
struct GRid  		*object_id	I  object id 
struct GRmd_env		*md_env		I  module environment 
struct IGRbsp_curve 	**curve_struct 	O  bspline curve structure
					     

Notes:
The memory for the B_spline curve structure's poles, knots and weights 
will be allocated by this function.

*/


int GRgetcurve_struct(msg,object_id,md_env,curve_struct)

IGRlong			*msg;
struct GRid  		*object_id;
struct GRmd_env		*md_env;
struct IGRbsp_curve 	**curve_struct;
{

   IGRint OMmsg;
   IGRlong size;
   struct GRmd_env *env,local_env;

   GRgetmd_env(md_env,&local_env,&env);

   OMmsg = om$send(
	msg = message GRvg.GRgetsize(msg,&env->md_env.matrix_type,
		env->md_env.matrix,&size),
           senderid = NULL_OBJID,
	   targetid = object_id->objid,
	   targetos = object_id->osnum);

   if ( 1 & OMmsg & *msg)
   {
	*curve_struct = (struct IGRbsp_curve *)malloc(size);

        OMmsg = om$send(msg = message GRvg.GRgetgeom
		(msg,&env->md_env.matrix_type,
		env->md_env.matrix,(char *) *curve_struct),
           senderid = NULL_OBJID,
	   targetid = object_id->objid,
	   targetos = object_id->osnum);
	
   }
   return(OMmsg);
}

/*
Name:

Abstract:

        This function will update an objects bspline geometry.

Arguments:

IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
struct GRid  		*object_id	I  object id 
struct GRmd_env		*md_env		I  module environment 
struct IGRbsp_curve 	*curve_struct  	I  bspline curve structure
IGRint			display_flag    I  flag to indicate whether 
					   redisplay of object with new
					   geometry is desired
					   1 -(default) redisplay
					   0 - do not redisplay

*/

int GRputcurve_struct(msg,object_id,md_env,curve_struct,display_flag,
		new_id)

IGRlong			*msg;
struct GRid  		*object_id;
struct GRmd_env		*md_env;
struct IGRbsp_curve 	*curve_struct;
IGRint			display_flag;
GRobjid			*new_id;
{

   IGRint OMmsg;
   struct GRmd_env *env,local_env;
   struct GRid module;
   enum GRdpmode mode;
   struct GRpost_info post_info;

   GRgetmd_env(md_env,&local_env,&env);
   ex$get_cur_mod(id=&module.objid,
		osnum=&module.osnum);

   if (display_flag)
   {
	mode = GRbehe;

	OMmsg = om$send(msg= message  GRgraphics.GRdisplay
		(msg,&env->md_env.matrix_type,env->md_env.matrix,&mode,
		 &module),
            	senderid = NULL_OBJID,
		targetid=object_id->objid,
		targetos=object_id->osnum);
   }

   post_info.construct_flag = FALSE;
   GRabsg_del_all();
   
   OMmsg = om$send(msg = message GRvg.GRpostabsg
		(msg,env,&post_info,(char *)curve_struct,new_id),
           senderid = NULL_OBJID,
	   targetid = object_id->objid,
	   targetos = object_id->osnum);

	
   if (display_flag)
   {
	mode = GRbd;

	OMmsg = om$send(msg= message  GRgraphics.GRdisplay
		(msg,&env->md_env.matrix_type,env->md_env.matrix,&mode,
		 &module),
            	senderid = NULL_OBJID,
		targetid=*new_id,
		targetos=object_id->osnum);
   }

   return(OMmsg);
}

/*
 Name:

  GRfree_curve(curve_struct)

 Abstract:
        This function will free up the memory that was allocated by the
        gr$get_curve_geometry() macro.

 Arguments:

struct IGRbsp_curve	*curve_struct	I       B_spline curve structure

*/

int  GRfree_curve(curve_struct)
struct IGRbsp_curve *curve_struct;

{
    free(curve_struct);
    return(1);

}

/*
Name:

 GRcreate_linestring(msg,md_env,num_points,points,object_id,name,
	display_flag)

 Abstract:

	This function will create a linear object from the input
points. If the number of points is 1, a point is created, if the
number of points is 2, a line segment is created, if the number of
points is greater than 2 a line string is created.

 Arguments:
 IGRint		*msg		O 	return message
					    MSSUCC - if successful
					    MSFAIL - if error occured
 struct GRmd_env *md_env	I	module environment
 IGRint 	num_points	I	number of points.
					    ( 1 means one (x,y,z) point)
 IGRdouble	*points		I	input array of input points.
 struct GRid	*object_id	O	Output id.
 IGRchar	*name 		I/O	name
					 if the name supplied has already
					  been used, a suffix will
					  be added to make the name unique
					  and this new name will be 
					  returned.
 IGRint		display_flag	I	display option.
					   0 - do not draw
					   1 - display object
*/

int  GRcreate_linestring(msg,md_env,num_points,points,object_id,name,display_flag)

 IGRint		*msg;
 struct GRmd_env *md_env;
 IGRint 	num_points;
 IGRdouble	*points;
 struct GRid	*object_id;
 IGRchar	*name;
 IGRint		display_flag;

{
   IGRint OMmsg;
   struct GRmd_env *env,local_env;
   struct IGRbsp_curve bspline;
   IGRdouble knots[502],local_points[6];
   struct GRid *disp_mod;
   struct IGRpolyline py;
   char classname[40];

    GRgetmd_env(md_env,&local_env,&env);

    bspline.knots=knots;
    bspline.poles=points;

    if (num_points ==1)
    {
	strcpy(classname,"GR3dpoint");
        bspline.poles=local_points;
    }
    else if (num_points == 2)
    {
	strcpy(classname,"GR3dlineseg");
    }
    else 
    {
	strcpy(classname,"GR3dlinestr");
    	if (num_points > 500)
    	{
	    bspline.knots = (double *)malloc((sizeof(double) * num_points)+2);
	}
    }

    if (display_flag)
    {
	disp_mod = &env->md_id;
    }
    else
    {
	disp_mod = NULL;
    }

    py.num_points = num_points;
    py.points = points;

    MApytobc(msg,&py,&bspline);

    if ( 1 & *msg)
    {
        co$construct_object(
                msg=msg,
                mode = GRbd,
                geometry= &bspline,
                module = env,
                display_obj = disp_mod,
                classname = classname,
                grid = object_id,
                cob_id = NULL_OBJID);
    }

    gr$put_name(msg = msg,object_id = object_id,name =name);

    return(OMmsg);
}

/*
Name:
   GRcreate_conic_by_edge(msg,md_env,flag,start_point,dir_point,end_point,
		object_id,name,display_flag)

 Abstract:
	This function will create an arc by three points on 
	the edge.

 Arguments:

 IGRint	        *msg		O	return value
					   MSSUCC - successful completion
					   MSFAIL - error
 struct GRmd_env *md_env	I	module environment
 IGRint		flag		I	conic flag
					   1 - arc
					   0 - circle
 IGRdouble	*start_point	I	input for start of arc.
 IGRdouble	*dir_point	I	input for direction point.
 IGRdouble	*end_point	I	input for end of arc.
 struct GRid	*object_id	O	Constructed object id.
 int		flag		I	conic flag
					1 - construct arc
					0 - construct circle
 IGRchar	*name 		I/O	name.
					 if the name supplied has already
					  been used, a suffix will
					  be added to make the name unique
 IGRint		display_flag	I	display option.
					   0 (default) do not display
					   1 display constructed object
*/
int  GRcreate_conic_by_edge(msg,md_env,flag,start_point,dir_point,
	end_point, object_id,name,display_flag)

 IGRint	        *msg;
 struct GRmd_env *md_env;
 int		flag;
 IGRdouble	*start_point;
 IGRdouble	*dir_point;
 IGRdouble	*end_point;
 struct GRid	*object_id;
 IGRchar	*name;
 IGRint		display_flag;

{
    IGRint OMmsg;
    struct GRmd_env *env,local_env;
    IGRdouble pts[9];
    IGRdouble knots[MAELKNOT_SIZE];
    IGRdouble weights[MAELPOLE_SIZE];
    IGRdouble poles[MAELPOLE_SIZE * 3];
    struct IGRbsp_curve curve;
    char classname[40];
    struct GRid *disp_mod;

    GRgetmd_env(md_env,&local_env,&env);
    curve.poles = poles;
    curve.knots = knots;
    curve.weights = weights;

    pts[0] = start_point[0];
    pts[1] = start_point[1];
    pts[2] = start_point[2];

    pts[3] = dir_point[0];
    pts[4] = dir_point[1];
    pts[5] = dir_point[2];

    pts[6] = end_point[0];
    pts[7] = end_point[1];
    pts[8] = end_point[2];

    if (flag == ARC)
    {
	strcpy(classname,"GR3dcirarc");

        MAar3ptconstr(msg,pts,&curve);
    }
    else
    {
	strcpy(classname,"GR3dcircle");
        MAcr3ptconstr(msg,pts,&curve);
    }
    if (display_flag)
    {
	disp_mod = &env->md_id;
    }
    else
    {
	disp_mod = NULL;
    }

    if ( 1 & *msg)
    {
        co$construct_object(
                msg=msg,
                mode = GRbd,
                geometry= &curve,
                module = env,
                display_obj = disp_mod,
                classname = classname,
                grid = object_id,
                cob_id = NULL_OBJID);
    }

    gr$put_name(msg = msg,object_id = object_id,name =name);

    return(OMmsg);
}

/*
Name:

   GRcreate_conic_by_center (msg,md_env,flag,center,start_point,
	end_point,window_id,object_id,name,display_flag)

 Abstract:
	This function will create an arc or a circle by center, 
a point defining the start point and a point for the end point.

	Whether the arc has clockwise or counter clockwise sweep will be
determined by the value stored in the dpb for sweep angle.

	The window information is used to determine the rotation
matrix of the arc if it can not be determined from the 3 input
points and to be used with the counter clockwise flag to determine
which direction is counter clockwise.

 Arguments:

 IGRint	        *msg		O	return value
					   MSSUCC - successful completion
					   MSFAIL - error
 struct GRmd_env *md_env	I	module environment
 IGRint		flag		I 	conic flag
					   1 - arc
					   2 - circle
 IGRdouble	*center		I	input for center of conic.
 IGRdouble	*start_point	I	input for start point.
 IGRdouble	*end_point	I	input for end of arc 
 					(plane for circle).
 struct GRid	*window_id	I	window to construct conic 
 struct GRid	*object_id	O	Constructed object id.
 IGRchar	*name 		I/O	name.
					 if the name supplied has already
					  been used, a suffix will
					  be added to make the name unique
 IGRint		display_flag	I	display option.
					   0 (default) do not display
					   1 display constructed object
HISTORY:
	Carlos	06/08/92  Modified code for the circle so that the 3rd
			  point is used to determine the plane. If no
			  3rd point is given, circle will be in view plane.
			  See TR91n1565. 
*/

extern IGRboolean BScrossp ();
int  GRcreate_conic_by_center (msg,md_env,flag,center,start_point,
	end_point,window_id,object_id,name,display_flag)
	
 IGRint	        *msg;
 struct GRmd_env *md_env;
 IGRint		flag;
 IGRdouble	*center;
 IGRdouble	*start_point;
 IGRdouble	*end_point;
 struct GRid	*window_id;
 struct GRid	*object_id;
 IGRchar	*name;
 IGRint		display_flag;

{
    IGRint i;
    struct GRmd_env *env,local_env;
    IGRdouble knots[MAELKNOT_SIZE];
    IGRdouble weights[MAELPOLE_SIZE];
    IGRdouble poles[MAELPOLE_SIZE*3];
    IGRdouble view_matrix[16],vc[3];
    IGRboolean dir;
    
    struct IGRbsp_curve curve;
    char classname[40];
    struct var_list view_info[2];

    struct GRid *disp_mod;

    GRgetmd_env(md_env,&local_env,&env);
    curve.poles = poles;
    curve.knots = knots;
    curve.weights = weights;

    view_info[0].var = VIEW_ROTATION;
    view_info[0].var_ptr = (char *) view_matrix;
    view_info[0].num_bytes = sizeof(view_matrix);
    view_info[0].bytes_returned = (long *)&i;
    view_info[1].var = END_PARAM;

    dp$inq_set_gragad(msg = msg,
		gragad_objid = window_id->objid,
		osnum = window_id->osnum,
		var_list = view_info,
		which_error = &i);
 
    i = sizeof(short);
    gr$get_arc_direction (msg=msg,
	sizbuf = &i,
	buffer = &dir,
	nret= &i);

    if (!dir)
    {
	vc[0] = -view_matrix[8];
    	vc[1] = -view_matrix[9];
	vc[2] = -view_matrix[10];
    }
    else
    {
	vc[0] = view_matrix[8];
    	vc[1] = view_matrix[9];
	vc[2] = view_matrix[10];
    }

    if (flag == ARC)
    {
	strcpy(classname,"GR3dcirarc");
	GRarcaxpt(msg,center,start_point,end_point,vc,&curve);
    }
    else
    {   
	strcpy(classname,"GR3dcircle");
	if (end_point) {
	  /* change the normal to that of the plane */
	  /* determined by the 3 points given.	    */
	  IGRvector v1,v2;
	  MAsubvc(msg,start_point,center,v1);
	  MAsubvc(msg,start_point,end_point,v2);
	  BScrossp(msg,v1,v2,vc);
	  }
	MAcrcptconstr (msg,center,start_point,vc,&curve);
    }
    if (display_flag)
    {
	disp_mod = &env->md_id;
    }
    else
    {
	disp_mod = NULL;
    }

    if (*msg == MSSUCC)
    {
        co$construct_object(
                msg=msg,
                mode = GRbd,
                geometry= &curve,
                module = env,
                display_obj = disp_mod,
                classname = classname,
                grid = object_id,
                cob_id = NULL_OBJID);
    }
    if ( *msg==MSSUCC)
    {
        gr$put_name(msg = msg,object_id = object_id,name =name);
    }

    return(*msg);
}


end implementation GRgraphics;
