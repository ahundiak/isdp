#ifndef grwireframe_include

#define grwireframe_include


/*
Name:
	gr$get_polyline(
		 msg, 
		 md_env=NULL,
		 object_id,
		 polyline);
Abstract:

	This macro will return an IGRpolyline structure for a linear
object.  Valid objects for this macro are  Points, Lines, Linestrings 
and polygons.

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
					     allocated in the macro. The 
					     caller must free the array
				  	     i.e.,free(polyline.points)
Sample Call:

    IGRint		i;
    IGRint 		msg1;
    struct GRid	linear_obj;
    struct IGRpolyline	polyline;
    struct GRmd_env	env;

    message("Get linear object information");

    while(1)
    {   
	ci$locate( obj = &linear_obj.objid,
	   	osnum = &linear_obj.osnum,
		classes = "GRlinear",
		md_env = &env,
		prompt= "Identify linear object");

	gr$get_polyline(
		msg = &msg1,
		object_id =&linear_obj,
		polyline = &polyline,
		md_env = &env);

	if (1 & msg1)	
	{
	    write("polyline information\n");
	    write("number of points= \n",polyline.num_points);
	    write("points\n");
	    for(i=0;i<polyline.num_points*3; i=i+3)
	    {
	        write(polyline.points[i],polyline.points[i+1],polyline.points[i+2],'\n');
	    }
	    free(polyline.points);
	}
    }


Notes:

If the module environment is not supplied, the coordinates of the polyline
will be returned as they were stored in the object space. Any
transformation applied to a reference file object will not be applied.  

History:

	12/21/90	MAS	Creation

*/

#omdef gr$get_polyline
		(msg,
		 md_env=NULL,
		 object_id,
		 polyline)

#if (! ( om$specified(polyline) || om$specified(msg) || om$specified(object_id)))
{
#   omerror "Must specify msg, polyline, and object_id"
}
#else
    GRgetpolyline_struct((msg),(object_id),(md_env),(polyline));

#endif
#endomdef

/*
Name:
	gr$get_conic(
		 msg, 
		 md_env=NULL,
		 object_id,
		 conic);
Abstract:

	This macro will return an IGRarc structure for a conic
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
struct IGRarc 		*conic		O  conic structure

Sample Call:

main()
{
    int		i;
    int 	msg1;
    struct GRid	conic_obj;
    struct IGRarc	conic;
    struct GRmd_env	env;

    message("Get conic object information");

    while(1)
    {   
	ci$locate( obj = &conic_obj.objid,
	   	osnum = &conic_obj.osnum,
		classes = "GRconic",
		md_env = &env,
		prompt= "Identify conic");

	gr$get_conic(
		msg = &msg1,
		object_id =&conic_obj,
		arc = &conic,
		md_env = &env);

	if (1 & msg1)	
	{
	    write("conic information\n");
	    write("start angle= \n",conic.start_angle);
	    write("sweep angle= \n",conic.sweep_angle);
	    write("primary axis= \n",conic.prim_axis);
	    write("secondary axis= \n",conic.sec_axis);
	    write("origin\n");
	    write(conic.origin[0],conic.origin[1],conic.origin[2],'\n');
	    write("rotation matrix");
	    for (i=0; i<16; i=i+4)
	    {
	       write(conic.rot_matrix[i],conic.rot_matrix[i+1],conic.rot_matrix[i+2],conic.rot_matrix[i+3]'\n');
	    }
	}
    }
}

Notes:

If the module environment is not supplied, the coordinates of the conic
will be returned as they were stored in the object space. Any
transformation applied to a reference file object will not be applied.  

History:

	12/21/90	MAS	Creation

*/

#omdef gr$get_conic
		(msg,
		 md_env=NULL,
		 object_id,
		 conic)

#if (! ( om$specified(conic) || om$specified(msg) || om$specified(object_id)))
{
#   omerror "Must specify msg, conic, and object_id"
}
#else
    GRgetconic_struct((msg),(object_id),(md_env),(conic));
#endif
#endomdef

