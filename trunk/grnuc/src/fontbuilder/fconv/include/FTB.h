/*
$Log: FTB.h,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:53  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:09  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:07  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:33  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:48  root
 * COMMENT : Corresponds to Rel201.1 in 2.0.1 RCS
 *
 * Revision 201.1  1992/07/13  20:42:41  tim
 * COMMENT : added Log variable
 *
*/

#ifndef ci_easy_include
#define ci_easy_include

#include "cieveryone.h"
#include "OMminimum.h"
#include "cimacros.h"
#include "cimath.h"
#include "dpmacros.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "growner.h"
#include "acdef.h";
#include "acmacros.h";
#include "macro.h";
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

#define SUCCESS  	134250505
#define SOL_SUC  	2654217
#define EXP_SCALAR 	0
#define EXP_DISTANCE 	1
#define EXP_ANGLE 	2

int			rtcd, loop_inc;
struct GRid      	dspGRid,TEMP_GRID, TEMP_GRID_NEW,
			TEMP_GRID1,TEMP_GRIDS[100];
struct GRmd_env  	MOD_ENV,ALT_ENV;
struct GRsymbology	symb;
IGRshort     	        set_properties1,properties1;
IGRshort     	        props;
struct IGRdisplay	dis;
struct GRvg_construct   cst;
double			*Dbl9,*Dbl6,*Dbls,double100[100],double6[6];
		
extern 		GRgs_fun(), 
		DPerase_hilite(),
		GRgsmgr_fun();

extern double	BSdotp();

extern void	BScrossp(),
		BSnorvec();

extern int 	GRcvt_imp_to_wrk(),
		GRget_default_units(),
	 	GRfindmod(),
	 	init_cnst_list(),
		DIuntranslate(),
		DIreport_error(),
		DIfetch_untrans(),
		DImain(),
		DIfast_trans(),
		DIadd_index(),
		DIsplit(),
		EXP_translate_exp(),
		EXP_create(),
		EMdpb_get();

extern	char 	*malloc();
extern  int	free();
extern 		sprintf();

extern	char    ASbroadcast_in_progress,
		*strchr(),
		*strrchr(),
		*strncpy();
extern int	strncmp();



