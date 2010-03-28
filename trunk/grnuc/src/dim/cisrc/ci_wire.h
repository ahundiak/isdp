#ifndef ci_wire_include
#define ci_wire_include

extern int	BSac2eptscr(),
		BScirc3pts(),
		BSarc3pts(),
		BSac2eptscr(),
		BSac2ptctvc();
extern int BShelix1();

/***************************************************************************/
/************ DEFINE THE EASY MACROS HERE **********************************/
/***************************************************************************/


/*---------------------- gr$get_linear_info ---------------------------
#omdef gr$get_linear_info
		(GRid_in  = TEMP_GRID ,
		 linear_struct,
		 md_env = MOD_ENV)				
 Abstract:

	This macro will fill the linear structure of the input linear id.
	This macro will return data about Points, Lines, and Linestrings.

 Arguments:

	GRid_in		I	struct GRid	input linear id

	linear_struct	O	struct IGRpolyline	output linear 
							structure, this
							structure is defined 
							in "igr.h"

	md_env		I	struct GRmd_env input module environment, this
						is only need if the linear resides
						in a reference file and you 
						want the local information.

 Sample Call:

main()
{
	int		i;
	struct GRid	CURVE;
	struct IGRpolyline	linear;	// structure defined in igr.h

   message("get linear info");

   while(1)
   {   

	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   classes = "GRlinear",
		   md_env = &MOD_ENV,
		   prompt= "Identify linear to get info from");

	gr$get_linear_info( GRid_in =CURVE,
			 linear_struct = linear,
			 md_env = MOD_ENV);

	write("linear stuff\nnumber of points=",linear.num_points,"\npoints\n");
	for(i=0;i<linear.num_points*3; i=i+3)
	{
	  write(linear.points[i],linear.points[i+1],linear.points[i+2],'\n');
	}
  }
}

 Notes:

	If the module environment is left out and the linear resides in a reference
	file the output will be in the coordinates in the reference file and
	not in the active file.

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/
#omdef gr$get_linear_info
		(GRid_in  = TEMP_GRID ,
		 linear_struct,
		 md_env = MOD_ENV)				


#if   !om$specified(md_env)
	ci$get_module_info( md_env = &MOD_ENV);
	get_linear_info( GRid_in, linear_struct, MOD_ENV);
#else
	get_linear_info( GRid_in, linear_struct, md_env);
#endif
#endomdef

/*---------------------- gr$get_arc_info ---------------------------
#omdef gr$get_arc_info
		(GRid_in  = TEMP_GRID ,
		 arc_struct,
		 md_env = MOD_ENV)				
 Abstract:

	This macro will fill the arc structure of the input arc id.

 Arguments:

	GRid_in		I	struct GRid	input arc id

	arc_struct	O	struct IGRarc	output arc structure, this
						structure is defined in "igr.h"

	md_env		I	struct GRmd_env input module environment, this
						is only need if the arc resides
						in a reference file and you 
						want the local information.

 Sample Call:

main()
{
	struct GRid	CURVE;
	struct IGRarc	arc;	// structure defined in igr.h

   message("get arc info");

   while(1)
   {   

	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   classes = "GRconic",
		   md_env = &MOD_ENV,
		   prompt= "Identify arc to get info from");

	gr$get_arc_info( GRid_in =CURVE,
			 arc_struct = arc,
			 md_env = MOD_ENV);

	write("arc stuff\norigin",arc.origin,"\nradius=",arc.prim_axis,'\n');
  }
}

 Notes:

	If the module environment is left out and the arc resides in a reference
	file the output will be in the coordinates in the reference file and
	not in the active file.

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/
#omdef gr$get_arc_info
		(GRid_in  = TEMP_GRID ,
		 arc_struct,
		 md_env = MOD_ENV)				


#if   !om$specified(md_env)
	ci$get_module_info( md_env = &MOD_ENV);
	get_arc_info( GRid_in, arc_struct, MOD_ENV);
#else
	get_arc_info( GRid_in, arc_struct, md_env);
#endif
#endomdef


/*---------------------- gr$get_circle_info ---------------------------
#omdef gr$get_circle_info
		(GRid_in  = TEMP_GRID ,
		 circle_struct,
		 md_env = MOD_ENV)				
 Abstract:

	This macro will fill the ellipse structure of the input circle id.
	This macro will handle ellipses and circles.	

 Arguments:

	GRid_in		I	struct GRid	input circle id

	circle_struct	O	struct IGRellipse	output circle 
							structure, this
							structure is defined 
							in "igr.h"

	md_env		I	struct GRmd_env input module environment, this
						is only need if the circle resides
						in a reference file and you 
						want the local information.

 Sample Call:

main()
{
	struct GRid	CURVE;
	struct IGRellipse	circle;	// structure defined in igr.h

   message("get circle info");

   while(1)
   {   

	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   classes = "GRconic",
		   md_env = &MOD_ENV,
		   prompt= "Identify circle to get info from");

	gr$get_circle_info( GRid_in =CURVE,
			 circle_struct = circle,
			 md_env = MOD_ENV);

	write("circle stuff\norigin",circle.origin,"\nradius=",circle.prim_axis,'\n');
  }
}

 Notes:

	If the module environment is left out and the circle resides in a reference
	file the output will be in the coordinates in the reference file and
	not in the active file.
	This macro will handle circles and ellipses.

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/
#omdef gr$get_circle_info
		(GRid_in  = TEMP_GRID ,
		 circle_struct,
		 md_env = MOD_ENV)				


#if   !om$specified(md_env)
	ci$get_module_info( md_env = &MOD_ENV);
	get_arc_info( GRid_in, circle_struct, MOD_ENV);
#else
	get_arc_info( GRid_in, circle_struct, md_env);
#endif
#endomdef




/*---------------------- gr$reverse_curve ---------------------------
#omdef gr$reverse_curve
			(GRid_in  = TEMP_GRID )				

 Abstract:

	This macro will change the direction of the input curve.

 Arguments:

	GRid_in		I	struct GRid	input curve id

 Sample Call:

	struct GRid 	CURVE;

   	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   prompt= "Identify curve");

	gr$reverse_curve(GRid_in  = CURVE );

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/
#omdef gr$reverse_curve(GRid_in  = TEMP_GRID )				

reverse_curve(GRid_in);
#endomdef


/*---------------------- gr$get_endpoints ---------------------------------

#omdef gr$get_endpoints
			(GRid_in  = TEMP_GRID,				
			point1,						
			point2)						

 Abstract:

	This macro will return the endpoints of any curve/line/point/arc
	into point1 and point2.

 Arguments:

	GRid_in		I	struct GRid	input id of curve.

	point1		O	double[3]	output start point.

	point2		O	double[3]	output end point.

 Sample Call:

	struct GRid 	CURVE;
	double		p1[3], p2[3];

   	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   prompt= "Identify curve");

 	gr$get_endpoints( GRid_in  = TEMP_GRID,	
			  point1   = p1,		
			  point2   = p2);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$get_endpoints(GRid_in  = TEMP_GRID,				
			point1,						
			point2)						

get_endpoints(GRid_in,point1,point2);
#endomdef


/*---------------------- gr$project_point_along_vector --------------------

#omdef gr$project_point_along_vector
			(GRid_in  = TEMP_GRID,	
			point1,		
			point2,		
			point3,		
			u_value = double_1,	
			v_value = double_2)
 Abstract:

	This macro will project the input point onto the input object
	along a vector.

 Arguments:
	GRid_in		I	struct GRid	input object id for point to
						be projected onto.

	point1		I	double[3]	start point of projection vector.
	
	point2		I	double[3]	end point of projection vector.

	point3		O	double[3]	returned point on element.

	u_value		O	double		output u value of object.

	v_value		O	double		output v value of object. 	

 Sample Call:

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$project_point_along_vector
			(GRid_in  = TEMP_GRID,
			point1,
			point2,
			point3,
			GRid_out = TEMP_GRID_NEW,
			u_value = double_1,
			v_value = double_2,
			polygon_inx = U_per)

project_point_along_vector(GRid_in,point1,point2,point3,GRid_out,u_value,v_value,polygon_inx);
#endomdef

struct IGRbsp_curve 	*bspline_curvep;


/*---------------------- gr$get_curve_geometry ----------------------

#omdef gr$get_curve_geometry
			(GRid_in      = TEMP_GRID,			
			curve_struct = bspline_curvep) 			

 Abstract:

	This macro will return the bspline geometry for use.

 Arguments:

	GRid_in		I	struct GRid	input curve

	curve_struct	O	struct IGRbsp_curve	output curve structure

 Sample Call:

	struct GRid 	CURVE;

   	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   prompt= "Identify curve");

 	gr$get_curve_geometry( GRid_in      = CURVE,			
			       curve_struct = bspline_curvep);			

	write("pole1=",bspline_curvep->poles[0],bspline_curvep->poles[1],
			bspline_curvep->poles[2],'\n');

	gr$free_curve( curve_struct = bspline_curvep);

 Notes:

	use gr$free_curve() to free up the memory that has been alocated.
	
 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$get_curve_geometry
			(GRid_in      = TEMP_GRID,			
			curve_struct = bspline_curvep) 			
get_curve_geometry(GRid_in,curve_struct);
#endomdef


/*---------------------- gr$put_curve_geometry ----------------------------

#omdef gr$put_curve_geometry(
			GRid_in   	= TEMP_GRID,	
			curve_struct 	= bspline_curvep,
			disp 		= DRAW)

 Abstract:

	This macro will put back curve geometry into the GRid_in id.

 Arguments:

	GRid_in		I	struct GRid	Input curve GRid

	curve_struct	I	struct IGRbsp_curve 	Input curve structure
							pointer. 

	disp		I	int		Input display identifier.

 Sample Call:

	struct GRid	CURVE;
	int		i;

   	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   classes = "GRcurve",
		   prompt= "Identify curve to modify");

	gr$get_curve_geometry(
			GRid_in    = CURVE,
			curve_struct = bspline_curvep);

	for( i=0; i<bspline_curvep->num_poles*3; i=i+3)
	{
		bspline_curvep->poles[i] = bspline_curvep->poles[i]/2; 
	}	

	 gr$put_curve_geometry(
			GRid_in   	= CURVE,	
			curve_struct 	= bspline_curvep,
			disp 		= DRAW);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/
#omdef gr$put_curve_geometry(
			GRid_in   	= TEMP_GRID,	
			curve_struct 	= bspline_curvep,
			disp 		= DRAW)

put_curve_geometry((GRid_in), (curve_struct), (disp));
#endomdef


/*----------------------  gr$free_curve ---------------------------

#omdef gr$free_curve
			( curve_struct = bspline_curvep) 		

 Abstract:

	This macro will free up the memory that was allocated by the
	gr$get_curve_geometry() macro.

 Arguments:

	curve_struct 		I	struct IGRbspline_curve	input structure
								to free up.

 Sample Call:

	struct GRid 	CURVE;

   	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   prompt= "Identify curve");

 	gr$get_curve_geometry( GRid_in      = CURVE,			
			       curve_struct = bspline_curvep);			

	write("pole1=",bspline_curvep->poles[0],bspline_curvep->poles[1],
			bspline_curvep->poles[2],'\n');

	gr$free_curve( curve_struct = bspline_curvep);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$free_curve
			( curve_struct = bspline_curvep) 		

 free((curve_struct));
#endomdef



/*---------------------- gr$place_point ---------------------------------

#omdef gr$place_point(
			point1,						
			weight = 3,	        			
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				
 Abstract:

	This macro will create a point.

 Arguments:

	point1		I	double[3]	input location for point.

	weight		I	int		input size of point.

	GRid_out	O	struct GRid	Output id.

	name 		I	char		name.

	disp		I	int		display option.

 Sample Call:

	double		p1[3];
	struct GRid	POINT;

	message("create easy point");

  	ci$get(point=p1 ,prompt="identify point1");

	gr$set_symbology(color = green, level = 11);

	gr$place_point(point1   = p1,
		    GRid_out = POINT, 
		    name     = "point",
		    disp     = 0);

	gr$reset_symbology();

	THIS IS THE MINIMUM INPUT
	place$point(point1=p1);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$place_point
			(point1,						
			weight = 3,	        			
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				

   create_point( (point1),(weight),(GRid_out),(name),(disp));
#endomdef



/*---------------------- gr$place_line ---------------------------------

#omdef gr$place_line(
			point1,	        				
			point2,	       					
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				
 Abstract:

	This macro will create a line given two points.

 Arguments:

	point1		I	double[3]	input location for point 1.

	point2		I	double[3]	input location for point 2.

	GRid_out	O	struct GRid	Output id.

	name 		I	char		name.

	disp		I	int		display option.

 Sample Call:

	double		p1[3], p2[3];

	struct GRid	LINE;

	message("create easy line");
  	ci$get(point=p1 ,prompt="identify point1");
  	ci$get(point=p2 ,prompt="identify point2");
	gr$set_symbology(co = cyan,lv = 6);
	gr$place_line( 
		    point1   = p1,
		    point2   = p2,
		    GRid_out = LINE,	// this is opt, def = TEMP_GRID
		    name     = "line",	// this is opt, def = no name
		    disp     = 0);	// this is opt, def = 0-dis 1-no dis
	gr$reset_symbology();


	THIS IS THE MINIMUM INPUT
	gr$place_line(point1=p1, point2=p2);


 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/
#omdef gr$place_line
			(point1,	        				
			point2,	       					
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				

   create_line( (point1),(point2),(GRid_out),(name),(disp));

#endomdef

/*---------------------- gr$place_linestring ---------------------------------

#omdef gr$place_linestring
			(num_points,	        			
			points,	       					
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				
 Abstract:

	This macro will create a linestring from a set of input
	points.

 Arguments:

	num_points		I	int		input number of points.

	points		I	double		input array of input points.

	GRid_out	O	struct GRid	Output id.

	name 		I	char		name.

	disp		I	int		display option.

 Sample Call:

	double	points[100], num_of_points;
	int	i;

	message("create easy linestring");

	for(i=0; i<30; i=i+3)
	{
  	  ci$get(point=p2 ,prompt="identify point");
	  points[i+0] = p2[0];
	  points[i+1] = p2[1];
	  points[i+2] = p2[2];
	}

	gr$place_linestring( 
		    num_points  = 10,
		    points   = points,
		    GRid_out = LINE,         
		    name     = "linestring", 
		    disp     = DRAW);

	THIS IS THE MINIMUM INPUT
	gr$place_linestring(num_points=10, points=points);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/
#omdef gr$place_linestring
			(num_points,	        			
			points,	       					
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				

   create_linestring( (num_points),(points),(GRid_out),(name),(disp));
#endomdef

/*---------------------- gr$place_arc_edge -------------------

#omdef gr$place_arc_edge
			(point1,	  					
			point2,	       					
			point3,	       					
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				

 Abstract:

	This macro will create a arc by three points on the edge.

 Arguments:

	point1		I	double[3]	input for start of arc.

	point2		I	double[3]	input for interior point.

	point3		I	double[3]	input for end of arc.

	GRid_out	O	struct GRid	Output id.

	name 		I	char		name.

	disp		I	int		display option.

 Sample Call:

	double		p3[3];
	struct GRid	ARC;

	message("create easy arc by edge");
  	ci$get(point=p1 ,prompt="identify point 1");
  	ci$get(point=p2 ,prompt="identify point 2");
  	ci$get(point=p3 ,prompt="identify point 3");
 	gr$place_arc_edge( 
		    point1   = p1,	        
		    point2   = p2,
		    point3   = p3,
		    GRid_out = ARC,    	// this is opt, def = TEMP_GRID
		    name     = "arc",   // this is opt, def = no name
		    disp     = 0);     	// this is opt, def = 0-dis 1-no dis

	THIS IS THE MINIMUM INPUT
	gr$place_arc_edge(point1=p1, point2=p2, point3=p3);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$place_arc_edge
			(point1,	  					
			point2,	       					
			point3,	       					
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				

   create_arc_by_edge( (point1),(point2),(point3),(GRid_out),(name),(disp));
#endomdef



/*---------------------- gr$place_arc_center -----------------------

#omdef gr$place_arc_center(
			point1,				    
			point2,	      					
			point3,	       					
			GRid_out = TEMP_GRID,	       			
			dir  = 0, 					
			name = "0", 					
			disp = DRAW)      				
 Abstract:

	This macro creates an arc by center and 2 points.

 Arguments:

	point1		I	double[3]	input for center of arc.

	point2		I	double[3]	input for start point.

	point3		I	double[3]	input for end of arc.

	dir		I	int		TRUE if arc is greater than
						180 deg. FALSE is less than
						180 deg.

	GRid_out	O	struct GRid	Output id.

	name 		I	char		name.

	disp		I	int		display option.

 Sample Call:


	double		p3[3];
	struct GRid	ARC;

	message("create easy arc by edge");
  	ci$get(point=p1 ,prompt="identify center");
  	ci$get(point=p2 ,prompt="identify point 2");
  	ci$get(point=p3 ,prompt="identify point 3");

 	gr$place_arc_center( 
		    point1   = p1,	        
		    point2   = p2,
		    point3   = p3,
		    dir      = 0,	
		    GRid_out = ARC,    	
		    name     = "arc",   
		    disp     = DRAW);

	THIS IS THE MINIMUM INPUT
	gr$place_arc_center(point1=p1, point2=p2, point3=p3);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$place_arc_center
			(point1,	    					    
			point2,	      					
			point3,	       					
			GRid_out = TEMP_GRID,	       			
			dir  = 0, 					
			name = "0", 					
			disp = DRAW)      				

   create_arc_by_center((point1),(point2),(point3),(dir),(GRid_out),(name),(disp));
#endomdef


/*---------------------- gr$place_circle_edge ----------------------

#omdef gr$place_circle_edge
			(point1,	        				
			point2,	       					
			point3,	       					
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				
 Abstract:

	This macro will create a circle by three points on the circle.

 Arguments:

	point1		I	double[3]	input for start of circle.

	point2		I	double[3]	input for interior point.

	point3		I	double[3]	input for 3rd point on edge
						of circle.

	GRid_out	O	struct GRid	Output id.

	name 		I	char		name.

	disp		I	int		display option.


 Sample Call:


	double		p3[3];
	struct GRid	CIRCLE;

	message("create easy circle by edge");
  	ci$get(point=p1 ,prompt="identify point 1");
  	ci$get(point=p2 ,prompt="identify point 2");
  	ci$get(point=p3 ,prompt="identify point 3");
 	gr$place_circle_edge( 
		    point1   = p1,	        
		    point2   = p2,
		    point3   = p3,
		    GRid_out = CIRCLE,   
		    name     = "circle",
		    disp     = DRAW); 

	THIS IS THE MINIMUM INPUT
	gr$place_circle_edge(point1=p1, point2=p2, point3=p3);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/
#omdef gr$place_circle_edge
			(point1,	        				
			point2,	       					
			point3,	       					
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				

   create_cir_by_edge( (point1),(point2),(point3),(GRid_out),(name),(disp));
#endomdef


/*---------------------- gr$place_circle_center ------------------

#omdef gr$place_circle_center
			(point1,	        				
			point2,	       					
			point3,	  						
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				
 Abstract:

	This macro will create a circle by center and 2 points.

 Arguments:

	point1		I	double[3]	input for center of circle.

	point2		I	double[3]	input for edge point 1.

	point3		I	double[3]	input for 2nd point on edge
						of circle.

	GRid_out	O	struct GRid	Output id.

	name 		I	char		name.

	disp		I	int		display option.


 Sample Call:

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$place_circle_center
			(point1,	        				
			point2,	       					
			point3,	  						
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				

   create_cir_by_center((point1),(point2),(point3),(GRid_out),(name),(disp));
#endomdef


/*---------------------- gr$place_curve_poles_p -----------------

#omdef gr$place_curve_poles_p
			(num_points,	       				
			points,	       					
			GRid_out = TEMP_GRID,				
			order    = 3,	        			
			periodic = 0,					
			name     = "0", 				
			disp     = DRAW)      				

 Abstract:

	This macro will create a curve by poles.

 Arguments:

	order	       	I  	int		curve order  

	num_points	I   	int  		number of input points 

	points	       	I	double		input points 

	periodic	I	short   	periodic or not

	GRid_out	O	struct GRid 	id of the line

	name		I  	char 		optional name for object

	disp		I	int  		display option.

 Sample Call:

struct GRid	LINE;
double	points[100], num_of_points;
int	i;

	message("create easy curve by poles");

	for(i=0; i<30; i=i+3)
	{
  	  ci$get(point=p2 ,prompt="identify point");
	  points[i+0] = p2[0];
	  points[i+1] = p2[1];
	  points[i+2] = p2[2];
	}

	gr$place_curve_poles_p( 
		    num_points  = 10,
		    points   = points,
		    GRid_out = LINE,        
		    name     = "curve", 
		    disp     = DRAW);

	THIS IS THE MINIMUM INPUT
	gr$place_curve_poles_p(num_points=10, points=points);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$place_curve_poles_p
			(num_points,	       				
			points,	       					
			GRid_out = TEMP_GRID,				
			order    = 3,	        			
			periodic = 0,					
			name     = "0", 				
			disp     = DRAW)      				

 create_curve_by_poles(order,num_points,points,periodic,GRid_out,name,disp);
#endomdef



/*---------------------- gr$place_dir_fit_curve_p ------------------------

#omdef gr$place_dir_fit_curve_p(
			num_points,	       				
			points,	       					
			GRid_out = TEMP_GRID,				
			order    = 3,	        			
			periodic = 0,					
			name     = "0", 				
			disp     = DRAW)      				
 Abstract:

	This macro will create a curve by direct fit to points.

 Arguments:

	num_points	I   	int  		number of input points 

	points	       	I	double		input points 

	GRid_out	O	struct GRid 	id of the line

	order	       	I  	int		curve order  

	periodic	I	short   	periodic or not

	name		I  	char 		optional name for object

	disp		I	int  		display option.

 Sample Call:


struct GRid	LINE;
double	points[100], num_of_points;
int	i;

	message("create easy curve by direct fit points");

	for(i=0; i<30; i=i+3)
	{
  	  ci$get(point=p2 ,prompt="identify point");
	  points[i+0] = p2[0];
	  points[i+1] = p2[1];
	  points[i+2] = p2[2];
	}

	gr$place_dir_fit_curve_p( 
		    num_points  = 10,
		    points   = points,
		    GRid_out = LINE,        
		    name     = "curve", 
		    disp     = DRAW);

	THIS IS THE MINIMUM INPUT
	gr$place_dir_fit_curve_p(num_points=10, points=points);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$place_dir_fit_curve_p
			(num_points,	       				
			points,	       					
			GRid_out = TEMP_GRID,				
			order    = 3,	        			
			periodic = 0,					
			name     = "0", 				
			disp     = DRAW)      				

create_dir_fit_curve((order),(num_points),(points),(periodic),(GRid_out),(name),(disp));
#endomdef


/*---------------------- gr$place_helix ------------------------

#omdef gr$place_helix(	point1,
			point2,
			point3,
			start_radius = 1,
			end_radius = -1,
			pitch_gap = 1,
			direction = 0,
			num_pitches = 0,
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				
			
 Abstract:
	This macro will create a helix from the set of inputs.

 Arguments:
	point1		I	double[3]	axis point 1 for the helix

	point2		I	double[3]	axis point 2 for the helix

	point3		I	double[3]	start point for the helix

	start_radius	I	double		starting radius must be > 0.

	end_radius	I	double		ending radius. If end_radius
						is < 0 end_radius = start_radius

	pitch_gap	I	double		distance for 1 revolution

	direction	I	int		clockwise=0/counter clockwise=1

	num_pitches	I	int		number of full revolutions,
						if num_pitches = 0, then the
						helix will go the distance 
						between point1 and point2.

	GRid_out	O	struct GRid	output object id for the helix.

	name		I  	char 		optional name for object

	disp		I	int  		display option.

 Sample Call:

#include "ci_easy.h"
#include "ci_wire.h"
main()
{
	double	p1[3], p2[3], p3[3], sr, er, dir, pg, np;
	char	name[132];
	struct GRid	HELIX;

	ci$get(string = name, prompt="key in name for helix");
	ci$get(value = sr, prompt="key in start radius");
	ci$get(value = er, prompt="key in end radius");
	ci$get(value = dir, prompt="key in direction 0/1");
	ci$get(value = pg, prompt="key in pitch gap");
	ci$get(value = np, prompt="key in number of pitches");

	while(1)
	{
		ci$get(point = p1, prompt="identify axis point 1");
		ci$get(point = p2, prompt="identify axis point 2");
		ci$get(point = p3, prompt="identify start point 3");

 		gr$place_helix(	
			point1 = p1,
			point2 = p2,
			point3 = p3,
			start_radius = sr,
			end_radius = er,
			pitch_gap= pg,
			direction = dir,
			num_pitches = np,
			GRid_out = HELIX,	       			
			name = name, 					
			disp = DRAW);
		
	}
}

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$place_helix(	point1,
			point2,
			point3,
			start_radius = 1,
			end_radius = -1,
			pitch_gap = 1,
			direction = 0,
			num_pitches = 0,
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				

  create_helix( point1,point2,point3, start_radius, end_radius, pitch_gap,num_pitches,direction,GRid_out,name,disp);

#endomdef

/*---------------------- gr$make_composite_curve ------------------------*/