/*
Name:
	gr$get_placement_information(
		 msg, 
		 md_env=NULL,
		 object_id,
		 geometry);
Abstract:

	This macro will return an IGRlbsys structure for a text
object, or a cell or a symbol.  This local bounded system will define
the orientation of the object.  The matrix in the local bounded system
defines the transformation of the object from local coordinates to world
coordinates.  The diagonal points are in local coordinates.  The 4x4
matrix has the origin as the 4th column of the matrix.

Arguments:
IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
						MSINARG - not a
						    linear object
struct GRmd_env		*md_env		I  module environment 
struct GRid  		*object_id	I  object id of linear object
struct IGRlbsys 	**geometry  	O  local bounded system structure
					     the structure  will be 
					     allocated in the macro. The 
					     caller must free the structure
					     after the call by using
					     free(*geometry);
Sample Call:

main()
{
    IGRint		i;
    IGRint 	msg1;
    struct GRid	lbsys_obj;
    struct IGRlbsys	*lbsys;
    struct GRmd_env	env;

    message("Get placement orientation information");

    while(1)
    {   
	ci$locate( obj = &lbsys_obj.objid,
	   	osnum = &lbsys_obj.osnum,
		classes = "GRlbsys",
		md_env = &env,
		prompt= "Identify text, cell, or symbol");

	gr$get_placement_information(
		msg = &msg1,
		object_id =&lbsys_obj,
		geometry = &lbsys,
		md_env = &env);

	if (1 & msg1)	
	{
	    write("orientation information\n");
	    write("origin = ",lbsys->matrix[3],lbsys->matrix[7],lbsys->matrix[11],'n\');
	    write("matrix\n");
	    for(i=0;i<16; i=i+4)
	    {
	        write(lbsys->matrix[i],lbsys->matrix[i+1],lbsys->matrix[i+2],lbsys->matrix[i+3],'\n');
	    }
	    free(lbsys);
	}
    }
}

Notes:

If the module environment is not supplied, the coordinates of the 
local bounded system will be returned as they were stored in the 
object space. Any transformation applied to a reference file object 
will not be applied.  

History:

	12/21/90	MAS	Creation

*/

#omdef gr$get_placement_information
		(msg,
		 md_env=NULL,
		 object_id,
		 geometry)

#if (! ( om$specified(geometry) || om$specified(msg) || om$specified(object_id)))
{
#   omerror "Must specify msg, geometry, and object_id"
}
#else
    GRgetcurve_struct((msg),(object_id),(md_env),(geometry));
#endif
#endomdef

/*
Name:	
	gr$reverse_curve
		msg,
		md_env=NULL,
		object_id)
Abstract:
    This macro will reverse the parametric direction of the input
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

Sample Call:

    struct GRid     curve;
    struct GRmd_env env;

    ci$locate( obj   = &curve.objid,
               osnum = &curve.osnum,
	       md_env = &env,
	       properties = LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY,
               prompt= "Identify curve");

    gr$reverse_curve(
	    msg = &msg1,
	    md_env = &env,
	    object_id  = &curve );

Notes:
       Note that since the operation is a write operation the
properties for locate  are set so that invalid objects are not located.

History:

	12/21/90	MAS	Creation

*/

#omdef gr$reverse_curve(
		msg,
		md_env=NULL,
		object_id)

#if (! (om$specified(msg) || om$specified(object_id)))
{
#   omerror "Must specify msg, and object_id"
}
#else
    GRreverse_curve((msg),(object_id),(md_env));
#endif
#endomdef


/*
Name:	
	gr$get_endpoints(
		msg,
		md_env=NULL,
		object_id,
		point1,
		point2)
Abstract:
    This macro will return the endpoints of a curve

Arguments:

IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
struct GRmd_env		*md_env		I  module environment 
struct GRid  		*object_id	I  object id 
IGRdouble		*point1		O  beginning point (x,y,z)
IGRdouble		*point2		O  end point (x,y,z)

Sample Call:

    struct GRid     curve;
    struct GRmd_env env;
    IGRdouble  	    point1[3],point2[3];
    IGRlong	    msg1;

    ci$locate( obj   = &curve.objid,
               osnum = &curve.osnum,
	       md_env = &env,
               prompt= "Identify curve");

    gr$get_endpoints(
	    msg = &msg1,
	    md_env = &env,
	    object_id  = &curve 
	    point1=point1,
	    point2=point2);
Notes:

If the module environment is not supplied, the coordinates of the object
will be returned as they were stored in the object space. Any
transformation applied to a reference file object will not be applied.  

History:

	12/21/90	MAS	Creation

*/

#omdef gr$get_endpoints(
		msg,
		md_env=NULL,
		object_id,
		point1,
		point2)

#if (! (om$specified(msg) || om$specified(object_id) || om$specified(point1) || om$specified(point2) ))
{
#   omerror "Must specify msg, point1, point2 and object_id"
}
#else

    GRget_endpoints((msg),(object_id),(md_env),(point1),(point2));
#endif

#endomdef

