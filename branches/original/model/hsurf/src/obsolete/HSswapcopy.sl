
/*
	This file defines and implements the following commands:

	   Swap Windows, Copy Window

	The command table entries for the commands should be:

	   "Swap Window", GRSwV, HSswapcopy, 0
	   "Copy Window", GRCpV, HSswapcopy, 1
*/

class              HSswapcopy
super_class        CEO_LOCATE
command_string     HSM_M_SwapWin,0,GRSwV
synonym            HSM_M_CopyWin,1,GRCpV
product_name       "$MODEL"
start_state        start

state_table

#define SWAP 0
#define COPY 1

#include "../include/hsmsg.h"

specification

#include "igrdp.h"
#include "dpstruct.h"
#include "dp.h"

#include "hsdef.h"
#include "hsurf.h"
#include "hsurferrpriv.h"

#include "vedef.h"
#include "ve.h"
#include "ve_inst.h"

instance
	{
	struct GRid             ids[2];
	struct gragad_inst      wireframe_inst[2];
	struct HS_tiler_globals shading_inst[2];
	struct VEinstance_data  visedges_inst[2];
	IGRchar                 types[2];
	IGRchar                 names[2][GRNAME_SIZE];
	}

implementation

#define SWAP 0
#define COPY 1

#define WIREFRAME_WIN 0
#define SHADING_WIN   1
#define VISEDGES_WIN  2
 
#include "hsurf_import.h"
#include "stdio.h"
#include "OMerrordef.h"
#include "msdef.h"

#include "igewindef.h"
#include "igewinmacros.h"
#include "igr.h"

#include "fontdef.h"
#include "font.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "godef.h"

#include "msdef.h"
#include "ms.h"
#include "msmacros.h"

#include "hsurferrpriv.h"
#include "hsmsg.h"

#include "griodef.h"
#include "griomacros.h"

from IGEgragad import DPcal;
from HSgragad  import HSinquire, HSset;
from VEgragad  import VEinquire, VEset;

state *			/* default transitions for all states */
   on EX_RJT_MOVEON state .
   on EX_RESTART    state get_window1
   on EX_BACK_UP    state -


state start
   on CMD_TYPE = SWAP
      do message_key HSM_M_SwapWin
      state get_window1
   on CMD_TYPE = COPY
      do message_key HSM_M_CopyWin
      state get_window1

state get_window1
   execute load_window_prompt( sts, 0 )
   filter  get_event

      on EX_DATA or EX_STRING 
         do get_selected_window( sts, 0 )
            on SUCCESS
               state get_window2
            on ELSE
               state .
         state .

state get_window2
   execute load_window_prompt( sts, 1 )
   filter  get_event

      on EX_DATA or EX_STRING
         do get_selected_window( sts, 1 )
            on SUCCESS
               on CMD_TYPE = SWAP
                  do process_windows
                  state get_window1
               on CMD_TYPE = COPY
                  do process_windows
                  state .
               state .	       
            on ELSE
               state .
         state .


/*--- load_window_prompt -----------------------------------------------*/

action load_window_prompt( IGRint *sts; IGRint which_one )

/*
DESCRIPTION
	This action loads a select window prompt based on the command type and
	the window that is being asked for (i.e., the first or the second).
*/

	{
	IGRint message_no;

	*sts = OM_S_SUCCESS;

	switch( me->mytype )
	   {
	   case SWAP :

	      if ( which_one == 0 )
	         message_no = HS_P_SelSrcWin;
	      else
	         message_no = HS_P_SelDstWin;
	      break;

	   case COPY :

	      if ( which_one == 0 )
	         message_no = HS_P_SelFromWin;
	      else
	         message_no = HS_P_SelToWin;
	      break;

	   }  /* end: switch */

	ex$message( msgnumb = message_no, buff = me->prompt );

	return( OM_S_SUCCESS );

	}  /* load_window_prompt */


/*--- get_selected_window ----------------------------------------------*/

action get_selected_window( IGRint *sts; IGRint which_one )