/*---------------------- gr$display_object ------------------------------

#omdef gr$display_object(
			GRid_in = TEMP_GRID,		
			disp   = DRAW )			

 Abstract:

	This macro will display the input grid with the specified 
	display option.

 Arguments:

	GRid_in		I	struct GRid	Input object id and osnum.
	
	disp		I	int		Input display option. The
						options are also defined in
						this include file. eg "DRAW,
						ERASE, GRbe".

 Sample Call:

	gr$display_object( GRid_in = TEMP_GRID, disp = ERASE );

		Both arguments have defaults and that means that if the object
	that you want to perform a "DRAW" display to is defined as "TEMP_GRID"
	than all you need to use is the following.

	gr$display_object();

 Notes:


 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$display_object
			(GRid_in = TEMP_GRID,
			disp   = DRAW )

display_w_opt((GRid_in),(disp));
#endomdef

/*---------------------- gr$put_properties ------------------------------

#omdef gr$put_properties
			(GRid_in = TEMP_GRID,				
			 set	 = TRUE,					
			 prop    = DISPLAYABLE)				

 Abstract:
	
	This macro sets the property bits of an object. This can be used
	to make an object un/displayable, un/locatable .....

 Arguments:

	GRid_in		I 	struct GRid	Input GRid of object to 
						set the properties of.

	set		I	short		This flag determines whether
						the list of properties is
						to be set or removed.

	prop		I 	short		This is the properties word
						that contains the list of 
						properties to be delt with.
						The properties are listed in
						this include file.
 Sample Call:

	All the arguments have defaults. If you want to set the object 
	"TEMP_GRID" to be displayable, then the call looks like this.

 	gr$put_properties();

	else if you want to set the object "SAM" to be locatable and read_only,
	then the call looks like this.

 	gr$put_properties
			(GRid_in = SAM,				
			 set	 = TRUE,					
			 prop    = LOCATABLE | READ_ONLY);

 Notes:

	The properties are as follows:

		RIGID_RELATIONSHIP   	
		PLANAR 			
		READ_ONLY
		NEW	
		MODIFIED
		LOCATABLE	  
		DISPLAYABLE	
		FILLED_DISPLAY
		NOT_IN_RTREE
		VIEW_INDEP
		SCALE_INDEP

	These are defined elsewhere in this include file.
	The "set" argument should be set to TRUE if you want to make
	the properties active, FALSE if you want to remove the property.

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/


#omdef 	gr$put_properties
			(GRid_in = TEMP_GRID,				
			 set	 = TRUE,					
			 prop    = DISPLAYABLE)				

	change_properties((GRid_in), (set), (prop));
#endomdef

/*---------------------- gr$get_properties ------------------------------

 gr$get_properties( GRid_in = TEMP_GRID, props );

 Abstract:

	This macro will get the property word from an object

 Arguments:

	GRid_in		I 	struct GRid	Input GRid of object to 
						get the properties from.

	prop		O 	short		This is the properties word
						that contains the list of 
						properties.
						The properties are listed in
						this include file.

 Sample Call:

 	gr$get_properties( GRid_in = TEMP_GRID, props = properties);
	
	Where the input object GRid is "TEMP_GRID" and the output 
	properties word is "properties". There is no default for the
	output props.
	
 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/



#omdef gr$get_properties
			( GRid_in = TEMP_GRID, props )	

	get_properties((GRid_in),(props));
#endomdef


/*---------------------- gr$set_symbology -------------------------------

#omdef gr$set_symbology(lv = -1 ^ level = -1,
		      	co = -1 ^ color = -1,
		      	st = -1 ^ style = -1,
		      	wt = -1 ^ weight = -1)

 Abstract:

	This macro sets the display symbology in the construction list
	that is used in the wire, surface, and solid macros. This does
	not change the active symbology in the file.

 Arguments:

	lv ^ level	I	IGRint		sets the construction level

	co ^ color 	I	IGRint		sets the construction color

	st ^ style	I	IGRint		sets the construction style

	wt ^ weight	I	IGRint		sets the construction weight

 Sample Call:

	 gr$set_symbology(lv = 2, co = red, st = 1, wt = 0);

	 gr$set_symbology(level = 2, color = red, style = 1, weight = 0);
	

 Notes:

	Be consistant with the arguments, 2 characters or word
	or you will find it will not set the 2 char values you mixed in.
	The colors are defined below and you can use the color names
	or numbers.

	green	1
	red	2
	blue	3
	yellow	4
	cyan	5
	magenta	6
	white	7

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$set_symbology
		( 	lv = -1 ^ level = -1,				/**/
		      	co = -1 ^ color = -1,				/**/
		      	st = -1 ^ style = -1,				/**/
		      	wt = -1 ^ weight = -1)				/**/

#if   	om$specified (level) || om$specified (color) || om$specified (style) || om$specified (weight) 
       	set_symbology((level), (color), (style), (weight));	
#else
       	set_symbology((lv), (co), (st), (wt));	
#endif
#endomdef