/*
 Name:	

 gr$project_point_along_vector
                        (msg,
			md_env=NULL,
			object_id,
                        vec_start,
                        vec_end=NULL,
			point,
                        proj_pt,
                        u_parm,
                        v_parm)

 Abstract:

        This macro will project the input point onto the input object
        along a vector.


 Arguments:

IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
struct GRmd_env		*md_env		I  module environment 
struct GRid  		*object_id	I  object id 
IGRdouble               *vec_start	I  start point to compute
					 	projection vector
IGRdouble               *vec_end	I  end point to compute
					 	projection vector
						(not necessary if vec_start
						 is a vector and not
						 just a data point)
IGRdouble		*point		I  point to project
IGRdouble		*proj_pt	O  projected point on object
IGRdouble		*u_parm		O  u parameter of projected point
					   on object
IGRdouble               *v_parm		O  v parameter of projected point
					   (only applies to surfaces,
					    but the argument is not optional)
Sample Call:

    struct GRid     object;
    struct GRmd_env env;
    IGRdouble  	    point[3],proj_point[3],vc1[3],vc2[3];
    IGRdouble	    u,v;
    IGRlong	    msg1;

    ci$locate( obj   = &object.objid,
               osnum = &object.osnum,
	       md_env = &env,
               prompt= "Identify object");

    ci$get(prompt="Enter point to project",
	   point = point);
    ci$get(prompt="Enter beginning point for vector",
	   point = vc1);
    ci$get(prompt="Enter ending point for vector",
	   point = vc2);

    gr$project_point_along_vector(
	    msg = &msg1,
	    md_env = &env,
	    object_id  = &object,
	    vec_start = vc1,
	    vec_end = vc2,
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

#omdef gr$project_point_along_vector
                        (msg,
			md_env=NULL,
			object_id,
                        vec_start,
                        vec_end=NULL,
			point,
			proj_pt,
			u_parm,
                        v_parm)

#if (! ( om$specified(msg) || om$specified(object_id) ||    om$specified(vec_start) || om$specified(proj_pt) ||    om$specified(v_parm) || om$specified(u_parm) || om$specified(point)))
{
#   omerror "Must specify msg, vec_start, vec_end, proj_pt, u_parm, v_parm, object_id, point"
}
#else

    GRproject_point((msg),(object_id),(md_env),(vec_start),(vec_end),
	(point), (proj_pt),(u_parm),(v_parm));

#endif

#endomdef

/*
Name:
  gr$get_curve_geometry
                       (msg,
			md_env=NULL,
			object_id,
                        curve_struct)

 Abstract:

        This macro will return the geometry of the object in B-spline format.

Arguments:

IGRlong			*msg		O  return message
						MSSUCC - successful
						MSFAIL - failure
struct GRid  		*object_id	I  object id of lbsys object
struct GRmd_env		*md_env		I  module environment 
struct IGRbsp_curve 	**curve_struct 	O  bspline curve structure
					     

Notes:
The memory for the B_spline curve structure and the poles, 
knots and weights will be allocated by this macro. The caller 
must free the memory by calling gr$free_curve.

 Sample Call:

      struct GRid     CURVE;
      struct IGRbsp_curve *bspline;
      struct GRmd_env	env;
      IGRlong msg1,i,j,OMmsg;

    ci$locate( obj   = &CURVE.objid,
                 osnum = &CURVE.osnum,
		 classes = "GRcurve",
		 md_env  = &env,
                 prompt= "Identify curve");

    OMmsg = gr$get_curve_geometry( msg = &msg1,
			     object_id = &CURVE,
			     md_env = &env,
                             curve_struct  = &bspline);      
    j = 1;
    if ( 1 & msg1 & OMmsg)
    {
      	for (i=0; i< bspline->num_poles; i=i+1)
      	{
      	    printf("pole %d = %lf %lf %lf\n",
		j,bspline->poles[i*3],bspline->poles[i*3+1],
		bspline->poles[i*3+2]);
	    j = j+1;
      	}

      	for (i=0; i<bspline->num_knots; i=i+1)
      	{
            printf("knot %d = %lf \n",i,bspline->knots[i]);
      	}

        gr$free_curve( curve_struct = bspline);
    }

History:

	12/21/90	MAS	Creation

*/

#omdef  gr$get_curve_geometry
                       (msg,
			md_env=NULL,
			object_id,
                        curve_struct)


#if (! ( om$specified(curve_struct) || om$specified(msg) || om$specified(object_id)))
{
#   omerror "Must specify msg, curve_struct, and object_id"
}
#else
    GRgetcurve_struct((msg),(object_id),(md_env),(curve_struct));

#endif

#endomdef