/*
DESCRIPTION
	This action get the window selected by the user.  If a window was selected
	*sts is set to OM_S_SUCCESS.  Otherwise, *sts is set to OM_W_WARNING and
	an error message is displayed.
*/

	{
	IGRlong      msg;
	IGRlong      total_found;
	IGRint       num_ids;
	struct GRid  window_ids[40];

	*sts = OM_S_SUCCESS;

	if ( me->event1.response == EX_DATA )
	   {
	   /* user hit a data button in a window */
	   me->ids[which_one].objid = me->event1.event.button.objid;
	   me->ids[which_one].osnum = me->event1.event.button.osnum;
	   }
	else
	   {
	   /* user keyed in a window name */
	   num_ids = 0;

	   /* get the window id(s) from the string */
	   dp$get_gragad_id( msg         = &msg,
	                     name        = me->event1.event.keyin,
                             array_size  = 40,
                             total_num   = &total_found,
	                     numberofids = &num_ids,
	                     found_GRids = window_ids,
	                     type_gragad = ALL_TYPES );

	   if ( num_ids == 0 )
	      {
	      /* Invalid window */
	      *sts = OM_W_WARNING;
	      ex$message( msgnumb = HS_E_WinNotFound );
	      }
	   else if ( num_ids == 1 )
	      {
	      me->ids[which_one] = window_ids[0];
	      }
	   else
	      {
              *sts = OM_W_WARNING;
	      ex$message( msgnumb = HS_E_WinAmbig );
	      }

	   }  /* end: else */

	}  /* get_selected_window */


/*--- change_class_and_name ------------------------------------------------------*/

action change_class_and_name( IGRint which_one; IGRint from_type; IGRint to_type )

/*
DESCRIPTION
	This action changes the class and name of a window.  The original type
	of the window is passed in in from_type and the type that the window
	is supposed to be changed to is passed in in to_type.
*/

	{
	IGRchar     *name;
	struct GRid *id;

	if ( from_type == to_type )
	   return( OM_S_SUCCESS );

	name = me->names[which_one];
	id = &me->ids[which_one];

	switch ( from_type )
	   {
	   case SHADING_WIN :

	      om$change_class( objid     = id->objid,
	                       osnum     = id->osnum,
	                       classname = "IGEgragad" );
	      name[ strlen(name) - 8 ] = '\0';

	      /* delete the shading information associated with this window */
	      HSdelete( me->wireframe_inst[which_one].gragad.gpipe_id );
	      break;

	   case VISEDGES_WIN :

	      om$change_class( objid     = id->objid,
	                       osnum     = id->osnum,
	                       classname = "IGEgragad" );
	      name[ strlen(name) - 9 ] = '\0';
	      break;

	   }  /* end: switch */

	switch ( to_type )
	   {
	   case SHADING_WIN :

	      om$change_class( objid     = id->objid,
	                       osnum     = id->osnum,
	                       classname = "HSgragad" );
	      sprintf( name, "%s%s", name, "-Shading" );
	      break;

	   case VISEDGES_WIN :

	      om$change_class( objid     = id->objid,
	                       osnum     = id->osnum,
	                       classname = "VEgragad" );
	      sprintf( name, "%s%s", name, "-VisEdges" );
	      break;

	   }  /* end: switch */

	Set_win_name( me->wireframe_inst[which_one].win_no, name );

	return( OM_S_SUCCESS );
	}  /* change_class_and_name */


/*--- swap_names_and_gpipe_ids ------------------------------------------------*/

action swap_names_and_gpipe_ids

/*
DESCRIPTION
	This action swaps the names and gpipe ids in the saved instance data
	for two windows.
*/

	{
	IGRint  temp_id;
	IGRchar temp_name[80];

	/* swap names */
	strcpy( temp_name, me->names[0] );
	strcpy( me->names[0], me->names[1] );
	strcpy( me->names[1], temp_name );

	/* swap gpipe ids */
	temp_id = me->wireframe_inst[0].gragad.gpipe_id;
	me->wireframe_inst[0].gragad.gpipe_id = me->wireframe_inst[1].gragad.gpipe_id;
	me->wireframe_inst[1].gragad.gpipe_id = temp_id;

	return( OM_S_SUCCESS );

	}  /* swap_names_and_gpipe_ids */


/*--- get_or_set_instance_data -------------------------------------------------*/

action get_or_set_instance_data( IGRint get0_set1; IGRint which_id; IGRint which_instance; )