/*---------------------- gr$reset_symbology -----------------------------

#omdef gr$reset_symbology()	

 Abstract:
	
	This macro resets the construction symbology back to the files
	active symbologies.

 Arguments:

	N/A

 Sample Call:

	gr$reset_symbology()	

 Notes:

	As mentioned above this sets the construction symbology back to
	the files active symbology.

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef 	gr$reset_symbology()

  	reset_to_active_symbology();
#endomdef

/*---------------------- gr$get_symbology -------------------------------

#omdef gr$get_symbology( GRid_in = TEMP_GRID, symb )

 Abstract:

	This macro will get the symbology from an object defined by its
	GRid, and put it in symb.

 Arguments:

	GRid_in 	I	struct GRid	 input object GRid

	symb 		O	struct GRsymbology	output symbology 
							structure.
 Sample Call:

	gr$get_symbology( GRid_in = TEMP_GRID, symb = symbol );
	
	Where "TEMP_GRID" is the input object and symbol is the output
	structure.

 Notes:

	This macro is used to copy the symbology from one object to another.

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef 	gr$get_symbology( GRid_in = TEMP_GRID, symb )

	get_symbology((GRid_in),(symb));
#endomdef

/*---------------------- gr$put_symbology -------------------------------

#omdef 	gr$put_symbology ( GRid_in = TEMP_GRID, symb )

 Abstract:
	
	This macro is used to put specific symbology on to an object.
	This was constructed to work in conjuntion with "gr$get_symbology".

 Arguments:

	GRid_in 	I	struct GRid	 input object GRid

	symb 		I	struct GRsymbology	input symbology 
							structure.

 Sample Call:

	gr$put_symbology ( GRid_in = TEMP_GRID, symb = symbol );

	Where "TEMP_GRID" is the input object and symbol is the input
	structure.

 Notes:

	This macro is used to copy the symbology from one object to another.

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef 	gr$put_symbology ( GRid_in = TEMP_GRID, symb )

	put_symbology((GRid_in),(symb));
#endomdef

/*---------------------- gr$delete_object -------------------------------

#omdef 	gr$delete_object( GRid_in = TEMP_GRID, disp = ERASE)

 Abstract:

	This macro will delete an object along with manipulating the
	display when the delete is performed.

 Arguments:

	GRid_in 	I	struct GRid	Input object GRid

	disp		I	int		Input display option.
						The options are the same
						as those in "gr$display_object"

 Sample Call:

	gr$delete_object( GRid_in = TEMP_GRID, disp = ERASE);

	Where "TEMP_GRID" is the object GRid and disp is ERASE the object.

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef 	gr$delete_object( GRid_in = TEMP_GRID, disp = ERASE)

	delete_object((GRid_in),(disp));
#endomdef

/*---------------------- gr$copy_object ---------------------------------


#omdef gr$copy_object(	GRid_in = TEMP_GRID,
		    	GRid_out = TEMP_GRID_NEW,
		    	md_env_in = MOD_ENV);

 Abstract:

	This macro copyies an object. The md_env_in argument is there
	if the object to copy is in a reference file.

 Arguments:

	GRid_in 	I	struct GRid	Input object GRid

	GRid_out 	O	struct GRid	Output object GRid. The
						copied object id.

	md_env_in	I	struct GRmd_env	Input module environment
						of the input object, this
						is defaulted to the current
						object space. If the object is
						in a reference file this 
						argument must be supplied
						in order to get the expected
						results.

 Sample Call:

	struct GRid	CURVE, CURVE_OUT;
	struct GRmd_env	CP_ENV;

   	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   md_env = &CP_ENV,
		   prompt= "Identify curve to copy");

 	gr$copy_object(	GRid_in = CURVE,
		    	GRid_out = CURVE_OUT,
		    	md_env_in = CP_ENV);
	
 Notes:

	Again the md_env_in is need only when the object being copied
	is in a reference file.

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$copy_object
			(GRid_in = TEMP_GRID,
		    	GRid_out = TEMP_GRID_NEW,
		    	md_env_in = MOD_ENV)

    set_up_easy();
    ci$send( msg = message GRvg.GRcopy(  
		&rtcd, 
		&(md_env_in), 
		&MOD_ENV, 
		&(GRid_out).objid), 
             	targetid = (GRid_in).objid,  
		targetos = (GRid_in).osnum ); 
   (GRid_out).osnum = MOD_ENV.md_id.osnum

#if   !om$specified(GRid_out)
      TEMP_GRID = TEMP_GRID_NEW;
#endif
#endomdef



/*---------------------- gr$put_name ------------------------------------

#omdef 	gr$put_name( GRid_in = TEMP_GRID, name = "OBJECT")

 Abstract:
	
	This macro puts a name on the input object. If the name is
	already used the macro will loop until it creates a unique name by
	adding a number to the name until it is unique. 

 Arguments:

	GRid_in 	I	struct GRid	Input object GRid

	name		I/O	char		Input name/ if not unique
						the new name is output here.

 Sample Call:


	char		ob_name[30];
	struct GRid	CURVE;

   	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   prompt= "Identify element to name");

	ci$get(string = ob_name, prompt="key in name");

 	gr$put_name( GRid_in = CURVE, name = ob_name);

 Notes:

	Again the macro will place the name on the object and assure you that
	the name is unique.

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef 	gr$put_name( GRid_in = TEMP_GRID, name = "OBJECT")

  	put_name((name),(GRid_in));
#endomdef


/*---------------------- gr$remove_name ---------------------------------

#omdef gr$remove_name(name) 

 Abstract:
	
	This macro removes a name from the directory system. It just calls
	the DImacro di$rm_name( regexp = name). 

 Arguments:

	name	 	I	IGRchar		Input name to remove

 Sample Call:
	
	IGRchar	ob_name[40];

	ci$get( string = ob_name, prompt="key in name to remove");
	
	gr$remove_name( name = obname );

 Notes:

	This is just a simplified di$rm_name();

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$remove_name	(name) 

	rtcd = di$rm_name( regexp = name);

#endomdef


/*---------------------- gr$get_name ---   ------------------------------

#omdef gr$get_name(	GRid_in = TEMP_GRID, 	
		 	name = object1name,	
		 	dir_name = directoryname,
		 	full_name = fullpathname)

 Abstract:

	This macro will get the object TEMP_GRID's name, directory path, and
	full name. All arguments have defaults for ease of use. This is
	a simpler use of 

 Arguments:

	GRid_in 	I	struct GRid	Input object GRid

	name		O	IGRchar		output name only 

	dir_name 	O	IGRchar		output directory only
		
	full_name	O	IGRchar		output directory:name 
	
 Sample Call:

	IGRchar		ob_name[40];
	struct GRid	CURVE;

   	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   prompt= "Identify element to get name from");

 	gr$get_name(	GRid_in = CURVE, 	
		 	name = ob_name);


 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/
IGRchar	object1name[132],directoryname[132],fullpathname[132];

#omdef gr$get_name(	GRid_in = TEMP_GRID, 
		 	name = object1name,	
		 	dir_name = directoryname,	
		 	full_name = fullpathname)

  get_name((name),(dir_name),(full_name),(GRid_in));
#endomdef


/*---------------------- gr$get_coordinate_data -------------------------


#omdef gr$get_coordinate_data(
			GRid_in   = TEMP_GRID, 
			origin   = Coord_origin, 
			x_vector = Coord_x,	
			y_vector = Coord_y,	
			z_vector = Coord_z,	
			matrix   = Coord_matrix)
 Abstract:

	This macro will return the x, y, and z vectors of a coordinate system.
	It also returns the origin and the full matrix of the coordinate system.
	All arguments have defaults so it is easy to get just the data that
	you require from the macro.

 Arguments:

	GRid_in 	I	struct GRid	Input GRid of coordinate system

	origin 		O	IGRdouble[3]	output xyz origin 

	x_vector	O	IGRdouble[3]	output x vector

	y_vector	O	IGRdouble[3]	output y vector

	z_vector	O	IGRdouble[3]	output z vector

	matrix 		O	IGRdouble[16]	output all the above in matrix

 Sample Call:

	struct GRid	COORD;
	double		org[3], xvec[3];

   	ci$locate( obj 	 = &COORD.objid,
		   osnum = &COORD.osnum,
		   classes = "GRgencs",
		   prompt= "Identify coordinate system");
	
 	gr$get_coordinate_data(
			GRid_in  = COORD,
			origin   = org,
			x_vector = xvec);

 Notes:

	All the arguments have defaults so you can easily get just the data
	needed.

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/
double	Coord_origin[3],Coord_x[3],Coord_y[3],Coord_z[3],Coord_matrix[16];

#omdef gr$get_coordinate_data(
			GRid_in   = TEMP_GRID, 
			origin   = Coord_origin, 
			x_vector = Coord_x,
			y_vector = Coord_y,
			z_vector = Coord_z,
			matrix   = Coord_matrix)

  get_coord_data((GRid_in),(origin),(matrix),(x_vector),(y_vector),(z_vector));

#endomdef

double	double_1,double_2;

/*---------------------- gr$project_pnt_on_element ----------------------


#omdef gr$project_pnt_on_element(
			GRid_in = TEMP_GRID,
			point1,	
			point2,	
			u_value = double_1,
			v_value = double_2)

 Abstract:

	This macro will project a point "point1" onto the object "GRid_in"
	and the output is "point2" which is the closest point, also the
	u, and v values are returned. I the case of a curve only the u value
	is valid.

 Arguments:

	GRid_in		I	struct GRid	Input object that the point is
						projected onto.

	point1		I	IGRdouble[3]	Input point to be projected.

	point2		O	IGRdouble[3]	Output point on the object.
	
	u_value		O	IGRdouble	U value of the point on object.

	v_value		O	IGRdouble	V value of the point on object.

 Sample Call:

	struct GRid	CURVE;
	IGRdouble	pnt1[3], pnt2[3];

   	ci$locate( obj 	 = &CURVE.objid,
		   osnum = &CURVE.osnum,
		   classes = "GRcurve",
		   prompt= "Identify curve to project point onto");

	ci$get(point = pnt1, prompt="identify the point to be projected");

 	gr$project_pnt_on_element(
			GRid_in = CURVE,
			point1 = pnt1,	
			point2 = pnt2);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$project_pnt_on_element(
			GRid_in = TEMP_GRID,
			point1,	
			point2,	
			u_value = double_1,
			v_value = double_2)

	pro_point_on_element(GRid_in,point1,point2,u_value,v_value)
#endomdef

/*---------------------- gr$create_graphic_group ------------------------

#omdef 	gr$create_graphic_group(
			GRids_in = TEMP_GRIDS,	
			GRid_out = TEMP_GRID,
			name = "0",
			disp = DRAW)

 Abstract:

	This macro will create a graphic group of the array of GRids_in.
	The graphic group id is the GRid_out.

 Arguments:

	GRids_in	I	struct GRid	Input array of objects.

	GRid_out	O	struct GRid	Output graphic group id.

	name		I/O	char		Input name/ if not unique
						the new name is output here.
	
	disp		I	int		Input display option. The
						options are also defined in
						this include file. eg "DRAW,
						ERASE, GRbe".

 Sample Call:

	struct GRid	CURVES, GRA_GROUP;
	int		i;

	i=0;
	while(1)
	{
   		if(!ci$locate( 
			obj   = &CURVES[i].objid,
			osnum = &CURVES[i].osnum,
			prompt= "Identify obj to add to graphic group"))break;
		i=i+1;
	}

	gr$create_graphic_group(
			GRids_in = CURVES,	
			GRid_out = GRA_GROUP,
			name = "graphic_group",
			disp = DRAW);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef 	gr$create_graphic_group(
			GRids_in = TEMP_GRIDS,	
			GRid_out = TEMP_GRID,
			name = "0",
			disp = DRAW)

	create_graphic_group( GRids_in, GRid_out, name, disp);
#endomdef

/*---------------------- gr$add_to_graphic_group ------------------------


#omdef 	gr$add_to_graphic_group(
			GRids_in = TEMP_GRIDS,	
			GRid_in = TEMP_GRID)
 Abstract:

	This macro will take an existing graphic group and add the array
	of new GRids to it.

 Arguments:

	GRids_in	I	struct GRid	Input array of objects.

	GRid_out	I	struct GRid	Output graphic group id.

 Sample Call:

	struct GRid	CURVES, GRA_GROUP;
	int		i;

	i=0;
	while(1)
	{
   		if(!ci$locate( 
			obj   = &CURVES[i].objid,
			osnum = &CURVES[i].osnum,
			prompt= "Identify obj to add to graphic group"))break;
		i=i+1;
	}

	gr$add_to_graphic_group(
			GRids_in = CURVES,	
			GRid_in = GRA_GROUP);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef 	gr$add_to_graphic_group(
			GRids_in = TEMP_GRIDS,	
			GRid_in = TEMP_GRID)

	add_to_graphic_group( GRids_in, GRid_in);
#endomdef

/*---------------------- gr$get_active_u_order --------------------------

#omdef 	gr$get_active_u_order( order)

 Abstract:

	This macro will get the active system u order.

 Arguments:

	order		O	IGRint		Output u order

 Sample Call:
	
	int	u_order;

	gr$get_active_u_order( order = u_order);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef 	gr$get_active_u_order( order)

  	EMdpb_get(&rtcd,0,&(order));
#endomdef

/*---------------------- gr$get_active_v_order --------------------------

#omdef 	gr$get_active_v_order( order)

 Abstract:

	This macro will get the active system v order.

 Arguments:

	order		O	IGRint		Output v order

 Sample Call:
	
	int	v_order;

	gr$get_active_v_order( order = v_order);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef 	gr$get_active_v_order( order)	

  	EMdpb_get(&rtcd,1,&(order));
#endomdef


/*******
	THESE ARE THE SUPPORTING FUNCTIONS FOR EACH OF THE ABOVE
	MACROS. THESE ARE SUBJECT TO CHANGE SO I DON'T RECOMEND
	THE COPYING OF THE CODE BELOW FOR USE.
*******/