/*
Name:
  gr$put_curve_geometry
                       (msg,
			md_env=NULL,
			object_id,
                        curve_struct,
			display_flag = 1,
			new_id)

 Abstract:

        This macro will update an objects bspline geometry.

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
GRobjid			*new_id		O  object id after changing
					   the geometry.  Some objects 
					   may need to change class 
					   after altering. 
 Sample Call:

      struct GRid     CURVE;
      struct IGRbsp_curve *bspline;
      struct GRmd_env	env;
      GRobjid		new_id;

      IGRlong msg1;

      ci$locate( obj   = &CURVE.objid,
                 osnum = &CURVE.osnum,
		 classes = "GRcurve",
		 md_env  = &env,
	   	 properties = (LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY),
	         owner_action=(LC_FLEX_COMP | LC_RIGID_OWNER | LC_FLEX_OWNER),
                 prompt= "Identify curve");

      gr$get_curve_geometry( msg = &msg1,
			     md_env = &env,
			     object_id = &CURVE,
                             curve_struct  = &bspline);      

      for (i=0; i<bspline.num_poles; i=i+1)
      {
	bspline->poles[i*3] = bspline->poles[i*3]+1;
	bspline->poles[i*3+1] = bspline->poles[i*3+1]+1;
	bspline->poles[i*3+2] = bspline->poles[i*3+2]+1;
      }

      gr$put_curve_geometry( msg = &msg1,
			     md_env = &env,
			     object_id = &CURVE,
                             curve_struct  = bspline,
			     new_id = &new_id);      


Notes:

       Note that since the operation is a write operation the
properties for locate  and owner_action are set so that invalid 
objects are not located.

History:

	12/21/90	MAS	Creation
*/

#omdef  gr$put_curve_geometry
                       (msg,
			md_env=NULL,
			object_id,
                        curve_struct,
			display_flag=1,
			new_id)


#if (! ( om$specified(curve_struct) || om$specified(msg) || om$specified(object_id) || om$specified(new_id)))
{
#   omerror "Must specify msg, curve_struct, and object_id"
}
#else
    GRputcurve_struct((msg),(object_id),(md_env),(curve_struct),
		(display_flag),(new_id));

#endif

#endomdef

/*
 Name:
 gr$free_curve ( curve_struct)

 Abstract:
        This macro will free up the memory that was allocated by the
        gr$get_curve_geometry() macro.

 Arguments:

struct IGRbsp_curve	*curve_struct	I       B_spline curve structure

 Sample Call:

      struct GRid     CURVE;
      struct IGRbsp_curve *bspline;
      struct GRmd_env	env;
      IGRlong msg1,i,OMmsg,j;

      ci$locate( obj   = &CURVE.objid,
                 osnum = &CURVE.osnum,
		 classes = "GRcurve",
		 md_env  = &env,
                 prompt= "Identify curve");

      OMmsg = gr$get_curve_geometry( msg = &msg1,
			     object_id = &CURVE,
			     md_env = &env,
                             curve_struct  = &bspline);      
      if ( 1 & msg1 & OMmsg)
      {
        j = 0;
      	printf("num_poles = %d\n", bspline->num_poles);

      	for (i=0; i< bspline->num_poles; i=i+1)
      	{
      	    printf("pole %d = %lf %lf %lf\n",
		j,bspline->poles[i*3],bspline->poles[i*3+1],
		bspline->poles[i*3+2]);
	    j = j+1;
      	}

      	for (i=0; i<bspline->num_knots; i=i+1)
      	{
            printf("knot %d = %lf \n",i,bspline->knots[i]);
      	}

        gr$free_curve( curve_struct = bspline);
     }

History:

	12/21/90	MAS	Creation
*/

#omdef gr$free_curve ( curve_struct)

#if (! om$specified(curve_struct))
#   omerror "Must specify curve_struct"
#else
    GRfree_curve((curve_struct));
#endif

#endomdef

/*
Name:
 	gr$place_linear_object
		       (msg,
			md_env=NULL,
			num_points,
			points,	       					
			object_id,
			name=NULL, 					
			display_flag=1)
 Abstract:

	This macro will create a linear object from the input
points. The type of object constructed depends on the number of points
that are input:
	number of points is 1, a point is created, 
	number of points is 2, a line segment is created, 
	number of points is greater than 2 a line string is created.

 Arguments:

 IGRint		*msg		O 	return message
					    MSSUCC - if successful
					    MSFAIL - if error occured
 struct GRmd_env *md_env	I	module environment
 IGRint 	num_points	I	number of points.
					    ( 1 means one (x,y,z) point)
 IGRdouble	*points		I	input array of points.
 struct GRid	*object_id	O	Output id. 
 IGRchar	*name 		I/O	name (optional)
					 if the name supplied has already
					  been used, a suffix will
					  be added to make the name unique
					  The new name will be returned
 IGRint		display_flag	I	display option.
					   0 - do not draw
					   1 - display object (default)

 Sample Call:

	IGRdouble	points[100],p2[3];
	IGRint	i,num_points,msg1;
	struct GRid linear_object;
	IGRchar	line_name[PATH_MAX];

	msg1= 1;
	num_points=0;

	for(i=0; msg1==1; i=i+3)
	{
 	    ci$get(point=p2 ,prompt="Enter point",rc=msg1);
	    if (msg1)
	    {
	      	points[i+0] = p2[0];
	      	points[i+1] = p2[1];
	      	points[i+2] = p2[2];
		num_points = num_points + 1;
	     }
	}

        strcpy(line_name,"linestring");

	gr$place_linear_object( 
		    msg = &msg1,
		    num_points  = 10,
		    points   = points,
		    object_id = &linear_object,         
		    name     = line_name, 
		    display_flag     = 1);

   Notes:	

	Be certain the name array is large enough in case the name must
be altered.  The dimension should be PATH_MAX (defined in DIdef.h).

History:

	12/21/90	MAS	Creation

*/

