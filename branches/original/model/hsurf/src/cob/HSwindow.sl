
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/


/*
	This file defines an abstract command object class for all of
	the HSURF commands that have to select windows.  It implements
	a single action that all of the commands can use to process
	the input received from the user to select a window or group
	of windows.

	There is no command table entry for this file.
*/

class              HSwindow
super_class        CEO_GSLOCATE
command_string     HSM_M_DisplMode,0,HSwindow
product_name       "$MODEL"
start_state        terminate
options            "t"         /* don't create a .T file */

specification

instance
	{
	IGRint	     num_win_ids;
	struct GRid  win_ids[40];
	IGRboolean   change_made;
	}

implementation

/*#include "hsurf_import.h"*/
#include "stdlib.h"
#include "math.h"
#include "igrtypedef.h"

#include "stdio.h"

#include "igewindef.h"

#include "fontdef.h"
#include "font.h"

#include "godef.h"
#include "griodef.h"

#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "exdef.h"

#include "msdef.h"
#include "msmacros.h"

#include "hsmsg.h"

from IGEgragad import DPshading_allowed, DPhidden_line_allowed;

/*--- get_selected_window -----------------------------------------*/

action get_selected_window( IGRint *sts; IGRint any0_shading1; IGRint single_window;
	                    IGRint validate_for_shading; IGRint validate_for_hidden_line )