#define set_up_easy()  set_up_cnst();

#define set_up_cnst()\
   if( MOD_ENV.md_id.osnum == 0) ci$get_module_info(md_env=&MOD_ENV);\
   if( dspGRid.objid == 0 && dspGRid.osnum == 0)\
   {\
    init_cnst_list();\
    get_symb();\
    dis.rgb_value  = 0;\
    dis.color      = cnst_list.color;\
    dis.weight     = cnst_list.weight;\
    dis.style      = cnst_list.style;\
    cst.msg        = &rtcd;\
    cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;\
    cst.display    = &dis;\
    cst.env_info   = &MOD_ENV;\
    cst.newflag    = 0;\
    cst.level      = cnst_list.level;\
    cst.geometry   = 0;\
    cst.class_attr = 0;\
    cst.name       = 0;\
    GRfindmod(&dspGRid);\
    }


/****************************************************************/
/*                                                              */
/*define THIS SECTION DEALS WITH THE DISPLAYING OF AN OBJECT 	*/
/* THE FOLLOWING defines ARE THE DIFFERENT OPTIONS FOR THE 	*/
/* "display_w_opt()" FUNCTION					*/
/*                                                              */
/****************************************************************/

#define	DRAW			GRbd	// 0 DRAW THE OBJECT
#define ERASE			GRbe	// 1 ERASE THE OBJECT
#define HILITE			GRhd	// 2 HIGHLITE THE OBJECT
#define ERASEHILITE		GRhe	// 3 ERASE HIGHLITE THE OBJECT
#define DRAW_HILITE		GRbdhd	// 4 DRAW AND HIGHLITE THE OBJECT
#define ERASE_ERASEHILITE 	GRbehe	// 5 ERASE AND UNHIGHLITE THE OBJECT
#define DRAW_ERASEHILITE	GRbdhe	// 6 DRAW AND UNHIGHLITE THE OBJECT
#define ERASE_HILITE		GRbehd	// 7 ERASE AND HIGHLITE THE OBJECT
#define HALFHILITE		GRhhd	// 8 HALF HILITE THE OBJECT
#define HILITE_OVER		GRhdo	// 9 HILITE ANY OBJECT DISPLAYABLE OR NOT
#define HALFHILITE_OVER		GRhhdo	// 10 HALF HILITE SAME AS HILITE_OVER
#define ERASEHILITE_OVER	GRheo	// 11 ERASE HILITE_OVER
#define DRAW_ERASEHILITE_OVER	GRbdheo	// 12 DRAW AND UNHILITE ANY OBJECT
#define ERASE_ERASEHILITE_OVER	GRbeheo	// 13 ERASE AND UNHILITE ANY OBJECT
#define NODISPLAY		14	// 14 DON'T DO ANY DISPLAY WITH THE OBJECT

