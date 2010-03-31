 
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>
#include "wl.h"

#include "exmacros.h"
#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igewinmacros.h"

#include "msdef.h"
#include "msmacros.h"

#include "godef.h"
#include "gr.h"

#include "igr.h"
#include "igrdp.h"

#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"

#include "dl.h"

#include "hsmacdef.h"
#include "hswinmacros.h"
#include "hsurf.h"
#include "hsdef.h"
#include "hsurferrpriv.h"
#include "hsmsg.h"

#include "vewinmacros.h"

#include "hslight.h"

#include "HSpr_dpb_imp.h"
#include "HSpr_gragad.h"

extern void HSdelete( IGRint pipe_no );

#if defined(__STDC__) || defined(__cplusplus)
    extern IGRlong HSget_saved_instance_id( IGRlong *msg,
	   OM_S_OBJID win_id,
           OMuword win_os,
           OM_S_OBJID *instance_id );
#else  
    extern IGRlong HSget_saved_instance_id( msg, win_id, win_os, instance_id )
            IGRlong    *msg;
            OM_S_OBJID win_id;
            OMuword    win_os;
            OM_S_OBJID *instance_ id;  
#endif

#if defined(__STDC__)
     extern IGRlong VEconvert_ve_win_to_wireframe(
	      IGRlong    *msg,
              OM_S_OBJID win_id,
	      OMuword    win_os );
#else
     extern IGRlong VEconvert_ve_win_to_wireframe( msg, win_id, win_os )
              IGRlong    *msg;
              OM_S_OBJID win_id;
	      OMuword    win_os;
#endif

/*-------------------------------
 *  for functions
 *     HSactivate_window
 *     HSinit_shading_window
 *     HSset_active_max_z
 */
 
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

#include "dpmacgenupd.h"

extern int DPsetinqgragad ( 
   IGRlong *msg,
   IGRchar inq0_set1,
   IGRlong *which_error,
   struct  var_list *list,
   GRspacenum osnum,
   GRobjid gragad_objid,
   IGRchar calc_info,
   IGRchar update );

/*-------------------------------
 *  for functions
 *     HSnot_enough_planes_to_shade
 *     HSpix_count
 */
 
%safe
#include "HSpr_co_func.h"
%endsafe

/*------------------------------*/


extern OMuword OPP_IGEgragad_class_id;
extern OMuword OPP_VEgragad_class_id;

from HSgragad import HSsave_instance, HSrestore_instance;
from IGEgragad import DPcal;
from IGEgragad import DPshading_allowed;


/*--- HSconvert_shading_window_to_wireframe -------------------------------------------------*/

IGRlong HSconvert_shading_window_to_wireframe(
   IGRlong *msg,
   OM_S_OBJID win_id,
   OMuword win_os,
   IGRint update,
   IGRint display_message )