#omdef gr$make_composite_curve(
			GRids_in,
			GRid_out,
			name     = "0", 				
			disp     = DRAW)      				

 make_comp_curve( (GRids_in), (GRid_out), (name), (disp));			
#endomdef






/*******
THESE ARE THE SUPPORTING FUNCTIONS FOR EACH OF THE ABOVE
MACROS. THESE ARE SUBJECT TO CHANGE SO I DON'T RECOMEND
THE COPYING OF THE CODE BELOW FOR USE.
*******/

// GET ARC INFORMATION

#define get_arc_info(object,struct,mod_env)\
ci$send(msg = message GRconic.GRgetarc( &rtcd,&(mod_env).md_env.matrix_type, (mod_env).md_env.matrix,&(struct) ), targetid = (object).objid, targetos = (object).osnum);

// GET LINEAR INFORMATION
int	Action;

#define get_linear_info(object,struct,mod_env)\
\
Action = 0;\
ci$send(msg = message GRlinear.GRgetpolyline(\
	&rtcd,\
	&(mod_env).md_env.matrix_type, \
	(mod_env).md_env.matrix,\
	&Action,\
	&(struct) ), \
	targetid = (object).objid, \
	targetos = (object).osnum);\
(struct).points = (IGRdouble *) malloc( (struct).num_points * 3 * sizeof(IGRdouble));\
Action = 1;\
ci$send(msg = message GRlinear.GRgetpolyline(\
	&rtcd,\
	&(mod_env).md_env.matrix_type, \
	(mod_env).md_env.matrix,\
	&Action,\
	&(struct) ), \
	targetid = (object).objid, \
	targetos = (object).osnum);


