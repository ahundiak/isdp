#ifndef ci_surface_include
#define ci_surface_include

#include "ci_setmd.h"
#include "EMSsfparms.h"
#include "EMSlcdef.h"
#include "emssfintdef.h"

#ifndef ci_wire_include
IGRchar                 *geometry1234;
struct IGRbsp_curve     *bspline_curvep;
#endif

double                  Ave_err,Max_err;
int                     num_ints;

#ifndef ci_easy_include
IGRchar                 object1name[132];
#endif

extern IGRboolean       EMintersect_with_plane_mod();
extern IGRboolean       MAdetplane();
extern int              EMintersect_two_element();
extern int              EMinitvgcnstr();
extern int		EMgetvgcnstr();

/*---------------------- md$create_surface_from_geometry ------------------

#omdef md$create_surface_from_geometry
                   (md_env = NULL,
                    geometry,
                    classname = NULL,
                    name = NULL,
                    color = -1,
                    style = -1,
                    level = -1,
                    weight = -1,
                    GRid_out,
                    display = 1)
 Abstract:

 This macro will create a surface object given it's geometric
 definition in the format (struct IGRbsp_surface). 

 Arguments:
      
I  struct *md_env  Construction environment. May be set to NULL in which
                   case the object will be created in the master file.

I  struct IGRbsp_surface *geometry  The geometry that is to be used 
                                    to construct the object.

I  IGRchar *classname  The classname of the object which needs to be
                       constructed. If one is not specified then a
                       general surface is constructed.

I IGRint color         The color of the entity that is to be constructed.
                       If not specified then the surface will be constructed
                       based on the active color.

I IGRint level         The layer, if specified, will be used for the
                       constructed entity. If not the surface will go onto the
                       active layer.

I IGRint style         The style, if specified, will be used for the
                       constructed entity. If not the surface will be defined
                       based on the active line style.

I IGRint weight        If specified, this weight will be used for the
                       constructed entity.  If not the surface will be defined
                       based on the active weight.

O struct GRid *GRid_out The constructed object is returned in this field

I IGRint display       The default option is to display the surface created.
                       If set to 0, then the surface will not be displayed
                       after creation

Sample call:

  struct GRid     SURFACE;
  int             i;
  struct GRid     GRid_out;

  ci$locate( obj   = &SURFACE.objid,
             osnum = &SURFACE.osnum,
             classes = "EMSplane",
             prompt= "Identify surface");

   md$get_surface_geometry(
                   GRid_in    = SURFACE,
                   surface_struct = bspline_surfacep);

   md$create_surface_from_geometry(
         geometry = bspline_surfacep,
         GRid_out = &GRid_out,
         classname = "EMSplane",
         color = 3,
         level= 10);
                                   
   
--------------------------------------------------------------------------- */

#omdef md$create_surface_from_geometry
                   (md_env = NULL,
                    geometry,
                    classname = NULL,
                    name = NULL,
                    color = -1,
                    style = -1,
                    level = -1,
                    weight = -1,
                    GRid_out,
                    display = 1)

EFcreate_surf_from_geom(md_env,(IGRchar *) geometry,
                        classname,color,style,level,weight,
                        name, display, GRid_out,1);
#endomdef


/*---------------------- md$project_point_along_vector_onto_surface--------

#omdef md$project_point_along_vector_onto_surface
                   (GRid_in = TEMP_GRID,
                    md_env = MOD_ENV,
                    vec_start,
                    vec_end,
                    point_to_project,
                    num_points,
                    proj_pnts,
                    u_pars,
                    v_pars)
 Abstract:
  This macro will project the incoming point onto the surface along the
  vector defined by vector_point1 and vector_point2 and will return all
  the projected points alongwith the u_parameter and v_parameter values.
 
 Arguments

  struct GRid_in     I    Input GRid of the surface
  struct GRmd_env  * I    Module environment
  IGRpoint vec_start I    start point of the vector
  IGRpoint vec_end   I    end point of the vector
  IGRpoint point_to_project I the point that needs to be projected
  IGRdouble *num_points O Total number of points that will be returned
  IGRdouble *proj_pnts  O Projected points
  IGRdouble *u_pars     O u parameter values of the projected points
  IGRdouble *v_aprs     O v parameter values of the projected points
  
 Sample Call:

 main ()
 {
    struct GRid     object;
    struct GRmd_env env;
    IGRint num_points;
    IGRdouble  	    point[3],proj_point[3],vc1[3],vc2[3];
    IGRdouble	    u,v;
    IGRdouble       *proj_points, *u_pars, *v_pars;
    IGRdouble       proj_pnt[3];
    IGRlong	    msg1;
    IGRint          i;

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

    md$project_point_along_vector_onto_surface(
        GRid_in = object,
        md_env = &env,
        vec_start = vc1,
        vec_end = vc2,
        point_to_project = point,
        num_points = &num_points,
        proj_pnts = proj_points,
        u_pars = u_pars,
        v_pars = v_pars);

    write("number of points= \n", num_points);
    for (i=0;i<num_points;i=i+1)
    {
     write ( proj_points[3*i+0],
              proj_points[3*i+1], proj_points[3*i+2]);
    }
 }
*/


#omdef md$project_point_along_vector_onto_surface
                   (GRid_in = TEMP_GRID,
                    md_env = MOD_ENV,
                    vec_start,
                    vec_end,
                    point_to_project,
                    num_points,
                    proj_pnts,
                    u_pars,
                    v_pars)

#if   (!om$specified(md_env))
      ci$get_module_info( md_env = &MOD_ENV);
        project_point_along_vector_onto_surface(GRid_in, &MOD_ENV, 
        vec_start,
        vec_end, point_to_project, num_points, proj_pnts, u_pars,
        v_pars);
#else
     project_point_along_vector_onto_surface((GRid_in),(md_env),
           (vec_start),
           (vec_end), (point_to_project), (num_points), 
           (proj_pnts), (u_pars), (v_pars));
#endif
#endomdef

/*---------------------- md$get_surface_normal--------------------------

#omdef md$get_surface_normal(
           GRid_in, 
           in_point,
           normal)
 get_surface_normal(GRid_in, in_point, normal);
#endomdef

Abstract
 This macro assists in obtaining the surface normal. 

Arguments
 struct GRid GRid_in I object id of the surface on which the normal
                       is to be determined
 IGRpoint in_point   I point that is lying on the surface. If the point does
                       not lie on the surface then a projection is done
                       automatically
 IGRvector normal    O The surface normal vector

Sample call

 main ()
 {
    struct GRid     object;
    struct GRmd_env env;
    IGRdouble  	    point[3];
    IGRdouble       nvec[3];
    IGRlong	    msg1;

    ci$locate( obj   = &object.objid,
               osnum = &object.osnum,
	       md_env = &env,
               prompt= "Identify object");

    ci$get(prompt="Enter point to project",
	   point = point);

    md$get_surface_normal(
           GRid_in = object, 
           in_point = point,
           normal = nvec);
    write (nvec[0], nvec[1], nvec[2]);
 }

*/


#omdef md$get_surface_normal(
           GRid_in, 
           in_point,
           normal)
 get_surface_normal(GRid_in, in_point, normal);
#endomdef

/*-------------------- md$create_xyz_curve_from_edge ---------------------

#omdef md$create_xyz_curve_from_edge(GRid_in,
                                     locatable = 1,
                                     GRid_out = &TEMP_GRID_NEW);

 Abstract
  This macro will create a xyz curve object when specified with the edge
  object in parametric or uv space

 Arguments
  
  GRid_in         I  struct GRid    Input object id and object space number
                                    of the edge 
  locatable       I  IGRint         If set to TRUE then the xyz object will
                                    be locatable and displayable.
                                    If set to FALSE then the xyz object will
                                    not be locatable or displayable. 
  GRid_out        O  struct GRid *  Output xyz curve object

Sample call:

main()
{
  struct GRid GRidin, GRidout;

  ci$get(value = GRidin.objid, prompt="key in Edge id");
  ci$get(value = GRidin.osnum, prompt="key in Edge osnum");

  md$create_xyz_curve_from_edge(GRid_in  =  GRidin,
                                GRid_out =  (&GRidout))
}
---------------------------------------------------------------------*/

#omdef md$create_xyz_curve_from_edge(GRid_in,
                                     md_env = MOD_ENV,
                                     locatable = 1,
                                     GRid_out = &TEMP_GRID_NEW);

       ci$get_module_info( md_env = &MOD_ENV);
       EFget_xyz_obj((GRid_in), (MOD_ENV), (GRid_out),(locatable));
#endomdef

/*---------------------- md$get_analytical_surface_info -------------------

#omdef md$get_analytical_surface_info(
                        GRid_in  = TEMP_GRID,
                        anl_struct,
                        srf_type = &Sf_Type,
                        md_env = MOD_ENV)

 Abstract:

        This macro will retrieve the analytical information about a surface.
        The structure that is returned will be of the class of the object that
        was input. The definitions for the structures of the data is documented
        in "EMSsfparms.h"

 Arguments:

        GRid_in         I       struct GRid     Input GRid of the surface

        anl_struct      O       struct EMsurface_params Output surface struct,
                                                        defined in 
                                                        "EMSsfparms.h"

        srf_type        O       int             Output surface type.
                                                0 = general surface
                                                1 = cylinder
                                                2 = cone
                                                3 = elliptical cylinder
                                                4 = elliptical cone
                                                5 = sphere
                                                6 = ellipsoid
                                                7 = torus
                                                8 = partial cylinder
                                                9 = partial cone
                                                10 = plane or surface of project
                                                11 = revolved surface
        
        md_env          I       struct GRmd_env input module environment, this
                                                is only need if the object
                                                resides in a reference file 
                                                and you want the information
                                                relative to the active file.


 Sample Call:

main()
{
        int             i, type;
        struct GRid     SURFACE;
        struct EMsurface_params anl; // structure defined in EMSsfparms.h

   message("get analytical surface info");

   while(1)
   {   

        ci$locate( obj   = &SURFACE.objid,
                   osnum = &SURFACE.osnum,
                   classes = "EMSsubbs",
                   md_env = &MOD_ENV,
                   prompt= "Identify surface to get info about");

        md$get_analytical_surface_info( 
                        GRid_in =SURFACE,
                        anl_struct = &anl,
                        srf_type = &type,
                        md_env = MOD_ENV);

        write("******************* surface stuff *******************\n");
        write("type =",type,'\n');
        write("range=",anl.range,"\n");
        if(type == 0) 
                write("gen or rev axis =",anl.params.revolve.axis,"\n");
        if(type == 1) 
                write("cylinder area =",anl.params.cyl.area,"\n");
        if(type == 2) 
                write("cone area =",anl.params.cone.area,"\n");
        if(type == 3) 
                write("ell cylinder area=",anl.params.elpcyl.area,"\n");
        if(type == 4) 
                write("ell cone area =",anl.params.elpcone.area,"\n");
        if(type == 5) 
                write("sphere area =",anl.params.sphere.area,"\n");
        if(type == 6) 
                write("ellipsoid  area=",anl.params.elpsd.area,"\n");
        if(type == 7) 
                write("torus  area=",anl.params.torus.area,"\n");
        if(type == 8) 
                write("partial cylinder area =",anl.params.pcyl.area,"\n");
        if(type == 9) 
                write("partial cone area =",anl.params.pcone.area,"\n");
        if(type == 10)
                 write("surface of project points=",
                        anl.params.project.axis_point0,
                        anl.params.project.axis_point1,"\n");
  }
}

 Notes:

        If the module environment is left out and the object resides in a 
        reference file, the output will be in the coordinates in the reference 
        file and not in the active file.

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$get_analytical_surface_info(
                        GRid_in  = TEMP_GRID,
                        anl_struct,
                        srf_type = &Sf_Type,
                        md_env = MOD_ENV)



#if   !om$specified(md_env)
        ci$get_module_info( md_env = &MOD_ENV);
        get_analytical_surface_info( GRid_in, anl_struct,srf_type, MOD_ENV);
#else
        get_analytical_surface_info( GRid_in, anl_struct,srf_type, md_env);
#endif
#endomdef

/*---------------------- md$get_surface_geometry ---------------------------

#omdef md$get_surface_geometry(
                        GRid_in    = TEMP_GRID,
                        surface_struct = bspline_surfacep)

 Abstract:

        This macro will return the bspline geometry of a surface. Since
        all the arguments have defaults, the input grid is "TEMP_GRID"
        and the output structure is bspline_surfacep. This is used when
        you need the pole positions for a given surface.

 Arguments:

        GRid_in         I       struct GRid     Input GRid of the surface

        surface_struct  O       struct IGRbsp_surface   Output surface structure
                                                        pointer.

 Sample Call:

        struct GRid     SURFACE;

        ci$locate( obj   = &SURFACE.objid,
                   osnum = &SURFACE.osnum,
                   classes = "EMSsurface",
                   prompt= "Identify surface to get the geometry from");

        md$get_surface_geometry(
                        GRid_in    = SURFACE,
                        surface_struct = bspline_surfacep)

        write("number of poles =", bspline_surfacep->u_num_poles,'\n');

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$get_surface_geometry(
                        GRid_in    = TEMP_GRID,
                        surface_struct = bspline_surfacep)

get_surface_geometry((GRid_in), (surface_struct));
#endomdef

/*---------------------- get$surface_geometry ---------------------------
-----------------------------------------------------------------------*/

#omdef get$surface_geometry( GRid_in        = TEMP_GRID,
                             surface_struct = bspline_surfacep )

   get_surface_geometry( (GRid_in), (surface_struct))

#endomdef