#omdef gr$place_linear_object
			(msg,
			md_env=NULL,
			num_points,	        			
			points,	       					
			object_id,
			name=NULL, 					
			display_flag = 1);

#if (! ( om$specified(msg) || om$specified(num_points) || om$specified(points)))
#  omerror "Must specify msg, num_points, points"
#else
   GRcreate_linestring((msg),(md_env),(num_points),(points),(object_id),(name),(display_flag));
#endif
#endomdef

/*
Name:
     gr$place_arc_by_edge_points
		    (msg,
		     md_env=NULL,
		     start_point,
		     dir_point,	       					
		     end_point,	       					
		     object_id,
		     name=NULL,
		     display_flag=1);

 Abstract:
	This macro will create an arc by three points on 
	the edge.

 Arguments:

 IGRint	        *msg		O	return value
					   MSSUCC - successful completion
					   MSFAIL - error
 struct GRmd_env *md_env	I	module environment
 IGRdouble	*start_point	I	input for start of arc.
 IGRdouble	*dir_point	I	input for direction point.
 IGRdouble	*end_point	I	input for end of arc.
 struct GRid	*object_id	O	Constructed object id.
 IGRchar	*name 		I/O	name (optional).
					 if the name supplied has already
					  been used, a suffix will
					  be added to make the name unique
					  The new name will be returned
 IGRint		display_flag	I	display option.
					   0 do not display
					   1 display object (default)
 Sample Call:

	IGRdouble		p1[3],p2[3],p3[3];
	struct GRid	object;
	IGRint		msg1;
        IGRchar 	arc_name[PATH_MAX];

  	ci$get(point=p1 ,prompt="identify point 1");
  	ci$get(point=p2 ,prompt="identify point 2");
  	ci$get(point=p3 ,prompt="identify point 3");

	strcpy(arc_name,"arc");

 	gr$place_arc_by_edge_points( 
		    msg = &msg1,
		    start_point   = p1,	        
		    dir_point   = p2,
		    end_point   = p3,
		    object_id = &object,
		    name     = arc_name,
		    display_flag = 1);     
Notes:

	Be certain the name array is large enough in case the name must
be altered.  The dimension should be PATH_MAX (defined in DIdef.h).

History:

	12/21/90	MAS	Creation

*/

#omdef gr$place_arc_by_edge_points
			(msg,
			md_env=NULL,
			start_point,
			dir_point,	 
			end_point,	 
			object_id,
			name=NULL,
			display_flag = 1);

#if (! (om$specified(start_point) || om$specified(dir_point) || om$specified(end_point) || om$specified(msg)))
#	omerror "Must specify msg, start_point dir_point, end_point"
#else
   GRcreate_conic_by_edge( (msg),(md_env),(1),(start_point),(dir_point),(end_point),
		(object_id),(name),(display_flag));
#endif

#endomdef

/*
Name:
     gr$place_arc_by_center
		    (msg,
		     md_env=NULL,
		     center,	  					
		     start_point,
		     end_point,	       					
		     window_id,
		     object_id,
		     name=NULL,
		     display_flag=1);

 Abstract:
	This macro will create a arc by three points on the edge.
Whether the arc has clockwise or counter clockwise sweep will be
determined by the value stored in the dpb for sweep angle.

	The window information is used to determine the rotation
matrix of the arc if it can not be determined from the 3 input
points.

 Arguments:

 IGRint	        *msg		O	return value
					   MSSUCC - successful completion
					   MSFAIL - error
 struct GRmd_env *md_env	I	module environment
 IGRdouble	*center		I	input for center of arc.
 IGRdouble	*start_point	I	input for start point.
 IGRdouble	*end_point	I	input for end of arc.
 struct GRid	*window_id	I	window to construct arc 
 struct GRid	*object_id	O	Constructed object id.
 IGRchar	*name 		I/O	name (optional).
					 if the name supplied has already
					  been used, a suffix will
					  be added to make the name unique
					  The new name will be returned
 IGRint		display_flag	I	display option.
					   0 do not display
					   1 display object (default)
 Sample Call:

	IGRdouble	p1[3],p2[3],p3[3];
	struct GRid	object,window_id;
	IGRint		msg1;
        IGRchar 	arc_name[PATH_MAX];

  	ci$get(point=p1 ,prompt="identify center",
	       window_id=&window_id.objid, 
	       window_osnum=&window_id.osnum);
  	ci$get(point=p2 ,prompt="identify start point");
  	ci$get(point=p3 ,prompt="identify end point ");

	strcpy(arc_name,"arc");

 	gr$place_arc_by_center( 
		    msg = &msg1,
		    center   = p1,	        
		    start_point   = p2,
		    end_point   = p3,
		    window_id = &window_id,
		    object_id = &object,
		    name     = arc_name,
		    display_flag     = 1);     
Notes:

	Be certain the name array is large enough in case the name must
be altered.  The dimension should be PATH_MAX (defined in DIdef.h).

History:

	12/21/90	MAS	Creation

*/