/*
NAME
	HSwindow.get_selected_winow

DESCRIPTION
	This action gets the GRid(s) for the window(s) selected by the user.
	The number of windows selected is stored in me->num_win_ids and the
	window GRid(s) are stored in me->win_ids.  The *sts parameter is set
	to OM_S_SUCCESS if at least one valid window was selected.  If no
	valid windows were selected, *sts is set to OM_W_WARNING and an error
	message is displayed.

PARAMETERS
	sts (OUT) - status return
	any0_shading1 (IN) - if 0, then any class of windows can be selected
	                     if 1, then only shading windows are selected
	single_window (IN) - if TRUE, then only a single window can be selected
	validate_for_shading (IN) - if TRUE, then only windows that will allow
	                            shading are selected
	validate_for_hidden_line (IN) - if TRUE, then only windows that will
	                                allow hidden line are selected

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
	05/08/92    S.P. Rogers
	    Added validate_for_shading and validate_for_hidden_line
	    parameters
*/

	{
	IGRlong         msg;
	IGRboolean      flag;
	IGRboolean	shading_not_allowed = FALSE, hidden_line_not_allowed = FALSE;
	IGRlong         total_found;
	IGRint          num_ids;
	IGRint          keep_count;
	IGRint          ii;
	IGRint          message_no = 0;
	struct GRid     window_ids[40];
	IGRchar         classname[OM_K_MAXCLASS_LEN];
	IGRlong 	ret_bytes;
	IGRlong		which_error;
	struct var_list var_list[2];
	IGRchar         gragad_name[GRNAME_SIZE];


	*sts = OM_S_SUCCESS;

	if ( me->event1.response == EX_DATA )
	   {
	   /* user hit a data button in a window */
	   num_ids = 1;
	   window_ids[0].objid = me->event1.event.button.objid;
	   window_ids[0].osnum = me->event1.event.button.osnum;
	   }
	else
	   {
	   /* user keyed in a window name */
	   if ( strlen( me->event1.event.keyin ) == 0 )
	      {
	      /* Invalid window */
	      *sts = OM_W_WARNING;
	      message_no = HS_E_WinNotFound;
	      }
	   else
	      {
	      num_ids = 0;

	      /* get the window id(s) from the string, but only */
	      /* accept windows that are ON.                    */
	      dp$get_gragad_id( msg         = &msg,
	                        name        = me->event1.event.keyin,
                                array_size  = 40,
                                total_num   = &total_found,
	                        numberofids = &num_ids,
	                        found_GRids = window_ids,
	                        type_gragad = (ALL_GG_CLASSES | GG_WIN_ON) );

	      if ( num_ids == 0 )
	         {
	         /* Invalid window */
	         *sts = OM_W_WARNING;
	         message_no = HS_E_WinNotFound;
	         }

	      }

	   }  /* end: else */

	if ( *sts == OM_S_SUCCESS )
	   {
	   if ( validate_for_shading )
	      {
	      /* make sure all selected windows allow shading */
	      for ( keep_count = ii = 0; ii < num_ids; ii++ )
	         {
	         om$send( msg      = message IGEgragad.DPshading_allowed( &flag ),
	                  targetid = window_ids[ii].objid,
	                  targetos = window_ids[ii].osnum );

	         if ( flag )
	            window_ids[keep_count++] = window_ids[ii];
	         else
	            shading_not_allowed = TRUE;
	         }  /* end: for */
	      num_ids = keep_count;
	      }

	   if ( validate_for_hidden_line )
	      {
	      /* make sure all selected windows allow shading */
	      for ( keep_count = ii = 0; ii < num_ids; ii++ )
	         {
	         om$send( msg      = message IGEgragad.DPhidden_line_allowed( &flag ),
	                  targetid = window_ids[ii].objid,
	                  targetos = window_ids[ii].osnum );

	         if ( flag )
	            window_ids[keep_count++] = window_ids[ii];
	         else
	            hidden_line_not_allowed = TRUE;
	         }  /* end: for */
	      num_ids = keep_count;
	      }

	   if ( any0_shading1 == 0 )
	      {
	      /* keep all selected windows */
	      me->num_win_ids = num_ids;
	      for ( ii = 0; ii < num_ids; ii++ )
	         me->win_ids[ii] = window_ids[ii];
	      }
	   else
	      {
	      /* only accept shaded windows */
	      for ( keep_count = ii = 0; ii < num_ids; ii++ )
	         {
	         /* get the classname of the window */
	         om$get_classname( objid     = window_ids[ii].objid,
	                           osnum     = window_ids[ii].osnum,
	                           classname = classname );

	         if ( strcmp( classname, "HSgragad" ) == 0 )
	            me->win_ids[keep_count++] = window_ids[ii];

	         }  /* end: for */

	      me->num_win_ids = keep_count;
	      }  /* end: else */
	
	   /* throw out the default view if it was selected */
	   var_list[0].var            = GRAGAD_NAME;
	   var_list[0].var_ptr        = gragad_name;
	   var_list[0].num_bytes      = sizeof( gragad_name );
	   var_list[0].bytes_returned = &ret_bytes;
	   var_list[1].var            = END_PARAM;

	   for ( keep_count = ii = 0; ii < me->num_win_ids; ii++ )
	      {
	      dp$inq_set_gragad( msg          = &msg,
	                         inq0_set1    = 0,
	                         osnum        = me->win_ids[ii].osnum,
	                         gragad_objid = me->win_ids[ii].objid,
	                         which_error  = &which_error,
	                         var_list     = var_list );
	
	      if ( strcmp( gragad_name, ".GRdefaultview" ) )
	         me->win_ids[keep_count++] = me->win_ids[ii];
	      }
	   me->num_win_ids = keep_count;

	   if ( me->num_win_ids == 0 )
	      {
	      *sts = OM_W_WARNING;
	      if ( shading_not_allowed )
	         message_no = HS_E_NoShading;
	      else if ( hidden_line_not_allowed )
	         message_no = HS_E_NoHiddenLine;
	      else
	         message_no = HS_E_InvWindow;
	      }
	   else if ( (single_window) && (me->num_win_ids > 1) )
	      {
	      *sts = OM_W_WARNING;
	      message_no = HS_E_WinAmbig;
	      }

	   }  /* end: if ( *sts == OM_S_SUCCESS ) */

	if ( *sts == OM_W_WARNING )
	   {
	   ex$message( msgnumb = message_no );
	   sleep( 3 );
	   ex$message( in_buff = "", field = ERROR_FIELD );
	   }

	}  /* get_selected_window */


/*--- get_windows -----------------------------------------*/

action get_windows( IGRint *sts; IGRint win_types;
	            IGRint validate_for_shading; IGRint validate_for_hidden_line )