/*---------------------- md$put_surface_geometry ----------------------------

#omdef md$put_surface_geometry(
                        GRid_in         = TEMP_GRID,    
                        surface_struct  = bspline_surfacep,
                        disp            = DRAW)

 Abstract:

        This macro will put back surface geometry into the GRid_in id.
        This also checks to see if the surface is owned by a solid or
        a composite and will not allow you to modify it in those cases
        because you may violate the stiched boundaries.

 Arguments:

        GRid_in         I       struct GRid     Input surface GRid

        surface_struct  I       struct IGRbsp_surface   Input surface structure
                                                        pointer. 

        disp            I       int             Input display identifier.

 Sample Call:

        struct GRid     SURFACE;
        int             i;

        ci$locate( obj   = &SURFACE.objid,
                   osnum = &SURFACE.osnum,
                   classes = "EMSsurface",
                   prompt= "Identify surface to modify");

        md$get_surface_geometry(
                        GRid_in    = SURFACE,
                        surface_struct = bspline_surfacep);

        for( i=0; i<bspline_surfacep->u_num_poles*3; i=i+3)
        {
                bspline_surfacep->poles[i] = bspline_surfacep->poles[i]/2; 
        }       

         md$put_surface_geometry(
                        GRid_in         = SURFACE,      
                        surface_struct  = bspline_surfacep,
                        disp            = DRAW);

 Notes:

        Again the surface will not be put back if it is owned by a solid
        or composite.

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/
#omdef md$put_surface_geometry(
                        GRid_in         = TEMP_GRID,    
                        surface_struct  = bspline_surfacep,
                        disp            = DRAW)

put_surface_geometry((GRid_in), (surface_struct), (disp));
#endomdef


/*---------------------- md$place_tube_surface -----------------------------


#omdef md$place_tube_surface(
                        GRid_out = &TEMP_GRID_NEW,
                        GRid_in = TEMP_GRID,
                        radius = TRUE,
                        bend_radii = double100, 
                        name = "0",
                        disp = DRAW)

 Abstract:

        This macro will create a tube surface along a linestring or 2nd order
        bspline curve.

 Arguments:
        GRid_out        O       struct GRid     Output tube surface id

        GRid_in         I       struct GRid     Input linestring id

        radius          I       double          radius of the tube.

        bend_radii      I       double          array of bend radii.

        name            I       char            name.

        disp            I       int             display option.

 Sample Call:

        double          radius;
        struct GRid     CURVE, SURFACE;
        char            ele_name[255];
        ci$locate( obj   = &CURVE.objid,
                   osnum = &CURVE.osnum,
                   classes = "GRsubbc",
                   prompt= "Identify linestring to place tube on");

        ci$get(value = radius, prompt="key in the tube radius");
        strcpy(ele_name, "tube");        
        md$place_tube_surface(
                        GRid_out = &SURFACE,
                        GRid_in = CURVE,
                        radius = radius,
                        name = ele_name,
                        disp = DRAW);
        
 Notes:

        The minimum bend radius is the tube radius and if no bend radii are
        input then the bend radii will equal the tube radius.

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$place_tube_surface(
                        GRid_out = &TEMP_GRID_NEW,
                        GRid_in = TEMP_GRID,
                        radius = TRUE,
                        bend_radii = double100, 
                        name = "0",
                        disp = DRAW)
#if !om$specified(bend_radii)
    for (counter=0; counter<100; counter=counter+1) 
        double100[counter] = (radius);
#endif
create_tube_surface((radius),(bend_radii),(GRid_in),(GRid_out),(name),(disp));
#if !om$specified(GRid_out)
    TEMP_GRID = TEMP_GRID_NEW;
#endif
#endomdef

/*---------------------- md$place_tube_surface -----------------------------
/* place$tube_surface

   place$tube_surface( GRid_out   = TEMP_GRID_NEW,
		       GRid_in    = TEMP_GRID,
		       radius     = TRUE,
		       bend_radii = double100,
		       name       = "0",
		       disp       = DRAW )

   md$place_tube_surface( GRid_out   = &TEMP_GRID_NEW,
                          GRid_in    =  TEMP_GRID,
                          radius     =  TRUE,
                          bend_radii =  double100, 
                          name       =  "0",
                          disp       =  DRAW )
-----------------------------------------------------------------------*/

#omdef place$tube_surface( GRid_out   = TEMP_GRID_NEW,
                           GRid_in    = TEMP_GRID,
                           radius     = TRUE,
                           bend_radii = double100, 
                           name       = "0",
                           disp       = DRAW )

#if (! om$specified(bend_radii))
   for (counter=0; counter<100; counter=counter+1) 
        double100[counter] = (radius);
#endif

   create_tube_surface( (radius),(bend_radii),(GRid_in),
		        &(GRid_out),(name),(disp));

#if (! om$specified(GRid_out))
   TEMP_GRID = TEMP_GRID_NEW;
#endif

#endomdef

/*---------------------- md$place_cylinder_surface ---------------------------

#omdef md$place_cylinder_surface(
                        point1, 
                        point2, 
                        radius ^ point3,
                        GRid_out = &TEMP_GRID,
                        name = "0", 
                        disp = DRAW)

 Abstract:

        This macro will create a cylinder given 3 points or 2 points describing
        the axis and a radius.

 Arguments:

        point1          I       double[3]       Input axis point 1

        point2          I       double[3]       Input axis point 2

        point3          I       double[3]       Input axis point 3

        radius          I       double          radius

        GRid_out        O       struct GRid     Output cylinder id

        name            I       char            name

        disp            I       int             display option


 Sample Call:

        double  p1[3], p2[3], p3[3];
        char    ele_name[255];
        ci$get(point = p1, prompt = "identify axis point one");

        ci$get(point = p2, prompt = "identify axis point two");

        ci$get(point = p3, prompt = "identify radius point");
        strcpy(ele_name, "cylinder");
        md$place_cylinder_surface(
                        point1 = p1,    
                        point2 = p2,    
                        point3 = p3,
                        GRid_out = &TEMP_GRID,
                        name = ele_name, 
                        disp = DRAW);

 Notes:

        Either point3 or radius may be used. Not both.

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$place_cylinder_surface(
                        point1, 
                        point2, 
                        radius ^ point3,
                        GRid_out = &TEMP_GRID,
                        name = "0", 
                        disp = DRAW)

#if om$specified (radius)
 {
 create_cylinder_surfacer(radius,point1,point2,GRid_out,name,disp);
 }
#elif om$specified (point3)
 {
 create_cylinder_surfacep(point3,point1,point2,GRid_out,name,disp);
 }
#endif
#endomdef

/*---------------------- place$cylinder_surface ---------------------------

   place$cylinder_surface( point1,
			   point2,
			   radius ^ point3,
			   GRid_out = TEMP_GRID,
			   name     = "0",
			   disp     = DRAW )

   md$place_cylinder_surface( point1, 
                              point2, 
                              radius ^ point3,
                              GRid_out = &TEMP_GRID,
                              name     =  "0", 
                              disp     =  DRAW )
-----------------------------------------------------------------------*/

#omdef place$cylinder_surface( point1,
			       point2,
			       radius ^ point3,
			       GRid_out = TEMP_GRID,
			       name     = "0",
			       disp     = DRAW )

#if ( om$specified (radius))
    create_cylinder_surfacer( (radius),(point1),(point2),
			      &(GRid_out),(name),(disp))
#elif ( om$specified (point3))
    create_cylinder_surfacep( (point3),(point1),(point2),
			      &(GRid_out),(name),(disp))
#endif

#endomdef

/*---------------------- md$place_sphere_surface ----------------------------

#omdef md$place_sphere_surface(
                        point1, 
                        radius ^ point2,        
                        GRid_out = &TEMP_GRID,   
                        name = "0",             
                        disp = DRAW)

 Abstract:

        This macro will create a sphere given 2 points or center and radius.

 Arguments:

        point1          I       double[3]       Input center

        point2          I       double[3]       Input radius point

        radius          I       double          radius

        GRid_out        O       struct GRid     Output sphere id

        name            I       char            name

        disp            I       int             display option

 Sample Call:

        double  p1[3], p2[3];
        char    ele_name[255];
        ci$get(point = p1, prompt = "identify center");

        ci$get(point = p2, prompt = "identify radius point");
        strcpy(ele_name, "sphere");
        md$place_sphere_surface(
                        point1 = p1,    
                        point2 = p2,    
                        GRid_out = &TEMP_GRID,
                        name = ele_name, 
                        disp = DRAW);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$place_sphere_surface(
                        point1, 
                        radius ^ point2,        
                        GRid_out = &TEMP_GRID,   
                        name = "0",             
                        disp = DRAW)

#if om$specified (radius)
 {
 create_sphere_surfacer(radius,point1,GRid_out,name,disp);
 }
#elif om$specified (point2)
 {
 create_sphere_surfacep(point2,point1,GRid_out,name,disp);
 }
#endif
#endomdef

/*---------------------- place$sphere_surface ----------------------------

   place$sphere_surface( point1,
			 radius ^ point2,
			 GRid_out = TEMP_GRID,
			 name     = "0",
			 disp     = DRAW )

   md$place_sphere_surface( point1, 
                            radius ^ point2,        
                            GRid_out = &TEMP_GRID,   
                            name     =  "0",             
                            disp     =  DRAW)
-----------------------------------------------------------------------*/

#omdef place$sphere_surface( point1,
			     radius ^ point2,
			     GRid_out = TEMP_GRID,
			     name     = "0",
			     disp     = DRAW )

#if ( om$specified (radius))
    create_sphere_surfacer( (radius),(point1),&(GRid_out),(name),(disp))
#elif ( om$specified (point2))
    create_sphere_surfacep( (point2),(point1),&(GRid_out),(name),(disp))
#endif

#endomdef

/*---------------------- md$place_surface_project ------------------------

#omdef md$place_surface_project(
                        GRid_in = TEMP_GRID ^ curve_struct = 0,
                        point1,
                        point2,
                        GRid_out = &TEMP_GRID_NEW,
                        name = "0",
                        disp = DRAW)
        
 Abstract:

        This macro will create a surface of project with either a curve
        GRid or a bspline curve structure. the projection will be the
        vector defined by the 2 points given.

 Arguments:


        point1          I       double[3]       Input point 1 of project vector

        point2          I       double[3]       Input point 1 of project vector

        GRid_in         I       struct GRid     Input curve id

        curve_struct    I       struct IGRbspline_curve Input bspline curve
                                                        structure.

        GRid_out        O       struct GRid     Output projection id

        name            I       char            name

        disp            I       int             display option

 Sample Call:

        double          p1[3], p2[3];
        struct GRid     CURVE, SURFACE;
        char            ele_name[255];
        ci$locate( obj   = &CURVE.objid,
                   osnum = &CURVE.osnum,
                   classes = "GRbspline",
                   prompt= "Identify curve to project");

        ci$get(point = p1, prompt = "identify project point 1");

        ci$get(point = p2, prompt = "identify project point 2");
        strcpy(ele_name, "project");
        md$place_surface_project(
                        GRid_in = CURVE,
                        point1  = p1,
                        point2  = p2,
                        GRid_out = &SURFACE,
                        name = ele_name,
                        disp = DRAW);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$place_surface_project(
                        GRid_in = TEMP_GRID ^ curve_struct = 0,
                        point1,
                        point2,
                        GRid_out = &TEMP_GRID_NEW,
                        name = "0",
                        disp = DRAW)
                        
#if om$specified (GRid_in)
 {
  create_surface_pro(&GRid_in,0,point1,point2,GRid_out,name,disp);
 }
#elif om$specified (curve_struct)
 {
  create_surface_pro(NULL,curve_struct,point1,point2,GRid_out,name,disp);
 }
#elif !om$specified (curve_struct) && !om$specified (GRid_in)
 {
  create_surface_pro(&GRid_in,0,point1,point2,GRid_out,name,disp);
 }
#endif

#if !om$specified (GRid_in) && !om$specified (GRid_out) && !om$specified (curve_struct)
  TEMP_GRID = TEMP_GRID_NEW;
#endif
#endomdef

/*---------------------- place$surface_project ------------------------

   place$surface_project( GRid_in  = TEMP_GRID ^ curve_struct = 0,
			  point1,
			  point2,
			  GRid_out = TEMP_GRID_NEW,
			  name     = "0",
			  disp     = DRAW )

   md$place_surface_project( GRid_in  =  TEMP_GRID ^ curve_struct = 0,
                             point1,
                             point2,
                             GRid_out = &TEMP_GRID_NEW,
                             name     =  "0",
                             disp     =  DRAW )
-----------------------------------------------------------------------*/

#omdef place$surface_project( GRid_in  = TEMP_GRID ^ curve_struct = 0,
			      point1,
			      point2,
			      GRid_out = TEMP_GRID_NEW,
			      name     = "0",
			      disp     = DRAW )
                        
#if ( om$specified (GRid_in))
     create_surface_pro( &(GRid_in),0,(point1),(point2),
			 &(GRid_out),(name),(disp));
#elif ( om$specified (curve_struct))
     create_surface_pro( NULL,(curve_struct),(point1),(point2),
		         &(GRid_out),(name),(disp));
#elif (! (om$specified (GRid_in) || om$specified (curve_struct)))
    create_surface_pro( &(GRid_in),0,(point1),(point2),
			&(GRid_out),(name),(disp));
#endif

#if (! ( om$specified (GRid_in) || om$specified (GRid_out) || om$specified (curve_struct)))
   TEMP_GRID = TEMP_GRID_NEW;
#endif

#endomdef


struct GRid TeMp;

/*---------------------- md$place_surface_revol ------------------------

#omdef md$place_surface_revol(
                        GRid_in = TEMP_GRID,    
                        point1,                                 
                        point2,                                         
                        start_angle = 0,                                
                        sweep_angle = 360,                              
                        GRid_out = &TEMP_GRID_NEW,                       
                        name = "0",                                     
                        disp = DRAW)                            

 Abstract:

        This macro will create a surface of revolution.

 Arguments:

        GRid_in         I       struct GRid     Input curve id

        point1          I       double[3]       Input axis point 1

        point2          I       double[3]       Input axis point 2

        start_angle     I       double          start of sweep angle

        sweep_angle     I       double          sweep angle of revolution

        GRid_out        O       struct GRid     Output surface id

        name            I       char            name

        disp            I       int             display option

 Sample Call:

        double          p1[3], p2[3];
        struct GRid     CURVE, SURFACE;
        char            ele_name[255];

        ci$locate( obj   = &CURVE.objid,
                   osnum = &CURVE.osnum,
                   classes = "GRbspline",
                   prompt= "Identify curve to revolve");

        ci$get(point = p1, prompt = "identify axis point 1");

        ci$get(point = p2, prompt = "identify axis point 2");
        strcpy(ele_name, "rev");
        md$place_surface_revol(
                        GRid_in = CURVE,        
                        point1 = p1,                                    
                        point2 = p2,                                          
                        GRid_out = &SURFACE,                     
                        name = ele_name);                  

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$place_surface_revol(
                        GRid_in = TEMP_GRID,    
                        point1,                                 
                        point2,                                         
                        start_angle = 0,                                
                        sweep_angle = 360,                              
                        GRid_out = &TEMP_GRID_NEW,                       
                        name = "0",                                     
                        disp = DRAW)                            

 create_surface_rev((GRid_in),(point1),(point2),(start_angle),(sweep_angle),(GRid_out),(name),(disp))\
#if !om$specified (GRid_out) && !om$specified (GRid_in)
 TEMP_GRID = TEMP_GRID_NEW;
#endif
#endomdef

/*---------------------- md$place_surface_revol ------------------------

   place$surface_revol( GRid_in     = TEMP_GRID,
			point1,
			point2,
			start_angle = 0,
			sweep_angle = 360,
			GRid_out    = TEMP_GRID_NEW,
			name        = "0",
			disp        = DRAW )

   md$place_surface_revol( GRid_in     =  TEMP_GRID,
                           point1,
                           point2,
                           start_angle =  0,
                           sweep_angle =  360,
                           GRid_out    = &TEMP_GRID_NEW,
                           name        =  "0",
                           disp        =  DRAW )
-----------------------------------------------------------------------*/

#omdef place$surface_revol( GRid_in     = TEMP_GRID,
			    point1,
			    point2,
			    start_angle = 0,
			    sweep_angle = 360,
			    GRid_out    = TEMP_GRID_NEW,
			    name        = "0",
			    disp        = DRAW )

#if (! (om$specified(point1) || om$specified(point2)))
#  omerror "Must specify point1 and point2"
#else
   create_surface_rev( (GRid_in),(point1),(point2),(start_angle),
		       (sweep_angle),&(GRid_out),(name),(disp))
#endif

#endomdef


struct GRlc_info        *LocIn;
IGRshort                *bLEN;
double                  *ePNt;