#omdef gr$place_arc_by_center
		    (msg,
		     md_env=NULL,
		     center,	  					
		     start_point,
		     end_point,	       					
		     window_id,
		     object_id,
		     name=NULL,
		     display_flag=1);

#if (! (om$specified(center) || om$specified(start_point) || om$specified(end_point) || om$specified(msg)))
#	omerror "Must specify msg, center, start_point, end_point"
#else
   GRcreate_conic_by_center( (msg),(md_env),(1),(center),(start_point),
	(end_point),(window_id),(object_id),(name),(display_flag));
#endif
#endomdef

/*
Name:
     gr$place_circle_by_edge_points
		    (msg,
		     md_env=NULL,
		     start_point,
		     dir_point,	       					
		     end_point,	       					
		     object_id,
		     name=NULL,
		     display_flag=1);

 Abstract:
	This macro will create an circle by three points on 
	the edge.

 Arguments:

 IGRint	        *msg		O	return value
					   MSSUCC - successful completion
					   MSFAIL - error
 struct GRmd_env *md_env	I	module environment
 IGRdouble	*start_point	I	input for start of circle.
 IGRdouble	*dir_point	I	input for direction point.
 IGRdouble	*end_point	I	input for 3rd point on circle.
 struct GRid	*object_id	O	Constructed object id.
 IGRchar	*name 		I/O	name (optional).
					 if the name supplied has already
					  been used, a suffix will
					  be added to make the name unique
					  The new name will be returned
 IGRint		display_flag	I	display option.
					   0 do not display
					   1 display object (default)
 Sample Call:

	IGRdouble		p1[3],p2[3],p3[3];
	struct GRid	object;
	IGRint		msg1;
        IGRchar 	circle_name[PATH_MAX];

  	ci$get(point=p1 ,prompt="identify point 1");
  	ci$get(point=p2 ,prompt="identify point 2");
  	ci$get(point=p3 ,prompt="identify point 3");

	strcpy(circle_name,"circle");

 	gr$place_circle_by_edge_points( 
		    msg = &msg1,
		    start_point   = p1,	        
		    dir_point   = p2,
		    end_point   = p3,
		    object_id = &object,
		    name     = circle_name,
		    display_flag = 1);     
Notes:

	Be certain the name array is large enough in case the name must
be altered.  The dimension should be PATH_MAX (defined in DIdef.h).

History:

	12/21/90	MAS	Creation

*/

#omdef gr$place_circle_by_edge_points
			(msg,
			md_env=NULL,
			start_point,
			dir_point,	 
			end_point,	 
			object_id,
			name=NULL,
			display_flag = 1);

#if (! (om$specified(start_point) || om$specified(dir_point) || om$specified(end_point) || om$specified(msg)))
#	omerror "Must specify msg, start_point dir_point, end_point"
#else
   GRcreate_conic_by_edge( (msg),(md_env),(0),(start_point),
		(dir_point),(end_point),(object_id),(name),
		(display_flag));
#endif

#endomdef

/*
Name:
     gr$place_circle_by_center
		    (msg,
		     md_env=NULL,
		     center,	  					
		     start_point,
		     dir_point,	       					
		     window_id,
		     object_id,
		     name=NULL,
		     display_flag=1);

 Abstract:
	This macro will create a circle by three points on the edge.
Whether the circle has clockwise or counter clockwise sweep will be
determined by the value stored in the dpb for sweep angle.

	The window information is used to determine the rotation
matrix of the circle if it can not be determined from the 3 input
points.

 Arguments:

 IGRint	        *msg		O	return value
					   MSSUCC - successful completion
					   MSFAIL - error
 struct GRmd_env *md_env	I	module environment
 IGRdouble	*center		I	input for center of circle.
 IGRdouble	*start_point	I	input for start point.
 IGRdouble	*dir_point	I	input for point on circle.
 struct GRid	*window_id	I	window to construct circle 
 struct GRid	*object_id	O	Constructed object id.
 IGRchar	*name 		I/O	name (optional).
					 if the name supplied has already
					  been used, a suffix will
					  be added to make the name unique
					  The new name will be returned
 IGRint		display_flag	I	display option.
					   0 do not display
					   1 display object (default)
 Sample Call:

	IGRdouble	p1[3],p2[3],p3[3];
	struct GRid	object,window_id;
	IGRint		msg1;
        IGRchar 	circle_name[PATH_MAX];

  	ci$get(point=p1 ,prompt="identify center",
	       window_id=&window_id.objid, 
	       window_osnum=&window_id.osnum);
  	ci$get(point=p2 ,prompt="identify start point");
  	ci$get(point=p3 ,prompt="identify end point ");

	strcpy(circle_name,"circle");

 	gr$place_circle_by_center( 
		    msg = &msg1,
		    center   = p1,	        
		    start_point   = p2,
		    dir_point   = p3,
		    window_id = &window_id,
		    object_id = &object,
		    name     = circle_name,
		    display_flag     = 1);     

Notes:

	Be certain the name array is large enough in case the name must
be altered.  The dimension should be PATH_MAX (defined in DIdef.h).

History:

	12/21/90	MAS	Creation

*/

