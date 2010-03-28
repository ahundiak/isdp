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
#include "EMSstruct.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "growner.h"
#include "acdef.h"
#include "acmacros.h"
#include "macro.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "emsdattyp.h"
#include "grmacros.h"

#ifndef ci_setmd_include
#define SUCCESS  	134250505
#define SOL_SUC  	2654217
#define EXP_SCALAR 	0
#define EXP_DISTANCE 	1
#define EXP_ANGLE 	2
#endif

#ifndef ci_wire_include
long                    msg;
#endif

#ifndef ci_setmd_include
#ifndef ci_wire_include
int			rtcd,loop_inc;
IGRboolean              Poly_inx;
double                  double6[6],double100[100];
double                  Uval,Vval;
struct GRid      	TEMP_GRID;
struct GRmd_env  	MOD_ENV;
struct IGRdisplay	dis;
struct GRvg_construct   cst;
#endif
struct GRid      	dspGRid,TEMP_GRID_NEW,TEMP_GRID1,TEMP_GRIDS[100];
struct GRmd_env  	ALT_ENV;
struct GRsymbology	symb;
IGRshort     	        set_properties1,properties1;
IGRshort     	        props;
IGRshort                lev2,
		       *p_lev;
double			*Dbl9,*Dbl6,*Dbls;
#endif

double                  double_1,double_2,Coord_origin[3],
		        Coord_x[3],Coord_y[3],Coord_z[3],Coord_matrix[16];
struct IGRdisplay	dis2,
		       *p_dis;




		
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
		EMdpb_get_trans();

extern	char 	*malloc();
extern  int	free();
extern 		sprintf();

extern	char    ASbroadcast_in_progress,
		*strchr(),
		*strrchr(),
		*strncpy();
extern int	strncmp();



/*---------------------- display$object -------------------------------

   display$object( GRid_in = TEMP_GRID,
		   disp    = DRAW )

   gr$display_object( object_id,
                      md_env = NULL,
                      mode   = GRbd )
 */

#omdef display$object( GRid_in = TEMP_GRID,
                       disp    = DRAW )

   GRdisplay_object(&(GRid_in),NULL,(disp))

#endomdef

/*---------------------- undisplay$object -------------------------------

   undisplay$object( GRid_in = TEMP_GRID,
		     disp    = ERASE )

   gr$display_object( object_id,
                      md_env = NULL,
                      mode   = GRbd )
 */

#omdef undisplay$object( GRid_in = TEMP_GRID,
                         disp    = ERASE )

   GRdisplay_object(&(GRid_in),NULL,(disp))

#endomdef

/*---------------------- hilite$object -------------------------------

   hilite$object( GRid_in = TEMP_GRID,
		  disp    = HILITE )

   gr$display_object( object_id,
                      md_env = NULL,
                      mode   = HILITE )
 */

#omdef hilite$object( GRid_in = TEMP_GRID,
                      disp    = HILITE )

   GRdisplay_object(&(GRid_in),NULL,(disp))

#endomdef

/*---------------------- unhilite$object -------------------------------

   unhilite$object( GRid_in = TEMP_GRID,
		    disp    = ERASEHILITE )

   gr$display_object( object_id,
                      md_env = NULL,
                      mode   = GRbd )
 */

#omdef unhilite$object( GRid_in = TEMP_GRID,
                        disp    = ERASEHILITE )

   GRdisplay_object(&(GRid_in),NULL,(disp))

#endomdef

/*---------------------- halfhilite$object -------------------------------

   halfhilite$object( GRid_in = TEMP_GRID,
		      disp    = HALFHILITE )

   gr$display_object( object_id,
                      md_env = NULL,
                      mode   = GRbd )
 */

#omdef halfhilite$object( GRid_in = TEMP_GRID,
                          disp    = HALFHILITE )

   GRdisplay_object(&(GRid_in),NULL,(disp))

#endomdef

/*---------------------- make$displayable -------------------------------

   make$displayable( GRid_in = TEMP_GRID,
		     set     = TRUE,
		     prop    = DISPLAYABLE )

   gr$put_properties( object_id,
                      action = 1,
                      properties_mask )
 */

#omdef make$displayable( GRid_in = TEMP_GRID,
		         set     = TRUE,
		         prop    = DISPLAYABLE )

   GRchange_properties(&(GRid_in), (set), (prop))