/*---------------------- md$place_surface_blend_interior ----------------

#omdef md$place_surface_blend_interior(
                        GRids_in,       
                        point1,                 
                        option1 = 3,            
                        option2 = 3,            
                        GRid_out = &TEMP_GRID_NEW,
                        name = "0",             
                        disp = DRAW)

 Abstract:

        This macro will create a blended surface from interior curves.

 Arguments:

        GRids_in        I       struct GRid     array of surfaces and curves

        point1          I       double[3]       blend direction point

        option1         I       int             blend option for the surface
                                                from surface and curve 1.
                                
        option2         I       int             blend option for the surface
                                                from surface and curve 2.
                                                                
        GRid_out        O       struct GRid     Output surface id

        name            I       char            name

        disp            I       int             display option


 Sample Call:

        struct GRid     GRIDS[4];
        double          point[3];
        char            ele_name[255];
        message("blend surface interior");

        ci$locate( obj   = &GRIDS[0].objid,
                   osnum = &GRIDS[0].osnum,
                   classes = "EMSsubbs",
                   prompt= "Identify surface 1");

        ci$locate( obj   = &GRIDS[1].objid,
                   osnum = &GRIDS[1].osnum,
                   classes = "GRcurve",
                   prompt= "Identify curve 1");

        ci$locate( obj   = &GRIDS[2].objid,
                   osnum = &GRIDS[2].osnum,
                   classes = "EMSsubbs",
                   prompt= "Identify surface 2");

        ci$locate( obj   = &GRIDS[3].objid,
                   osnum = &GRIDS[3].osnum,
                   classes = "GRcurve",
                   prompt= "Identify curve 2");

        ci$get( point = point, prompt="identify blend point");
        strcpy(ele_name, "blend");
        md$place_surface_blend_interior
                        (GRids_in = GRIDS,
                        point1 = point, 
                        option1 = 3,
                        option2 = 3,
                        GRid_out = &TEMP_GRID, 
                        name = ele_name, 
                        disp = DRAW);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$place_surface_blend_interior(
                        GRids_in,       
                        point1,                 
                        option1 = 3,            
                        option2 = 3,            
                        GRid_out = &TEMP_GRID_NEW,
                        name = "0",             
                        disp = DRAW)

/**************************************
 the code below is not to be used 
 by a ppl user the messages are 
 private and not fixed. If used
 your code may break in later releases.
***************************************/

  set_up_easy();

  ePNt = (double *) malloc( 9 * sizeof(double));
  bLEN = (IGRshort *) malloc( 2 * sizeof(IGRshort));
  LocIn = (struct GRlc_info *) malloc(4 * sizeof(struct GRlc_info));

  ci$send( msg = message GRcurve.GRendpts(&rtcd,
                &MOD_ENV.md_env.matrix_type,
                MOD_ENV.md_env.matrix, &ePNt[0],&ePNt[6]),
                targetid = GRids_in[1].objid,
                targetos = GRids_in[1].osnum);

  ci$send( msg = message GRcurve.GRendpts(&rtcd,
                &MOD_ENV.md_env.matrix_type,
                MOD_ENV.md_env.matrix, &ePNt[3],&ePNt[6]),
                targetid = GRids_in[3].objid,
                targetos = GRids_in[3].osnum);

  for(bLEN[0] = 0; bLEN[0] < 3; bLEN[0] = bLEN[0] + 1 )
  {
        ePNt[bLEN[0]] = point1[bLEN[0]] - ePNt[bLEN[0]];
        ePNt[bLEN[0]+3] = point1[bLEN[0]] - ePNt[bLEN[0]+3];
  }
  
  for(bLEN[0] = 0; bLEN[0] < 4; bLEN[0] = bLEN[0] + 1 )
  {
        LocIn[bLEN[0]].located_obj = GRids_in[bLEN[0]];
        LocIn[bLEN[0]].module_info = MOD_ENV;
  }

  bLEN[0] = option1;
  bLEN[1] = option2;

  (*(GRid_out)).objid = NULL_OBJID;
  (*(GRid_out)).osnum = MOD_ENV.md_id.osnum;

  ci$send(msg = message EMSgenbs.EMblend_surface_interior(
                &LocIn[0], &LocIn[1], &ePNt[0], bLEN[0],
                &LocIn[2], &LocIn[3], &ePNt[3], bLEN[1], &cst),
                targetid = (*(GRid_out)).objid,
                targetos = (*(GRid_out)).osnum);

  free(LocIn);
  free(bLEN);
  free(ePNt);

  name_display((*(GRid_out)), (name), (disp));

#endomdef

/*---------------------- place$surface_blend_interior ----------------

   place$surface_blend_interior( GRids_in,
				 point1,
				 option1  = 3,
				 option2  = 3,
				 GRid_out = TEMP_GRID_NEW,
				 name     = "0",
				 disp     = DRAW )

   md$place_surface_blend_interior( GRids_in,
                                    point1,
                                    option1  =  3,
                                    option2  =  3,
                                    GRid_out = &TEMP_GRID_NEW,
                                    name     =  "0",
                                    disp     =  DRAW )
-----------------------------------------------------------------------*/

#omdef place$surface_blend_interior( GRids_in,
				     point1,
				     option1  = 3,
				     option2  = 3,
				     GRid_out = TEMP_GRID_NEW,
				     name     = "0",
				     disp     = DRAW )

/**************************************
 the code below is not to be used 
 by a ppl user the messages are 
 private and not fixed. If used
 your code may break in later releases.
***************************************/

  set_up_easy();

  ePNt = (double *) malloc( 9 * sizeof(double));
  bLEN = (IGRshort *) malloc( 2 * sizeof(IGRshort));
  LocIn = (struct GRlc_info *) malloc(4 * sizeof(struct GRlc_info));

  ci$send( msg = message GRcurve.GRendpts(&rtcd,
                &MOD_ENV.md_env.matrix_type,
                MOD_ENV.md_env.matrix, &ePNt[0],&ePNt[6]),
                targetid = GRids_in[1].objid,
                targetos = GRids_in[1].osnum);

  ci$send( msg = message GRcurve.GRendpts(&rtcd,
                &MOD_ENV.md_env.matrix_type,
                MOD_ENV.md_env.matrix, &ePNt[3],&ePNt[6]),
                targetid = GRids_in[3].objid,
                targetos = GRids_in[3].osnum);

  for(bLEN[0] = 0; bLEN[0] < 3; bLEN[0] = bLEN[0] + 1 )
  {
        ePNt[bLEN[0]] = point1[bLEN[0]] - ePNt[bLEN[0]];
        ePNt[bLEN[0]+3] = point1[bLEN[0]] - ePNt[bLEN[0]+3];
  }
  
  for(bLEN[0] = 0; bLEN[0] < 4; bLEN[0] = bLEN[0] + 1 )
  {
        LocIn[bLEN[0]].located_obj = GRids_in[bLEN[0]];
        LocIn[bLEN[0]].module_info = MOD_ENV;
  }

  bLEN[0] = option1;
  bLEN[1] = option2;

  (GRid_out).objid = NULL_OBJID;
  (GRid_out).osnum = MOD_ENV.md_id.osnum;

  ci$send(msg = message EMSgenbs.EMblend_surface_interior(
                &LocIn[0], &LocIn[1], &ePNt[0], bLEN[0],
                &LocIn[2], &LocIn[3], &ePNt[3], bLEN[1], &cst),
                targetid = (GRid_out).objid,
                targetos = (GRid_out).osnum);

  free(LocIn);
  free(bLEN);
  free(ePNt);

  name_display((GRid_out), (name), (disp));

#endomdef


#ifndef ci_solid_include
#define INTERSECTION    0 
#define UNION           1
#define DIFFERENCE      2 
#define SAVE_SIDE       3 
#define DISJOINT_UNION  4
#define HOLLOW_DIFF     5 
#endif

/*---------------------- md$surface_boolean ---------------------------

#omdef md$surface_boolean(
                        num_objects,    
                        GRids_in,       
                        op_type = DIFFERENCE,   
                        bool_disp = 1,          
                        GRid_out = &TEMP_GRID,   
                        name = "0",             
                        disp = DRAW)
 Abstract:

        This macro will perform a surface boolean on the input surfaces.
        The user is under the same constraints that he is if using the
        command from the menu.

 Arguments:

        num_objects     I       int             Number of input surfaces.

        op_type         I       int             Boolean operation type. These
                                                are listed here:
        
                                                        INTERSECTION    0 
                                                        UNION           1
                                                        DIFFERENCE      2 
                                                        SAVE_SIDE       3 
                                                        DISJOINT_UNION  4
                                                        HOLLOW_DIFF     5 

        bool_disp       I       int             Input display option from 
                                                boolean operation.  If TRUE
                                                display is done by the macro.

        GRid_out        O       struct GRid     Output GRid of the solid

        GRids_in        I       struct GRid     Input array of GRid surfaces

        name            I/O     IGRchar        Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:
        int             i;
        struct GRid     GRIDS[50];
        char            ele_name[255];

        message("surface boolean");

        i=0;
        
        while(1)
        {
                if( !ci$locate( obj = &GRIDS[i].objid,
                           osnum = &GRIDS[i].osnum,
//                         classes = "EMSsurface",
                           prompt= "Identify surface")) break;
                i=i+1;
                if(i == 50) break;
        }
        strcpy(ele_name, "boolean");
        md$surface_boolean
                        (num_objects = i,
                        GRids_in = GRIDS,
                        op_type = DIFFERENCE,
                        bool_disp = 1,
                        GRid_out = &TEMP_GRID,
                        name = ele_name,
                        disp = DRAW);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$surface_boolean(
                        num_objects,    
                        GRids_in,       
                        op_type = DIFFERENCE,   
                        bool_disp = 1,          
                        GRid_out = &TEMP_GRID,   
                        name = "0",             
                        disp = DRAW)

  surface_boolean((num_objects),(GRids_in),(op_type),(bool_disp),(GRid_out),(name),(disp));
#endomdef

/*---------------------- surface$boolean ---------------------------

   surface$boolean( num_objects,
		    GRids_in,
		    op_type   = DIFFERENCE,
		    bool_disp = 1,
		    GRid_out  = TEMP_GRID,
		    name      = "0",
		    disp      = DRAW )

   md$surface_boolean( num_objects,    
                       GRids_in,       
                       op_type   =  DIFFERENCE,   
                       bool_disp =  1,          
                       GRid_out  = &TEMP_GRID,   
                       name      =  "0",             
                       disp      =  DRAW)
-----------------------------------------------------------------------*/

#omdef surface$boolean( num_objects,
		        GRids_in,
		        op_type   = DIFFERENCE,
		        bool_disp = 1,
		        GRid_out  = TEMP_GRID,
		        name      = "0",
		        disp      = DRAW )

   surface_boolean( (num_objects),(GRids_in),(op_type),
		    (bool_disp),&(GRid_out),(name),(disp))

#endomdef

/*---------------------- md$composite_surface ---------------------------

#omdef md$composite_surface(
                        num_objects,
                        GRids_in,
                        GRid_out = &TEMP_GRID,
                        name = "0",
                        disp = DRAW)

 Abstract:

        This macro will create a composite surface from multiple input
        surfaces.

 Arguments:

        num_objects     I       int             Number of input surfaces.


        GRid_out        O       struct GRid     Output GRid of the solid

        GRids_in        I       struct GRid     Input array of GRid surfaces

        name            I/O     IGRchar         Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:
        int             i;
        struct GRid     GRIDS[50];
        char            ele_name[255];

        message("composite surface");

        i=0;

        while(1)
        {
                if( !ci$locate( obj = &GRIDS[i].objid,
                           osnum = &GRIDS[i].osnum,
                           classes = "EMSsubbs",
                           prompt= "Identify surface")) break;
                i=i+1;
                if(i == 50) break;
        }
        strcpy(ele_name, "composite");        
        md$composite_surface
                        (num_objects = i,
                        GRids_in = GRIDS,
                        GRid_out = &TEMP_GRID,
                        name = ele_name,
                        disp = DRAW);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$composite_surface(
                        num_objects,
                        GRids_in,
                        GRid_out = &TEMP_GRID,
                        name = "0",
                        disp = DRAW)

create_composite_surface((GRid_out),(num_objects),(GRids_in),(name),(disp));
#endomdef

/*---------------------- composite$surface ---------------------------

   composite$surface( num_objects,
		      GRids_in,
		      GRid_out = TEMP_GRID,
		      name     = "0",
		      disp     = DRAW )

   md$composite_surface( num_objects,
                         GRids_in,
                         GRid_out = &TEMP_GRID,
                         name     =  "0",
                         disp     =  DRAW)
-----------------------------------------------------------------------*/

#omdef composite$surface( num_objects,
		          GRids_in,
		          GRid_out = TEMP_GRID,
		          name     = "0",
		          disp     = DRAW )

   create_composite_surface(&(GRid_out),(num_objects),(GRids_in),(name),(disp))

#endomdef

/*---------------------- md$place_surface_by_curves -------------------

#omdef md$place_surface_by_curves(
                        order = 3,      
                        num_objects,    
                        GRids_in,
                        GRid_out = &TEMP_GRID,   
                        name = "0",     
                        disp = DRAW)

 Abstract:

        This macro will create a surface from curves.

 Note : This surface the macro placers depends on the direction of the
       curves, Hence the direction of the curves should be oriented properly.

 Arguments:

        order           I       int             order for v direction of surf.

        num_objects     I       int             number of curves.

        GRid_out        O       struct GRid     Output GRid of the solid

        GRids_in        I       struct GRid     Input array of curve ids.

        name            I/O     IGRchar        Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:
        int             i;
        struct GRid     GRIDS[50];
        char            ele_name[255];

        message("surface by curves");

        i=0;
        
        while(1)
        {
                if( !ci$locate( obj = &GRIDS[i].objid,
                           osnum = &GRIDS[i].osnum,
                           classes = "GRbspline",
                           prompt= "Identify curve")) break;
                i=i+1;
                if(i == 50) break;
        }

        strcpy(ele_name, "surf_by_curves");
        md$place_surface_by_curves
                        (order = 3,     
                        num_objects = i,        
                        GRids_in = GRIDS,       
                        GRid_out = &TEMP_GRID,
                        name = ele_name,        
                        disp = DRAW);
        
 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$place_surface_by_curves(
                        order = 3,      
                        num_objects,    
                        GRids_in,
                        GRid_out = &TEMP_GRID,   
                        name = "0",     
                        disp = DRAW)

direct_fit_surface_by_curves(order,num_objects,GRids_in,GRid_out,name,disp)\
#endomdef

/*---------------------- place$surface_by_curves -------------------

   place$surface_by_curves( order    = 3,
			    num_objects,
			    GRids_in,
			    GRid_out = TEMP_GRID,
			    name     = "0",
			    disp     = DRAW )

   md$place_surface_by_curves( order = 3,
                               num_objects,
                               GRids_in,
                               GRid_out = &TEMP_GRID,
                               name = "0",
                               disp = DRAW )
/
-----------------------------------------------------------------------*/

#omdef place$surface_by_curves( order    = 3,
			        num_objects,
			        GRids_in,
			        GRid_out = TEMP_GRID,
			        name     = "0",
			        disp     = DRAW )

   direct_fit_surface_by_curves( (order),(num_objects),(GRids_in),
				 &(GRid_out),(name),(disp))

#endomdef