#omdef gr$place_circle_by_center
		    (msg,
		     md_env=NULL,
		     center,	  					
		     start_point,
		     dir_point,	       					
		     window_id,
		     object_id,
		     name=NULL,
		     display_flag=1);

#if (! (om$specified(center) || om$specified(start_point) || om$specified(dir_point) || om$specified(msg)))
#	omerror "Must specify msg, center, start_point, dir_point"
#else
   GRcreate_conic_by_center( (msg),(md_env),(0),(center),(start_point),
	(dir_point),(window_id),(object_id),(name),(display_flag));
#endif

#endomdef

/*
Name:
	gr$place_curve_by_poles
			(msg,
			md_env=NULL,
			num_points=NULL,       				
			points=NULL,   					
			object_id=NULL,
			object_env=NULL,
			order    = 3,	        			
			periodic = 0,					
			name=NULL,
			new_id,
			display_flag=1)
 Abstract:

	This macro will create a curve by poles.

 Arguments:

 IGRint		*msg		O	completion code
					   MSSUCC- Successful completion
					   MSFAIL - error
 struct GRmd_env *md_env	I	module environment
 IGRint		num_points	I 	number of input points
					 (optional) 
 IGRdouble	*points		I	input points
					 (optional)
 struct GRid	*object_id	I	the curve to use for the fit
					 (optional) 
 struct GRmd_env *object_env	I	the enviornment for object_id
					 (optional)
 IGRint		order		I	order of curve (2-16)
 IGRshort	periodic	I   	periodic or not indicator
 struct GRid	*new_id		O	object id of constructed object
 IGRchar	*name		I/O	name (optional) 
					 if the name supplied has already
					  been used, a suffix will
					  be added to make the name unique
					  The new name will be returned
 IGRint		display_flag	I	display option.
					   0 do not display
					   1 display object (default)

 Sample Call:

	Example 1: To place the curve by input points:

	struct GRid	object,linear_object;
	struct GRmd_env env;
	IGRdouble	points[100], p2[3];
	IGRint		i,msg1,num_points,option;
 	IGRchar 	objects_name[PATH_MAX];

        strcpy(objects_name,"my_name");
	msg1 = 1;
	num_points=0;
	for(i=0; msg1==1; i=i+3)
	{
 	    ci$get(point=p2 ,prompt="Enter point",rc=msg1);
	    if (msg1)
	    {
	      	points[i+0] = p2[0];
	      	points[i+1] = p2[1];
	      	points[i+2] = p2[2];
		num_points = num_points + 1;
	     }
	}
	gr$place_curve_by_poles( 
		    msg = &msg1,
		    num_points  = num_points,
		    points   = points,
		    order = 4,
		    periodic = 0,
		    new_id = &object,
		    name     = objects_name,
		    display_flag     = 1);

	Example 2: 	To place the curve by input object:

	ci$locate( obj = &linear_object.objid,
	   	osnum = &linear_object.osnum,
		md_env = &env,
		prompt= "Identify object");

	gr$place_curve_by_poles( 
		    msg = &msg1,
		    object_id = &linear_object,
		    object_env = &env,
		    order = 4,
		    periodic = 0,
		    new_id = &object,
		    name     = objects_name,
		    display_flag     = 1);

Notes:

	Be certain the name array is large enough in case the name must
be altered.  The dimension should be PATH_MAX (defined in DIdef.h).

	Either num_points and points or object_id and object_env must be
specified.

History:

	12/21/90	MAS	Creation
*/

#omdef 	gr$place_curve_by_poles
			(msg,
			md_env=NULL,
			num_points=NULL,       				
			points=NULL,	       				
		        object_id = NULL,
			object_env = NULL,
			order    = 3,	        			
			periodic = 0,					
			new_id,
			name=NULL,
			display_flag=1)