#endomdef

/*---------------------- make$undisplayable -------------------------------

   make$undisplayable( GRid_in = TEMP_GRID,
		       set     = FALSE,
		       prop    = DISPLAYABLE )

   gr$put_properties( object_id,
                      action = 1,
                      properties_mask )
 */

#omdef make$undisplayable( GRid_in = TEMP_GRID,
		           set     = FALSE,
		           prop    = DISPLAYABLE )

   GRchange_properties(&(GRid_in), (set), (prop))

#endomdef

/*---------------------- make$locatable -------------------------------

   make$locatable( GRid_in = TEMP_GRID,
		   set     = TRUE,
		   prop    = LOCATABLE )

   gr$put_properties( object_id,
                      action = 1,
                      properties_mask )
 */

#omdef make$locatable( GRid_in = TEMP_GRID,
		       set     = TRUE,
		       prop    = LOCATABLE )

   GRchange_properties(&(GRid_in), (set), (prop))

#endomdef

/*---------------------- make$unlocatable -------------------------------

   make$unlocatable( GRid_in = TEMP_GRID,
		     set     = FALSE,
		     prop    = LOCATABLE )

   gr$put_properties( object_id,
                      action = 1,
                      properties_mask )
 */

#omdef make$unlocatable( GRid_in = TEMP_GRID,
		         set     = FALSE,
		         prop    = LOCATABLE )

   GRchange_properties(&(GRid_in), (set), (prop))

#endomdef

/*---------------------- make$filled -------------------------------

   make$filled( GRid_in = TEMP_GRID,
		set     = TRUE,
		prop    = FILLED_DISPLAY )

   gr$put_properties( object_id,
                      action = 1,
                      properties_mask )
 */

#omdef make$filled( GRid_in = TEMP_GRID,
		    set     = TRUE,
		    prop    = FILLED_DISPLAY )

   GRchange_properties(&(GRid_in), (set), (prop))

#endomdef

/*---------------------- make$unfilled -------------------------------

   make$unfilled( GRid_in = TEMP_GRID,
		  set     = FALSE,
		  prop    = FILLED_DISPLAY )

   gr$put_properties( object_id,
                      action = 1,
                      properties_mask )
 */

#omdef make$unfilled( GRid_in = TEMP_GRID,
		      set     = FALSE,
		      prop    = FILLED_DISPLAY )

   GRchange_properties(&(GRid_in), (set), (prop))

#endomdef

/*---------------------- make$scale_ind -------------------------------

   make$scale_ind( GRid_in = TEMP_GRID,
		   set     = TRUE,
		   prop    = SCALE_INDEP )

   gr$put_properties( object_id,
                      action = 1,
                      properties_mask )
 */

#omdef make$scale_ind( GRid_in = TEMP_GRID,
		       set     = TRUE,
		       prop    = SCALE_INDEP )

   GRchange_properties(&(GRid_in), (set), (prop))

#endomdef

/*---------------------- make$unscale_ind -------------------------------

   make$unscale_ind( GRid_in = TEMP_GRID,
		     set     = FALSE,
		     prop    = SCALE_INDEP )

   gr$put_properties( object_id,
                      action = 1,
                      properties_mask )
 */

#omdef make$unscale_ind( GRid_in = TEMP_GRID,
		         set     = FALSE,
		         prop    = SCALE_INDEP )

   GRchange_properties(&(GRid_in), (set), (prop))

#endomdef

/*---------------------- get$properties -------------------------------

   get$properties( GRid_in = TEMP_GRID,
		   props )

   gr$get_properties( object_id,
                      properties_mask )
 */

#omdef get$properties( GRid_in = TEMP_GRID,
                       props )

#if (! om$specified(props))
#  omerror "Must specify props"
#else
   GRget_properties(&(GRid_in),&(props))
#endif

#endomdef

/*---------------------- put$properties -------------------------------

   put$properties( GRid_in = TEMP_GRID,
		   props )

   gr$put_properties( object_id,
                      action  = 1,
                      properties_mask )
 */

#omdef put$properties( GRid_in = TEMP_GRID,
		       action  = 1,
                       props )

#if (! om$specified(props))
#  omerror "Must specify props"
#else
   GRchange_properties(&(GRid_in), (action), (props))
#endif

#endomdef