/*---------------------- md$place_surface_by_linestrings ----------------


#omdef md$place_surface_by_linestrings(
                        u_order = 3,
                        v_order = 3,
                        u_period = 0,
                        v_period = 0,
                        num_objects,
                        GRids_in,
                        GRid_out = &TEMP_GRID,
                        name = "0",
                        disp = DRAW)
 Abstract:

        This macro will create a surface using linestrings and given the
        order for the surface in both directions.

 Note : This surface the macro placers depends on the direction of the
        linestrings, Hence the direction of the linestrings  should be
        oriented properly.

 Arguments:

        u_period        I       IGRboolean      is u direction periodic

        v_period        I       IGRboolean      is v direction periodic

        u_order         I       int             order for u direction of surf.

        v_order         I       int             order for v direction of surf.

        num_objects     I       int             number of linestrings.

        GRid_out        O       struct GRid     Output GRid of the surface

        GRids_in        I       struct GRid     Input array of linestrings ids.

        name            I/O     IGRchar        Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:
        int             i;
        struct GRid     GRIDS[50];
        char            ele_name[255];
        message("surface by linestrings");

        i=0;
        
        while(1)
        {
                if( !ci$locate( obj = &GRIDS[i].objid,
                           osnum = &GRIDS[i].osnum,
                           classes = "GR3dlinestr",
                           prompt= "Identify linestring")) break;
                i=i+1;
                if(i == 50) break;
        }

        strcpy(ele_name, "surf_by_linestrings");
        md$place_surface_by_linestrings
                        (u_order = 3,
                        v_order = 3,
                        u_period = 0,
                        v_period = 0,
                        num_objects = i,
                        GRids_in = GRIDS,
                        GRid_out = &TEMP_GRID,   
                        name = ele_name,   
                        disp = DRAW);
        
 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/
#omdef md$place_surface_by_linestrings(
                        u_order = 3,
                        v_order = 3,
                        u_period = 0,
                        v_period = 0,
                        num_objects,
                        GRids_in,
                        GRid_out = &TEMP_GRID,
                        name = "0",
                        disp = DRAW)

direct_fit_surface(u_order,v_order,u_period,v_period,num_objects,GRids_in,GRid_out,name,disp)
#endomdef

/*---------------------- place$surface_by_linestrings ----------------

   place$surface_by_linestrings( u_order  = 3,
				 v_order  = 3,
				 u_period = 0,
				 v_period = 0,
				 num_objects,
				 GRids_in,
				 GRid_out = TEMP_GRID,
				 name     = "0",
				 disp     = DRAW )

   md$place_surface_by_linestrings( u_order  =  3,
                                    v_order  =  3,
                                    u_period =  0,
                                    v_period =  0,
                                    num_objects,
                                    GRids_in,
                                    GRid_out = &TEMP_GRID,
                                    name     =  "0",
                                    disp     =  DRAW )
-----------------------------------------------------------------------*/

#omdef place$surface_by_linestrings( u_order  = 3,
				     v_order  = 3,
				     u_period = 0,
				     v_period = 0,
				     num_objects,
				     GRids_in,
				     GRid_out = TEMP_GRID,
				     name     = "0",
				     disp     = DRAW )

   direct_fit_surface( (u_order),(v_order),(u_period),(v_period),
		       (num_objects),(GRids_in),&(GRid_out),(name),(disp))

#endomdef


/*---------------------- md$place_surface_by_network ----------------------

#omdef md$place_surface_by_network
                        (num_of_u,                                      
                        num_of_v,                                       
                        GRids_in,                                       
                        GRid_out = &TEMP_GRID,                           
                        name = "0",                                     
                        disp = DRAW)                                    

 Abstract:

        This macro will create a surface from a network of curves.

 Arguments:

        num_of_u        I       int             number of u direction curves.

        num_of_v        I       int             number of v direction curves.

        GRid_out        O       struct GRid     Output GRid of the surface

        GRids_in        I       struct GRid     Input array of linestrings ids.

        name            I/O     IGRchar        Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:
        int             i, j, k;
        struct GRid     GRIDS[50];
        char            ele_name[255];

        message("surface by network");

        i=0;
        while(1)
        {
                if( !ci$locate( obj = &GRIDS[i].objid,
                           osnum = &GRIDS[i].osnum,
                           classes = "GRbspline",
                           prompt= "Identify u curves")) break;
                i=i+1;
                if(i == 50) break;
        }

        j=0;
        k=i;
        while(1)
        {
                if( !ci$locate( obj = &GRIDS[k].objid,
                           osnum = &GRIDS[k].osnum,
                           classes = "GRbspline",
                           prompt= "Identify v curves")) break;
                k=k+1;
                j=j+1;
                if(k == 50) break;
                
        }

        strcpy(ele_name, "surf_network");
        md$place_surface_by_network
                        (num_of_u = i,
                        num_of_v = j,
                        GRids_in = GRIDS,
                        GRid_out = &TEMP_GRID,
                        name = ele_name,
                        disp = DRAW);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$place_surface_by_network
                        (num_of_u,                                      
                        num_of_v,                                       
                        GRids_in,                                       
                        GRid_out = &TEMP_GRID,                           
                        name = "0",                                     
                        disp = DRAW)                                    

surface_network((GRid_out),(num_of_u),(num_of_v),(GRids_in),(name),(disp));
#endomdef

/*---------------------- place$surface_by_network ----------------------

   place$surface_by_network( num_of_u,
			     num_of_v,
			     GRids_in,
			     GRid_out = TEMP_GRID,
			     name     = "0",
			     disp     = DRAW )

   md$place_surface_by_network( num_of_u,
                                num_of_v,
                                GRids_in,
                                GRid_out = &TEMP_GRID,
                                name     =  "0",
                                disp     =  DRAW)
-----------------------------------------------------------------------*/

#omdef place$surface_by_network( num_of_u,
			         num_of_v,
			         GRids_in,
			         GRid_out = TEMP_GRID,
			         name     = "0",
			         disp     = DRAW )

   surface_network( &(GRid_out),(num_of_u),(num_of_v),(GRids_in),(name),(disp))

#endomdef

/*---------------------- md$place_lsq_surface_linestrings --------------

#omdef md$place_lsq_surface_linestrings(
                        num_linestrings = 100,                          
                        GRids_in,                                       
                        GRid_out = &TEMP_GRID,                           
                        num_u_seg = 1,                                  
                        num_v_seg = 1,                                  
                        u_order = 3,                                    
                        v_order = 3,                                    
                        u_periodic = FALSE,                             
                        v_periodic = FALSE,                             
                        ave_err = &Ave_err,                              
                        max_err = &Max_err,                              
                        max_seg = double6,                              
                        name = "0",                                     
                        disp = DRAW)                                    
 Abstract:

        This macro will create a surface by least square fit to linestrings.

 Arguments:

        num_linestrings         I       int     number of input linestrings

        GRids_in                I       struct GRid  array of input linestrings

        GRid_out                O       struct GRid     output surface GRid

        num_u_seg               I       int             number of u segments
                                                        to create surface with.

        num_v_seg               I       int             number of v segments
                                                        to create surface with.

        u_order                 I       int             surface u order
        
        v_order                 I       int             surface v order

        u_periodic              I       int             is surface periodic 
                                                        in u direction.

        v_periodic              I       int             is surface periodic 
                                                        in v direction.

        ave_err                 O       double          output average error.

        max_err                 O       double          output maximum error.

        max_seg                 O       double[6]       output vector where
                                                        the maximum error
                                                        occures.

        name            I/O     IGRchar       Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:
        int             i;
        struct GRid     GRIDS[50];
        char            ele_name[255];

        message("surface by least sq fit");

        i=0;
        
        while(1)
        {
                if( !ci$locate( obj = &GRIDS[i].objid,
                           osnum = &GRIDS[i].osnum,
                           classes = "GRlinear",
                           prompt= "Identify linestring")) break;
                i=i+1;
                if(i == 50) break;
        }
        
        strcpy(ele_name, "surf_lsq");    
        md$place_lsq_surface_linestrings
                        (num_linestrings = i,
                        GRids_in = GRIDS,
                        GRid_out = &TEMP_GRID,   
                        num_u_seg = 1,  
                        num_v_seg = 1,
                        u_order = 3,
                        v_order = 3,
                        ave_err = &Ave_err,
                        max_err = &Max_err,
                        max_seg = double6,
                        name = ele_name,
                        disp = DRAW);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$place_lsq_surface_linestrings
                        (num_linestrings = 100,                         
                        GRids_in,                                       
                        GRid_out = &TEMP_GRID,                           
                        num_u_seg = 1,                                  
                        num_v_seg = 1,                                  
                        u_order = 3,                                    
                        v_order = 3,                                    
                        u_periodic = FALSE,                             
                        v_periodic = FALSE,                             
                        ave_err = &Ave_err,                              
                        max_err = &Max_err,                              
                        max_seg = double6,                              
                        name = "0",                                     
                        disp = DRAW)                                    

surface_lsq(    GRid_out,num_linestrings,GRids_in,u_order,v_order,
                u_periodic,v_periodic,num_u_seg,num_v_seg,ave_err,
                max_err,max_seg,name,disp);
#endomdef

/*---------------------- place$lsq_surface_linestrings --------------

   place$lsq_surface_linestrings( num_linestrings,
				  GRids_in,
				  GRid_out = TEMP_GRID,
				  num_u_seg = 1,
				  num_v_seg = 1,
				  u_order   = 3,
				  v_order   = 3,
				  u_periodic = FALSE,
				  v_periodic = FALSE,
				  ave_err    = Ave_err,
				  max_err    = Max_err,
				  max_seg    = double6,
				  name       = "0",
				  disp       = DRAW )

   md$place_lsq_surface_linestrings( num_linestrings = 100,
                                     GRids_in,
                                     GRid_out        = &TEMP_GRID,
                                     num_u_seg       =  1,
                                     num_v_seg       =  1,
                                     u_order         =  3,
                                     v_order         =  3,
                                     u_periodic      =  FALSE,
                                     v_periodic      =  FALSE,
                                     ave_err         = &Ave_err,
                                     max_err         = &Max_err,
                                     max_seg         =  double6,
                                     name            =  "0",
                                     disp            =  DRAW )
-----------------------------------------------------------------------*/

#omdef place$lsq_surface_linestrings( num_linestrings,
				      GRids_in,
				      GRid_out  = TEMP_GRID,
				      num_u_seg = 1,
				      num_v_seg = 1,
				      u_order   = 3,
				      v_order   = 3,
				      u_periodic = FALSE,
				      v_periodic = FALSE,
				      ave_err    = Ave_err,
				      max_err    = Max_err,
				      max_seg    = double6,
				      name       = "0",
				      disp       = DRAW )

   surface_lsq( &(GRid_out),(num_linestrings),(GRids_in),(u_order),(v_order),
                (u_periodic),(v_periodic),(num_u_seg),(num_v_seg),(ave_err),
                (max_err),(max_seg),(name),(disp))

#endomdef

/*---------------------- md$free_surface --------------------------

#omdef md$free_surface
                ( surface_struct = bspline_surfacep) 

 Abstract:

        This macro is used to free up the memory allocated by the
        md$get_surface_geometry().

 Arguments:

        surface_struct          I   struct IGRbspline_surface   the surface
                                                                structure to
                                                                be freed.
                                                

 Sample Call:
        int     i;

        message("get and put surface geometry");

        ci$locate( obj   = &TEMP_GRID.objid,
                   osnum = &TEMP_GRID.osnum,
                   classes = "EMSsubbs",
                   prompt= "Identify surface");

        md$get_surface_geometry
                        (GRid_in    = TEMP_GRID,                        
                        surface_struct = bspline_surfacep);

        for(i=0;i<bspline_surfacep->u_num_poles*3; i=i+3)
        {
                bspline_surfacep->poles[i]= bspline_surfacep->poles[i] + 2;
        }

        md$put_surface_geometry
                        (GRid_in  = TEMP_GRID,                  
                        surface_struct = bspline_surfacep,              
                        disp = DRAW);
        
        md$free_surface
                ( surface_struct = bspline_surfacep);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/
#omdef md$free_surface
                ( surface_struct = bspline_surfacep) 

free_surface(surface_struct);
#endomdef

/*---------------------- free$surface --------------------------
-----------------------------------------------------------------------*/

#omdef free$surface( surface_struct = bspline_surfacep )

   free_surface( (surface_struct))

#endomdef


double  ePNt1[3], ePNt2[3];

/*---------------------- md$place_fillet_surface ---------------------

#omdef md$place_fillet_surface(
                        GRids_in = TEMP_GRIDS,                          
                        GRid_out = &TEMP_GRID,                           
                        radius1 = 1,                                    
                        radius2 = 1,                                    
                        side1  = 0,                                     
                        side2  = 0,                                     
                        point1 = ePNt1,                                 
                        point2 = ePNt2,                                 
                        rho    = .4142,                                 
                        name   = "0",                                   
                        disp   = DRAW)                                  
 Abstract:

        This macro will create a fillet surface.

 Arguments:

        GRids_in        I       struct GRid     the two input surfaces

        GRid_out        O       struct GRid     output surface GRid

        radius1         I       double          start radius for fillet.

        radius2         I       double          end radius for fillet.

        side1           I       int             side of surface 1 to
                                                        place fillet on.

        side2           I       int             side of surface 2 to
                                                        place fillet on.


        point1          I       double[3]       point for the start
                                                        of fillet.

        point2          I       double[3]       point for the end
                                                        of fillet.


        rho             I       double          rho is the type of
                                                        fillet to be created.
                                                        .4142 is circular, 0
                                                        would be a chamfer.

        name            I/O     IGRchar        Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:
        int             i;
        struct GRid     GRIDS[50];
        double          point1[3], point2[3], rad1, rad2, rho, nat1, nat2;
        char            ele_name[255];
    
        message("surface fillet");

        i=0;
        
        while(1)
        {
                if( !ci$locate( obj = &GRIDS[i].objid,
                           osnum = &GRIDS[i].osnum,
                           classes = "EMSsurface",
                           prompt= "Identify surface")) break;
                i=i+1;
                if(i == 2) break;
        }

        ci$get( point=point1, prompt="ident start point");
        ci$get( point=point2, prompt="ident end point");
        ci$get( value = rad1, prompt="key in start radius");
        ci$get( value = rad2, prompt="key in end radius");
        ci$get( value = rho, prompt="key in rho");
        ci$get( value = nat1, prompt="key in nat side1");
        ci$get( value = nat2, prompt="key in nat side2");

        strcpy(ele_name, "fillet");
        md$place_fillet_surface
                        (GRids_in = GRIDS,      
                        GRid_out = &TEMP_GRID,   
                        radius1 = rad1, 
                        radius2 = rad2, 
                        side1  = nat1,  
                        side2  = nat2,  
                        point1 = point1,        
                        point2 = point2,
                        rho    = rho,   
                        name   = ele_name,      
                        disp   = DRAW);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/
#omdef md$place_fillet_surface
                       (GRids_in = TEMP_GRIDS,                         
                        GRid_out = &TEMP_GRID,                           
                        radius1 = 1,                                    
                        radius2 = 1,                                    
                        side1  = 0,                                     
                        side2  = 0,                                     
                        point1 = ePNt1,                                 
                        point2 = ePNt2,                                 
                        rho    = .4142,                                 
                        name   = "0",                                   
                        disp   = DRAW)                                  

fillet_surface(GRids_in,radius1,radius2,side1,side2,point1,point2,rho,GRid_out,name,disp)\

#endomdef


/*---------------------- md$offset_surface -------------------


#omdef md$offset_surface(
                        GRid_in = TEMP_GRID,                            
                        GRid_out = &TEMP_GRID_NEW,                       
                        side = TRUE,                                    
                        distance,                                  
                        option = TRUE,                                  
                        obj_name = "0",                                     
                        disp = DRAW)                                    
 Abstract:

        This macro will create an offset surface.

 Arguments:

        GRid_in         I       struct GRid     input surface

        GRid_out        O       struct GRid     output surface GRid

        side            I       IGRboolean      should offset be on natural
                                                normal side.

        distance        I       double          offset distance value.

        option          I       IGRushort       If TRUE, any boundaries on the
                                                original surface will be copied
                                                to the new offset surface.

        obj_name        I/O     IGRchar        Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:

                double  offset_distance;
                char    ele_name[255];
                struct GRid TEMP_GRID,
                            TEMP_GRID_NEW;

                message("offset surface");

                ci$locate( obj = &TEMP_GRID.objid,
                           osnum = &TEMP_GRID.osnum,
                           classes = "EMSsurface",
                           owner_action = LC_RIGID_COMP | LC_RIGID_OWNER,
                           prompt= "Identify surface");

                ci$get( value = offset_distance, 
                        prompt="key in offset distance value");

                strcpy(ele_name, "offset");
                md$offset_surface
                        (GRid_in = TEMP_GRID,
                        GRid_out = &TEMP_GRID_NEW,
                        side = TRUE,    
                        distance = offset_distance,        
                        obj_name = ele_name,
                        disp = DRAW);
                        
 Notes:   The macro can now offset single as well as composite
          surfaces. 

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

       16/12/93 Vadi    Rewrote the macro. 
-----------------------------------------------------------------------*/
struct GRvg_construct construct_list;
struct IGRdisplay display_attr;
IGRint nret, bufsize;