/*
NAME
	HSconvert_shading_window_to_wireframe

DESCRIPTION
	This function changes a shading window to a wireframe window
	by changing the class of the window and deleting the internal
	tiling structures for it.

PARAMETERS
	msg (OUT) - error return code, MSSUCC if function was successful
	win_id (IN) - object id of window to convert from shading to wireframe
	win_os (IN) - object space number of window
	update (IN) - if TRUE, then window will be updated after conversion
	display_message (IN) - if TRUE, a message will be displayed indicating the conversion

RETURN VALUES
	0 - if successful
	1 - otherwise

GLOBALS USED
	active_window - indirectly changed

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong         msg2;
	IGRlong         sts;
	IGRlong         ret_bytes;
	IGRlong         which_error;
	IGRint          win_no;
	IGRint          gpipe_id;
	IGRshort        display_mode;
	OMuword         classid;
	struct var_list var_list[4];
	IGRlong vol_msg = MSSUCC;

	*msg = MSSUCC;

if (  ex$is_batch() )
   {
      *msg = MSFAIL;
	   return( 1 );
   }

	om$get_classid( objid = win_id, osnum = win_os, p_classid = &classid );

	if ( om$is_ancestry_valid( subclassid = classid,
	                           superclassid = OPP_HSgragad_class_id ) != OM_S_SUCCESS )
	   {
	   *msg = MSFAIL;
	   return( 1 );
	   }

	if ( display_message )
	   {
	   ex$message( field = KEYIN_FIELD, msgnumb = HS_I_ShdToWire, justification = CENTER_JUS );
	   }

	/* get needed window information */
	var_list[0].var             = DISPLAY_MODE;
	var_list[0].var_ptr         = (IGRchar *) &display_mode;
	var_list[0].num_bytes       = sizeof( display_mode );
	var_list[0].bytes_returned  = &ret_bytes;
	var_list[1].var             = WIN_NO;
	var_list[1].var_ptr         = (IGRchar *) &win_no;
	var_list[1].num_bytes       = sizeof( IGRint );
	var_list[1].bytes_returned  = &ret_bytes;
	var_list[2].var             = GPIPE_ID;
	var_list[2].var_ptr         = (IGRchar *) &gpipe_id;
	var_list[2].num_bytes       = sizeof( IGRint );
	var_list[2].bytes_returned  = &ret_bytes;
	var_list[3].var             = END_PARAM;

	dp$inq_set_gragad( msg          = msg,
	                   inq0_set1    = 0,
	                   osnum        = win_os,
	                   gragad_objid = win_id,
	                   which_error  = &which_error,
	                   var_list     = var_list );

        MSG_ERRCHK( *msg, "HSconvert_shading_window_to_wireframe: dp$inq_set_gragad failed" );

	HSrestore_window_context( win_no, win_id, win_os);

	/* save the shading window's instance data */
	sts = om$send( msg      = message HSgragad.HSsave_instance( &msg2 ),
	               targetid = win_id,
	               targetos = win_os,
	               senderid = NULL_OBJID );

        OM_ERRCHK( sts, "HSconvert_shading_window_to_wireframe: HSgragad.HSsave_instance send failed" );

	HSactivate_window( gpipe_id );
	HSdelete( gpipe_id );

	/* change shading window to wireframe */
	sts = om$change_class( objid = win_id, osnum = win_os, classname = "IGEgragad" );

	   OM_ERRCHK( sts, "HSconvert_shading_window_to_wireframe: om$change_class failed" );

	/* set the display_mode to wireframe in the window */
	var_list[1].var = END_PARAM;
	display_mode = 0;
	dp$inq_set_gragad( msg          = msg,
	                   inq0_set1    = 1,
	                   osnum        = win_os,
	                   gragad_objid = win_id,
	                   which_error  = &which_error,
	                   var_list     = var_list );

	    MSG_ERRCHK( *msg, "HSconvert_shading_window_to_wireframe: dp$inq_set_gragad failed" );

        /* reset to wireframe state in DL */
        DLreset_for_wireframe( gpipe_id );

	if ( update )
	   {
	   dp$gen_update( msg = msg, objid = win_id, osnum = win_os );
	   }

	if ( display_message )
	   {
	   ex$message( field = KEYIN_FIELD, in_buff = "" );
	   }

	sts = om$send(mode = OM_e_wrt_message,
                             msg = message IGEgragad.DPcal(&vol_msg),
                             senderid = NULL_OBJID,
                             targetid = NULL_OBJID);

	return( (*msg == MSSUCC) ? 0 : 1 );

	}  /* HSconvert_shading_window_to_wireframe */


/*--- HSconvert_wireframe_window_to_shading ---------------------------------*/

IGRlong HSconvert_wireframe_window_to_shading(
   IGRlong *msg,
   OM_S_OBJID win_id,
   OMuword win_os,
   IGRint update,
   IGRint display_message,
   IGRuchar shading_style,
   IGRint x_dits,
   IGRint y_dits )