/*
NAME
	HSwindow.get_windows

DESCRIPTION
	This action gets the GRid(s) for the window(s) based on window types.
	The number of windows selected is stored in me->num_win_ids and the
	window GRid(s) are stored in me->win_ids.  The *sts parameter is set
	to OM_S_SUCCESS if at least one valid window was selected.  If no
	valid windows were selected, *sts is set to OM_W_WARNING.

PARAMETERS
	sts (OUT) - status return
	win_types (IN) - bit mask of what kind of windows to select with the
	                 defines for the bits in dpdef.h
	validate_for_shading (IN) - if TRUE, then only windows that will allow
	                            shading are selected
	validate_for_hidden_line (IN) - if TRUE, then only windows that will
	                                allow hidden line are selected

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
	05/08/92    S.P. Rogers
	    Added validate_for_shading and validate_for_hidden_line
	    parameters
*/

	{
	IGRlong         msg;
	IGRboolean	flag;
	IGRboolean	shading_not_allowed = FALSE, hidden_line_not_allowed = FALSE;
	IGRlong         total_found;
	IGRint          keep_count;
	IGRint          ii;
	IGRint          message_no = 0;
	IGRlong 	ret_bytes;
	IGRlong		which_error;
	struct var_list var_list[2];
	IGRchar         gragad_name[GRNAME_SIZE];


	*sts = OM_S_SUCCESS;
	me->num_win_ids = 0;

	/* get the window id(s) from the string */
	dp$get_gragad_id( msg         = &msg,
	                  name        = "*",
                          array_size  = 40,
                          total_num   = &total_found,
	                  numberofids = &me->num_win_ids,
	                  found_GRids = me->win_ids,
	                  type_gragad = win_types );

	if ( me->num_win_ids == 0 )
	   *sts = OM_W_WARNING;

	if ( *sts == OM_S_SUCCESS )
	   {
	   if ( validate_for_shading )
	      {
	      /* make sure all selected windows allow shading */
	      for ( keep_count = ii = 0; ii < me->num_win_ids; ii++ )
	         {
	         om$send( msg      = message IGEgragad.DPshading_allowed( &flag ),
	                  targetid = me->win_ids[ii].objid,
	                  targetos = me->win_ids[ii].osnum );

	         if ( flag )
	            me->win_ids[keep_count++] = me->win_ids[ii];
	         else
	            shading_not_allowed = TRUE;
	         }  /* end: for */
	      me->num_win_ids = keep_count;
	      }

	   if ( validate_for_hidden_line )
	      {
	      /* make sure all selected windows allow shading */
	      for ( keep_count = ii = 0; ii < me->num_win_ids; ii++ )
	         {
	         om$send( msg      = message IGEgragad.DPhidden_line_allowed( &flag ),
	                  targetid = me->win_ids[ii].objid,
	                  targetos = me->win_ids[ii].osnum );

	         if ( flag )
	            me->win_ids[keep_count++] = me->win_ids[ii];
	         else
	            hidden_line_not_allowed = TRUE;
	         }  /* end: for */
	      me->num_win_ids = keep_count;
	      }

	   /* throw out the default view if it was selected */
	   var_list[0].var            = GRAGAD_NAME;
	   var_list[0].var_ptr        = gragad_name;
	   var_list[0].num_bytes      = sizeof( gragad_name );
	   var_list[0].bytes_returned = &ret_bytes;
	   var_list[1].var            = END_PARAM;

	   for ( keep_count = ii = 0; ii < me->num_win_ids; ii++ )
	      {
	      dp$inq_set_gragad( msg          = &msg,
	                         inq0_set1    = 0,
	                         osnum        = me->win_ids[ii].osnum,
	                         gragad_objid = me->win_ids[ii].objid,
	                         which_error  = &which_error,
	                         var_list     = var_list );
	
	      if ( strcmp( gragad_name, ".GRdefaultview" ) )
	         me->win_ids[keep_count++] = me->win_ids[ii];
	      }

	   me->num_win_ids = keep_count;

	   if ( me->num_win_ids == 0 )
	      {
	      if ( shading_not_allowed )
	         message_no = HS_E_NoShading;
	      else if ( hidden_line_not_allowed )
	         message_no = HS_E_NoHiddenLine;
	      else
	         message_no = HS_E_InvWindow;
	         
	      ex$message( msgnumb = message_no );
	      sleep( 3 );
	      ex$message( in_buff = "", field = ERROR_FIELD );

	      *sts = OM_W_WARNING;
	      }

	   }

	}  /* get_windows */