#omdef md$offset_surface
                       (GRid_in = TEMP_GRID,                           
                        GRid_out = &TEMP_GRID_NEW,                       
                        side = TRUE,                                    
                        distance,  
                        option = TRUE,                                  
                        obj_name = "0",                                     
                        disp = DRAW)                                    

set_up_easy();

bufsize = sizeof(struct IGRdisplay);
gr$get_active_display(msg = &rtcd,
                      sizbuf = &bufsize,
                      buffer = &display_attr,
                      nret = &nret);

construct_list.msg = &rtcd;
construct_list.env_info = &MOD_ENV;
construct_list.newflag = FALSE;
construct_list.level = 1;
construct_list.geometry = NULL;
construct_list.display = &display_attr;
construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
construct_list.class_attr = NULL;
construct_list.name = NULL;

ci$send(msg = message EMSsurface.EMoffset(&rtcd,
        (option), &(MOD_ENV).md_env.matrix_type, 
        (MOD_ENV).md_env.matrix, &construct_list,
        (side), (distance), 0, NULL,
        NULL, 0, NULL, NULL, &(GRid_out)->objid, NULL),
        targetid = (GRid_in).objid,
        targetos = (GRid_in).osnum);
        
(*(GRid_out)).osnum = MOD_ENV.md_id.osnum;

name_display((*(GRid_out)), (obj_name), (disp))
#endomdef

/*---------------------- md$show_normals ---------------------------------

#omdef md$show_normals
                (GRid_in = TEMP_GRID, disp = HILITE )
                
 Abstract:

        This macro will display the normals of surfaces, composites surfaces,
        and solids.

 Arguments:
        
        GRid_in         I       struct GRid     Input surface/solid id.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:


        message("show surface normals");

        ci$locate( obj   = &TEMP_GRID.objid,
                   osnum = &TEMP_GRID.osnum,
                   classes = "EMSsurface",
                   prompt= "Identify surface");

        md$show_normals(GRid_in = TEMP_GRID, disp = HILITE );

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$show_normals
                (GRid_in = TEMP_GRID, disp = HILITE )           

 show_normals(GRid_in,disp)
#endomdef

/*---------------------- show$normals ---------------------
-----------------------------------------------------------------------*/

#omdef show$normals( GRid_in = TEMP_GRID,
		     disp    = HILITE )

   show_normals( (GRid_in), (disp) )

#endomdef

/*---------------------- md$int_plane_save_side ---------------------

#omdef md$int_plane_save_side
                       (GRid_in = TEMP_GRID,                           
                        GRid_out = &TEMP_GRID_NEW,                       
                        point1,                                         
                        point2,                                         
                        point3,                                         
                        point4,                                         
                        name = "0",                                     
                        disp = DRAW)                                    

 Abstract:

        This macro will cut a surface/ composite surface/ solid with
        a plane and trim it to the plane.

 Arguments:

        GRid_in         I       struct GRid     input surface

        GRid_out        O       struct GRid     output surface/solid id

        point1          I       double[3]       point 1 of plane.               

        point2          I       double[3]       point 2 of plane.               

        point3          I       double[3]       point 3 of plane.               

        point4          I       double[3]       point 4 is side to save.

        name            I/O     IGRchar         Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:

        struct GRid     my_surface;
        double          point1[3], point2[3], point3[3], point4[3];     
        char            ele_name[255];

        message("intersect plane save side");

        ci$locate( obj = &my_surface.objid,
                           osnum = &my_surface.osnum,
                           classes = "EMSsurface",
                           prompt= "Identify surface");

        ci$get( point=point1, prompt="point 1 of plane");
        ci$get( point=point2, prompt="point 2 of plane");
        ci$get( point=point3, prompt="point 3 of plane");
        ci$get( point=point4, prompt="side point");

        strcpy(ele_name, "save_side");
        md$int_plane_save_side
                       (GRid_in = my_surface,
                        point1 = point1,
                        point2 = point2,
                        point3 = point3,
                        point4 = point4,        
                        name = ele_name,
                        disp = DRAW);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$int_plane_save_side
                       (GRid_in = TEMP_GRID,                           
                        GRid_out = &TEMP_GRID_NEW,
                        point1,                                         
                        point2,                                         
                        point3,                                         
                        point4,                                         
                        name = "0",                                     
                        disp = DRAW)                                    
 
int_plane_save_side(point1,point2,point3,point4,GRid_in,GRid_out,name,disp);

#if   !om$specified(GRid_out)
      TEMP_GRID = TEMP_GRID_NEW;
#endif
#endomdef

/*---------------------- int$plane_save_side ---------------------

   int$plane_save_side( GRid_in = TEMP_GRID,
			GRid_out = TEMP_GRID_NEW,
			point1,
			point2,
			point3,
			point4,
			name = "0",
			disp = DRAW )

   md$int_plane_save_side( GRid_in = TEMP_GRID,
                           GRid_out = &TEMP_GRID_NEW,
                           point1,
                           point2,
                           point3,
                           point4,
                           name = "0",
                           disp = DRAW )
-----------------------------------------------------------------------*/

#omdef int$plane_save_side( GRid_in  = TEMP_GRID,
			    GRid_out = TEMP_GRID_NEW,
			    point1,
			    point2,
			    point3,
			    point4,
			    name     = "0",
			    disp     = DRAW )

   int_plane_save_side( (point1),(point2),(point3),(point4),
			(GRid_in),&(GRid_out),(name),(disp))

#if (! om$specified(GRid_out))
      TEMP_GRID = TEMP_GRID_NEW;
#endif

#endomdef

/*---------------------- md$int_plane ---------------------------------

#omdef md$int_plane
                       (GRid_in = TEMP_GRID,                           
                        num_cuts = 1,                                   
                        GRids_out = TEMP_GRIDS,                         
                        num_GRids_out = &num_ints,                       
                        point1,                                         
                        point2,                                         
                        point3,                                         
                        point4,                                         
                        trim = TRUE,
                        name = "0",                                     
                        disp = DRAW)                                    
 Abstract:

        This macro will intersect a surface/solid with a plane with
        multiple cuts.

 Arguments:

        num_cuts        I       int             number of cuts to make

        GRid_in         I       struct GRid     input surface

        num_GRids_out   O       int             number of output linestrings
        
        GRid_out        O       struct GRid     output surface/solid id

        point1          I       double[3]       point 1 of plane.              

        point2          I       double[3]       point 2 of plane.              

        point3          I       double[3]       point 3 of plane.              

        point4          I       double[3]       point 4 is the end of the 
                                                parallel planes.

        trim            I       int             do you want to trim to
                                                boundaries. TRUE for trim,
                                                FALSE to ignore boundaries.

        name            I/O     char           Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:

        int             i;
        struct GRid     GRIDS[1];
        double          point1[3], point2[3], point3[3], point4[3];     
        char            ele_name[255];

        message("intersect plane");

        ci$locate( obj     = &GRIDS[0].objid,
                   osnum   = &GRIDS[0].osnum,
                   classes = "EMSsurface",
                   prompt  = "Identify surface");

        ci$get( point=point1, prompt="point 1 of plane");
        ci$get( point=point2, prompt="point 2 of plane");
        ci$get( point=point3, prompt="point 3 of plane");
        ci$get( point=point4, prompt="end point");
        ci$get( value=i, prompt="key in number of intersections");
        strcpy(ele_name, "int_planes");
        md$int_plane
                (GRid_in      = GRIDS[0],       
                num_cuts      = i,      
                GRids_out     = TEMP_GRIDS,
                num_GRids_out = &i,
                point1        = point1, 
                point2        = point2, 
                point3        = point3, 
                point4        = point4, 
                trim          = TRUE,
                name          = ele_name,
                disp          = DRAW);
 
 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$int_plane
                       (GRid_in = TEMP_GRID,                           
                        num_cuts = 1,                                   
                        GRids_out = TEMP_GRIDS,                         
                        num_GRids_out = &num_ints,                       
                        point1,                                         
                        point2,                                         
                        point3,                                         
                        point4,                                         
                        trim = TRUE,
                        name = "0",                                     
                        disp = DRAW)                                    
 
intersect_w_plane(!(trim),num_cuts,point1,point2,point3,point4,GRid_in,GRids_out,num_GRids_out,name,disp) 
#endomdef

/*----------------------  int$plane_trim ---------------------------

#omdef int$plane_trim
                      ( GRid_in       = TEMP_GRID,
                        num_cuts      = 1,
                        GRids_out     = TEMP_GRIDS,
                        num_GRids_out = &num_ints,
                        point1,
                        point2,
                        point3,
                        point4,
                        name          = "0",
                        disp          = DRAW )

-----------------------------------------------------------------------*/

#omdef int$plane_trim
                      ( GRid_in       = TEMP_GRID,
                        num_cuts      = 1,
                        GRids_out     = TEMP_GRIDS,
                        num_GRids_out = &num_ints,
                        point1,
                        point2,
                        point3,
                        point4,
                        name          = "0",
                        disp          = DRAW )
 
   intersect_w_plane( 0,num_cuts,point1,point2,point3,point4,
		      GRid_in,GRids_out,num_GRids_out,name,disp )

#endomdef

/*----------------------  int$plane_notrim ----------------------

#omdef int$plane_notrim
                      ( GRid_in       = TEMP_GRID,
                        num_cuts      = 1,
                        GRids_out     = TEMP_GRIDS,
                        num_GRids_out = &num_ints,
                        point1,
                        point2,
                        point3,
                        point4,
                        name          = "0",
                        disp          = DRAW )

-----------------------------------------------------------------------*/

#omdef int$plane_notrim
                      ( GRid_in       = TEMP_GRID,
                        num_cuts      = 1,
                        GRids_out     = TEMP_GRIDS,
                        num_GRids_out = &num_ints,
                        point1,
                        point2,
                        point3,
                        point4,
                        name          = "0",
                        disp          = DRAW )
 
   intersect_w_plane( 1,num_cuts,point1,point2,point3,point4,
		      GRid_in,GRids_out,num_GRids_out,name,disp )

#endomdef

/*----------------------  md$int_planes_cross ----------------------

#omdef md$int_planes_cross
                       (GRid_in = TEMP_GRID,                           
                        num_cuts = 1,                                   
                        GRids_out = TEMP_GRIDS,                         
                        num_GRids_out = &num_ints,
                        point1,                                         
                        point2,                                         
                        point3,                                         
                        point4,                                         
                        name = "0",                                     
                        disp = DRAW)                                    
 Abstract:

        This macro will do an intersect with multiple parallel planes
        and create parallel planes trimmed to the boundaries of the 
        intersections so the user can cross hatch the sections.

 Arguments:

        num_cuts        I       int             number of cuts to make

        GRid_in         I       struct GRid     input surface

        num_GRids_out   O       int             number of output linestrings
        
        GRid_out        O       struct GRid     output surface/solid id

        point1          I       double[3]       point 1 of plane.              

        point2          I       double[3]       point 2 of plane.              

        point3          I       double[3]       point 3 of plane.              

        point4          I       double[3]       point 4 is the end of the 
                                                parallel planes.

        name            I/O     IGRchar        Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:
        int             i;
        struct GRid     my_surface;
        double          point1[3], point2[3], point3[3], point4[3];     
        char            ele_name[255];

        message("intersect plane and cross hatch");

        ci$locate( obj = &my_surface.objid,
                   osnum = &my_surface.osnum,
                   classes = "EMSsurface",
                   prompt= "Identify surface");

        ci$get( point=point1, prompt="point 1 of plane");
        ci$get( point=point2, prompt="point 2 of plane");
        ci$get( point=point3, prompt="point 3 of plane");
        ci$get( point=point4, prompt="side point");
        ci$get( prompt="key in number of intersections", value=i);

        strcpy(ele_name, "cross");
        md$int_planes_cross(
                            GRid_in = my_surface,     
                            num_cuts = i,
                            GRids_out = TEMP_GRIDS,
                            num_GRids_out = &i,
                            point1 = point1,                
                            point2 = point2,
                            point3 = point3,        
                            point4 = point4,
                            name = ele_name,
                            disp = DRAW);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$int_planes_cross
                       (GRid_in = TEMP_GRID,                           
                        num_cuts = 1,                                   
                        GRids_out = TEMP_GRIDS,                         
                        num_GRids_out = &num_ints,
                        point1,                                         
                        point2,                                         
                        point3,                                         
                        point4,                                         
                        name = "0",                                     
                        disp = DRAW)                                    

intersect_w_plane(3,num_cuts,point1,point2,point3,point4,GRid_in,GRids_out,num_GRids_out,name,disp) 
#endomdef

/*----------------------  int$plane_cross ----------------------
-----------------------------------------------------------------------*/

#omdef int$plane_cross( GRid_in       = TEMP_GRID,
                        num_cuts      = 1,
                        GRids_out     = TEMP_GRIDS,
                        num_GRids_out = &num_ints,
                        point1,
                        point2,
                        point3,
                        point4,
                        name          = "0",
                        disp          = DRAW )

   intersect_w_plane( 3,(num_cuts),(point1),(point2),(point3),(point4),
		      (GRid_in),(GRids_out),(num_GRids_out),(name),(disp)) 

#endomdef