// DISPLAY AN OBJECT
int	display;

/* this function you must supply the display value 0-13 or one of the above */
/* defined display functions						    */

#define display_w_opt(object,disp)\
\
   set_up_easy();\
\
   display = (disp);\
   if( display >= DRAW && display <= ERASE_ERASEHILITE_OVER)\
   {\
   ci$send(msg = message GRgraphics.GRdisplay(\
		&rtcd,\
		&MOD_ENV.md_env.matrix_type,\
		MOD_ENV.md_env.matrix,\
		&display,\
		&dspGRid),\
	   	targetid = (object).objid,\
		targetos = (object).osnum);\
   }

#define display_object(object)\
   display_w_opt(object,DRAW);

/****************************************************************/
/*                                                              */
/*  THESE FUNCTIONS DEAL WITH THE PROPERTIES OF AN OBJECT 	*/
/* THE FOLLOWING defines ARE THE DIFFERENT OPTIONS FOR THE 	*/
/* "change_properties()" FUNCTION				*/
/*                                                              */
/****************************************************************/

#define RIGID_RELATIONSHIP   	0X1	/* object has rigid owner	    */
#define PLANAR 			0x2	/* object is planar		    */
#define READ_ONLY		0x4	/* object is read only		    */
#define NEW			0x8	/* object is new		    */
#define MODIFIED		0x10	/* object has been modified	    */
#define LOCATABLE		0x20	/* object is locatable		    */
#define DISPLAYABLE		0x40	/* object is displayable	    */
#define FILLED_DISPLAY		0x80	/* display as filled object	    */
#define NOT_IN_RTREE		0X100   /* object is not in R-tree	    */
#define VIEW_INDEP		0X200	/* object is display as vw ind      */
#define SCALE_INDEP		0x400	/* object is display as vw scale ind*/