// CREATE POINT WITH NAME AND DISPLAY INCLUDED
struct IGRpolyline      polyline;

#define create_point(p1,weig,object,name,disp)\
\
	set_up_easy();\
	dis.weight = dis.weight + (weig);\
        for(loop_inc=0;loop_inc<3;loop_inc=loop_inc+1)\
	{\
	 double6[loop_inc+0] = (p1)[loop_inc];\
	 double6[loop_inc+3] = (p1)[loop_inc];\
	}\
\
	polyline.points=double6;\
  	polyline.num_points = 2;\
  	cst.geometry = (char *)&polyline;\
        (object).objid = NULL_OBJID;\
  	(object).osnum = MOD_ENV.md_id.osnum;\
\
        ci$send(msg= message GR3dpoint.GRaltconstruct(\
		&cst),\
		targetid = (object).objid,\
		targetos = (object).osnum,\
                construct = 1 );\
\
	dis.weight = dis.weight - (weig);\
        cst.geometry   = 0;\
	name_display((object), (name), (disp));

// CREATE LINE WITH NAME AND DISPLAY INCLUDED

#define create_line(p1,p2,object,name,disp)\
\
	set_up_easy();\
        for(loop_inc=0;loop_inc<3;loop_inc=loop_inc+1)\
	{\
	 double6[loop_inc+0] = (p1)[loop_inc];\
	 double6[loop_inc+3] = (p2)[loop_inc];\
	}\