/*---------------------- get$symbology -------------------------------

   get$symbology( GRid_in = TEMP_GRID,
		  symb )

   gr$get_symbology( GRid_in = TEMP_GRID,
                     symb )
 */

#omdef get$symbology( GRid_in = TEMP_GRID,
                      symb )

#if (! om$specified(symb))
#  omerror "Must specify symb"
#else
   get_symbology((GRid_in),(symb))
#endif

#endomdef

/*---------------------- put$symbology -------------------------------

   put$symbology( GRid_in = TEMP_GRID,
		  symb )

   gr$put_symbology( GRid_in = TEMP_GRID,
                     symb )
 */

#omdef put$symbology( GRid_in = TEMP_GRID,
                      symb )

#if (! om$specified(symb))
#  omerror "Must specify symb"
#else
   put_symbology((GRid_in),(symb))
#endif

#endomdef

/*---------------------- delete$object -------------------------------

   delete$object( GRid_in = TEMP_GRID,
		  disp    = ERASE )

   gr$delete_object( msg,
		     md_env       = NULL,
		     object_id,
		     display_flag = 1)
 */

#omdef delete$object( GRid_in = TEMP_GRID,
		      disp    = TRUE )

   GRdelete_object(&(msg),NULL,&(GRid_in),(disp))

#endomdef

/*---------------------- copy$object -------------------------------

   copy$object( GRid_in  = TEMP_GRID,
		GRid_out = TEMP_GRID_NEW )

   gr$copy_object( msg,
                   object_id,
                   md_env       = NULL,
                   new_env      = NULL,
                   new_id       = NULL,
                   display_flag = 1 )
 */

#omdef copy$object( GRid_in  = TEMP_GRID,
		    GRid_out = TEMP_GRID_NEW )

    GRcopyobject(&(msg),&(GRid_in),NULL,NULL,&(GRid_out),1)

#endomdef

/*---------------------- put$name -------------------------------

   put$name( GRid_in = TEMP_GRID,
             name    = "OBJECT" )

   gr$put_name( msg,
                object_id,
                name )
 */

#omdef put$name( GRid_in = TEMP_GRID,
                 name    = "OBJECT" )

   GRput_name(&(msg),&(GRid_in),(name))

#endomdef

/*---------------------- get$coordinate_data -------------------------------

   get$coordinate_data( GRid_in  = TEMP_GRID,
			origin   = Coord_origin,
			x_vector = Coord_x,
			y_vector = Coord_y,
			z_vector = Coord_z,
			matric   = Coord_matrix )

   gr$get_coordinate_data( GRid_in  = TEMP_GRID, 
			   origin   = Coord_origin, 
			   x_vector = Coord_x,
			   y_vector = Coord_y,
			   z_vector = Coord_z,
			   matrix   = Coord_matrix )
 */

#omdef get$coordinate_data( GRid_in  = TEMP_GRID,
			    origin   = Coord_origin, 
			    x_vector = Coord_x,
			    y_vector = Coord_y,
			    z_vector = Coord_z,
			    matrix   = Coord_matrix )

   get_coord_data((GRid_in),(origin),(matrix),(x_vector),(y_vector),(z_vector))

#endomdef

/*---------------------- project$pnt_on_element -------------------------------

   project$pnt_on_element( GRid_in = TEMP_GRID,
			   point1,
			   point2,
			   u_value = double_1,
			   v_value = double_2 )

   gr$project_pnt_on_element( msg,
			      md_env = NULL,
			      object_id,
			      point,
                              proj_pt,
                              u_parm,
                              v_parm )
 */

#omdef project$pnt_on_element( GRid_in = TEMP_GRID,
			       point1,
			       point2,
			       u_value = double_1,
			       v_value = double_2 )

#if (! ( om$specified(point1) || om$specified(point2)))
#   omerror "Must specify point1 and point2"
#else
    GRproject_point_on_element(&(msg),&(GRid_in),NULL,(point1), 
		(point2),&(u_value),&(v_value))
#endif

#endomdef

/*---------------------- project$point_on_element -----------------------------

   project$point_on_element( GRid_in     = TEMP_GRID,
			     point1,
			     point2,
			     GRid_out    = TEMP_GRID_NEW,
			     u_value     = Uval,
			     v_value     = Vval,
			     polygon_inx = Poly_inx )

   gr$project_pnt_on_element( msg,
			      md_env = NULL,
			      object_id,
			      point,
                              proj_pt,
                              u_parm,
                              v_parm )
 */

