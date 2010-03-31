class              HStridata
spec_path	   "$DRAFT/display/spec"
spec_path	   "$DRAFT/go/spec"
super_class        CEO_LOCATE
command_string     HSM_M_GenTriData,0,HStridata
product_name       "$EMS"
start_state        get_filename


specification

instance
	{
	IGRchar			filename[132];
	IGRint                	win_no;
	IGRint                	gpipe_id;
	struct GRid		gragad;
	}


implementation

#define CHECK_RETURN_CODES	1

#include "hsurf_import.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "dpdef.h"

#include "grdpbmacros.h"
#include "madef.h"

#include "msdef.h"
#include "ms.h"
#include "msmacros.h"

#include "fidef.h"
#include "fi.h"

#include "hsmsg.h"
#include "tools.h"

#include "igewindef.h"
#include "igewinmacros.h"

#include "hsurf.h"
#include "hsurfdef.h"
#include "hsurferrpriv.h"

from IGEgragad	import DPupdate;

state_table


state 	*			
  	on EX_RJT_MOVEON state .
	on EX_RESTART   state .


state 	get_filename	
	message 	"Generate Triangle Data"
	prompt		"Input filename"
	filter		get_event
  	on EX_STRING    do check_filename
                           on SUCCESS
	                      state get_window
	                   on ELSE
	                      state .
	                state .
  	on EX_BACK_UP   state .


state 	get_window	
	prompt		"Select window"		/* HS_P_SelWin */
	filter		get_event
  	on EX_DATA	do get_win_from_data_button
			state process_into_triangles
  	on EX_STRING    do get_win_from_keyin
                           on SUCCESS
	                      state process_into_triangles
	                   on ELSE
	                      state .
	                state .
  	on EX_BACK_UP   state .


state	process_into_triangles
	status 		"Generating Triangle Data...."
	execute		generate_triangle_data
	on ELSE		state	terminate 

 
/*--- check_filename -----------------------------------------*/

action check_filename

/*
DESCRIPTION
	Checks that the given filename is valid.
*/

{
	/* for the time being, there is no check */
	strcpy ( me->filename, me->event1.event.keyin );

}  /* check_filename */



/*--- get_win_from_data_button -----------------------------------------*/

action get_win_from_data_button

/*
DESCRIPTION
	Gets the window information & sets up the form when the user
	selects a window with a data button rather than a keyin.
*/

{
	struct EX_button  *resp_ptr;

	
	resp_ptr = me->response_data;
	me->gragad.osnum = resp_ptr->osnum;
	me->gragad.objid = resp_ptr->objid;

}  /* get_win_from_data_button */

 
/*--- get_win_from_keyin -----------------------------------------*/

action get_win_from_keyin

/*
DESCRIPTION
	Gets the window information & sets up the form when the user
	selects a window with a keyin.
*/

{
	IGRlong     msg;
	IGRlong     num_id;
	IGRlong     total_found;
	struct GRid wnid[40];


	num_id = 0;
	dp$get_gragad_id( msg         = &msg,
	                  name        = me->event1.event.keyin,
                          array_size  = 40,
                          total_num   = &total_found,
	                  numberofids = &num_id,
	                  found_GRids = wnid,
	                  type_gragad = ALL_TYPES );

	MSG_ERRCHK( msg, "HSgentridata:  dp$get_gragad_id failed" );

	if ( num_id == 0 )
	   {
	   /* Invalid window */
	   *sts = OM_W_WARNING;
	   ex$message( msgnumb = HS_E_WinNotFound );
	   }
	else
	   {
	   /* store window name and GRid in instance data */
	   *sts = OM_S_SUCCESS;
	   me->gragad.osnum = wnid[0].osnum;
	   me->gragad.objid = wnid[0].objid;

	   }
}  /* get_win_from_keyin */


/*----- generate_triangle_data ------------------------------------------------------- */

action generate_triangle_data