\
	polyline.points=double6;\
  	polyline.num_points = 2;\
  	cst.geometry = (char *)&polyline;\
        (object).objid = NULL_OBJID;\
  	(object).osnum = MOD_ENV.md_id.osnum;\
\
        ci$send(msg= message GR3dlineseg.GRaltconstruct(\
		&cst),\
		targetid = (object).objid,\
		targetos = (object).osnum,\
                construct = 1 );\
\
        cst.geometry   = 0;\
	name_display((object), (name), (disp));

// CREATE LINESTRING WITH NAME AND DISPLAY INCLUDED

struct IGRpolyline      line_string;

#define create_linestring(num,pts,object,name,disp)\
\
   set_up_easy();\
\
   line_string.num_points = (num);\
   line_string.points = (IGRdouble *) malloc((num) * 3 * sizeof(IGRdouble));\
   for(loop_inc = 0; loop_inc < (num)*3; loop_inc = loop_inc + 3)\
   {\
	line_string.points[loop_inc+0] = (pts)[loop_inc+0];\
	line_string.points[loop_inc+1] = (pts)[loop_inc+1];\
	line_string.points[loop_inc+2] = (pts)[loop_inc+2];\
   }\
\
  	cst.geometry = (char *)&line_string;\
        (object).objid = NULL_OBJID;\
  	(object).osnum = MOD_ENV.md_id.osnum;\