/*
DESCRIPTION
	This action gets/sets the instance data of a window.  The parameter
	which_id is an index into the window id array and is used to determine
	which window to use.  The parameter which_instance is an index into
	the instance data array and is used to determine where the instance data
	should be stored if we are getting instance data or which instance data
	to store in the window if we are setting instance data.
*/

	{
	struct var_list	inq_list[3];
	char            classname[OM_K_MAXCLASS_LEN];
	IGRint          not_exit;
	IGRlong         msg;
	IGRlong         ret_bytes;
	IGRlong         which_error;
	IGRlong         sts;
	struct GRid     *id;

	id = &me->ids[which_id];

	if ( get0_set1 == 0 )
	   {
	   /* determine window type */
	   om$get_classname( classname = classname,
	                     objid     = id->objid,
	                     osnum     = id->osnum );

	   if ( strcmp( classname, "HSgragad" ) == 0 )
	      me->types[which_instance] = SHADING_WIN;
	   else if ( strcmp( classname, "VEgragad" ) == 0 )
	      me->types[which_instance] = VISEDGES_WIN;
	   else
	      me->types[which_instance] = WIREFRAME_WIN;

	   }

	/* get/set wireframe instance */
	inq_list[0].bytes_returned = &ret_bytes;
	if ( get0_set1 == 0 )
	   {
	   inq_list[0].var            = GRAGAD_INST_STRUCT;
	   inq_list[0].var_ptr        = (IGRchar *) &me->wireframe_inst[which_instance];
	   inq_list[0].num_bytes      = sizeof( struct gragad_inst );
	   }
	else
	   {
	   inq_list[0].var            = GRAGAD_STRUCT;
	   inq_list[0].var_ptr        = (IGRchar *) &me->wireframe_inst[which_instance].gragad;
	   inq_list[0].num_bytes      = sizeof( struct DPgra_gad );
	   }


	inq_list[1].var            = GRAGAD_NAME;
	inq_list[1].var_ptr        = me->names[which_instance];
	inq_list[1].num_bytes      = sizeof( me->names[which_instance] );
	inq_list[1].bytes_returned = &ret_bytes;

	inq_list[2].var = END_PARAM;

	sts = dp$inq_set_gragad( msg          = &msg,
	                         inq0_set1    = get0_set1,
	                         osnum        = id->osnum,
	                         gragad_objid = id->objid,
	                         which_error  = &which_error,
	                         var_list     = inq_list );
	
	if ( !(sts & 1))
	   {
	   fprintf( stderr, "HSswapcopy: dp$inq_set_gragad failed\n");
	   om$report_error(sts = sts);
	   return( OM_W_WARNING );
	   }

	if ( me->types[which_instance] == SHADING_WIN )
	   {
	   /* Get/Set Shading window instance */
	   inq_list[0].var            = HS_WINDOW_PARMS;
	   inq_list[0].var_ptr        = (IGRchar *) &me->shading_inst[which_instance];
	   inq_list[0].num_bytes      = sizeof( struct HS_tiler_globals );
	   inq_list[0].bytes_returned = &ret_bytes;

	   inq_list[1].var = END_PARAM;

	   if ( get0_set1 == 0 )
	      {
	      sts = om$send( msg      = message HSgragad.HSinquire( &msg,
	                                                            &which_error,
	                                                            inq_list ),
	                     targetid = id->objid,
	                     targetos = id->osnum );
	      }
	   else
	      {
	      sts = om$send( msg      = message HSgragad.HSset( &msg, &which_error, inq_list ),
	                     targetid = id->objid,
	                     targetos = id->osnum );
	      }

	   if ( !(sts & 1))
	      {
	      fprintf( stderr, "HSswapcopy: HSinquire/HSset failed\n");
	      om$report_error(sts = sts);
	      return( OM_W_WARNING );
	      }

	   }  /* end: shading window */

	else if ( me->types[which_instance] == VISEDGES_WIN )

	   {
	   /* Get/Set Visedges window instance */
	   inq_list[0].var            = VE_WINDOW_PARMS;
	   inq_list[0].var_ptr        = (IGRchar *) &me->visedges_inst[which_instance];
	   inq_list[0].num_bytes      = sizeof( struct VEinstance_data );
	   inq_list[0].bytes_returned = &ret_bytes;

	   inq_list[1].var = END_PARAM;

	   if ( get0_set1 == 0 )
	      {
	      sts = om$send( msg      = message VEgragad.VEinquire( &msg,
	                                                            &which_error,
	                                                            inq_list ),
	                     targetid = id->objid,
	                     targetos = id->osnum );
	      }
	   else
	      {
	      sts = om$send( msg      = message VEgragad.VEset( &msg, &which_error, inq_list ),
	                     targetid = id->objid,
	                     targetos = id->osnum );
	      }

	   if ( !(sts & 1))
	      {
	      fprintf( stderr, "HSswapcopy: VEinquire/VEset failed\n");
	      om$report_error( sts = sts );
	      return( OM_W_WARNING );
	      }

	   }  /* end: VisEdges window */

	return( OM_S_SUCCESS );

	}  /* get_or_set_instance_data */