// CHANGE THE PROPERTIES OF AN OBJECT 
#define change_properties(object, set_prop, props)\
    set_properties1 = (set_prop);\
    properties1 = (props);\
    ci$send(msg = message GRvg.GRchgprops(\
	    &rtcd,\
	    &set_properties1,\
	    &properties1),\
            targetid = (object).objid,\
            targetos = (object).osnum);


// TURN THE DISPLAY OFF OF AN OBJECT
#define undisplayable(object)\
    change_properties(object, FALSE, DISPLAYABLE);

// TURN THE DISPLAY ON OF AN OBJECT
#define displayable(object)\
    change_properties(object, TRUE, DISPLAYABLE);

// MAKE AN OBJECT UNLOCATABLE
#define unlocatable(object)\
    change_properties(object, FALSE, LOCATABLE);

// MAKE AN OBJECT LOCATABLE
#define locatable(object)\
    change_properties(object, TRUE, LOCATABLE);


// GET THE PROPERTIES OF AN OBJECT 
#define get_properties(object,properties1)\
    ci$send(msg = message GRvg.GRgetprops(&rtcd,&(properties1)),\
            targetid = (object).objid,\
            targetos = (object).osnum);

// CHANGE THE PROPERTIES OF AN OBJECT 
#define put_properties(object,properties1)\
    set_properties1=1;\
    ci$send(msg = message GRvg.GRchgprops(\
	    &rtcd,\
	    &set_properties1,\
	    &(properties1)),\
            targetid = (object).objid,\
            targetos = (object).osnum);