\
        ci$send(msg= message GR3dlinestr.GRaltconstruct(\
		&cst),\
		targetid = (object).objid,\
		targetos = (object).osnum,\
                construct = 1 );\
\
   	free(line_string.points);\
        cst.geometry   = 0;\
	name_display((object), (name), (disp));

// CREATE ARC BY EDGE WITH NAME AND DISPLAY INCLUDED
struct IGRbsp_curve     bspline_curve;

#define create_arc_by_edge(p1,p2,p3,object,name,disp)\
\
	set_up_easy();\
\
   	bspline_curve.poles   = &double100[0];\
   	bspline_curve.knots   = &double100[21];\
   	bspline_curve.weights = &bspline_curve.knots[10];\
\
   	BSarc3pts(	&rtcd,(p1),(p2),(p3),&bspline_curve );\
\
   	cst.geometry   = (char *)&bspline_curve;\
   	(object).objid = NULL_OBJID;\
   	(object).osnum = MOD_ENV.md_id.osnum;\
\
   	rtcd = ci$send(msg = message GR3dcirarc.GRconstruct(\
		&cst),\
	        targetid = (object).objid,\
	        targetos = (object).osnum);\
\
   	cst.geometry   = 0;\
	name_display((object), (name), (disp));

// CREATE ARC BY CENTER WITH NAME AND DISPLAY INCLUDED
double		normal_vector[3], Tem1[3],Tem2[3],Tem3[3];
int		direction;
IGRboolean	Direction;

