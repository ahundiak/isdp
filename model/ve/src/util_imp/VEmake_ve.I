
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 1

#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"

#include "msdef.h"
#include "msmacros.h"

#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"

#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "vedef.h"
#include "ve.h"
#include "veerr.h"
#include "vewinmacros.h"

#include "hswinmacros.h"

/* prototype files */
#include "VEpr_utilimp.h"

#include "DPsetinq.h"

from IGEgragad import DPhidden_line_allowed;
from VEgragad  import VErestore_instance, VEsave_instance;

extern OMuword OPP_HSgragad_class_id;


/*--- VEmake_win_ve -------------------------------------------------------*/

#if defined(__STDC__)
IGRlong VEmake_win_ve(  IGRlong    *msg,
			OM_S_OBJID win_id,
			OMuword    win_os,
			IGRint     display_message )
#else
IGRlong VEmake_win_ve( msg, win_id, win_os, display_message )

	IGRlong    *msg;
	OM_S_OBJID win_id;
	OMuword    win_os;
	IGRint     display_message;
#endif

/*
NAME
	VEmake_win_ve

DESCRIPTION
	This function changes a wireframe or shading window to a Visible
	Edges window by changing the class and the name of the window.

PARAMETERS
	msg (OUT) - status indicator
	win_id (IN) - the object id of the window to convert to VE
	win_os (IN) - the object space number of the window to convert
	display_message (IN) - if TRUE, a message is displayed if the window
	                       is converted from shading to VE

GLOBALS USED
	none

RETURN VALUES
	0 - if successful
	1 - if a failure occured
	
HISTORY
	02/20/90    S.P. Rogers
	   Creation Date
	05/11/92    S.P. Rogers
	   Added check to make sure window supports hidden line
	   processing
*/

	{
	IGRlong         sts;
	IGRlong         ret_bytes;
	IGRlong         which_error;
	IGRboolean      flag;
	IGRint          win_no;
	IGRint          gpipe_id;
	IGRchar         gragad_name[GRNAME_SIZE];
	OMuword         classid;
	struct var_list var_list[4];

	*msg = MSSUCC;

	/* see if window supports hidden line */
	flag = FALSE;
	om$send( msg      = message IGEgragad.DPhidden_line_allowed( &flag ),
	         targetid = win_id,
	         targetos = win_os,
	         senderid = NULL_OBJID );

	if ( ! flag )
	   {
	   *msg = MSFAIL;
	   return( 1 );
	   }

	om$get_classid( objid = win_id, osnum = win_os, p_classid = &classid );

	/* get the name, window number and gpipe id of the window */
	var_list[0].var             = GRAGAD_NAME;
	var_list[0].var_ptr         = gragad_name;
	var_list[0].num_bytes       = sizeof( gragad_name );
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

	    MSG_ERRCHK( *msg, "VEmake_win_ve: dp$inq_set_gragad failed" );

	if ( om$is_ancestry_valid( subclassid = classid,
	                           superclassid = OPP_VEgragad_class_id ) != OM_S_SUCCESS )
	   {
	   if ( om$is_ancestry_valid( subclassid = classid,
	                              superclassid = OPP_HSgragad_class_id ) == OM_S_SUCCESS )
	      {
	      /* converting shading window to a VE window */

	      /* have shading window save its instance data */
	      hs$convert_shading_window_to_wireframe( msg = msg,
	                                              win_id = win_id,
	                                              win_os = win_os,
	                                              update = FALSE,
	                                              display_message = display_message );
	      }

	   /* change wireframe window to visible edges */
	   sts = om$change_class( objid = win_id, osnum = win_os, classname = "VEgragad" );

	      OM_ERRCHK( sts, "VEmake_win_ve: om$change_class failed" );

	   /* send VErestore_instance to window so its instance data will be set */
	   sts = om$send( msg      = message VEgragad.VErestore_instance( msg ),
	                  targetid = win_id,
	                  targetos = win_os,
	                  senderid = NULL_OBJID );

	      OM_ERRCHK( sts, "VEmake_win_ve: VEgg_construct send failed" );

	   }  /* end:  selected gragad was not already a VEgragad */

	return( (*msg == MSSUCC) ? 0 : 1 );
	}  /* VEmake_win_ve */


/*--- VEconvert_ve_win_to_wireframe --------------------------------------------------*/

#if defined(__STDC__)
IGRlong VEconvert_ve_win_to_wireframe(  IGRlong    *msg,
					OM_S_OBJID win_id,
					OMuword    win_os )
#else
IGRlong VEconvert_ve_win_to_wireframe( msg, win_id, win_os )

	IGRlong    *msg;
	OM_S_OBJID win_id;
	OMuword    win_os;
#endif

/*
NAME
	VEconvert_ve_win_to_wireframe

DESCRIPTION
	This function changes a Visible Edges window to a wireframe window by
	changing the class and the name of the window.

PARAMETERS
	msg (OUT) - status indicator
	win_id (IN) - the object id of the window to convert to VE
	win_os (IN) - the object space number of the window to convert

GLOBALS USED
	none

RETURN VALUES
	0 - if successful
	1 - if a failure occured

HISTORY
	04/19/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong           sts;
	OMuword           classid;

	*msg = MSSUCC;

	om$get_classid( objid = win_id, osnum = win_os, p_classid = &classid );

	if ( classid == OPP_VEgragad_class_id )
	   {
	   /* window is a VE window => change it to wireframe */

	   /* have the VEgragad save its instance data as a VEinstance object */
	   sts = om$send( msg      = message VEgragad.VEsave_instance( msg ),
	                  targetid = win_id,
	                  targetos = win_os,
	                  senderid = NULL_OBJID );

	   /* change visible edges window to wireframe */
	   sts = om$change_class( objid = win_id, osnum = win_os, classname = "IGEgragad" );

	      OM_ERRCHK( sts, "VEconvert_ve_win_to_wireframe: om$change_class failed" );
	   }  /* end: if ( window is a VEgragad ) */
	else
	   *msg = MSFAIL;

	return( (*msg == MSSUCC) ? 0 : 1 );
	}  /* VEconvert_ve_win_to_wireframe */


end implementation Root;