/********************************************************************/
/*                                                                  */
/*  THESE FUNCTIONS SET UP DISPLAY PROPERTIES FOR CONSTRUCTION      */
/*                                                                  */
/********************************************************************/

#define green	1
#define red	2
#define blue	3
#define yellow	4
#define cyan	5
#define magenta	6
#define white	7

// SET THE DISPLAY SYMBOLOGY FOR CONSTRUCTION
#define set_symbology(lv,co,st,wt)\
    set_up_easy();\
    if((lv) != -1){ cst.level  = (lv);}\
    if((st) != -1){ dis.style  = (st);}\
    if((co) != -1){ dis.color  = (co);}\
    if((wt) != -1){ dis.weight = (wt);}

// RESET THE CONSTRUCTION SYMBOLOGY TO THE ACTIVE
#define reset_to_active_symbology()\
\
   set_up_easy();\
   init_cnst_list();\
   get_symb();\
   dis.color      = cnst_list.color;\
   dis.weight     = cnst_list.weight;\
   dis.style      = cnst_list.style;\
   cst.level      = cnst_list.level;

// GET THE SYMBOLOGY OF AN OBJECT 
#define get_symbology(object,symb)\
    ci$send(msg = message GRvg.GRgetsymb(&rtcd,&(symb)),\
            targetid = (object).objid,\
            targetos = (object).osnum);

// CHANGE THE SYMBOLOGY OF AN OBJECT 
#define put_symbology(object,symb)\
    ci$send(msg = message GRvg.GRputsymb(&rtcd,&(symb)),\
            targetid = (object).objid,\
            targetos = (object).osnum);

/********************************************************************/
/*                                                                  */
/*define  THESE FUNCTIONS ARE FOR MANIPULATION OF OBJECTS           */
/*                                                                  */
/********************************************************************/

// DELETE AND OBJECT WITH UNDISPLAY
#define delete_object(object,disp)\
    display_w_opt((object), (disp) );\
    ci$send(msg = message GRgraphics.GRdelete(\
		&rtcd,\
		&MOD_ENV),\
	   	targetid = (object).objid,\
		targetos = (object).osnum);

// PUT A NAME ON AN OBJECT WITH A CHECK AND AN INCREMENTER
char	object_name[132];
int	counter,counter1;

#define put_name(name,object)\
  rtcd = -1;\
  counter=0;\
  strcpy(object_name,(name));\
  while( rtcd != SUCCESS)\
  {\
    ci$send(msg = message GRvg.GRputname(\
		&rtcd,\
		object_name),\
	   	targetid = (object).objid,\
		targetos = (object).osnum);\
    if( rtcd == SUCCESS) break;\
    counter=counter+1;\
    strcpy(object_name,(name));\
    strcat(object_name,itoa(counter));\
  }\
  strcpy(name,object_name);