#define create_arc_by_center(p1,p2,p3,dir,object,name,disp)\
\
	set_up_easy();\
\
   	bspline_curve.poles   = &double100[0];\
   	bspline_curve.knots   = &double100[21];\
   	bspline_curve.weights = &bspline_curve.knots[10];\
\
   	if( (dir) < 1) Direction = 0;\
   	if( (dir) > 0) Direction = 1; \
\
	v_sub(p2,p1,Tem1);\
	v_sub(p3,p1,Tem2);\
	v_cross(Tem1,Tem2,Tem3);\
	v_scale(Tem3,1/v_len(Tem3),normal_vector);\
\
   	BSac2ptctvc( (p2),(p1),(p3),normal_vector, Direction,\
		&bspline_curve, &rtcd );\
\
   	cst.geometry   = (char *)&bspline_curve;\
   	(object).objid = NULL_OBJID;\
   	(object).osnum = MOD_ENV.md_id.osnum;\
\
   	rtcd = ci$send(msg = message GR3dcirarc.GRconstruct(\
		&cst),\
	        targetid = (object).objid,\
	        targetos = (object).osnum);\
\
   	cst.geometry   = 0;\
	name_display((object), (name), (disp));

/*
   	BSac2eptscr(	&rtcd,(p2),(p1),(p3),\
		normal_vector,&direction,&bspline_curve );\
*/
// CREATE CIRCLE BY EDGE WITH NAME AND DISPLAY INCLUDED