#if (! (om$specified(msg) || om$specified(new_id)))
#   omerror "Must specify msg and new_id"
#else 
#   if (! ( (om$specified(num_points) && om$specified(points)) || (om$specified(object_id) && om$specified(object_env))))
#      omerror "Must specify num_points and points or object_id and object_env"
#   else
  	GRcreate_curve_by_option((msg),(md_env),(0),(0),(num_points),
		(points), (object_id),(object_env),(order),
		(periodic),(0),(0), (new_id),(name),(display_flag));
#   endif
#endif
#endomdef

/*
Name:
	gr$place_fitted_curve
			(msg,
			md_env=NULL,
			num_points,	       				
			points,	       					
			tolerance=NULL,
			object_id,
			object_env,
			order    = 3,	        			
			avg_error =NULL,
			max_error = NULL,
			new_id,
			name=NULL,
			display_flag=1)
 Abstract:

	This macro will create a curve via data reduction principles
such that the curve will lie within the input tolerance of the input
points.

 Arguments:

 IGRint		*msg		O	completion code
					   MSSUCC- Successful completion
					   MSFAIL - error
 struct GRmd_env *md_env	I	module environment
 IGRint		num_points	I 	number of input points
					 (optional) 
 IGRdouble	*points		I	input points
					 (optional)
 struct GRid	*object_id	I	the curve to use for the fit
					 (optional) 
 struct GRmd_env *object_env	I	the enviornment for object_id
					 (optional)
 IGRdouble	*tolerance	I	the tolerance for
					 determining how close the 
					 curve should lie to the 
					 input points (optional)
 IGRint		order		I	order of curve (2-16)
 IGRdouble	*avg_error	O	the average error of the fit
 					  (optional)
 IGRdouble	*max_error	O	the maximum error of the fit
 					  (optional)
 struct GRid	*new_id		O	object id of constructed object
 IGRchar	*name		I/O	name (optional) 
					 if the name supplied has already
					 been used, a suffix will
					 be added to make the name unique
					 The new name will be returned
 IGRint		display_flag	I	display option.
					   0 do not display
					   1 display object (default)
 Sample Call:

	Example 1: to place curve by input points:

	struct GRid	object,linear_obj;
	struct GRmd_env env;
	IGRdouble	points[100],p2[3],tolerance;
	IGRint		i,msg1,num_points,option;
 	IGRchar 	objects_name[PATH_MAX];
	IGRdouble	a,m;
	
	msg1 = 1;
	num_points=0;

    	ci$get(prompt = "enter tolerance",
	       value = tolerance);

    	strcpy(objects_name,"curve");

	for(i=0; msg1==1; i=i+3)
	{
 	    ci$get(point=p2 ,prompt="Enter point",rc=msg1);
	    if (msg1)
	    {
	      	points[i+0] = p2[0];
	      	points[i+1] = p2[1];
	      	points[i+2] = p2[2];
		num_points = num_points + 1;
	     }
	}

	gr$place_fitted_curve( 
		    msg = &msg1,
		    num_points  = num_points,
		    points   = points,
		    tolerance  = &tolerance,
		    order = 4,
		    avg_error = &a,
		    max_error = &m,
		    new_id = &object,
		    name     = objects_name,
		    display_flag     = 1);

	Example 2: To place curve using input object:

	ci$locate( obj = &linear_obj.objid,
	   	osnum = &linear_obj.osnum,
		md_env = &env,
		prompt= "Identify object");

	gr$place_fitted_curve( 
		    msg = &msg1,
		    object_id = &linear_obj,
		    object_env = &env,
		    order = 4,
		    avg_error = &a,
		    max_error = &m,
		    new_id = &object,
		    name     = objects_name,
		    display_flag     = 1);


Notes:

	Be certain the name array is large enough in case the name must
be altered.  The dimension should be PATH_MAX (defined in DIdef.h).

	If the tolerance is not specified, chord height tolerance
will be used.

	Either num_points and points or object_id and object_env must be
specified.

History:

	12/21/90	MAS	Creation

*/

#omdef 	gr$place_fitted_curve
			(msg,
			md_env=NULL,
			num_points=NULL,
			points=NULL,
			tolerance=NULL,
			object_id=NULL,
			object_env=NULL,
			order    = 3,	        			
			avg_error = NULL,
			max_error = NULL,
			new_id,
			name=NULL,
			display_flag=1)

#if (! (om$specified(msg) || om$specified(new_id)))
#   omerror "Must specify msg and new_id"
#else 
#   if (! ( (om$specified(num_points) && om$specified(points)) || (om$specified(object_id) && om$specified(object_env))))
#      omerror "Must specify num_points and points or object_id and object_env"
#   else
  	GRcreate_curve_by_option((msg),(md_env),(1),(tolerance),
		(num_points),(points),(object_id),(object_env),
		(order),(0),(avg_error),(max_error),(new_id),(name),
		(display_flag));
#   endif
#endif

#endomdef

#endif