// GET A NAME FROM AND OBJECT ID
#define get_name(name,diname,funame,object)\
\
    	ci$send(msg = message GRvg.GRgetname(\
		&rtcd,\
		(funame)),\
	   	targetid = (object).objid,\
		targetos = (object).osnum);\
       DIsplit ( (funame), (diname), (name) );\

#define name_display(object,name,disp)\
	  if( strcmp((name),"0") != 0 )\
	  {\
            put_name((name), (object));\
	  }\
	  if((disp) != 1)\
	  {\
	     display_w_opt((object), (disp));\
	  }

struct GRobj_env	GROBJ_ENV[100];
int 			sam;
#define create_graphic_group( objects, object, name, disp)\
\
   set_up_easy();\
   cst.newflag = TRUE;\
   (object).objid = NULL_OBJID;\
   (object).osnum = MOD_ENV.md_id.osnum;\
\
   ci$send(msg = message GRgrgrp.GRconstruct(&cst),\
		targetid = (object).objid,\
		targetos = (object).osnum);\
\
   cst.newflag = FALSE;\
\
   for(loop_inc=0; loop_inc < 100; loop_inc = loop_inc + 1)\
   {\
     if((objects)[loop_inc].objid == 0 || (objects)[loop_inc].objid == NULL_OBJID ) break;\
     GROBJ_ENV[loop_inc].obj_id = (objects)[loop_inc];\
     GROBJ_ENV[loop_inc].mod_env = MOD_ENV;\
   }\
\
   ci$send(msg = message GRgrgrp.GRadd_components(\
		&rtcd,&MOD_ENV,&loop_inc,GROBJ_ENV,NULL,NULL),\
		targetid = (object).objid, \
		targetos = (object).osnum);\
\
   name_display(object,name,disp);

#define add_to_graphic_group(objects, object)\
\
   set_up_easy();\
   for(loop_inc=0; loop_inc < 100; loop_inc = loop_inc + 1)\
   {\
     if((objects)[loop_inc].objid == 0 || (objects)[loop_inc].objid == NULL_OBJID ) break;\
     GROBJ_ENV[loop_inc].obj_id = (objects)[loop_inc];\
     GROBJ_ENV[loop_inc].mod_env = MOD_ENV;\
   }\
\
   ci$send(msg = message GRgrgrp.GRadd_components(\
		&rtcd,&MOD_ENV,&loop_inc,GROBJ_ENV, NULL, NULL),\
		targetid = (object).objid,\
		targetos = (object).osnum);

// THIS FUNCTION WILL RETRIEVE THE ORIENTATION AND ORIGIN OF A Coord

#define get_coord_data(object,origin,matriX,x_vect,y_vect,z_vect)\
  	ci$send( msg = message GRgencs.GRgetmatrix(\
		&rtcd,(matriX)),\
	   	targetid = (object).objid,\
		targetos = (object).osnum );\
	(origin)[0] = (matriX)[3];\
	(origin)[1] = (matriX)[7];\
	(origin)[2] = (matriX)[11];\
	(x_vect)[0] = (matriX)[0];\
	(x_vect)[1] = (matriX)[4];\
	(x_vect)[2] = (matriX)[8];\
	(y_vect)[0] = (matriX)[1];\
	(y_vect)[1] = (matriX)[5];\
	(y_vect)[2] = (matriX)[9];\
	(z_vect)[0] = (matriX)[2];\
	(z_vect)[1] = (matriX)[6];\
	(z_vect)[2] = (matriX)[10];
	
struct	GRparms proJ_parms;

#define pro_point_on_element(object,stpt,enpt,u,v)\
\
   set_up_easy();\
   ci$send(msg = message GRgraphics.GRptproject(\
		&rtcd,\
		&MOD_ENV.md_env.matrix_type,\
		MOD_ENV.md_env.matrix,\
		(stpt),\
		(enpt),\
		&proJ_parms),\
		targetid = OBJECT1.objid,\
	  	targetos = OBJECT1.osnum);\
	(u)=proJ_parms.u;\
	(v)=proJ_parms.v;


#endif