#define create_cir_by_edge(p1,p2,p3,object,name,disp)\
\
	set_up_easy();\
\
   	bspline_curve.poles   = &double100[0];\
   	bspline_curve.knots   = &double100[21];\
   	bspline_curve.weights = &bspline_curve.knots[10];\
\
	BScirc3pts(&rtcd,(p1),(p2),(p3),&bspline_curve);\
\
   	cst.geometry   = (char *)&bspline_curve;\
   	(object).objid = NULL_OBJID;\
   	(object).osnum = MOD_ENV.md_id.osnum;\
\
   	rtcd = ci$send(msg = message GR3dellipse.GRconstruct(\
		&cst),\
	        targetid = (object).objid,\
	        targetos = (object).osnum);\
\
   	cst.geometry   = 0;\
	name_display((object), (name), (disp));

// CREATE CIRCLE BY CENTER AND 2 POINTS WITH NAME AND DISPLAY INCLUDED

#define create_cir_by_center(p1,p2,p3,object,name,disp)\
\
	set_up_easy();\
\
   	bspline_curve.poles   = &double100[0];\
   	bspline_curve.knots   = &double100[21];\
   	bspline_curve.weights = &bspline_curve.knots[10];\
\
   	Direction = 0;\
\
	v_sub(p2,p1,Tem1);\
	v_sub(p3,p1,Tem2);\
	v_cross(Tem1,Tem2,Tem3);\
	v_scale(Tem3,1/v_len(Tem3),normal_vector);\
\
   	BSac2ptctvc( (p2),(p1),(p3),normal_vector, Direction,\
		&bspline_curve, &rtcd );\
\
   	cst.geometry   = (char *)&bspline_curve;\
   	(object).objid = NULL_OBJID;\
   	(object).osnum = MOD_ENV.md_id.osnum;\
\
   	rtcd = ci$send(msg = message GR3dellipse.GRconstruct(\
		&cst),\
	        targetid = (object).objid,\
	        targetos = (object).osnum);\
\
   	cst.geometry   = 0;\
	name_display((object), (name), (disp));


/*
#define create_cir_by_center(p1,p2,p3,object,name,disp)\
\
	set_up_easy();\
\
   	bspline_curve.poles   = &double100[0];\
   	bspline_curve.knots   = &double100[21];\
   	bspline_curve.weights = &bspline_curve.knots[10];\
\
	BSac2eptscr(&rtcd,(p2),(p1),(p3),normal_vector,\
		1,&bspline_curve);\
\
   	cst.geometry   = (char *)&bspline_curve;\
   	(object).objid = NULL_OBJID;\
   	(object).osnum = MOD_ENV.md_id.osnum;\
\
   	rtcd = ci$send(msg = message GR3dellipse.GRconstruct(\
		&cst),\
	        targetid = (object).objid,\
	        targetos = (object).osnum);\
\
   	cst.geometry   = 0;\
	name_display((object), (name), (disp));
*/

// CREATE A CURVE BY POLES WITH NAME AND DISPLAY INCLUDED
#define create_curve_by_poles(order,num_points,points,periodic,object,name,disp)\
\
	set_up_easy();\
\
        (object).objid = NULL_OBJID;\
  	(object).osnum = MOD_ENV.md_id.osnum;\
\
        ci$send(msg= message GRbcsubbc.EMcurve_by_poles(\
        	(order),\
		0,\
		(num_points),\
		(points),\
		(periodic),\
		&cst),\
		targetid = (object).objid,\
		targetos = (object).osnum);\
	name_display((object), (name), (disp));

// CREATE A DIRECT FIT CURVE WITH NAME AND DISPLAY INCLUDED
IGRboolean	U_per;
int		U_order, Num_crv;
#define create_dir_fit_curve(order,num_points,points,periodic,object,name,disp)\
\
	set_up_easy();\
\
        (object).objid = NULL_OBJID;\
  	(object).osnum = MOD_ENV.md_id.osnum;\
	U_per = (periodic);\
  	U_order = (order);\
	Num_crv = (num_points);\