#omdef project$point_on_element( GRid_in     = TEMP_GRID,
			         point1,
			         point2,
				 GRid_out    = TEMP_GRID_NEW,
			         u_value     = Uval,
			         v_value     = Vval,
				 polygon_inx = Poly_inx )

#if (! ( om$specified(point1) || om$specified(point2)))
#   omerror "Must specify point1 and point2"
#else
    pro_point_on_element((GRid_in),(point1),(point2),(GRid_out),
			 (u_value), (v_value),(polygon_inx))
#endif

#endomdef

/*---------------------- gr$set_symbology -------------------------------

#omdef gr$set_symbology(lv     = -1,
			level  = -1,
		      	co     = -1,
			color  = -1,
		      	st     = -1,
			style  = -1,
		      	wt     = -1,
			weight = -1)

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
		( 	lv     = -1,
			level  = -1,
		      	co     = -1,
			color  = -1,
		      	st     = -1,
			style  = -1,
		      	wt     = -1,
			weight = -1 )

#if   	om$specified (level) || om$specified (color) || om$specified (style) || om$specified (weight) 
       	set_symbology((level), (color), (style), (weight))
#else
       	set_symbology((lv), (co), (st), (wt))
#endif

#endomdef

/*---------------------- set$symbology -------------------------------
-----------------------------------------------------------------------*/

#omdef set$symbology( lv     = -1,
		      level  = -1,
		      co     = -1,
		      color  = -1,
		      st     = -1,
		      style  = -1,
		      wt     = -1,
		      weight = -1 )

#if ( om$specified(level) || om$specified(color) || om$specified(style) || om$specified(weight))
   set_symbology((level), (color), (style), (weight))
#else
   set_symbology((lv), (co), (st), (wt))
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

  	reset_to_active_symbology()
#endomdef

/*---------------------- reset$symbology -----------------------------
-----------------------------------------------------------------------*/

#omdef reset$symbology()

   reset_to_active_symbology()

#endomdef

/*---------------------- gr$get_name ---------------------------------

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
#ifndef ci_surface_include
IGRchar	object1name[132];
#endif

IGRchar	directoryname[132],fullpathname[132];

#omdef gr$get_name(	GRid_in = TEMP_GRID, 
		 	name = object1name,	
		 	dir_name = directoryname,	
		 	full_name = fullpathname)

  get_name((name),(dir_name),(full_name),(GRid_in))
#endomdef

/*---------------------- get$name -------------------------------
-----------------------------------------------------------------------*/

#omdef get$name( GRid_in   = TEMP_GRID,
		 name      = object1name,	
		 dir_name  = directoryname,	
		 full_name = fullpathname )

   get_name((name),(dir_name),(full_name),(GRid_in))

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

	rtcd = di$rm_name( regexp = name)

#endomdef

/*---------------------- remove$name ---------------------------------
-----------------------------------------------------------------------*/

#omdef remove$name( name ) 

   rtcd = di$rm_name( regexp = name )

#endomdef

/*---------------------- gr$create_graphic_group ------------------------

#omdef 	gr$create_graphic_group(
			GRids_in = TEMP_GRIDS,	
			GRid_out = TEMP_GRID)

 Abstract:

	This macro will create a graphic group of the array of GRids_in.
	The graphic group id is the GRid_out.

 Arguments:

	GRids_in	I	struct GRid	Input array of objects.

	GRid_out	O	struct GRid	Output graphic group id.

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
			GRid_out = GRA_GROUP);

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef 	gr$create_graphic_group(
			GRids_in = TEMP_GRIDS,	
			GRid_out = TEMP_GRID)

	create_graphic_group( GRids_in, GRid_out)
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

	add_to_graphic_group( GRids_in, GRid_in)
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
        There is a macro in grmacros.h which has the same name and
        performs the same service.  The grmacros.h version has a
        different argument list.  It is strongly advised to use the
        macro in grmacros.h rather than this one. - EMS Development

 Caveats:

 History:

	8/2/90	jvh	Created and documented.
        03/10/92  scw   Changed function called from EMdpb_get 
                        to EMdpb_get_trans

-----------------------------------------------------------------------*/

