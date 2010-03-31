class implementation HSwindow;



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



method get_selected_window ( IGRint *sts; IGRint any0_shading1; IGRint single_window;
	                    IGRint validate_for_shading; IGRint validate_for_hidden_line )
{
  int		  status = OM_S_SUCCESS;

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

	quit:
  return OM_S_SUCCESS;
}

method get_windows ( IGRint *sts; IGRint win_types;
	            IGRint validate_for_shading; IGRint validate_for_hidden_line )
{
  int		  status = OM_S_SUCCESS;

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

	quit:
  return OM_S_SUCCESS;
}

end implementation HSwindow;