/*--- process_windows -------------------------------------------------------------*/

action process_windows

/*
DESCRIPTION
	This action does the actual swap/copy of two windows.
*/

	{
	IGRlong           msg;
	IGRint            stat;
	IGRint            i;
	IGRint            vs_no;
	IGRint            win_no;
	IGRint            gpipe_id;
	IGRint            screen_no;
	IGRint            xdits, ydits;
	IGRint            persp_flag;
	IGRint            start;
	IGRboolean        on_left_screen[2];
	IGRboolean        swapping;
	extern IGRboolean HSinit_shading_window();

	swapping = (me->mytype == SWAP);

	/* get the instance data for both windows */
	*sts = om$send( msg      = message HSswapcopy.get_or_set_instance_data( 0, 0, 0 ),
	                targetid = my_id );

	if ( *sts != OM_S_SUCCESS )
	    return( *sts );

	*sts = om$send( msg      = message HSswapcopy.get_or_set_instance_data( 0, 1, 1 ),
	                targetid = my_id );

	if ( *sts != OM_S_SUCCESS )
	    return( *sts );

	on_left_screen[0] = me->wireframe_inst[0].gragad.flags & DPLEFT_SCREEN;
	on_left_screen[1] = me->wireframe_inst[1].gragad.flags & DPLEFT_SCREEN;

	screen_no = (on_left_screen[0]) ? IGE_LEFT_SCREEN : IGE_RIGHT_SCREEN;
	ige$inq_term_info( screen_no = screen_no, vs_no = &vs_no );

	persp_flag = 0;
	if ( me->wireframe_inst[0].gragad.flags & IS_PERSP ) 
	   persp_flag |= 1;
	if ( me->wireframe_inst[1].gragad.flags & IS_PERSP ) 
	   persp_flag |= 2;

	if ( ( (me->types[0] == SHADING_WIN) || (me->types[1] == SHADING_WIN) ) &&
             ( on_left_screen[0] != on_left_screen[1] ) )
	   {
	   /* can't move a shading window across virtual screens */
	   HSnew_vs();
	   return( OM_W_WARNING );
	   }

	if ( swapping )
	   {
	   if ( ( (me->types[0] == SHADING_WIN) && (me->types[1] != SHADING_WIN) ) ||
                ( (me->types[1] == SHADING_WIN) && (me->types[0] != SHADING_WIN) ) )
	      {
	      /* We are swapping a shading and a non-shading window. The      */
	      /* window that is already shading will be made wireframe so     */
	      /* we will try to adjust the size of its Z-buffer to fit the    */
	      /* window that is wireframe and will become shading.  When the  */
	      /* new shading window is updated at the end of this routine, it */
	      /* will be assigned the re-sized Z-buffer because HSURF holds   */
	      /* on to the last buffer that was freed.                        */
	      if ( me->types[0] == SHADING_WIN )
	         {
	         win_no = me->wireframe_inst[0].win_no;
	         gpipe_id = me->wireframe_inst[0].gragad.gpipe_id;
	         xdits = me->wireframe_inst[1].max_x_dep - me->wireframe_inst[1].min_x_dep;
	         ydits = me->wireframe_inst[1].max_y_dep - me->wireframe_inst[1].min_y_dep;
	         }
	      else
	         {
	         win_no = me->wireframe_inst[1].win_no;
	         gpipe_id = me->wireframe_inst[1].gragad.gpipe_id;
	         xdits = me->wireframe_inst[0].max_x_dep - me->wireframe_inst[0].min_x_dep;
	         ydits = me->wireframe_inst[0].max_y_dep - me->wireframe_inst[0].min_y_dep;
	         }

	      if ( ! HSinit_shading_window( vs_no, win_no, gpipe_id, xdits, ydits ) )
	         {
	         /* not enough memory */
	         HSpix_count();
	         return( OM_W_WARNING );
	         }

	      }  /* end: must see if we have Z-buffer space */

	   }  /* end: if ( swapping ) */
	else
	   {
	   if ( (me->types[0] == SHADING_WIN) && (me->types[1] != SHADING_WIN) )
	      {
	      /* We are copying from a shading window to a wireframe window. */
	      /* We must check to see if we have enough memory for a         */
	      /* Z-buffer for the copied window                              */
	      xdits = me->wireframe_inst[1].max_x_dep - me->wireframe_inst[1].min_x_dep + 1;
	      ydits = me->wireframe_inst[1].max_y_dep - me->wireframe_inst[1].min_y_dep + 1;

	      if ( ! HSinit_shading_window( vs_no,
	                                    me->wireframe_inst[1].win_no,
	                                    me->wireframe_inst[1].gragad.gpipe_id,
	                                    xdits, ydits ) )
	         {
	         /* not enough memory */
	         HSpix_count();
	         return( OM_W_WARNING );
	         }

	      }  /* end: must see if we have Z-buffer space */

	   }  /* end: else */

	/* fix the screen flags */
	if ( swapping )
	   {
	   if ( on_left_screen[0] )
	      me->wireframe_inst[1].gragad.flags |= DPLEFT_SCREEN;
	   else
	      me->wireframe_inst[1].gragad.flags &= ~DPLEFT_SCREEN;
	   }

	if ( on_left_screen[1] )
	   me->wireframe_inst[0].gragad.flags |= DPLEFT_SCREEN;
	else
	   me->wireframe_inst[0].gragad.flags &= ~DPLEFT_SCREEN;

	if ( swapping )
	   {
	   *sts = om$send( msg      = message HSswapcopy.change_class_and_name( 0,
	                                                                        me->types[0],
	                                                                        me->types[1] ),
	                   targetid = my_id );
	   }

	*sts = om$send( msg      = message HSswapcopy.change_class_and_name( 1,
	                                                                     me->types[1],
	                                                                     me->types[0] ),
	                targetid = my_id );


	*sts = om$send( msg      = message HSswapcopy.swap_names_and_gpipe_ids( &stat ),
	                targetid = my_id );

	/* save instance data in windows */
	if ( swapping )
	   {
	   *sts = om$send( msg      = message HSswapcopy.get_or_set_instance_data( 1, 0, 1 ),
	                   targetid = my_id );
	   }

	*sts = om$send( msg      = message HSswapcopy.get_or_set_instance_data( 1, 1, 0 ),
	                targetid = my_id );


	start = (swapping) ? 0 : 1;

	/* have windows re-calculate their data */
	for ( i = start; i < 2; i++ )
	   {
	   *sts = om$send( msg      = message IGEgragad.DPcal( &msg ),
	                   targetid = me->ids[i].objid,
	                   targetos = me->ids[i].osnum );
	   }


	/* fix perspective mode of the windows */
	if ( persp_flag == 1 )
	   {
	   /* window 0 was perspective and window 1 wasn't */
	   if ( swapping )
	      {
	      dp$un_persp( msg = &msg, gg_id = &me->ids[0] );
	      }

	   dp$set_persp( msg = &msg, gg_id = &me->ids[1], in_flags = DP_CVT_WN_ONLY );
	   }
	else if ( persp_flag == 2 )
	   {
	   /* window 1 was perspective and window 0 wasn't */
	   dp$un_persp( msg = &msg, gg_id = &me->ids[1] );

	   if ( swapping )
	      {
	      dp$set_persp( msg = &msg, gg_id = &me->ids[0], in_flags = DP_CVT_WN_ONLY );
	      }
	   }
	   
	/* update windows */
	for ( i = start; i < 2; i++ )
	   {
	   dp$gen_update( msg = &msg, objid = me->ids[i].objid, osnum = me->ids[i].osnum );
	   }

	return( OM_S_SUCCESS );

	}  /* process_windows */