/*
NAME
	HSconvert_wireframe_window_to_shading

DESCRIPTION
	This function changes a wireframe window to a shading window by
	changing the class of the window and initializing the internal
	tiling structures for the window.

PARAMETERS
	msg (OUT) - error return code, MSSUCC if function was successful
	win_id (IN) - object id of window to convert from wireframe to shading
	win_os (IN) - object space number of window
	update (IN) - if TRUE, then window will be updated after conversion
	display_message (IN) - if TRUE, a message will be displayed indicating the conversion
	shading_style (IN) - the shading style of the window
	x_dits (IN) - the size in dits to activate (if -1, use whole window)
	y_dits (IN) - the size in dits to activate (if -1, use whole window)

RETURN VALUES
	0 - if successful
	1 - otherwise

GLOBALS USED
	active_window - indirectly changed

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
	05/08/92    S.P. Rogers
	   Added check to see if window allows itself to be shaded
*/

	{
	IGRlong                        msg2;
	IGRlong                        sts;
	IGRlong                        ret_bytes;
	IGRlong                        which_error;
	OMuword                        classid;
	struct HStotal_window_instance total_instance;
	struct var_list	               hs_var_list[2], dp_var_list[4];
	IGRshort                       display_mode;
	struct gragad_inst             gragad_instance;
	IGRboolean                     flag = FALSE;
	IGRboolean	               enough_memory;
	IGRboolean	               enough_planes;
	OM_S_OBJID                     hs_inst_id;
	IGRchar                        gragad_name[GRNAME_SIZE];
	WLuint16 lscreen_no;
	WLuint32 context_no;
	int depth;

	*msg = MSSUCC;

   if (  ex$is_batch() )
   {
      *msg = MSFAIL;
	   return( 1 );
   }
	om$get_classid( objid = win_id, osnum = win_os, p_classid = &classid );

	if ( om$is_ancestry_valid( subclassid = classid,
	                           superclassid = OPP_IGEgragad_class_id ) != OM_S_SUCCESS )
	   {
	   *msg = MSFAIL;
	   return( 1 );
	   }

	/* see if window can be shaded */
	om$send( msg      = message IGEgragad.DPshading_allowed( &flag ),
	         targetid = win_id,
	         targetos = win_os,
	         senderid = NULL_OBJID );

	if ( ! flag )
	   {
	   *msg = MSFAIL;
	   return( 1 );
	   }

	/* get the needed instance data */
	dp_var_list[0].var            = DISPLAY_MODE;
	dp_var_list[0].var_ptr        = (IGRchar *) &display_mode;
	dp_var_list[0].num_bytes      = sizeof( display_mode );
	dp_var_list[0].bytes_returned = &ret_bytes;

	dp_var_list[1].var            = GRAGAD_INST_STRUCT;
	dp_var_list[1].var_ptr        = (IGRchar *) &gragad_instance;
	dp_var_list[1].num_bytes      = sizeof( struct gragad_inst );
	dp_var_list[1].bytes_returned = &ret_bytes;

	dp_var_list[2].var            = GRAGAD_NAME;
	dp_var_list[2].var_ptr        = (IGRchar *) gragad_name;
	dp_var_list[2].num_bytes      = sizeof( gragad_name );
	dp_var_list[2].bytes_returned = &ret_bytes;

	dp_var_list[3].var            = END_PARAM;

	dp$inq_set_gragad( msg          = msg,
	                   inq0_set1    = 0,
	                   osnum        = win_os,
	                   gragad_objid = win_id,
	                   which_error  = &which_error,
	                   var_list     = dp_var_list );

	enough_memory = TRUE;
	enough_planes = TRUE;

        WLget_window_screen( gragad_instance.win_no, &lscreen_no );
	WLget_window_base_context( gragad_instance.win_no, &context_no );
	WLget_context_depth( context_no, &depth );
	
        if (depth < 3)
	   enough_planes = FALSE;
	else
	   {
	   /* Attempt to initialize the window for shading. */
	   /* This will simply try to allocate memory for   */
	   /* shading window.                               */
					 
	   HSset_active_max_z( gragad_instance.gragad.gpipe_id, shading_style, FALSE, 5 );

	   if ((x_dits==-1)||(y_dits==-1))
	   {
		x_dits = (gragad_instance.max_x_dep - gragad_instance.min_x_dep) + 1;
	   	y_dits = (gragad_instance.max_y_dep - gragad_instance.min_y_dep) + 1;
           } /* else the values were sent in by parameter (like disp region)*/
					
	   enough_memory = HSinit_shading_window( lscreen_no,
	                                          gragad_instance.win_no,
	                                          gragad_instance.gragad.gpipe_id,
	                                          x_dits, y_dits, shading_style,
                                                  win_id, win_os );
	   }

	if ( ! enough_planes )
	   {
	   HSnot_enough_planes_to_shade( gragad_name );
	   *msg = MSFAIL;
	   return( 1 );
	   }
	else if ( ! enough_memory )
	   {
	   HSpix_count();
	   *msg = MSFAIL;
	   return( 1 );
	   }

	if ( display_message )
	   {
	   ex$message( field = KEYIN_FIELD, msgnumb = HS_I_WireToShd, justification = CENTER_JUS );
	   }

	if ( classid == OPP_VEgragad_class_id )
	   {
	   /* convert VE window to wireframe */
	   ve$convert_ve_win_to_wireframe( msg = msg,
	                                   win_id = win_id,
	                                   win_os = win_os );
	   }

	hs$get_saved_instance_id( msg = msg,
	                          win_id = win_id,
	                          win_os = win_os,
	                          instance_id = &hs_inst_id );

	/* change wireframe window to shading */
	sts = om$change_class( objid = win_id, osnum = win_os, classname = "HSgragad" );

	   OM_ERRCHK( sts, "HSconvert_wireframe_window_to_shading: om$change_class failed" );

	hs_var_list[0].var             = HS_TOTAL_INSTANCE;
	hs_var_list[0].var_ptr         = (IGRchar *) &total_instance;
	hs_var_list[0].num_bytes       = sizeof( struct HStotal_window_instance );
	hs_var_list[0].bytes_returned  = &ret_bytes;
	hs_var_list[1].var             = END_PARAM;

	if ( hs_inst_id != NULL_OBJID )
	   {
	   /* restore the shading window's instance data from the HSinstance object */

	   sts = om$send( msg      = message HSgragad.HSrestore_instance( &msg2 ),
	                  targetid = win_id,
	                  targetos = win_os,
	                  senderid = NULL_OBJID );

	      OM_ERRCHK( sts, "HSconvert_wireframe_window_to_shading: HSgragad.HSrestore_instance send failed" );

	   /* change the shading style of the window */

	   hs$get_window_instance_data( msg = msg,
	                                win_id = win_id,
	                                win_os = win_os,
	                                which_error = &which_error,
	                                var_list = hs_var_list );

	   total_instance.shading_style = shading_style;

	   hs$set_window_instance_data( msg = msg,
	                                win_id = win_id,
	                                win_os = win_os,
	                                which_error = &which_error,
	                                var_list = hs_var_list );
	   }
	else
	   {
	   /* load default instance data into HSgragad */

	   HSget_default_instance( msg, &which_error, hs_var_list );

	   total_instance.shading_style = shading_style;

	   hs$set_window_instance_data( msg = msg,
	                                win_id = win_id,
	                                win_os = win_os,
	                                which_error = &which_error,
	                                var_list = hs_var_list );
	   }

	display_mode = 1;
	dp_var_list[1].var = END_PARAM;

	dp$inq_set_gragad( msg          = msg,
	                   inq0_set1    = 1,
	                   osnum        = win_os,
	                   gragad_objid = win_id,
	                   which_error  = &which_error,
	                   var_list     = dp_var_list,
	                   update       = update,
	                   calc_info    = TRUE );

	if ( display_message )
	   {
	   ex$message( field = KEYIN_FIELD, in_buff = "" );
	   }

	return( (*msg == MSSUCC) ? 0 : 1 );
	}  /* HSconvert_wireframe_window_to_shading */

end implementation Root;