/*---------------------- md$place_iso_curves ---------------------------------

#omdef md$place_iso_curves
                        (GRid_in    = TEMP_GRID,                              
                        GRids_out  = TEMP_GRIDS,                        
                        trim       = TRUE,                              
                        num_params = TRUE,                              
                        params     = FALSE,                             
                        direction  = FALSE,                             
                        num_isos   = &number_isos,                       
                        name       = "0",                               
                        disp       = DRAW)                              

 Abstract:

        this macro will create isoparametric curves from a surface.

 Arguments:
        GRid_in         I       struct GRid     input surface id

        GRids_out       O       struct GRid     output curve id's

        trim            I       int             do you want the curves to
                                                be trimmed to boundaries?

        num_params      I       int             number of input parameters
                                                
        params          I       double[?]       input parameters for iso curves
                                                to generated to.

        direction       I       int             direction 0=U or 1=V

        num_isos        O       int             output number of iso curves 
                                                created.


        name            I/O     IGRchar        Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:

        struct GRid     SURFACE, CURVES[10];
        int             num_in, num_out, response, direction;
        double          parameters[10];
        char            *string1;

        message("Create iso curves");

        ci$locate( obj   = &SURFACE.objid,
                   osnum = &SURFACE.osnum,
                   classes = "EMSsubbs",
                   prompt= "Identify surface");

        ci$get(value = direction,
               prompt = "key in 0 for U, 1 for V direction");

        num_in = 0;

        while(1)
        {
                ci$getevent(    prompt = "Key in parameter to place curve",
                                mask =  GRm_RJT_MOVEON | GRm_BACK_UP | 
                                        GRm_STRING | GRm_DATA | GRm_OBJID,
                                data = string1, 
                                response = &response);

                if( (response == EX_RJT_MOVEON) || 
                    (response == EX_BACK_UP )) break;

                if( response == STRING)
                {
                  parameters[num_in] = atof(string1);
                  num_in = num_in + 1;
                }
                if (num_in >= 10) break;
        }
        md$place_iso_curves(
                        GRid_in    = SURFACE,                           
                        GRids_out  = CURVES,                    
                        trim       = TRUE,                              
                        num_params = num_in,                            
                        params     = parameters,                              
                        direction  = FALSE,                             
                        num_isos   = &num_out,                   
                        name       = "0",                               
                        disp       = DRAW);             
 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

// PLACE ISO CURVES ON SURFACE
int     number_isos;

#omdef md$place_iso_curves
                        (GRid_in   = TEMP_GRID,                             
                        GRids_out  = TEMP_GRIDS,                        
                        trim       = TRUE,                              
                        num_params = TRUE,                              
                        params     = FALSE,                             
                        direction  = FALSE,                             
                        num_isos   = &number_isos,                       
                        name       = "0",                               
                        disp       = DRAW)                              

create_iso_curves((trim),(num_params),(params),(direction),(num_isos),
                (GRids_out),(GRid_in),(name),(disp));

#if   !om$specified(num_params)
      TEMP_GRID = TEMP_GRIDS[0];
#endif
#endomdef


/*---------------------- place$iso_curves ---------------------------------

   place$iso_curves( GRid_in    = TEMP_GRID,
		     GRids_out  = TEMP_GRIDS,
		     trim       = TRUE,
		     num_params = TRUE,
		     params     = FALSE,
		     direction  = FALSE,
		     num_isos   = number_isos,
		     name       = "0",
		     disp       = DRAW )

   md$place_iso_curves( GRid_in    =  TEMP_GRID,
                        GRids_out  =  TEMP_GRIDS,
                        trim       =  TRUE,
                        num_params =  TRUE,
                        params     =  FALSE,
                        direction  =  FALSE,
                        num_isos   = &number_isos,
                        name       =  "0",
                        disp       =  DRAW )
-----------------------------------------------------------------------*/

#omdef place$iso_curves( GRid_in    = TEMP_GRID,
		         GRids_out  = TEMP_GRIDS,
		         trim       = TRUE,
		         num_params = TRUE,
		         params     = FALSE,
		         direction  = FALSE,
		         num_isos   = number_isos,
		         name       = "0",
		         disp       = DRAW )

   create_iso_curves((trim),(num_params),(params),(direction),&(num_isos),
                (GRids_out),(GRid_in),(name),(disp))

#endomdef


/*---------------------- md$get_attributes -------------------

#omdef md$get_attributes(
                        GRid_in  = TEMP_GRID,
                        attr_struct)

 Abstract:

	This macro will retrieve the element specific attributes of an
	object. The object can be a curve or a surface. 
	
 Arguments:

        GRid_in         I       struct GRid     Input GRid of the object.

        attr_struct     O       struct IGResbs or IGResbc depending on whether
                                                it is a curve or a surface.
                                                structures defined in
                                                igrdp.h
 Sample Call:

main()
{
        int             i, type;
        struct GRid     SURFACE;
        struct IGResbs  sfatt; // structure defined in igrdp.h

   message("get surface attributes");

   while(1)
   {   

        ci$locate( obj   = &SURFACE.objid,
                   osnum = &SURFACE.osnum,
                   classes = "EMSsubbs",
		   owner_action = LC_RIGID_COMP | LC_FLEX_COMP 
		                  | LC_REF_OBJECTS, 
                   md_env = &MOD_ENV,
                   prompt= "Identify surface to get attributes about");

        md$get_attributes( 
                        GRid_in =SURFACE,
                        attr_struct = &sfatt);

        write("******************* surface attributes *******************\n");
        write("Num u rules = ", sfatt.u_rules,"\n");
        write("Num v rules = ", sfatt.v_rules,"\n");
        if(sfatt.is_polydis == 1)
         write("Polygon display is ON\n");
        else
         write("Polygon display is OFF\n");
        if(sfatt.is_slowdis == 1)
         write("Slow display (equal arc length) is ON\n");
        else
         write("Fast display (equal parameter) is ON\n");
  }
}


 History:

        4/9/92  SM     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$get_attributes(
                        GRid_in  = TEMP_GRID,
                        attr_struct)



        get_attributes( GRid_in, attr_struct);

#endomdef



/*---------------------- md$get_rule_line_table -------------------

#omdef md$get_rule_line_table(
                        GRid_in  = TEMP_GRID,
                        md_env = MOD_ENV, 
                        include_natural = 0, 
                        rlt)

 Abstract:

	This macro will retrieve the rule line table of a surface.
	
 Arguments:

        GRid_in         I       struct GRid     Input GRid of the object.

        md_env          I       struct GRmd_env input module environment, this
                                                is only need if the object
                                                resides in a reference file 
                                                and you want the information
                                                relative to the active file.
        include_natural I       short           flag indicating whether natural
                                                edges of the surfaces should
                                                be included in the table
        rlt             O       struct IGResqbs The rule line table. Structure
                                                defined in igrdp.h. Memory
                                                allocated internally and
                                                to be freed by the caller.
 Sample Call:

main()
{
        int             i, type, j;
        struct GRid     SURFACE;
        struct IGResqbs *rlt; // structure defined in igrdp.h

   message("get surface rule line table");
   rlt = 0x0;
   while(1)
   {   
        ci$locate( obj   = &SURFACE.objid,
                   osnum = &SURFACE.osnum,
                   classes = "EMSsubbs",
		   owner_action = LC_RIGID_COMP | LC_FLEX_COMP 
		                  | LC_REF_OBJECTS, 
                   md_env = &MOD_ENV,
                   prompt= "Identify surface to get rule line table from");

        md$get_rule_line_table(
                        GRid_in =SURFACE,
                        rlt = &rlt);


       write("Number of U rules -- ", rlt->u_rules, "\n");
       if(rlt->u_rules)
        {
         write("\n", "U rules:\n");
         for(i = 0; i < rlt->u_rules; i = i+1)
          {
           write("\n", rlt->u_rule_values[i]);
           if(rlt->u_num_bound[i])
            {
             write("\tboundaries:\n", rlt->u_num_bound[i]);
             for(j = 0; j < rlt->u_num_bound[i] * 2; j = j+1)
              {
               write("\t\n", rlt->u_bdrys[i][j]);
               j = j+1;
               write("\t\n", rlt->u_bdrys[i][j]);
              }
            }
          }
        }
       write("\n");
       write("Number of V rules -- ", rlt->v_rules, "\n");
       if(rlt->v_rules)
        {
         write("\n", "V rules:\n");
         for(i = 0; i < rlt->v_rules; i = i+1)
          {
           write("\n", rlt->v_rule_values[i]);
           if(rlt->v_num_bound[i])
            {
             write("\tboundaries:\n", rlt->v_num_bound[i]);
             for(j = 0; j < rlt->v_num_bound[i] * 2; j = j+1)
              {
               write("\t\n", rlt->v_bdrys[i][j]);
               j = j+1;
               write("\t\n", rlt->v_bdrys[i][j]);
              }
            }
          }
        }
     write("\n");
     if(rlt) free(rlt);
     rlt = 0x0;
  }
}

 History:

        4/9/92  SM     Created and documented.

-----------------------------------------------------------------------*/


#omdef md$get_rule_line_table(
                        GRid_in  = TEMP_GRID,
                        md_env = MOD_ENV, 
                        include_natural = 0, 
                        rlt)

#if   !om$specified(md_env)
        ci$get_module_info( md_env = &MOD_ENV);
        get_rule_line_table(GRid_in, MOD_ENV, include_natural, rlt);
#else
        get_rule_line_table(GRid_in, MOD_ENV, include_natural, rlt);
#endif

#endomdef

/*---------------------- md$int_elems ---------------------------------

#omdef md$int_elems
                       (GRid1_in,
			GRid2_in, 
                        GRids_out,                         
                        num_GRids_out,                       
                        trim = TRUE), 
 Abstract:

        This macro will intersect 2 elements (curve/curve, surface/surface, 
        or curve/surface).

 Arguments:

        GRid1_in        I       struct GRid     input element 1

        GRid2_in        I       struct GRid     input element 2

        num_GRids_out   O       * int           number of output objects
        
        GRids_out       O       ** struct GRid  output intersection objects
						Must be initialized to
						NULL. Memory to be freed
						by the caller.
						
        trim            I       int             do you want to trim to
                                                boundaries. TRUE for trim,
                                                FALSE to ignore boundaries.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:

main()
{
        int             i;
        struct GRid     GRIDS[2], *GRid_out;
 
        message("intersect 2 elements");

        ci$locate( obj     = &GRIDS[0].objid,
                   osnum   = &GRIDS[0].osnum,
                   classes = "GRvg",
                   prompt  = "Identify element 1");
        ci$locate( obj     = &GRIDS[1].objid,
                   osnum   = &GRIDS[1].osnum,
                   classes = "GRvg",
                   prompt  = "Identify element 2");

        GRid_out = NULL;
        i = 0;

        md$int_elems
                (GRid1_in      = GRIDS[0],
                 GRid2_in      = GRIDS[1], 
                 GRids_out     = &GRid_out,
                 num_GRids_out = &i);
        if(GRid_out) free(GRid_out);
}

 Notes:

 Caveats:

 History:

        3/22/93  SM     Created and documented.

-----------------------------------------------------------------------*/

#omdef md$int_elems
                       (GRid1_in,
			GRid2_in, 
                        GRids_out,                         
                        num_GRids_out,                       
                        trim = TRUE, 
                        disp = DRAW)
 
intersect_two_elems((trim), (GRid1_in), (GRid2_in), (GRids_out), (num_GRids_out), (disp)) 
#endomdef

/*******
        THESE ARE THE SUPPORTING FUNCTIONS FOR EACH OF THE ABOVE
        MACROS. THESE ARE SUBJECT TO CHANGE SO I DON'T RECOMEND
        THE COPYING OF THE CODE BELOW FOR USE.
*******/

// GET ANALYTICAL SURFACE DATA
IGRushort Sf_Type;

#define get_analytical_surface_info( object, anl, type, md_env)\
\
        ci$send( msg = message EMSsurface.EMget_params(\
                &rtcd,\
                NULL,\
                &(md_env),\
                &Sf_Type,\
                (anl)),\
                targetid = (object).objid,\
                targetos = (object).osnum);\
        (*(type)) = Sf_Type;


// GET THE BSPLINE SURFACE DATA STRUCTURE FROM AN GRID
int                     size_of_surface;
struct IGRbsp_surface   *bspline_surfacep;
IGRchar                 *geometry123;

#define get_surface_geometry(surface,srf_struct)\
\
        set_up_easy();\
\
        ci$send( msg = message GRvg.GRgetsize(\
                &rtcd,\
                &MOD_ENV.md_env.matrix_type,\
                MOD_ENV.md_env.matrix,\
                &size_of_surface),\
                targetid = (surface).objid,\
                targetos = (surface).osnum );\
        geometry123=malloc(size_of_surface);\
        ci$send( msg = message GRvg.GRgetgeom(\
                &rtcd,\
                &MOD_ENV.md_env.matrix_type,\
                MOD_ENV.md_env.matrix,\
                geometry123),\
                targetid = (surface).objid,\
                targetos = (surface).osnum);\
\
        (srf_struct) = (struct IGRbsp_surface *) geometry123;\
\
        ci$send( msg = message EMSsubbs.EMget_boundaries(\
                &rtcd,\
                &MOD_ENV.md_env.matrix_type,\
                MOD_ENV.md_env.matrix,\
                &srf_struct->on_off,\
                &srf_struct->num_boundaries,\
                &srf_struct->bdrys),\
                targetid = (surface).objid,\
                targetos = (surface).osnum );\

GRobj           *owdpR;

#define put_surface_geometry(surface,srf_struct,disp)\
        \
        set_up_easy();\
        \
        owdpR = (GRobj *) malloc(100 * sizeof(GRobj));\
        size_of_surface = 0;\
        ci$get_channel_objects(\
                                objid     = (surface).objid, \
                                osnum     = (surface).osnum,\
                                channname = "to_owners",\
                                obj_list  = owdpR,\
                                count     = &size_of_surface );\
        \
        if( size_of_surface > 0)\
        {\
           for(loop_inc = 0;loop_inc < size_of_surface; loop_inc=loop_inc+1)\
           {\
                om$get_classname( objid = owdpR[loop_inc],\
                                  osnum = (surface).osnum,\
                                  classname = object1name);\
                \
                if( om$is_ancestry_valid( subclassname   =  object1name,\
                              superclassname = "EMScompsurf" ) == 1 )\
                {\
                status("Error: surface is owned by solid/composite");\
                size_of_surface = -1;\
                }\
           }\
        }\
        if( size_of_surface >= 0)\
        {\
                size_of_surface = 0;\
                \
                ci$send( msg = message GRvg.GRpostabsg( \
                        &rtcd,\
                        &MOD_ENV,\
                        &size_of_surface,\
                        (srf_struct),\
                        &(surface).objid ),\
                        targetid = (surface).objid,\
                        targetos = (surface).osnum );\
                display_w_opt( (surface), (disp));\
        }\
        free(owdpR);

// FREE THE MEMORY FROM BSPLINE SURFACE STRUCTURE 
#define free_surface(srf_struct)  free((srf_struct));


// CREATE A CYLINDER SURFACE
struct EMSradius  cyl_radius1;

#define create_cylinder_surfacer(radius,pt1,pt2,object,name,disp)\
\
        set_up_easy();\