\
        ci$send(msg= message GRbcsubbc.EMdirect_fit_curve(\
        	U_order,\
		U_per,\
		Num_crv,\
		(points),\
		0,0,0,\
		&cst),\
		targetid = (object).objid,\
		targetos = (object).osnum);\
	name_display((object), (name), (disp));

// GET THE BSPLINE CURVE STRUCTURE FROM A CURVE GRID
IGRchar			*geometry1234;

#define get_curve_geometry(curve,crv_stuct)\
\
	ci$get_module_info( md_env = &MOD_ENV);\
\
  	ci$send( msg = message GRvg.GRgenabsg( \
		&rtcd,\
		&MOD_ENV.md_env.matrix_type,\
		MOD_ENV.md_env.matrix,\
		&geometry1234 ),\
		targetid = (curve).objid,\
		targetos = (curve).osnum );\
	(crv_stuct) = (struct IGRbsp_curve *) geometry1234;

struct GRpost_info Cur_post;

#define put_curve_geometry(curve,crv_struct,disp)\
\
 	display_w_opt( (curve), ERASE);\
	ci$get_module_info( md_env = &MOD_ENV);\
  	ci$send( msg = message GRvg.GRpostabsg( \
		&rtcd,\
		&MOD_ENV,\
		&Cur_post,\
		(crv_struct),\
		&(curve).objid ),\
		targetid = (curve).objid,\
	  	targetos = (curve).osnum );\
 	display_w_opt( (curve), (disp));


#define get_endpoints(object,p1,p2)\
\
	set_up_easy();\
\
  	ci$send( msg = message GRcurve.GRendpts(\
		&rtcd,\
		&MOD_ENV.md_env.matrix_type,\
		MOD_ENV.md_env.matrix,\
		(p1),\
		(p2)),\
		targetid = (object).objid,\
		targetos = (object).osnum);

#define reverse_curve(object)\
\
	ci$get_module_info(md_env = &MOD_ENV);\
\
   	ci$send( msg = message GRcurve.GRrevparm(\
		&rtcd,\
		&MOD_ENV),\
		targetid = (object).objid,\
		targetos = (object).osnum); 

double	PoinT3[3];
struct IGRline	LinE;
#define project_point_along_vector(object,pnt1,pnt2,pnt3,GRid_out,u_value,v_value,p_inx)\
\
   set_up_easy();\
\
   LinE.point1 = (pnt1);\
   LinE.point2 = (pnt2);\
   ci$send( msg = message GRgraphics.GRlnproject(\
		&rtcd,\
		&MOD_ENV.md_env.matrix_type,\
		MOD_ENV.md_env.matrix,\
		&LinE,\
		(pnt3),\
		PoinT3,\
		&double_1,\
		&proJ_parms),\
		targetid = (object).objid,\
		targetos = (object).osnum); \
   (u_value) = proJ_parms.u;\
   (v_value) = proJ_parms.v;\
   (p_inx) = proJ_parms.polygon_inx;\
   (GRid_out) = proJ_parms.leaf_id;

struct GRlc_info *LCINF;
int	loopy,rt1;

#define  make_comp_curve( objs_in, object, name, disp)\
\
  ci$get_module_info( md_env = &MOD_ENV);\
  Action = 0;\
  while(1)\
	{\
  	   if((objs_in)[Action].objid == 0 || (objs_in)[Action].objid == -1 ) break;\
	   Action = Action+1;\
	}\
  LCINF = (struct GRlc_info *) malloc ( Action * sizeof(struct GRlc_info));\
\
  for(loopy = 0; loopy < Action; loopy=loopy+1)\
  {\
	LCINF[loopy].located_obj = (objs_in)[loopy];\
	LCINF[loopy].module_info = MOD_ENV;\
  }\
	(object).objid = NULL_OBJID;\
	(object).osnum = MOD_ENV.md_id.osnum;\
\
       ci$send( msg =  message GRcompcurve.EMmakecomp(\
			&rtcd, &MOD_ENV, Action, LCINF, &rt1),\
			targetid = (object).objid,\
			targetos = (object).osnum);\
	free(LCINF);\
\
	name_display((object), (name), (disp));

IGRboolean	Full,Dir,Tpr;
int		Nm_pit,ChK;

#define create_helix(p1,p2,p3,sr,er,pg,np,dir,object,name,disp)\
\
  set_up_easy();\
  Dir = (dir);\
  Full = 1;\
  Nm_pit = (np);\
  if( Nm_pit == 0)Full = 0;\
  Tpr = 1;\
  if( (sr) == 0) sr = .001;\
  if( (er) <= 0 ){ ChK = 1; er = fabs(sr);}\
\
  BShelix1( (p1), (p2), (p3), fabs(sr), (pg), Full, Nm_pit, Dir,\
		Tpr, (er), &bspline_curvep, &rtcd);\
\
  if( ChK == 1) {(er) = -1; ChK = 0;}\
  cst.geometry	= (char *)bspline_curvep;\
\
  (object).objid = NULL_OBJID;\
  (object).osnum = MOD_ENV.md_id.osnum;\
\
  ci$send(msg = message GRbcsubbc.GRconstruct(&cst),\
                targetid = (object).objid,\
	        targetos = (object).osnum );\
\
  name_display( (object), (name), (disp));






#endif