#omdef 	gr$get_active_u_order( order)

  	EMdpb_get_trans(&rtcd,0,&(order))
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
        There is a macro in grmacros.h which has the same name and
        performs the same service.  The grmacros.h version has a
        different argument list.  It is strongly advised to use the
        macro in grmacros.h rather than this one. - EMS Development

 Caveats:

 History:

	8/2/90	jvh	Created and documented.
        03/10/92  scw   Changed function called from EMdpb_get
                        to EMdpb_get_trans

-----------------------------------------------------------------------*/

#omdef 	gr$get_active_v_order( order)	

  	EMdpb_get_trans(&rtcd,1,&(order))
#endomdef


/*******
	THESE ARE THE SUPPORTING FUNCTIONS FOR EACH OF THE ABOVE
	MACROS. THESE ARE SUBJECT TO CHANGE SO I DON'T RECOMEND
	THE COPYING OF THE CODE BELOW FOR USE.
*******/

#ifndef ci_setmd_include
#define set_up_easy()  set_up_cnst();

#define set_up_cnst()\
   ci$get_module_info(md_env=&MOD_ENV);\
   init_cnst_list();\
   get_symb();\
   if ( p_dis )\
   {\
     dis.color      = p_dis->color;\
     dis.weight     = p_dis->weight;\
     dis.style      = p_dis->style;\
   }\
   else\
   {\
     dis.color      = cnst_list.color;\
     dis.weight     = cnst_list.weight;\
     dis.style      = cnst_list.style;\
   }\
   cst.msg        = &rtcd;\
   cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;\
   cst.display    = &dis;\
   cst.env_info   = &MOD_ENV;\
   cst.newflag    = 0;\
   if ( p_lev )\
     cst.level      = *p_lev;\
   else\
     cst.level      = cnst_list.level;\
   cst.geometry   = 0;\
   cst.class_attr = 0;\
   cst.name       = 0;\
   GRfindmod(&dspGRid);


/****************************************************************/
/*                                                              */
/*define THIS SECTION DEALS WITH THE DISPLAYING OF AN OBJECT 	*/
/* THE FOLLOWING defines ARE THE DIFFERENT OPTIONS FOR THE 	*/
/* "display_w_opt()" FUNCTION					*/
/*                                                              */
/****************************************************************/

#ifndef ci_wire_include
#define	DRAW			GRbd	// 0 DRAW THE OBJECT
#endif

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

#endif

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
\
    p_dis = &dis2;\
    p_lev = &lev2;\
    if((lv) != -1){ lev2 = (lv);}\
    if((st) != -1){ dis2.style  = (st);}\
    if((co) != -1){ dis2.color  = (co);}\
    if((wt) != -1){ dis2.weight = (wt);}

// RESET THE CONSTRUCTION SYMBOLOGY TO THE ACTIVE
#define reset_to_active_symbology()\
\
   p_dis = 0;\
   p_lev = 0;\
   set_up_easy();\
   init_cnst_list();\
   get_symb();

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

#ifndef ci_setmd_include

#define name_display(object,name,disp)\
	  if( strcmp((name),"0") != 0 )\
	  {\
            put_name((name), (object));\
	  }\
	  if((disp) != 1)\
	  {\
	     display_w_opt((object), (disp));\
	  }

#endif

struct GRobj_env	GROBJ_ENV[100];
int 			sam;
#define create_graphic_group( objects, object)\
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
		targetos = (object).osnum);

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

#define pro_point_on_element(object,stpt,enpt,leaf,uval,vval,poly)\
\
   set_up_easy();\
   ci$send(msg = message GRgraphics.GRptproject(\
		&rtcd,\
		&MOD_ENV.md_env.matrix_type,\
		MOD_ENV.md_env.matrix,\
		(stpt),\
		(enpt),\
		&proJ_parms),\
		targetid = (object).objid,\
	  	targetos = (object).osnum);\
	(uval)=proJ_parms.u;\
	(vval)=proJ_parms.v;\
	(leaf)=proJ_parms.leaf_id;\
	(poly)=proJ_parms.polygon_inx;

// GET A NAME FROM AND OBJECT ID
#define get_name(bname,diname,funame,object)\
\
    	ci$send(msg = message GRvg.GRgetname(\
		&rtcd,\
		(funame)),\
	   	targetid = (object).objid,\
		targetos = (object).osnum);\
       di$split (pathname = (funame),dirname = (diname), name = (bname));\

#endif