\
        (*(object)).objid = NULL_OBJID;\
        (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
        cyl_radius1.select = 0;\
        cyl_radius1.input.value = (radius);\
\
        ci$send( msg = message EMScylindr.EMcylinder_by_axis_n_radius(\
                &cst,\
                (pt1),\
                (pt2),\
                &cyl_radius1), \
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum );\
\
        name_display((*(object)), (name), (disp));


#define create_cylinder_surfacep(pt3,pt1,pt2,object,name,disp)\
\
        set_up_easy();\
\
        (*(object)).objid = NULL_OBJID;\
        (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
        cyl_radius1.select = 1;\
        cyl_radius1.input.pnt[0] = (pt3)[0];\
        cyl_radius1.input.pnt[1] = (pt3)[1];\
        cyl_radius1.input.pnt[2] = (pt3)[2];\
\
        ci$send( msg = message EMScylindr.EMcylinder_by_axis_n_radius(\
                &cst,\
                (pt1),\
                (pt2),\
                &cyl_radius1), \
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum );\
\
        name_display((*(object)), (name), (disp));

// CREATE A SPHERE SURFACE

double  sphere_radius, sphere_vector[3];

#define create_sphere_surfacer(radius,pt1,object,name,disp)\
\
        set_up_easy();\
\
        (*(object)).objid = NULL_OBJID;\
        (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
        sphere_radius = (radius);\
\
        ci$send( msg = message EMSsphere.EMsphere_by_center_radius(\
                &cst,\
                (pt1),\
                sphere_radius), \
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum );\
\
        name_display((*(object)), (name), (disp));


#define create_sphere_surfacep(pt3,pt1,object,name,disp)\
\
        set_up_easy();\
\
        (*(object)).objid = NULL_OBJID;\
        (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
        v_sub(pt3, pt1, sphere_vector);\
        sphere_radius = v_len(sphere_vector);\
\
        ci$send( msg = message EMSsphere.EMsphere_by_center_radius(\
                &cst,\
                (pt1),\
                sphere_radius), \
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum );\
\
        name_display((*(object)), (name), (disp));


// CREATE A TUBE SURFACE

double  tube_radius;
int     curve_size;

#define create_tube_surface(radius,bend_radii,curve,object,name,disp)\
\
        set_up_easy();\
        ci$get_module_info( md_env = &MOD_ENV);\
        ci$send(msg = message GRvg.GRgetsize(\
                &rtcd,\
                &MOD_ENV.md_env.matrix_type,\
                MOD_ENV.md_env.matrix,\
                &curve_size),\
                targetid = (curve).objid,\
                targetos = (curve).osnum);\
        geometry1234=malloc(curve_size);\
        ci$send( msg = message GRvg.GRgetgeom(\
                &rtcd,\
                &MOD_ENV.md_env.matrix_type,\
                MOD_ENV.md_env.matrix,\
                geometry1234),\
                targetid = (curve).objid,\
                targetos = (curve).osnum );\
\
        bspline_curvep = (struct IGRbsp_curve *) geometry1234;\
\
        if(bspline_curvep->order != 2 )\
        {\
           status("curve is not of order 2");\
        }\
        if(bspline_curvep->order == 2 )\
        {\
        tube_radius = (radius);\
        for( loop_inc = 0; loop_inc < bspline_curvep->num_poles; loop_inc=loop_inc+1 )\
        {\
              if( (bend_radii)[loop_inc] <= (radius) )\
                    double100[loop_inc] = (radius);\
              if( (bend_radii)[loop_inc] > (radius) )\
                    double100[loop_inc] = (bend_radii)[loop_inc];\
         }\
         (*(object)).objid = NULL_OBJID;\
         (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
         ci$send( msg = message EMSgenbs.EMplctbesrf( \
                &rtcd,\
                &MOD_ENV, \
                (curve), \
                tube_radius, \
                double100,\
                &cst ) , \
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum ); \
\
           if( rtcd != SUCCESS )\
           {\
              status("surface was not created");\
              (*(object)).objid = NULL_OBJID;\
           }\
           if( rtcd == SUCCESS )\
           {\
             for( loop_inc = 0; loop_inc < bspline_curvep->num_poles; loop_inc=loop_inc+1 )\
             {\
                    double100[loop_inc] = 0.0;\
             }\
             if( strcmp((name),"0") != 0 )\
             {\
               put_name(name, (*(object)) );\
             }\
             if((disp) != 1)\
             {\
                display = disp;\
                display_w_opt((*(object)), display);\
             }\
           status("");\
           }\
        }\
        free(geometry1234);


#define create_surface_pro(obj_in,bs_curve,pnt1,pnt2,object,name,disp)\
\
   set_up_easy();\
\
   (*(object)).objid = NULL_OBJID;\
   (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
   rtcd = ci$send( msg = message EMSproject.EMplace_surface_of_projection(\
                &cst,\
                (obj_in),\
                &MOD_ENV,\
                (bs_curve),\
                0,\
                pnt1,\
                pnt2,\
                0,\
                &(*(object)).objid),\
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum); \
\
        name_display((*(object)), (name), (disp));


struct GRlc_info        SURF_rev_locate;
int             rotaTion_flag;
double          SwEeP,StArT;
#define create_surface_rev(obj_in,point1,point2,st_ang,sw_ang,object,name,disp)\
\
   set_up_easy();\
\
   (*(object)).objid = NULL_OBJID;\
   (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
   SURF_rev_locate.located_obj = (obj_in);\
   SURF_rev_locate.module_info = MOD_ENV;\
\
   double6[0] = (point1)[0];\
   double6[1] = (point1)[1];\
   double6[2] = (point1)[2];\
   double6[3] = (point2)[0];\
   double6[4] = (point2)[1];\
   double6[5] = (point2)[2];\
   rotaTion_flag = 0;\
   if((sw_ang) == 0 || (sw_ang) == 360) rotaTion_flag = 1;\
\
   StArT = (st_ang);\
   SwEeP = (sw_ang);\
   ci$send( msg = message EMSrevol.EMrevolve_curve(\
                &cst,\
                &SURF_rev_locate,\
                NULL,\
                double6,\
                StArT,\
                SwEeP,\
                rotaTion_flag,\
                1,\
                &(*(object)).objid,\
                &rtcd),\
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum); \
\
   name_display((*(object)), (name), (disp));

struct GRlc_info        *croS, *traC;
IGRboolean              is_scaL, are_seC;

/*

#define skin_surface(on_site,scale,num_trc,num_crv,object,objects_in,name,disp)\
\
  set_up_easy();\
\
  (object).objid = NULL_OBJID;\
  (object).osnum = MOD_ENV.md_id.osnum;\
\
  is_scaL    = (on_site);\
  are_seC    = (scale);\
\
  ci$send(msg = message EMSgenbs.EMmove_cross_section(\
        &rtcd, &cst, (num_crv),\
        croS, (num_trc), traC,\
        is_scal, are_sec, org,\
        mat, xvec, yvec ),\
        targetid = (object).objid,\
        targetos = (object).osnum );\
*/


#define surface_boolean(num_obj,objects,operation,bdisp,object,name,disp)\
\
  set_up_easy();\
\
  cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;\
  cst.newflag    = FALSE;\
  (*(object)).objid = NULL_OBJID;\
  (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
  Objs = (GRobj *) malloc ( (num_obj) * sizeof(GRobj) );\
\
  ci$send(msg = message EMSsurface.EMmk_nat_bdry(\
                &rtcd, &MOD_ENV, 0),\
                targetid = (objects)[0].objid,\
                targetos = (objects)[0].osnum);\
  for(loop_inc=0;loop_inc<(num_obj)-1; loop_inc=loop_inc+1) \
  {\
        if((objects)[loop_inc+1].objid == 0 || (objects)[loop_inc+1].objid == NULL_OBJID) break;\
        ci$send(msg = message EMSsurface.EMmk_nat_bdry(\
                &rtcd, &MOD_ENV, 0),\
                targetid = (objects)[loop_inc+1].objid,\
                targetos = (objects)[loop_inc+1].osnum);\
        Objs[loop_inc] = (objects)[loop_inc+1].objid;\
  }\
\
  ci$send( msg = message EMSsfboolean.EMboolean( \
                &rtcd,\
                &MOD_ENV.md_env.matrix_type,\
                MOD_ENV.md_env.matrix,\
                (objects)[0].objid,\
                loop_inc,\
                Objs,\
                &cst,\
                (operation),\
                (bdisp),\
                NULL,NULL,NULL,NULL,NULL),\
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum);\
\
  free(Objs);\
  cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;\
  cst.newflag    = TRUE;\
  name_display((*(object)), (name), (disp));

short           Num_iN;
GRobj           *Objs;

#define create_composite_surface(object,num_in,obj_in,name,disp)\
\
   set_up_easy();\
\
   Num_iN=(num_in);\
\
   Objs = (GRobj *) malloc( Num_iN * sizeof(GRobj));\
\
   for(loop_inc = 0; loop_inc < Num_iN; loop_inc = loop_inc + 1)\
   {\
        if((obj_in)[loop_inc].objid == 0 ||(obj_in)[loop_inc].objid == NULL_OBJID) break;\
        Objs[loop_inc] = (obj_in)[loop_inc].objid;\
        ci$send(msg = message EMSsurface.EMmk_nat_bdry(\
                &rtcd,\
                &MOD_ENV,\
                0),\
                targetid = (obj_in)[loop_inc].objid,\
                targetos = (obj_in)[loop_inc].osnum);\
   }\
   Num_iN = loop_inc;\
   (*(object)).objid = NULL_OBJID;\
   (*(object)).osnum = MOD_ENV.md_id.osnum;\
   ci$send(msg = message EMSgencompsf.EMmake_comp(\
                &rtcd,\
                (num_in),\
                Objs,\
                &MOD_ENV),\
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum);\
   free(Objs);\
   name_display((*(object)), (name), (disp));

int     V_order,U_order,Num_crv;

#define direct_fit_surface_by_curves(order,num_curves,crvs_in,object,name,disp)\
\
   set_up_easy();\
\
  (*(object)).objid = NULL_OBJID;\
  (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
  croS = (struct GRlc_info *) malloc ( (num_curves)*sizeof(struct GRlc_info));\
  V_order = (order);\
  Num_crv = (num_curves);\
\
  for( loop_inc=0; loop_inc< Num_crv; loop_inc=loop_inc+1)\
  {\
        croS[loop_inc].located_obj = (crvs_in)[loop_inc];\
        croS[loop_inc].module_info = MOD_ENV;\
        croS[loop_inc].geom_parms.polygon_inx = 0;\
  }\
\
  rtcd = ci$send(msg= message EMSgenbs.EMdirect_fit_surface_by_curves(\
                V_order,\
                0,\
                Num_crv,\
                croS,\
                &cst),\
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum);\
  if( rtcd == 1) rtcd = SUCCESS;\
  free(croS);\
  name_display((*(object)), (name), (disp));

IGRboolean      U_per, V_per;

#define direct_fit_surface(uorder,vorder,uper,vper,num_curves,crvs_in,object,name,disp)\
\
   set_up_easy();\
\
  (*(object)).objid = NULL_OBJID;\
  (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
  U_order = (uorder);\
  V_order = (vorder);\
  U_per = (uper);\
  V_per = (vper);\
  Num_crv = (num_curves);\
  croS = (struct GRlc_info *) malloc ( (num_curves) * sizeof( struct GRlc_info));\
\
  for( loop_inc=0; loop_inc< Num_crv; loop_inc=loop_inc+1)\
  {\
        croS[loop_inc].located_obj = (crvs_in)[loop_inc];\
        croS[loop_inc].module_info = MOD_ENV;\
        croS[loop_inc].geom_parms.polygon_inx = 0;\
  }\
\
  rtcd = ci$send(msg= message EMSgenbs.EMdirect_fit_surface(\
                U_order,\
                V_order,\
                U_per,\
                V_per,\
                Num_crv,\
                croS,\
                &cst),\
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum);\
  if( rtcd == 1) rtcd = SUCCESS;\
  free(croS);\
  name_display((*(object)), (name), (disp));


// THIS WILL CREATE A SURFACE BY NETWORK OF CURVES
#define surface_network(object,numu,numv,curves,name,disp)\
\
   set_up_easy();\
\
  croS = (struct GRlc_info *) malloc ( (numu) * sizeof( struct GRlc_info));\
  for(loop_inc = 0; loop_inc < (numu); loop_inc = loop_inc + 1)\
  {\
     if((curves)[loop_inc].objid==0 || (curves)[loop_inc].objid == NULL_OBJID) exit; \
     croS[loop_inc].located_obj = (curves)[loop_inc];\
     croS[loop_inc].module_info = MOD_ENV;\
  }\
\
  traC = (struct GRlc_info *) malloc ( (numv) * sizeof( struct GRlc_info));\
  for(loop_inc1 = 0; loop_inc1 < (numv); loop_inc1 = loop_inc1 + 1)\
  {\
     if((curves)[loop_inc1].objid == 0 ||(curves)[loop_inc1].objid == NULL_OBJID)break;\
     traC[loop_inc1].located_obj = (curves)[loop_inc+loop_inc1];\
     traC[loop_inc1].module_info = MOD_ENV;\
  }\
  (*(object)).objid = NULL_OBJID;\
  (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
  ci$send(msg= message EMSgenbs.EMnetwork_of_curves(\
                &rtcd, &cst, (numu),\
                croS, loop_inc1, traC),\
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum);\
  free(croS);\
  free(traC);\
  name_display((*(object)), (name), (disp));


// THIS FUNCTION WILL CREATE A LEAST SQUARE FIT SURFACE TO LINESTRINGS

int     max_ind[2],num_crvs,U_spans,V_spans;
IGRboolean u_period,v_period;

#define surface_lsq(object,num_curves,curves,uorder,vorder,uper,vper,numu,numv,ave_err,max_err,max_seg,name,disp)\
\
   set_up_easy();\
\
   (*(object)).objid = NULL_OBJID;\
   (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
  num_crvs = (num_curves);\
  V_order = (vorder);\
  U_order = (uorder);\
  U_spans = (numu);\
  V_spans = (numv);\
  croS = (struct GRlc_info *) malloc ( (num_curves) * sizeof( struct GRlc_info));\
  for(loop_inc = 0; loop_inc < (num_curves); loop_inc = loop_inc + 1)\
  {\
     if((curves)[loop_inc].objid == 0 || (curves)[loop_inc].objid == NULL_OBJID) break;\
     croS[loop_inc].located_obj = (curves)[loop_inc];\
     croS[loop_inc].module_info = MOD_ENV;\
     croS[loop_inc].geom_parms.polygon_inx = 0;\
  }\
  num_crvs = loop_inc;\
  u_period = (uper);\
  v_period = (vper);\
  ci$send(msg= message EMSgenbs.EMleast_squares_fit_surface(\
                        U_order,\
                        V_order,\
                        u_period,\
                        v_period,\
                        num_crvs,\
                        croS,\
                        U_spans,\
                        V_spans,\
                        (ave_err),\
                        (max_err),\
                        max_ind,\
                        (max_seg),\
                        &cst),\
           targetid = (*(object)).objid,\
           targetos = (*(object)).osnum);\
    free(croS);\
    name_display((*(object)), (name), (disp));


short   *natS;
double  *radS;


#define fillet_surface(objects,rad1,rad2,nat1,nat2,point1,point2,rho,object,name,disp)\
\
   set_up_easy();\
\
  croS = (struct GRlc_info *) malloc ( 2 * sizeof( struct GRlc_info));\
  radS = (double *) malloc ( 9 * sizeof( double));\
  natS = (short *) malloc ( 2 * sizeof( short));\
  if( (nat1) < .5 )  natS[0] = 0;\
  if( (nat1) >= .5 ) natS[0] = 1;\
  if( (nat2) < .5 )  natS[1] = 0;\
  if( (nat2) >= .5 ) natS[1] = 1;\
  radS[0] = (rad1);\
  radS[1] = (rad2);\
  radS[2] = (rho);\
  if( (rho) < 0.0 ) radS[2] = 0.0;\
  if( (rho) >= 1.0 ) radS[2] = 0.9999;\
  radS[3] = (point1)[0];\
  radS[4] = (point1)[1];\
  radS[5] = (point1)[2];\
  radS[6] = (point2)[0];\
  radS[7] = (point2)[1];\
  radS[8] = (point2)[2];\
  croS[0].located_obj = (objects)[0];\
  croS[0].module_info = MOD_ENV;\
  croS[1].located_obj = (objects)[1];\
  croS[1].module_info = MOD_ENV;\
  (*(object)).objid = NULL_OBJID;\
  (*(object)).osnum = MOD_ENV.md_id.osnum;\
  \
  ci$send(msg = message EMSgenbs.EMmkfilletsf(\
                &rtcd,\
                &croS[0], natS[0],\
                &croS[1], natS[1],\
                &radS[3], radS[0],\
                &radS[6], radS[1],\
                NULL, NULL,\
                radS[2], &cst, 0),\
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum);\
  free(croS);\
  free(radS);\
  free(natS);\
  name_display( (*(object)), (name), (disp));



// THIS MACRO WILL INTERSECT OBJECTS WITH A PLANE OR DO SAVE SIDE
int                     loop_inc1;

struct RLWplane
 {
  IGRpoint      point;
  IGRvector     normal;
 }                      *planes_T;
struct IGRplane         plane_intersection;
int                     *intS;
double                  double9[9],toL,disT,delT_disT,delTpT[3],Tp1[3],
                        Tp2[3],Tp3[3];
struct GRlc_info        input_obJect;
struct GRid             *int_GRid;

#define intersect_w_plane(option,num_cut,p1,p2,p3,p4,object,object_out,num_out,name,disp)\
\
   set_up_easy();\
   intS = (int *) malloc ( 6 * sizeof(int));\
   dblS = (double *) malloc ( 9 * sizeof(double));\
   \
   intS[3] = (num_cut);\
   intS[0] = (option);\
   \
   for(intS[1] = 0; intS[1] < 3; intS[1]=intS[1]+1)\
   {\
        dblS[intS[1]+0] = (p1)[intS[1]];\
        dblS[intS[1]+3] = (p2)[intS[1]];\
        dblS[intS[1]+6] = (p3)[intS[1]];\
   }\
   \
   plane_T.point = (IGRdouble *) malloc(24);\
   plane_T.normal = (IGRdouble *) malloc(24);\
   intS[4] = 3;\
   toL = .001;\
   MAdetplane(&rtcd, dblS , &intS[4], &toL, &plane_T);\
   dblS[0] = plane_T.point[0];\
   dblS[1] = plane_T.point[1];\
   dblS[2] = plane_T.point[2];\
   dblS[6] = plane_T.normal[0];\
   dblS[7] = plane_T.normal[1];\
   dblS[8] = plane_T.normal[2];\
   dblS[3] = (p4)[0] - dblS[0];\
   dblS[4] = (p4)[1] - dblS[1];\
   dblS[5] = (p4)[2] - dblS[2];\
   disT = ( dblS[3]*dblS[6] + dblS[4]*dblS[7] + dblS[5]*dblS[8]);\
   if( intS[3] > 1) delT_disT = disT / (intS[3]-1);\
   if( intS[3] == 1) delT_disT = disT / (intS[3]);\
   \
   delTpT[0] = plane_T.normal[0] * delT_disT;\
   delTpT[1] = plane_T.normal[1] * delT_disT;\
   delTpT[2] = plane_T.normal[2] * delT_disT;\
   \
   planes_T = (struct RLWplane *) malloc(intS[3] * sizeof(struct RLWplane));\
   \
   if(planes_T == 0) { status("malloc error"); exit; }\
   \
   for(intS[2] = 0; intS[2] < intS[3]; intS[2] = intS[2] + 1)\
   {\
        for(intS[1] = 0; intS[1] < 3; intS[1] = intS[1] + 1)\
        {\
           planes_T[intS[2]].normal[intS[1]] = plane_T.normal[intS[1]];\
           planes_T[intS[2]].point[intS[1]] = plane_T.point[intS[1]] + ((intS[2]) * delTpT[intS[1]]);\
        }\
   }\
   \
   free(plane_T.normal);\
   free(plane_T.point);\
   input_obJect.located_obj = (object);\
   input_obJect.module_info = MOD_ENV;\
   \
   EMintersect_with_plane_mod(\
        intS[0],\
        intS[3],\
        planes_T,\
        0,\
        (p4),\
        FALSE,\
        &MOD_ENV,\
        &input_obJect,\
        &cst,\
        TRUE,\
        NULL_OBJID,\
        1,\
        &intS[5],\
        &int_GRid,\
        NULL,\
        &rtcd);\
   \
   *(num_out) = intS[5];\
   for(intS[1]=0; intS[1] < *(num_out); intS[1] =intS[1] + 1)\
   {\
        (object_out)[intS[1]] = int_GRid[intS[1]];\
        \
        if( (disp) >= DRAW && (disp) <= ERASE_ERASEHILITE_OVER)\
        {\
                display = (disp);\
                ci$send(msg = message GRgraphics.GRdisplay(\
                        &rtcd,\
                        &MOD_ENV.md_env.matrix_type,\
                        MOD_ENV.md_env.matrix,\
                        &display,\
                        &dspGRid),\
                        targetid = (object_out)[intS[1]].objid,\
                        targetos = (object_out)[intS[1]].osnum);\
        }\
        \
        if( strcmp((name),"0") != 0 )\
        {\
          counter=0;\
          rtcd = -1;\
          strcpy(object_name,(name));\
          while( rtcd != SUCCESS)\
          {\
             ci$send(msg = message GRvg.GRputname(\
                &rtcd,\
                (object_name)),\
                targetid = (object_out)[intS[1]].objid,\
                targetos = (object_out)[intS[1]].osnum);\
             counter=counter+1;\
             strcpy(object_name,(name));\
             strcat(object_name,itoa(counter));\
          }\
          strcpy(object_name,(name));\
        }\
   }\
   free(planes_T);\
   free(dblS);\
   free(intS);\

/*
        name_display((object_out)[intS[1]],name,disp);\
   disT = v_dot(Tp2,Tp3);\
   v_sub((p4),Tp1, Tp2);\
   v_scale(plane_T.normal,delT_disT,delTpT);\
*/

struct EMSdataselect    save;
struct IGRplane         plane_T;
double                  *dblS;

#define int_plane_save_side(p1,p2,p3,p4,object,object_out,name,disp)\
\
   set_up_easy();\
   intS = (int *) malloc ( 6 * sizeof(int));\
   dblS = (double *) malloc ( 9 * sizeof(double));\
   for(loop_inc = 0; loop_inc < 3; loop_inc=loop_inc+1)\
   {\
        dblS[loop_inc+0] = (p1)[loop_inc];\
        dblS[loop_inc+3] = (p2)[loop_inc];\
        dblS[loop_inc+6] = (p3)[loop_inc];\
   }\
   plane_T.point = (IGRdouble *) malloc(24);\
   plane_T.normal = (IGRdouble *) malloc(24);\
   intS[4] = 3;\
   toL = .001;\
   MAdetplane(&rtcd, dblS , &intS[4], &toL, &plane_T);\
   free(dblS);\
   save.datatype = EMSdata_plane;\
   save.data.plane = (struct IGRplane *) &plane_T;\
   \
   ci$send(msg = message EMSsurface.EMintsurf_saveside( \
             &rtcd, \
             &cst, \
             &save,\
             &MOD_ENV,\
             (p4),\
             1, \
             1,\
             NULL,\
             NULL,\
             TRUE,\
             NULL),\
             targetid = (object).objid,\
             targetos = (object).osnum);\
   \
   free(plane_T.point);\
   free(plane_T.normal);\
   \
   if(rtcd != SUCCESS && rtcd != SOL_SUC )\
   {\
        status("Intersection failed");\
        *(object_out) = (object);\
   }\
   \
   if(rtcd == SUCCESS || rtcd == SOL_SUC )\
   {\
      ci$send(msg = message EMSsurface.EMgetactiveid(\
             &rtcd,\
             (object_out),\
             NULL), \
             targetid = (object).objid,\
             targetos = (object).osnum);\
   \
      name_display(*(object_out),(name),(disp));\
   }\
   free(intS);

#define show_normals(object,disp)\
\
   set_up_easy();\
   ci$send(msg = message EMSsurface.EMshow_normals(\
                        &rtcd, &MOD_ENV,&dis, (disp)),\
                        targetid = (object).objid,\
                        targetos = (object).osnum);


// THIS FUNCTION WILL CREATE ISO PARAMETERIC CURVES ON A SURFACE
GRobj   *ISO_CURVES;

#define create_iso_curves(trim,number,parameters,direction,number_isos,ISO_GRIDS,object,name,disp)\
\
        set_up_easy();\
\
        ci$send( msg = message EMSsubbs.EMisoparcvs( \
                &rtcd,&MOD_ENV.md_env.matrix_type, \
                MOD_ENV.md_env.matrix,&cst,(trim), \
                (number),(parameters),(direction), \
                (number_isos),&ISO_CURVES ), \
                targetid = (object).objid, \
                targetos = (object).osnum ); \
\
        for(loop_inc = 0; loop_inc < *(number_isos); loop_inc = loop_inc + 1) \
        {\
          ISO_GRIDS[loop_inc].objid = ISO_CURVES[loop_inc];\
          ISO_GRIDS[loop_inc].osnum = MOD_ENV.md_id.osnum;\
          if( strcmp((name),"0") != 0 )\
          {\
            put_name(name,ISO_GRIDS[loop_inc]);\
          }\
          if((disp) != 1)\
          {\
            display = (disp);\
            display_w_opt(ISO_GRIDS[loop_inc],display);\
          }\
        }



// GET ATTRIBUTES

#define get_attributes( object, attr)\
\
        ci$send( msg = message GRvg.GRgetattr(\
                &rtcd,\
                (attr)),\
                targetid = (object).objid,\
                targetos = (object).osnum);

// GET RULE LINE TABLE

#define get_rule_line_table(object, MOD_ENV, include_natural, rlt)\
\
        ci$send( msg = message EMSsubbs.EMgetRuleLineTable(\
                &rtcd,\
                (include_natural),\
                NULL, NULL, NULL, &MOD_ENV.md_env.matrix_type, \
                MOD_ENV.md_env.matrix, NULL, 0, (rlt)), \
                targetid = (object).objid,\
                targetos = (object).osnum);

struct GRsymbology symb_loc;
IGRshort action;
IGRshort gprops;

#define EFget_xyz_obj(GRid_in, MOD_ENV,GRid_out,locatable)\
\
 set_up_easy();\
 symb_loc.level = cst.level;\
 symb_loc.display_attr = (*cst.display);\
\
  ci$send (msg = message EMSboundary.EMgetxyzobj (&rtcd, \
                EMSlcopt_noassoc,&(MOD_ENV.md_env),\
                NULL,NULL, \
                &symb_loc, (cst.class_attr), \
                (GRid_in.osnum), &(GRid_out->objid)),\
                targetid = GRid_in.objid,\
                targetos = GRid_in.osnum);\
  GRid_out->osnum = GRid_in.osnum; \
  if ((locatable) && (1&rtcd))\
  {\
   action = 0;\
   gprops = GRNOT_IN_RTREE;\
   ci$send (msg = message GRgraphics.GRchgprops(&rtcd,&action,&gprops),\
                targetid = GRid_out->objid,\
                targetos = GRid_out->osnum);\
   \
   ci$send (msg = message GRgraphics.GRaddwrng(&rtcd,\
                  &MOD_ENV),\
                targetid = (GRid_out->objid),\
                targetos = (GRid_out->osnum));\
  }

// THIS FUNCTION PROJECTS A POINT ALONG A VECTOR ONTO A SURFACE

#ifndef ci_wire_include
IGRint msg;
#endif

#define project_point_along_vector_onto_surface(GRid_in,md_env,vector_point1, vector_point2, point_to_project, num_points, proj_pnts, u_pars,v_pars)\
\
 ci$send(msg = message EMSsubbs.EMpjptsf(\
               &msg, md_env, vector_point1, vector_point2, \
               point_to_project, num_points, &proj_pnts, \
               &u_pars, &v_pars), \
         targetid =  GRid_in.objid, \
         targetos = GRid_in.osnum ); 

// THIS FUNCTION SHALL RETURN THE THE NORMAL INFORMATION

IGRboolean out_solid;

#define get_surface_normal(GRid_in,in_point,normal)\
\
 set_up_easy();\
 out_solid = 0;\
 ci$send (msg = message EMSsubbs.EMget_unit_norm(\
                &msg, out_solid,\
                0, &MOD_ENV.md_env, in_point, normal),\
          targetid = GRid_in.objid,\
          targetos = GRid_in.osnum);

// INTERSECT 2 ELEMS

struct GRlc_info        Ele1, Ele2;
IGRushort trimopt;
IGRint inx;
IGRlong rc;

#define intersect_two_elems(trim,object1,object2,object_out,num_out, disp)\
\
   set_up_easy();\
   Ele1.located_obj = (object1);\
   Ele1.module_info = MOD_ENV;\
   Ele2.located_obj = (object2);\
   Ele2.module_info = MOD_ENV;\
   if(trim) \
    trimopt = EMSINT_TRIM_OUTPUT;\
   else \
    trimopt = NULL; \
   \
   EMintersect_two_element(&Ele1, &Ele2, trimopt, &cst, num_out, object_out, &rc);\
   \
   for(inx=0; inx < *(num_out); inx = inx + 1)\
   {\
     if( (disp) >= DRAW && (disp) <= ERASE_ERASEHILITE_OVER)\
      {\
        display = (disp);\
        ci$send(msg = message GRgraphics.GRdisplay(\
                      &rtcd,\
                      &MOD_ENV.md_env.matrix_type,\
                      MOD_ENV.md_env.matrix,\
                      &display,\
                      &dspGRid),\
                      targetid = (object_out)[0][inx].objid,\
                      targetos = (object_out)[0][inx].osnum);\
      }\
   }\

EFcreate_surf_from_geom(md_env,geometry,classname,color,style,level,weight,
                        name, display, GRid_out,is_surf)
struct GRmd_env *md_env;
IGRchar *geometry;
IGRchar *classname;
IGRint color;
IGRint style;
IGRint level;
IGRint weight;
IGRchar *name;
IGRint display;
struct GRid *GRid_out;
IGRint is_surf;
{
 IGRchar objtype;
 enum GRdpmode dpmode;
 OMuword constructos;
 IGRint msg_loc,stat_func,status;
 IGRshort loc_level;
 IGRchar construct_class[40];
 unsigned IGRshort opts;
 IGRchar loc_name[DI_PATH_MAX];
 struct GRvg_construct vgcnstr;
 struct IGRdisplay loc_disp;
 struct GRmd_env loc_mdenv;
 
 
 opts = NULL;
 EMinitvgcnstr(&msg_loc,&loc_mdenv,&loc_disp,loc_name,&vgcnstr);
 loc_level=2000;
 objtype = 0;

 stat_func = EMgetvgcnstr(opts,objtype,md_env,loc_level,NULL,NULL,name,
             &vgcnstr);

 GRid_out->osnum = vgcnstr.env_info->md_id.osnum;
 constructos = GRid_out->osnum;

 if (!(level == -1))
  vgcnstr.level = level;

 if (!(color == -1))
  vgcnstr.display->color = color;
 
 if (!(weight == -1))
  vgcnstr.display->weight = weight;

 if (!(style == -1))
  vgcnstr.display->style = style;

 vgcnstr.geometry = geometry;

 if (is_surf)
 {
  if (classname)
   strcpy (construct_class,classname);
  else
   strcpy (construct_class,"EMSgenbs");
 }
 else
 {
  if (classname)
   strcpy (construct_class,classname);
  else
   strcpy (construct_class,"GRbcsubbc");
 }

 GRid_out->objid = -1;

 status = om$construct(classname = construct_class,
                       p_objid = &GRid_out->objid,
                       osnum = constructos);


  ci$send (msg = message GRvg.GRconstruct(&vgcnstr),
                   targetid = GRid_out->objid,
                   targetos = constructos);

 

 if (display)
 {
  dpmode = GRbd;

  ci$send (msg = message GRgraphics.GRdisplay(&msg_loc,
                 &vgcnstr.env_info->md_env.matrix_type,
                 vgcnstr.env_info->md_env.matrix,
                 &dpmode,
                 &vgcnstr.env_info->md_id),
                   targetid = GRid_out->objid,
                   targetos = constructos);
         
 }

 return;
}

#endif