/*
DESCRIPTION
	This action generates triangle data for all elements in the window.  First,
	it sets the tiler into "triangle" mode.  Next, it makes the window into a
	shading window (unless it already is).  Then, it updates the window, which
	causes the surfaces to be broken into triangles and the triangles written
	to the output file.  Next, it gets the tiler out of "triangle" mode.  And,
	finally, it restores the window.
*/

	{
	IGRlong			msg;
	IGRlong			which_error;
	IGRint            	org_x, org_y, ext_x, ext_y, ifb_present, ret_bytes;
	IGRboolean		was_wireframe;
	IGRchar			win_classname[OM_K_MAXCLASS_LEN];

	struct gragad_inst	gadget_stuff;
	struct HS_tiler_globals tiler_globals;
	
	struct var_list		var_list1[4];
	extern IGRboolean	HScheck_configuration();

	FILE			*fp;
	IGRshort		prev_msg_data, dummy;
	
	/* get the name, window number and gpipe id of the window */
	var_list1[0].var             = WIN_NO;
	var_list1[0].var_ptr         = &(me->win_no);
	var_list1[0].num_bytes       = sizeof( IGRint );
	var_list1[0].bytes_returned  = &ret_bytes;
	var_list1[1].var             = GPIPE_ID;
	var_list1[1].var_ptr         = &(me->gpipe_id);
	var_list1[1].num_bytes       = sizeof( IGRint );
	var_list1[1].bytes_returned  = &ret_bytes;
	var_list1[2].var             = GRAGAD_INST_STRUCT;
	var_list1[2].var_ptr         = &gadget_stuff;
	var_list1[2].num_bytes       = sizeof( struct gragad_inst );
	var_list1[2].bytes_returned  = &ret_bytes;
	var_list1[3].var             = END_PARAM;

	dp$inq_set_gragad( msg          = &msg,
	                   inq0_set1    = 0,
	                   osnum        = me->gragad.osnum,
	                   gragad_objid = me->gragad.objid,
	                   which_error  = &which_error,
	                   var_list     = var_list1 );

	MSG_ERRCHK( msg, "ShadedNC: dp$inq_set_gragad failed" );

	om$get_classname( classname 	= win_classname,
			  objid 	= me->gragad.objid,
			  osnum 	= me->gragad.osnum);


	/* open the triangle file */
	fp = fopen ( me->filename, "w" );

	/* set the tiler into "triangle" mode */
	HSenable_triangles( fp );

	/* if the window is wireframe, set up a temporary shading window */
	if ( (was_wireframe = (strcmp( win_classname, "IGEgragad" ) == 0) ) )
	   {
	   /* change wireframe class to HSgragad */
	   *sts = om$change_class( classname 	= "HSgragad",
	                   	   osnum 	= me->gragad.osnum,
                           	   objid	= me->gragad.objid );
	   OM_ERRCHK( *sts, "HSgentridata: om$change_class failed.");

	   if ( HScheck_configuration (me->win_no, 0) )
	      {
	      /* default the tiler globals.  (replaces call to HSgg_construct) */
	      tiler_globals.num_lights = 0;
	      tiler_globals.persp_angle = 0;
	      tiler_globals.tiler_toler = 0.5;
	      tiler_globals.reflect_parms = 0;
	      tiler_globals.diffuse_intens = 0;
	      tiler_globals.ifb_globals.max_shades = (255 << 8) & 128;
	      tiler_globals.ifb_globals.replic_factor = 1;
	      tiler_globals.ifb_globals.disp_flags = HSdf_shading | HSdf_1x1_screen_door;

	      /* set the ifb flag */
	      ige$inq_term_info( db_enabled = &ifb_present );

	      /* get the window region */
	      Inq_win_region ( me->win_no, &org_x, &org_y, &ext_x, &ext_y );

	      /* initialize the tiler structures for the window */
	      status = HSinit_display (	me->win_no,
					gadget_stuff.min_x_dep + org_x,
					gadget_stuff.min_y_dep + org_y,
					(gadget_stuff.max_x_dep - gadget_stuff.min_x_dep) + 1,
					(gadget_stuff.max_y_dep - gadget_stuff.min_y_dep) + 1,
					&(gadget_stuff.gragad),
					&(tiler_globals),
					ifb_present );
	      }
	   }

	/* turn off messages so "Shading display in progress" won't appear on screen */
	ms$onoff(	msg		= &msg,
			prevstate	= &prev_msg_data,
			type		= MS_OFF );

	/* update the window. NOTE: since the tiler is in "triangle" mode, this will
	   cause all visible surfaces to be broken into triangles and be written out */
	*sts = om$send( msg 		= message IGEgragad.DPupdate ( &msg, NULL, FALSE ),
	                targetos 	= me->gragad.osnum,
                        targetid	= me->gragad.objid );

	/* turn messages back on */
	ms$onoff(	msg		= &msg,
			prevstate	= &dummy,
			setstate	= prev_msg_data,
			type		= MS_SET );

	/* if the window was wireframe, delete the temporary shading window */
	if ( was_wireframe )
	   {
	   /* change window class back to wireframe */
	   *sts = om$change_class( classname 	= "IGEgragad",
	                   	   osnum 	= me->gragad.osnum,
                           	   objid	= me->gragad.objid );
	   OM_ERRCHK( *sts, "ShadedNC: om$change_class failed.");

	   /* delete the tiler data associated with the temporary shading window */
	   HSdelete( me->gpipe_id );
	   }

	/* get the tiler out of "triangle" mode */
	HSdisable_triangles();

	/* close the triangle file */
	fclose ( fp );

	/* update the window to restore it */
	*sts = om$send( msg 		= message IGEgragad.DPupdate ( &msg, NULL, FALSE ),
	                targetos 	= me->gragad.osnum,
                        targetid	= me->gragad.objid );

	OM_ERRCHK( *sts, "HSgentridata: DPupdate failed." );
	MSG_ERRCHK( msg, "HSgentridata: DPupdate failed." );
	}  /* generate_triangle_data*/
